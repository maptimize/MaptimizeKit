//
//  Tile.h
//  MaptimizeKit
//
//  Created by Oleg Shnitko on 4/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSUInteger XMTileLevel;

struct _XMTilePoint
{
	UInt64 x;
	UInt64 y;
};
typedef struct _XMTilePoint XMTilePoint;

struct _XMTileSize
{
	UInt64 width;
	UInt64 height;
};
typedef struct _XMTileSize XMTileSize;

struct _XMTile
{
	XMTilePoint origin;
	XMTileLevel level;
};
typedef struct _XMTile XMTile;

struct _XMTileRect
{
	XMTilePoint origin;
	XMTileSize size;
	XMTileLevel level;
};
typedef struct _XMTileRect XMTileRect;
