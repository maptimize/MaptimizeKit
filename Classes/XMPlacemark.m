//
//  Placemark.m
//  MaptimizeKit
//
//  Created by Oleg Shnitko on 4/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "XMPlacemark.h"


@implementation XMPlacemark

@synthesize tile = _tile;

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


@end
