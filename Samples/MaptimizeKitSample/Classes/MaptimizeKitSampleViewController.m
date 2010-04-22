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
@property (nonatomic, readonly) MaptimizeService *service;

@end

@implementation MaptimizeKitSampleViewController

@synthesize mapView = _mapView;

- (void)dealloc
{
	SC_RELEASE_SAFELY(_converter);
	SC_RELEASE_SAFELY(_service);
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

- (MaptimizeService *)service
{
	if (!_service)
	{
		_service = [[MaptimizeService alloc] init];
		_service.entitiesConverter = self.converter;
		_service.mapKey = @"43ca6fa91127c2cbac6b513dbe0381204caae5ec";
		_service.delegate = self;
	}
	
	return _service;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
	MercatorProjection *projection = [[MercatorProjection alloc] initWithRegion:mapView.region andViewport:mapView.bounds.size];
	NSUInteger zoomLevel = projection.zoomLevel;
	
	TileRect tileRect = [projection tileRectForRegion:mapView.region andViewport:mapView.bounds.size];
	
	[_mapView removeAnnotations:_mapView.annotations];
	for (UInt64 i = 0; i < tileRect.size.width; i++)
	{
		for (UInt64 j = 0; j < tileRect.size.height; j++)
		{
			TilePoint tile;
			tile.x = tileRect.origin.x + i;
			tile.y = tileRect.origin.y + j;
			
			Bounds bounds = [projection boundsForTile:tile];
			[self.service clusterizeBounds:bounds withZoomLevel:zoomLevel];
		}
	}
	
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

- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView
{
	/*MKCoordinateRegion region = mapView.region;
	CGSize size = mapView.frame.size;
	
	int zoom = [self.converter zoomFromSpan:region.span andViewportSize:size];
	SC_LOG_TRACE(@"SampleViewController", @"willStartLoading with zoom: %d", zoom);
	*/
	
}

- (void)maptimizeService:(MaptimizeService *)maptimizeService failedWithError:(NSError *)error
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

- (void)maptimizeService:(MaptimizeService *)maptimizeService didClusterize:(NSDictionary *)graph
{
	//[_mapView removeAnnotations:_mapView.annotations];
	//SC_LOG_TRACE(@"Sample", @"Graph: %@", graph);
	NSArray *clusters = [graph objectForKey:@"clusters"];
	for (NSDictionary *clusterDict in clusters)
	{
		//SC_LOG_TRACE(@"Sample", @"Cluster: %@", clusterDict);
		NSString *coordString = [clusterDict objectForKey:@"coords"];
		NSUInteger count = [[clusterDict objectForKey:@"count"] intValue];
		CLLocationCoordinate2D coordinate = [self coordinatesFromString:coordString];
		Cluster *c = [[Cluster alloc] initWithCoordinate:coordinate];
		c.count = count;
		
		[_mapView addAnnotation:c];
	}
}

@end
