//
//  SourcesController.h
//  iLigner
//
//  Created by Andrew Rambaut on 04/08/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ILDocument;
@class AlignmentViewController;
@class SequencesViewController;
@class SeparatorCell;

@interface SourcesController : NSObject {
	IBOutlet ILDocument			*document;
	
	IBOutlet NSOutlineView		*outlineView;
	IBOutlet NSTreeController	*treeController;

	IBOutlet NSButton			*newAlignmentButton;

	NSMutableArray				*contents;

	// cached images
	NSImage						*folderImage;
	NSImage						*urlImage;
		
	BOOL						buildingOutlineView;	// signifies we are building the outline view at launch time
	
	NSArray						*dragNodesArray; // used to keep track of dragged nodes
	
	SeparatorCell				*separatorCell;	// the cell used to draw a separator line in the outline view
}

@property (assign) NSArray *dragNodesArray;

- (void)setContents:(NSArray*)newContents;
- (NSMutableArray*)contents;

- (IBAction)newAlignment:(id)sender;

@end
