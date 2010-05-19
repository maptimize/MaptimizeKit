//
//  XMTileCache.h
//  MaptimizeKit
//
//  Created by Oleg Shnitko on 4/22/10.
//  olegshnitko@gmail.com
//  
//  Copyright © 2010 Screen Customs s.r.o. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "XMTile.h"

@class XMTileCache;

@protocol XMTileCacheDelegate

- (void)tileCache:(XMTileCache *)tileCache reachedCapacity:(NSUInteger)capacity;

@end

@interface XMTileCache : NSObject
{
@private
	
	NSUInteger _capacity;
	NSUInteger _tilesCount;
	
	NSMutableDictionary *_cache;
	
	id<XMTileCacheDelegate> _delegate;
}

@property (nonatomic, assign) id<XMTileCacheDelegate> delegate;

- (id)initWithCapacity:(NSUInteger)capacity;

@property (nonatomic, readonly) NSUInteger capacity;
@property (nonatomic, readonly) NSUInteger tilesCount;
@property (nonatomic, readonly) NSUInteger levelsCount;

- (NSUInteger)tilesCountAtLevel:(NSUInteger)level;

- (id)objectForTile:(XMTile)tile;
- (void)setObject:(id)value forTile:(XMTile)tile;

- (void)clearAll;
- (void)clearLevel:(NSUInteger)level;
- (void)clearRect:(XMTileRect)tileRect;
- (void)clearTile:(XMTile)tile;

- (void)clearAllExceptLevel:(NSUInteger)level;
- (void)clearAllExceptRect:(XMTileRect)tileRect;
- (void)clearAllExceptTile:(XMTile)tile;

@end
