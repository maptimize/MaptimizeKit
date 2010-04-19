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

//#import "Operator.h"
//#import "Placering.h"

#define CLUSTERIZE_URL		@"%@/%@/clusterize?zoom=%d&sw=%@&ne=%@&condition=%@&aggregates=%@&properties=speed_down,speed_up,date,Placering,Operator,model&span=%@&viewport=%@&groupingDistance=%d"
#define SELECT_URL			@"%@/%@/select?zoom=%d&sw=%@&ne=%@&condition=%@&aggregates=%@&properties=speed_down,speed_up,date,Placering,Operator,model&offset=0&count=50&span=%@&viewport=%@"

#define	BASE_URL			@"http://engine.maptimize.com/map"
#define MAP_KEY				@"0b8594b060360cbb548d62f1b2b60cd32044003a"
#define LAT_LONG_FORMAT		@"%f,%f"

#define CONDITION_PLACERING	@"Placering='%@'"
#define CONDITION_OPERATOR	@"Operator='%@'"
#define CONDITION_MODEL		@"model='%@'"
#define AGGREGATE			@"avg(speed_down)"

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
}

@property (nonatomic, assign) IBOutlet id<MaptimizeServiceDelegate> delegate;
@property (nonatomic, retain) IBOutlet EntitiesConverter *entitiesConverter;
@property (nonatomic, assign) NSUInteger groupingDistance;

- (void)cancelRequests;

/**
 * @param viewportSize	Specifies the size of the MKMapView instance.
 */
- (void)clusterizeAtRegion:(MKCoordinateRegion)region andViewportSize:(CGSize)viewportSize;
				 /*withModel:(PhoneModel)model conditionPlacering:(Placering)placering
			   andOperator:(Operator)mobileOperator;*/

/**
 * @param viewportSize	Specifies the size of the MKMapView instance.
 */
- (void)selectAtRegion:(MKCoordinateRegion)region andViewportSize:(CGSize)viewportSize;
			 /*withModel:(PhoneModel)model conditionPlacering:(Placering)placering 
		   andOperator:(Operator)mobileOperator;*/

@end
