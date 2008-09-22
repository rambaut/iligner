//
//  AlignmentViewController.h
//  iLigner
//
//  Created by Andrew Rambaut on 31/07/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ILViewController.h"

@class AlignmentEditorView, Alignment;

@interface AlignmentViewController : ILViewController {
	IBOutlet AlignmentEditorView* alignmentEditorView;
	IBOutlet NSScrollView* scrollView;
	
	int rowCount;
	int columnCount;
	
	double rowHeight;
	double columnWidth;
}

@property (assign) int rowCount;
@property (assign) int columnCount;
@property (assign) double rowHeight;
@property (assign) double columnWidth;

- (void) startAlignment: (Alignment*)alignment;

@end
