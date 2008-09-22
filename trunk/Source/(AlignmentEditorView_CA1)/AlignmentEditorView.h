//
//  AlignmentEditorView.h
//  iLigner
//
//  Created by Andrew Rambaut on 01/07/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class Bit, Grid, Alignment;
@protocol BitHolder;


@interface AlignmentEditorView : NSView {
@private
	Alignment* _currentAlignment;

    CALayer *_alignmentLayer;                   // main layer
    
    // Used during mouse-down tracking:
    NSPoint _dragStartPos;                      // Starting position of mouseDown
    Bit *_dragBit;                              // Bit being dragged
    id<BitHolder> _oldHolder;                   // Bit's original holder
    CALayer *_oldSuperlayer;                    // Bit's original superlayer
    int _oldLayerIndex;                         // Bit's original index in _oldSuperlayer.layers
    CGPoint _oldPos;                            // Bit's original x/y position
    CGPoint _dragOffset;                        // Offset of mouse position from _dragBit's origin
    BOOL _dragMoved;                            // Has the mouse moved more than 3 pixels since mouseDown?
    id<BitHolder> _dropTarget;                  // Current BitHolder the cursor is over
    
    // Used while handling incoming drags:
    CALayer *_viewDropTarget;                   // Current drop target during an incoming drag-n-drop
    NSDragOperation _viewDropOp;                // Current drag operation
}

- (void) startAlignment: (Alignment*)alignment;

- (IBAction) enterFullScreen: (id)sender;

@property (readonly) CALayer *alignmentLayer;

- (CGRect) alignmentLayerFrame;

@end
