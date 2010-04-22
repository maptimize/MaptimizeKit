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

#import "Tile.h"

@interface Cluster : NSObject <MKAnnotation>
{
@private
	
	Tile _tile;
	CLLocationCoordinate2D _coordinate;
	NSUInteger _count;
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

@property (nonatomic, assign) Tile tile;
@property (nonatomic, assign) NSUInteger count;

@end
