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

#import "MercatorProjection.h"

typedef enum
{
	RequestClusterize,
	RequestSelect
} RequestType;

@class MaptimizeService;

@protocol MaptimizeServiceDelegate

- (void)maptimizeService:(MaptimizeService *)maptimizeService didClusterize:(NSDictionary *)graph userInfo:(id)userInfo;
- (void)maptimizeService:(MaptimizeService *)maptimizeService failedWithError:(NSError *)error;

@end

@interface MaptimizeService : NSObject
{
@private
	NSOperationQueue *_queue;
	
	NSUInteger _groupingDistance;
	NSString *_mapKey;
	
	id<MaptimizeServiceDelegate> _delegate;
}

@property (nonatomic, assign) IBOutlet id<MaptimizeServiceDelegate> delegate;
@property (nonatomic, assign) NSUInteger groupingDistance;
@property (nonatomic, retain) NSString *mapKey;

- (void)cancelRequests;
- (void)clusterizeBounds:(Bounds)bounds withZoomLevel:(NSUInteger)zoomLevel userInfo:(id)userInfo;

@end
