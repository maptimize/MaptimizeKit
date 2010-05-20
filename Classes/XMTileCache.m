//
//  XMTileCache.m
//  MaptimizeKit
//
//  Created by Oleg Shnitko on 4/22/10.
//  olegshnitko@gmail.com
//  
//  Copyright © 2010 Screen Customs s.r.o. All rights reserved.
//

#import "XMTileCache.h"
#import "XMTileCacheDelegate.h"

#import "SCMemoryManagement.h"

@implementation XMTileCache

@synthesize delegate = _delegate;

@synthesize capacity = _capacity;
@synthesize tilesCount = _tilesCount;

- (id)initWithCapacity:(NSUInteger)capacity
{
	if (self = [super init])
	{
		_capacity = capacity;
		_cache = [[NSMutableDictionary alloc] initWithCapacity:20];
	}
	
	return self;
}

- (void)dealloc
{
	SC_RELEASE_SAFELY(_cache);
	[super dealloc];
}

- (NSUInteger)levelsCount
{
	return [_cache count];
}

- (NSUInteger)tilesCountAtLevel:(XMTileLevel)level
{
	NSValue *l = [NSValue valueWithXMTileLevel:level];
	NSMutableDictionary *levelCache = [_cache objectForKey:l];
	NSUInteger levelCount = [levelCache count];
	return levelCount;
}

- (id)objectForTile:(XMTile)tile
{
	NSValue *level = [NSValue valueWithXMTileLevel:tile.level];
	
	NSMutableDictionary *levelCache = [_cache objectForKey:level];
	if (!levelCache)
	{
		return nil;
	}
	
	NSValue *tileHash = [NSValue valueWithXMTilePoint:tile.origin];
	id tileObject = [levelCache objectForKey:tileHash];
	return tileObject;
}

- (void)setObject:(id)value forTile:(XMTile)tile
{
	NSValue *level = [NSValue valueWithXMTileLevel:tile.level];
	
	NSMutableDictionary *levelCache = [_cache objectForKey:level];
	if (!levelCache)
	{
		levelCache = [NSMutableDictionary dictionary];
		[_cache setObject:levelCache forKey:level];
	}
	
	NSValue *tileHash = [NSValue valueWithXMTilePoint:tile.origin];
	
	id tileObject = [levelCache objectForKey:tileHash];
	if (!tileObject)
	{
		if (_capacity <= _tilesCount)
		{
			[_delegate tileCache:self reachedCapacity:_capacity];
		}
		
		if (_capacity <= _tilesCount)
		{
			return;
		}
		
		_tilesCount++;
		[levelCache setObject:value forKey:tileHash];
		
		if (_capacity <= _tilesCount)
		{
			[_delegate tileCache:self reachedCapacity:_capacity];
		}
	}
	else
	{
		[levelCache setObject:value forKey:tileHash];
	}
}

- (void)clearAll
{
	[_cache removeAllObjects];
	_tilesCount = 0;
}

- (void)clearLevel:(XMTileLevel)level
{
	NSValue *l = [NSValue valueWithXMTileLevel:level];
	NSMutableDictionary *levelCache = [_cache objectForKey:l];
	NSUInteger levelCount = [levelCache count];
	[_cache removeObjectForKey:l];
	_tilesCount -= levelCount;
}

- (void)clearRect:(XMTileRect)tileRect
{
	NSValue *level = [NSValue valueWithXMTileLevel:tileRect.level];
	NSMutableDictionary *levelCache = [_cache objectForKey:level];
	if (!levelCache)
	{
		return;
	}
	
	UInt64 minX = tileRect.origin.x;
	UInt64 minY = tileRect.origin.y;
	UInt64 maxX = minX + tileRect.size.width;
	UInt64 maxY = minY + tileRect.size.height;
	
	for (UInt64 i = minX; i < maxX; i++)
	{
		for (UInt64 j = minY; j < maxY; j++)
		{
			NSValue *tileHash = [NSValue valueWithXMTilePoint:XMTilePointMake(i, j)];
			
			id tileInfo = [levelCache objectForKey:tileHash];
			if (tileInfo)
			{
				[levelCache removeObjectForKey:tileHash];
				_tilesCount--;
			}
		}
	}	
}

- (void)clearTile:(XMTile)tile
{
	XMTileRect tileRect = XMTileRectMake(tile.level, tile.origin.x, tile.origin.y, 1, 1);
	[self clearRect:tileRect];
}

- (void)clearAllExceptLevel:(XMTileLevel)level
{
	for (NSValue *key in [_cache allKeys])
	{
		if (level != [key xmTileLevelValue])
		{
			NSMutableDictionary *levelCache = [_cache objectForKey:key];
			NSUInteger count = [levelCache count];
			_tilesCount -= count;
			[_cache removeObjectForKey:key];
		}
	}
}

- (void)clearAllExceptRect:(XMTileRect)tileRect
{
	[self clearAllExceptLevel:tileRect.level];
	
	NSValue *level = [NSValue valueWithXMTileLevel:tileRect.level];
	NSMutableDictionary *levelCache = [_cache objectForKey:level];
	
	UInt64 minX = tileRect.origin.x;
	UInt64 minY = tileRect.origin.y;
	UInt64 maxX = minX + tileRect.size.width;
	UInt64 maxY = minY + tileRect.size.height;
	
	for (NSValue *key in [levelCache allKeys])
	{
		XMTilePoint tile = [key xmTilePointValue];
		
		if (tile.x < minX || tile.x >= maxX || tile.y < minY || tile.y >= maxY)
		{
			[levelCache removeObjectForKey:key];
			_tilesCount--;
		}
	}
}

- (void)clearAllExceptTile:(XMTile)tile
{
	XMTileRect tileRect = XMTileRectMake(tile.level, tile.origin.x, tile.origin.y, 1, 1);
	[self clearAllExceptRect:tileRect];
}

@end
