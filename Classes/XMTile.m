//
//  XMTile.m
//  MaptimizeKit
//
//  Created by Oleg Shnitko on 4/22/10.
//  olegshnitko@gmail.com
//  
//  Copyright © 2010 Screen Customs s.r.o. All rights reserved.
//

#import "XMTile.h"

NSString *NSStringFromXMTilePoint(XMTilePoint point)
{
	NSString *string = [NSString stringWithFormat:@"{%lld, %lld}", point.x, point.y];
	return string;
}

NSString *NSStringFromXMTileSize(XMTileSize size)
{
	NSString *string = [NSString stringWithFormat:@"{%lld, %lld}", size.width, size.height];
	return string;
}

NSString *NSStringFromXMTile(XMTile tile)
{
	NSString *string = [NSString stringWithFormat:@"{%d, {%lld, %lld}}",
						tile.level,
						tile.origin.x, tile.origin.y];
	return string;
}

NSString *NSStringFromXMTileRect(XMTileRect rect)
{
	NSString *string = [NSString stringWithFormat:@"{%d, {%lld, %lld}, {%lld, %lld}}",
						rect.level,
						rect.origin.x, rect.origin.y,
						rect.size.width, rect.size.height];
	return string;
}

@implementation NSValue (XMTile)

+ (NSValue *)valueWithXMTileLevel:(XMTileLevel)level
{
	NSValue *value = [NSValue valueWithBytes:&level objCType:@encode(XMTileLevel)];
	return value;
}

+ (NSValue *)valueWithXMTilePoint:(XMTilePoint)point
{
	NSValue *value = [NSValue valueWithBytes:&point objCType:@encode(XMTilePoint)];
	return value;
}

+ (NSValue *)valueWithXMTileSize:(XMTileSize)size
{
	NSValue *value = [NSValue valueWithBytes:&size objCType:@encode(XMTileSize)];
	return value;
}

+ (NSValue *)valueWithXMTile:(XMTile)tile
{
	NSValue *value = [NSValue valueWithBytes:&tile objCType:@encode(XMTile)];
	return value;
}

+ (NSValue *)valueWithXMTileRect:(XMTileRect)rect
{
	NSValue *value = [NSValue valueWithBytes:&rect objCType:@encode(XMTileRect)];
	return value;
}

- (XMTileLevel)xmTileLevelValue
{
	XMTileLevel level;
	[self getValue:&level];
	return level;
}

- (XMTilePoint)xmTilePointValue
{
	XMTilePoint point;
	[self getValue:&point];
	return point;
}

- (XMTileSize)xmTileSizeValue
{
	XMTileSize size;
	[self getValue:&size];
	return size;
}

- (XMTile)xmTileValue
{
	XMTile tile;
	[self getValue:&tile];
	return tile;
}

- (XMTileRect)xmTileRectValue
{
	XMTileRect rect;
	[self getValue:&rect];
	return rect;
}

@end


