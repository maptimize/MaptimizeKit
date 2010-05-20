//
//  XMClusterizeRequest.h
//  MaptimizeKit
//
//  Created by Oleg Shnitko on 4/23/10.
//  olegshnitko@gmail.com
//  
//  Copyright © 2010 Screen Customs s.r.o. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "XMRequest.h"

@interface XMClusterizeRequest : XMRequest
{

}

- (id)initWithMapKey:(NSString *)mapKey
			  bounds:(XMBounds)bounds
		   zoomLevel:(NSUInteger)zoomLevel
			  params:(NSDictionary *)params;

@end
