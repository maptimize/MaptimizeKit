//
//  TileService.m
//  MaptimizeKit
//
//  Created by Oleg Shnitko on 4/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "XMTileService.h"

#import "SCMemoryManagement.h"

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

- (void)clusterizeTileRect:(XMTileRect)tileRect
{
	NSUInteger zoomLevel = tileRect.level;
	XMMercatorProjection *projection = [[[XMMercatorProjection alloc] initWithZoomLevel:zoomLevel] autorelease];
	
	_lastLevel = zoomLevel;
	_lastRect = tileRect;
	
	NSNumber *z = [NSNumber numberWithUnsignedInt:zoomLevel];
	
	for (UInt64 i = 0; i < tileRect.size.width; i++)
	{
		for (UInt64 j = 0; j < tileRect.size.height; j++)
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
				[_tileCache setObject:tileInfo forTile:tile];
			}
			
			NSNumber *tileState = [tileInfo objectForKey:@"state"];
			
			switch ([tileState intValue])
			{
				case TILE_STATE_EMPTY:
				{
					[tileInfo setObject:[NSNumber numberWithInt:TILE_STATE_LOADING] forKey:@"state"];
					[tileInfo setObject:x forKey:@"x"];
					[tileInfo setObject:y forKey:@"y"];
					[tileInfo setObject:z forKey:@"z"];
					
					XMBounds bounds = [projection boundsForTile:tile.origin];
					[_service clusterizeBounds:bounds withZoomLevel:zoomLevel userInfo:tileInfo];
					
					break;
				}
				case TILE_STATE_CACHED:
				{
					NSDictionary *graph = [tileInfo objectForKey:@"data"];
					[_delegate tileService:self didClusterizeTile:tile withGraph:graph];
				}
				case TILE_STATE_LOADING:
				default:
					break;
			}
		}
	}
}

- (void)optimizeService:(XMOptimizeService *)optimizeService failedWithError:(NSError *)error
{
	[_delegate tileService:self failedWithError:error];
}

- (void)optimizeService:(XMOptimizeService *)optimizeService didClusterize:(NSDictionary *)graph userInfo:(id)userInfo
{
	NSMutableDictionary *tileInfo = userInfo;
	XMTile tile;
	tile.origin.x = [[tileInfo objectForKey:@"x"] unsignedLongLongValue];
	tile.origin.y = [[tileInfo objectForKey:@"y"] unsignedLongLongValue];
	tile.level = [[tileInfo objectForKey:@"z"] unsignedIntValue];
	
	[tileInfo setObject:[NSNumber numberWithInt:TILE_STATE_CACHED] forKey:@"state"];
	[tileInfo setObject:graph forKey:@"data"];
	
	[_tileCache setObject:tileInfo forTile:tile];
	
	[_delegate tileService:self didClusterizeTile:tile withGraph:graph];
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
