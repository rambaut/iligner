//
//  KDTextView.m
//  LineNumbering
//
//  Created by Koen van der Drift on Sat May 01 2004.
//  Pimped by Alexander Griekspoor on Sat Mar 04 2006
//  Copyright (c) 2004 Koen van der Drift. All rights reserved.
//
//
//  THIS IS EXPERIMENTAL SOFTWARE AND IT IS KNOWN TO HAVE BUGS, SOME OF WHICH MAY HAVE
//  SERIOUS CONSEQUENCES. THE COPYRIGHT HOLDER ALLOWS FREE USE OF THIS SOFTWARE IN ITS
//  "AS IS" CONDITION. THE COPYRIGHT HOLDER DISCLAIMS ANY LIABILITY OF ANY KIND FOR ANY
//  DAMAGES WHATSOEVER RESULTING DIRECTLY OR INDIRECTLY FROM THE USE OF THIS SOFTWARE
//  OR OF ANY DERIVATIVE WORK.
//---------------------------------------------------------------------------------------

//  NSTextView subclass which adds:
//  - line numbering
//  - column spacing
//  - fancy overlays for mouse position and selections
//  - better information transmission on selections to the delegate

//  To be added in future versions:
//  - make columnwidth character based, instead of 90 points -> 10 chars
//  - calculate column width based on current font
//  - optimization by only redrawing dirty areas

#import "KDTextView.h"
#import "KDTextViewContainer.h"

// Available delegate methods
@protocol KDTextViewDelegate <NSObject>
- (void)copy:(id)sender;
- (void)didClickInTextView: (id)sender location: (NSPoint)thePoint character: (int)c;
- (void)didDragInTextView: (id)sender location: (NSPoint)thePoint character: (int)c;
- (void)didMoveInTextView: (id)sender location: (NSPoint)thePoint character: (int)c;
- (void)didDragSelectionInTextView: (id)sender range: (NSRange)aRange;
- (NSMenu *)menuForTextView: (id)sender;
@end

@implementation KDTextView

- (id)initWithCoder:(NSCoder *)aDecoder;
{
	if (self = [super initWithCoder:aDecoder])
	{
		[self initLineMargin: [self frame]];
		[self setUnit: @""];
	}
	
    return self;
}

-(id)initWithFrame:(NSRect)frame
{
    if (self = [super initWithFrame:frame])
    {
		[self initLineMargin: frame];
		[self setUnit: @""];
    }
	
    return self;
}

- (void) initLineMargin:(NSRect) frame
{
	NSSize				contentSize;
	KDTextViewContainer	*myContainer;
	
	// create a subclass of NSTextContainer that specifies the textdraw area. 
	// This will allow for a left margin for numbering.
	
	contentSize = [[self enclosingScrollView] contentSize];
	frame = NSMakeRect(0, 0, contentSize.width, contentSize.height);
	myContainer = [[KDTextViewContainer allocWithZone:[self zone]] 
			initWithContainerSize:NSMakeSize(frame.size.width, 100000)];
	
	[myContainer setWidthTracksTextView:YES];
	[myContainer setHeightTracksTextView:NO];
	
	// This controls the inset of our text away from the margin.
	[myContainer setLineFragmentPadding:7];
	
	[self replaceTextContainer:myContainer];
	[myContainer release];
	
	// set all the parameters for the text view - it's was created from scratch, so it doesn't use
	// the values from the Nib file.
	
	[self setMinSize:frame.size];
	[self setMaxSize:NSMakeSize(100000, 100000)];
	
	[self setHorizontallyResizable:NO];
	[self setVerticallyResizable:YES];
	
	[self setAutoresizingMask:NSViewWidthSizable];
	[self setAllowsUndo:YES];
	
	[self setFont:[NSFont fontWithName: @"Courier" size: 14]];
	
	// listen to updates from the window to force a redraw - eg when the window resizes.
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidUpdate:)
												 name:NSWindowDidUpdateNotification object:[self window]];
	
	marginAttributes = [[NSMutableDictionary alloc] init];
	
	[marginAttributes setObject:[NSFont boldSystemFontOfSize:8] forKey: NSFontAttributeName];
	[marginAttributes setObject:[NSColor darkGrayColor] forKey: NSForegroundColorAttributeName];
	
	selectionAttributes = [[NSMutableDictionary alloc] init];
	
	[selectionAttributes setObject:[NSFont boldSystemFontOfSize:9] forKey: NSFontAttributeName];
	[selectionAttributes setObject:[NSColor whiteColor] forKey: NSForegroundColorAttributeName];
	
	
	drawNumbersInMargin = YES;
	drawLineNumbers = NO;
	drawOverlay = YES;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [marginAttributes release];
	[selectionAttributes release];
	
	[unit release];
	
    [super dealloc];
}

