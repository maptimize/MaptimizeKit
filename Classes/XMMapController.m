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

#import "XMMercatorProjection.h"
#import "XMClusterView.h"

#import "SCMemoryManagement.h"
#import "SCLog.h"

#define TILE_CACHE_SIZE 128

@interface XMMapController (Private)

@property (nonatomic, readonly) XMOptimizeService *optimizeService;
@property (nonatomic, readonly) XMTileService *tileService;
@property (nonatomic, readonly) XMTileCache *tileCache;

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForCluster:(XMCluster *)cluster;
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForMarker:(XMMarker *)marker;

@end

@implementation XMMapController

@synthesize mapView = _mapView;
@synthesize delegate = _delegate;

- (void)dealloc
{
	SC_RELEASE_SAFELY(_optimizeService);
	SC_RELEASE_SAFELY(_tileService);
	SC_RELEASE_SAFELY(_tileCache);
	
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
		[self.optimizeService cancelRequests];
		[self.tileService clearCache];
		[self.tileCache clearAll];
		[self.mapView removeAnnotations:self.mapView.annotations];
		
		self.optimizeService.mapKey = mapKey;
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
		[_mapView removeAnnotations:_mapView.annotations];
		[self.tileCache clearAll];
		_zoomLevel = zoomLevel;
	}
	
	_lastRect = tileRect;
	[self.tileService clusterizeTileRect:tileRect];
	
	[projection release];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
	[self update];
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

- (CLLocationCoordinate2D)coordinatesFromString:(NSString *)value
{
	NSArray *chunks = [value componentsSeparatedByString:@","]; /* Should contain 2 parts: latitude and longitude. */
	
	NSString *latitudeValue = [chunks objectAtIndex:0];
	NSString *longitudeValue = [chunks objectAtIndex:1];
	
	CLLocationCoordinate2D result;
	result.latitude = [latitudeValue doubleValue];
	result.longitude = [longitudeValue doubleValue];
	return result;
}

- (void)tileService:(XMTileService *)tileService didClusterizeTile:(XMTile)tile withGraph:(XMGraph *)graph;
{
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
	
	[_mapView addAnnotations:graph.clusters];
	[_mapView addAnnotations:graph.markers];
}

- (void)tileCache:(XMTileCache *)tileCache reachedCapacity:(NSUInteger)capacity
{
	NSLog(@"tileCache reached capacity: %d", capacity);
	
	NSLog(@"clearing all except last tile rect");
	[tileCache clearAllExceptRect:_lastRect];
	
	for (XMPlacemark *placemark in [_mapView.annotations copy])
	{
		id info = [self.tileCache objectForTile:placemark.tile];
		if (!info)
		{
			[_mapView removeAnnotation:placemark];
		}
	}
	
	NSUInteger count = tileCache.tilesCount;
	NSLog(@"tilesCount: %d", count);
}

@end
