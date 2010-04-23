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

#import "XMCondition.h"
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
	NSString *_mapKey;
	NSMutableDictionary *_params;
	
	id<XMOptimizeServiceDelegate> _delegate;
}

@property (nonatomic, assign) IBOutlet id<XMOptimizeServiceDelegate> delegate;
@property (nonatomic, retain) NSString *mapKey;

@property (nonatomic, assign) NSUInteger distance;

@property (nonatomic, retain) NSArray *properties;
@property (nonatomic, retain) NSString *aggregates;
@property (nonatomic, retain) XMCondition *condition;
@property (nonatomic, retain) NSString *groupBy;

- (void)cancelRequests;
- (void)clusterizeBounds:(XMBounds)bounds withZoomLevel:(NSUInteger)zoomLevel userInfo:(id)userInfo;

@end
