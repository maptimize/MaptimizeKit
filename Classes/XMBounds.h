//
//  XMBounds.h
//  MaptimizeKit
//
//  Created by Oleg Shnitko on 4/23/10.
//  olegshnitko@gmail.com
//  
//  Copyright © 2010 Screen Customs s.r.o. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

struct _XMBounds
{
	CLLocationCoordinate2D sw;
	CLLocationCoordinate2D se;
	CLLocationCoordinate2D ne;
	CLLocationCoordinate2D nw;
	CLLocationCoordinate2D c;
};
typedef struct _XMBounds XMBounds;
