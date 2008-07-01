//
//  theController.m
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



#import "theController.h"
#import <BioCocoa/BCFoundation.h>
#import <BioCocoa/BCAppKit.h>
#import <BioCocoa/BCUtilStrings.h>


@implementation theController

/////////////////////////////////////////////////////////////////////
//
//  FILL THE FOLLOWING METHOD WITH CODE THAT TESTS YOUR WORK IN THE 
//  BIOCOCOA FRAMEWORK.
//
//  THE TWO NSTEXTVIEWS AVAILABLE ARE CALLED "theInput" and "theOutput"
//  THE NSTEXTFIELD "theDuration" WILL SHOW THE DURATION OF THE PROCESS
//  THE NSTEXTFIELD "theComments" CAN OPTIONALLY BE USED TO DISPLAY
//  ADDITIONAL INFO
//
/////////////////////////////////////////////////////////////////////


-(void)dealloc
{
	[theDNA release];
	[theProtein release];
	
	[super dealloc];
}

-(void)setTheDNA:(BCSequence *)newDNA
{
	[newDNA retain];
	[theDNA release];
	theDNA = newDNA;	
}

-(void)setTheProtein:(BCSequence *)newProtein
{
	[newProtein retain];
	[theProtein release];
	theProtein = newProtein;
}

- (BCSequence *) theDNA
{
	return theDNA;
}

- (BCSequence *) theProtein;
{
	return theProtein;
}

- (void)awakeFromNib
{
 // we already create the sequences, so the textviews will be able to filter the input
	[self setTheDNA: [BCSequence sequenceWithString: @"" symbolSet: [BCSymbolSet dnaSymbolSet]]];
	[theInput setDelegate: self];
	[theInput setUnit: @"bp"];
	[theInput setFilter: YES];
	
	[self setTheProtein: [BCSequence sequenceWithString: @"" symbolSet: [BCSymbolSet proteinSymbolSet]]];
	[theOutput setDelegate: self];
	[theOutput setUnit: @"aa"];
	[theOutput setFilter: YES];


	// ANNOTATION TESTS
	/*
	 BCAnnotation *ann1 = [BCAnnotation annotationWithName: @"Organism" content: @"Homo Sapiens"];
	 BCAnnotation *ann2 = [BCAnnotation annotationWithName: @"Species" content: @"Homo Sapiens"];
	 BCAnnotation *annint1 = [BCAnnotation annotationWithName: @"Length" intValue: 18];
	 BCAnnotation *annint2 = [BCAnnotation annotationWithName: @"Length" intValue: 2];
	 BCAnnotation *annfloat = [BCAnnotation annotationWithName: @"Identity" floatValue: 25.5];
	 BCAnnotation *annbool = [BCAnnotation annotationWithName: @"Edited" boolValue: YES];
	 BCAnnotation *annstringint = [BCAnnotation annotationWithName: @"Stringint" content: @"11"];
	 
	 NSLog(@"%@", ann1);
	 
	 NSArray *array = [NSArray arrayWithObjects: ann1, ann2, annint1, annint2, annfloat, annbool, nil];
	 NSLog(@"%@", [array sortedArrayUsingSelector: @selector(sortAnnotationsOnNameAscending:)]);
	 NSLog(@"%@", [array sortedArrayUsingSelector: @selector(sortAnnotationsOnNameDescending:)]);
	 NSLog(@"%@", [array sortedArrayUsingSelector: @selector(sortAnnotationsOnContentAscending:)]);
	 NSLog(@"%@", [array sortedArrayUsingSelector: @selector(sortAnnotationsOnContentDescending:)]);
	 
	 NSLog(@"%@: %f", ann1, [ann1 floatValue]);
	 NSLog(@"%@: %f", ann2, [ann2 floatValue]);
	 NSLog(@"%@: %f", annint1, [annint1 floatValue]);
	 NSLog(@"%@: %f", annint2, [annint2 floatValue]);
	 NSLog(@"%@: %f", annfloat, [annfloat floatValue]);
	 NSLog(@"%@: %f", annbool, [annbool floatValue]);
	 NSLog(@"%@: %f", annstringint, [annstringint floatValue]);
	 
	 NSLog(@"%d", [ann1 isEqualTo: ann2]);
	 NSLog(@"%d", [annint1 isEqualTo: annint2]);
	 NSLog(@"%d", [ann1 isEqualToAnnotation: ann2]);
	 NSLog(@"%d", [annint1 isEqualToAnnotation: annint2]);
	 */
}


