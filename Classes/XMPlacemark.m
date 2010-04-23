//
//  XMPlacemark.m
//  MaptimizeKit
//
//  Created by Oleg Shnitko on 4/22/10.
//  olegshnitko@gmail.com
//  
//  Copyright © 2010 Screen Customs s.r.o. All rights reserved.
//

#import "XMPlacemark.h"
#import "SCMemoryManagement.h"

@implementation XMPlacemark

@synthesize tile = _tile;
@synthesize data = _data;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate
{
	if (self = [super init])
	{
		_coordinate = coordinate;
	}
	
	return self;
}

- (void)dealloc
{
	SC_RELEASE_SAFELY(_data);
	[super dealloc];
}

- (CLLocationCoordinate2D)coordinate
{
	return _coordinate;
}


@end
