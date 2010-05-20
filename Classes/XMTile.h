//
//  XMTile.h
//  MaptimizeKit
//
//  Created by Oleg Shnitko on 4/22/10.
//  olegshnitko@gmail.com
//  
//  Copyright © 2010 Screen Customs s.r.o. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "XMBase.h"

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

XM_INLINE
XMTilePoint XMTilePointMake(UInt64 x, UInt64 y)
{
	XMTilePoint point;
	point.x = x;
	point.y = y;
	return point;
}

XM_INLINE
XMTileSize XMTileSizeMake(UInt64 width, UInt64 height)
{
	XMTileSize size;
	size.width = width;
	size.height = height;
	return size;
}

XM_INLINE
XMTile XMTileMake(XMTileLevel level, UInt64 x, UInt64 y)
{
	XMTile tile;
	tile.level = level;
	tile.origin.x = x;
	tile.origin.y = y;
	return tile;
}

XM_INLINE
XMTileRect XMTileRectMake(XMTileLevel level, UInt64 x, UInt64 y, UInt64 width, UInt64 height)
{
	XMTileRect rect;
	rect.level = level;
	rect.origin.x = x;
	rect.origin.y = y;
	rect.size.width = width;
	rect.size.height = height;
	return rect;
}

XM_EXTERN NSString *NSStringFromXMTilePoint(XMTilePoint point);
XM_EXTERN NSString *NSStringFromXMTileSize(XMTileSize size);
XM_EXTERN NSString *NSStringFromXMTile(XMTile tile);
XM_EXTERN NSString *NSStringFromXMTileRect(XMTileRect rect);

@interface NSValue (XMTile)

+ (NSValue *)valueWithXMTileLevel:(XMTileLevel)level;
+ (NSValue *)valueWithXMTilePoint:(XMTilePoint)point;
+ (NSValue *)valueWithXMTileSize:(XMTileSize)size;
+ (NSValue *)valueWithXMTile:(XMTile)tile;
+ (NSValue *)valueWithXMTileRect:(XMTileRect)rect;

- (XMTileLevel)xmTileLevelValue;
- (XMTilePoint)xmTilePointValue;
- (XMTileSize)xmTileSizeValue;
- (XMTile)xmTileValue;
- (XMTileRect)xmTileRectValue;

@end

