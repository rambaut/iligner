//
//  AlignmentEditorView.m
//  iLigner
//
//  Created by Andrew Rambaut on 01/07/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AlignmentEditorView.h"
#import "Bit.h"
#import "Piece.h"
#import "BitHolder.h"
#import "Grid.h"
#import "QuartzUtils.h"

#import "Alignment.h"

@implementation AlignmentEditorView


@synthesize alignmentLayer=_alignmentLayer;

- (void) awakeFromNib
{
    [self registerForDraggedTypes: [NSImage imagePasteboardTypes]];
    [self registerForDraggedTypes: [NSArray arrayWithObject: NSFilenamesPboardType]];
    
//    self.layer.backgroundColor = [NSColor whiteColor];
	
//    bounds.size.height -= 32;
//    _headline = AddTextLayer(self.layer,
//                             nil, [NSFont boldSystemFontOfSize: 24], 
//                             kCALayerWidthSizable | kCALayerMinYMargin);
}

- (void) addPieces: (NSString*)imageName
            toGrid: (Grid*)grid
              rows: (NSRange)rows
{
    Piece *p = [[Piece alloc] initWithImageNamed: imageName scale: floor(grid.spacing.width * 0.8)];
    unsigned cols=grid.columns;
    for( unsigned row=rows.location; row<NSMaxRange(rows); row++ )
        for( unsigned col=0; col<cols; col++ ) {
			GridCell *cell = [grid cellAtRow: row column: col];
			if( cell ) {
				cell.bit = [p copy];
				//cell.bit.rotation = random() % 360; // keeps pieces from looking too samey
            }
        }
}

- (Grid*) makeGrid
{
    RectGrid *grid = [[RectGrid alloc] initWithRows: 20 columns: 20 frame: _alignmentLayer.bounds];
    CGPoint pos = grid.position;
    pos.x = floor((_alignmentLayer.bounds.size.width - grid.frame.size.width)/2);
    [grid addAllCells];
    grid.position = pos;
    grid.cellColor = CGColorCreateGenericGray(0.0, 0.25);
    grid.altCellColor = CGColorCreateGenericGray(1.0, 0.25);
    grid.lineColor = nil;
    [self addPieces: @"Green Ball.png" toGrid: grid rows: NSMakeRange(0,9)];
    [self addPieces: @"Red Ball.png"   toGrid: grid rows: NSMakeRange(10,19)];
    return grid;
}

- (void) startAlignment: (Alignment*)alignment
{
	_currentAlignment = alignment;
	
    if( _alignmentLayer ) {
        [_alignmentLayer removeFromSuperlayer];
        _alignmentLayer = nil;
    }
    _alignmentLayer = [[CALayer alloc] init];
    _alignmentLayer.frame = [self alignmentLayerFrame];
    _alignmentLayer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;

//	[_alignmentLayer addSublayer: [self makeGrid]];
	[self.layer addSublayer: [self makeGrid]];
	[self.layer addSublayer: _alignmentLayer];
}

- (CGRect) alignmentLayerFrame
{
    return self.layer.bounds;
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
    [self startAlignment: _currentAlignment];        // restart so it'll use the new size
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


#pragma mark -
#pragma mark HIT-TESTING:


// Hit-testing callbacks (to identify which layers caller is interested in):
typedef BOOL (*LayerMatchCallback)(CALayer*);

static BOOL layerIsBit( CALayer* layer )        {return [layer isKindOfClass: [Bit class]];}
static BOOL layerIsBitHolder( CALayer* layer )  {return [layer conformsToProtocol: @protocol(BitHolder)];}
static BOOL layerIsDropTarget( CALayer* layer ) {return [layer respondsToSelector: @selector(draggingEntered:)];}


/** Locates the layer at a given point in window coords.
 If the leaf layer doesn't pass the layer-match callback, the nearest ancestor that does is returned.
 If outOffset is provided, the point's position relative to the layer is stored into it. */
- (CALayer*) hitTestPoint: (NSPoint)locationInWindow
         forLayerMatching: (LayerMatchCallback)match
                   offset: (CGPoint*)outOffset
{
    CGPoint where = NSPointToCGPoint([self convertPoint: locationInWindow fromView: nil]);
    where = [_alignmentLayer convertPoint: where fromLayer: self.layer];
    CALayer *layer = [_alignmentLayer hitTest: where];
    while( layer ) {
        if( match(layer) ) {
            CGPoint bitPos = [self.layer convertPoint: layer.position 
                              fromLayer: layer.superlayer];
            if( outOffset )
                *outOffset = CGPointMake( bitPos.x-where.x, bitPos.y-where.y);
            return layer;
        } else
            layer = layer.superlayer;
    }
    return nil;
}


#pragma mark -
#pragma mark MOUSE CLICKS & DRAGS:


- (void) mouseDown: (NSEvent*)ev
{
    _dragStartPos = ev.locationInWindow;
    _dragBit = (Bit*) [self hitTestPoint: _dragStartPos
                        forLayerMatching: layerIsBit 
                                  offset: &_dragOffset];
    if( _dragBit ) {
        _dragMoved = NO;
        _dropTarget = nil;
        _oldHolder = _dragBit.holder;
        // Ask holder's and game's permission before dragging:
        if( _oldHolder )
            _dragBit = [_oldHolder canDragBit: _dragBit];
        if( _dragBit /*&& ! [_game canBit: _dragBit moveFrom: _oldHolder]*/ ) {
            [_oldHolder cancelDragBit: _dragBit];
            _dragBit = nil;
        }
        if( ! _dragBit ) {
            _oldHolder = nil;
            NSBeep();
            return;
        }
        // Start dragging:
        _oldSuperlayer = _dragBit.superlayer;
        _oldLayerIndex = [_oldSuperlayer.sublayers indexOfObjectIdenticalTo: _dragBit];
        _oldPos = _dragBit.position;
        ChangeSuperlayer(_dragBit, self.layer, self.layer.sublayers.count);
        _dragBit.pickedUp = YES;
        [[NSCursor closedHandCursor] push];
    } else
        NSBeep();
}

- (void) mouseDragged: (NSEvent*)ev
{
    if( _dragBit ) {
        // Get the mouse position, and see if we've moved 3 pixels since the mouseDown:
        NSPoint pos = ev.locationInWindow;
        if( fabs(pos.x-_dragStartPos.x)>=3 || fabs(pos.y-_dragStartPos.y)>=3 )
            _dragMoved = YES;
        
        // Move the _dragBit (without animation -- it's unnecessary and slows down responsiveness):
        NSPoint where = [self convertPoint: pos fromView: nil];
        where.x += _dragOffset.x;
        where.y += _dragOffset.y;
        
        CGPoint newPos = [_dragBit.superlayer convertPoint: NSPointToCGPoint(where) 
						  fromLayer: self.layer];
		
        [CATransaction flush];
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue
                         forKey:kCATransactionDisableActions];
        _dragBit.position = newPos;
        [CATransaction commit];
		
        // Find what it's over:
        id<BitHolder> target = (id<BitHolder>) [self hitTestPoint: where
                                                 forLayerMatching: layerIsBitHolder
                                                           offset: NULL];
        if( target == _oldHolder )
            target = nil;
        if( target != _dropTarget ) {
            [_dropTarget willNotDropBit: _dragBit];
            _dropTarget.highlighted = NO;
            _dropTarget = nil;
        }
        if( target ) {
            CGPoint targetPos = [(CALayer*)target convertPoint: _dragBit.position
                                                     fromLayer: _dragBit.superlayer];
            if( [target canDropBit: _dragBit atPoint: targetPos]
               /*&& [_game canBit: _dragBit moveFrom: _oldHolder to: target]*/ ) {
                _dropTarget = target;
                _dropTarget.highlighted = YES;
            }
        }
    }
}

