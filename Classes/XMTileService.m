//
//  XMTileService.m
//  MaptimizeKit
//
//  Created by Oleg Shnitko on 4/22/10.
//  olegshnitko@gmail.com
//  
//  Copyright © 2010 Screen Customs s.r.o. All rights reserved.
//

#import "XMTileService.h"

#import "SCMemoryManagement.h"
#import "SCLog.h"

#define TILE_STATE_EMPTY 0
#define TILE_STATE_LOADING 1
#define TILE_STATE_CACHED 2

#define CACHE_SIZE 1024

@implementation XMTileService

@synthesize delegate = _delegate;
@synthesize service = _service;

- (id)initWithOptimizeService:(XMOptimizeService *)service
{
	if (self = [super init])
	{
		_service = [service retain];
		_service.delegate = self;
		
		_tileCache = [[XMTileCache alloc] initWithCapacity:CACHE_SIZE];
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
	
	NSNumber *z = [NSNumber numberWithUnsignedInt:zoomLevel];
	NSMutableArray *tilesArray = [NSMutableArray array];
	
	BOOL isFullRect = YES;
	BOOL isEmptyRect = YES;
	BOOL firstNonEmptyTileFound = NO;
	XMTile firstNonEmptyTile;
	
	for (UInt64 j = 0; j < tileRect.size.height; j++)
	{
		for (UInt64 i = 0; i < tileRect.size.width; i++)
		{
			XMTile tile;
			tile.origin.x = tileRect.origin.x + i;
			tile.origin.y = tileRect.origin.y + j;
			tile.level = zoomLevel;
			
			NSNumber *x = [NSNumber numberWithUnsignedLongLong:tile.origin.x];
			NSNumber *y = [NSNumber numberWithUnsignedLongLong:tile.origin.y];
			
			NSMutableDictionary *tileInfo = [_tileCache objectForTile:tile];
			if (!tileInfo)
			{
				tileInfo = [NSMutableDictionary dictionary];
				[tileInfo setObject:[NSNumber numberWithInt:TILE_STATE_EMPTY] forKey:@"state"];
				[tileInfo setObject:x forKey:@"x"];
				[tileInfo setObject:y forKey:@"y"];
				[tileInfo setObject:z forKey:@"z"];
				
				XMGraph *tileGraph = [[XMGraph alloc] initWithClusters:[NSArray array] markers:[NSArray array] totalCount:0];
				[tileInfo setObject:tileGraph forKey:@"data"];
				[tileGraph release];
				
				[_tileCache setObject:tileInfo forTile:tile];
			}
			
			NSNumber *tileState = [tileInfo objectForKey:@"state"];
			
			switch ([tileState intValue])
			{
				case TILE_STATE_EMPTY:
				{
					isFullRect = NO;
					[tilesArray addObject:tileInfo];
					break;
				}
				case TILE_STATE_CACHED:
				case TILE_STATE_LOADING:
				{
					if (TILE_STATE_CACHED == [tileState intValue])
					{
						XMGraph *graph = [tileInfo objectForKey:@"data"];
						[_delegate tileService:self didClusterizeTile:tile withGraph:graph];
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
		return;
	}
	
	if (isEmptyRect)
	{
		for (NSMutableDictionary *tileInfo in tilesArray)
		{
			[tileInfo setObject:[NSNumber numberWithInt:TILE_STATE_LOADING] forKey:@"state"];
		}
		
		if ([self.delegate respondsToSelector:@selector(tileServiceWillStartLoadingTiles:)])
		{
			[self.delegate tileServiceWillStartLoadingTiles:self];
		}
		
		XMBounds bounds = [projection boundsForTileRect:tileRect];
		[_service clusterizeBounds:bounds withZoomLevel:zoomLevel userInfo:tilesArray];
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

- (void)optimizeService:(XMOptimizeService *)optimizeService failedWithError:(NSError *)error
{
	[_delegate tileService:self failedWithError:error];
}

- (void)optimizeService:(XMOptimizeService *)optimizeService didCancelRequest:(XMRequest *)request
{
	if ([self.delegate respondsToSelector:@selector(tileServiceDidCancelLoadingTiles:)])
	{
		[self.delegate tileServiceDidCancelLoadingTiles:self];
	}
}

- (void)optimizeService:(XMOptimizeService *)optimizeService didClusterize:(XMGraph *)graph userInfo:(id)userInfo
{
	for (XMCluster *cluster in [graph clusters])
	{
		NSMutableDictionary *tileInfo = [_tileCache objectForTile:cluster.tile];
		XMGraph *tileGraph = [tileInfo objectForKey:@"data"];
		[tileGraph addCluster:cluster];
	}
	
	for (XMMarker *marker in [graph markers])
	{
		NSMutableDictionary *tileInfo = [_tileCache objectForTile:marker.tile];
		XMGraph *tileGraph = [tileInfo objectForKey:@"data"];
		[tileGraph addMarker:marker];
	}
	
	NSArray *tilesArray = (NSArray *)userInfo;
	for (NSMutableDictionary *tileInfo in tilesArray)
	{
		[tileInfo setObject:[NSNumber numberWithInt:TILE_STATE_CACHED] forKey:@"state"];
		
		XMGraph *tileGraph = [tileInfo objectForKey:@"data"];
		XMTile tile;
		tile.origin.x = [[tileInfo objectForKey:@"x"] unsignedLongLongValue];
		tile.origin.y = [[tileInfo objectForKey:@"y"] unsignedLongLongValue];
		tile.level = [[tileInfo objectForKey:@"z"] unsignedIntValue];
		
		[_delegate tileService:self didClusterizeTile:tile withGraph:tileGraph];
	}
	
	if ([self.delegate respondsToSelector:@selector(tileServiceDidFinishLoadingTiles:)])
	{
		[self.delegate tileServiceDidFinishLoadingTiles:self];
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
