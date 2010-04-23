//
//  SelectRequest.h
//  MaptimizeKit
//
//  Created by Oleg Shnitko on 4/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MaptimizeRequest.h"

@interface SelectRequest : MaptimizeRequest
{
}

- (id)initWithMapKey:(NSString *)mapKey
			  bounds:(Bounds)bounds
		   zoomLevel:(NSUInteger)zoomLevel
			  params:(NSDictionary *)params;

@end
