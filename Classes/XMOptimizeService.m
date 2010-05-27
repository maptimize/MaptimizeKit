//
//  XMOptimizeService.m
//  MaptimizeKit
//
//  Created by Oleg Shnitko on 4/20/10.
//  olegshnitko@gmail.com
//  
//  Copyright © 2010 Screen Customs s.r.o. All rights reserved.
//  

#import "XMBase.h"

#import "XMOptimizeService.h"
#import "XMOptimizeServiceDelegate.h"
#import "XMOptimizeServiceParser.h"

#import "XMNetworkErrors.h"
#import "XMRequest.h"
#import "XMClusterizeRequest.h"
#import "XMSelectRequest.h"

#import "XMCondition.h"

#import "XMCluster.h"
#import "XMMarker.h"
#import "XMGraph.h"

#import "XMMercatorProjection.h"

#import "XMLog.h"

#import "JSON.h"

#define DEFAULT_DISTANCE 25

@interface XMOptimizeService (PrivateMethods)

- (XMGraph *)parseResponse:(ASIHTTPRequest *)request;

- (XMCluster *)parseCluster:(NSMutableDictionary *)clusterDict;
- (XMMarker *)parseMarker:(NSMutableDictionary *)markerDict;

- (BOOL)verifyGraph:(NSDictionary *)graph;

@end

@implementation XMOptimizeService

@synthesize delegate = _delegate;
@synthesize parser = _parser;

@synthesize mapKey = _mapKey;

@synthesize expandDistance = _expandDistance;
@synthesize filterResults = _filterResults;

- (id)init
{
	if (self = [super init])
	{
		_requestQueue = [[NSOperationQueue alloc] init];
		_parseQueue = [[NSOperationQueue alloc] init];
		
		_params = [[NSMutableDictionary alloc] init];
		
		_expandDistance = 256;
		_filterResults = YES;
		
		XM_LOG_TRACE(@"OptiomizeService initialized: %@", self);
	}
	
	return self;
}

- (void)dealloc
{
	[self cancelRequests];
	
	SC_RELEASE_SAFELY(_requestQueue);
	SC_RELEASE_SAFELY(_parseQueue);
	
	SC_RELEASE_SAFELY(_mapKey);
	SC_RELEASE_SAFELY(_params);
	
	XM_LOG_TRACE(@"OptimizeService deallocated: %@", self);
	
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
	XM_LOG_TRACE(@"OptimizeService changed grouping distance: %d", distance);
	
	[_params setObject:[NSNumber numberWithUnsignedInt:distance] forKey:kXMDistance];
}

- (NSArray *)properties
{
	return [_params objectForKey:kXMProperties];
}

- (void)setProperties:(NSArray *)properties
{
	XM_LOG_TRACE(@"OptimizeService changed fetching properties: %d", properties);
	
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
	XM_LOG_TRACE(@"OptimizeService changed aggregates value: %d", aggregates);
	
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
	XM_LOG_TRACE(@"OptimizeService changed condition: %d", condition);
	
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
	XM_LOG_TRACE(@"OptimizeService changed groupBy value: %d", groupBy);
	
	if (!groupBy)
	{
		[_params removeObjectForKey:kXMGroupBy];
		return;
	}
	
	[_params setObject:groupBy forKey:kXMGroupBy];
}

- (void)cancelRequests
{
	NSArray *operations = [_requestQueue operations];
	NSUInteger requestsCount = operations.count;
	
	XM_LOG_TRACE(@"Optimize service will cancel %d requests.", requestsCount);
	
	if (!requestsCount)
	{
		return;
	}
	
	for (XMRequest *request in operations)
	{
		request.delegate = nil;
		
		XM_LOG_TRACE(@"Request cancelled: %@", request);
		
		if ([self.delegate respondsToSelector:@selector(optimizeService:didCancelRequest:userInfo:)])
		{
			[self.delegate optimizeService:self didCancelRequest:request userInfo:[request.userInfo objectForKey:@"userInfo"]];
		}
	}
	
	XM_LOG_DEBUG(@"Optimize service did cancel %d requests.", requestsCount);
	
	[_requestQueue cancelAllOperations];
}

