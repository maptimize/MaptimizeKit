//
//  Placemark.h
//  MaptimizeKit
//
//  Created by Oleg Shnitko on 4/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#import "XMTile.h"

@interface XMPlacemark : NSObject <MKAnnotation>
{
@private
	
	XMTile _tile;
	CLLocationCoordinate2D _coordinate;
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

@property (nonatomic, assign) XMTile tile;

@end
