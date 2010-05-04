//
//  XMRequest.h
//  MaptimizeKit
//
//  Created by Oleg Shnitko on 4/23/10.
//  olegshnitko@gmail.com
//  
//  Copyright © 2010 Screen Customs s.r.o. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ASIHTTPRequest.h"
#import "XMBounds.h"

extern const NSString *kXMDistance;

extern const NSString *kXMProperties;
extern const NSString *kXMAggreagtes;
extern const NSString *kXMCondition;
extern const NSString *kXMGroupBy;

extern const NSString *kXMLimit;
extern const NSString *kXMOffset;

@interface XMRequest : ASIHTTPRequest
{
}

- (id)initWithMapKey:(NSString *)mapKey
			  method:(NSString *)method
			  bounds:(XMBounds)bounds
		   zoomLevel:(NSUInteger)zoomLevel
			  params:(NSDictionary *)params;

@end
