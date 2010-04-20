//
//  MaptimizeKitSampleViewController.m
//  MaptimizeKitSample
//
//  Created by Oleg Shnitko on 4/20/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "MaptimizeKitSampleViewController.h"

#import "MaptimizeService.h"
#import "MKMapView+ZoomLevel.h"

#import "SCMemoryManagement.h"
#import "SCLog.h"

@interface MaptimizeKitSampleViewController (Private)

@property (nonatomic, readonly) EntitiesConverter *converter;

@end

@implementation MaptimizeKitSampleViewController

- (void)dealloc
{
	SC_RELEASE_SAFELY(_converter);
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
	//SC_LOG_TRACE(@"SampleViewController", @"regionDidChangeAnimated:%d", animated);
	NSUInteger zoomLevel = [mapView zoomLevel];
	SC_LOG_TRACE(@"SampleViewController", @"zoomLevel: %d", zoomLevel);
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
	//SC_LOG_TRACE(@"SampleViewContreoller", @"regionWillChamgeAnimated:%d", animated);
}

- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView
{
	/*MKCoordinateRegion region = mapView.region;
	CGSize size = mapView.frame.size;
	
	int zoom = [self.converter zoomFromSpan:region.span andViewportSize:size];
	SC_LOG_TRACE(@"SampleViewController", @"willStartLoading with zoom: %d", zoom);
	*/
	
}

@end
