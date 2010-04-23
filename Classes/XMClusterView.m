//
//  ClusterView.m
//  MaptimizeKit
//
//  Created by Oleg Shnitko on 4/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "XMClusterView.h"
#import "XMCluster.h"

static const size_t num_locations = 2;
static const CGFloat locations[2] = { 0.0, 1.0 };
static const CGFloat components[5][8] = {
{
	118.0 / 255., 209.0 / 255., 0.0 / 255., 1.0, // Start color
	118.0 / 255., 209.0 / 255., 0.0 / 255., 0.0  // End color
},
{
	255.0 / 255., 159.0 / 255., 0.0 / 255., 1.0, // Start color
	255.0 / 255., 159.0 / 255., 0.0 / 255., 0.0  // End color
},
{
	255.0 / 255., 105.0 / 255., 0.0 / 255., 1.0, // Start color
	255.0 / 255., 105.0 / 255., 0.0 / 255., 0.0  // End color
},
{
	240.0 / 255., 60.0 / 255., 0.0 / 255., 1.0, // Start color
	240.0 / 255., 60.0 / 255., 0.0 / 255., 0.0  // End color
},
{
	181.0 / 255., 0.0 / 255., 21.0 / 255., 1.0, // Start color
	181.0 / 255., 0.0 / 255., 21.0 / 255., 0.0  // End color
}};

@implementation XMClusterView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
	if (self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier])
	{
		CGSize size = [[annotation title] sizeWithFont:[UIFont boldSystemFontOfSize:12]];
		CGFloat r = 2 * MAX(size.width, size.height) + 15;
		CGRect frame = CGRectMake(0, 0, r, r);
		_colorIndex = MIN(4, [[annotation title] length] - 1);
		[self setFrame:frame];
	}
	
	return self;
}

- (void)setAnnotation:(id<MKAnnotation>)annotation
{
	if (annotation != self.annotation)
	{
		CGSize size = [[annotation title] sizeWithFont:[UIFont boldSystemFontOfSize:12]];
		CGFloat r = 2 * MAX(size.width, size.height) + 15;
		CGRect frame = CGRectMake(0, 0, r, r);
		_colorIndex = MIN(4, [[annotation title] length] - 1);
		[self setFrame:frame];
		[self setNeedsDisplay];
	}
	
	[super setAnnotation:annotation];
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
    
	CGContextSaveGState(context);
    
    CGGradientRef myGradient;
    CGColorSpaceRef myColorspace;
    
    myColorspace = CGColorSpaceCreateDeviceRGB();
    myGradient = CGGradientCreateWithColorComponents (myColorspace, components[_colorIndex],
                                                      locations, num_locations);
	
	CGPoint center = CGPointMake(rect.size.width / 2, rect.size.height / 2);
	CGContextDrawRadialGradient(context, myGradient, center, 1, center, rect.size.width / 2, kCGGradientDrawsBeforeStartLocation);
	
	CGGradientRelease(myGradient);
    CGColorSpaceRelease(myColorspace);
    
    CGContextRestoreGState(context);
	
	CGContextSaveGState(context);
	
	CGContextSetFillColor(context, components[_colorIndex]);
    CGContextFillEllipseInRect(context, CGRectMake(rect.size.width / 4, rect.size.height / 4, rect.size.width / 2, rect.size.height / 2));
    
    CGContextRestoreGState(context);
	
	CGContextSaveGState(context);
	
	NSString *title = [self.annotation title];
	UIFont *font = [UIFont boldSystemFontOfSize:12];
	CGSize tSize = [title sizeWithFont:font];
	
	CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
	
	[title drawInRect:CGRectMake(0, rect.size.height / 2 - tSize.height / 2, rect.size.width, tSize.height)
			 withFont:[UIFont boldSystemFontOfSize:12]
		lineBreakMode:UILineBreakModeClip
			alignment:UITextAlignmentCenter];
	
    CGContextRestoreGState(context);
}

- (void)dealloc
{
    [super dealloc];
}


@end
