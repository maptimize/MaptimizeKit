//
//  XMNetworkUtils.m
//  MaptimizeKit
//
//  Created by Oleg Shnitko on 5/20/10.
//  olegshnitko@gmail.com
//  
//  Copyright © 2010 Screen Customs s.r.o. All rights reserved.
//

#import "XMNetworkUtils.h"

#define CHARS_COUNT 19

static NSString * const _escapeChars[CHARS_COUNT] =
{
	@";", @"/", @"?", @":", @"@", @"&", @"=", @"+", @"$", @",", @"[", @"]", @"#", @"!", @"'", @"(", @")", @"*", @" "
}
;
static NSString * const _replaceChars[CHARS_COUNT] =
{
	@"%3B", @"%2F", @"%3F", @"%3A", @"%40", @"%26", @"%3D", @"%2B", @"%24", @"%2C", @"%5B", @"%5D", @"%23", @"%21", @"%22", @"%28", @"%29", @"%2A", @"%20"
};

NSString *XMEncodedStringFromString(NSString *string)
{
	NSMutableString *temp = [string mutableCopy];
	
    for(NSUInteger i = 0; i < CHARS_COUNT; i++)
	{
	    [temp replaceOccurrencesOfString:_escapeChars[i]
							  withString:_replaceChars[i]
								 options:NSLiteralSearch
								   range:NSMakeRange(0, [temp length])];
    }
	
    return [temp autorelease];
}