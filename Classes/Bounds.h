//
//  Bounds.h
//  MaptimizeKit
//
//  Created by Oleg Shnitko on 4/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

struct _Bounds
{
	CLLocationCoordinate2D sw;
	CLLocationCoordinate2D se;
	CLLocationCoordinate2D ne;
	CLLocationCoordinate2D nw;
	CLLocationCoordinate2D c;
};
typedef struct _Bounds Bounds;
