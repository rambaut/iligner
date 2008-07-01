//
//  BCSequenceView.m
//  BioCocoa
//
//  Created by Koen van der Drift on Sat May 01 2004.
//  Pimped by Alexander Griekspoor on Sat Mar 04 2006
//  Copyright (c) 2005 The BioCocoa Project. All rights reserved.
//
//  This code is covered by the Creative Commons Share-Alike Attribution license.
//	You are free:
//	to copy, distribute, display, and perform the work
//	to make derivative works
//	to make commercial use of the work
//
//	Under the following conditions:
//	You must attribute the work in the manner specified by the author or licensor.
//	If you alter, transform, or build upon this work, you may distribute the resulting work only under a license identical to this one.
//
//	For any reuse or distribution, you must make clear to others the license terms of this work.
//	Any of these conditions can be waived if you get permission from the copyright holder.
//
//  For more info see: http://creativecommons.org/licenses/by-sa/2.5/

//---------------------------------------------------------------------------------------
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

#import "BCSequenceView.h"

#define	COLUMN_WIDTH 10

// Available delegate methods
@protocol BCSequenceViewDelegate <NSObject>
- (void)copy:(id)sender;
- (void)didClickInTextView: (id)sender location: (NSPoint)thePoint character: (int)c;
- (void)didDragInTextView: (id)sender location: (NSPoint)thePoint character: (int)c;
- (void)didMoveInTextView: (id)sender location: (NSPoint)thePoint character: (int)c;
- (void)didDragSelectionInTextView: (id)sender range: (NSRange)aRange;
- (NSMenu *)menuForTextView: (id)sender;
- (void)didDragFilesWithPaths: (NSArray *)paths textView: (id)sender;
- (NSMenu *)menuForTextView: (id)sender;
- (NSString *)filterInputString: (NSString *) input textView: (id)sender;
@end

@implementation BCSequenceView

- (id)initWithCoder:(NSCoder *)aDecoder;
{
	if (self = [super initWithCoder:aDecoder])
	{
		[self initLineMargin: [self frame]];
		[self setUnit: @""];
		[self setMarkingRange: NSMakeRange(NSNotFound,0)];
		[self setFilter: NO];	// off by default
		[self setSymbolCase: BCUppercase];
		[self setSymbolsPerColumn: 10];	// default
	}
	
    return self;
}

-(id)initWithFrame:(NSRect)frame
{
    if (self = [super initWithFrame:frame])
    {
		[self initLineMargin: frame];
		[self setUnit: @""];
		[self setMarkingRange: NSMakeRange(NSNotFound,0)];
		[self setFilter: NO];	// off by default
		[self setSymbolCase: BCUppercase];
		[self setSymbolsPerColumn: 10];	// default
    }
	
    return self;
}

