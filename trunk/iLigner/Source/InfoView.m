//
//  InfoView.m
//  iLigner
//
//  Created by Andrew Rambaut on 03/08/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "InfoView.h"


@implementation InfoView

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
	
	NSColor *bgColor = [NSColor grayColor];
	[bgColor set];
	[NSBezierPath fillRect:bounds];
	
	[self drawString:@"Info" inRect: bounds];
}


@end
