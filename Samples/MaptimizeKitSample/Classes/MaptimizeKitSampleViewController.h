//
//  MaptimizeKitSampleViewController.h
//  MaptimizeKitSample
//
//  Created by Oleg Shnitko on 4/20/10.
//  olegshnitko@gmail.com
//  
//  Copyright © 2010 Screen Customs s.r.o. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "XMMapController.h"

@interface MaptimizeKitSampleViewController : UIViewController <XMMapControllerDelegate>
{
@private

	MKMapView *_mapView;
	XMMapController *_mapController;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;

@end