- (BOOL)drawNumbersInMargin
{
	return drawNumbersInMargin;
}

- (void)setDrawNumbersInMargin:(BOOL)newDrawNumbersInMargin
{
	drawNumbersInMargin = newDrawNumbersInMargin;
}

- (BOOL)drawLineNumbers
{
	return drawLineNumbers;
}

- (void)setDrawLineNumbers:(BOOL)newDrawLineNumbers
{
	drawLineNumbers = newDrawLineNumbers;
}

- (BOOL)drawOverlay
{
	return drawOverlay;
}

- (void)setDrawOverlay:(BOOL)newDrawOverlay
{
	drawOverlay = newDrawOverlay;
}

// displayed in the selection marker, e.g. set to bp for DNA and aa for amino acids
// format: 187-195 (8 $UNIT)

- (NSString *)unit
{
	return unit;
}

- (void)setUnit:(NSString *)newUnit
{
	[newUnit retain];
	[unit release];
	unit = newUnit;
}


- (void)drawRect:(NSRect)aRect 
{
    [super drawRect:aRect];
	
    [self drawEmptyMargin: [self marginRect]];
    
	// line numbers
    if ( drawNumbersInMargin )
    {
        [self drawNumbersInMargin: [self marginRect]];
    }
	
	// overlays, not when printed.
	if ( drawOverlay && [[NSGraphicsContext currentContext] isDrawingToScreen])
	{
		[self drawSelectionOverlayInTextview: aRect];
		[self drawOverlayInTextview: aRect];
	}
	
}


- (void)windowDidUpdate:(NSNotification *)notification
{
    [self updateMargin];
}

- (void)updateLayout
{
    [self updateMargin];
}


-(void)updateMargin
{
    [self setNeedsDisplayInRect:[self marginRect] avoidAdditionalLayout:NO];
}


-(NSRect)marginRect
{
    NSRect  r;
    
    r = [self bounds];
    r.size.width = kLEFT_MARGIN_WIDTH;
	
    return r;
}

-(void)drawEmptyMargin:(NSRect)aRect
{
	/*
     These values control the color of our margin. Giving the rect the 'clear' 
     background color is accomplished using the windowBackgroundColor.  Change 
     the color here to anything you like to alter margin contents.
	 */
	if([[NSGraphicsContext currentContext] isDrawingToScreen]){
		[[NSColor controlHighlightColor] set];
		[NSBezierPath fillRect: aRect]; 
	}	
	// These points should be set to the left margin width.
    NSPoint top = NSMakePoint(aRect.size.width, [self bounds].size.height);
    NSPoint bottom = NSMakePoint(aRect.size.width, 0);
    
	// This draws the dark line separating the margin from the text area.
    [[NSColor grayColor] set];
    [NSBezierPath setDefaultLineWidth:0.75];
    [NSBezierPath strokeLineFromPoint:top toPoint:bottom];
}


-(void) drawNumbersInMargin:(NSRect)aRect;
{
	UInt32		index, lineNumber;
	NSRange		lineRange;
	NSRect		lineRect;
	
	NSLayoutManager* layoutManager = [self layoutManager];
	NSTextContainer* textContainer = [self textContainer];
	
	// Only get the visible part of the scroller view
	NSRect documentVisibleRect = [[self enclosingScrollView] documentVisibleRect];
	
	// Find the glyph range for the visible glyphs
	NSRange glyphRange = [layoutManager glyphRangeForBoundingRect: documentVisibleRect inTextContainer: textContainer];
	
	// Calculate the start and end indexes for the glyphs	
	unsigned start_index = glyphRange.location;
	unsigned end_index = glyphRange.location + glyphRange.length;
	
	if(![[NSGraphicsContext currentContext] isDrawingToScreen]){
		start_index = 0;
		end_index = [layoutManager numberOfGlyphs];
	}
	
	index = 0;
	lineNumber = 1;
	
	if([[NSGraphicsContext currentContext] isDrawingToScreen]){
		
		// Skip all lines that are visible at the top of the text view (if any)
		while (index < start_index)
		{
			lineRect = [layoutManager lineFragmentRectForGlyphAtIndex:index effectiveRange:&lineRange];
			index = NSMaxRange( lineRange );
			++lineNumber;
		}
	}
	
	for ( index = start_index; index < end_index; lineNumber++ )
	{
		lineRect  = [layoutManager lineFragmentRectForGlyphAtIndex:index effectiveRange:&lineRange];
		//NSLog(@"Rect: %f, %f, %f, %f", lineRect.origin.x, lineRect.origin.y, lineRect.size.width, lineRect.size.height);
		if ( drawLineNumbers && lineRect.origin.x == 30)
		{
			index = NSMaxRange( lineRange );
			[self drawOneNumberInMargin:lineNumber inRect:lineRect];
		}
		else if ( lineRect.origin.x == 30)   // draw character numbers
		{
			[self drawOneNumberInMargin:index+1 inRect:lineRect];
		}
		
		index = NSMaxRange( lineRange );
	}
	
    if ( drawLineNumbers )
    {
        lineRect = [layoutManager extraLineFragmentRect];
        [self drawOneNumberInMargin:lineNumber inRect:lineRect];
    }
	
}


