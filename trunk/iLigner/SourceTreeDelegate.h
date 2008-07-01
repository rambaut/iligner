//
// File:       SourceTreeDelegate.h
//
// Abstract:   Header for the source tree delegate. Includes outlets to outline view and 
//             tree controller.
//
// Version:    1.0
//

#import <Cocoa/Cocoa.h>

extern NSString *AbstractTreeNodeType;

@interface SourceTreeDelegate : NSObject {
    IBOutlet NSWindow *window;
    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;

    IBOutlet NSOutlineView *outlineView;
	IBOutlet NSTreeController *treeController;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (NSManagedObjectModel *)managedObjectModel;
- (NSManagedObjectContext *)managedObjectContext;

- (IBAction)saveAction:sender;


@end
