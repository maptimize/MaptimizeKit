//
//  XMGraph.m
//  MaptimizeKit
//
//  Created by Oleg Shnitko on 4/23/10.
//  olegshnitko@gmail.com
//  
//  Copyright © 2010 Screen Customs s.r.o. All rights reserved.
//

#import "XMGraph.h"

#import "SCMemoryManagement.h"

@implementation XMGraph

@synthesize totalCount = _totalCount;
@synthesize clusters = _clusters;
@synthesize markers = _markers;

- (id)initWithClusters:(NSArray *)clusters markers:(NSArray *)markers totalCount:(NSUInteger)totalCount
{
	if (self = [super init])
	{
		_totalCount = totalCount;
		_clusters = [clusters retain];
		_markers = [markers retain];
	}
	
	return self;
}

- (void)dealloc
{
	SC_RELEASE_SAFELY(_clusters);
	SC_RELEASE_SAFELY(_markers);
	
	[super dealloc];
}

@end
