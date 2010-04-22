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

#define CLUSTERIZE_URL		@"%@/%@/clusterize?sw=%@&ne=%@&z=%d"
#define SELECT_URL			@"%@/%@/select?zoom=%d&sw=%@&ne=%@&condition=%@&aggregates=%@&properties=%@&span=%@&viewport=%@&offset=%d&count=%d"

#define	BASE_URL			@"http://betav2.maptimize.com/api/v2-0"
#define LAT_LONG_FORMAT		@"%f,%f"

typedef enum {
	RequestClusterize,
	RequestSelect
} RequestType;

@class MaptimizeService;

@protocol MaptimizeServiceDelegate

- (void)maptimizeService:(MaptimizeService *)maptimizeService failedWithError:(NSError *)error;

@optional

- (void)maptimizeService:(MaptimizeService *)maptimizeService didClusterize:(NSDictionary *)graph;
- (void)maptimizeService:(MaptimizeService *)maptimizeService didSelect:(NSDictionary *)graph;

@end

@class EntitiesConverter;

@interface MaptimizeService : NSObject {
	
@private
	NSOperationQueue *_queue;
	
	id<MaptimizeServiceDelegate> _delegate;
	EntitiesConverter *_entitiesConverter;
	
	NSUInteger _groupingDistance;
	
	NSString *_mapKey;
}

@property (nonatomic, assign) IBOutlet id<MaptimizeServiceDelegate> delegate;
@property (nonatomic, retain) IBOutlet EntitiesConverter *entitiesConverter;
@property (nonatomic, assign) NSUInteger groupingDistance;
@property (nonatomic, retain) NSString *mapKey;

- (void)cancelRequests;

- (void)clusterizeBounds:(Bounds)bounds withZoomLevel:(NSUInteger)zoomLevel;

/**
 * @param viewportSize	Specifies the size of the MKMapView instance.
 */
- (void)clusterizeAtRegion:(MKCoordinateRegion)region andViewportSize:(CGSize)viewportSize
			 withCondition:(NSString *)condition aggregates:(NSString *)aggregates properties:(NSString *)properties;

/**
 * @param viewportSize	Specifies the size of the MKMapView instance.
 */
- (void)selectAtRegion:(MKCoordinateRegion)region andViewportSize:(CGSize)viewportSize
		 withCondition:(NSString *)condition aggregates:(NSString *)aggregates properties:(NSString *)properties
				offset:(NSUInteger)offset count:(NSUInteger)count;

@end
