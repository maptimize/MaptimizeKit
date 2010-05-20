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

@synthesize tiles;
@synthesize tileRect;
@synthesize graph;

- (id)init
{
	if (self = [super init])
	{
		tiles = [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (void)dealloc
{
	SC_RELEASE_SAFELY(tiles);
	SC_RELEASE_SAFELY(graph);
	
	[super dealloc];
}

@end
