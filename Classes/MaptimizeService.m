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

#import "MaptimizeService.h"
#import "NetworkErrors.h"

#import "SCMemoryManagement.h"
#import "SCLog.h"

@interface MaptimizeService (PrivateMethods)

- (void)processResponse:(ASIHTTPRequest *)request requestType:(RequestType)requestType;
- (BOOL)verifyGraph:(NSDictionary *)graph;
- (NSString *)encodeString:(NSString *)string;

@end

@implementation MaptimizeService

@synthesize delegate = _delegate;
@synthesize groupingDistance = _groupingDistance;
@synthesize mapKey = _mapKey;

- (id)init
{
	if (self = [super init])
	{
		_queue = [[NSOperationQueue alloc] init];
	}
	
	return self;
}

- (void)dealloc
{
	[_queue cancelAllOperations];
	
	SC_RELEASE_SAFELY(_queue);
	SC_RELEASE_SAFELY(_mapKey);
	
	[super dealloc];
}

- (void)cancelRequests
{
	[_queue cancelAllOperations];
}

- (void)clusterizeBounds:(Bounds)bounds withZoomLevel:(NSUInteger)zoomLevel userInfo:(id)userInfo
{
	CLLocationCoordinate2D swLatLong = bounds.sw;
	NSString *swValue = [NSString stringWithFormat:LAT_LONG_FORMAT, swLatLong.latitude, swLatLong.longitude];
	NSString *swEncoded = [self encodeString:swValue];
	
	CLLocationCoordinate2D neLatLong = bounds.ne;
	NSString *neValue = [NSString stringWithFormat:LAT_LONG_FORMAT, neLatLong.latitude, neLatLong.longitude];
	NSString *neEncoded = [self encodeString:neValue];
	
	NSString *url = [NSString stringWithFormat:
					 CLUSTERIZE_URL,
					 BASE_URL, _mapKey,
					 swEncoded, neEncoded, zoomLevel];
		
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:url]] autorelease];
	
	request.userInfo = userInfo;
	request.delegate = self;
	request.didFinishSelector = @selector(clusterizeRequestDone:);
	request.didFailSelector = @selector(requestWentWrong:);
	
	[request addRequestHeader:@"User-Agent" value:@"MaptimizeKit-iPhone"];
	[request addRequestHeader:@"accept" value:@"application/json"];
	
	[_queue addOperation:request];	
}

- (void)clusterizeRequestDone:(ASIHTTPRequest *)request
{
	[self processResponse:request requestType:RequestClusterize];
}
	
- (void)requestWentWrong:(ASIHTTPRequest *)request
{
	[self.delegate maptimizeService:self failedWithError:[NSError errorWithDomain:MAPTIMIZE_ERROR_DOMAIN
																			 code:MAPTIMIZE_REQUEST_FAILED
																		 userInfo:nil]];
}

#pragma mark Private Methods

- (void)processResponse:(ASIHTTPRequest *)request requestType:(RequestType)requestType
{
	NSString *response = [request responseString];
	
	/* Need to parse the response */
	
	SBJSON *parser = [SBJSON new];
	NSError *error = nil;
	NSDictionary *graph = [parser objectWithString:response error:&error];
	
	if (error)
	{
		SC_LOG_ERROR(@"MaptimizeService", @"Parser error: %@", error);
	}
	
	[parser release];
	
	/* Now can map JSON to objects. */
	
	if (![self verifyGraph:graph])
	{
		[self.delegate maptimizeService:self failedWithError:[NSError errorWithDomain:MAPTIMIZE_ERROR_DOMAIN
																				 code:MAPTIMIZE_RESPONSE_INVALID
																			userInfo:nil]];
	}
	else
	{
		BOOL success = [[graph objectForKey:@"success"] boolValue];
		if (!success)
		{
			[self.delegate maptimizeService:self failedWithError:[NSError errorWithDomain:MAPTIMIZE_ERROR_DOMAIN
																					 code:MAPTIMIZE_RESPONSE_SUCCESS_NO
																				 userInfo:nil]];
		}
		else
		{
			switch (requestType)
			{
				case RequestClusterize:
					[self.delegate maptimizeService:self didClusterize:graph userInfo:request.userInfo];
					break;
				case RequestSelect:
					break;
			}
		}
	}	
}

- (BOOL)verifyGraph:(NSDictionary *)graph
{	
	if (!graph)
	{
		return NO;
	}
	
	id successObject = [graph objectForKey:@"success"];
	if (!successObject)
	{
		return NO;
	}
	
	return YES;
}

- (NSString *)encodeString:(NSString *)string
{	
	/* Note that we use ' char in argument strings, however %22 is a code for ".
	 * That was done to simplify this algorithm. */
	
	NSArray *escapeChars = [NSArray arrayWithObjects:@";" , @"/" , @"?" , @":" ,
							@"@" , @"&" , @"=" , @"+" ,
							@"$" , @"," , @"[" , @"]",
							@"#", @"!", @"'", @"(", 
							@")", @"*", @" ", nil];
	
    NSArray *replaceChars = [NSArray arrayWithObjects:@"%3B", @"%2F", @"%3F", @"%3A" , 
							 @"%40" , @"%26" , @"%3D" , @"%2B" , 
							 @"%24" , @"%2C" , @"%5B" , @"%5D", 
							 @"%23", @"%21", @"%22", @"%28", 
							 @"%29", @"%2A", @"%20", nil];
	
    int len = [escapeChars count];
	
    NSMutableString *temp = [string mutableCopy];
	
    int i;
	
    for(i = 0; i < len; i++)
	{
	    [temp replaceOccurrencesOfString: [escapeChars objectAtIndex:i]
							  withString:[replaceChars objectAtIndex:i]
								 options:NSLiteralSearch
								   range:NSMakeRange(0, [temp length])];
    }
	
    NSString *result = [NSString stringWithString: temp];
	[temp release];
	
    return result;
}

@end
