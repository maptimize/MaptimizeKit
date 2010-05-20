//
//  XMTileCacheDelegate.h
//  MaptimizeKit
//
//  Created by Oleg Shnitko on 5/20/10.
//  olegshnitko@gmail.com
//  
//  Copyright © 2010 Screen Customs s.r.o. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XMTileCache;

@protocol XMTileCacheDelegate <NSObject>

- (void)tileCache:(XMTileCache *)tileCache reachedCapacity:(NSUInteger)capacity;

@end
