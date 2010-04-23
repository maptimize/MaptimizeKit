//
//  XMCondition.m
//  MaptimizeKit
//
//  Created by Oleg Shnitko on 4/23/10.
//  olegshnitko@gmail.com
//  
//  Copyright © 2010 Screen Customs s.r.o. All rights reserved.
//

#import "XMCondition.h"
#import "JSON.h"

#import "SCMemoryManagement.h"

@implementation XMCondition

- (id)initWithFormat:(NSString *)format args:(NSArray *)arguments
{
	NSUInteger count = [arguments count];
	id escapedArgs[count];
	
	for (NSUInteger i = 0; i < [arguments count]; i++)
	{
		NSObject *arg = [arguments objectAtIndex:i];
		NSObject *escapedArg = arg;
		
		if ([arg isKindOfClass:[NSNumber class]])
		{
			CFTypeID argTypeId = CFGetTypeID(arg);
			CFTypeID booleanTypeId = CFBooleanGetTypeID();
			if (argTypeId == booleanTypeId)
			{
				NSNumber *number = (NSNumber *)arg;
				if ([number boolValue])
				{
					escapedArg = @"true";
				}
				else
				{
					escapedArg = @"false";
				}
			}
		}
		else if ([arg isKindOfClass:[NSArray class]])
		{
			NSString *arrayString = [arg JSONRepresentation];
			escapedArg = arrayString;
		}
		else if ([arg isKindOfClass:[NSString class]])
		{
			NSString *escapedString = [NSString stringWithFormat:@"\"%@\"", arg];
			escapedArg = escapedString;
		}
		
		escapedArgs[i] = escapedArg;
	}
	
	if (self = [super init])
	{
		_string = [[NSString alloc] initWithFormat:format arguments:(va_list)escapedArgs];
	}
	
	return self;
}

- (void)dealloc
{
	SC_RELEASE_SAFELY(_string);
	[super dealloc];
}

- (void)mergeCondition:(XMCondition *)condition withOperator:(NSString *)operator
{
	NSString *newString = [[NSString alloc] initWithFormat:@"(%@) %@ (%@)", _string, operator, condition];
	
	[_string release];
	_string = newString;
}

- (void)appendAnd:(XMCondition *)condition
{
	[self mergeCondition:condition withOperator:@"AND"];
}

- (void)appendOr:(XMCondition *)condition
{
	[self mergeCondition:condition withOperator:@"OR"];
}

- (BOOL)isEqual:(id)object
{
	return [_string isEqualToString:[object description]];
}

- (NSString *)description
{
	return _string;
}

@end
