//
//  MaptimizeService.m
//  Bredbandskollen
//
//  Created by Aleks Nesterow on 8/11/09.
//  aleks.nesterow@gmail.com
//  
//  Copyright © 2009 Screen Customs s.r.o. All rights reserved.
//  

#import "ASIHTTPRequest.h"
#import "JSON.h"

//#import "MbpsCluster.h"
//#import "MbpsMarker.h"
//#import "KartaEntitiesConverter.h"
//#import "NetworkErrors.h"

#import "MaptimizeService.h"

//#import "SCLog.h"
//#import "SCMemoryManagement.h"

@interface MaptimizeService (PrivateMethods)

- (void)makeRequest:(SEL)requestDoneSelector apiUrl:(NSString *)apiUrl clusterizeAtRegion:(MKCoordinateRegion)region andViewportSize:(CGSize)viewportSize
		  withModel:(PhoneModel)model conditionPlacering:(Placering)placering andOperator:(Operator)operator;
- (void)processResponse:(ASIHTTPRequest *)request requestType:(RequestType)requestType;
- (BOOL)verifyGraph:(NSDictionary *)graph;

@end

@implementation MaptimizeService

@synthesize delegate = _delegate, entitiesConverter = _entitiesConverter;
@synthesize groupingDistance = _groupingDistance;

- (id)init {

	if (self = [super init]) {
		_queue = [[NSOperationQueue alloc] init];
	}
	return self;
}

- (void)dealloc {
	
	[_queue cancelAllOperations];
	SC_RELEASE_SAFELY(_queue);
	
	SC_RELEASE_SAFELY(_entitiesConverter);
	
	[super dealloc];
}

- (void)cancelRequests {
	
	[_queue cancelAllOperations];
}

- (void)clusterizeAtRegion:(MKCoordinateRegion)region andViewportSize:(CGSize)viewportSize
			  withModel:(PhoneModel)model conditionPlacering:(Placering)placering andOperator:(Operator)mobileOperator {
	
	[self makeRequest:@selector(clusterizeRequestDone:) apiUrl:CLUSTERIZE_URL clusterizeAtRegion:region andViewportSize:viewportSize
			withModel:model conditionPlacering:placering andOperator:mobileOperator];	
}

- (void)selectAtRegion:(MKCoordinateRegion)region andViewportSize:(CGSize)viewportSize
			 withModel:(PhoneModel)model conditionPlacering:(Placering)placering 
		   andOperator:(Operator)mobileOperator {
	
	[self makeRequest:@selector(selectRequestDone:) apiUrl:SELECT_URL clusterizeAtRegion:region andViewportSize:viewportSize
			withModel:model conditionPlacering:placering andOperator:mobileOperator];
}

- (void)clusterizeRequestDone:(ASIHTTPRequest *)request {

	[self processResponse:request requestType:RequestClusterize];
}
	
- (void)selectRequestDone:(ASIHTTPRequest *)request {
		
	[self processResponse:request requestType:RequestSelect];
}

- (void)requestWentWrong:(ASIHTTPRequest *)request {
	
	[AppDelegate hideActivityIndicator];
	
	[self.delegate maptimizeService:self failedWithError:[NSError errorWithDomain:MAPTIMIZE_ERROR_DOMAIN
																			 code:MAPTIMIZE_REQUEST_FAILED
																		 userInfo:nil]];
}

#pragma mark Private Methods

