//
//  ILWindowController.h
//  iLigner
//
//  Created by Andrew Rambaut on 04/08/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ILDocument;
@class SourcesTreeController;
@class SourcesOutlineView;

@interface ILWindowController : NSWindowController {
    IBOutlet ILDocument *document;
    IBOutlet SourcesTreeController *treeController;
	IBOutlet SourcesOutlineView *outlineView;

	IBOutlet NSButton *newAlignment;
}

- (IBAction)newAlignment:(id)sender;

@end
