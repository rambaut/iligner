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

- (void)drawRect:(NSRect)rect {
    NSRect        bounds = [self bounds];
 
    NSBezierPath*    clipShape = [NSBezierPath bezierPath];
    [clipShape appendBezierPathWithRoundedRect:bounds xRadius:40 yRadius:30];
 
 
    NSGradient* aGradient = [[[NSGradient alloc]
                    initWithColorsAndLocations:[NSColor redColor], (CGFloat)0.0,
                                            [NSColor orangeColor], (CGFloat)0.166,
                                            [NSColor yellowColor], (CGFloat)0.33,
                                            [NSColor greenColor], (CGFloat)0.5,
                                            [NSColor blueColor], (CGFloat)0.75,
                                            [NSColor purpleColor], (CGFloat)1.0,
                                            nil] autorelease];
 
    [aGradient drawInBezierPath:clipShape angle:0.0];
}

@end
