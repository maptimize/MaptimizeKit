//
//	XMOptimizeServiceDelegate.h
//	MaptimizeKit
//
//	Created by Oleg Shnitko on 5/20/10.
//  olegshnitko@gmail.com
//  
//  Copyright © 2010 Screen Customs s.r.o. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XMOptimizeService;
@class XMRequest;
@class XMGraph;

@protocol XMOptimizeServiceDelegate <NSObject>
@optional

- (void)optimizeService:(XMOptimizeService *)optimizeService failedWithError:(NSError *)error userInfo:(id)userInfo;

- (void)optimizeService:(XMOptimizeService *)optimizeService didClusterize:(XMGraph *)graph userInfo:(id)userInfo;
- (void)optimizeService:(XMOptimizeService *)optimizeService didSelect:(XMGraph *)graph userInfo:(id)userInfo;
- (void)optimizeService:(XMOptimizeService *)optimizeService didCancelRequest:(XMRequest *)request userInfo:(id)userInfo;

@end