//
//  XMBounds.m
//  MaptimizeKit
//
//  Created by Oleg Shnitko on 4/23/10.
//  olegshnitko@gmail.com
//  
//  Copyright © 2010 Screen Customs s.r.o. All rights reserved.
//

#import "XMBounds.h"

NSString *NSStringFromXMBounds(XMBounds bounds)
{
	NSString *boundsString = [NSString stringWithFormat:@"{{%g, %g}, {%g, %g}}",
							  bounds.sw.latitude, bounds.sw.longitude,
							  bounds.ne.latitude, bounds.ne.longitude];
	
	return boundsString;
}

NSString *XMStringFromXMBounds(XMBounds bounds)
{
	NSString *boundsString = [NSString stringWithFormat:@"sw=%g,%g&ne=%g,%g",
							  bounds.sw.latitude, bounds.sw.longitude,
							  bounds.ne.latitude, bounds.ne.longitude];
	
	return boundsString;
}