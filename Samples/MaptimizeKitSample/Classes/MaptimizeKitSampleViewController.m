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

@interface MaptimizeKitSampleViewController (Private)

@property (nonatomic, readonly) EntitiesConverter *converter;
@property (nonatomic, readonly) MaptimizeService *maptimizeService;
@property (nonatomic, readonly) TileService *tileService;

@end

@implementation MaptimizeKitSampleViewController

@synthesize mapView = _mapView;

- (void)dealloc
{
	SC_RELEASE_SAFELY(_converter);
	SC_RELEASE_SAFELY(_maptimizeService);
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
	MercatorProjection *projection = [[MercatorProjection alloc] initWithRegion:mapView.region andViewport:mapView.bounds.size];
	TileRect tileRect = [projection tileRectForRegion:mapView.region andViewport:mapView.bounds.size];
	NSUInteger zoomLevel = projection.zoomLevel;
	
	BOOL notifyCached = NO;
	
	if (_zoomLevel != zoomLevel)
	{
		[_mapView removeAnnotations:_mapView.annotations];
		_zoomLevel = zoomLevel;
		notifyCached = YES;
	}
	
	[self.tileService clusterizeTileRect:tileRect withProjection:projection notifyCached:notifyCached];
	
	[projection release];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	MKAnnotationView *view = [mapView dequeueReusableAnnotationViewWithIdentifier:@"cluster"];
	
	//if (!view)
	//{
		view = [[ClusterView alloc] initWithAnnotation:annotation reuseIdentifier:@"cluster"];
		[view setBackgroundColor:[UIColor clearColor]];
	//}
	//else
	//{
	//	[view setAnnotation:annotation];
	//}
	
	CGSize size = [[annotation title] sizeWithFont:[UIFont systemFontOfSize:14]];
	CGFloat r = 2 * MAX(size.width, size.height) + 15;
	CGRect frame = CGRectMake(0, 0, r, r);
	[view setFrame:frame];
	
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

- (void)tileService:(TileService *)tileService didClusterize:(NSDictionary *)graph atZoomLevel:(NSUInteger)zoomLevel
{
	if (zoomLevel != _zoomLevel)
	{
		return;
	}
	
	NSArray *clusters = [graph objectForKey:@"clusters"];
	for (NSDictionary *clusterDict in clusters)
	{
		NSString *coordString = [clusterDict objectForKey:@"coords"];
		NSUInteger count = [[clusterDict objectForKey:@"count"] intValue];
		CLLocationCoordinate2D coordinate = [self coordinatesFromString:coordString];
		Cluster *c = [[Cluster alloc] initWithCoordinate:coordinate];
		c.count = count;
		
		[_mapView addAnnotation:c];
	}
}

@end
