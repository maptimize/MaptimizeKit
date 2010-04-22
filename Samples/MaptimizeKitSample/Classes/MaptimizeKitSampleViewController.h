//
//  MaptimizeKitSampleViewController.h
//  MaptimizeKitSample
//
//  Created by Oleg Shnitko on 4/20/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "MaptimizeService.h"
#import "EntitiesConverter.h"
#import "TileService.h"

@interface MaptimizeKitSampleViewController : UIViewController <MKMapViewDelegate, TileServiceDelegate>
{
@private
	
	EntitiesConverter *_converter;
	MaptimizeService *_maptimizeService;
	TileService *_tileService;
	
	MKMapView *_mapView;
	
	NSUInteger _zoomLevel;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;

@end

