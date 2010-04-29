//
//  XMGraph.h
//  MaptimizeKit
//
//  Created by Oleg Shnitko on 4/23/10.
//  olegshnitko@gmail.com
//  
//  Copyright © 2010 Screen Customs s.r.o. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "XMCluster.h"
#import "XMMarker.h"

@interface XMGraph : NSObject
{
@private
	
	NSUInteger _totalCount;
	
	NSMutableArray *_clusters;
	NSMutableArray *_markers;
}

- (id)initWithClusters:(NSArray *)clusters markers:(NSArray *)markers totalCount:(NSUInteger)totalCount;

@property (nonatomic, readonly) NSUInteger totalCount;

@property (nonatomic, readonly) NSArray *clusters;
@property (nonatomic, readonly) NSArray *markers;

- (void)addCluster:(XMCluster *)cluster;
- (void)addMarker:(XMMarker *)marker;

@end
