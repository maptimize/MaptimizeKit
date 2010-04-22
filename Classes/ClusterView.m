//
//  ClusterView.m
//  MaptimizeKit
//
//  Created by Oleg Shnitko on 4/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ClusterView.h"
#import "Cluster.h"

static const size_t num_locations = 2;
static const CGFloat locations[3] = { 0.0, 1.0 };
static const CGFloat components[12] =
{
	0.0 / 255., 0.0 / 255., 255.0 / 255., 1.0, // Start color
	0.0 / 255., 0.0 / 255., 255.0 / 255., 0.0  // End color
};

@implementation ClusterView

- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
    
	CGContextSaveGState(context);
    
    CGGradientRef myGradient;
    CGColorSpaceRef myColorspace;
    
    myColorspace = CGColorSpaceCreateDeviceRGB();
    myGradient = CGGradientCreateWithColorComponents (myColorspace, components,
                                                      locations, num_locations);
	
	CGPoint center = CGPointMake(rect.size.width / 2, rect.size.height / 2);
	CGContextDrawRadialGradient(context, myGradient, center, 1, center, rect.size.width / 2, kCGGradientDrawsBeforeStartLocation);
	
	CGGradientRelease(myGradient);
    CGColorSpaceRelease(myColorspace);
    
    CGContextRestoreGState(context);
	
	CGContextSaveGState(context);
	
    CGContextSetFillColorWithColor(context, [[UIColor blueColor] CGColor]);
    CGContextFillEllipseInRect(context, CGRectMake(rect.size.width / 4, rect.size.height / 4, rect.size.width / 2, rect.size.height / 2));
    
    CGContextRestoreGState(context);
	
	CGContextSaveGState(context);
	
	NSString *title = [self.annotation title];
	UIFont *font = [UIFont systemFontOfSize:14];
	CGSize tSize = [title sizeWithFont:font];
	
	CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
	
	[title drawInRect:CGRectMake(0, rect.size.height / 2 - tSize.height / 2, rect.size.width, tSize.height)
			 withFont:[UIFont systemFontOfSize:14]
		lineBreakMode:UILineBreakModeClip
			alignment:UITextAlignmentCenter];
	
    CGContextRestoreGState(context);
}

- (void)dealloc {
    [super dealloc];
}


@end
