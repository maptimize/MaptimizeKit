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

#import "SCLog.h"

#define MERCATOR_OFFSET 268435456
#define MERCATOR_RADIUS 85445659.44705395

@implementation MKMapView (ZoomLevel)

- (double)longitudeToPixelSpaceX:(double)longitude
{
    return round(MERCATOR_OFFSET + MERCATOR_RADIUS * longitude * M_PI / 180.0);
}

- (double)latitudeToPixelSpaceY:(double)latitude
{
    return round(MERCATOR_OFFSET - MERCATOR_RADIUS * logf((1 + sinf(latitude * M_PI / 180.0)) / (1 - sinf(latitude * M_PI / 180.0))) / 2.0);
}

- (double)pixelSpaceXToLongitude:(double)pixelX
{
    return ((round(pixelX) - MERCATOR_OFFSET) / MERCATOR_RADIUS) * 180.0 / M_PI;
}

- (double)pixelSpaceYToLatitude:(double)pixelY
{
    return (M_PI / 2.0 - 2.0 * atan(exp((round(pixelY) - MERCATOR_OFFSET) / MERCATOR_RADIUS))) * 180.0 / M_PI;
}

- (NSUInteger)zoomLevel
{
	MKCoordinateRegion region = self.region;
	MKCoordinateSpan span = region.span;
	CLLocationCoordinate2D centerCoordinate = region.center;
	
	CLLocationDegrees longitudeDelta = span.longitudeDelta;
	CLLocationDegrees minLng = centerCoordinate.longitude - longitudeDelta / 2.0;
	CLLocationDegrees maxLng = centerCoordinate.longitude + longitudeDelta / 2.0;
	
	double topLeftPixelX = [self longitudeToPixelSpaceX:minLng];
	double bottomRightPixelX = [self longitudeToPixelSpaceX:maxLng];
	
	double scaledMapWidth = bottomRightPixelX - topLeftPixelX;
	CGSize mapSizeInPixels = self.bounds.size;
	
	double zoomScaleX = scaledMapWidth / mapSizeInPixels.width; 
	double zoomExponentX = log(zoomScaleX) / log(2);
	NSUInteger zoomExponent = round(zoomExponentX);
	
	SC_LOG_TRACE(@"MapView", @"zoomExpX: %f", zoomExponentX);
	
	return 20 - zoomExponent;
}

@end
