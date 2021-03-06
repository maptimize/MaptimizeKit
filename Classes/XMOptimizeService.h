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

@protocol XMOptimizeServiceDelegate;
@protocol XMOptimizeServiceParser;

@class XMCondition;

@interface XMOptimizeService : NSObject
{
@private

	NSOperationQueue *_requestQueue;
	NSOperationQueue *_parseQueue;
	
	NSString *_mapKey;
	NSMutableDictionary *_params;
	
	id<XMOptimizeServiceDelegate> _delegate;
	id<XMOptimizeServiceParser>	_parser;
	
	NSUInteger _expandDistance;
	BOOL _filterResults;
}

@property (nonatomic, assign) IBOutlet id<XMOptimizeServiceDelegate> delegate;
@property (nonatomic, assign) IBOutlet id<XMOptimizeServiceParser> parser;

@property (nonatomic, retain) NSString *mapKey;

@property (nonatomic, assign) NSUInteger distance;

@property (nonatomic, retain) NSArray *properties;
@property (nonatomic, retain) NSString *aggregates;
@property (nonatomic, retain) XMCondition *condition;
@property (nonatomic, retain) NSString *groupBy;

@property (nonatomic, assign) NSUInteger expandDistance;
@property (nonatomic, assign) BOOL filterResults; 

- (void)cancelRequests;

- (void)clusterizeBounds:(XMBounds)bounds withZoomLevel:(NSUInteger)zoomLevel userInfo:(id)userInfo;

- (void)selectBounds:(XMBounds)bounds
	   withZoomLevel:(NSUInteger)zoomLevel
			  offset:(NSUInteger)offset
			   limit:(NSUInteger)limit
			userInfo:(id)userInfo;

- (void)selectBounds:(XMBounds)bounds
	   withZoomLevel:(NSUInteger)zoomLevel
			  offset:(NSUInteger)offset
			   limit:(NSUInteger)limit
			   order:(NSString *)order
			userInfo:(id)userInfo;

@end
