//
//  XMRequest.m
//  MaptimizeKit
//
//  Created by Oleg Shnitko on 4/23/10.
//  olegshnitko@gmail.com
//  
//  Copyright © 2010 Screen Customs s.r.o. All rights reserved.
//

#import "XMRequest.h"

#define	BASE_URL	@"http://betav2.maptimize.com/api/v2-0"
#define URL_FORMAT	@"%@/%@/%@?%@&z=%d"

#define BOUNDS_FORMAT @"sw=%@&ne=%@"
#define LAT_LONG_FORMAT	@"%f,%f"

#define PARAM_FORMAT @"&%@=%@"

const NSString *kXMDistance	=	@"d";

const NSString *kXMProperties	=	@"p";
const NSString *kXMAggreagtes	=	@"a";
const NSString *kXMCondition	=	@"c";
const NSString *kXMGroupBy		=	@"g";

const NSString *kXMLimit		=	@"l";
const NSString *kXMOffset		=	@"o";

@interface XMRequest (Private)

+ (NSString *)encodeString:(NSString *)string;

+ (NSURL *)urlForMapKey:(NSString *)mapKey
				 method:(NSString *)method
				 bounds:(XMBounds)bounds
			  zoomLevel:(NSUInteger)zoomLevel
				 params:(NSDictionary *)params;

+ (NSString *)stringForBounds:(XMBounds)bounds;
+ (NSString *)stringForParams:(NSDictionary *)params;

@end

@implementation XMRequest

- (id)initWithMapKey:(NSString *)mapKey
			  method:(NSString *)method
			  bounds:(XMBounds)bounds
		   zoomLevel:(NSUInteger)zoomLevel
			  params:(NSDictionary *)parmas
{
	NSURL *anUrl = [XMRequest urlForMapKey:mapKey method:method bounds:bounds zoomLevel:zoomLevel params:parmas];
	if (self = [super initWithURL:anUrl])
	{
		[self addRequestHeader:@"User-Agent" value:@"MaptimizeKit-iPhone"];
		[self addRequestHeader:@"accept" value:@"application/json"];
	}
	
	return self;
}

+ (NSURL *)urlForMapKey:(NSString *)mapKey
				 method:(NSString *)method
				 bounds:(XMBounds)bounds
			  zoomLevel:(NSUInteger)zoomLevel
				 params:(NSDictionary *)params
{
	NSString *boundsString = [XMRequest stringForBounds:bounds];
	
	NSString *commonString = [NSString stringWithFormat: URL_FORMAT, BASE_URL, mapKey, method, boundsString, zoomLevel];
	NSString *paramsString = [XMRequest stringForParams:params];
	
	NSString *urlString = [NSString stringWithFormat:@"%@%@", commonString, paramsString];
	
	return [NSURL URLWithString:urlString];
}

+ (NSString *)stringForBounds:(XMBounds)bounds
{
	CLLocationCoordinate2D swLatLong = bounds.sw;
	NSString *swValue = [NSString stringWithFormat:LAT_LONG_FORMAT, swLatLong.latitude, swLatLong.longitude];
	NSString *swEncoded = [XMRequest encodeString:swValue];
	
	CLLocationCoordinate2D neLatLong = bounds.ne;
	NSString *neValue = [NSString stringWithFormat:LAT_LONG_FORMAT, neLatLong.latitude, neLatLong.longitude];
	NSString *neEncoded = [XMRequest encodeString:neValue];
	
	return [NSString stringWithFormat:BOUNDS_FORMAT, swEncoded, neEncoded];
}

+ (NSString *)stringForParams:(NSDictionary *)params
{
	NSMutableString *paramsString =  [NSMutableString stringWithString:@""];
	
	NSObject *distance = [params objectForKey:kXMDistance];
	if ([distance isKindOfClass:[NSNumber class]])
	{
		[paramsString appendFormat:PARAM_FORMAT, kXMDistance, distance];
	}
	
	NSObject *properties = [params objectForKey:kXMProperties];
	if ([properties isKindOfClass:[NSString class]])
	{
		NSString *propertiesString = (NSString *)properties;
		[paramsString appendFormat:PARAM_FORMAT, kXMProperties, [XMRequest encodeString:propertiesString]];
	}
	else if ([properties isKindOfClass:[NSArray class]])
	{
		NSArray *propertiesArray = (NSArray *)properties;
		NSString *propertiesString = [propertiesArray componentsJoinedByString:@","];
		[paramsString appendFormat:PARAM_FORMAT, kXMProperties, [XMRequest encodeString:propertiesString]];
	}
	
	NSObject *aggregates = [params objectForKey:kXMAggreagtes];
	if ([aggregates isKindOfClass:[NSString class]])
	{
		NSString *aggregatesString = (NSString *)aggregates;
		[paramsString appendFormat:PARAM_FORMAT, kXMAggreagtes, [XMRequest encodeString:aggregatesString]];
	}
	
	NSObject *condition = [params objectForKey:kXMCondition];
	if ([condition isKindOfClass:[NSString class]])
	{
		NSString *conditionString = (NSString *)condition;
		[paramsString appendFormat:PARAM_FORMAT, kXMCondition, [XMRequest encodeString:conditionString]];
	}
	
	NSObject *groupBy = [params objectForKey:kXMGroupBy];
	if ([groupBy isKindOfClass:[NSString class]])
	{
		NSString *groupByString = (NSString *)groupBy;
		[paramsString appendFormat:PARAM_FORMAT, kXMGroupBy, [XMRequest encodeString:groupByString]];
	}
	
	NSObject *limit = [params objectForKey:kXMLimit];
	if ([limit isKindOfClass:[NSNumber class]])
	{
		[paramsString appendFormat:PARAM_FORMAT, kXMLimit, limit];
	}
	
	NSObject *offset = [params objectForKey:kXMOffset];
	if ([offset isKindOfClass:[NSNumber class]])
	{
		[paramsString appendFormat:PARAM_FORMAT, kXMOffset, offset];
	}
	
	return paramsString;
}

+ (NSString *)encodeString:(NSString *)string
{	
	/* Note that we use ' char in argument strings, however %22 is a code for ".
	 * That was done to simplify this algorithm. */
	
	static NSArray *escapeChars = nil;
	if (!escapeChars) escapeChars = [[NSArray alloc] initWithObjects:
									 @";", @"/", @"?", @":", @"@", @"&", @"=", @"+", @"$", @",",
									 @"[", @"]", @"#", @"!", @"'", @"(", @")", @"*", @" ", nil];
	
	static NSArray *replaceChars = nil;
    if (!replaceChars) replaceChars = [[NSArray alloc] initWithObjects:
									   @"%3B", @"%2F", @"%3F", @"%3A", @"%40", @"%26", @"%3D", @"%2B", @"%24", @"%2C",
									   @"%5B", @"%5D", @"%23", @"%21", @"%22", @"%28", @"%29", @"%2A", @"%20", nil];
	
	static NSUInteger len = 0;
    if (!len) len = [escapeChars count];
	
    NSMutableString *temp = [string mutableCopy];
	
    for(NSUInteger i = 0; i < len; i++)
	{
	    [temp replaceOccurrencesOfString:[escapeChars objectAtIndex:i]
							  withString:[replaceChars objectAtIndex:i]
								 options:NSLiteralSearch
								   range:NSMakeRange(0, [temp length])];
    }
	
    NSString *result = [NSString stringWithString:temp];
	[temp release];
	
    return result;
}

@end
