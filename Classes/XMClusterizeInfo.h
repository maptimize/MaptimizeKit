//
//  XMClusterizeInfo.h
//  MaptimizeKit
//
//  Created by Oleg Shnitko on 5/20/10.
//  olegshnitko@gmail.com
//  
//  Copyright © 2010 Screen Customs s.r.o. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "XMTile.h"

@class XMGraph;

@interface XMClusterizeInfo : NSObject
{
@private
	
	NSMutableArray *tiles;
	XMTileRect tileRect;
	XMGraph *graph;
}

@property (nonatomic, readonly) NSMutableArray *tiles;
@property (nonatomic, assign) XMTileRect tileRect;
@property (nonatomic, retain) XMGraph *graph;

@end
