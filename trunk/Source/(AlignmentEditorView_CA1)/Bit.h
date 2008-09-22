//
//  Bit.h
//  iLigner
//
//  Created by Andrew Rambaut on 01/07/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//
 
#import <Quartz/Quartz.h>


@class Game, Player;
@protocol BitHolder;

/** Standard Z positions */
enum {
    kBoardZ = 1,
    kCardZ  = 2,
    kPieceZ = 3,
    
    kPickedUpZ = 100
};

/** A moveable item in a card/board game.
    Abstract superclass of Card and Piece. */
@interface Bit : CALayer <NSCopying>
{
    @private
    int _restingZ;      // Original z position, saved while pickedUp
    Player *_owner;     // Player that owns this Bit
}

/** Conveniences for getting/setting the layer's scale and rotation */
@property CGFloat scale;
@property int rotation;         // in degrees! Positive = clockwise

/** "Picking up" a Bit makes it larger, translucent, and in front of everything else */
@property BOOL pickedUp;

/** Current holder (or nil) */
@property (readonly) id<BitHolder> holder;

/** Removes this Bit while running a explosion/fade-out animation */
- (void) destroy;

@end
