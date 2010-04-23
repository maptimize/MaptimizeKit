//
//  MaptimizeRequest.h
//  MaptimizeKit
//
//  Created by Oleg Shnitko on 4/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ASIHTTPRequest.h"
#import "Bounds.h"

const NSString *kMPKDistance;

const NSString *kMPKProperties;
const NSString *kMPKAggreagtes;
const NSString *kMPKCondition;
const NSString *kMPKGroupBy;

const NSString *kMPKLimit;
const NSString *kMPKOffset;

@interface MaptimizeRequest : ASIHTTPRequest
{
}

- (id)initWithMapKey:(NSString *)mapKey
			  method:(NSString *)method
			  bounds:(Bounds)bounds
		   zoomLevel:(NSUInteger)zoomLevel
			  params:(NSDictionary *)params;

@end