//===========================================================================
#pragma mark -
#pragma mark --- IMPORT METHODS
//===========================================================================

- (IBAction)importSequence:(id)sender{
	
    // OPEN
    NSOpenPanel * oPanel = [NSOpenPanel openPanel];
    [oPanel setAllowsMultipleSelection:NO];
    [oPanel setResolvesAliases: YES];
    [oPanel setCanChooseDirectories: NO];
    [oPanel setCanChooseFiles: YES]; 
    NSArray *fileTypes = [NSArray arrayWithObjects: @"text", @"TEXT", @"txt", @"TXT", @"fasta", @"FASTA", @"seq", @"SEQ",
		@"html", @"HTML", @"htm", @"HTM", @"rtf", @"RTF", @"rtfd", @"RTFD", 
		@"gde", @"fas", @"nessig", @"pir", @"nona", @"phylip", @"nexus", 
		@"GDE", @"FAS", @"NESSIG", @"PIR", @"NONA", @"PHYLIP", @"NEXUS", 
		@"raw", @"clustal", @"pdb", @"embl", @"swissprot", @"NCBI", @"GCK",
		@"RAW", @"CLUSTAL", @"PDB", @"EMBL", @"SWISSPROT", @"ncbi", @"gck",
		@"aln", @"hen", @"fst", @"msf", @"nxs", @"non", @"phy", @"tnt", @"ape", 
		@"ALN", @"HEN", @"FST", @"MSF", @"NXS", @"NON", @"PHY", @"TNT", @"APE", @"exdna", 
		NSFileTypeForHFSTypeCode('TEXT'), NSFileTypeForHFSTypeCode('TXT '), 				
		NSFileTypeForHFSTypeCode('text'), 
		NSFileTypeForHFSTypeCode('xDNA'), NSFileTypeForHFSTypeCode('DNA '),
		NSFileTypeForHFSTypeCode('GCKc'), NSFileTypeForHFSTypeCode('GCKs'),
		NSFileTypeForHFSTypeCode('NUCL'), nil];
	
    [oPanel beginSheetForDirectory: nil 
                              file: nil
                             types: fileTypes
                    modalForWindow: window
                     modalDelegate: self
                    didEndSelector: @selector(importPanelDidEnd:returnCode:contextInfo:)
                       contextInfo: nil];
}

- (void)importPanelDidEnd:(NSOpenPanel *)oPanel returnCode:(int)returnCode contextInfo:(void *)contextInfo{
	
    if (returnCode == NSOKButton) {
		
		BCSequenceReader *sequenceReader = [[BCSequenceReader alloc] init];
		
		NS_DURING
			
			BCSequenceArray *sequenceArray = [sequenceReader readFileUsingPath: [[oPanel filenames] objectAtIndex: 0]];			
			
			// HERE FUTURE CHOOSE!
			if([sequenceArray count] > 0)
			{
				[self setTheDNA: [sequenceArray sequenceAtIndex: 0]];
				
				// this is a translation demo, so we can only allow a DNA sequence
				
				if ([[self theDNA] sequenceType] == BCSequenceTypeDNA)
				{
					[theInput setString: [[self theDNA] sequenceString]];
					[theInput updateLayout];
					
					// display the annotations for the sequence
					NSDictionary	*inputAnnotations = [[self theDNA] annotations];
					NSEnumerator	*enumerator = [inputAnnotations keyEnumerator];
					id				key;
					
					while ((key = [enumerator nextObject]))
					{
						NSLog(@"%@", [[inputAnnotations objectForKey: key] description]);
					}
					
					[theComments setStringValue: [NSString stringWithFormat: @"The sequence contains %d nucleotides", [[self theDNA] length]]];
				}
			}
			
			NS_HANDLER
				NSBeep(); 
				NSString *title = @"Error Reading File";			
				NSString *defaultButton = @"OK";
				NSString *alternateButton = nil;
				NSString *otherButton = nil;
				NSString *message = @"Could not read the selected file, which might not be a sequence file or of a format that BioCocoa supports. Try converting it to plain text or fasta format. Alternatively, you can copy the sequence from its native application.";
				
				NSRunAlertPanel(title, message, defaultButton, alternateButton, otherButton);
				
			NS_ENDHANDLER

		 // cleanup	
			[sequenceReader release];
    }     
}

