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

- (void)mapController:(XMMapController *)mapController regionDidChangeAnimated:(BOOL)animated;
- (void)mapController:(XMMapController *)mapController regionWillChangeAnimated:(BOOL)animated;

- (void)mapControllerWillStartLoadingMap:(XMMapController *)mapController;
- (void)mapControllerDidFinishLoadingMap:(XMMapController *)mapController;
- (void)mapControllerDidFailLoadingMap:(XMMapController *)mapController withError:(NSError *)error;

- (void)mapController:(XMMapController *)mapController didAddAnnotationViews:(NSArray *)views;
- (void)mapController:(XMMapController *)mapController annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control;

- (MKAnnotationView *)mapController:(XMMapController *)mapController viewForAnnotation:(id<MKAnnotation>)annotation;
- (MKAnnotationView *)mapController:(XMMapController *)mapController viewForCluster:(XMCluster *)cluster;
- (MKAnnotationView *)mapController:(XMMapController *)mapController viewForMarker:(XMMarker *)marker;

- (void)mapController:(XMMapController *)mapController didClusterizeTile:(XMTile)tile withGraph:(XMGraph *)graph;

- (void)mapControllerWillStartLoadingClusters:(XMMapController *)mapController;
- (void)mapControllerDidFinishLoadingClusters:(XMMapController *)mapController fromCache:(BOOL)fromCache;
- (void)mapControllerDidCancelLoadingClusters:(XMMapController *)mapController;

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
	
	NSMutableArray *_annotations;
	
	id<XMMapControllerDelegate> _delegate;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) NSString *mapKey;

@property (nonatomic, assign) NSUInteger distance;

@property (nonatomic, retain) NSArray *properties;
@property (nonatomic, retain) NSString *aggregates;
@property (nonatomic, retain) XMCondition *condition;
@property (nonatomic, retain) NSString *groupBy;

@property (nonatomic, assign) BOOL clusterizeByTileRects;

@property (nonatomic, assign) id<XMMapControllerDelegate> delegate;

@property (nonatomic, readonly) XMOptimizeService *optimizeService;
@property (nonatomic, readonly) NSMutableArray *annotations;

- (void)update;
- (void)refresh;

@end
