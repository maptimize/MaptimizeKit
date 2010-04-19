//
//  KartaEntitiesConverter.h
//  Bredbandskollen
//
//  Created by Aleks Nesterow on 8/11/09.
//  aleks.nesterow@gmail.com
//  
//  Copyright © 2009 Screen Customs s.r.o. All rights reserved.
//  
//  Purpose
//	Gives string representation for entities, and vice versa converts string representations to entities that are used in maps.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface EntitiesConverter : NSObject {

}

- (NSString *)encodeString:(NSString *)string;
- (CLLocationCoordinate2D)swFromRegion:(MKCoordinateRegion)region;
- (CLLocationCoordinate2D)neFromRegion:(MKCoordinateRegion)region;
- (int)zoomFromSpan:(MKCoordinateSpan)span andViewportSize:(CGSize)viewportSize;

@end