- (IBAction)process:(id)sender
{
	NSString	*inputString = [theInput string];

    if ( [inputString length] == 0)
        return;
    
 // until we have mutable sequences, we re-create the sequence from the string in the BCSequenceView
 // when the process button is pressed. The MW won't be updated until then, so this may need some improvement
 	[self setTheDNA: [BCSequence sequenceWithString: inputString symbolSet: [BCSymbolSet dnaSymbolSet]]];	

//	BCSequence  *reverse = [[self theDNA] reverse];

 // set the begin time
    NSDate *theDate = [NSDate date];

 // BEGIN YOUR IMPLEMENTATION HERE
    
    
 // ADDED THE FOLLOWING FOR PERFORMANCE PROFILING
    
    /*
    NSArray *theReturn;
    int loopCounter;
    BCToolSequenceFinder *theFinder = [BCToolSequenceFinder sequenceFinderWithSequence: [self theDNA]];
    [theFinder setStrict: NO];
    [theFinder setFirstOnly: NO];
    
    BCSequence *findSequence = [BCSequence sequenceWithString: @"GTRYAC" symbolSet: [BCSymbol dnaSymbolSet]];
    theDate = [NSDate date];
    for ( loopCounter = 0; loopCounter < 50; loopCounter++ ) 
        theReturn = [theFinder findSequence: findSequence];

    NSLog( [NSString stringWithFormat: @"ambiguous finding took %f seconds", [theDate timeIntervalSinceNow]] );
    
    theDate = [NSDate date];
    for ( loopCounter = 0; loopCounter < 50; loopCounter++ ) 
        theReturn = [theFinder slow_findSequence: findSequence];
    
    NSLog( [NSString stringWithFormat: @"ambiguous slow finding took %f seconds", [theDate timeIntervalSinceNow]] );
    
    [theFinder setStrict: YES];
    findSequence = [BCSequence sequenceWithString: @"GTATAC" symbolSet: [BCSymbol dnaSymbolSet]];
    theDate = [NSDate date];
    for ( loopCounter = 0; loopCounter < 50; loopCounter++ ) 
        theReturn = [theFinder findSequence: findSequence];
    
    NSLog( [NSString stringWithFormat: @"strict finding took %f seconds", [theDate timeIntervalSinceNow]] );
    
    theDate = [NSDate date];
    for ( loopCounter = 0; loopCounter < 50; loopCounter++ ) 
        theReturn = [theFinder slow_findSequence: findSequence];
    
    NSLog( [NSString stringWithFormat: @"strict slow finding took %f seconds", [theDate timeIntervalSinceNow]] );
    
    return;
     */
    
 // translate the DNA sequence 
	BCToolTranslator *translator = [BCToolTranslator translatorToolWithSequence: [self theDNA]];

 // the defaults for frame and genetic code are fine
	BCSequenceCodon *theCodonSeq = [translator codonTranslation];

    NSLog ( @"%f", [theDate timeIntervalSinceNow] );

//	create a BCSequence using the amino acid string from the translation
	NSRange tempRange = [theCodonSeq longestOpenReadingFrame];
	[self setTheProtein: [theCodonSeq translationOfRange: tempRange]];

 // same thing, now requiring the translation to start at an ATG
//	[self setTheProtein: [theCodonSeq translationOfRange: tempRange usingStartCodon:
//		[BCGeneticCode codon: [BCSequence sequenceWithString: @"ATG"] inGeneticCode: BCUniversalCode]]];

    NSLog ( @"time after translation: %f", [theDate timeIntervalSinceNow] );

 // use a BCToolMassCalculator class to calculate the MW of the DNA.
	BCToolMassCalculator *mwCalculator = [BCToolMassCalculator massCalculatorWithSequence: [self theDNA]];
	[mwCalculator setMassType: BCAverage];
	NSArray * mw = [mwCalculator calculateMass];

    NSLog ( @"time after calculating MW: %f", [theDate timeIntervalSinceNow] );

 // use a BCToolHydropathy class to calculate the hydropathy values of the protein.
//	BCToolHydropathyCalculator *hpCalculator = [BCToolHydropathyCalculator hydropathyCalculatorWithSequence: [self theProtein]];
//	[hpCalculator setHydropathyType: BCKyteDoolittle];
//	NSArray * hp = [hpCalculator calculateHydropathy];
//
//    NSLog ( @"time after calculating hydropathy: %f", [theDate timeIntervalSinceNow] );
//	NSLog ( @"the hydropathy-array is %@", hp );
	
 // use a BCToolSequenceFinder class to search for a sequence
	NSArray *foundIt = [[self theDNA] findSequence: 
				[BCSequence sequenceWithString:@"CNT" symbolSet: [BCSymbolSet dnaSymbolSet]]];

 // display the results in the console	
	NSLog ( @"the found-array is %@", foundIt );
    NSLog ( @"time after searching: %f", [theDate timeIntervalSinceNow] );

	// do some testing for the alignment code
	
//	BCSequence	*first = [BCSequence sequenceWithString:@"TGCATAT" symbolSet: [BCSymbol dnaSymbolSet]];
//	BCSequence	*second = [BCSequence sequenceWithString:@"ATCCGAT" symbolSet: [BCSymbol dnaSymbolSet]];
//	
//	BCSequenceAlignment	*alignArray = [BCSequenceAlignment needlemanWunschAlignmentWithSequences:
//							[NSArray arrayWithObjects: first, second, nil] properties: nil];
//
//	NSLog ( @"the first alignment sequence is %@", [alignArray sequenceAtIndex:0] );
//	NSLog ( @"the second alignment sequence is %@", [alignArray sequenceAtIndex:1] );
	

 // END
    
 // now we can update the widgets in the window
    [theOutput setString: [[self theProtein] sequenceString]];
    [theOutput updateLayout];
    
    [theDuration setStringValue: [NSString stringWithFormat: @"%.3fs", [theDate timeIntervalSinceNow] * -1]];

	float min = [[mw objectAtIndex:0] floatValue];
	float max = [[mw objectAtIndex:1] floatValue];
	
	if ( min == max )
		[theMW setStringValue: [NSString stringWithFormat: @"and has a MW of %.1f", min/1000]];
	else
		[theMW setStringValue: [NSString stringWithFormat: @"and has a MW ranging from %.1f to %.1f kDa", min/1000, max/1000 ]];
}


- (void)textDidChange:(NSNotification *)aNotification
{
    if ([aNotification object] == theInput)
    {
        [theInput updateLayout];
    } 
    else if ([aNotification object] == theOutput)
    {
        [theOutput updateLayout];
    }
}


- (NSString *)filterInputString: (NSString *) inputString textView: (BCSequenceView *)textView
{
	BCSymbolSet	*symbolSet;

	if ( textView == theInput )
	{	
		symbolSet = [theDNA symbolSet];
		return [symbolSet stringByRemovingUnknownCharsFromString: inputString];
	}
	else if (textView == theOutput)
	{
		symbolSet = [theProtein symbolSet];
		return [symbolSet stringByRemovingUnknownCharsFromString: inputString];
	}
	
	return inputString;
}


@end
