//
//  XMMaptimizeController.m
//  MaptimizeKit
//
//  Created by Oleg Shnitko on 4/22/10.
//  olegshnitko@gmail.com
//  
//  Copyright © 2010 Screen Customs s.r.o. All rights reserved.
//

#import "XMMapController.h"

#import "XMMapControllerDelegate.h"

#import "XMGraph.h"

#import "XMMercatorProjection.h"
#import "XMClusterView.h"

#import "SCMemoryManagement.h"
#import "SCLog.h"

#define TILE_CACHE_SIZE 128

@interface XMMapController (Private)

@property (nonatomic, readonly) XMTileService *tileService;
@property (nonatomic, readonly) XMTileCache *tileCache;

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForCluster:(XMCluster *)cluster;
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForMarker:(XMMarker *)marker;

@end

@implementation XMMapController

@synthesize mapView = _mapView;
@synthesize delegate = _delegate;

- (id)initWithTileService:(XMTileService *)tileService
{
	if (self = [super init])
	{
		_tileService = [tileService retain];
		_tileService.delegate = self;
		_optimizeService = _tileService.service;
	}
	
	return self;
}

- (void)dealloc
{
	SC_RELEASE_SAFELY(_optimizeService);
	SC_RELEASE_SAFELY(_tileService);
	SC_RELEASE_SAFELY(_tileCache);
	SC_RELEASE_SAFELY(_annotations);
	
	SC_RELEASE_SAFELY(_mapView);
	
    [super dealloc];
}

- (XMOptimizeService *)optimizeService
{
	if (!_optimizeService)
	{
		_optimizeService = [[XMOptimizeService alloc] init];
	}
	
	return _optimizeService;
}

- (XMTileService *)tileService
{
	if (!_tileService)
	{
		_tileService = [[XMTileService alloc] initWithOptimizeService:self.optimizeService];
		_tileService.delegate = self;
	}
	
	return _tileService;
}

- (XMTileCache *)tileCache
{
	if (!_tileCache)
	{
		_tileCache = [[XMTileCache alloc] initWithCapacity:TILE_CACHE_SIZE];
		_tileCache.delegate = self;
	}
	
	return _tileCache;
}

- (NSMutableArray *)annotations
{
	if (!_annotations)
	{
		_annotations = [[NSMutableArray alloc] init];
	}
	
	return _annotations;
}

- (void)setMapView:(MKMapView *)mapView
{
	if (_mapView != mapView)
	{
		[self.optimizeService cancelRequests];
		[self.tileCache clearAll];
		
		_mapView.delegate = nil;
		[_mapView release];
		
		_mapView = [mapView retain];
		_mapView.delegate = self;
	}
}

- (NSString *)mapKey
{
	return self.optimizeService.mapKey;
}

- (void)setMapKey:(NSString *)mapKey
{
	if (![self.optimizeService.mapKey isEqualToString:mapKey])
	{
		self.optimizeService.mapKey = mapKey;
		[self refresh];
	}
}

- (NSUInteger)distance
{
	return self.optimizeService.distance;
}

- (void)setDistance:(NSUInteger)distance
{
	if (self.optimizeService.distance != distance)
	{
		self.optimizeService.distance = distance;
		[self refresh];
	}
}

- (NSArray *)properties
{
	return self.optimizeService.properties;
}

- (void)setProperties:(NSArray *)properties
{
	if (![self.optimizeService.properties isEqualToArray:properties])
	{
		self.optimizeService.properties = properties;
		[self refresh];
	}
}

- (NSString *)aggregates
{
	return self.optimizeService.aggregates;
}

- (void)setAggregates:(NSString *)aggregates
{
	if (![self.optimizeService.aggregates isEqualToString:aggregates])
	{
		self.optimizeService.aggregates = aggregates;
		[self refresh];
	}
}

- (XMCondition *)condition
{
	return self.optimizeService.condition;
}

- (void)setCondition:(XMCondition *)condition
{
	if (![self.optimizeService.condition isEqual:condition])
	{
		self.optimizeService.condition = condition;
		[self refresh];
	}
}

- (NSString *)groupBy
{
	return self.optimizeService.groupBy;
}

- (void)setGroupBy:(NSString *)groupBy
{
	if (![self.optimizeService.groupBy isEqualToString:groupBy])
	{
		self.optimizeService.groupBy = groupBy;
		[self refresh];
	}
}

- (void)update
{
	if (!_mapView)
	{
		return;
	}
	
	XMMercatorProjection *projection = [[XMMercatorProjection alloc] initWithRegion:_mapView.region andViewport:_mapView.bounds.size];
	XMTileRect tileRect = [projection tileRectForRegion:_mapView.region andViewport:_mapView.bounds.size];
	NSUInteger zoomLevel = projection.zoomLevel;
	
	if (_zoomLevel != zoomLevel)
	{
		[_mapView removeAnnotations:self.annotations];
		[self.annotations removeAllObjects];
		
		[self.tileCache clearAll];
		_zoomLevel = zoomLevel;
	}
	
	_lastRect = tileRect;
	[self.tileService clusterizeTileRect:tileRect];
	
	[projection release];
}

- (void)refresh
{
	[self.optimizeService cancelRequests];
	[self.tileService clearCache];
	[self.tileCache clearAll];
	[self.mapView removeAnnotations:self.annotations];
	[self.annotations removeAllObjects];
	
	[self update];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
	if ([self.delegate respondsToSelector:@selector(mapController:regionDidChangeAnimated:)])
	{
		[self.delegate mapController:self regionDidChangeAnimated:animated];
	}
	
	[self.optimizeService cancelRequests];
	[self update];
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
	if ([self.delegate respondsToSelector:@selector(mapController:regionWillChangeAnimated:)])
	{
		[self.delegate mapController:self regionWillChangeAnimated:animated];
	}
}

- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView
{
	if ([self.delegate respondsToSelector:@selector(mapControllerWillStartLoadingMap:)])
	{
		[self.delegate mapControllerWillStartLoadingMap:self];
	}
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
	if ([self.delegate respondsToSelector:@selector(mapControllerDidFinishLoadingMap:)])
	{
		[self.delegate mapControllerDidFinishLoadingMap:self];
	}
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error
{
	if ([self.delegate respondsToSelector:@selector(mapControllerDidFailLoadingMap:withError:)])
	{
		[self.delegate mapControllerDidFailLoadingMap:self withError:error];
	}
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
	if ([self.delegate respondsToSelector:@selector(mapController:didAddAnnotationViews:)])
	{
		[self.delegate mapController:self didAddAnnotationViews:views];
	}
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
	if ([self.delegate respondsToSelector:@selector(mapController:annotationView:calloutAccessoryControlTapped:)])
	{
		[self.delegate mapController:self annotationView:view calloutAccessoryControlTapped:control];
	}
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
	if ([annotation isKindOfClass:[XMCluster class]])
	{
		XMCluster *cluster = (XMCluster *)annotation;
		return [self mapView:mapView viewForCluster:cluster];
	}
	
	if ([annotation isKindOfClass:[XMMarker class]])
	{
		XMMarker *marker = (XMMarker *)annotation;
		return [self mapView:mapView viewForMarker:marker];
	}
	
	if ([self.delegate respondsToSelector:@selector(mapController:viewForAnnotation:)])
	{
		return [self.delegate mapController:self viewForAnnotation:annotation];
	}
	
	return nil; 
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForCluster:(XMCluster *)cluster
{
	if ([_delegate respondsToSelector:@selector(mapController:viewForCluster:)])
	{
		MKAnnotationView *view = [_delegate mapController:self viewForCluster:cluster];
		if (view)
		{
			return view;
		}
	}
	
	static NSString *identifier = @"MaptimizeController:Cluster";
	
	MKAnnotationView *view = [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
	if (!view)
	{
		view = [[XMClusterView alloc] initWithAnnotation:cluster reuseIdentifier:identifier];
		[view setBackgroundColor:[UIColor clearColor]];
	}
	else
	{
		[view setAnnotation:cluster];
	}
	
	return view;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForMarker:(XMMarker *)marker
{
	if ([_delegate respondsToSelector:@selector(mapController:viewForMarker:)])
	{
		MKAnnotationView *view = [_delegate mapController:self viewForMarker:marker];
		if (view)
		{
			return view;
		}
	}
	
	return nil;
}

- (void)tileService:(XMTileService *)tileService failedWithError:(NSError *)error
{
	[_delegate mapController:self failedWithError:error];
}

- (void)tileServiceWillStartLoadingTiles:(XMTileService *)tileService
{
	if ([self.delegate respondsToSelector:@selector(mapControllerWillStartLoadingClusters:)])
	{
		[self.delegate mapControllerWillStartLoadingClusters:self];
	}
}

- (void)tileServiceDidFinishLoadingTiles:(XMTileService *)tileService fromCache:(BOOL)fromCache
{
	if ([self.delegate respondsToSelector:@selector(mapControllerDidFinishLoadingClusters:fromCache:)])
	{
		[self.delegate mapControllerDidFinishLoadingClusters:self fromCache:fromCache];
	}
}

- (void)tileServiceDidCancelLoadingTiles:(XMTileService *)tileService
{
	if ([self.delegate respondsToSelector:@selector(mapControllerDidCancelLoadingClusters:)])
	{
		[self.delegate mapControllerDidCancelLoadingClusters:self];
	}
}

- (void)tileService:(XMTileService *)tileService didClusterizeTile:(XMTile)tile withGraph:(XMGraph *)graph;
{
	if ([self.delegate respondsToSelector:@selector(mapController:didClusterizeTile:withGraph:)])
	{
		[self.delegate mapController:self didClusterizeTile:tile withGraph:graph];
	}
	
	if (tile.level != _zoomLevel)
	{
		return;
	}
	
	NSMutableDictionary *tileInfo = [self.tileCache objectForTile:tile];
	BOOL showed = [[tileInfo objectForKey:@"showed"] boolValue];
	if (showed)
	{
		return;
	}
	
	if (!tileInfo)
	{
		tileInfo = [NSMutableDictionary dictionary];
		[tileInfo setObject:[NSNumber numberWithBool:YES] forKey:@"showed"];
		[self.tileCache setObject:tileInfo forTile:tile];
	}
	
	[_annotations addObjectsFromArray:graph.clusters];
	[_annotations addObjectsFromArray:graph.markers];
	
	[_mapView addAnnotations:graph.clusters];
	[_mapView addAnnotations:graph.markers];
}

- (void)tileCache:(XMTileCache *)tileCache reachedCapacity:(NSUInteger)capacity
{
	NSLog(@"tileCache reached capacity: %d", capacity);
	
	NSLog(@"clearing all except last tile rect");
	[tileCache clearAllExceptRect:_lastRect];
	
	for (id<MKAnnotation> annotation in [_mapView.annotations copy])
	{
		if (![annotation isKindOfClass:[XMPlacemark class]])
		{
			continue;
		}
		
		XMPlacemark *placemark = (XMPlacemark *)annotation;
		
		id info = [self.tileCache objectForTile:placemark.tile];
		if (!info)
		{
			[_annotations removeObject:placemark];
			[_mapView removeAnnotation:placemark];
		}
	}
	
	NSUInteger count = tileCache.tilesCount;
	NSLog(@"tilesCount: %d", count);
}

@end
