//
//  MaptimizeKitSampleViewController.m
//  MaptimizeKitSample
//
//  Created by Oleg Shnitko on 4/20/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "MaptimizeKitSampleViewController.h"

#import "MKMapView+ZoomLevel.h"
#import "MercatorProjection.h"
#import "Cluster.h"
#import "ClusterView.h"

#import "SCMemoryManagement.h"
#import "SCLog.h"

#define TILE_CACHE_SIZE 128

@interface MaptimizeKitSampleViewController (Private)

@property (nonatomic, readonly) EntitiesConverter *converter;
@property (nonatomic, readonly) MaptimizeService *maptimizeService;
@property (nonatomic, readonly) TileService *tileService;
@property (nonatomic, readonly) TileCache *tileCache;

@end

@implementation MaptimizeKitSampleViewController

@synthesize mapView = _mapView;

- (void)dealloc
{
	SC_RELEASE_SAFELY(_converter);
	SC_RELEASE_SAFELY(_maptimizeService);
	SC_RELEASE_SAFELY(_tileService);
	SC_RELEASE_SAFELY(_tileCache);
	
	SC_RELEASE_SAFELY(_mapView);
	
    [super dealloc];
}

- (EntitiesConverter *)converter
{
	if (!_converter)
	{
		_converter = [[EntitiesConverter alloc] init];
	}
	
	return _converter;
}

- (MaptimizeService *)maptimizeService
{
	if (!_maptimizeService)
	{
		_maptimizeService = [[MaptimizeService alloc] init];
		_maptimizeService.entitiesConverter = self.converter;
		_maptimizeService.mapKey = @"43ca6fa91127c2cbac6b513dbe0381204caae5ec";
	}
	
	return _maptimizeService;
}

- (TileService *)tileService
{
	if (!_tileService)
	{
		_tileService = [[TileService alloc] initWithMaptimizeService:self.maptimizeService];
		_tileService.delegate = self;
	}
	
	return _tileService;
}

- (TileCache *)tileCache
{
	if (!_tileCache)
	{
		_tileCache = [[TileCache alloc] initWithCapacity:TILE_CACHE_SIZE];
		_tileCache.delegate = self;
	}
	
	return _tileCache;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
	MercatorProjection *projection = [[MercatorProjection alloc] initWithRegion:mapView.region andViewport:mapView.bounds.size];
	TileRect tileRect = [projection tileRectForRegion:mapView.region andViewport:mapView.bounds.size];
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

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	MKAnnotationView *view = [mapView dequeueReusableAnnotationViewWithIdentifier:@"cluster"];
	
	if (!view)
	{
		view = [[ClusterView alloc] initWithAnnotation:annotation reuseIdentifier:@"cluster"];
		[view setBackgroundColor:[UIColor clearColor]];
	}
	else
	{
		[view setAnnotation:annotation];
	}
	
	return view;
}

- (void)tileService:(TileService *)tileService failedWithError:(NSError *)error
{
	SC_LOG_ERROR(@"Sample", @"Error: %@", error); 
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

- (void)tileService:(TileService *)tileService didClusterizeTile:(Tile)tile withGraph:(NSDictionary *)graph;
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
	
	NSArray *clusters = [graph objectForKey:@"clusters"];
	for (NSDictionary *clusterDict in clusters)
	{
		NSString *coordString = [clusterDict objectForKey:@"coords"];
		NSUInteger count = [[clusterDict objectForKey:@"count"] intValue];
		CLLocationCoordinate2D coordinate = [self coordinatesFromString:coordString];
		
		Cluster *cluster = [[Cluster alloc] initWithCoordinate:coordinate];
		cluster.count = count;
		cluster.tile = tile;
		
		[_mapView addAnnotation:cluster];
	}
}

- (void)tileCache:(TileCache *)tileCache reachedCapacity:(NSUInteger)capacity
{
	NSLog(@"tileCache reached capacity: %d", capacity);
	
	NSLog(@"clearing all except last tile rect");
	[tileCache clearAllExceptRect:_lastRect];
	
	for (Cluster *cluster in [_mapView.annotations copy])
	{
		id info = [self.tileCache objectForTile:cluster.tile];
		if (!info)
		{
			[_mapView removeAnnotation:cluster];
		}
	}
	
	NSUInteger count = tileCache.tilesCount;
	NSLog(@"tilesCount: %d", count);
}

@end
