//
//  BCToolTranslator.m
//  BioCocoa
//
//  Created by John Timmer on 8/29/04.
//  Copyright 2004 The BioCocoa Project. All rights reserved.
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


#import "BCToolTranslator.h"
#import "BCNucleotideDNA.h"
#import "BCAminoAcid.h"
#import "BCSequence.h"
#import "BCSequenceCodon.h"
#import "BCCodonDNA.h"
#import "BCGeneticCode.h"

@implementation BCToolTranslator

- (BCToolTranslator *) initWithSequence: (BCSequence *)list {
	self = [super initWithSequence: list];

	// set some defaults
	if ( self != nil ) {
		readingFrame = 1;
		codeName = BCUniversalCode;
	}
	
	return self;
}


- (int) readingFrame {
	return readingFrame;
}


- (void) setReadingFrame: (int)theFrame {
	// this has got to be between -3 and 3, skipping 0.
	// we default to 1
	if ( theFrame > 3 || theFrame == 0 )
		readingFrame = 1;
	else if ( theFrame < -3 )
		readingFrame = -1;
	else
		readingFrame = theFrame;
}


- (BCGeneticCodeName) codeName {
	return codeName;
}


- (void)setCodeName: (BCGeneticCodeName)aName {
	codeName = aName;	
}


+ (BCToolTranslator *) translatorToolWithSequence: (BCSequence *)list {
     BCToolTranslator *translatorTool = [[BCToolTranslator alloc] initWithSequence: list];
     
	 return [translatorTool autorelease];
}

- (BCSequenceCodon *) codonTranslation {
	// check for the right kind of sequence
	if ( [sequence sequenceType] != BCSequenceTypeDNA && [sequence sequenceType] != BCSequenceTypeRNA )
		return nil;

	// next, grab the genetic code
    NSArray *theCode = [BCGeneticCode geneticCode: codeName forSequenceType: [sequence sequenceType]];
    if ( theCode == nil || [theCode count] == 0 )
        return nil;
    
	// adjust the sequence to reflect the desired frame
	BCSequence *tempSequence;
	if ( readingFrame < 0 )
		tempSequence = [sequence reverse];
	else tempSequence = sequence;
	
	NSArray *theSequenceArray;
	if ( abs( readingFrame ) == 1 )
		theSequenceArray = [tempSequence symbolArray];
	else if (  abs( readingFrame ) == 2 )
		theSequenceArray = [tempSequence subSymbolArrayInRange: NSMakeRange( 1, [sequence length] - 1) ];
	else
		theSequenceArray = [tempSequence subSymbolArrayInRange: NSMakeRange( 2, [sequence length] - 2) ];
		
    int codonCount = [theCode count];
    int loopCounter, innerCounter;
    NSMutableArray *returnArray = [NSMutableArray array];
    NSArray *tempCodon;
    BCCodonDNA *aCodon;
    BOOL oneMatch;

    for ( loopCounter = 0 ; loopCounter + 2 < [sequence length] ; loopCounter = loopCounter + 3 ) {
        tempCodon = [theSequenceArray subarrayWithRange: NSMakeRange( loopCounter, 3 ) ];
        oneMatch = NO;
        
        for ( innerCounter = 0 ; innerCounter < codonCount ; innerCounter++ ) {
            aCodon = [theCode objectAtIndex: innerCounter];
            if ( [aCodon matchesTriplet: tempCodon] ) {
                [returnArray addObject: aCodon];
                oneMatch = YES;
                break;
            }
        }
        
        if ( !oneMatch )
            [returnArray addObject: [BCCodonDNA unmatched]];
    }
    
	NSString *frameRep;
	if ( readingFrame > 0 )
		frameRep = [NSString stringWithFormat: @"+%i", readingFrame];
	else 
		frameRep = [NSString stringWithFormat: @"-%i", readingFrame];
	
    return [[[BCSequenceCodon alloc] initWithCodonArray: returnArray geneticCode: codeName frame: frameRep] autorelease];
	
}
	
- (NSDictionary *) allCodonTranslations {
	// we hang onto the frame that's set because we're going to change it repeatedly
	int holdingInt = readingFrame;
	int loopCounter = -4;
	NSMutableDictionary *theReturn = [NSMutableDictionary dictionary];
	BCSequenceCodon *codonSequence;
	while ( loopCounter < 3) {
		loopCounter++;
		if ( loopCounter == 0 )
			loopCounter++;
		readingFrame = loopCounter;
		codonSequence = [self codonTranslation];
		[theReturn setObject: codonSequence forKey: [codonSequence readingFrame]];
	}
	
	readingFrame = holdingInt;
	return theReturn;
}


@end

