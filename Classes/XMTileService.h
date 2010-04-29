//
//  XMTileService.h
//  MaptimizeKit
//
//  Created by Oleg Shnitko on 4/22/10.
//  olegshnitko@gmail.com
//  
//  Copyright © 2010 Screen Customs s.r.o. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "XMOptimizeService.h"
#import "XMMercatorProjection.h"
#import "XMTileCache.h"
#import "XMGraph.h"

@class XMTileService;

@protocol XMTileServiceDelegate <NSObject>

- (void)tileService:(XMTileService *)tileService failedWithError:(NSError *)error;
- (void)tileService:(XMTileService *)tileService didClusterizeTile:(XMTile)tile withGraph:(XMGraph *)graph;

@optional

- (void)tileServiceWillStartLoadingTiles:(XMTileService *)tileService; 
- (void)tileServiceDidFinishLoadingTiles:(XMTileService *)tileService;

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
