//
//  XMClusterizeRequest.m
//  MaptimizeKit
//
//  Created by Oleg Shnitko on 4/23/10.
//  olegshnitko@gmail.com
//  
//  Copyright © 2010 Screen Customs s.r.o. All rights reserved.
//

#import "XMClusterizeRequest.h"

#define METHOD @"clusterize"

@implementation XMClusterizeRequest

- (id)initWithMapKey:(NSString *)mapKey
			  bounds:(XMBounds)bounds
		   zoomLevel:(NSUInteger)zoomLevel
			  params:(NSDictionary *)params
{
	return [super initWithMapKey:mapKey method:METHOD bounds:bounds zoomLevel:zoomLevel params:params];
}

@end
