//
//  KDTextViewContainer.m
//  LineNumbering
//
//  Created by Koen van der Drift on Sat May 01 2004.
//  Copyright (c) 2004 Koen van der Drift. All rights reserved.
//

#import "KDTextViewContainer.h"


@implementation KDTextViewContainer

- (id) initWithContainerSize:(NSSize) size {
    self = [super initWithContainerSize:size];
	
	// default columnwidth (width of 10 characters in Courier 12)
    columnWidth = 90.0;

    return self;
}


- (BOOL) isSimpleRectangularTextContainer {
    return NO;
}

- (void) setColumnWidth:(float) width {
    columnWidth = width;
    [[self layoutManager] textContainerChangedGeometry:self];
}

- (float) columnWidth {
    return columnWidth;
}

- (NSRect)lineFragmentRectForProposedRect:(NSRect)proposedRect 
        sweepDirection:(NSLineSweepDirection)sweepDirection 
        movementDirection:(NSLineMovementDirection)movementDirection 
        remainingRect:(NSRect *)remainingRect
{
	
	if(proposedRect.origin.x <= 0.0)
		proposedRect.origin.x = kLEFT_MARGIN_WIDTH;
	
	proposedRect.size.width = columnWidth;
	
    if (proposedRect.origin.x + 2 * columnWidth - 20.0 >= [self containerSize].width) *remainingRect = NSZeroRect;
    else {
        remainingRect->origin.x = proposedRect.origin.x + columnWidth - 10.0;
        remainingRect->origin.y = proposedRect.origin.y;
        remainingRect->size.width = [self containerSize].width - proposedRect.origin.x - columnWidth;
        remainingRect->size.height = proposedRect.size.height;
    }
	
	
    return proposedRect;
}

@end
