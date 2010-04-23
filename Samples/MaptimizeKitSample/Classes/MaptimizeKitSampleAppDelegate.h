//
//  MaptimizeKitSampleAppDelegate.h
//  MaptimizeKitSample
//
//  Created by Oleg Shnitko on 4/20/10.
//  olegshnitko@gmail.com
//  
//  Copyright © 2010 Screen Customs s.r.o. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MaptimizeKitSampleViewController;

@interface MaptimizeKitSampleAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    MaptimizeKitSampleViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet MaptimizeKitSampleViewController *viewController;

@end

