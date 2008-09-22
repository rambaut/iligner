//
//  PreferenceController.h
//  iLigner
//
//  Created by Andrew Rambaut on 01/08/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString * const ILAlignmentBgColorKey;
extern NSString * const ILEmptyDocKey;
extern NSString * const ILSequenceNameFontSizeKey;

@interface PreferenceController : NSWindowController {
}

- (NSColor *)alignmentBGColor;
- (BOOL)emptyDoc;

@end
