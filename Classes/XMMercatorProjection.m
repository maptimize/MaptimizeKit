//
//  XMMercatorProjection.m
//  MaptimizeKit
//
//  Created by Oleg Shnitko on 4/21/10.
//  olegshnitko@gmail.com
//  
//  Copyright © 2010 Screen Customs s.r.o. All rights reserved.
//

#import "XMMercatorProjection.h"

#define TILE_SIZE 256
#define MAX_ZOOM_LEVEL 20

@implementation XMMercatorProjection

@synthesize zoomLevel = _zoomLevel;
@synthesize offset = _offset;
@synthesize radius = _radius;

+ (NSUInteger)zoomLevelForRegion:(MKCoordinateRegion)region andViewport:(CGSize)viewport
{
	XMMercatorProjection *proj = [[XMMercatorProjection alloc] initWithZoomLevel:MAX_ZOOM_LEVEL];
	
	MKCoordinateSpan span = region.span;
	CLLocationCoordinate2D centerCoordinate = region.center;
	
	CLLocationDegrees longitudeDelta = span.longitudeDelta;
	CLLocationDegrees minLng = centerCoordinate.longitude - longitudeDelta / 2.0;
	CLLocationDegrees maxLng = centerCoordinate.longitude + longitudeDelta / 2.0;
	
	double topLeftPixelX = [proj longitudeToPixelSpaceX:minLng];
	double bottomRightPixelX = [proj longitudeToPixelSpaceX:maxLng];
	
	double scaledMapWidth = bottomRightPixelX - topLeftPixelX;
	CGSize mapSizeInPixels = viewport;
	
	double zoomScaleX = scaledMapWidth / mapSizeInPixels.width; 
	double zoomExponentX = log(zoomScaleX) / log(2);
	NSUInteger zoomExponent = round(zoomExponentX);
	
	[proj release];
	
	return MAX_ZOOM_LEVEL - zoomExponent;
}

- (id)initWithZoomLevel:(NSUInteger)zoomLevel
{
	if (self = [super init])
	{
		_zoomLevel = zoomLevel;
		_offset = pow(2, _zoomLevel) * TILE_SIZE;
		_radius = _offset / (2.0 * M_PI);
	}
	
	return self;
}

- (id)initWithRegion:(MKCoordinateRegion)region andViewport:(CGSize)viewport
{
	NSUInteger zoomLevel = [XMMercatorProjection zoomLevelForRegion:region andViewport:viewport];
	return [self initWithZoomLevel:zoomLevel];
}

- (double)longitudeToPixelSpaceX:(double)longitude
{
    return round(_offset + _radius * longitude * M_PI / 180.0);
}

- (double)latitudeToPixelSpaceY:(double)latitude
{
    return round(_offset - _radius * logf((1 + sinf(latitude * M_PI / 180.0)) / (1 - sinf(latitude * M_PI / 180.0))) / 2.0);
}

- (double)pixelSpaceXToLongitude:(double)pixelX
{
    return ((round(pixelX) - _offset) / _radius) * 180.0 / M_PI;
}

- (double)pixelSpaceYToLatitude:(double)pixelY
{
    return (M_PI / 2.0 - 2.0 * atan(exp((round(pixelY) - _offset) / _radius))) * 180.0 / M_PI;
}

- (XMTileRect)tileRectForRegion:(MKCoordinateRegion)region andViewport:(CGSize)viewport
{
	CLLocationCoordinate2D centerCoordinate = region.center;
	
	double centerPixelX = [self longitudeToPixelSpaceX:centerCoordinate.longitude];
	double centerPixelY = [self latitudeToPixelSpaceY:centerCoordinate.latitude];
	
	double topLeftPixelX = centerPixelX - viewport.width / 2;
    double topLeftPixelY = centerPixelY + viewport.height / 2;
	
	double bottomRightPixelX = centerPixelX + viewport.width / 2;
	double bottomRightPixelY = centerPixelY - viewport.height / 2;
	
	UInt64 topLeftTileX = round(topLeftPixelX / TILE_SIZE - 0.5);
	UInt64 topLeftTileY = round(topLeftPixelY / TILE_SIZE + 0.5);
	
	UInt64 bottomRightTileX = round(bottomRightPixelX / TILE_SIZE + 0.5);
	UInt64 bottomRightTileY = round(bottomRightPixelY / TILE_SIZE - 0.5);
	
	XMTileRect tileRect;
	
	tileRect.origin.x = topLeftTileX;
	tileRect.origin.y = bottomRightTileY;
	tileRect.size.width = bottomRightTileX - topLeftTileX;
	tileRect.size.height = topLeftTileY - bottomRightTileY;
	tileRect.level = self.zoomLevel;
	
	return tileRect;
}

