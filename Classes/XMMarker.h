//
//  XMMarker.h
//  MaptimizeKit
//
//  Created by Oleg Shnitko on 4/22/10.
//  olegshnitko@gmail.com
//  
//  Copyright © 2010 Screen Customs s.r.o. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#import "XMPlacemark.h"

/*
 Class: XMMarker
 
 Represents single point on the map.
 
 */
@interface XMMarker : XMPlacemark
{
@private
	
	NSString *_identifier;
}

/*
 Property: identifier
 */
@property (nonatomic, retain) NSString *identifier;

@end
