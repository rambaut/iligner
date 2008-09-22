/*

File: Piece.m

Abstract: A playing piece. A concrete subclass of Bit that displays an image..

Version: 1.0

*/


#import "Piece.h"
#import "QuartzUtils.h"


@implementation Piece


- (id) initWithImageNamed: (NSString*)imageName
                    scale: (CGFloat)scale
{
    self = [super init];
    if (self != nil) {
        _imageName = imageName;
        [self setImage: GetCGImageNamed(imageName) scale: scale];
        self.zPosition = kPieceZ;
    }
    return self;
}


- (id) initWithCoder: (NSCoder*)decoder
{
    self = [super initWithCoder: decoder];
    if( self ) {
        _imageName = [decoder decodeObjectForKey: @"imageName"];
        // (actual image (self.contents) was already restord by superclass)
    }
    return self;
}

- (void) encodeWithCoder: (NSCoder*)coder
{
    [super encodeWithCoder: coder];
    [coder encodeObject: _imageName forKey: @"imageName"];
}


- (NSString*) description
{
    return [NSString stringWithFormat: @"%@[%@]", 
            [self class],
            _imageName.lastPathComponent.stringByDeletingPathExtension];
}


@synthesize imageName=_imageName;


- (void) setImage: (CGImageRef)image scale: (CGFloat)scale
{
    self.contents = (id) image;
    self.contentsGravity = @"resize";
    self.minificationFilter = kCAFilterLinear;
    int width = CGImageGetWidth(image), height = CGImageGetHeight(image);
    if( scale > 0 ) {
        if( scale >= 4.0 )
            scale /= MAX(width,height);             // interpret scale as target dimensions
        width = ceil( width * scale);
        height= ceil( height* scale);
    }
    self.bounds = CGRectMake(0,0,width,height);
    _imageName = nil;
}

- (void) setImage: (CGImageRef)image
{
    CGSize size = self.bounds.size;
    [self setImage: image scale: MAX(size.width,size.height)];
}

- (void) setImageNamed: (NSString*)name
{
    [self setImage: GetCGImageNamed(name)];
    _imageName = name;
}


- (BOOL)containsPoint:(CGPoint)p
{
    // Overrides CGLayer's implementation,
    // returning YES only for pixels at which this layer's alpha is at least 0.5.
    // This takes into account the opacity, bg color, and background image's alpha channel.
    if( ! [super containsPoint: p] )
        return NO;
    float opacity = self.opacity;
    if( opacity < 0.5 )
        return NO;
    float thresholdAlpha = 0.5 / self.opacity;
    
    CGColorRef bg = self.backgroundColor;
    float alpha = bg ?CGColorGetAlpha(bg) :0.0;
    if( alpha < thresholdAlpha ) {
        CGImageRef image = (CGImageRef)self.contents;
        if( image ) {
            // Note: This makes the convenient assumption that the image entirely fills the bounds.
            alpha = MAX(alpha, GetPixelAlpha(image, self.bounds.size, p));
        }
    }
    return alpha >= thresholdAlpha;
}


@end
