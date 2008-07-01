//
//  theController.m
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

#import "theController.h"
#import "Result.h"
#import "Peptide.h"
#import <BioCocoa/BCFoundation.h>
#import <BioCocoa/BCAppKit.h>

#define	USE_PEPTIDE_CLASS	1

@implementation theController

//===========================================================================
#pragma mark -
#pragma mark ¥ INIT and DEALLOC
//===========================================================================

- (void)awakeFromNib
{
	// Wakey, Wakey!
	
	// register for the textDidChange method
	[theInput setDelegate: self];
	
	// prepare empty results array for tableview
	[self setResults: [NSMutableArray array]];
	
	// read in the file test1.txt using a BCSequenceReader object as the default sequence

	if (![self loadSequenceFromFile: [[NSBundle mainBundle] pathForResource: @"test1" ofType:@"txt"]])
		NSBeep();

	[toleranceInput setFloatValue: 100];
	[chargePopup selectItemAtIndex:1];
	
	[theInput setUnit: @"aa"];
	[theInput setFilter: YES];
	[self setName: @"ER Beta"];
	[self updateCalculations];	
}


- (void)dealloc{
	// cleanup our mess
	[name release];
	[results release];
	[sequence release];
		
	[super dealloc];
}

//===========================================================================
#pragma mark -
#pragma mark ¥ ACCESSOR METHODS
//===========================================================================

- (NSString *)name
{
	return name;
}

- (void)setName:(NSString *)newName
{
	[newName retain];
	[name release];
	name = newName;
}

- (BCSequence *)sequence
{
	return sequence;
}

- (void)setSequence:(BCSequence *)newSequence
{
	[newSequence retain];
	[sequence release];
	sequence = newSequence;
}

- (NSMutableArray *)results
{
	return results;
}

- (void)setResults:(NSMutableArray *)newResults
{
	[newResults retain];
	[results release];
	results = newResults;
}


//===========================================================================
#pragma mark -
#pragma mark ¥ ACTIONS AND METHODS
//===========================================================================

- (IBAction)openInput:(id)sender{
	// triggered by the file -> open command, present file open sheet
	NSOpenPanel *opanel = [NSOpenPanel openPanel];
    [opanel setCanSelectHiddenExtension: NO];
	[opanel setCanChooseDirectories: NO];
	[opanel setCanChooseFiles: YES];
	[opanel setPrompt: @"Open"];
    [opanel setDelegate: self];
    
    [opanel beginSheetForDirectory: nil 
                              file: nil                    
					modalForWindow: [NSApp mainWindow]
                     modalDelegate: self 
                    didEndSelector: @selector(inputPanelDidEnd:returnCode:contextInfo:)
                       contextInfo: @"Input"];	
}

- (void)inputPanelDidEnd:(NSOpenPanel *)oPanel returnCode:(int)returnCode contextInfo:(void *)contextInfo{
	// path choosen
	NSString *path = [oPanel filename];
	// pressed ok?
	if(returnCode != NSOKButton) return;
	
	// load data from file
	if (![self loadSequenceFromFile: path])
		NSBeep();
	
	[self updateCalculations];
}

- (BOOL)loadSequenceFromFile:(NSString *)path
{
    // store filename
    [self setName: [path lastPathComponent]];
   
	// read the file using a BCSequenceReader object 
    BCSequenceReader *sequenceReader = [[BCSequenceReader alloc] init];	
	BCSequenceArray *sequenceArray = [sequenceReader readFileUsingPath: path];

	// if nothing read, stop here
	if(!sequenceArray) return NO;
	// else NSLog(@"%@", sequenceArray);
   
    // take the first entry found in the file and store the BCSequence object
	
    BCSequence *seq = [sequenceArray sequenceAtIndex: 0];
   
    if(seq){
	   [self setSequence: seq];
	   [theInput setString: [sequence sequenceString]];
	   [theInput updateLayout];
    } 
   
    // cleanup	
    [sequenceReader release];

	return YES;
}


