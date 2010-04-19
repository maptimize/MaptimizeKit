//
//  KartaEntitiesConverter.m
//  Bredbandskollen
//
//  Created by Aleks Nesterow on 8/11/09.
//  aleks.nesterow@gmail.com
//  
//  Copyright © 2009 Screen Customs s.r.o. All rights reserved.
//  

#import "EntitiesConverter.h"
#import "SCLog.h"

@implementation EntitiesConverter

- (NSString *)encodeString:(NSString *)string {
	
	/* Note that we use ' char in argument strings, however %22 is a code for ".
	 * That was done to simplify this algorithm. */
	
	NSArray *escapeChars = [NSArray arrayWithObjects:@";" , @"/" , @"?" , @":" ,
							@"@" , @"&" , @"=" , @"+" ,
							@"$" , @"," , @"[" , @"]",
							@"#", @"!", @"'", @"(", 
							@")", @"*", @" ", nil];
	
    NSArray *replaceChars = [NSArray arrayWithObjects:@"%3B", @"%2F", @"%3F", @"%3A" , 
							 @"%40" , @"%26" , @"%3D" , @"%2B" , 
							 @"%24" , @"%2C" , @"%5B" , @"%5D", 
							 @"%23", @"%21", @"%22", @"%28", 
							 @"%29", @"%2A", @"%20", nil];
	
    int len = [escapeChars count];
	
    NSMutableString *temp = [string mutableCopy];
	
    int i;
	
    for(i = 0; i < len; i++) {
		
        [temp replaceOccurrencesOfString: [escapeChars objectAtIndex:i]
							  withString:[replaceChars objectAtIndex:i]
								 options:NSLiteralSearch
								   range:NSMakeRange(0, [temp length])];
    }
	
    NSString *result = [NSString stringWithString: temp];
	[temp release];
	
    return result;
}

- (CLLocationCoordinate2D)swFromRegion:(MKCoordinateRegion)region {
	
	CLLocationCoordinate2D center = region.center;
	MKCoordinateSpan span = region.span;
	
	CLLocationCoordinate2D result;
	result.latitude = center.latitude - span.latitudeDelta / 2.0;
	result.longitude = center.longitude - span.longitudeDelta / 2.0;
	
	return result;
}

- (CLLocationCoordinate2D)neFromRegion:(MKCoordinateRegion)region {
	
	CLLocationCoordinate2D center = region.center;
	MKCoordinateSpan span = region.span;
	
	CLLocationCoordinate2D result;
	result.latitude = center.latitude + span.latitudeDelta / 2.0;
	result.longitude = center.longitude + span.longitudeDelta / 2.0;
	
	return result;
}

- (int)zoomFromSpan:(MKCoordinateSpan)span andViewportSize:(CGSize)viewportSize {
	
	CLLocationDegrees spanLatitude = span.latitudeDelta;
	CLLocationDegrees spanLongitude = span.longitudeDelta;
	
	SC_LOG_DEBUG(@"MaptimizeService", @"spanLatitude = %f", spanLatitude);
	
	CGFloat viewportWidth = viewportSize.width;
	CGFloat viewportHeight = viewportSize.height;
	
	CGFloat usedSpan = MAX(spanLatitude * viewportHeight / viewportWidth, spanLongitude * viewportWidth / viewportHeight);
	
	SC_LOG_DEBUG(@"MaptimizeService", @"usedSpan = %f", usedSpan);
	
	/* We calculate the value, however limit it to 1..17, since this is what Maptimize API really expects. */
	
	int result = MIN(17, MAX(1, log(225.0 / usedSpan) / log(2) + 1));
	return result;
}

@end
