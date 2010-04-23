//
//  XMCluster.h
//  MaptimizeKit
//
//  Created by Oleg Shnitko on 4/20/10.
//  olegshnitko@gmail.com
//  
//  Copyright © 2010 Screen Customs s.r.o. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#import "XMPlacemark.h"
#import "XMBounds.h"

@interface XMCluster : XMPlacemark
{
@private

	NSUInteger _count;
	XMBounds _bounds;
}

@property (nonatomic, assign) NSUInteger count;
@property (nonatomic, assign) XMBounds bounds;

@end