-(void)drawOneNumberInMargin:(unsigned) aNumber inRect:(NSRect)r
{
    NSString    *s;
    NSSize      stringSize;
    
    s = [NSString stringWithFormat:@"%d", aNumber, nil];
    stringSize = [s sizeWithAttributes:marginAttributes];
	
	// Simple algorithm to center the line number next to the glyph.
    [s drawAtPoint: NSMakePoint( r.origin.x - stringSize.width - 1, 
								 r.origin.y + ((r.size.height / 2) - (stringSize.height / 2))) 
	withAttributes:marginAttributes];
}

-(void)drawSelectionOverlayInTextview: (NSRect)rect{
	
	// don't draw when margin is drawn
	if(NSWidth(rect) == 30) return;
	
	NSRange range = [self selectedRange];
	
	NSString    *s;
    NSSize      stringSize;
	NSRect		stringRect;
	NSBezierPath *stringPath;
	
	NSPoint p;
	
	if(range.length > 0){
		// calculate rect of 1st char of selection
		NSRect r = [[self layoutManager] boundingRectForGlyphRange: NSMakeRange(range.location, 1) 
												   inTextContainer: [self textContainer]];
		p = (NSPoint){r.origin.x, NSMaxY(r)};	
		
		// generate string
		if(range.length == 1)
			s = [NSString stringWithFormat:@"%d", range.location+1];
		else 
			s = [NSString stringWithFormat:@"%d-%d (%d%@)", range.location+1, range.location+range.length, range.length, [self unit]];

		stringSize = [s sizeWithAttributes:selectionAttributes];
		
		// position with respect to character
		stringRect.origin.x = p.x + 5.0;
		stringRect.origin.y = p.y - stringSize.height - 16.0;
		
		// if doesn't fit (to close to top), move to last char of selection
		if(stringRect.origin.y - 15.0 < rect.origin.y){			
			NSRect r = [[self layoutManager] boundingRectForGlyphRange: NSMakeRange(range.location + range.length - 1, 1) 
													   inTextContainer: [self textContainer]];
			
			stringRect.origin.x = NSMaxX(r) - stringSize.width;
			stringRect.origin.y = NSMaxY(r) + 2.0;
		}
		
		// if doesn't fit (to close to right edge), reposition
		if((stringRect.origin.x + stringSize.width + 10.0) > rect.origin.x + NSWidth(rect)) 
			stringRect.origin.x -= (stringRect.origin.x + stringSize.width + 10.0) - (rect.origin.x + NSWidth(rect));
	
		// if doesn't fit (to close to left edge), reposition
		// NOTE: HARDCODED MARGIN WIDTH + 5 -> room for more elegant solution here
		if(stringRect.origin.x < 35.0) stringRect.origin.x = 35.0;
		
		// draw overlay + text
		stringRect.size = stringSize;	
		
		stringPath = [NSBezierPath bezierPath];
		[stringPath moveToPoint: (NSPoint) {stringRect.origin.x, stringRect.origin.y + 7.0}];
		[stringPath lineToPoint: (NSPoint) {stringRect.origin.x + stringRect.size.width, stringRect.origin.y + 7.0}];
		[stringPath setLineCapStyle: NSRoundLineCapStyle];
		[[NSColor colorWithCalibratedWhite: 0.0 alpha: 0.6]set];
		[stringPath setLineWidth: stringSize.height];
		[stringPath stroke];
		
		[s drawAtPoint: stringRect.origin withAttributes:selectionAttributes];
	}
}

