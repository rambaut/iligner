//
//  Bit.m
//  iLigner
//
//  Created by Andrew Rambaut on 01/07/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Bit.h"
#import "QuartzUtils.h"


@implementation Bit


- (id) copyWithZone: (NSZone*)zone
{
    // NSLayer isn't copyable, but it is archivable. So create a copy by archiving to
    // a temporary data block, then unarchiving a new layer from that block.
    // One complication is that, due to a bug in Core Animation, CALayer can't archive
    // a pattern-based CGColor. So as a workaround, clear the background before archiving,
    // then restore it afterwards.
    CGColorRef bg = CGColorRetain(self.backgroundColor);
    self.backgroundColor = NULL;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject: self];
    self.backgroundColor = bg;
    Bit *clone = [NSKeyedUnarchiver unarchiveObjectWithData: data];
    clone.backgroundColor = bg;
    CGColorRelease(bg);

    clone->_owner = _owner;             // _owner is not archived
    return clone;
}


- (NSString*) description
{
    return [NSString stringWithFormat: @"%@[(%g,%g)]", self.class,self.position.x,self.position.y];
}


- (CGFloat) scale
{
    NSNumber *scale = [self valueForKeyPath: @"transform.scale"];
    return scale.floatValue;
}

- (void) setScale: (CGFloat)scale
{
    [self setValue: [NSNumber numberWithFloat: scale]
        forKeyPath: @"transform.scale"];
}


- (int) rotation
{
    NSNumber *rot = [self valueForKeyPath: @"transform.rotation"];
    return round( rot.doubleValue * 180.0 / M_PI );
}

- (void) setRotation: (int)rotation
{
    [self setValue: [NSNumber numberWithDouble: rotation*M_PI/180.0]
        forKeyPath: @"transform.rotation"];
}


- (BOOL) pickedUp
{
    return self.zPosition >= kPickedUpZ;
}

- (void) setPickedUp: (BOOL)up
{
    if( up != self.pickedUp ) {
        CGFloat shadow, offset, radius, opacity, z, scale;
        if( up ) {
            shadow = 0.8;
            offset = 2;
            radius = 8;
            opacity = 0.9;
            scale = 1.2;
            z = kPickedUpZ;
            _restingZ = self.zPosition;
        } else {
            shadow = offset = radius = 0.0;
            opacity = 1.0;
            scale = 1.0/1.2;
            z = _restingZ;
        }
        
        self.zPosition = z;
        self.shadowOpacity = shadow;
        self.shadowOffset = CGSizeMake(offset,-offset);
        self.shadowRadius = radius;
        self.opacity = opacity;
        self.scale *= scale;
    }
}


- (BOOL)containsPoint:(CGPoint)p
{
    // Make picked-up pieces invisible to hit-testing.
    // Otherwise, while dragging a Bit, hit-testing the cursor position would always return
    // that Bit, since it's directly under the cursor...
    if( self.pickedUp )
        return NO;
    else
        return [super containsPoint: p];
}


-(id<BitHolder>) holder
{
    // Look for my nearest ancestor that's a BitHolder:
    for( CALayer *layer=self.superlayer; layer; layer=layer.superlayer ) {
        if( [layer conformsToProtocol: @protocol(BitHolder)] )
            return (id<BitHolder>)layer;
        else if( [layer isKindOfClass: [Bit class]] )
            return nil;
    }
    return nil;
}


- (void) destroy
{
    // "Pop" the Bit by expanding it 5x as it fades away:
    self.scale = 5;
    self.opacity = 0.0;
    // Removing the view from its superlayer right now would cancel the animations.
    // Instead, defer the removal until sometime shortly after the animations finish:
    [self performSelector: @selector(removeFromSuperlayer) withObject: nil afterDelay: 1.0];
}


@end
