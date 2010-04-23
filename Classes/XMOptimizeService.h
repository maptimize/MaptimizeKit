//
//  MaptimizeService.h
//  Bredbandskollen
//
//  Created by Aleks Nesterow on 8/11/09.
//  aleks.nesterow@gmail.com
//  
//  Copyright © 2009 Screen Customs s.r.o. All rights reserved.
//  
//  Purpose
//	Requests the web-service for meta-data about clusters.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#import "XMBounds.h"

typedef enum
{
	RequestClusterize,
	RequestSelect
} RequestType;

@class XMOptimizeService;

@protocol XMOptimizeServiceDelegate

- (void)optimizeService:(XMOptimizeService *)optimizeService didClusterize:(NSDictionary *)graph userInfo:(id)userInfo;
- (void)optimizeService:(XMOptimizeService *)optimizeService failedWithError:(NSError *)error;

@end

@interface XMOptimizeService : NSObject
{
@private
	NSOperationQueue *_queue;
	
	NSUInteger _groupingDistance;
	NSString *_mapKey;
	
	id<XMOptimizeServiceDelegate> _delegate;
}

@property (nonatomic, assign) IBOutlet id<XMOptimizeServiceDelegate> delegate;
@property (nonatomic, assign) NSUInteger groupingDistance;
@property (nonatomic, retain) NSString *mapKey;

- (void)cancelRequests;
- (void)clusterizeBounds:(XMBounds)bounds withZoomLevel:(NSUInteger)zoomLevel userInfo:(id)userInfo;

@end
