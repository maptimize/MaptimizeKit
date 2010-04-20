//
//  MaptimizeKitSampleAppDelegate.h
//  MaptimizeKitSample
//
//  Created by Oleg Shnitko on 4/20/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
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

