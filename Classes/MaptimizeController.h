//
//  MaptimizeController.h
//  MaptimizeKit
//
//  Created by Oleg Shnitko on 4/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <MapKit/MapKit.h>

#import "MaptimizeService.h"
#import "TileService.h"
#import "TileCache.h"

@interface MaptimizeController : NSObject <MKMapViewDelegate, TileServiceDelegate, TileCacheDelegate>
{
@private
	
	MaptimizeService *_maptimizeService;
	TileService *_tileService;
	TileCache *_tileCache;
	TileRect _lastRect;
	
	MKMapView *_mapView;
	
	NSUInteger _zoomLevel;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) NSString *mapKey;

- (void)update;

@end
