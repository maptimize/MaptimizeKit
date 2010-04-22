//
//  Tile.h
//  MaptimizeKit
//
//  Created by Oleg Shnitko on 4/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSUInteger TileLevel;

struct _TilePoint
{
	UInt64 x;
	UInt64 y;
};
typedef struct _TilePoint TilePoint;

struct _TileSize
{
	UInt64 width;
	UInt64 height;
};
typedef struct _TileSize TileSize;

struct _Tile
{
	TilePoint origin;
	TileLevel level;
};
typedef struct _Tile Tile;

struct _TileRect
{
	TilePoint origin;
	TileSize size;
	TileLevel level;
};
typedef struct _TileRect TileRect;
