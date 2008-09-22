/*

File: DiscPiece.m

Abstract: A Piece whose image is superimposed on a disc.

Version: 1.0

*/


#import "DiscPiece.h"
#import "QuartzUtils.h"


@implementation DiscPiece


- (void) setImage: (CGImageRef)image scale: (CGFloat)scale
{
    if( scale < 4.0 ) {
        int size = MAX(CGImageGetWidth(image), CGImageGetHeight(image));
        if( scale > 0 )
            scale = ceil( size * scale);
        else
            scale = size;
        scale *= 1.2;
    }
    self.bounds = CGRectMake(0,0,scale,scale);
    
    if( ! _imageLayer ) {
        _imageLayer = [[CALayer alloc] init];
        _imageLayer.contentsGravity = @"resizeAspect";
        [self addSublayer: _imageLayer];
    }
    _imageLayer.frame = CGRectInset(self.bounds, scale*.1, scale*.1);
    _imageLayer.contents = (id) image;
    self.cornerRadius = scale/2;
    self.borderWidth = 3;
    self.borderColor = kTranslucentLightGrayColor;
    self.imageName = nil;
}


@end
