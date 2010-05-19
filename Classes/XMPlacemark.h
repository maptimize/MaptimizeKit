//
//  XMPlacemark.h
//  MaptimizeKit
//
//  Created by Oleg Shnitko on 4/22/10.
//  olegshnitko@gmail.com
//  
//  Copyright © 2010 Screen Customs s.r.o. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#import "XMTile.h"

/*
 Class: XMPlacemark
 
 Provide base functionality for annotations fetched from the Maptimize API.
 You no need to use this class directly. Use it subclasses XMCluster and XMMarker.
 
 */
@interface XMPlacemark : NSObject <MKAnnotation>
{
@private
	
	XMTile _tile;
	CLLocationCoordinate2D _coordinate;
	NSMutableDictionary *_data;
}

/*
 Method: initWithCoordinate:
 
 Initialize new placemark with specified coordinate.
 
 Parameters:
 
	coordinate - Coordinate for the placemark.
 
 */
- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

/*
 Method: initWithCoordinate:data:
 
 Initialize new place placemark with specified coordinate and data.
 
 Parameters:
 
	coordinate - Coordinate for the placemark.
 
	data - Additional data fetched from Maptimize API.
 
 */
- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate data:(NSMutableDictionary *)data;

/*
 Property: tile
 
 Tile descriptor that contains this placemark.
 
 */
@property (nonatomic, assign) XMTile tile;

/*
 Property: data
 
 Additional data fetched from Maptimize API.
 
 */
@property (nonatomic, readonly) NSMutableDictionary *data;

@end
