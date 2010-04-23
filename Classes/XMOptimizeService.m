//
//  XMOptimizeService.m
//  MaptimizeKit
//
//  Created by Oleg Shnitko on 4/20/10.
//  olegshnitko@gmail.com
//  
//  Copyright © 2010 Screen Customs s.r.o. All rights reserved.
//  

#import "XMOptimizeService.h"

#import "JSON.h"
#import "XMNetworkErrors.h"
#import "XMClusterizeRequest.h"

#import "XMCluster.h"
#import "XMMarker.h"

#import "XMMercatorProjection.h"

#import "SCMemoryManagement.h"
#import "SCLog.h"

#define DEFAULT_DISTANCE 25

@interface XMOptimizeService (PrivateMethods)

- (XMGraph *)parseResponse:(ASIHTTPRequest *)request;

- (XMCluster *)parseCluster:(NSDictionary *)clusterDict;
- (XMMarker *)parseMarker:(NSDictionary *)markerDict;

- (BOOL)verifyGraph:(NSDictionary *)graph;
- (NSString *)encodeString:(NSString *)string;
- (CLLocationCoordinate2D)coordinatesFromString:(NSString *)value;

@end

@implementation XMOptimizeService

@synthesize delegate = _delegate;
@synthesize mapKey = _mapKey;

- (id)init
{
	if (self = [super init])
	{
		_queue = [[NSOperationQueue alloc] init];
		_params = [[NSMutableDictionary alloc] init];
	}
	
	return self;
}

- (void)dealloc
{
	[_queue cancelAllOperations];
	
	SC_RELEASE_SAFELY(_queue);
	SC_RELEASE_SAFELY(_mapKey);
	SC_RELEASE_SAFELY(_params);
	
	[super dealloc];
}

- (NSUInteger)distance
{
	NSNumber *d = [_params objectForKey:kXMDistance];
	if (!d)
	{
		return DEFAULT_DISTANCE;
	}
	
	return [d unsignedIntValue];
}

- (void)setDistance:(NSUInteger)distance
{
	if (distance < DEFAULT_DISTANCE)
	{
		[self setDistance:DEFAULT_DISTANCE];
	}
	
	[_params setObject:[NSNumber numberWithUnsignedInt:distance] forKey:kXMDistance];
}

- (NSArray *)properties
{
	return [_params objectForKey:kXMProperties];
}

- (void)setProperties:(NSArray *)properties
{
	if (!properties)
	{
		[_params removeObjectForKey:kXMProperties];
		return;
	}
	
	[_params setObject:properties forKey:kXMProperties];
}

- (NSString *)aggregates
{
	return [_params objectForKey:kXMAggreagtes];
}

- (void)setAggregates:(NSString *)aggregates
{
	if (!aggregates)
	{
		[_params removeObjectForKey:kXMAggreagtes];
		return;
	}
	
	[_params setObject:aggregates forKey:kXMAggreagtes];
}

- (XMCondition *)condition
{
	return [_params objectForKey:kXMCondition];
}

- (void)setCondition:(XMCondition *)condition
{
	if (!condition)
	{
		[_params removeObjectForKey:kXMCondition];
		return;
	}
	
	[_params setObject:condition forKey:kXMCondition];
}

- (NSString *)groupBy
{
	return [_params objectForKey:kXMGroupBy];
}

- (void)setGroupBy:(NSString *)groupBy
{
	if (!groupBy)
	{
		[_params removeObjectForKey:kXMGroupBy];
		return;
	}
	
	[_params setObject:groupBy forKey:kXMGroupBy];
}

- (void)cancelRequests
{
	[_queue cancelAllOperations];
}

- (void)clusterizeBounds:(XMBounds)bounds withZoomLevel:(NSUInteger)zoomLevel userInfo:(id)userInfo
{
	XMClusterizeRequest *request = [[XMClusterizeRequest alloc] initWithMapKey:_mapKey
																  bounds:bounds
															   zoomLevel:zoomLevel
																  params:nil];
	
	NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
						  userInfo, @"userInfo",
						  [NSNumber numberWithUnsignedInt:zoomLevel], @"zoomLevel", nil];
	
 	request.userInfo = info;
	request.delegate = self;
	request.didFinishSelector = @selector(clusterizeRequestDone:);
	request.didFailSelector = @selector(requestWentWrong:);
	
	[_queue addOperation:request];
}

- (void)clusterizeRequestDone:(ASIHTTPRequest *)request
{
	XMGraph *graph = [self parseResponse:request];
	if (graph)
	{
		[self.delegate optimizeService:self didClusterize:graph userInfo:[request.userInfo objectForKey:@"userInfo"]];
	}
}
	
- (void)requestWentWrong:(ASIHTTPRequest *)request
{
	[self.delegate optimizeService:self failedWithError:[NSError errorWithDomain:XM_OPTIMIZE_ERROR_DOMAIN
																			code:XM_OPTIMIZE_REQUEST_FAILED
																		userInfo:nil]];
}

