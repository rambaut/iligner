//
//  AlignmentEditorView.m
//  iLigner
//
//  Created by Andrew Rambaut on 01/07/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AlignmentEditorView.h"

#import "Alignment.h"

@implementation AlignmentEditorView


- (void) awakeFromNib
{
    [self registerForDraggedTypes: [NSImage imagePasteboardTypes]];
    [self registerForDraggedTypes: [NSArray arrayWithObject: NSFilenamesPboardType]];
}

- (void) startAlignment: (Alignment*)alignment
{
}

- (void)drawString:(NSString *) string 
			inRect:(NSRect) r
			 atRow:(int) row
{	
	NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
	
	[attributes setObject:[NSFont fontWithName:@"Courier" size:12]
				   forKey:NSFontAttributeName];
	
	[attributes setObject:[NSColor redColor]
				   forKey:NSForegroundColorAttributeName];
	
	NSSize strSize = [string sizeWithAttributes:attributes];
	
	NSPoint strOrigin;
	strOrigin.x = 0;
	strOrigin.y = r.size.height - (strSize.height * (row + 1));
	
	[string drawAtPoint:strOrigin withAttributes:attributes];
}

- (void)drawRect:(NSRect)rect {
    NSRect        bounds = [self bounds];
	
	NSColor *bgColor = [NSColor whiteColor];
	[bgColor set];
	[NSBezierPath fillRect:bounds];
	
	for (int i = 0; i < 100; i++) {
		[self drawString:@"ACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGT"
				  inRect: bounds atRow: i];
	}
}


- (void)resetCursorRects
{
    [super resetCursorRects];
    [self addCursorRect: self.bounds cursor: [NSCursor openHandCursor]];
}


- (IBAction) enterFullScreen: (id)sender
{
    if( self.isInFullScreenMode ) {
        [self exitFullScreenModeWithOptions: nil];
    } else {
        [self enterFullScreenMode: self.window.screen 
                      withOptions: nil];
    }
    //[self startAlignment: _currentAlignment];        // restart so it'll use the new size
}


#pragma mark -
#pragma mark KEY EVENTS:


- (void) keyDown: (NSEvent*)ev
{
    if( self.isInFullScreenMode ) {
        if( [ev.charactersIgnoringModifiers hasPrefix: @"\033"] )       // Esc key
            [self enterFullScreen: self];
    }
}



@end
