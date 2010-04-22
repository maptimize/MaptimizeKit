//
//  Cluster.m
//  MaptimizeKit
//
//  Created by Oleg Shnitko on 4/20/10.
//	oleg@screencustoms.com
//	
//  Copyright © 2010 __MyCompanyName__
//	All rights reserved.
//

#import "Cluster.h"


@implementation Cluster

@synthesize count = _count;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate
{
	if (self = [super init])
	{
		_coordinate = coordinate;
	}
	
	return self;
}

- (CLLocationCoordinate2D)coordinate
{
	return _coordinate;
}

- (NSString *)title
{
	return [NSString stringWithFormat:@"%d", _count];
}

@end
