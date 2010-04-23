//
//  XMCluster.m
//  MaptimizeKit
//
//  Created by Oleg Shnitko on 4/20/10.
//  olegshnitko@gmail.com
//  
//  Copyright © 2010 Screen Customs s.r.o. All rights reserved.
//

#import "XMCluster.h"


@implementation XMCluster

@synthesize count = _count;
@synthesize bounds = _bounds;

- (NSString *)title
{
	return [NSString stringWithFormat:@"%d", _count];
}

@end
