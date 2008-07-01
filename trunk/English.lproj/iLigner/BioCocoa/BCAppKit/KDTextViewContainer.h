//
//  KDTextViewContainer.h
//  LineNumbering
//
//  Created by Koen van der Drift on Sat May 01 2004.
//  Copyright (c) 2004 Koen van der Drift. All rights reserved.
//

/* TextViewContainer subclass corrects for the 30 point indent needed for the linenumber margin */

#import <Cocoa/Cocoa.h>

#define	kLEFT_MARGIN_WIDTH	30;

@interface KDTextViewContainer : NSTextContainer {

	float columnWidth;
}


- (float) columnWidth;
- (void) setColumnWidth:(float) width;

@end
