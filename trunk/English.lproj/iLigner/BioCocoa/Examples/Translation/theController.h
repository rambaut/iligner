//
//  theController.h
//  Translation Demo
//
//  Copyright 2003 The BioCocoa Project. All rights reserved.
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

@class BCSequenceView;
@class BCSequence;

@interface theController : NSObject
{
    IBOutlet BCSequenceView *theInput;
    IBOutlet BCSequenceView *theOutput;
	
	IBOutlet id				theDuration;
	IBOutlet id				theComments;
	IBOutlet id				theMW;
	IBOutlet NSWindow		*window;
	
	BCSequence				*theDNA;
	BCSequence				*theProtein;
}

- (void) setTheDNA:(BCSequence *)newDNA;
- (void) setTheProtein:(BCSequence *)newProtein;

- (BCSequence *) theDNA;
- (BCSequence *) theProtein;

- (IBAction) process:(id)sender;
- (IBAction) importSequence:(id)sender;
- (void) importPanelDidEnd:(NSOpenPanel *)oPanel returnCode:(int)returnCode contextInfo:(void *)contextInfo;

@end
