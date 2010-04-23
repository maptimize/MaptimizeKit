//
//  XMOptimizeService.h
//  MaptimizeKit
//
//  Created by Oleg Shnitko on 20/04/10.
//  olegshnitko@gmail.com
//  
//  Copyright © 2010 Screen Customs s.r.o. All rights reserved.
//  

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#import "XMBounds.h"
#import "XMGraph.h"

typedef enum
{
	RequestClusterize,
	RequestSelect
} RequestType;

@class XMOptimizeService;

@protocol XMOptimizeServiceDelegate

- (void)optimizeService:(XMOptimizeService *)optimizeService didClusterize:(XMGraph *)graph userInfo:(id)userInfo;
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