-(void)drawOverlayInTextview: (NSRect)rect{
	
	// where are we?
	NSPoint cursor = [self convertPoint: [[self window] mouseLocationOutsideOfEventStream] fromView: nil];
	
	// not in margin, not outside ourselves
	if(cursor.x < 30.0) return;
	if(!NSPointInRect(cursor, rect)) return;
	
	NSTextStorage* textStorage = [self textStorage];
	NSRange selectedRange = [self selectedRange];
	
	NSString    *s;
    NSSize      stringSize;
	NSRect		stringRect;
	NSBezierPath *stringPath;
	
	// don't draw if active selection
	if(selectedRange.length > 0){
		return;
		
	// what's the char under our mouse
	} else {
		float partial = 1.0;
		int c = (int) [[self layoutManager] glyphIndexForPoint: cursor inTextContainer: [self textContainer] fractionOfDistanceThroughGlyph: &partial];
		if(c > 0 && c < [textStorage length] - 1)
			s = [NSString stringWithFormat:@"%d", c+1];
		else return;
	}
	
    stringSize = [s sizeWithAttributes:selectionAttributes];
	
	// position with respect to char
	stringRect.origin.x = cursor.x + 8.0;
	stringRect.origin.y = cursor.y + stringSize.height + 2.0;
	
	// if doesn't fit (to close to right edge), reposition
	if((stringRect.origin.x + stringSize.width + 10.0) > rect.origin.x + NSWidth(rect)) 
		stringRect.origin.x -= (stringRect.origin.x + stringSize.width + 10.0) - (rect.origin.x + NSWidth(rect));
	
	// if doesn't fit (to close to bottom edge), reposition
	if((stringRect.origin.y + stringSize.height + 10.0) > rect.origin.y + NSHeight(rect)) 
		stringRect.origin.y -= (stringRect.origin.y + stringSize.height + 10.0) - (rect.origin.y + NSHeight(rect));
	
	// draw overlay + text
	stringRect.size = stringSize;	
	
	stringPath = [NSBezierPath bezierPath];
	[stringPath moveToPoint: (NSPoint) {stringRect.origin.x, stringRect.origin.y + 7.0}];
	[stringPath lineToPoint: (NSPoint) {stringRect.origin.x + stringRect.size.width, stringRect.origin.y + 7.0}];
	[stringPath setLineCapStyle: NSRoundLineCapStyle];
	[[NSColor colorWithCalibratedWhite: 0.0 alpha: 0.6]set];
	[stringPath setLineWidth: stringSize.height];
	[stringPath stroke];
	
    [s drawAtPoint: stringRect.origin withAttributes:selectionAttributes];
	
}

// Allows customization of contextual menu by delegate
-(NSMenu*)menuForEvent:(NSEvent*) evt { 
	id <KDTextViewDelegate> delegate = [self delegate];
    if ([delegate respondsToSelector:@selector(menuForTextView:)]) 
		return [delegate menuForTextView: self];
	return nil;
}

// Mouse methods that inform delegate
- (void)mouseDown:(NSEvent *)theEvent{
	id <KDTextViewDelegate> delegate = [self delegate];
	float partial = 0.5;
	NSPoint p = [self convertPoint: [theEvent locationInWindow] fromView: nil];
	
    if ([delegate respondsToSelector:@selector(didClickInTextView: location: character:)]){
		int c = (int) [[self layoutManager] glyphIndexForPoint: p inTextContainer: [self textContainer] fractionOfDistanceThroughGlyph: &partial];
        [delegate didClickInTextView: self location: p character: c];
	}
	
	// redraw to sync overlays
	[self setNeedsDisplay: YES];
	
	[super mouseDown: theEvent];

}  

- (void)mouseMoved:(NSEvent *)theEvent{
	float partial = 1.0;
	NSPoint p = [self convertPoint: [theEvent locationInWindow] fromView: nil];
	int c = (int) [[self layoutManager] glyphIndexForPoint: p inTextContainer: [self textContainer] fractionOfDistanceThroughGlyph: &partial];
	
	id <KDTextViewDelegate> delegate = [self delegate];
    if ([delegate respondsToSelector:@selector(didMoveInTextView: location: character:)]){
		
		[delegate didMoveInTextView: self location: p character: c];
	}
	
	// redraw to sync overlays
	[self setNeedsDisplay: YES];
	
	[super mouseMoved: theEvent];
	
}  

- (void)mouseEntered:(NSEvent *)theEvent{
	
	// redraw to sync overlays
	[self setNeedsDisplay: YES];
	
	[super mouseEntered: theEvent];
	
}  

- (void)mouseExited:(NSEvent *)theEvent{
	
	// redraw to sync overlays
	[self setNeedsDisplay: YES];
	
	[super mouseExited: theEvent];
	
}  

- (NSRange)selectionRangeForProposedRange:(NSRange)proposedCharRange granularity:(NSSelectionGranularity)granularity{
	// DRAGGING SELECTION, inform delegate
	id <KDTextViewDelegate> delegate = [self delegate];
    if ([delegate respondsToSelector:@selector(didDragSelectionInTextView:range:)]){
		
		[delegate didDragSelectionInTextView: self range: proposedCharRange];
	}
	
	// MAKE SURE THAT SELECTION IS REDRAWN DURING DRAG	
	[self setNeedsDisplay: YES];
	return [super selectionRangeForProposedRange:proposedCharRange granularity:granularity];
}

- (void)setSelectedRange:(NSRange)aRange{
	// MAKE SURE THAT SELECTION IS REDRAWN DURING DRAG	
	[self setNeedsDisplay: YES];
	[super setSelectedRange: aRange];
}

@end
