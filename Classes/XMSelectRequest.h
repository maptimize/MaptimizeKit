//
//  SelectRequest.h
//  MaptimizeKit
//
//  Created by Oleg Shnitko on 4/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "XMRequest.h"

@interface XMSelectRequest : XMRequest
{
}

- (id)initWithMapKey:(NSString *)mapKey
			  bounds:(XMBounds)bounds
		   zoomLevel:(NSUInteger)zoomLevel
			  params:(NSDictionary *)params;

@end