#pragma mark Private Methods

- (XMGraph *)parseResponse:(ASIHTTPRequest *)request
{
	NSString *response = [request responseString];
	
	SBJSON *parser = [SBJSON new];
	NSError *error = nil;
	NSDictionary *graphDict = [parser objectWithString:response error:&error];
	
	if (error)
	{
		[self.delegate optimizeService:self failedWithError:error];
		[parser release];
		return nil;
	}
	
	[parser release];
	
	if (![self verifyGraph:graphDict])
	{
		[self.delegate optimizeService:self failedWithError:[NSError errorWithDomain:XM_OPTIMIZE_ERROR_DOMAIN
																				code:XM_OPTIMIZE_RESPONSE_INVALID
																			userInfo:nil]];
		return nil;
	}
	
	BOOL success = [[graphDict objectForKey:@"success"] boolValue];
	if (!success)
	{
		[self.delegate optimizeService:self failedWithError:[NSError errorWithDomain:XM_OPTIMIZE_ERROR_DOMAIN
																				code:XM_OPTIMIZE_RESPONSE_SUCCESS_NO
																			userInfo:nil]];
		return nil;
	}
	
	NSUInteger zoomLevel = [[request.userInfo objectForKey:@"zoomLevel"] unsignedIntValue];
	XMMercatorProjection *projection = [[XMMercatorProjection alloc] initWithZoomLevel:zoomLevel];
	
	NSUInteger totalCount = 0;
	
	NSArray *clusters = [graphDict objectForKey:@"clusters"];
	NSMutableArray *parsedClusters = [NSMutableArray arrayWithCapacity:[clusters count]];
	
	for (NSDictionary *clusterDict in clusters)
	{
		XMCluster *cluster = [self parseCluster:clusterDict];
		cluster.tile = [projection tileForCoordinate:cluster.coordinate];
		
		totalCount += cluster.count;
		[parsedClusters addObject:cluster];
	}
	
	NSArray *markers = [graphDict objectForKey:@"markers"];
	NSMutableArray *parsedMarkers = [NSMutableArray arrayWithCapacity:[markers count]];
	
	for (NSDictionary *markerDict in markers)
	{
		XMMarker *marker = [self parseMarker:markerDict];
		marker.tile = [projection tileForCoordinate:marker.coordinate];
		
		totalCount++;
		[parsedMarkers addObject:marker];
	}
	
	[projection release];
	
	XMGraph *graph = [[XMGraph alloc] initWithClusters:parsedClusters markers:parsedMarkers totalCount:totalCount];
	return [graph autorelease];
}

- (XMCluster *)parseCluster:(NSDictionary *)clusterDict
{
	NSMutableDictionary *data = [clusterDict mutableCopy];
	
	NSString *coordString = [clusterDict objectForKey:@"coords"];
	[data removeObjectForKey:@"coords"];
	CLLocationCoordinate2D coordinate = [self coordinatesFromString:coordString];
	
	NSDictionary *boundsDict = [clusterDict objectForKey:@"bounds"];
	[data removeObjectForKey:@"bounds"];
	NSString *swString = [boundsDict objectForKey:@"sw"];
	NSString *neString = [boundsDict objectForKey:@"ne"];
	
	XMBounds bounds;
	bounds.sw = [self coordinatesFromString:swString];
	bounds.ne = [self coordinatesFromString:neString];
	
	NSUInteger count = [[clusterDict objectForKey:@"count"] intValue];
	[data removeObjectForKey:@"count"];
	
	XMCluster *cluster = [[XMCluster alloc] initWithCoordinate:coordinate];
	cluster.bounds = bounds;
	cluster.count = count;
	cluster.data = data;
	
	return [cluster autorelease];
}

- (XMMarker *)parseMarker:(NSDictionary *)markerDict
{
	NSMutableDictionary *data = [markerDict mutableCopy];
	
	NSString *coordString = [markerDict objectForKey:@"coords"];
	[data removeObjectForKey:@"coords"];
	CLLocationCoordinate2D coordinate = [self coordinatesFromString:coordString];
	
	NSString *identifier = [markerDict objectForKey:@"id"];
	[data removeObjectForKey:@"id"];
	
	XMMarker *marker = [[XMMarker alloc] initWithCoordinate:coordinate];
	marker.identifier = identifier;
	
	return [marker autorelease];
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

- (CLLocationCoordinate2D)coordinatesFromString:(NSString *)value
{
	NSArray *chunks = [value componentsSeparatedByString:@","]; /* Should contain 2 parts: latitude and longitude. */
	
	NSString *latitudeValue = [chunks objectAtIndex:0];
	NSString *longitudeValue = [chunks objectAtIndex:1];
	
	CLLocationCoordinate2D result;
	result.latitude = [latitudeValue doubleValue];
	result.longitude = [longitudeValue doubleValue];
	
	return result;
}

@end
