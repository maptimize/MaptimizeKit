//
//  XMBounds.h
//  MaptimizeKit
//
//  Created by Oleg Shnitko on 4/23/10.
//  olegshnitko@gmail.com
//  
//  Copyright © 2010 Screen Customs s.r.o. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#import "XMBase.h"

struct _XMBounds
{
	CLLocationCoordinate2D sw;
	CLLocationCoordinate2D ne;
};
typedef struct _XMBounds XMBounds;

XM_INLINE
XMBounds XMBoundsMake(CLLocationDegrees swLat, CLLocationDegrees swLng, CLLocationDegrees neLat, CLLocationDegrees neLng)
{
	XMBounds bounds;
	bounds.sw.latitude = swLat;
	bounds.sw.longitude = swLng;
	bounds.ne.latitude = neLat;
	bounds.ne.longitude = neLng;
	return bounds;
}

XM_EXTERN NSString *NSStringFromXMBounds(XMBounds bounds);
XM_EXTERN NSString *NSStringFromCLCoordinates(CLLocationCoordinate2D coordinates);

XM_EXTERN NSString *XMStringFromXMBounds(XMBounds bounds);
XM_EXTERN NSString *XMStringFromCLCoordinates(CLLocationCoordinate2D coordinates);

XM_EXTERN CLLocationCoordinate2D XMCoordinatesFromString(NSString *string);
XM_EXTERN XMBounds XMBoundsFromDictionary(NSDictionary *dict);

@interface NSValue (XMBounds)

+ (NSValue *)valueWithXMBounds:(XMBounds)bounds;
- (XMBounds)xmBoundsValue;

@end
