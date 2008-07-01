#import "Controller.h"
#import "MyDocument.h"


static void addToolbarItem(NSMutableDictionary *theDict,NSString *identifier,NSString *label,NSString *paletteLabel,NSString *toolTip,id target,SEL settingSelector, id itemContent,SEL action, NSMenu * menu)
{
    NSMenuItem *mItem;
    // here we create the NSToolbarItem and setup its attributes in line with the parameters
    NSToolbarItem *item = [[[NSToolbarItem alloc] initWithItemIdentifier:identifier] autorelease];
    [item setLabel:label];
    [item setPaletteLabel:paletteLabel];
    [item setToolTip:toolTip];
    [item setTarget:target];
    // the settingSelector parameter can either be @selector(setView:) or @selector(setImage:).  Pass in the right
    // one depending upon whether your NSToolbarItem will have a custom view or an image, respectively
    // (in the itemContent parameter).  Then this next line will do the right thing automatically.
    [item performSelector:settingSelector withObject:itemContent];
    [item setAction:action];
    // If this NSToolbarItem is supposed to have a menu "form representation" associated with it (for text-only mode),
    // we set it up here.  Actually, you have to hand an NSMenuItem (not a complete NSMenu) to the toolbar item,
    // so we create a dummy NSMenuItem that has our real menu as a submenu.
    if (menu!=NULL)
    {
	// we actually need an NSMenuItem here, so we construct one
	mItem=[[[NSMenuItem alloc] init] autorelease];
	[mItem setSubmenu: menu];
	[mItem setTitle: [menu title]];
	[item setMenuFormRepresentation:mItem];
    }
    // Now that we've setup all the settings for this new toolbar item, we add it to the dictionary.
    // The dictionary retains the toolbar item for us, which is why we could autorelease it when we created
    // it (above).
    [theDict setObject:item forKey:identifier];
}

@implementation Controller

// When we launch, we have to get our NSToolbar set up.  This involves creating a new one, adding the NSToolbarItems,
// and installing the toolbar in our window.
-(void)awakeFromNib
{
    NSFont *theFont;
    NSToolbar *toolbar=[[[NSToolbar alloc] initWithIdentifier:@"myToolbar"] autorelease];
    
    // Here we create the dictionary to hold all of our "master" NSToolbarItems.
    toolbarItems=[[NSMutableDictionary dictionary] retain];
    // Now lets create three NSToolbarItems; 2 using custom views, and a standard one using an image.
    // We call our special processing function to do the initialization and add them to the dictionary.
    addToolbarItem(toolbarItems,@"Search",@"Search Taxa",@"Search Taxa",@"Search in the taxa list",self,@selector(setView:),searchView,NULL,NULL);
        // often using an image will be your standard case.  You'll notice that a selector is passed
    // for the action (blueText:), which will be called when the image-containing toolbar item is clicked.
    addToolbarItem(toolbarItems,@"New",@"New Taxon",@"New Taxon",@"Create a new taxon",myDoc,@selector(setImage:),[NSImage imageNamed:@"new.tiff"],@selector(addNewRecord:),NULL);

    addToolbarItem(toolbarItems,@"Delete",@"Delete Taxon",@"Delete Taxon",@"Delete selected taxa",myDoc,@selector(setImage:),[NSImage imageNamed:@"delete.tiff"],@selector(removeTaxa:),NULL);

    addToolbarItem(toolbarItems,@"Drawer",@"Show Info",@"Show Info",@"Show Info",myDoc,@selector(setImage:),[NSImage imageNamed:@"info.tiff"],@selector(toggleDrawer:),NULL);

    addToolbarItem(toolbarItems,@"Calculate",@"Calculate",@"Calculate",@"Calculate the new character states",myDoc,@selector(setImage:),[NSImage imageNamed:@"calculator.tiff"],@selector(calculateNewForEveryCharacter:),NULL);

 addToolbarItem(toolbarItems,@"Export",@"Export Nexus",@"Export Nexus",@"Export the new character states to a nexus file",myDoc,@selector(setImage:),[NSImage imageNamed:@"export.tiff"],@selector(exportToNexus:),NULL);

 addToolbarItem(toolbarItems,@"Import",@"Import Data",@"Import Data",@"Import data from a tab delimited text file",myDoc,@selector(setImage:),[NSImage imageNamed:@"import.tiff"],@selector(chooseTDFile:),NULL);

     
    // the toolbar wants to know who is going to handle processing of NSToolbarItems for it.  This controller will.
    [toolbar setDelegate:self];
    [toolbar setAllowsUserCustomization:YES];
    [toolbar setAutosavesConfiguration: YES]; 
    [toolbar setDisplayMode: NSToolbarDisplayModeIconAndLabel];
    [theWindow setToolbar:toolbar];
    
}





- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem
{
    // You could check [theItem itemIdentifier] here and take appropriate action if you wanted to

    if ([[theItem itemIdentifier] isEqual:@"BlueLetter"]) {
        return NO;
    }
    else {   
    return YES;
    }
}




- (void) toolbarWillAddItem: (NSNotification *) notif
{
    NSToolbarItem *addedItem = [[notif userInfo] objectForKey: @"item"];
}  



// This method is required of NSToolbar delegates.  It takes an identifier, and returns the matching NSToolbarItem.
// It also takes a parameter telling whether this toolbar item is going into an actual toolbar, or whether it's
// going to be displayed in a customization palette.
- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag
{
    // We create and autorelease a new NSToolbarItem, and then go through the process of setting up its
    // attributes from the master toolbar item matching that identifier in our dictionary of items.
    NSToolbarItem *newItem = [[[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier] autorelease];
    NSToolbarItem *item=[toolbarItems objectForKey:itemIdentifier];
    
    [newItem setLabel:[item label]];
    [newItem setPaletteLabel:[item paletteLabel]];
    if ([item view]!=NULL)
    {
	[newItem setView:[item view]];
    }
    else
    {
	[newItem setImage:[item image]];
    }
    [newItem setToolTip:[item toolTip]];
    [newItem setTarget:[item target]];
    [newItem setAction:[item action]];
    [newItem setMenuFormRepresentation:[item menuFormRepresentation]];
    // If we have a custom view, we *have* to set the min/max size - otherwise, it'll default to 0,0 and the custom
    // view won't show up at all!  This doesn't affect toolbar items with images, however.
    if ([newItem view]!=NULL)
    {
	[newItem setMinSize:[[item view] bounds].size];
	[newItem setMaxSize:[[item view] bounds].size];
    }

    return newItem;
}


// This method is required of NSToolbar delegates.  It returns an array holding identifiers for the default
// set of toolbar items.  It can also be called by the customization palette to display the default toolbar.    
- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar
{
    return [NSArray arrayWithObjects:@"Import",@"Calculate",@"Export",@"Search", NSToolbarFlexibleSpaceItemIdentifier, @"Drawer",nil];
}



// This method is required of NSToolbar delegates.  It returns an array holding identifiers for all allowed
// toolbar items in this toolbar.  Any not listed here will not be available in the customization palette.
- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar
{
    return [NSArray arrayWithObjects:@"Delete",@"Import",@"Calculate",@"Export",@"Search", NSToolbarSeparatorItemIdentifier, @"Drawer", NSToolbarSpaceItemIdentifier,NSToolbarFlexibleSpaceItemIdentifier,NSToolbarPrintItemIdentifier,nil];
}



// throw away our toolbar items dictionary
- (void) dealloc
{
    [toolbarItems release];
    [super dealloc];
}

@end