- (void) mouseUp: (NSEvent*)ev
{
    if( _dragBit ) {
        if( _dragMoved ) {
            // Update the drag tracking to the final mouse position:
            [self mouseDragged: ev];
            _dropTarget.highlighted = NO;
            _dragBit.pickedUp = NO;
			
            // Is the move legal?
            if( _dropTarget && [_dropTarget dropBit: _dragBit
                                            atPoint: [(CALayer*)_dropTarget convertPoint: _dragBit.position 
																			   fromLayer: _dragBit.superlayer]] ) {
                // Yes, notify the interested parties:
                [_oldHolder draggedBit: _dragBit to: _dropTarget];
                /*[_game bit: _dragBit movedFrom: _oldHolder to: _dropTarget];*/
            } else {
                // Nope, cancel:
                [_dropTarget willNotDropBit: _dragBit];
                ChangeSuperlayer(_dragBit, _oldSuperlayer, _oldLayerIndex);
                _dragBit.position = _oldPos;
                [_oldHolder cancelDragBit: _dragBit];
            }
        } else {
            // Just a click, without a drag:
            _dropTarget.highlighted = NO;
            _dragBit.pickedUp = NO;
            ChangeSuperlayer(_dragBit, _oldSuperlayer, _oldLayerIndex);
            [_oldHolder cancelDragBit: _dragBit];
            /*if( ! [_game clickedBit: _dragBit] )
                NSBeep();*/
        }
        _dropTarget = nil;
        _dragBit = nil;
        [NSCursor pop];
    }
}


#pragma mark -
#pragma mark INCOMING DRAGS:


// subroutine to call the target
static int tell( id target, SEL selector, id arg, int defaultValue )
{
    if( target && [target respondsToSelector: selector] )
        return (ssize_t) [target performSelector: selector withObject: arg];
    else
        return defaultValue;
}


- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    _viewDropTarget = [self hitTestPoint: [sender draggingLocation]
                        forLayerMatching: layerIsDropTarget
                                  offset: NULL];
    _viewDropOp = _viewDropTarget ?[_viewDropTarget draggingEntered: sender] :NSDragOperationNone;
    return _viewDropOp;
}

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender
{
    CALayer *target = [self hitTestPoint: [sender draggingLocation]
                        forLayerMatching: layerIsDropTarget 
                                  offset: NULL];
    if( target == _viewDropTarget ) {
        if( _viewDropTarget )
            _viewDropOp = tell(_viewDropTarget,@selector(draggingUpdated:),sender,_viewDropOp);
    } else {
        tell(_viewDropTarget,@selector(draggingExited:),sender,0);
        _viewDropTarget = target;
        if( _viewDropTarget )
            _viewDropOp = [_viewDropTarget draggingEntered: sender];
        else
            _viewDropOp = NSDragOperationNone;
    }
    return _viewDropOp;
}

- (BOOL)wantsPeriodicDraggingUpdates
{
    return (_viewDropTarget!=nil);
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
    tell(_viewDropTarget,@selector(draggingExited:),sender,0);
    _viewDropTarget = nil;
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
    return tell(_viewDropTarget,@selector(prepareForDragOperation:),sender,YES);
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    return [_viewDropTarget performDragOperation: sender];
}

- (void)concludeDragOperation:(id <NSDraggingInfo>)sender
{
    tell(_viewDropTarget,@selector(concludeDragOperation:),sender,0);
}

- (void)draggingEnded:(id <NSDraggingInfo>)sender
{
    tell(_viewDropTarget,@selector(draggingEnded:),sender,0);
}

@end
