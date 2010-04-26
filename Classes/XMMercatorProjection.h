//
//  XMMercatorProjection.h
//  MaptimizeKit
//
//  Created by Oleg Shnitko on 4/21/10.
//  olegshnitko@gmail.com
//  
//  Copyright © 2010 Screen Customs s.r.o. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#import "XMBounds.h"
#import "XMTile.h"

@interface XMMercatorProjection : NSObject
{
@private
	
	NSUInteger _zoomLevel;
	double _offset;
	double _radius;
}

+ (NSUInteger)zoomLevelForRegion:(MKCoordinateRegion)region andViewport:(CGSize)viewport;

- (id)initWithZoomLevel:(NSUInteger)zoomLevel;
- (id)initWithRegion:(MKCoordinateRegion)region andViewport:(CGSize)viewport;

@property (nonatomic, readonly) NSUInteger zoomLevel;
@property (nonatomic, readonly) double offset;
@property (nonatomic, readonly) double radius;

- (double)longitudeToPixelSpaceX:(double)longitude;
- (double)latitudeToPixelSpaceY:(double)latitude;

- (double)pixelSpaceXToLongitude:(double)pixelX;
- (double)pixelSpaceYToLatitude:(double)pixelY;

- (XMTileRect)tileRectForRegion:(MKCoordinateRegion)region andViewport:(CGSize)viewport;
- (XMTile)tileForCoordinate:(CLLocationCoordinate2D)coordinate;

- (XMBounds)boundsForTile:(XMTilePoint)tile;
- (XMBounds)expandBounds:(XMBounds)bounds onDistance:(NSUInteger)distance;

- (BOOL)isCoordinate:(CLLocationCoordinate2D)coordinate inBounds:(XMBounds)bounds;

@end
