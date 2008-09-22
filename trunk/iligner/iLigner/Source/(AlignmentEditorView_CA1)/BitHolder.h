/*

File: BitHolder.h

Abstract: Protocol for a layer that acts as a container for Bits.

Version: 1.0

*/


#import <Quartz/Quartz.h>
@class Bit;


/** Protocol for a layer that acts as a container for Bits. */
@protocol BitHolder <NSObject>

/** Current Bit, or nil if empty */
@property (assign) Bit* bit;

/** Conveniences for comparing self.bit with nil */
@property (readonly, getter=isEmpty) BOOL empty;

/** BitHolders will be highlighted while the target of a drag operation */
@property BOOL highlighted;


/** Tests whether the bit is allowed to be dragged out of me.
    Returns the input bit, or possibly a different Bit to drag instead, or nil if not allowed.
    Either -cancelDragBit: or -draggedBit:to: must be called next. */
- (Bit*) canDragBit: (Bit*)bit;

/** Cancels a pending drag (begun by -canDragBit:). */
- (void) cancelDragBit: (Bit*)bit;

/** Called after a drag finishes. */
- (void) draggedBit: (Bit*)bit to: (id<BitHolder>)dst;


/** Tests whether the bit is allowed to be dropped into me.
    Either -willNotDropBit: or -dropBit:atPoint: must be called next. */
- (BOOL) canDropBit: (Bit*)bit atPoint: (CGPoint)point;

/** Cancels a pending drop (after -canDropBit:atPoint: was already called.) */
- (void) willNotDropBit: (Bit*)bit;

/** Finishes a drop. */
- (BOOL) dropBit: (Bit*)bit atPoint: (CGPoint)point;

@end


/** A basic implementation of the BitHolder protocol. */
@interface BitHolder : CALayer <BitHolder>
{
    @protected
    Bit *_bit;
    BOOL _highlighted;
}

@end
