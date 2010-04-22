//
//  MKMapView+ZoomLevel.m
//  MaptimizeKit
//
//  Created by Oleg Shnitko on 4/20/10.
//	oleg@screencustoms.com
//	
//  Copyright © 2010 __MyCompanyName__
//	All rights reserved.
//

#import "MKMapView+ZoomLevel.h"
#import "MercatorProjection.h"

#import "SCLog.h"

@implementation MKMapView (ZoomLevel)

- (NSUInteger)zoomLevel
{
	MercatorProjection *proj = [[MercatorProjection alloc] initWithZoomLevel:20];
	
	MKCoordinateRegion region = self.region;
	MKCoordinateSpan span = region.span;
	CLLocationCoordinate2D centerCoordinate = region.center;
	
	CLLocationDegrees longitudeDelta = span.longitudeDelta;
	CLLocationDegrees minLng = centerCoordinate.longitude - longitudeDelta / 2.0;
	CLLocationDegrees maxLng = centerCoordinate.longitude + longitudeDelta / 2.0;
	
	double topLeftPixelX = [proj longitudeToPixelSpaceX:minLng];
	double bottomRightPixelX = [proj longitudeToPixelSpaceX:maxLng];
	
	double scaledMapWidth = bottomRightPixelX - topLeftPixelX;
	CGSize mapSizeInPixels = self.bounds.size;
	
	double zoomScaleX = scaledMapWidth / mapSizeInPixels.width; 
	double zoomExponentX = log(zoomScaleX) / log(2);
	NSUInteger zoomExponent = round(zoomExponentX);
	
	SC_LOG_TRACE(@"MapView", @"zoomExpX: %f", zoomExponentX);
	
	[proj release];
	
	return 20 - zoomExponent;
}

- (NSUInteger)maptimizeZoomLevel
{
	NSUInteger zoomLevel = self.zoomLevel;
	NSUInteger maptimizeZoomLevel = MIN(17, zoomLevel + 1);
	return maptimizeZoomLevel;
}

- (UInt64)tilesCount
{
	NSUInteger zoomLevel = self.zoomLevel;
	UInt64 count = 1 << zoomLevel;
	return count * count;
}

- (NSArray *)visibleTiles
{
	NSUInteger zoomLevel = self.zoomLevel;
	MercatorProjection *projection = [[MercatorProjection alloc] initWithZoomLevel:(zoomLevel)];
	
	MKCoordinateRegion region = self.region;
	MKCoordinateSpan span = region.span;
	CLLocationCoordinate2D centerCoordinate = region.center;
	
	CLLocationDegrees longitudeDelta = span.longitudeDelta;
	CLLocationDegrees minLng = centerCoordinate.longitude - longitudeDelta / 2.0;
	CLLocationDegrees maxLng = centerCoordinate.longitude + longitudeDelta / 2.0;
	
	CLLocationDegrees latitudeDelta = span.latitudeDelta;
	CLLocationDegrees minLat = centerCoordinate.latitude - latitudeDelta / 2.0;
	CLLocationDegrees maxLat = centerCoordinate.latitude + latitudeDelta / 2.0;
	
	NSUInteger count = 1 << (zoomLevel);
	
	double topLeftPixelX = [projection longitudeToPixelSpaceX:minLng];
    double topLeftPixelY = [projection latitudeToPixelSpaceY:minLat];
	
	double bottomRightPixelX = [projection longitudeToPixelSpaceX:maxLng];
	double bottomRightPixelY = [projection latitudeToPixelSpaceY:maxLat];
	
	UInt64 topLeftTileX = topLeftPixelX / 256.0 - 0.5;
	UInt64 topLeftTileY = topLeftPixelY / 256.0 - 0.5;
	
	UInt64 bottomRightTileX = bottomRightPixelX / 256.0 - 0.5;
	UInt64 bottomRightTileY = bottomRightPixelY / 256.0 - 0.5;
	
	UInt64 index1 = topLeftTileX + topLeftTileY * count;
	UInt64 index2 = topLeftTileX + bottomRightTileY * count;
	UInt64 index3 = bottomRightTileX + topLeftTileY * count;
	UInt64 index4 = bottomRightTileX + bottomRightTileY * count;
	
	NSNumber *n1 = [NSNumber numberWithUnsignedLongLong:index1];
	NSNumber *n2 = [NSNumber numberWithUnsignedLongLong:index2];
	NSNumber *n3 = [NSNumber numberWithUnsignedLongLong:index3];
	NSNumber *n4 = [NSNumber numberWithUnsignedLongLong:index4];
	
	NSMutableArray *tiles = [NSMutableArray array];
	
	if (![tiles containsObject:n1]) [tiles addObject:n1];
	if (![tiles containsObject:n2]) [tiles addObject:n2];
	if (![tiles containsObject:n3]) [tiles addObject:n3];
	if (![tiles containsObject:n4]) [tiles addObject:n4];
	
	[projection release];
	
	return tiles;
}

/*
 - (NSArray *)visibleTiles
 {
 NSUInteger zoomLevel = self.zoomLevel;
 double zoomScale = pow(2, 20 - zoomLevel);
 
 double centerPixelX = [self longitudeToPixelSpaceX:self.centerCoordinate.longitude];
 double centerPixelY = [self latitudeToPixelSpaceY:self.centerCoordinate.latitude];
 
 NSUInteger count = 1 << zoomLevel;
 
 CGSize mapSizeInPixels = self.bounds.size;
 double scaledMapWidth = mapSizeInPixels.width * zoomScale;
 double scaledMapHeight = mapSizeInPixels.height * zoomScale;
 
 UInt64 topLeftPixelX = centerPixelX - (scaledMapWidth / 2);
 UInt64 topLeftPixelY = centerPixelY - (scaledMapHeight / 2);
 
 UInt64 bottomRightPixelX = centerPixelX + (scaledMapWidth / 2);
 UInt64 bottomRightPixelY = centerPixelX + (scaledMapHeight / 2);
 
 UInt64 topLeftTileX = topLeftPixelX / 256 / zoomScale;
 UInt64 topLeftTileY = topLeftPixelY / 256 / zoomScale;
 
 UInt64 bottomRightTileX = bottomRightPixelX / 256 / zoomScale;
 UInt64 bottomRightTileY = bottomRightPixelY / 256 / zoomScale;
 
 UInt64 index1 = topLeftTileX + topLeftTileY * count;
 UInt64 index2 = topLeftTileX + bottomRightTileY * count;
 UInt64 index3 = bottomRightTileX + topLeftTileY * count;
 UInt64 index4 = bottomRightTileX + bottomRightTileY * count;
 
 NSNumber *n1 = [NSNumber numberWithUnsignedLongLong:index1];
 NSNumber *n2 = [NSNumber numberWithUnsignedLongLong:index2];
 NSNumber *n3 = [NSNumber numberWithUnsignedLongLong:index3];
 NSNumber *n4 = [NSNumber numberWithUnsignedLongLong:index4];
 
 NSMutableArray *tiles = [NSMutableArray array];
 
 if (![tiles containsObject:n1]) [tiles addObject:n1];
 if (![tiles containsObject:n2]) [tiles addObject:n2];
 if (![tiles containsObject:n3]) [tiles addObject:n3];
 if (![tiles containsObject:n4]) [tiles addObject:n4];
 
 return tiles;
 }
 
 */

@end
