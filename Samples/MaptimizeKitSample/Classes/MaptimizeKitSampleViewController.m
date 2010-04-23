//
//  MaptimizeKitSampleViewController.m
//  MaptimizeKitSample
//
//  Created by Oleg Shnitko on 4/20/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "MaptimizeKitSampleViewController.h"

//#define MAP_KEY @"0b8594b060360cbb548d62f1b2b60cd32044003a" // bbk
#define MAP_KEY @"43ca6fa91127c2cbac6b513dbe0381204caae5ec" // crunch

#import "SCMemoryManagement.h"
#import "SCLog.h"

@interface MaptimizeKitSampleViewController (Private)

@property (nonatomic, readonly) XMMapController *mapController;

@end

@implementation MaptimizeKitSampleViewController

@synthesize mapView = _mapView;

- (void)dealloc
{
	SC_RELEASE_SAFELY(_mapController);
	SC_RELEASE_SAFELY(_mapView);
	
    [super dealloc];
}

- (XMMapController *)mapController
{
	if (!_mapController)
	{
		_mapController = [[XMMapController alloc] init];
		_mapController.mapKey = MAP_KEY;
		_mapController.delegate = self;
	}
	
	return _mapController;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.mapController.mapView = self.mapView;
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	self.mapController.mapView = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
	[self.mapController update];
}

- (MKAnnotationView *)mapController:(XMMapController *)mapController viewForMarker:(XMMarker *)marker
{
	static NSString *identifier = @"Marker";
	
	MKAnnotationView *view = [mapController.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
	if (!view)
	{
		view = [[MKAnnotationView alloc] initWithAnnotation:marker reuseIdentifier:identifier];
		view.image = [UIImage imageNamed:@"marker.png"];
		view.centerOffset = CGPointMake(0.0f, -33.0f/2.0f);
	}
	else
	{
		[view setAnnotation:marker];
	}

	return view;
}

- (void)mapController:(XMMapController *)mapController failedWithError:(NSError *)error
{
	SC_LOG_ERROR(@"Sample", @"Error: %@", error); 
}

@end
