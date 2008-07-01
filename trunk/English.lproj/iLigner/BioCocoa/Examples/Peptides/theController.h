//
//  theController.h
//  Peptides
//
//  Created by Alexander Griekspoor on Zat Mar 19 2005.
//  Copyright 2005 The BioCocoa Project. All rights reserved.
//
//  This code is covered by the Creative Commons Share-Alike Attribution license.
//	You are free:
//	to copy, distribute, display, and perform the work
//	to make derivative works
//	to make commercial use of the work
//
//	Under the following conditions:
//	You must attribute the work in the manner specified by the author or licensor.
//	If you alter, transform, or build upon this work, you may distribute the resulting work only under a license identical to this one.
//
//	For any reuse or distribution, you must make clear to others the license terms of this work.
//	Any of these conditions can be waived if you get permission from the copyright holder.
//
//  For more info see: http://creativecommons.org/licenses/by-sa/2.5/

#import <Cocoa/Cocoa.h>

@class BCSequenceView, BCSequence;

@interface theController : NSObject
{
	//===========================================================================
    //  Nib Outlets
    //===========================================================================
	
    IBOutlet BCSequenceView *theInput;
	IBOutlet NSTableView	*tv;
	IBOutlet NSTextField	*general;
	IBOutlet NSTextField	*peptideCount;
	IBOutlet NSTextField	*mwInput;
	IBOutlet NSTextField	*theDuration;
	IBOutlet NSTextField	*toleranceInput;
	IBOutlet NSPopUpButton	*tolerancePopup;
	IBOutlet NSPopUpButton	*chargePopup;

	IBOutlet NSProgressIndicator *indicator;
	
	IBOutlet NSButton *massType;
	IBOutlet NSButton *processButton;
		
	//===========================================================================
    //  Variables and properties
    //===========================================================================
	
	NSString *name;					// filename currently loaded
	BCSequence  *sequence;			// sequence currently loaded
	NSMutableArray *results;		// place to store the results (contains Result objects)
}

//===========================================================================
//  Accessor methods
//===========================================================================

- (NSString *)name;
- (void)setName:(NSString *)newName;

- (BCSequence *)sequence;
- (void)setSequence:(BCSequence *)newSequence;

- (NSMutableArray *)results;
- (void)setResults:(NSMutableArray *)newResults;

//===========================================================================
//  Actions and methods
//===========================================================================

- (IBAction)openInput:(id)sender;
- (void)inputPanelDidEnd:(NSOpenPanel *)oPanel returnCode:(int)returnCode contextInfo:(void *)contextInfo;	
- (BOOL)loadSequenceFromFile:(NSString *)path;
- (void)updateCalculations;

- (IBAction)revert:(id)sender;
- (IBAction)process:(id)sender;

- (void)findpeptide;
- (void)updateIndicator;
	
@end
