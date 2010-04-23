//
//  ClusterizeRequest.m
//  MaptimizeKit
//
//  Created by Oleg Shnitko on 4/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ClusterizeRequest.h"

#define METHOD @"clusterize"

@implementation ClusterizeRequest

- (id)initWithMapKey:(NSString *)mapKey
			  bounds:(Bounds)bounds
		   zoomLevel:(NSUInteger)zoomLevel
			  params:(NSDictionary *)params
{
	return [super initWithMapKey:mapKey method:METHOD bounds:bounds zoomLevel:zoomLevel params:params];
}

@end
