//
//  XMRequest.m
//  MaptimizeKit
//
//  Created by Oleg Shnitko on 4/23/10.
//  olegshnitko@gmail.com
//  
//  Copyright © 2010 Screen Customs s.r.o. All rights reserved.
//

#import "XMBase.h"

#import "XMRequest.h"

#import "XMNetworkUtils.h"
#import "XMCondition.h"

#import "XMLog.h"

#define	BASE_URL	@"http://v2.maptimize.com/api/v2-0"
#define URL_FORMAT	@"%@/%@/%@?%@"

#define PARAM_FORMAT @"%@=%@"

const NSString *kXMZoomLevel	=	@"z";

const NSString *kXMDistance		=	@"d";

const NSString *kXMProperties	=	@"p";
const NSString *kXMAggreagtes	=	@"a";
const NSString *kXMCondition	=	@"c";
const NSString *kXMGroupBy		=	@"g";

const NSString *kXMLimit		=	@"l";
const NSString *kXMOffset		=	@"o";

const NSString *kXMOrder		=	@"order";

@interface XMRequest (Private)

+ (NSURL *)urlForMapKey:(NSString *)mapKey
				 method:(NSString *)method
				 bounds:(XMBounds)bounds
			  zoomLevel:(NSUInteger)zoomLevel
				 params:(NSDictionary *)params;

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
	NSMutableDictionary *allParams = [NSMutableDictionary dictionary];
	
	NSDictionary *boundsDict = XMDictionaryFromXMBounds(bounds);
	[allParams addEntriesFromDictionary:boundsDict];
	
	[allParams setObject:[NSNumber numberWithInteger:zoomLevel] forKey:kXMZoomLevel];
	
	[allParams addEntriesFromDictionary:params];
	
	NSString *paramsString = [XMRequest stringForParams:allParams];
	NSString *urlString = [NSString stringWithFormat:URL_FORMAT, BASE_URL, mapKey, method, paramsString];
	
	NSURL *url = [[NSURL alloc] initWithString:urlString];
	
	XM_LOG_TRACE(@"url: %@", url);
	
	return [url autorelease];
}

+ (NSString *)stringForParams:(NSDictionary *)params
{
	NSMutableString *paramsString = [NSMutableString stringWithString:@""];
	
	NSArray *keys = [params allKeys];
	NSArray *sortedKeys = [keys sortedArrayUsingSelector:@selector(compare:)];
	
	NSUInteger count = sortedKeys.count;
	for (NSUInteger i = 0; i < count; i++)
	{
		NSString *key = [sortedKeys objectAtIndex:i];
		
		NSObject *value = [params objectForKey:key];
		if ([value isKindOfClass:[NSArray class]])
		{
			NSArray *valueArray = (NSArray *)value;
			value = [valueArray componentsJoinedByString:@","];
		}
		
		NSString *paramString = [NSString stringWithFormat:@"%@", value];
		[paramsString appendFormat:PARAM_FORMAT, key, XMEncodedStringFromString(paramString)];
		
		if (i < count - 1)
		{
			[paramsString appendString:@"&"];
		}
	}
	
	return paramsString;
}

@end
