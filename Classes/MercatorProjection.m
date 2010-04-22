//
//  MercatorProjection.m
//  MaptimizeKit
//
//  Created by Oleg Shnitko on 4/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MercatorProjection.h"

#define TILE_SIZE 256
#define MAX_ZOOM_LEVEL 20

@implementation MercatorProjection

@synthesize zoomLevel = _zoomLevel;
@synthesize offset = _offset;
@synthesize radius = _radius;

+ (NSUInteger)zoomLevelForRegion:(MKCoordinateRegion)region andViewport:(CGSize)viewport
{
	MercatorProjection *proj = [[MercatorProjection alloc] initWithZoomLevel:MAX_ZOOM_LEVEL];
	
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
	NSUInteger zoomLevel = [MercatorProjection zoomLevelForRegion:region andViewport:viewport];
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

- (TileRect)tileRectForRegion:(MKCoordinateRegion)region andViewport:(CGSize)viewport
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
	
	TileRect tileRect;
	
	tileRect.origin.x = topLeftTileX;
	tileRect.origin.y = bottomRightTileY;
	tileRect.size.width = bottomRightTileX - topLeftTileX;
	tileRect.size.height = topLeftTileY - bottomRightTileY;
	tileRect.level = self.zoomLevel;
	
	return tileRect;
}

- (Bounds)boundsForTile:(TilePoint)tile
{
	double topLeftPixelX = tile.x * TILE_SIZE;
	double bottomRightPixelX = topLeftPixelX + TILE_SIZE - 2;
 	
	double bottomRightPixelY = tile.y * TILE_SIZE;
	double topLeftPixelY = bottomRightPixelY + TILE_SIZE - 2;
	
	double centerPixelX = topLeftPixelX + TILE_SIZE / 2;
	double centerPixelY = topLeftPixelY - TILE_SIZE / 2;
	
	CLLocationDegrees minLng = [self pixelSpaceXToLongitude:topLeftPixelX];
	CLLocationDegrees maxLng = [self pixelSpaceXToLongitude:bottomRightPixelX];
	
	CLLocationDegrees minLat = [self pixelSpaceYToLatitude:topLeftPixelY];
	CLLocationDegrees maxLat = [self pixelSpaceYToLatitude:bottomRightPixelY];
	
	CLLocationDegrees centerLng = [self pixelSpaceXToLongitude:centerPixelX];
	CLLocationDegrees centerLat = [self pixelSpaceYToLatitude:centerPixelY];
	
	Bounds bounds;
	bounds.sw.longitude = minLng;
	bounds.sw.latitude = minLat;
	
	bounds.ne.longitude = maxLng;
	bounds.ne.latitude = maxLat;
	
	bounds.se.longitude = maxLng;
	bounds.se.latitude = minLat;
	
	bounds.nw.longitude = minLng;
	bounds.nw.latitude = maxLat;
	
	bounds.c.longitude = centerLng;
	bounds.c.latitude = centerLat;
	
	return bounds;
}

@end
