/*

File: BitHolder.m

Abstract: Protocol for a layer that acts as a container for Bits.

Version: 1.0

*/


#import "BitHolder.h"
#import "Bit.h"
#import "QuartzUtils.h"


@implementation BitHolder


- (Bit*) bit
{
    if( _bit && _bit.superlayer != self && !_bit.pickedUp )
        _bit = nil;
    return _bit;
}

- (void) setBit: (Bit*)bit
{
    if( bit != self.bit ) {
        if( bit && _bit )
            [_bit destroy];
        _bit = bit;
        ChangeSuperlayer(bit,self,-1);
    }
}

- (BOOL) isEmpty    {return self.bit==nil;}

@synthesize highlighted=_highlighted;

- (Bit*) canDragBit: (Bit*)bit
{
    if( bit.superlayer == self /*&& ! bit.unfriendly*/ )
        return bit;
    else
        return nil;
}

- (void) cancelDragBit: (Bit*)bit                       { }
- (void) draggedBit: (Bit*)bit to: (id<BitHolder>)dst   {self.bit = nil;}

- (BOOL) canDropBit: (Bit*)bit atPoint: (CGPoint)point  {return YES;}
- (void) willNotDropBit: (Bit*)bit                      { }

- (BOOL) dropBit: (Bit*)bit atPoint: (CGPoint)point
{
    self.bit = bit;
    return YES;
}

@end
