//
// File:	   ImageAndTextCell.h
//
// Abstract:   Subclass of NSTextFieldCell which can display text and an image simultaneously.
//
// Version:	   1.0
//

#import <Cocoa/Cocoa.h>

@interface ImageAndTextCell : NSTextFieldCell
{
@private
	NSImage *image;
}

- (void)setImage:(NSImage *)anImage;
- (NSImage*)image;

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView*)controlView;
- (NSSize)cellSize;

@end
