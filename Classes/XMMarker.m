//
//  XMMarker.m
//  MaptimizeKit
//
//  Created by Oleg Shnitko on 4/22/10.
//  olegshnitko@gmail.com
//  
//  Copyright © 2010 Screen Customs s.r.o. All rights reserved.
//

#import "XMMarker.h"

#import "SCMemoryManagement.h"

@implementation XMMarker

@synthesize identifier = _identifier;

- (void)dealloc
{
	SC_RELEASE_SAFELY(_identifier);
	[super dealloc];
}

@end
