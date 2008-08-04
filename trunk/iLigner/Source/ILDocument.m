//
//  ILDocument.m
//  iLigner
//
//  Created by Andrew Rambaut on 01/07/2008.
//  Copyright __MyCompanyName__ 2008 . All rights reserved.
//

#import "ILDocument.h"
#import "SourceSection.h"
#import "Alignment.h"

@implementation ILDocument

- (id)init 
{
    self = [super init];
    if (self != nil) {
		// init here
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

	SourceSection *sourceSection = [[SourceSection alloc] init];
	sourceSection.displayName = @"Alignments";
	[windowController insertSection:sourceSection];	

	sourceSection = [[SourceSection alloc] init];
	sourceSection.displayName = @"Sequences";
	[windowController insertSection:sourceSection];	
}	

- (Alignment *)newAlignment
{
	Alignment *alignment = [NSEntityDescription insertNewObjectForEntityForName:@"Alignment" inManagedObjectContext:[self managedObjectContext]];
	return alignment;
}

@end