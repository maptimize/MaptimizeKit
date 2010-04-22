//
//  TileService.h
//  MaptimizeKit
//
//  Created by Oleg Shnitko on 4/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MaptimizeService.h"
#import "MercatorProjection.h"
#import "TileCache.h"

@class TileService;

@protocol TileServiceDelegate

- (void)tileService:(TileService *)tileService failedWithError:(NSError *)error;

@optional

- (void)tileService:(TileService *)tileService didClusterize:(NSDictionary *)graph atZoomLevel:(NSUInteger)zoomLevel;

@end

@interface TileService : NSObject <MaptimizeServiceDelegate, TileCacheDelegate>
{
@private
	
	MaptimizeService *_service;
	TileCache *_tileCache;
	NSUInteger _lastLevel;
	TileRect _lastRect;
	
	id<TileServiceDelegate> _delegate;
}

@property (nonatomic, assign) id<TileServiceDelegate> delegate;
@property (nonatomic, readonly) MaptimizeService *service;

- (id)initWithMaptimizeService:(MaptimizeService *)service;

- (void)cancelRequests;

- (void)clusterizeTileRect:(TileRect)tileRect notifyCached:(BOOL)notifyCached;

@end
