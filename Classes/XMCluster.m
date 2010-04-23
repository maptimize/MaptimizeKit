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

#import "XMCluster.h"


@implementation XMCluster

@synthesize count = _count;

- (NSString *)title
{
	return [NSString stringWithFormat:@"%d", _count];
}

@end
