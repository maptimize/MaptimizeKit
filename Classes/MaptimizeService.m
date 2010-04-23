//
//  MaptimizeService.m
//  Bredbandskollen
//
//  Created by Aleks Nesterow on 8/11/09.
//  aleks.nesterow@gmail.com
//  
//  Copyright © 2009 Screen Customs s.r.o. All rights reserved.
//  

#import "MaptimizeService.h"

#import "JSON.h"
#import "NetworkErrors.h"
#import "ClusterizeRequest.h"

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
	ClusterizeRequest *request = [[ClusterizeRequest alloc] initWithMapKey:_mapKey
																  bounds:bounds
															   zoomLevel:zoomLevel
																  params:nil];
	
	request.userInfo = userInfo;
	request.delegate = self;
	request.didFinishSelector = @selector(clusterizeRequestDone:);
	request.didFailSelector = @selector(requestWentWrong:);
	
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

@end