- (void)clusterizeBounds:(XMBounds)bounds withZoomLevel:(NSUInteger)zoomLevel userInfo:(id)userInfo
{
	XM_LOG_DEBUG(@"bounds: %@, zoomLevel: %d, userInfo: %@", NSStringFromXMBounds(bounds), zoomLevel, userInfo);
	
	XMMercatorProjection *projection = [[XMMercatorProjection alloc] initWithZoomLevel:zoomLevel];
	XMBounds expandedBounds = [projection expandBounds:bounds onDistance:_expandDistance];
	
	XM_LOG_TRACE(@"expand distance: %d, expanded bounds: %@", _expandDistance, NSStringFromXMBounds(expandedBounds));
	
	[projection release];
	
	XMClusterizeRequest *request = [[XMClusterizeRequest alloc] initWithMapKey:_mapKey
																  bounds:expandedBounds
															   zoomLevel:zoomLevel
																  params:_params];
	
	NSValue *boundsValue = [NSValue valueWithXMBounds:bounds];
	
	NSMutableDictionary *info = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
								 [NSNumber numberWithUnsignedInt:zoomLevel], @"zoomLevel",
								 boundsValue, @"bounds", nil];
	
	if (userInfo)
	{
		[info setObject:userInfo forKey:@"userInfo"];
	}
	
 	request.userInfo = info;
	request.delegate = self;
	request.didFinishSelector = @selector(clusterizeRequestDone:);
	request.didFailSelector = @selector(requestWentWrong:);
	
	[_requestQueue addOperation:request];
	XM_LOG_TRACE(@"request started: %@", request);
	[request release];
	[info release];
}

- (void)selectBounds:(XMBounds)bounds withZoomLevel:(NSUInteger)zoomLevel offset:(NSUInteger)offset limit:(NSUInteger)limit userInfo:(id)userInfo
{
	XM_LOG_DEBUG(@"bounds: %@, zoomLevel: %d, offset: %d, limit %d, userInfo: %@",
				 NSStringFromXMBounds(bounds), zoomLevel, offset, limit, userInfo);
	
	NSMutableDictionary *params = [_params mutableCopy];
	[params setObject:[NSNumber numberWithUnsignedInt:offset] forKey:kXMOffset];
	[params setObject:[NSNumber numberWithUnsignedInt:limit] forKey:kXMLimit];
	
	XMSelectRequest *request = [[XMSelectRequest alloc] initWithMapKey:_mapKey
																bounds:bounds
															 zoomLevel:zoomLevel
																params:params];
	[params release];
	
	NSMutableDictionary *info = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
								 [NSNumber numberWithUnsignedInt:zoomLevel], @"zoomLevel", nil];
	
	if (userInfo)
	{
		[info setObject:userInfo forKey:@"userInfo"];
	}
	
	request.userInfo = info;
	request.delegate = self;
	request.didFinishSelector = @selector(selectRequestDone:);
	request.didFailSelector = @selector(requestWentWrong:);
	
	[_requestQueue addOperation:request];
	XM_LOG_TRACE(@"request started: %@", request);
	[request release];
	[info release];
}

- (void)clusterizeRequestDone:(ASIHTTPRequest *)request
{
	XM_LOG_TRACE(@"request done: %@", request);
	
	NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(parseClusterizeRequest:) object:request];
	[_parseQueue addOperation:operation];
	
	XM_LOG_TRACE(@"parse operation started: %@", operation);
	[operation release];
}

- (void)parseClusterizeRequest:(id)data
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	ASIHTTPRequest *request = data;
	XMGraph *graph = [self parseResponse:request];
	
	if (graph)
	{
		NSMutableDictionary *info = (NSMutableDictionary *)request.userInfo;
		[info setObject:graph forKey:@"graph"];
		[self performSelectorOnMainThread:@selector(clusterizeRequestParsed:) withObject:request waitUntilDone:YES];
	}
	
	[pool release];
}

