//
//  MaptimizeKitSampleViewController.h
//  MaptimizeKitSample
//
//  Created by Oleg Shnitko on 4/20/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "EntitiesConverter.h"

@interface MaptimizeKitSampleViewController : UIViewController <MKMapViewDelegate>
{
@private
	
	EntitiesConverter *_converter;
}

@end

