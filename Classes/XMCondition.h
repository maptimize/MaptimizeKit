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


@interface XMCondition : NSObject
{
@private
	
	NSString *_string;
}

- (id)initWithFormat:(NSString *)format args:(NSArray *)arguments;

- (void)appendAnd:(XMCondition *)condition;
- (void)appendOr:(XMCondition *)condition;

@end
