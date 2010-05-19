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

/*
 Class: XMCluster
 
 Represents cluster info.
 
 */
@interface XMCluster : XMPlacemark
{
@private

	NSUInteger _count;
	XMBounds _bounds;
}

/*
 Property: count
 
 Number of points aggregated in this cluster.
 
 */
@property (nonatomic, assign) NSUInteger count;

/*
 Property: bounds
 
 Represents area covered by this cluster.
 
 */
@property (nonatomic, assign) XMBounds bounds;

@end
