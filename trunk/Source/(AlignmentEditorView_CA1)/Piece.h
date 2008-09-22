/*

File: Piece.h

Abstract: A playing piece. A concrete subclass of Bit that displays an image..

Version: 1.0

*/


#import "Bit.h"


/** A playing piece. A concrete subclass of Bit that displays an image. */
@interface Piece : Bit
{
    @private
    NSString *_imageName;
}

/** Initialize a Piece from an image file.
    imageName can be a resource name from the app bundle, or an absolute path.
    If scale is 0.0, the image's natural size will be used.
    If 0.0 < scale < 4.0, the image will be scaled by that factor.
    If scale >= 4.0, it will be used as the size to scale the maximum dimension to. */
- (id) initWithImageNamed: (NSString*)imageName
                    scale: (CGFloat)scale;

- (void) setImage: (CGImageRef)image scale: (CGFloat)scale;
- (void) setImage: (CGImageRef)image;
- (void) setImageNamed: (NSString*)name;

@property (copy) NSString* imageName;

@end