- (void)updateCalculations{	
	// presents some general info about the sequence currently loaded, triggered both manually
	// and automatically after 0.3s when the text in the inputview changes

    if (![self sequence]){
		// if no sequence present bail
		[general setStringValue: @"Input"];
        return;
	}
	
	// use a BCToolMassCalculator class to calculate the MW of the total Protein.
	BCToolMassCalculator *calculator = [BCToolMassCalculator massCalculatorWithSequence: [self sequence]];
	// choose type of mass based on checkbox
	if([massType state])[calculator setMassType: BCMonoisotopic];
	else [calculator setMassType: BCAverage];
	
	// calculate mass and convert to kDa
	float mw = [[[calculator calculateMass]objectAtIndex: 0]floatValue] / 1000.0;
	// build nice string and present to the user
	[general setStringValue: [NSString stringWithFormat: @"%@, %d aa, %.2f kDa", [self name], [[self sequence]length], mw]];
}

- (IBAction)revert:(id)sender{
	// triggered by file -> revert command, reset the whole thing
	[self setName: nil];
	[self setSequence: nil];
	[self setResults: nil];

	[tv reloadData];
	[theInput setString: @""];
	[general setStringValue: @"Input"];
}

- (IBAction)process:(id)sender
{
	// triggered by the "Find peptide" button
	// spin off a thread to make sure the interface remains active and the progress indicator is updated
	[NSThread detachNewThreadSelector: @selector(findpeptide) toTarget: self withObject: nil];
}


