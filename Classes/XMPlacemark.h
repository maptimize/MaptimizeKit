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

@interface XMPlacemark : NSObject <MKAnnotation>
{
@private
	
	XMTile _tile;
	CLLocationCoordinate2D _coordinate;
	NSMutableDictionary *_data;
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;
- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate data:(NSMutableDictionary *)data;

@property (nonatomic, assign) XMTile tile;
@property (nonatomic, readonly) NSMutableDictionary *data;

@end
