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
#import "XMOptimizeServiceDelegate.h"

#import "XMMercatorProjection.h"
#import "XMTileCache.h"
#import "XMGraph.h"

@class XMTileService;

@protocol XMTileServiceDelegate <NSObject>

- (void)tileService:(XMTileService *)tileService failedWithError:(NSError *)error;
- (void)tileService:(XMTileService *)tileService didClusterizeTile:(XMTile)tile withGraph:(XMGraph *)graph;

@optional

- (void)tileServiceWillStartLoadingTiles:(XMTileService *)tileService; 
- (void)tileServiceDidFinishLoadingTiles:(XMTileService *)tileService fromCache:(BOOL)fromCache;
- (void)tileServiceDidCancelLoadingTiles:(XMTileService *)tileService;

@end

@interface ClusterizeInfo : NSObject
{
@private
	
	NSMutableArray *tiles;
	XMTileRect tileRect;
	XMGraph *graph;
}

@property (nonatomic, readonly) NSMutableArray *tiles;
@property (nonatomic, assign) XMTileRect tileRect;
@property (nonatomic, retain) XMGraph *graph;

@end

@interface TileInfo : NSObject
{
@private
	
	XMTile tile;
	NSInteger state;
	XMGraph *graph;
	id data;
}

@property (nonatomic, assign) XMTile tile;
@property (nonatomic, assign) NSInteger state;
@property (nonatomic, retain) XMGraph *graph;
@property (nonatomic, retain) id data;

@end

@interface XMTileService : NSObject <XMOptimizeServiceDelegate, XMTileCacheDelegate>
{
@private
	
	XMOptimizeService *_service;
	NSUInteger _lastLevel;
	XMTileRect _lastRect;
	
	id<XMTileServiceDelegate> _delegate;
	
@protected
	
	XMTileCache *_tileCache;
}

@property (nonatomic, assign) id<XMTileServiceDelegate> delegate;
@property (nonatomic, readonly) XMOptimizeService *service;

- (id)initWithOptimizeService:(XMOptimizeService *)service;

- (void)cancelRequests;
- (void)clearCache;

- (void)clusterizeTileRect:(XMTileRect)tileRect;

- (void)handleOptimizeService:(XMOptimizeService *)optimizeService didClusterize:(XMGraph *)graph userInfo:(id)userInfo;

@end
