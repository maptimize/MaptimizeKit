//
//  XMMaptimizeController.h
//  MaptimizeKit
//
//  Created by Oleg Shnitko on 4/22/10.
//  olegshnitko@gmail.com
//  
//  Copyright © 2010 Screen Customs s.r.o. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <MapKit/MapKit.h>

#import "XMOptimizeService.h"
#import "XMTileService.h"
#import "XMTileCache.h"

#import "XMCluster.h"
#import "XMMarker.h"

@class XMMapController;

@protocol XMMapControllerDelegate <NSObject>

- (void)mapController:(XMMapController *)mapController failedWithError:(NSError *)error;

@optional

- (MKAnnotationView *)mapController:(XMMapController *)mapController viewForCluster:(XMCluster *)cluster;
- (MKAnnotationView *)mapController:(XMMapController *)mapController viewForMarker:(XMMarker *)marker;

@end

@interface XMMapController : NSObject <MKMapViewDelegate, XMTileServiceDelegate, XMTileCacheDelegate>
{
@private
	
	XMOptimizeService *_optimizeService;
	XMTileService *_tileService;
	XMTileCache *_tileCache;
	XMTileRect _lastRect;
	
	MKMapView *_mapView;
	NSUInteger _zoomLevel;
	
	id<XMMapControllerDelegate> _delegate;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) NSString *mapKey;

@property (nonatomic, assign) NSUInteger distance;

@property (nonatomic, retain) NSArray *properties;
@property (nonatomic, retain) NSString *aggregates;
@property (nonatomic, retain) NSString *condition;
@property (nonatomic, retain) NSString *groupBy;

@property (nonatomic, assign) id<XMMapControllerDelegate> delegate;

- (void)update;
- (void)refresh;

@end
