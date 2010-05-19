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

/*
 Interface: XMMapControllerDelegate
 
 The XMMapControllerDelegate protocol defines a set of optional methods that you can use to receive map-related update messages.
 */
@protocol XMMapControllerDelegate <NSObject>
@optional

/* Group: Error handling */

/*
 Method: mapController:failedWithError:
 
 Tells the delegate that the map was unable to clusterize data.
 
 Parameters:
 
 mapController - The map that started the clusterize operation.
 
 error - The reason that the data could not be clusterized.
 
 */
- (void)mapController:(XMMapController *)mapController failedWithError:(NSError *)error;

/*
 Method: mapControllerDidFailLoadingMap:withError:
 
 Tells the delegate that the map was unable to load the map data.
 
 Parameters:
 
 mapController - The map that started the load operation.
 
 error - The reason that the map data could not be loaded.
 
 */
- (void)mapControllerDidFailLoadingMap:(XMMapController *)mapController withError:(NSError *)error;

/* Group: Responding to Map Position Changes */

/*
 Method: mapController:regionDidChangeAnimated:
 
 Tells the delegate that the region displayed by the map just changed.
 
 Parameters:
 
 mapController - The map controller whose visible region is about to change.
 
 animated - If YES, the change to the new region will be animated. If NO, the change will be made immediately.
 
 */
- (void)mapController:(XMMapController *)mapController regionDidChangeAnimated:(BOOL)animated;

/*
 Method: mapController:regionWillChangeAnimated:
 
 Tells the delegate that the region displayed by the map is about to change.
 
 Parameters:
 
 mapController - The map controller whose visible region is about to change.
 
 animated - If YES, the change to the new region will be animated. If NO, the change will be made immediately.
 
 */
- (void)mapController:(XMMapController *)mapController regionWillChangeAnimated:(BOOL)animated;

/* Group: Loading the Map Data */

/*
 Method: mapControllerWillStartLoadingMap:
 
 Tells the delegate that the specified map is about to retrieve some map data.
 
 Parameters:
 
 mapController - The map that began loading the data.
 
 */
- (void)mapControllerWillStartLoadingMap:(XMMapController *)mapController;

/*
 Method: mapControllerDidFinishLoadingMap:
 
 Tells the delegate that the specified map successfully loaded the needed map data.
 
 Parameters:
 
 mapController - The map that started the load operation.
 
 */
- (void)mapControllerDidFinishLoadingMap:(XMMapController *)mapController;

/* Group: Clusterizing the map */

/*
 Method: mapController:didClusterizeTile:withGraph:
 
 Tells the delegate that the specified map view successfully clusterized tile
 
 Parameters:
 
 mapController - The map that started the clusterize operation.
 tile - Clusterized tile
 graph - Graph object with clusters and markers for clusterized tile
 
 */
- (void)mapController:(XMMapController *)mapController didClusterizeTile:(XMTile)tile withGraph:(XMGraph *)graph;

/*
 Method: mapControllerWillStartLoadingClusters:mapController:
 
 Tells the delegate that the specified map is about to retrieve some map data.
 
 Parameters:
 
 mapController - The map that began clusterizing.
 
 */
- (void)mapControllerWillStartLoadingClusters:(XMMapController *)mapController;

/*
 Method: mapControllerDidFinishLoadingClusters:fromCache:
 
 Tells the delegate that the specified map successfully clusterized current region.
 
 Parameters:
 
 mapController - The map that started the clusterized operation.
 
 fromCache - Indicates that clusters data was fetched from local cache.
 
 */
- (void)mapControllerDidFinishLoadingClusters:(XMMapController *)mapController fromCache:(BOOL)fromCache;

/*
 Method: mapControllerDidCancelLoadingClusters:
 
 Tells the delegate that the specified map canceled clusterize operation.
 
 Parameters:
 
 mapController - The map that canceled the clusterized operation.
 
 */
- (void)mapControllerDidCancelLoadingClusters:(XMMapController *)mapController;

/* Group: Managing Annotation Views */

/*
 Method: mapController:viewForAnnotation:
 
 Returns the view associated with the specified annotation object.
 
 Parameters:
 
 mapController - The map that requested the annotation view.
 
 annotation - The object representing the annotation that is about to be displayed.
 
 */
- (MKAnnotationView *)mapController:(XMMapController *)mapController viewForAnnotation:(id<MKAnnotation>)annotation;

/*
 Method: mapController:viewForCluster:
 
 Returns the view associated with the specified cluster object.
 
 Parameters:
 
 mapController - The map that requested the annotation view.
 
 cluster - The cluster is about to be displayed.
 
 */
- (MKAnnotationView *)mapController:(XMMapController *)mapController viewForCluster:(XMCluster *)cluster;