- (void)makeRequest:(SEL)requestDoneSelector apiUrl:(NSString *)apiUrl clusterizeAtRegion:(MKCoordinateRegion)region andViewportSize:(CGSize)viewportSize
		  withModel:(PhoneModel)model conditionPlacering:(Placering)placering andOperator:(Operator)operator {
	
	CLLocationCoordinate2D swLatLong = [self.entitiesConverter swFromRegion:region];
	NSString *swValue = [NSString stringWithFormat:LAT_LONG_FORMAT, swLatLong.latitude, swLatLong.longitude];
	NSString *swEncoded = [self.entitiesConverter encodeString:swValue];
	
	CLLocationCoordinate2D neLatLong = [self.entitiesConverter neFromRegion:region];
	NSString *neValue = [NSString stringWithFormat:LAT_LONG_FORMAT, neLatLong.latitude, neLatLong.longitude];
	NSString *neEncoded = [self.entitiesConverter encodeString:neValue];
	
	MKCoordinateSpan span = region.span;
	NSString *spanValue = [NSString stringWithFormat:LAT_LONG_FORMAT, span.latitudeDelta, span.longitudeDelta];
	NSString *spanEncoded = [self.entitiesConverter encodeString:spanValue];
	
	NSString *viewportValue = [NSString stringWithFormat:LAT_LONG_FORMAT, viewportSize.width, viewportSize.height];
	NSString *viewportEncoded = [self.entitiesConverter encodeString:viewportValue];
	
	NSString *placeringValue = nil;
	if (PlaceringAll != placering) {
		placeringValue = [self.entitiesConverter placeringToString:placering];
	}
	
	NSString *operatorValue = nil;
	if (OperatorAll != operator) {
		operatorValue = [self.entitiesConverter operatorToString:operator];
	}
	
	NSString *modelValue = nil;
	if (PhoneModelAll != model) {
		modelValue = [self.entitiesConverter modelToString:model];
	}
	
	NSString *conditionValue = @"";
	
	NSMutableArray *conditions = [NSMutableArray arrayWithCapacity:3];
	
	if (placeringValue) {
		[conditions addObject:[NSString stringWithFormat:CONDITION_PLACERING, placeringValue]];
	} 
	
	if (operatorValue) {
		[conditions addObject:[NSString stringWithFormat:CONDITION_OPERATOR, operatorValue]];
	}
	
	if (modelValue) {
		[conditions addObject:[NSString stringWithFormat:CONDITION_MODEL, modelValue]];
	}
	
	if (conditions.count > 0) {
		conditionValue = [conditions objectAtIndex:0];
		
		for (int i = 1; i < conditions.count; i++) {
			
			NSString *partOne = conditionValue;
			NSString *partTwo = [conditions objectAtIndex:i];
			
			conditionValue = [NSString stringWithFormat:@"%@ AND %@", partOne, partTwo];
		}
	}
	
	NSString *conditionEncoded = [self.entitiesConverter encodeString:conditionValue];
	
	NSString *aggregateValue = [NSString stringWithString:AGGREGATE];
	NSString *aggregateEncoded = [self.entitiesConverter encodeString:aggregateValue];
	
	int zoom = [self.entitiesConverter zoomFromSpan:region.span andViewportSize:viewportSize];
	SC_LOG_TRACE(@"zoom = %d", zoom);
	
	NSString *url = [NSString stringWithFormat:
					 apiUrl,
					 BASE_URL, MAP_KEY, zoom, swEncoded, neEncoded, conditionEncoded, aggregateEncoded,
					 spanEncoded, viewportEncoded, self.groupingDistance];
	SC_LOG_TRACE(@"url = %@", url);
	
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:url]] autorelease];
	
	request.delegate = self;
	request.didFinishSelector = requestDoneSelector;
	request.didFailSelector = @selector(requestWentWrong:);
	
	[request addRequestHeader:@"User-Agent" value:@"Bredbandskollen-iPhone"];
	[request addRequestHeader:@"accept" value:@"application/json"];
	
	[AppDelegate showActivityIndicator];
	
	[_queue addOperation:request];
}

- (void)processResponse:(ASIHTTPRequest *)request requestType:(RequestType)requestType {
	
	NSString *response = [request responseString];
	SC_LOG_DEBUG(@"response = %@", response);
	
	[AppDelegate hideActivityIndicator];
	
	/* Need to parse the response */
	
	SBJSON *parser = [SBJSON new];
	NSError *error = nil;
	NSDictionary *graph = [parser objectWithString:response error:&error];
	
	if (error) {
		SC_LOG_ERROR(@"MaptimizeService", @"Parser error: %@", error);
	}
	
	[parser release];
	
	/* Now can map JSON to objects. */
	
	if (![self verifyGraph:graph]) {
		[self.delegate maptimizeService:self failedWithError:[NSError errorWithDomain:MAPTIMIZE_ERROR_DOMAIN
																				 code:MAPTIMIZE_RESPONSE_INVALID
																			 userInfo:nil]];
	} else {
		
		BOOL success = [[graph objectForKey:@"success"] boolValue];
		if (!success) {
			[self.delegate maptimizeService:self failedWithError:[NSError errorWithDomain:MAPTIMIZE_ERROR_DOMAIN
																					 code:MAPTIMIZE_RESPONSE_SUCCESS_NO
																				 userInfo:nil]];
		} else {
			
			switch (requestType) {
				case RequestClusterize:
					[self.delegate maptimizeService:self didClusterize:graph];
					break;
				case RequestSelect:
					[self.delegate maptimizeService:self didSelect:graph];
					break;
			}
		}
	}	
}

- (BOOL)verifyGraph:(NSDictionary *)graph {
	
	if (!graph) {
		return NO;
	}
	
	id successObject = [graph objectForKey:@"success"];
	if (!successObject) {
		return NO;
	}
	
	return YES;
}

@end
