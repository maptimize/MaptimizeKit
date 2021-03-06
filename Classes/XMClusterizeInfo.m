//
//  XMClusterizeInfo.m
//  MaptimizeKit
//
//  Created by Oleg Shnitko on 5/20/10.
//  olegshnitko@gmail.com
//  
//  Copyright © 2010 Screen Customs s.r.o. All rights reserved.
//

#import "XMClusterizeInfo.h"

#import "SCMemoryManagement.h"

@implementation XMClusterizeInfo

@synthesize tiles = _tiles;
@synthesize tileRect = _tileRect;
@synthesize graph = _graph;

- (id)init
{
	if (self = [super init])
	{
		_tiles = [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (void)dealloc
{
	SC_RELEASE_SAFELY(_tiles);
	SC_RELEASE_SAFELY(_graph);
	
	[super dealloc];
}

@end
