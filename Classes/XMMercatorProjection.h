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
	
	double _zoom;
	NSUInteger _zoomLevel;
	
	double _size;
	double _levelSize;
	
	double _scale;
	
	double _tileSize;
	double _levelTileSize;
	
	double _offset;
	double _radius;
}

+ (double)zoomForRegion:(MKCoordinateRegion)region andViewport:(CGSize)viewport;
+ (NSUInteger)zoomLevelForRegion:(MKCoordinateRegion)region andViewport:(CGSize)viewport;

- (id)initWithZoom:(double)zoom;
- (id)initWithZoomLevel:(NSUInteger)zoomLevel;
- (id)initWithSize:(double)size;
- (id)initWithRegion:(MKCoordinateRegion)region andViewport:(CGSize)viewport;

@property (nonatomic, readonly) double zoom;
@property (nonatomic, readonly) NSUInteger zoomLevel;

@property (nonatomic, readonly) double size;
@property (nonatomic, readonly) double levelSize;

@property (nonatomic, readonly) double scale;

@property (nonatomic, readonly) double tileSize;
@property (nonatomic, readonly) double levelTileSize;

@property (nonatomic, readonly) double offset;
@property (nonatomic, readonly) double radius;

- (double)longitudeToPixelSpaceX:(double)longitude;
- (double)latitudeToPixelSpaceY:(double)latitude;

- (double)pixelSpaceXToLongitude:(double)pixelX;
- (double)pixelSpaceYToLatitude:(double)pixelY;

- (XMTileRect)tileRectForRegion:(MKCoordinateRegion)region andViewport:(CGSize)viewport;
- (XMTile)tileForCoordinate:(CLLocationCoordinate2D)coordinate;
- (CLLocationCoordinate2D)centerForTile:(XMTile)tile;

- (XMBounds)boundsForRegion:(MKCoordinateRegion)region andViewport:(CGSize)viewport;
- (XMBounds)boundsForTile:(XMTilePoint)tile;
- (XMBounds)boundsForTileRect:(XMTileRect)tileRect;
- (XMBounds)expandBounds:(XMBounds)bounds onDistance:(NSUInteger)distance;

- (BOOL)isCoordinate:(CLLocationCoordinate2D)coordinate inBounds:(XMBounds)bounds;

@end
