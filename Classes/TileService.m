//
//  TileService.m
//  MaptimizeKit
//
//  Created by Oleg Shnitko on 4/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TileService.h"

#import "SCMemoryManagement.h"

#define TILE_STATE_EMPTY 0
#define TILE_STATE_LOADING 1
#define TILE_STATE_CACHED 2

@implementation TileService

@synthesize delegate = _delegate;
@synthesize service = _service;

- (id)initWithMaptimizeService:(MaptimizeService *)service
{
	if (self = [super init])
	{
		_service = [service retain];
		_service.delegate = self;
		
		_cache = [[NSMutableDictionary alloc] initWithCapacity:20];
	}
	
	return self;
}

- (void)dealloc
{
	SC_RELEASE_SAFELY(_service);
	SC_RELEASE_SAFELY(_cache);
	[super dealloc];
}

- (void)cancelRequests
{
	[_service cancelRequests];
}

- (void)clusterizeTileRect:(TileRect)tileRect notifyCached:(BOOL)notifyCached
{
	NSUInteger zoomLevel = tileRect.level;
	MercatorProjection *projection = [[[MercatorProjection alloc] initWithZoomLevel:zoomLevel] autorelease];
	
	NSNumber *z = [NSNumber numberWithUnsignedInt:zoomLevel];
	
	NSMutableDictionary *levelCache = [_cache objectForKey:z];
	if (!levelCache)
	{
		levelCache = [NSMutableDictionary dictionary];
		[_cache setObject:levelCache forKey:z];
	}
	
	for (UInt64 i = 0; i < tileRect.size.width; i++)
	{
		for (UInt64 j = 0; j < tileRect.size.height; j++)
		{
			TilePoint tile;
			tile.x = tileRect.origin.x + i;
			tile.y = tileRect.origin.y + j;
			
			NSNumber *x = [NSNumber numberWithUnsignedLongLong:tile.x];
			NSNumber *y = [NSNumber numberWithUnsignedLongLong:tile.y];
			
			NSString *tileHash = [NSString stringWithFormat:@"%@x%@", x, y];
			NSMutableDictionary *tileInfo = [levelCache objectForKey:tileHash];
			if (!tileInfo)
			{
				tileInfo = [NSMutableDictionary dictionary];
				[tileInfo setObject:[NSNumber numberWithInt:TILE_STATE_EMPTY] forKey:@"state"];
				[levelCache setObject:tileInfo forKey:tileHash];
			}
			
			NSNumber *tileState = [tileInfo objectForKey:@"state"];
			
			switch ([tileState intValue])
			{
				case TILE_STATE_EMPTY:
				{
					[tileInfo setObject:[NSNumber numberWithInt:TILE_STATE_LOADING] forKey:@"state"];
					
					NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:x, @"x", y, @"y", z, @"z", nil];
					Bounds bounds = [projection boundsForTile:tile];
					[_service clusterizeBounds:bounds withZoomLevel:zoomLevel userInfo:userInfo];
					
					break;
				}
				case TILE_STATE_CACHED:
				{
					if (notifyCached)
					{
						NSDictionary *graph = [tileInfo objectForKey:@"data"];
						[_delegate tileService:self didClusterize:graph atZoomLevel:zoomLevel];
					}
				}
				case TILE_STATE_LOADING:
				default:
					break;
			}
		}
	}
}

- (void)maptimizeService:(MaptimizeService *)maptimizeService failedWithError:(NSError *)error
{
	[_delegate tileService:self failedWithError:error];
}

- (void)maptimizeService:(MaptimizeService *)maptimizeService didClusterize:(NSDictionary *)graph userInfo:(id)userInfo
{
	NSDictionary *tileDict = userInfo;
	NSNumber *x = [tileDict objectForKey:@"x"];
	NSNumber *y = [tileDict objectForKey:@"y"];
	NSNumber *z = [tileDict objectForKey:@"z"];
	
	NSMutableDictionary *levelCache = [_cache objectForKey:z];
	NSString *tileHash = [NSString stringWithFormat:@"%@x%@", x, y];
	NSMutableDictionary *tileInfo = [levelCache objectForKey:tileHash];
	
	[tileInfo setObject:[NSNumber numberWithInt:TILE_STATE_CACHED] forKey:@"state"];
	[tileInfo setObject:graph forKey:@"data"];
	
	[_delegate tileService:self didClusterize:graph atZoomLevel:[z unsignedIntValue]];
}

@end
