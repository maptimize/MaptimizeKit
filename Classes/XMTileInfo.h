//
//  XMTileInfo.h
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

enum _XMTileInfoState
{
	XMTileInfoStateEmpty,
	XMTileInfoStateLoading,
	XMTileInfoStateCached
};
typedef enum _XMTileInfoState XMTileInfoState;

@interface XMTileInfo : NSObject
{
@private
	
	XMTile _tile;
	XMTileInfoState _state;
	XMGraph *_graph;
	id _data;
}

@property (nonatomic, assign) XMTile tile;
@property (nonatomic, assign) XMTileInfoState state;
@property (nonatomic, retain) XMGraph *graph;
@property (nonatomic, retain) id data;

@end