//
//  ILDocument.m
//  iLigner
//
//  Created by Andrew Rambaut on 01/07/2008.
//  Copyright __MyCompanyName__ 2008 . All rights reserved.
//

#import "ILDocument.h"
#import "ILEngine.h"
#import "AlignmentViewController.h"
#import "SequencesViewController.h"

@implementation ILDocument

@synthesize alignmentEngine;

- (id)init 
{
    self = [super init];
    if (self != nil) {
		ILEngine* engine = [[ILEngine alloc] init];
		[engine setManagedObjectContext:[self managedObjectContext]];
		[self setAlignmentEngine:engine];	
		
		alignmentViewController = [[AlignmentViewController alloc] init];
		[alignmentViewController setAlignmentEngine:[self alignmentEngine]];
		
 		sequencesViewController = [[SequencesViewController alloc] init];
		[alignmentViewController setAlignmentEngine:[self alignmentEngine]];
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
}	

// -------------------------------------------------------------------------------
//	outlineViewSelectionDidChange:notification
// -------------------------------------------------------------------------------
- (void)sourcesSelected:(NSArray *)selection
{
//	NSLog(@"sourcesSelected: %@", selection);
	if ([selection count] == 1) {
		if ([[selection objectAtIndex:0] alignment] != nil) {
			[self displayViewController:alignmentViewController];
		} else {
			[self displayViewController:sequencesViewController];
		}
	} else {
		[self displayViewController:nil];
	}
}

- (void)displayViewController:(ILViewController *)vc
{	
	// Try to end editing
//	NSWindow *w = [box window];
//	BOOL ended = [w makeFirstResponder: w];
//	if (!ended) {
//		NSBeep();
//		return;
//	}
	
	if (vc != nil) {
		NSView *v = [vc view];
		[box setContentView: v];
	} else {
		[box setContentView:nil];
	}
 
	
}

@end