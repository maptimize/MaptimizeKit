//
//	XMOptimizeServiceParser.h
//	MaptimizeKit
//
//	Created by Oleg Shnitko on 5/20/10.
//  olegshnitko@gmail.com
//  
//  Copyright © 2010 Screen Customs s.r.o. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#import "XMBounds.h"

@class XMOptimizeService;
@class XMCluster;
@class XMMarker;

@protocol XMOptimizeServiceParser <NSObject>
@optional

- (XMCluster *)optimizeService:(XMOptimizeService *)optimizeService
		 clusterWithCoordinate:(CLLocationCoordinate2D)coordinate
						bounds:(XMBounds)bounds
						 count:(NSUInteger)count
						  data:(NSMutableDictionary *)data;

- (XMMarker *)optimizeService:(XMOptimizeService *)optimizeService
		 markerWithCoordinate:(CLLocationCoordinate2D)coordinate
				   identifier:(NSString *)identifier
						 data:(NSMutableDictionary *)data;

@end
