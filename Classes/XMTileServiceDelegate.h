//
//	XMTileServiceDelegate.h
//	MaptimizeKit
//
//	Created by Oleg Shnitko on 5/20/10.
//  olegshnitko@gmail.com
//  
//  Copyright © 2010 Screen Customs s.r.o. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "XMTile.h"

@class XMTileService;
@class XMGraph;

@protocol XMTileServiceDelegate <NSObject>
@optional

- (void)tileService:(XMTileService *)tileService failedWithError:(NSError *)error;
- (void)tileService:(XMTileService *)tileService didClusterizeTile:(XMTile)tile withGraph:(XMGraph *)graph;

- (void)tileServiceWillStartLoadingTiles:(XMTileService *)tileService; 
- (void)tileServiceDidFinishLoadingTiles:(XMTileService *)tileService fromCache:(BOOL)fromCache;
- (void)tileServiceDidCancelLoadingTiles:(XMTileService *)tileService;

@end