- (void)clusterizeRequestParsed:(ASIHTTPRequest *)request
{
	XMGraph *graph = [request.userInfo objectForKey:@"graph"];
	
	XM_LOG_TRACE(@"request parsed: %@, graph: %@", request, graph);
	XM_LOG_DEBUG(@"request completed: %@, graph: %@", request, graph);
	
	if ([self.delegate respondsToSelector:@selector(optimizeService:didClusterize:userInfo:)])
	{
		[self.delegate optimizeService:self didClusterize:graph userInfo:[request.userInfo objectForKey:@"userInfo"]];
	}
}

- (void)selectRequestDone:(ASIHTTPRequest *)request
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	XM_LOG_TRACE(@"request done: %@", request);
	
	XMGraph *graph = [self parseResponse:request];
	
	XM_LOG_TRACE(@"request parsed: %@, graph: %@", request, graph);
	XM_LOG_DEBUG(@"request completed: %@, graph: %@", request, graph);
	
	if (graph)
	{
		if ([self.delegate respondsToSelector:@selector(optimizeService:didSelect:userInfo:)])
		{
			[self.delegate optimizeService:self didSelect:graph userInfo:[request.userInfo objectForKey:@"userInfo"]];
		}
	}
	
	[pool release];
}

- (void)requestWentWrong:(ASIHTTPRequest *)request
{
	id userInfo = [request.userInfo objectForKey:@"userInfo"];
	
	XM_LOG_ERROR(@"request failed: %@, error: %@, userInfo: %@", request, request.error, userInfo);
	
	[self.delegate optimizeService:self
				   failedWithError:request.error
						  userInfo:userInfo];
}

#pragma mark Private Methods

- (void)notifyError:(NSError *)error
{
	XM_LOG_ERROR(@"error: %@", error);
	
	[self.delegate optimizeService:self failedWithError:error userInfo:error.userInfo];
}

- (void)notifyErrorInMainThread:(NSError *)error
{
	[self performSelectorOnMainThread:@selector(notifyError:) withObject:error waitUntilDone:YES];
}

- (XMGraph *)parseResponse:(ASIHTTPRequest *)request
{
	NSString *response = [request responseString];
	
	XM_LOG_TRACE(@"string response: %@", response);
	
	SBJSON *parser = [SBJSON new];
	NSError *error = nil;
	NSDictionary *graphDict = [parser objectWithString:response error:&error];
	
	if (error)
	{
		id userInfo = [request.userInfo objectForKey:@"userInfo"];
		
		XM_LOG_ERROR(@"error: %@, userInfo: %@", error, userInfo);
		
		[self.delegate optimizeService:self failedWithError:error userInfo:userInfo];
		
		[parser release];
		return nil;
	}
	
	[parser release];
	
	XM_LOG_TRACE(@"dictionary response: %@", graphDict);
	
	if (![self verifyGraph:graphDict])
	{
		[self notifyErrorInMainThread:[NSError errorWithDomain:XM_OPTIMIZE_ERROR_DOMAIN
														  code:XM_OPTIMIZE_RESPONSE_INVALID
													  userInfo:[request.userInfo objectForKey:@"userInfo"]]];
		
		return nil;
	}
	
	BOOL success = [[graphDict objectForKey:@"success"] boolValue];
	if (!success)
	{
		[self notifyErrorInMainThread:[NSError errorWithDomain:XM_OPTIMIZE_ERROR_DOMAIN
														  code:XM_OPTIMIZE_RESPONSE_SUCCESS_NO
													  userInfo:[request.userInfo objectForKey:@"userInfo"]]];
		
		return nil;
	}
	
	NSUInteger zoomLevel = [[request.userInfo objectForKey:@"zoomLevel"] unsignedIntValue];
	XMMercatorProjection *projection = [[XMMercatorProjection alloc] initWithZoomLevel:zoomLevel];
	
	NSValue *boundsValue = [request.userInfo objectForKey:@"bounds"];
	XMBounds bounds = [boundsValue xmBoundsValue];
	
	NSUInteger totalCount = 0;
	
	NSArray *clusters = [graphDict objectForKey:@"clusters"];
	NSMutableArray *parsedClusters = [NSMutableArray arrayWithCapacity:[clusters count]];
	
	for (NSMutableDictionary *clusterDict in clusters)
	{
		XMCluster *cluster = [self parseCluster:clusterDict];
		
		XM_LOG_TRACE(@"cluster parsed: %@", cluster);
		
		if (!_filterResults || !boundsValue || [projection isCoordinate:cluster.coordinate inBounds:bounds])
		{
			cluster.tile = [projection tileForCoordinate:cluster.coordinate];
		
			totalCount += cluster.count;
			[parsedClusters addObject:cluster];
		}
		else
		{
			XM_LOG_TRACE(@"cluster: %@, not in bounds: %@", cluster, NSStringFromXMBounds(bounds));
		}
	}
	
	NSArray *markers = [graphDict objectForKey:@"markers"];
	NSMutableArray *parsedMarkers = [NSMutableArray arrayWithCapacity:[markers count]];
	
	for (NSMutableDictionary *markerDict in markers)
	{
		XMMarker *marker = [self parseMarker:markerDict];
		
		XM_LOG_TRACE(@"marker parsed: %@", marker);
		
		if (!_filterResults || !boundsValue || [projection isCoordinate:marker.coordinate inBounds:bounds])
		{
			marker.tile = [projection tileForCoordinate:marker.coordinate];
		
			totalCount++;
			[parsedMarkers addObject:marker];
		}
		else
		{
			XM_LOG_TRACE(@"markers: %@, not in bounds: %@", marker, NSStringFromXMBounds(bounds));
		}
	}
	
	[projection release];
	
	if ([request isKindOfClass:[XMSelectRequest class]])
	{
		totalCount = [[graphDict objectForKey:@"totalCount"] intValue];
	}
	
	XMGraph *graph = [[XMGraph alloc] initWithClusters:parsedClusters markers:parsedMarkers totalCount:totalCount];
	return [graph autorelease];
}

