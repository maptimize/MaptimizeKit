//
//  TileService.h
//  MaptimizeKit
//
//  Created by Oleg Shnitko on 4/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "XMOptimizeService.h"
#import "XMMercatorProjection.h"
#import "XMTileCache.h"

@class XMTileService;

@protocol XMTileServiceDelegate

- (void)tileService:(XMTileService *)tileService failedWithError:(NSError *)error;
- (void)tileService:(XMTileService *)tileService didClusterizeTile:(XMTile)tile withGraph:(NSDictionary *)graph;

@end

@interface XMTileService : NSObject <XMOptimizeServiceDelegate, XMTileCacheDelegate>
{
@private
	
	XMOptimizeService *_service;
	XMTileCache *_tileCache;
	NSUInteger _lastLevel;
	XMTileRect _lastRect;
	
	id<XMTileServiceDelegate> _delegate;
}

@property (nonatomic, assign) id<XMTileServiceDelegate> delegate;
@property (nonatomic, readonly) XMOptimizeService *service;

- (id)initWithOptimizeService:(XMOptimizeService *)service;

- (void)cancelRequests;
- (void)clearCache;

- (void)clusterizeTileRect:(XMTileRect)tileRect;

@end
