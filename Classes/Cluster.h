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

@interface Cluster : NSObject <MKAnnotation>
{
@private
	
	CLLocationCoordinate2D _coordinate;
	NSUInteger _count;
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

@property (nonatomic, assign) NSUInteger count;

@end
