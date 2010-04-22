//
//  MKMapView+ZoomLevel.h
//  MaptimizeKit
//
//  Created by Oleg Shnitko on 4/20/10.
//	oleg@screencustoms.com
//	
//  Copyright © 2010 __MyCompanyName__
//	All rights reserved.
//	
//	Purpose
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MKMapView (ZoomLevel)

@property (nonatomic, readonly) NSUInteger zoomLevel;
@property (nonatomic, readonly) NSUInteger maptimizeZoomLevel;

@property (nonatomic, readonly) UInt64 tilesCount;
@property (nonatomic, readonly) NSArray *visibleTiles;

@end
