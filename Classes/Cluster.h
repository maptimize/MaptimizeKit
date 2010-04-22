//
//  Cluster.h
//  MaptimizeKit
//
//  Created by Oleg Shnitko on 4/20/10.
//	oleg@screencustoms.com
//	
//  Copyright © 2010 __MyCompanyName__
//	All rights reserved.
//	
//	Purpose
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#import "Placemark.h"

@interface Cluster : Placemark
{
@private

	NSUInteger _count;
}

@property (nonatomic, assign) NSUInteger count;

@end
