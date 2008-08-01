//
//  ILDocument.m
//  iLigner
//
//  Created by Andrew Rambaut on 01/07/2008.
//  Copyright __MyCompanyName__ 2008 . All rights reserved.
//

#import "ILDocument.h"
#import "SequencesViewController.h"
#import "AlignmentViewController.h"

@implementation ILDocument

- (id)init 
{
    self = [super init];
    if (self != nil) {
        viewControllers = [[NSMutableArray alloc] init];
		
		ManagingViewController *vc;
		vc = [[AlignmentViewController alloc] init];
		[vc setManagedObjectContext:[self managedObjectContext]];
		[viewControllers addObject:vc];

		vc = [[SequencesViewController alloc] init];
		[vc setManagedObjectContext:[self managedObjectContext]];
		[viewControllers addObject:vc];
	}
    return self;
}

- (NSString *)windowNibName 
{
    return @"ILDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController 
{
    [super windowControllerDidLoadNib:windowController];
    // user interface preparation code
	
	NSMenu *menu = [popUp menu];
	int i, itemCount;
	
	itemCount = [viewControllers count];
	
	for (i = 0; i < itemCount; i++) {
		NSViewController *vc = [viewControllers objectAtIndex:i];
		NSMenuItem *mi = [[NSMenuItem alloc] initWithTitle:[vc title]
													action:@selector(changeViewController:)
											 keyEquivalent:@""];
		[mi setTag:i];
		[menu addItem:mi];
	}
	
	// initially show the first controller
	[self displayViewController:[viewControllers objectAtIndex:0]];
	[popUp selectItemAtIndex:0];
}	

- (void)displayViewController:(ManagingViewController *)vc
{
	// Try to end editing
	NSWindow *w = [box window];
	BOOL ended = [w makeFirstResponder:w];
	if (!ended) {
		NSBeep();
		return;
	}

	// Put the view in the box
	NSView *v = [vc view];
	[box setContentView:v];
}

- (IBAction)changeViewController:(id)sender
{
	int i = [sender tag];
	ManagingViewController *vc = [viewControllers objectAtIndex:i];
	[self displayViewController:vc];
}

@end
