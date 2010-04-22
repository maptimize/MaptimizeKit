//
//  MaptimizeKitSampleViewController.h
//  MaptimizeKitSample
//
//  Created by Oleg Shnitko on 4/20/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "MaptimizeController.h"

@interface MaptimizeKitSampleViewController : UIViewController
{
@private

	MKMapView *_mapView;
	MaptimizeController *_maptimizeController;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;

@end

