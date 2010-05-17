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

#define TILE_SIZE 256.0
#define MAX_ZOOM_LEVEL 20.0

@implementation XMMercatorProjection

@synthesize zoom = _zoom; 
@synthesize zoomLevel = _zoomLevel;

@synthesize size = _size;
@synthesize levelSize = _levelSize;

@synthesize scale = _scale;

@synthesize tileSize = _tileSize;
@synthesize levelTileSize = _levelTileSize;

@synthesize offset = _offset;
@synthesize radius = _radius;

+ (double)zoomForRegion:(MKCoordinateRegion)region andViewport:(CGSize)viewport
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
	
	[proj release];
	
	return MAX_ZOOM_LEVEL - zoomExponentX;
}

+ (NSUInteger)zoomLevelForRegion:(MKCoordinateRegion)region andViewport:(CGSize)viewport
{
	double zoom = [XMMercatorProjection zoomForRegion:region andViewport:viewport];
	return round(zoom);
}

- (id)initWithZoom:(double)zoom
{
	if (self = [super init])
	{
		_zoom = zoom;
		_zoomLevel = round(zoom);
		
		_size = pow(2.0, _zoom) * TILE_SIZE;
		_levelSize = pow(2.0, _zoomLevel) * TILE_SIZE;
		
		_scale = _size / _levelSize;
		
		_levelTileSize = TILE_SIZE;
		_tileSize = _levelTileSize * _scale;
		
		_offset = _size * 0.5;
		_radius = _offset / M_PI;
	}
	
	return self;
}

- (id)initWithSize:(double)size
{
	if (self = [super init])
	{
		_size = size;
		
		_zoom = log(_size / TILE_SIZE) / log(2.0);
		_zoomLevel = round(_zoom);
		
		_levelSize = pow(2.0, _zoomLevel) * TILE_SIZE;
		
		_scale = _size / _levelSize;
		
		_levelTileSize = TILE_SIZE;
		_tileSize = _levelTileSize * _scale;
		
		_offset = _size * 0.5;
		_radius = _offset / M_PI;
	}
	
	return self;
}

- (id)initWithZoomLevel:(NSUInteger)zoomLevel
{
	double zoom = (double)zoomLevel;
	return [self initWithZoom:zoom];
}

- (id)initWithRegion:(MKCoordinateRegion)region andViewport:(CGSize)viewport
{
	double zoom = [XMMercatorProjection zoomForRegion:region andViewport:viewport];
	return [self initWithZoom:zoom];
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
	
	UInt64 topLeftTileX = /*round(*/topLeftPixelX / _tileSize/* - 0.5)*/;
	UInt64 topLeftTileY = /*round(*/topLeftPixelY / _tileSize + 1.0/*)*/;
	
	UInt64 bottomRightTileX = /*round(*/bottomRightPixelX / _tileSize + 1.0/*)*/;
	UInt64 bottomRightTileY = /*round(*/bottomRightPixelY / _tileSize/* - 0.5)*/;
	
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
	
	UInt64 tileX = pixelX / _tileSize;
	UInt64 tileY = pixelY / _tileSize;
	
	XMTile tile;
	tile.origin.x = tileX;
	tile.origin.y = tileY;
	tile.level = self.zoomLevel;
	
	return tile;
}

- (CLLocationCoordinate2D)centerForTile:(XMTile)tile
{
	double centerPixelX = tile.origin.x * _tileSize + _tileSize / 2;
	double centerPixelY = tile.origin.y * _tileSize + _tileSize / 2;
	
	CLLocationDegrees centerLng = [self pixelSpaceXToLongitude:centerPixelX];
	CLLocationDegrees centerLat = [self pixelSpaceYToLatitude:centerPixelY];
	
	CLLocationCoordinate2D center;
	center.longitude = centerLng;
	center.latitude = centerLat;
	
	return center;
}

- (XMBounds)boundsForTile:(XMTilePoint)tile
{
	double topLeftPixelX = tile.x * _tileSize;
	double bottomRightPixelX = topLeftPixelX + _tileSize - 1;
 	
	double bottomRightPixelY = tile.y * _tileSize;
	double topLeftPixelY = bottomRightPixelY + _tileSize - 1;
	
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
	double topLeftPixelX = tileRect.origin.x * _tileSize;
	double bottomRightPixelX = topLeftPixelX + tileRect.size.width * _tileSize - 1;
	
	double bottomRightPixelY = tileRect.origin.y * _tileSize;
	double topLeftPixelY = bottomRightPixelY + tileRect.size.height * _tileSize - 1;
	
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
	nePixelY -= distance;
	if (nePixelY < 0.0) nePixelY = 0.0;
	
	nePixelX += distance;
	if (nePixelX >= 2.0 * _offset) nePixelX = 2.0 * _offset - 1;
	swPixelY += distance;
	if (swPixelY >= 2.0 * _offset) swPixelY = 2.0 * _offset - 1;
	
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
		pixelY < nePixelY ||
		pixelX > nePixelX ||
		pixelY > swPixelY)
	{
		return NO;
	}
	
	return YES;
}

@end
