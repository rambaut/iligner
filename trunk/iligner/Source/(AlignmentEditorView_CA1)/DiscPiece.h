/*

File: DiscPiece.h

Abstract: A Piece whose image is superimposed on a disc.

Version: 1.0

*/


#import "Piece.h"


/** A Piece whose image is superimposed on a disc.
    Set the backgroundColor property to change the color or texture of the disc. */
@interface DiscPiece : Piece
{
    CALayer *_imageLayer;
}

@end