- (void)findpeptide{
	// the workhorse
	
	// all threads should create their own autorelease pool
	NSAutoreleasePool *threadPool = [[NSAutoreleasePool alloc] init];
	
	// What are we looking for?
	float theweight = [mwInput floatValue];
	// If nothing or if there's no sequence then bail...
	if(![self sequence] || theweight == 0){
		NSBeep();
		[threadPool release];
		return;
	}

	float	protonMass = [massType state] ? hydrogenMonoisotopicMass : hydrogenAverageMass;
	int		chargeState = [chargePopup indexOfSelectedItem];
	int		toleranceType = [tolerancePopup indexOfSelectedItem];	// 0 = ppm, 1 = Da
	
	//correct for chargeState, if entered
	if ( chargeState > 0 )
	{
	 // this will calculate the 'real MW' of the uncharged peptide
		theweight = ( theweight * chargeState ) - ( chargeState * protonMass );
	}

	// set the begin time
    NSDate *theDate = [NSDate date];
	
	// prepare for liftoff
	[indicator setIndeterminate: NO];
	[indicator startAnimation: self];
	[processButton setEnabled: NO];

	// Ok, here we go. Note that we do everything the BioCocoa way, i.a.w. a lot of convenience (e.g., the average vs monoisotopic choice)
	// but also considerable overhead because of object messaging. For instance, most time is spend in the calculateMassOfRange: method (obviously)
	// which uses NSCountedSet to calculate how often each amino acid occurs. It must be possible to speed it up drammatically if you implement everything
	// in C using hardcoded mass values and plain char arrays. That's left to an excercise for the reader ;-) Tassos, show me how fast you can 
	// make it! 
	
	// Prepare and cache a BCToolMassCalculator class to calculate the MWs.
	BCToolMassCalculator *calculator = [BCToolMassCalculator massCalculatorWithSequence: [self sequence]];
	// Set the masstype based on the checkbox
	if([massType state])[calculator setMassType: BCMonoisotopic];
	else [calculator setMassType: BCAverage];
	
	// Store the length of the sequence
	int seqlength = [[self sequence] length];
	
	// To limit the searchspace, we take a very simple algorithm. What would be the maximum and minimum number of aminoacids
	// that would lead to the MW we're looking for. This is somewhat overkill perhaps. For instance, it would save us a lot of time		
	// if we would just divide through the average weight of an aminoacid and take a certain bandwidth (e.g., ±10%). But to let's
	// be on the save side here.
	
	// Weight of lightest and heaviest aminoacid
	float lightweight = [massType state] ? [[BCAminoAcid glycine] monoisotopicMass] : [[BCAminoAcid glycine] averageMass];
	float heavyweight = [massType state] ? [[BCAminoAcid tryptophan] monoisotopicMass] : [[BCAminoAcid tryptophan] averageMass];
	// Calculate the lowest and higest possible number of aminoacids
	int minnumber = floor(theweight/heavyweight);
	int maxnumber = ceil(theweight/lightweight);
	// Check if maxnumber is not longer than the actual sequence ;-)
	maxnumber = (maxnumber > seqlength) ? seqlength : maxnumber;
	// So what will we check?
	NSLog(@"Min: %d, Max: %d", minnumber, maxnumber);
	
	// Prepare the progressindicator
	// OUCH, you shouldn't call these appkit methods from a thread as the mainthread might be updating/modifying it as well,
	// making your app crash. We can't do this in commercial software ;-)
	[indicator setMinValue: (double)minnumber];
	[indicator setMaxValue: (double)maxnumber];
	[indicator setDoubleValue: (double)minnumber];
	
	// Some variables we need in the loops
	int length, idx, counter;
	NSRange aRange;
	float mw, diff, tolerance;
	NSAutoreleasePool *innerPool;

	tolerance = [toleranceInput floatValue];
	
	// We store the results as Result/Peptide objects in a NSMutableArray to enable easy connection with the tableview
	// Calculate raw (over) estimate of nr of peptides and create result array with that capacity
	counter = (maxnumber + 1 - minnumber) * (seqlength - minnumber);
	[self setResults: [NSMutableArray arrayWithCapacity: counter]];
	NSLog(@"Estimated nr of peptides: %d", counter);
	
	// Here we are for the next couple of seconds...
	counter = 0;
	[peptideCount performSelectorOnMainThread: @selector(setStringValue:) withObject: 
							[NSString stringWithFormat: @"Matching peptides found: %d", counter] waitUntilDone: NO];

	// From minimum length to maximum length of peptide
	for ( length = minnumber ; length < maxnumber + 1 ; length++ ) {
		// NSLog(@"Length: %d", length);
		
		// update the interface on the main thread
		[theDuration performSelectorOnMainThread: @selector(setStringValue:) withObject: [NSString stringWithFormat: @"Checking peptides of length: %d", length] waitUntilDone: NO];
		[self performSelectorOnMainThread: @selector(updateIndicator) withObject: nil waitUntilDone: NO];
		
		// create autoreleasepool to speed up memory management, we release this one after each outer loop increment
		innerPool = [[NSAutoreleasePool alloc] init];
		
		// From begin to end - length of current peptide
		for ( idx = 0 ; idx < seqlength - length ; idx++ ) {
			// where are we in the sequence?
			aRange = NSMakeRange(idx, length);
			// calculate MW for this peptide
			mw = [[[calculator calculateMassForRange: aRange]objectAtIndex: 0]floatValue];
			
			// only add if we're within accuracy range

            switch ( toleranceType )
            {
                case 0:		// ppm
                    diff = ( ( ( mw - theweight )/ theweight ) * 1000000 );
                    break;

                case 1:		// Da
                    diff = ( mw - theweight );
                    break;
            }

			// absolute distance from target mw
			if ( fabs( diff ) < tolerance )
			{
			// create the Result/Peptide object and fill it
			#if USE_PEPTIDE_CLASS
				Peptide *peptide = [[Peptide alloc] init];
			#else
				Result *peptide = [[Result alloc]init];
			#endif
				[peptide setMw: mw];
				[peptide setDiff: diff]; 
				[peptide setRange: aRange];
				// add it to the results array, release it to counterbalance the init as it is now retained by the array
				[results addObject: peptide];
				[peptide release];
				
				[peptideCount performSelectorOnMainThread: @selector(setStringValue:) withObject: 
							[NSString stringWithFormat: @"Matching peptides found: %d", [results count]] waitUntilDone: NO];
			}
			
			// yep, we have another one screened:
			counter++;
		}
		
		// release unused objects
		[innerPool release];
	}	
	
	// done, now sort the result array on the distance from the target mw
	[results sortUsingSelector: @selector(compare:)];
	
	// update the interface, remember the thing about not doing this in a thread?
	[indicator setIndeterminate: YES];
	[indicator stopAnimation: self];
	[processButton setEnabled: YES];

//	[theDuration setStringValue: [NSString stringWithFormat: @"%d peptides were checked in %.3fs", counter, [theDate timeIntervalSinceNow] * -1]];
	[theDuration performSelectorOnMainThread: @selector(setStringValue:) withObject: 
				[NSString stringWithFormat: @"%d peptides were checked in %.3fs", counter, [theDate timeIntervalSinceNow] * -1] waitUntilDone: NO];
	[tv reloadData];
	
	// cleanup the thread's autoreleasepool
	[threadPool release];
}


