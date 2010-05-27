//
//  XMMarker.h
//  MaptimizeKit
//
//  Created by Oleg Shnitko on 4/22/10.
//  olegshnitko@gmail.com
//  
//  Copyright © 2010 Screen Customs s.r.o. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#import "XMPlacemark.h"

/*
 Class: XMMarker
 
 Represents single point on the map.
 
 */
@interface XMMarker : XMPlacemark
{
@private
	
	NSString *_identifier;
}

/*
 Method: initWithCoordinate:identifier:
 
 Initialize new marker with specified coordinate and identifier.
 
 Parameters:
 
	coordinate - Coordinate for the placemark.
 
	identifier - Unique marker identifier.
 
 */
- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate identifier:(NSString *)identifier;

/*
 Method: initWithCoordinate:data:
 
 Initialize new marker with specified coordinate, data and identifier.
 
 Parameters:
 
	coordinate - Coordinate for the placemark.
 
	data - Additional data fetched from Maptimize API.
 
	identifier - Unique marker identifier.
 
 */
- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate data:(NSMutableDictionary *)data identifier:(NSString *)identifier;

/*
 Property: identifier
 */
@property (nonatomic, readonly) NSString *identifier;

@end
