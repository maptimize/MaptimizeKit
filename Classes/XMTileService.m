//
//  XMTileService.m
//  MaptimizeKit
//
//  Created by Oleg Shnitko on 4/22/10.
//  olegshnitko@gmail.com
//  
//  Copyright © 2010 Screen Customs s.r.o. All rights reserved.
//

#import "XMBase.h"

#import "XMTileService.h"
#import "XMTileServiceDelegate.h"

#import "XMMercatorProjection.h"

#import "XMTileCache.h"
#import "XMClusterizeInfo.h"
#import "XMTileInfo.h"

#import "XMOptimizeService.h"
#import "XMGraph.h"

#import "SCMemoryManagement.h"
#import "SCLog.h"

@implementation XMTileService

@synthesize delegate = _delegate;
@synthesize service = _service;

- (id)initWithOptimizeService:(XMOptimizeService *)service
{
	if (self = [super init])
	{
		_service = [service retain];
		_service.delegate = self;
		
		_tileCache = [[XMTileCache alloc] initWithCapacity:XM_TILE_SERVICE_CACHE_SIZE];
		_tileCache.delegate = self;
	}
	
	return self;
}

- (void)dealloc
{
	SC_RELEASE_SAFELY(_service);
	SC_RELEASE_SAFELY(_tileCache);
	
	[super dealloc];
}

- (void)cancelRequests
{
	[_service cancelRequests];
}

- (void)clearCache
{
	[_tileCache clearAll];
}

- (void)clusterizeTileRect:(XMTileRect)tileRect memorize:(BOOL)memorize
{
	NSUInteger zoomLevel = tileRect.level;
	XMMercatorProjection *projection = [[[XMMercatorProjection alloc] initWithZoomLevel:zoomLevel] autorelease];
	
	if (memorize)
	{
		_lastLevel = zoomLevel;
		_lastRect = tileRect;
	}
	
	XMClusterizeInfo *info = [[[XMClusterizeInfo alloc] init] autorelease];
	info.tileRect = tileRect;
	
	BOOL isFullRect = YES;
	BOOL isEmptyRect = YES;
	BOOL firstNonEmptyTileFound = NO;
	XMTile firstNonEmptyTile;
	
	UInt64 minX = tileRect.origin.x;
	UInt64 minY = tileRect.origin.y;
	UInt64 maxX = minX + tileRect.size.width;
	UInt64 maxY = minY + tileRect.size.height;
	
	for (UInt64 j = minY; j < maxY; j++)
	{
		for (UInt64 i = minX; i < maxX; i++)
		{
			XMTile tile = XMTileMake(zoomLevel, i, j);
			
			XMTileInfo *tileInfo = [_tileCache objectForTile:tile];
			if (!tileInfo)
			{
				tileInfo = [[XMTileInfo alloc] init];
				tileInfo.tile = tile;
				
				XMGraph *tileGraph = [[XMGraph alloc] initWithClusters:[NSArray array] markers:[NSArray array] totalCount:0];
				tileInfo.graph = tileGraph;
				[tileGraph release];
				
				[_tileCache setObject:tileInfo forTile:tile];
				[tileInfo release];
			}
			
			XMTileInfoState tileState = tileInfo.state;
			switch (tileState)
			{
				case XMTileInfoStateEmpty:
				{
					isFullRect = NO;
					[info.tiles addObject:tileInfo];
					break;
				}
				case XMTileInfoStateCached:
				case XMTileInfoStateLoading:
				{
					if (XMTileInfoStateCached == tileState)
					{
						[_delegate tileService:self didClusterizeTile:tile withGraph:tileInfo.graph];
					}
					
					isEmptyRect = NO;
					
					if (!firstNonEmptyTileFound)
					{
						firstNonEmptyTileFound = YES;
						firstNonEmptyTile = tile;
					}
				}
				default:
					break;
			}
		}
	}
	
	if (isFullRect)
	{
		if ([self.delegate respondsToSelector:@selector(tileServiceDidFinishLoadingTiles:fromCache:)])
		{
			[self.delegate tileServiceDidFinishLoadingTiles:self fromCache:YES];
		}
		
		return;
	}
	
	if (isEmptyRect)
	{
		for (XMTileInfo *tileInfo in info.tiles)
		{
			tileInfo.state = XMTileInfoStateLoading;
		}
		
		if ([self.delegate respondsToSelector:@selector(tileServiceWillStartLoadingTiles:)])
		{
			[self.delegate tileServiceWillStartLoadingTiles:self];
		}
		
		XMBounds bounds = [projection boundsForTileRect:tileRect];
		[_service clusterizeBounds:bounds withZoomLevel:zoomLevel userInfo:info];
		return;
	}
	
	UInt64 i = firstNonEmptyTile.origin.x - tileRect.origin.x;
	UInt64 j = firstNonEmptyTile.origin.y - tileRect.origin.y;
	
	if (j > 0)
	{
		XMTileRect topRect = tileRect;
		topRect.size.height = j;
		[self clusterizeTileRect:topRect memorize:NO];
	}
	
	if (i > 0)
	{
		XMTileRect leftRect = tileRect;
		leftRect.origin.y = firstNonEmptyTile.origin.y;
		leftRect.size.width = i;
		leftRect.size.height = 1;
		[self clusterizeTileRect:leftRect memorize:NO];
	}
	
	if (i < tileRect.size.width - 1)
	{
		XMTileRect rigthRect = tileRect;
		rigthRect.origin.x = firstNonEmptyTile.origin.x + 1;
		rigthRect.origin.y = firstNonEmptyTile.origin.y;
		rigthRect.size.width = tileRect.size.width - i - 1;
		rigthRect.size.height = 1;
		[self clusterizeTileRect:rigthRect memorize:NO];
	}
	
	if (j < tileRect.size.height - 1)
	{
		XMTileRect bottomRect = tileRect;
		bottomRect.origin.y = firstNonEmptyTile.origin.y + 1;
		bottomRect.size.height = tileRect.size.height - j - 1;
		[self clusterizeTileRect:bottomRect memorize:NO];
	}
}

