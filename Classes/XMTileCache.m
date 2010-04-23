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

- (NSUInteger)tilesCountAtLevel:(NSUInteger)level
{
	NSNumber *l = [NSNumber numberWithUnsignedInt:level];
	NSMutableDictionary *levelCache = [_cache objectForKey:l];
	NSUInteger levelCount = [levelCache count];
	return levelCount;
}

- (id)objectForTile:(XMTile)tile
{
	NSNumber *level = [NSNumber numberWithUnsignedInt:tile.level];
	
	NSMutableDictionary *levelCache = [_cache objectForKey:level];
	if (!levelCache)
	{
		return nil;
	}
	
	NSNumber *x = [NSNumber numberWithUnsignedLongLong:tile.origin.x];
	NSNumber *y = [NSNumber numberWithUnsignedLongLong:tile.origin.y];
	NSString *tileHash = [NSString stringWithFormat:@"%@;%@", x, y];
	
	id tileObject = [levelCache objectForKey:tileHash];
	return tileObject;
}

- (void)setObject:(id)value forTile:(XMTile)tile
{
	NSNumber *level = [NSNumber numberWithUnsignedInt:tile.level];
	
	NSMutableDictionary *levelCache = [_cache objectForKey:level];
	if (!levelCache)
	{
		levelCache = [NSMutableDictionary dictionary];
		[_cache setObject:levelCache forKey:level];
	}
	
	NSNumber *x = [NSNumber numberWithUnsignedLongLong:tile.origin.x];
	NSNumber *y = [NSNumber numberWithUnsignedLongLong:tile.origin.y];
	NSString *tileHash = [NSString stringWithFormat:@"%@;%@", x, y];
	
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

- (void)clearLevel:(NSUInteger)level
{
	NSNumber *l = [NSNumber numberWithUnsignedInt:level];
	NSMutableDictionary *levelCache = [_cache objectForKey:l];
	NSUInteger levelCount = [levelCache count];
	[_cache removeObjectForKey:l];
	_tilesCount -= levelCount;
}

- (void)clearRect:(XMTileRect)tileRect
{
	NSNumber *level = [NSNumber numberWithUnsignedInt:tileRect.level];
	NSMutableDictionary *levelCache = [_cache objectForKey:level];
	if (!levelCache)
	{
		return;
	}
	
	for (UInt64 i = 0; i < tileRect.size.width; i++)
	{
		for (UInt64 j = 0; j < tileRect.size.height; j++)
		{
			NSNumber *x = [NSNumber numberWithUnsignedLongLong:tileRect.origin.x + i];
			NSNumber *y = [NSNumber numberWithUnsignedLongLong:tileRect.origin.y + j];
			NSString *tileHash = [NSString stringWithFormat:@"%@;%@", x, y];
			
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
	XMTileSize tileSize;
	tileSize.width = 1;
	tileSize.height = 1;
	
	XMTileRect tileRect;
	tileRect.level = tile.level;
	tileRect.origin = tile.origin;
	tileRect.size = tileSize;
	
	[self clearRect:tileRect];
}

- (void)clearAllExceptLevel:(NSUInteger)level
{
	for (NSNumber *key in [_cache allKeys])
	{
		if (level != [key unsignedIntValue])
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
	
	NSNumber *level = [NSNumber numberWithUnsignedInt:tileRect.level];
	NSMutableDictionary *levelCache = [_cache objectForKey:level];
	
	for (NSString *key in [levelCache allKeys])
	{
		NSArray *chunks = [key componentsSeparatedByString:@";"];
		UInt64 x = [[chunks objectAtIndex:0] longLongValue];
		UInt64 y = [[chunks objectAtIndex:1] longLongValue];
		
		if (x < tileRect.origin.x ||
			x >= tileRect.origin.x + tileRect.size.width ||
			y < tileRect.origin.y ||
			y >= tileRect.origin.y + tileRect.size.height)
		{
			[levelCache removeObjectForKey:key];
			_tilesCount--;
		}
	}
}

- (void)clearAllExceptTile:(XMTile)tile
{
	XMTileSize tileSize;
	tileSize.width = 1;
	tileSize.height = 1;
	
	XMTileRect tileRect;
	tileRect.level = tile.level;
	tileRect.origin = tile.origin;
	tileRect.size = tileSize;
	
	[self clearAllExceptRect:tileRect];
}

@end