- (void) initLineMargin:(NSRect) frame
{
	NSSize						contentSize;
	BCSequenceViewContainer		*myContainer;
	BCSequenceViewLayoutManager	*myLayoutManager;
	
	// create a subclass of NSTextContainer that specifies the textdraw area. 
	// This will allow for a left margin for numbering.
	
	contentSize = [[self enclosingScrollView] contentSize];
	frame = NSMakeRect(0, 0, contentSize.width, contentSize.height);
	myContainer = [[BCSequenceViewContainer allocWithZone:[self zone]] 
			initWithContainerSize:NSMakeSize(frame.size.width, 100000)];
	
	[myContainer setWidthTracksTextView:YES];
	[myContainer setHeightTracksTextView:NO];
	
	// This controls the inset of our text away from the margin.
	[myContainer setLineFragmentPadding: 7];
	[self replaceTextContainer: myContainer];
	[myContainer release];
	
	// create a subclass of NSLayoutManager to correct for selection bug
	myLayoutManager = [[BCSequenceViewLayoutManager allocWithZone: [self zone]] init];
	[myContainer replaceLayoutManager: myLayoutManager];
	[myLayoutManager release];

	// set all the parameters for the text view - it's was created from scratch, so it doesn't use
	// the values from the Nib file.
	
    [self setContinuousSpellCheckingEnabled: NO];
	[self setRichText: NO];
 	
	[self setMinSize:frame.size];
	[self setMaxSize:NSMakeSize(100000, 100000)];
	
	[self setHorizontallyResizable:NO];
	[self setVerticallyResizable:YES];
	
	[self setAutoresizingMask:NSViewWidthSizable];
	[self setAllowsUndo:YES];
	
	[self setFont:[NSFont fontWithName: @"Courier" size: 12]];
	
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

- (BOOL)filter
{
	return filter;
}

- (void)setFilter:(BOOL)newFilter
{
	filter = newFilter;
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

- (BOOL)drawMarking
{
	return drawMarking;
}

- (void)setDrawMarking:(BOOL)newDrawMarking
{
	drawMarking = newDrawMarking;
}

- (BCSequenceViewCase)symbolCase
{
	return symbolCase;
}

- (void)setSymbolCase:(BCSequenceViewCase)newCase
{
	symbolCase = newCase;
}

- (NSRange)markingRange
{
	return markingRange;
}

- (void)setMarkingRange:(NSRange)newMarkingRange
{
	markingRange = newMarkingRange;
}

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

- (int)symbolsPerColumn
{
	return symbolsPerColumn;
}

- (void)setSymbolsPerColumn:(int)newNumber
{
	symbolsPerColumn = newNumber;
	
 // need to update the textContainer and the layoutManager as well
	
 //	float	characterWidth = [[self font] boundingRectForFont].size.width;
	float	characterWidth = [[self font] maximumAdvancement].width;
	float	columnWidth = (float) ( symbolsPerColumn * characterWidth );

	columnWidth = 90;		// for now hardcode this until bug is fixed
	symbolsPerColumn = 10;	// for now hardcode this until bug is fixed
	
	[(BCSequenceViewLayoutManager *) [self layoutManager] setSymbolsPerColumn: symbolsPerColumn];
	[(BCSequenceViewContainer *) [self textContainer] setColumnWidth: columnWidth];
}

- (void)drawRect:(NSRect)aRect 
{
	[[self textStorage] removeAttribute: NSForegroundColorAttributeName range: NSMakeRange (0,[[self textStorage] length])];
	
	if ( drawMarking && [self markingRange].location != NSNotFound)
	{
		[[self textStorage] addAttribute: NSForegroundColorAttributeName value:[NSColor redColor] range:[self markingRange]];
//		[[self textStorage] addAttribute: NSForegroundColorAttributeName value:[NSColor darkmarkcolor] range:[self markingRange]];
	}
	
    [super drawRect: aRect];

    [self drawEmptyMargin: [self marginRect]];
    
    if ( drawNumbersInMargin )
    {
        [self drawNumbersInMargin: [self marginRect]];
    }
	
	if ( drawMarking && [self markingRange].location != NSNotFound)
	{
		[self drawMarkingInTextview: aRect];
	}
	
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
		if ( drawLineNumbers && lineRect.origin.x == kLEFT_MARGIN_WIDTH)
		{
			index = NSMaxRange( lineRange );
			[self drawOneNumberInMargin:lineNumber inRect:lineRect];
		}
		else if ( lineRect.origin.x == kLEFT_MARGIN_WIDTH)   // draw character numbers
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

-(void)drawMarkingInTextview: (NSRect)rect{
	
	// don't draw when margin is drawn
	if(NSWidth(rect) == 30) return;
	
	NSRange range = [self markingRange];
	//	[[self textStorage] removeAttribute: NSForegroundColorAttributeName range: NSMakeRange (0,[[self textStorage] length])];
	//	[[self textStorage] addAttribute: NSForegroundColorAttributeName value:[NSColor darkmarkcolor] range:[self markingRange]];
	
	NSString    *s;
    NSSize      stringSize;
	NSRect		stringRect;
	NSBezierPath *stringPath;
	
	NSPoint p;
	
	if(range.length > 0){
		NSRect r = [[self layoutManager] boundingRectForGlyphRange: NSMakeRange(range.location, 1) 
												   inTextContainer: [self textContainer]];
		p = (NSPoint){r.origin.x, NSMaxY(r)};	
		
		if(range.length == 1)
			s = [NSString stringWithFormat:@"%d", range.location+1];
		else 
			s = [NSString stringWithFormat:@"%d-%d (%d %@)", range.location+1, range.location+range.length, range.length, [self unit]];
		
		stringSize = [s sizeWithAttributes:selectionAttributes];
		
		stringRect.origin.x = p.x + 5.0;
		stringRect.origin.y = p.y - stringSize.height - 16.0;
		
		if(stringRect.origin.y - 15.0 < rect.origin.y){			
			NSRect r = [[self layoutManager] boundingRectForGlyphRange: NSMakeRange(range.location + range.length - 1, 1) 
													   inTextContainer: [self textContainer]];
			
			stringRect.origin.x = NSMaxX(r) - stringSize.width;
			stringRect.origin.y = NSMaxY(r) + 2.0;
		}
		
		if((stringRect.origin.x + stringSize.width + 10.0) > rect.origin.x + NSWidth(rect)) 
			stringRect.origin.x -= (stringRect.origin.x + stringSize.width + 10.0) - (rect.origin.x + NSWidth(rect));
		
		if(stringRect.origin.x < 35.0) stringRect.origin.x = 35.0;
		
		
		//		if((stringRect.origin.y + stringSize.height + 10.0) > rect.origin.y + NSHeight(rect)) 
		//			stringRect.origin.y -= (stringRect.origin.y + stringSize.height + 10.0) - (rect.origin.y + NSHeight(rect));
		
		
		stringRect.size = stringSize;	
		
		stringPath = [NSBezierPath bezierPath];
		[stringPath moveToPoint: (NSPoint) {stringRect.origin.x, stringRect.origin.y + 7.0}];
		[stringPath lineToPoint: (NSPoint) {stringRect.origin.x + stringRect.size.width, stringRect.origin.y + 7.0}];
		[stringPath setLineCapStyle: NSRoundLineCapStyle];
//		[[NSColor darkmarkcolor]set];
		[[NSColor redColor]set];
		[stringPath setLineWidth: stringSize.height];
		[stringPath stroke];
		
		[s drawAtPoint: stringRect.origin withAttributes:selectionAttributes];
	}
}


-(void)drawSelectionOverlayInTextview: (NSRect)rect{
	
	// don't draw when margin is drawn
	if(NSWidth(rect) == kLEFT_MARGIN_WIDTH) return;
	
	NSRange range = [self selectedRange];
	
	NSString    *s;
    NSSize      stringSize;
	NSRect		stringRect;
	NSBezierPath *stringPath;
	
	NSPoint p;
	
	if(range.length > 0){
		NSRect r = [[self layoutManager] boundingRectForGlyphRange: NSMakeRange(range.location, 1) 
												   inTextContainer: [self textContainer]];
		p = (NSPoint){r.origin.x, NSMaxY(r)};	
		
		if(range.length == 1)
			s = [NSString stringWithFormat:@"%d", range.location+1];
		else 
			s = [NSString stringWithFormat:@"%d-%d (%d %@)", range.location+1, range.location+range.length, range.length, [self unit]];
		
		stringSize = [s sizeWithAttributes:selectionAttributes];
		
		stringRect.origin.x = p.x + 5.0;
		stringRect.origin.y = p.y - stringSize.height - 16.0;
		
		if(stringRect.origin.y - 15.0 < rect.origin.y){			
			NSRect r = [[self layoutManager] boundingRectForGlyphRange: NSMakeRange(range.location + range.length - 1, 1) 
													   inTextContainer: [self textContainer]];
			
			stringRect.origin.x = NSMaxX(r) - stringSize.width;
			stringRect.origin.y = NSMaxY(r) + 2.0;
		}
		
		if((stringRect.origin.x + stringSize.width + 10.0) > rect.origin.x + NSWidth(rect)) 
			stringRect.origin.x -= (stringRect.origin.x + stringSize.width + 10.0) - (rect.origin.x + NSWidth(rect));
		
		if(stringRect.origin.x < 35.0) stringRect.origin.x = 35.0;
		
		
		//		if((stringRect.origin.y + stringSize.height + 10.0) > rect.origin.y + NSHeight(rect)) 
		//			stringRect.origin.y -= (stringRect.origin.y + stringSize.height + 10.0) - (rect.origin.y + NSHeight(rect));
		
		
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
	
	NSPoint cursor = [self convertPoint: [[self window] mouseLocationOutsideOfEventStream] fromView: nil];
	
	if(cursor.x < 30.0) return;
	if(!NSPointInRect(cursor, rect)) return;
	
	NSTextStorage* textStorage = [self textStorage];
	NSRange selectedRange = [self selectedRange];
	
	NSString    *s;
    NSSize      stringSize;
	NSRect		stringRect;
	NSBezierPath *stringPath;
	
	
	if(selectedRange.length > 0){
		return;
		
	} else {
		float partial = 1.0;
		int c = (int) [[self layoutManager] glyphIndexForPoint: cursor inTextContainer: [self textContainer] fractionOfDistanceThroughGlyph: &partial];
		if(c > 0 && c < [textStorage length] - 1)
			s = [NSString stringWithFormat:@"%d", c+1];
		else return;
	}
	
    stringSize = [s sizeWithAttributes:selectionAttributes];
	
	stringRect.origin.x = cursor.x + 8.0;
	stringRect.origin.y = cursor.y + stringSize.height + 2.0;
	
	if((stringRect.origin.x + stringSize.width + 10.0) > rect.origin.x + NSWidth(rect)) 
		stringRect.origin.x -= (stringRect.origin.x + stringSize.width + 10.0) - (rect.origin.x + NSWidth(rect));
	
	if((stringRect.origin.y + stringSize.height + 10.0) > rect.origin.y + NSHeight(rect)) 
		stringRect.origin.y -= (stringRect.origin.y + stringSize.height + 10.0) - (rect.origin.y + NSHeight(rect));
	
	
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
	id <BCSequenceViewDelegate> delegate = [self delegate];
    if ([delegate respondsToSelector:@selector(menuForTextView:)]) 
		return [delegate menuForTextView: self];
	return nil;
}

// Mouse methods that inform delegate
- (void)mouseDown:(NSEvent *)theEvent{
	id <BCSequenceViewDelegate> delegate = [self delegate];
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
	
	id <BCSequenceViewDelegate> delegate = [self delegate];
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
	NSRange newCharRange;
	if(granularity == NSSelectByWord){
		newCharRange.location = (proposedCharRange.location / 10) * 10;
		newCharRange.length = ((proposedCharRange.location + proposedCharRange.length) / 10 + 1) * 10 - newCharRange.location;
		// sanity checks
		if(newCharRange.location < 0){
			newCharRange.length -= -newCharRange.location;
			newCharRange.location = 0;
		}
		if(newCharRange.location + newCharRange.length > [[self textStorage]length]){
			newCharRange.length -= (newCharRange.location + newCharRange.length)  - [[self textStorage]length];
		}
	}
	else {
		newCharRange = [super selectionRangeForProposedRange:proposedCharRange granularity:granularity];
	}
	//NSLog(@"%d -> old: %@ new: %@", granularity, NSStringFromRange(proposedCharRange), NSStringFromRange(newCharRange));
	
	// DRAGGING SELECTION
	id <BCSequenceViewDelegate> delegate = [self delegate];
    if ([delegate respondsToSelector:@selector(didDragSelectionInTextView:range:)]){
		[delegate didDragSelectionInTextView: self range: newCharRange];
	}
	
	// MAKE SURE THAT SELECTION IS REDRAWN DURING DRAG	
	[self setNeedsDisplay: YES];
	return newCharRange;
}

- (void)setSelectedRange:(NSRange)aRange{
	// MAKE SURE THAT SELECTION IS REDRAWN DURING DRAG	
	[self setNeedsDisplay: YES];
	[super setSelectedRange: aRange];
}

-(int)charactersPerColumn
{
	int		result = 0;
	float	columnWidth = [(BCSequenceViewContainer *)[self textContainer] columnWidth];
	float	characterWidth = [[self font] boundingRectForFont].size.width;
	
	result = (int) ( columnWidth / characterWidth );
	
	return result;
}

// DRAG FILE
- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
	NSPasteboard *pboard = [sender draggingPasteboard];
    if ( [[pboard types] containsObject: NSFilenamesPboardType] )
	{
		id <BCSequenceViewDelegate> delegate = [self delegate];
		if ([delegate respondsToSelector:@selector(didDragFilesWithPaths:textView:)]){
			[delegate didDragFilesWithPaths: [pboard propertyListForType:NSFilenamesPboardType] textView: self];
			return YES;
		}
		else return NO;
		
	}
    else return [super performDragOperation:sender];
}


- (void)insertText:(id)aString{
	NSString *filteredString;

	// FILTERING OF VALID SYMBOLS
	if([self filter])
	{
		id <BCSequenceViewDelegate> delegate = [self delegate];
		if ([delegate respondsToSelector:@selector(filterInputString: textView:)]){
			filteredString = [delegate filterInputString: aString textView: self];
		}
	}
	else
		filteredString = aString;
	
	// also check if we need to update the marking
	if(markingRange.length > 0){
		NSRange editedRange = [self rangeForUserTextChange];
		//NSLog(@"Edit: %@  Marking: %@", NSStringFromRange(editedRange), NSStringFromRange(markingRange));
		
		// begins after
		if(editedRange.location >= NSMaxRange(markingRange)){
			//NSLog(@"begins after");
		}
		// begins before
		else if(editedRange.location < markingRange.location){
			// ends before
			if(NSMaxRange(editedRange) <= markingRange.location){
				//NSLog(@"begins before, ends before");
				markingRange.location -= editedRange.length - [filteredString length];
			}
			// ends in
			else if(NSMaxRange(editedRange) < NSMaxRange(markingRange)){
				//NSLog(@"begins before, ends in");
				markingRange.length -=  editedRange.location + editedRange.length - markingRange.location;
				markingRange.location = editedRange.location + [filteredString length];
			}
			// ends after
			else {
				//NSLog(@"begins before, ends after");
				markingRange = NSMakeRange(NSNotFound,0);
			}
			// editedrange contained in
		} else {
			// ends in
			if(NSMaxRange(editedRange) < NSMaxRange(markingRange)){
				//NSLog(@"begins in, ends in");
				markingRange.length -= editedRange.length - [filteredString length];
			}
			// ends after
			else {
				//NSLog(@"begins in, ends after");
				markingRange.length -= NSMaxRange(markingRange) - editedRange.location;
			}
		}
	}

	// finally insert the filteredstring
	switch ([self symbolCase])
	{
		case BCUppercase:
			[super insertText: [filteredString uppercaseString]];
			break;
			
		case BCLowercase:
			[super insertText: [filteredString lowercaseString]];
			break;

		case BCOthercase:
			[super insertText: filteredString];
			break;
	}
}

- (void)setString:(NSString *)aString
{
	if (aString == nil)
		return;
		
	NSString *filteredString;

	if([self filter])
	{
		id <BCSequenceViewDelegate> delegate = [self delegate];
		if ([delegate respondsToSelector:@selector(filterInputString: textView:)]){
			filteredString = [delegate filterInputString: aString textView: self];
		}
	}
	else
		filteredString = aString;
	
	// also check if we need to update the marking
	if(markingRange.length > 0)
		markingRange = NSMakeRange(NSNotFound,0);
	
	// finally insert the filteredstring
	switch ([self symbolCase])
	{
		case BCUppercase:
			[super insertText: [filteredString uppercaseString]];
			break;
			
		case BCLowercase:
			[super insertText: [filteredString lowercaseString]];
			break;
			
		case BCOthercase:
			[super insertText: filteredString];
			break;
	}
}

- (BOOL)readSelectionFromPasteboard:(NSPasteboard *)pboard type:(NSString *)type{
	
	// the docs say to call this first, so we do ;-)
	[pboard types];
	// try to read a string, if not succesful bummer, otherwise insert it
	NSString *aString = [pboard stringForType: type];		
	if(aString){
		[self insertText: aString];
		return YES;
	}
	else
		return NO;	
}

- (void)delete:(id)sender{
	[self deleteBackward: (id)sender];
}

- (void)deleteBackward:(id)sender{
	// also check if we need to update the marking
	if(markingRange.length > 0){
		NSRange editedRange = [self rangeForUserTextChange];
		// NSLog(@"Edit: %@  Marking: %@", NSStringFromRange(editedRange), NSStringFromRange(markingRange));
		
		// begins after
		if(editedRange.location > NSMaxRange(markingRange)){
			//NSLog(@"begins after");
		}
		// begins before
		else if(editedRange.location < markingRange.location){
			// ends before
			if(NSMaxRange(editedRange) <= markingRange.location){
				//NSLog(@"begins before, ends before");
				if(editedRange.length == 0) markingRange.location --;
				else markingRange.location -= editedRange.length;
			}
			// ends in
			else if(NSMaxRange(editedRange) < NSMaxRange(markingRange)){
				//NSLog(@"begins before, ends in");
				markingRange.length -=  editedRange.location + editedRange.length - markingRange.location;
				markingRange.location = editedRange.location;
			}
			// ends after
			else {
				//NSLog(@"begins before, ends after");
				markingRange = NSMakeRange(NSNotFound,0);
			}
			// editedrange contained in
		} else {
			// ends in
			if(NSMaxRange(editedRange) < NSMaxRange(markingRange)){
				//NSLog(@"begins in, ends in");
				if(editedRange.length == 0) markingRange.length --;
				else markingRange.length -= editedRange.length;
			}
			// ends after
			else {
				//NSLog(@"begins in, ends after");
				if(editedRange.length == 0) markingRange.length --;
				else markingRange.length -= NSMaxRange(markingRange) - editedRange.location;
			}
		}
	}
	[super deleteBackward: sender];
}

- (void)deleteForward:(id)sender{	
	// also check if we need to update the marking
	if(markingRange.length > 0){
		NSRange editedRange = [self rangeForUserTextChange];
		// NSLog(@"Edit: %@  Marking: %@", NSStringFromRange(editedRange), NSStringFromRange(markingRange));
		
		// begins after
		if(editedRange.location > NSMaxRange(markingRange)){
			//NSLog(@"begins after");
		}
		// begins before
		else if(editedRange.location < markingRange.location){
			// ends before
			if(NSMaxRange(editedRange) <= markingRange.location){
				//NSLog(@"begins before, ends before");
				if(editedRange.length == 0) markingRange.location --;
				else markingRange.location -= editedRange.length;
			}
			// ends in
			else if(NSMaxRange(editedRange) < NSMaxRange(markingRange)){
				//NSLog(@"begins before, ends in");
				markingRange.length -=  editedRange.location + editedRange.length - markingRange.location;
				markingRange.location = editedRange.location;
			}
			// ends after
			else {
				//NSLog(@"begins before, ends after");
				markingRange = NSMakeRange(NSNotFound,0);
			}
			// editedrange contained in
		} else {
			// ends in
			if(NSMaxRange(editedRange) < NSMaxRange(markingRange)){
				//NSLog(@"begins in, ends in");
				if(editedRange.length == 0) markingRange.length --;
				else markingRange.length -= editedRange.length;
			}
			// ends after
			else {
				//NSLog(@"begins in, ends after");
				if(editedRange.length == 0) markingRange.length --;
				else markingRange.length -= NSMaxRange(markingRange) - editedRange.location;
			}
		}
	}
	[super deleteForward: sender];
}


@end

@implementation BCSequenceViewContainer

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


@implementation BCSequenceViewLayoutManager

- (void)setSymbolsPerColumn:(int)newNumber
{
	symbolsPerColumn = newNumber;
}

- (unsigned)glyphIndexForPoint:(NSPoint)aPoint inTextContainer:(NSTextContainer *)aTextContainer fractionOfDistanceThroughGlyph:(float *)partialFraction{
	
	unsigned idx = [super glyphIndexForPoint: aPoint inTextContainer: aTextContainer fractionOfDistanceThroughGlyph: partialFraction];
	
	// because of a bug in this method we check by hand if wrong value is given
	if(idx == symbolsPerColumn && !NSPointInRect(aPoint, [self boundingRectForGlyphRange: NSMakeRange(symbolsPerColumn,1) inTextContainer: aTextContainer])){
		int i;
		for (i=0; i<symbolsPerColumn; i++){			
			NSRect glyphRect = [self boundingRectForGlyphRange: NSMakeRange(i,1) inTextContainer: aTextContainer];
			if(NSPointInRect(aPoint, glyphRect)){
				// calculate fraction
				if (partialFraction) *partialFraction = (aPoint.x - NSMinX(glyphRect)) / NSWidth(glyphRect);
				return i;
			}
		}
		// if not found, check whether before or after 
		if(aPoint.x < NSMinX([self boundingRectForGlyphRange: NSMakeRange(0,1) inTextContainer: aTextContainer])) {
			if (partialFraction) *partialFraction = 0.0;
			return 0;
		}
		else {
			if (partialFraction) *partialFraction = 1.0;
			return symbolsPerColumn;
		}
	}
	
	return idx;
}

@end