- (XMCluster *)parseCluster:(NSMutableDictionary *)clusterDict
{
	NSMutableDictionary *data = clusterDict;//[clusterDict mutableCopy];
	
	NSString *coordString = [clusterDict objectForKey:@"coords"];
	[data removeObjectForKey:@"coords"];
	CLLocationCoordinate2D coordinate = XMCoordinatesFromString(coordString);
	
	NSDictionary *boundsDict = [clusterDict objectForKey:@"bounds"];
	[data removeObjectForKey:@"bounds"];
	XMBounds bounds = XMBoundsFromDictionary(boundsDict);
	
	NSUInteger count = [[clusterDict objectForKey:@"count"] intValue];
	[data removeObjectForKey:@"count"];
	
	XMCluster *cluster = nil;
	
	if ([self.parser respondsToSelector:@selector(optimizeService:clusterWithCoordinate:bounds:count:data:)])
	{
		cluster = [self.parser optimizeService:self clusterWithCoordinate:coordinate bounds:bounds count:count data:data];
	}
	
	if (!cluster)
	{
		cluster = [[[XMCluster alloc] initWithCoordinate:coordinate data:data] autorelease];
		cluster.bounds = bounds;
		cluster.count = count;
	}
	
	return cluster;
}

- (XMMarker *)parseMarker:(NSMutableDictionary *)markerDict
{
	NSMutableDictionary *data = markerDict;//[markerDict mutableCopy];
	
	NSString *coordString = [markerDict objectForKey:@"coords"];
	[data removeObjectForKey:@"coords"];
	CLLocationCoordinate2D coordinate = XMCoordinatesFromString(coordString);
	
	NSString *identifier = [markerDict objectForKey:@"id"];
	[data removeObjectForKey:@"id"];
	
	XMMarker *marker = nil;
	
	if ([self.parser respondsToSelector:@selector(optimizeService:markerWithCoordinate:identifier:data:)])
	{
		marker = [self.parser optimizeService:self markerWithCoordinate:coordinate identifier:identifier data:data];
	}
	
	if (!marker)
	{
		marker = [[[XMMarker alloc] initWithCoordinate:coordinate data:data identifier:identifier] autorelease];
	}
	
	return marker;
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