- (void)clusterizeTileRect:(XMTileRect)tileRect
{
	[self clusterizeTileRect:tileRect memorize:YES];
}

- (void)optimizeService:(XMOptimizeService *)optimizeService failedWithError:(NSError *)error userInfo:(id)userInfo
{
	XMClusterizeInfo *info = userInfo;
	for (XMTileInfo *tileInfo in info.tiles)
	{
		tileInfo.state = XMTileInfoStateEmpty;
	}
	
	[_delegate tileService:self failedWithError:error];
}

- (void)optimizeService:(XMOptimizeService *)optimizeService didCancelRequest:(XMRequest *)request userInfo:(id)userInfo
{
	XMClusterizeInfo *info = userInfo;
	for (XMTileInfo *tileInfo in info.tiles)
	{
		tileInfo.state = XMTileInfoStateEmpty;
	}
	
	if ([self.delegate respondsToSelector:@selector(tileServiceDidCancelLoadingTiles:)])
	{
		[self.delegate tileServiceDidCancelLoadingTiles:self];
	}
}

- (void)optimizeService:(XMOptimizeService *)optimizeService didClusterize:(XMGraph *)graph userInfo:(id)userInfo
{
	[self handleOptimizeService:optimizeService didClusterize:graph clusterizeInfo:userInfo];
}

- (void)handleOptimizeService:(XMOptimizeService *)optimizeService didClusterize:(XMGraph *)graph clusterizeInfo:(XMClusterizeInfo *)info
{
	for (XMCluster *cluster in [graph clusters])
	{
		XMTileInfo *tileInfo = [_tileCache objectForTile:cluster.tile];
		[tileInfo.graph addCluster:cluster];
	}
	
	for (XMMarker *marker in [graph markers])
	{
		XMTileInfo *tileInfo = [_tileCache objectForTile:marker.tile];
		[tileInfo.graph addMarker:marker];
	}
	
	for (XMTileInfo *tileInfo in info.tiles)
	{
		tileInfo.state = XMTileInfoStateCached;
		[_delegate tileService:self didClusterizeTile:tileInfo.tile withGraph:tileInfo.graph];
	}
	
	if ([self.delegate respondsToSelector:@selector(tileServiceDidFinishLoadingTiles:fromCache:)])
	{
		[self.delegate tileServiceDidFinishLoadingTiles:self fromCache:NO];
	}	
}

- (void)tileCache:(XMTileCache *)tileCache reachedCapacity:(NSUInteger)capacity
{
	NSLog(@"tileCache reached capacity: %d", capacity);
	
	NSLog(@"clearing levels except: %d", _lastLevel);
	[tileCache clearAllExceptLevel:_lastLevel];
	
	NSUInteger count = tileCache.tilesCount;
	NSLog(@"tilesCount: %d", count);
	
	if (count < capacity)
	{
		return;
	}
	
	NSLog(@"clearing all except last tile rect");
	[tileCache clearAllExceptRect:_lastRect];
	
	count = tileCache.tilesCount;
	NSLog(@"tilesCount: %d", count);
	
	if (count < capacity)
	{
		return;
	}
	
	NSLog(@"clearing all");
	[tileCache clearAll];
}

@end
