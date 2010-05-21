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
#import "GTMNSString+URLArguments.h"

NSString *XMEncodedStringFromString(NSString *string)
{
	return [string gtm_stringByEscapingForURLArgument];
}