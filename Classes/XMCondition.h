//
//  XMCondition.h
//  MaptimizeKit
//
//  Created by Oleg Shnitko on 4/23/10.
//  olegshnitko@gmail.com
//  
//  Copyright © 2010 Screen Customs s.r.o. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 Class: XMCondition
 
 The XMCondition class is a wrapper around Maptimize Query Language (MQL).
 When a condition is given to XMMapController, only points matching this condition will be retrieved and displayed on the map when performing a request.
 
 */
@interface XMCondition : NSObject
{
@private
	
	NSString *_string;
}

/*
 Method: initWithFormat:args:
 */
- (id)initWithFormat:(NSString *)format args:(NSArray *)arguments;

/*
 Method: appendAnd:
 
 Interprets and appends the given condition to receiver so that it will be satisfied if both of these are satisfied.
 
 Parameters:
 
	condition - The condition for append.
 
 */
- (void)appendAnd:(XMCondition *)condition;

/*
 Method: appendOr:
 
 Interprets and appends the given condition to receiver so that it will be satisfied if any of these are satisfied.
 
 Parameters:
 
	condition - The condition fo append.
 
 */
- (void)appendOr:(XMCondition *)condition;

@end
