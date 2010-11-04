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

#pragma mark -
#pragma mark Init and Destroy

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate identifier:(NSString *)identifier
{
	if (self = [super initWithCoordinate:coordinate])
	{
		_identifier = [identifier copy];
	}
	
	return self;
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate data:(NSMutableDictionary *)data identifier:(NSString *)identifier
{
	if (self = [super initWithCoordinate:coordinate data:data])
	{
		_identifier = [identifier copy];
	}
	
	return self;
}

- (void)dealloc
{
	SC_RELEASE_SAFELY(_identifier);
	[super dealloc];
}

#pragma mark -
#pragma mark Identifying and Comparing Markers

- (NSUInteger)hash
{
	return [self.identifier hash];
}

- (BOOL)isEqual:(id)object
{
	if (![object isKindOfClass:[XMMarker class]])
	{
		return NO;
	}
	
	XMMarker *marker = object;
	return [self.identifier isEqualToString:marker.identifier];
}

@end
