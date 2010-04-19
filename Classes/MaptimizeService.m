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

#import "EntitiesConverter.h"
#import "MaptimizeService.h"
#import "NetworkErrors.h"

#import "SCMemoryManagement.h"
#import "SCLog.h"

@interface MaptimizeService (PrivateMethods)

- (void)makeRequest:(SEL)requestDoneSelector apiUrl:(NSString *)apiUrl clusterizeAtRegion:(MKCoordinateRegion)region andViewportSize:(CGSize)viewportSize
	  withCondition:(NSString *)condition aggregates:(NSString *)aggregates properties:(NSString *)properties
			 offset:(NSUInteger)offset count:(NSUInteger)count requestType:(RequestType)requestType;

- (void)processResponse:(ASIHTTPRequest *)request requestType:(RequestType)requestType;
- (BOOL)verifyGraph:(NSDictionary *)graph;

@end

@implementation MaptimizeService

@synthesize delegate = _delegate, entitiesConverter = _entitiesConverter;
@synthesize groupingDistance = _groupingDistance;
@synthesize mapKey = _mapKey;

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
	
	SC_RELEASE_SAFELY(_mapKey);
	
	[super dealloc];
}

- (void)cancelRequests {
	
	[_queue cancelAllOperations];
}

- (void)clusterizeAtRegion:(MKCoordinateRegion)region andViewportSize:(CGSize)viewportSize
			 withCondition:(NSString *)condition aggregates:(NSString *)aggregates properties:(NSString *)properties {
	
	[self makeRequest:@selector(clusterizeRequestDone:) apiUrl:CLUSTERIZE_URL clusterizeAtRegion:region andViewportSize:viewportSize
		withCondition:condition aggregates:aggregates properties:properties
			   offset:0 count:0 requestType:RequestClusterize];	
}

- (void)selectAtRegion:(MKCoordinateRegion)region andViewportSize:(CGSize)viewportSize
		 withCondition:(NSString *)condition aggregates:(NSString *)aggregates properties:(NSString *)properties
				offset:(NSUInteger)offset count:(NSUInteger)count {
	
	[self makeRequest:@selector(selectRequestDone:) apiUrl:SELECT_URL clusterizeAtRegion:region andViewportSize:viewportSize
		withCondition:condition aggregates:aggregates properties:properties
			   offset:offset count:count requestType:RequestSelect];
}

- (void)clusterizeRequestDone:(ASIHTTPRequest *)request {

	[self processResponse:request requestType:RequestClusterize];
}
	
- (void)selectRequestDone:(ASIHTTPRequest *)request {
		
	[self processResponse:request requestType:RequestSelect];
}

- (void)requestWentWrong:(ASIHTTPRequest *)request {
	
	[self.delegate maptimizeService:self failedWithError:[NSError errorWithDomain:MAPTIMIZE_ERROR_DOMAIN
																			 code:MAPTIMIZE_REQUEST_FAILED
																		 userInfo:nil]];
}

#pragma mark Private Methods

- (void)makeRequest:(SEL)requestDoneSelector apiUrl:(NSString *)apiUrl clusterizeAtRegion:(MKCoordinateRegion)region andViewportSize:(CGSize)viewportSize
	  withCondition:(NSString *)condition aggregates:(NSString *)aggregates properties:(NSString *)properties
			 offset:(NSUInteger)offset count:(NSUInteger)count requestType:(RequestType)requestType {
	
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
	
	NSString *conditionEncoded = [self.entitiesConverter encodeString:condition];
	NSString *aggregateEncoded = [self.entitiesConverter encodeString:aggregates];
	NSString *propertiesEncoded = [self.entitiesConverter encodeString:properties];
	
	int zoom = [self.entitiesConverter zoomFromSpan:region.span andViewportSize:viewportSize];
	SC_LOG_TRACE(@"MaptimizeService", @"zoom = %d", zoom);
	
	NSString *url = nil;
	
	if (requestType == RequestClusterize) {
		
		url = [NSString stringWithFormat:
			   apiUrl,
			   BASE_URL, _mapKey,
			   zoom, swEncoded, neEncoded,
			   conditionEncoded, aggregateEncoded, propertiesEncoded,
			   spanEncoded, viewportEncoded, self.groupingDistance];
	
	} else if (requestType == RequestSelect) {
		
		url = [NSString stringWithFormat:
			   apiUrl,
			   BASE_URL, _mapKey,
			   zoom, swEncoded, neEncoded,
			   conditionEncoded, aggregateEncoded, propertiesEncoded,
			   spanEncoded, viewportEncoded, offset, count];
		
	}
	SC_LOG_TRACE(@"MaptimizeService", @"url = %@", url);
	
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:url]] autorelease];
	
	request.delegate = self;
	request.didFinishSelector = requestDoneSelector;
	request.didFailSelector = @selector(requestWentWrong:);
	
	[request addRequestHeader:@"User-Agent" value:@"MaptimizeKit-iPhone"];
	[request addRequestHeader:@"accept" value:@"application/json"];
	
	[_queue addOperation:request];
}

- (void)processResponse:(ASIHTTPRequest *)request requestType:(RequestType)requestType {
	
	NSString *response = [request responseString];
	SC_LOG_DEBUG(@"MaptimizeService", @"response = %@", response);
	
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
