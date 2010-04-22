//
//  TileCache.h
//  MaptimizeKit
//
//  Created by Oleg Shnitko on 4/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Tile.h"

@class TileCache;

@protocol TileCacheDelegate

- (void)tileCache:(TileCache *)tileCache reachedCapacity:(NSUInteger)capacity;

@end


@interface TileCache : NSObject
{
@private
	
	NSUInteger _capacity;
	NSUInteger _tilesCount;
	
	NSMutableDictionary *_cache;
	
	id<TileCacheDelegate> _delegate;
}

@property (nonatomic, assign) id<TileCacheDelegate> delegate;

- (id)initWithCapacity:(NSUInteger)capacity;

@property (nonatomic, readonly) NSUInteger capacity;
@property (nonatomic, readonly) NSUInteger tilesCount;
@property (nonatomic, readonly) NSUInteger levelsCount;

- (NSUInteger)tilesCountAtLevel:(NSUInteger)level;

- (id)objectForTile:(Tile)tile;
- (void)setObject:(id)value forTile:(Tile)tile;

- (void)clearAll;
- (void)clearLevel:(NSUInteger)level;
- (void)clearRect:(TileRect)tileRect;
- (void)clearTile:(Tile)tile;

- (void)clearAllExceptLevel:(NSUInteger)level;
- (void)clearAllExceptRect:(TileRect)tileRect;
- (void)clearAllExceptTile:(Tile)tile;

@end
