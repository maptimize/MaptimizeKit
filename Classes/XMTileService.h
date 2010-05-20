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

#import "XMOptimizeServiceDelegate.h"

#import "XMMercatorProjection.h"
#import "XMTileCache.h"

@class XMOptimizeService;
@class XMGraph;
@class XMClusterizeInfo;

@protocol XMTileServiceDelegate;

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

- (void)handleOptimizeService:(XMOptimizeService *)optimizeService didClusterize:(XMGraph *)graph clusterizeInfo:(XMClusterizeInfo *)info;

@end
