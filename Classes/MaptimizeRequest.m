//
//  MaptimizeRequest.m
//  MaptimizeKit
//
//  Created by Oleg Shnitko on 4/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MaptimizeRequest.h"

#define	BASE_URL	@"http://betav2.maptimize.com/api/v2-0"
#define URL_FORMAT	@"%@/%@/%@?%@&z=%d"

#define BOUNDS_FORMAT @"sw=%@&ne=%@"
#define LAT_LONG_FORMAT	@"%f,%f"

#define PARAM_FORMAT @"&%@=%@"

const NSString *kMPKDistance	=	@"d";

const NSString *kMPKProperties	=	@"p";
const NSString *kMPKAggreagtes	=	@"a";
const NSString *kMPKCondition	=	@"c";
const NSString *kMPKGroupBy		=	@"g";

const NSString *kMPKLimit		=	@"l";
const NSString *kMPKOffset		=	@"o";

@interface MaptimizeRequest (Private)

+ (NSString *)encodeString:(NSString *)string;

+ (NSURL *)urlForMapKey:(NSString *)mapKey
				 method:(NSString *)method
				 bounds:(Bounds)bounds
			  zoomLevel:(NSUInteger)zoomLevel
				 params:(NSDictionary *)params;

+ (NSString *)stringForBounds:(Bounds)bounds;
+ (NSString *)stringForParams:(NSDictionary *)params;

@end

@implementation MaptimizeRequest

- (id)initWithMapKey:(NSString *)mapKey
			  method:(NSString *)method
			  bounds:(Bounds)bounds
		   zoomLevel:(NSUInteger)zoomLevel
			  params:(NSDictionary *)parmas
{
	NSURL *anUrl = [MaptimizeRequest urlForMapKey:mapKey method:method bounds:bounds zoomLevel:zoomLevel params:parmas];
	if (self = [super initWithURL:anUrl])
	{
		[self addRequestHeader:@"User-Agent" value:@"MaptimizeKit-iPhone"];
		[self addRequestHeader:@"accept" value:@"application/json"];
	}
	
	return self;
}

+ (NSURL *)urlForMapKey:(NSString *)mapKey
				 method:(NSString *)method
				 bounds:(Bounds)bounds
			  zoomLevel:(NSUInteger)zoomLevel
				 params:(NSDictionary *)params
{
	NSString *boundsString = [MaptimizeRequest stringForBounds:bounds];
	
	NSString *commonString = [NSString stringWithFormat: URL_FORMAT, BASE_URL, mapKey, method, boundsString, zoomLevel];
	NSString *paramsString = [MaptimizeRequest stringForParams:params];
	
	NSString *urlString = [NSString stringWithFormat:@"%@%@", commonString, paramsString];
	
	return [NSURL URLWithString:urlString];
}

+ (NSString *)stringForBounds:(Bounds)bounds
{
	CLLocationCoordinate2D swLatLong = bounds.sw;
	NSString *swValue = [NSString stringWithFormat:LAT_LONG_FORMAT, swLatLong.latitude, swLatLong.longitude];
	NSString *swEncoded = [MaptimizeRequest encodeString:swValue];
	
	CLLocationCoordinate2D neLatLong = bounds.ne;
	NSString *neValue = [NSString stringWithFormat:LAT_LONG_FORMAT, neLatLong.latitude, neLatLong.longitude];
	NSString *neEncoded = [MaptimizeRequest encodeString:neValue];
	
	return [NSString stringWithFormat:BOUNDS_FORMAT, swEncoded, neEncoded];
}

+ (NSString *)stringForParams:(NSDictionary *)params
{
	NSMutableString *paramsString =  [NSMutableString stringWithString:@""];
	
	NSObject *distance = [params objectForKey:kMPKDistance];
	if ([distance isKindOfClass:[NSNumber class]])
	{
		[paramsString appendFormat:PARAM_FORMAT, kMPKDistance, distance];
	}
	
	NSObject *properties = [params objectForKey:kMPKProperties];
	if ([properties isKindOfClass:[NSString class]])
	{
		NSString *propertiesString = (NSString *)properties;
		[paramsString appendFormat:PARAM_FORMAT, kMPKProperties, [MaptimizeRequest encodeString:propertiesString]];
	}
	else if ([properties isKindOfClass:[NSArray class]])
	{
		NSArray *propertiesArray = (NSArray *)properties;
		NSString *propertiesString = [propertiesArray componentsJoinedByString:@","];
		[paramsString appendFormat:PARAM_FORMAT, kMPKProperties, [MaptimizeRequest encodeString:propertiesString]];
	}
	
	NSObject *aggregates = [params objectForKey:kMPKAggreagtes];
	if ([aggregates isKindOfClass:[NSString class]])
	{
		NSString *aggregatesString = (NSString *)aggregates;
		[paramsString appendFormat:PARAM_FORMAT, kMPKAggreagtes, [MaptimizeRequest encodeString:aggregatesString]];
	}
	
	NSObject *condition = [params objectForKey:kMPKCondition];
	if ([condition isKindOfClass:[NSString class]])
	{
		NSString *conditionString = (NSString *)condition;
		[paramsString appendFormat:PARAM_FORMAT, kMPKCondition, [MaptimizeRequest encodeString:conditionString]];
	}
	
	NSObject *groupBy = [params objectForKey:kMPKGroupBy];
	if ([groupBy isKindOfClass:[NSString class]])
	{
		NSString *groupByString = (NSString *)groupBy;
		[paramsString appendFormat:PARAM_FORMAT, kMPKGroupBy, [MaptimizeRequest encodeString:groupByString]];
	}
	
	NSObject *limit = [params objectForKey:kMPKLimit];
	if ([limit isKindOfClass:[NSNumber class]])
	{
		[paramsString appendFormat:PARAM_FORMAT, kMPKLimit, limit];
	}
	
	NSObject *offset = [params objectForKey:kMPKOffset];
	if ([offset isKindOfClass:[NSNumber class]])
	{
		[paramsString appendFormat:PARAM_FORMAT, kMPKOffset, offset];
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
