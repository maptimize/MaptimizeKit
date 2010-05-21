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
#import "XMNetworkUtils.h"

NSString *NSStringFromXMBounds(XMBounds bounds)
{
	NSString *boundsString = [NSString stringWithFormat:@"{{%g, %g}, {%g, %g}}",
							  bounds.sw.latitude, bounds.sw.longitude,
							  bounds.ne.latitude, bounds.ne.longitude];
	
	return boundsString;
}

NSString *NSStringFromCLCoordinates(CLLocationCoordinate2D coordinates)
{
	NSString *string = [NSString stringWithFormat:@"{%g, %g}", coordinates.latitude, coordinates.longitude];
	return string;
}

NSString *XMStringFromXMBounds(XMBounds bounds)
{
	NSString *boundsString = [NSString stringWithFormat:@"sw=%@&ne=%@",
							  XMStringFromCLCoordinates(bounds.sw),
							  XMStringFromCLCoordinates(bounds.ne)];
	
	return boundsString;
}

NSString *XMStringFromCLCoordinates(CLLocationCoordinate2D coordinates)
{
	NSString *string = [NSString stringWithFormat:@"%g,%g",
						 coordinates.latitude, coordinates.longitude];
	
	return XMEncodedStringFromString(string);
}

CLLocationCoordinate2D XMCoordinatesFromString(NSString *string)
{
	NSArray *chunks = [string componentsSeparatedByString:@","];
	
	NSString *latitudeValue = [chunks objectAtIndex:0];
	NSString *longitudeValue = [chunks objectAtIndex:1];
	
	CLLocationCoordinate2D result;
	result.latitude = [latitudeValue doubleValue];
	result.longitude = [longitudeValue doubleValue];
	
	return result;
}

XMBounds XMBoundsFromDictionary(NSDictionary *dict)
{
	NSString *swString = [dict objectForKey:@"sw"];
	NSString *neString = [dict objectForKey:@"ne"];
	
	XMBounds bounds;
	bounds.sw = XMCoordinatesFromString(swString);
	bounds.ne = XMCoordinatesFromString(neString);
	
	return bounds;
}

@implementation NSValue (XMBounds)

+ (NSValue *)valueWithXMBounds:(XMBounds)bounds
{
	NSValue *value = [NSValue valueWithBytes:&bounds objCType:@encode(XMBounds)];
	return value;
}

- (XMBounds)xmBoundsValue
{
	XMBounds bounds;
	[self getValue:&bounds];
	return bounds;
}

@end
