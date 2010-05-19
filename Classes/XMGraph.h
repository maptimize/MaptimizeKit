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

/*
 Class: XMGraph
 
 XMGraph represents collection of clusters and markers fetched by single API request.
 
 */
@interface XMGraph : NSObject
{
@private
	
	NSUInteger _totalCount;
	
	NSMutableArray *_clusters;
	NSMutableArray *_markers;
}

/*
 Method: initWithClusters:markers:totalCount:
 */
- (id)initWithClusters:(NSArray *)clusters markers:(NSArray *)markers totalCount:(NSUInteger)totalCount;

/*
 Method: addCluster:
 */
- (void)addCluster:(XMCluster *)cluster;

/*
 Method: addMarker:
 */
- (void)addMarker:(XMMarker *)marker;

/*
 Property: totalCount
 
 Total point count in this collection.
 
 */
@property (nonatomic, readonly) NSUInteger totalCount;

/*
 Property: clusters
 */
@property (nonatomic, readonly) NSArray *clusters;

/*
 Property: markers
 */
@property (nonatomic, readonly) NSArray *markers;

@end