- (void)updateIndicator{
	// this simple method bumps the progressindicator on the main thread
	[indicator incrementBy: 1.0];
}


//===========================================================================
#pragma mark -
#pragma mark ¥ TEXTVIEW DELEGATE
//===========================================================================

- (NSString *)filterInputString: (NSString *) inputString textView: (BCSequenceView *)textView
{
	BCSymbolSet	*symbolSet;
	
	if ( textView == theInput )
	{	
		symbolSet = [sequence symbolSet];
		return [symbolSet stringByRemovingUnknownCharsFromString: inputString];
	}

	return inputString;
}

- (void)textDidChange:(NSNotification *)aNotification
{
	// if our input textview changes, recalculate the mw and nr of aminoacids
    if ([aNotification object] == theInput)
    {		
		// replace the sequence for a new one, unfortunately we haven't created a BCSequenceView that works natively with BCSequences yet
		[self setSequence: [BCSequence sequenceWithString: [theInput string] symbolSet: [BCSymbolSet proteinSymbolSet]]];
		// make sure the spaces are nicely added
        [theInput updateLayout];
		// now do the calculations, but do it with a delay so we don't get choppy behaviour if we keep on typing
		// cancel the previous request if this one followed within 0.3s
		[NSObject cancelPreviousPerformRequestsWithTarget: self];
		[self performSelector: @selector(updateCalculations) withObject: nil afterDelay: 0.3];
    }
}


//===========================================================================
#pragma mark -
#pragma mark ¥ TABLEVIEW DELEGATE
//===========================================================================	

- (int)numberOfRowsInTableView:(NSTableView *)theTableView
{
	// don't show more than 200 results, the rest we're not interested in anyway
	if([results count] > 200) return 200;
    else return [results count];
}

- (id)tableView:(NSTableView *)theTableView objectValueForTableColumn:(NSTableColumn *)theColumn row:(int)rowIndex
{
	// this will trigger the description: method of the object
	return [results objectAtIndex: rowIndex];
}


- (void)tableViewSelectionDidChange:(NSNotification *)aNotification{
	// is there a selection?
	if ([[aNotification object] selectedRow] == -1) return;
	else {
		// which result is selected?
	#if USE_PEPTIDE_CLASS
		Peptide *res = [results objectAtIndex: [tv selectedRow]];
	#else
		Result *res = [results objectAtIndex: [tv selectedRow]];
	#endif
		// select the location of the peptide in the inputview
		
		[theInput setSelectedRange: [res range]];
	}
}

//===========================================================================
#pragma mark -
#pragma mark ¥ APP DELEGATE
//===========================================================================	

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication{
	return YES;
}

@end
