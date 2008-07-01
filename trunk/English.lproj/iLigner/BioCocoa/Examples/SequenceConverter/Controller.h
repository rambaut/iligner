
#import <Cocoa/Cocoa.h>

@interface Controller : NSObject
{
    IBOutlet id theWindow;
    IBOutlet NSView *searchView; //the font size changing view (ends up in an NSToolbarItem)
    NSMutableDictionary *toolbarItems; //The dictionary that holds all our "master" copies of the NSToolbarItems
    IBOutlet id myDoc;
}

//Required NSToolbar delegate methods
- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag;    
- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar;
- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar;

@end
