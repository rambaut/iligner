//
//  RulerView.m
//  iLigner
//
//  Created by Andrew Rambaut on 01/07/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "RulerView.h"


@implementation RulerView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawString:(NSString *) string 
			inRect: (NSRect) r
{	
	NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
	
	[attributes setObject:[NSFont fontWithName:@"Courier" size:12]
				   forKey:NSFontAttributeName];
	
	[attributes setObject:[NSColor darkGrayColor]
				   forKey:NSForegroundColorAttributeName];
	
	NSPoint strOrigin;
	strOrigin.x = 0;
	strOrigin.y = 0;
	
	[string drawAtPoint:strOrigin withAttributes:attributes];
}

- (void)drawRect:(NSRect)rect {
    NSRect        bounds = [self bounds];
	
	NSColor *bgColor = [NSColor lightGrayColor];
	[bgColor set];
	[NSBezierPath fillRect:bounds];
	
	[self drawString:@"|1    |5    |10   |15    |20   |25    |30   |35    |40   |45    |50   |55    |60   |65" inRect: bounds];
}

@end
