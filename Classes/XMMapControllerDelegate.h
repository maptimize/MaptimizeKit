//
// XMMapControllerDelegate.h
//	MaptimizeKit
//
// Created by Oleg Shnitko on 5/20/10.
//  olegshnitko@gmail.com
//  
//  Copyright © 2010 Screen Customs s.r.o. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#import "XMTile.h"

@class XMMapController;
@class XMCluster;
@class XMMarker;
@class XMGraph;

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
