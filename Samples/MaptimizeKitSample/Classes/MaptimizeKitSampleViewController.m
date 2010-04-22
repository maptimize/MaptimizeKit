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

@property (nonatomic, readonly) MaptimizeController *maptimizeController;

@end

@implementation MaptimizeKitSampleViewController

@synthesize mapView = _mapView;

- (void)dealloc
{
	SC_RELEASE_SAFELY(_maptimizeController);
	SC_RELEASE_SAFELY(_mapView);
	
    [super dealloc];
}

- (MaptimizeController *)maptimizeController
{
	if (!_maptimizeController)
	{
		_maptimizeController = [[MaptimizeController alloc] init];
		_maptimizeController.mapKey = MAP_KEY;
		_maptimizeController.delegate = self;
	}
	
	return _maptimizeController;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.maptimizeController.mapView = self.mapView;
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	self.maptimizeController.mapView = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
	[self.maptimizeController update];
}

- (void)maptimizeController:(MaptimizeController *)maptimizeController failedWithError:(NSError *)error
{
	SC_LOG_ERROR(@"Sample", @"Error: %@", error); 
}

@end
