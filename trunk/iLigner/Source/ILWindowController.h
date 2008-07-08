//
// File:	   ILWindowController.h
//
// Abstract:   Interface for ILWindowController class.
//
// Version:	   1.0
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@class IconViewController;
@class FileViewController;
@class ChildEditController;
@class SeparatorCell;

@interface ILWindowController : NSWindowController
{
	IBOutlet NSOutlineView		*myOutlineView;
	IBOutlet NSTreeController	*sequencesController;
	IBOutlet NSView				*placeHolderView;
	
	IBOutlet NSButton			*addFolderButton;
	IBOutlet NSButton			*removeButton;
	IBOutlet NSPopUpButton		*actionButton;
	
	NSMutableArray				*contents;
	
	// cached images for generic folder and url document
	NSImage						*folderImage;
	NSImage						*urlImage;
	
	NSView						*currentView;
	IconViewController			*iconViewController;
	FileViewController			*fileViewController;
	ChildEditController			*childEditController;
	
	BOOL						buildingOutlineView;	// signifies we are building the outline view at launch time
	
	NSArray						*dragNodesArray; // used to keep track of dragged nodes

	SeparatorCell				*separatorCell;	// the cell used to draw a separator line in the outline view
}

@property (retain) NSArray *dragNodesArray;

- (void)setContents:(NSArray*)newContents;
- (NSMutableArray*)contents;

- (IBAction)addFolderAction:(id)sender;
- (IBAction)addSequenceAction:(id)sender;
- (IBAction)editSequenceAction:(id)sender;
- (IBAction)removeSequenceAction:(id)sender;

@end
