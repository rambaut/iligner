//
// File:	   ChildEditController.h
//
// Abstract:   Controller object for the edit sheet panel.
//
// Version:    1.0
//

#import <Cocoa/Cocoa.h>

@class ILDocumentController;

@interface ChildEditController : NSWindowController
{
@private
	BOOL					cancelled;
	NSMutableDictionary*	savedFields;
	
	IBOutlet NSButton*		doneButton;
	IBOutlet NSButton*		cancelButton;
	IBOutlet NSForm*		editForm;
}

- (NSMutableDictionary*)edit:(NSDictionary*)startingValues from:(ILDocumentController*)sender;
- (BOOL)wasCancelled;

- (IBAction)done:(id)sender;
- (IBAction)cancel:(id)sender;

@end