/*
 Method: mapController:viewForMarker:
 
 Returns the view associated with the specified marker object.
 
 Parameters:
 
 mapController - The map that requested the annotation view.
 
 marker - The marker is about to be displayed.
 
 */
- (MKAnnotationView *)mapController:(XMMapController *)mapController viewForMarker:(XMMarker *)marker;

/*
 Method: mapController:didAddAnnotationViews:
 
 Tells the delegate that one or more annotation views were added to the map.
 
 Parameters:
 
 mapController - The map that added the annotation views.
 
 views - An array of MKAnnotationView objects representing the views that were added.
 
 */
- (void)mapController:(XMMapController *)mapController didAddAnnotationViews:(NSArray *)views;

/*
 Method: mapController:annotationView:calloutAccessoryControlTapped:
 
 Tells the delegate that the user tapped one of the annotation view’s accessory buttons.
 
 Parameters:
 
 mapController - The map containing the specified annotation view.
 
 view - The annotation view whose button was tapped.
 
 control - The control that was tapped.
 
 */
- (void)mapController:(XMMapController *)mapController annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control;

@end

/*
 Class: XMMapController
 Class that populating map with markers and clusters
 */
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

/*
 Group: Initializing
 */

/*
 Method: initWithTileService:
 Initializes and returns a newly allocated map controller object with the specified tile service.
 
 Parameters:
	tileService - The tile service for created map controller.
 
 Returns:
	An initialized map controller object or nil if the object couldn't be created.
 
 See also:
	<XMTileService>
 */
- (id)initWithTileService:(XMTileService *)tileService;

/*
 Group: Updating map
 */

/*
 Method: update
 
 Updates map using current region if needed.
 
 Previously loaded data will not be erased. Updates only new visible rects.
 
 See also:
	<refresh>
 */
- (void)update;

/*
 Method: refresh
 
 Clear all caches and updates map.
 
 This method erase all previously loaded data, remove all markers and cluster, and after that updates the map.
 
 See also:
	<update>
 
 */
- (void)refresh;

/*
 Group: Properties
 */

/*
 Property: mapView
 
 Map view for manage.
 
 Map controller will be delegate of providede map view.
 Changing this property will refresh map.
 
 */
@property (nonatomic, retain) IBOutlet MKMapView *mapView;

/*
 Property: mapKey
 
 Unique identifier of the map in Maptimize API.
 Changing this property will refresh map.
 
 */
@property (nonatomic, retain) NSString *mapKey;

/*
 Property: distance
 
 Grouping distance represented in pixels.
 
 Lets you customize the distance used by the clustering algorithm.
 For example, a value of 30 means that two points that would be closer than 30px on screen will end up in a cluster (25 is the default value).
 
 Changing this property will refresh map.
 
 */
@property (nonatomic, assign) NSUInteger distance;

/*
 Property: properties
 
 Properties for fetch from Maptimize API.
 
 Must be an array of strings.
 Changing this property will refresh map.
 
 > mapController.properties = [NSArray arrayWithObjects:@"upload_speed", @"download_speed", nil];
 
 */
@property (nonatomic, retain) NSArray *properties;

/*
 Property: aggregates
 
 Defines which aggregates functions will be executed against the points within each cluster and retrieved when performing a request.
 
 These are basically the aggregates that need to be displayed directly on the cluster, not in a popup window, for which they can be computed later.
 Please note that retrieving a lot of aggregates can lead to large responses that may degrade user experience depending on the client's bandwidth.
 Be especially careful when using concat on large strings or with lots of points.
 Changing this property will refresh map.
 
 > mapController.aggregates = @"avg(upload_speed)";
 
 */
@property (nonatomic, retain) NSString *aggregates;

/*
 Property: condition
 
 Sets the condition that will filter points when performing a request.
 
 Changing this property will refresh map.
 
 (start code)
 
 XMCondition *condition = [[XMCondition alloc] initWithFormat:@"upload_speed > %@" args:[NSArray arrayWithObject:[NSNumber numberWithFloat:2.3f]]];
 mapController.condition = condition;
 [condition release];
 
 (end)
 */
@property (nonatomic, retain) XMCondition *condition;

/*
 Property: groupBy
 
 Setting up group by request field.

 Changing this property will refresh map.
 
 */
@property (nonatomic, retain) NSString *groupBy;

/*
 Property: delegate
 
 Specifies map controller delegate.
 
 */
@property (nonatomic, assign) id<XMMapControllerDelegate> delegate;

/*
 Property: optimizeService
 
 Returns XMOptimizeService object using to fetch data from API.
 
 */
@property (nonatomic, readonly) XMOptimizeService *optimizeService;

/*
 Property: annotations
 
 Returns array of markers and clusters managed by map controller.
 
 */
@property (nonatomic, readonly) NSMutableArray *annotations;

@end