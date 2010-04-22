//
//  MercatorProjection.h
//  MaptimizeKit
//
//  Created by Oleg Shnitko on 4/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

struct _TilePoint
{
	UInt64 x;
	UInt64 y;
};
typedef struct _TilePoint TilePoint;

struct _TileSize
{
	UInt64 width;
	UInt64 height;
};
typedef struct _TileSize TileSize;

struct _TileRect
{
	TilePoint origin;
	TileSize size;
};
typedef struct _TileRect TileRect;

struct _Bounds
{
	CLLocationCoordinate2D sw;
	CLLocationCoordinate2D se;
	CLLocationCoordinate2D ne;
	CLLocationCoordinate2D nw;
	CLLocationCoordinate2D c;
};
typedef struct _Bounds Bounds;

@interface MercatorProjection : NSObject
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

- (TileRect)tileRectForRegion:(MKCoordinateRegion)region andViewport:(CGSize)viewport;

- (Bounds)boundsForTile:(TilePoint)tile;

@end