- (XMTile)tileForCoordinate:(CLLocationCoordinate2D)coordinate
{
	double pixelX = [self longitudeToPixelSpaceX:coordinate.longitude];
	double pixelY = [self latitudeToPixelSpaceY:coordinate.latitude];
	
	UInt64 tileX = round(pixelX / TILE_SIZE);
	UInt64 tileY = round(pixelY / TILE_SIZE);
	
	XMTile tile;
	tile.origin.x = tileX;
	tile.origin.y = tileY;
	tile.level = self.zoomLevel;
	
	return tile;
}

- (XMBounds)boundsForTile:(XMTilePoint)tile
{
	double topLeftPixelX = tile.x * TILE_SIZE;
	double bottomRightPixelX = topLeftPixelX + TILE_SIZE - 1;
 	
	double bottomRightPixelY = tile.y * TILE_SIZE;
	double topLeftPixelY = bottomRightPixelY + TILE_SIZE - 1;
	
	CLLocationDegrees minLng = [self pixelSpaceXToLongitude:topLeftPixelX];
	CLLocationDegrees maxLng = [self pixelSpaceXToLongitude:bottomRightPixelX];
	
	CLLocationDegrees minLat = [self pixelSpaceYToLatitude:topLeftPixelY];
	CLLocationDegrees maxLat = [self pixelSpaceYToLatitude:bottomRightPixelY];
	
	XMBounds bounds;
	bounds.sw.longitude = minLng;
	bounds.sw.latitude = minLat;
	
	bounds.ne.longitude = maxLng;
	bounds.ne.latitude = maxLat;
	
	return bounds;
}

- (XMBounds)boundsForTileRect:(XMTileRect)tileRect
{
	double topLeftPixelX = tileRect.origin.x * TILE_SIZE;
	double bottomRightPixelX = topLeftPixelX + tileRect.size.width * TILE_SIZE - 1;
	
	double bottomRightPixelY = tileRect.origin.y * TILE_SIZE;
	double topLeftPixelY = bottomRightPixelY + tileRect.size.height * TILE_SIZE - 1;
	
	CLLocationDegrees minLng = [self pixelSpaceXToLongitude:topLeftPixelX];
	CLLocationDegrees maxLng = [self pixelSpaceXToLongitude:bottomRightPixelX];
	
	CLLocationDegrees minLat = [self pixelSpaceYToLatitude:topLeftPixelY];
	CLLocationDegrees maxLat = [self pixelSpaceYToLatitude:bottomRightPixelY];
	
	XMBounds bounds;
	bounds.sw.longitude = minLng;
	bounds.sw.latitude = minLat;
	
	bounds.ne.longitude = maxLng;
	bounds.ne.latitude = maxLat;
	
	return bounds;
}

- (XMBounds)expandBounds:(XMBounds)bounds onDistance:(NSUInteger)distance
{
	double swPixelX = [self longitudeToPixelSpaceX:bounds.sw.longitude];
	double swPixelY = [self latitudeToPixelSpaceY:bounds.sw.latitude];
	
	double nePixelX = [self longitudeToPixelSpaceX:bounds.ne.longitude];
	double nePixelY = [self latitudeToPixelSpaceY:bounds.ne.latitude];
	
	swPixelX -= distance;
	if (swPixelX < 0.0) swPixelX = 0.0;
	swPixelY -= distance;
	if (swPixelY < 0.0) swPixelY = 0.0;
	
	nePixelX += distance;
	if (nePixelX >= _offset) nePixelX = _offset - 1;
	nePixelY += distance;
	if (nePixelY >= _offset) nePixelY = _offset - 1;
	
	XMBounds expandedBounds;
	
	expandedBounds.sw.longitude = [self pixelSpaceXToLongitude:swPixelX];
	expandedBounds.sw.latitude = [self pixelSpaceYToLatitude:swPixelY];
	
	expandedBounds.ne.longitude = [self pixelSpaceXToLongitude:nePixelX];
	expandedBounds.ne.latitude = [self pixelSpaceYToLatitude:nePixelY];
	
	return expandedBounds;
}

- (BOOL)isCoordinate:(CLLocationCoordinate2D)coordinate inBounds:(XMBounds)bounds
{
	double pixelX = [self longitudeToPixelSpaceX:coordinate.longitude];
	double pixelY = [self latitudeToPixelSpaceY:coordinate.latitude];
	
	double swPixelX = [self longitudeToPixelSpaceX:bounds.sw.longitude];
	double swPixelY = [self latitudeToPixelSpaceY:bounds.sw.latitude];
	
	double nePixelX = [self longitudeToPixelSpaceX:bounds.ne.longitude];
	double nePixelY = [self latitudeToPixelSpaceY:bounds.ne.latitude];
	
	if (pixelX < swPixelX ||
		pixelY < swPixelY ||
		pixelX > nePixelX ||
		pixelY > nePixelY)
	{
		return NO;
	}
	
	return YES;
}

@end
