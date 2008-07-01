//
//  BCSequenceCodon.m
//  BioCocoa
//
//  Created by John Timmer on 9/17/04.
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

#import "BCSequenceCodon.h"
//#import "BCNucleotideDNA.h"
//#import "BCSequenceProtein.h"
//#import "BCSequenceDNA.h"
//#import "BCSequenceRNA.h"
#import "BCSequence.h"
#import "BCSymbolSet.h"
#import "BCCodonRNA.h"
#import "BCCodonDNA.h"
#import "BCAminoAcid.h"
#import "BCToolTranslator.h"
//#import "BCFoundationDefines.h"

#import "BCInternal.h"

@implementation BCSequenceCodon


////////////////////////////////////////////////////////////////////////////
#if 0
#pragma mark ‚ 
#pragma mark ‚INITIALIZATION METHODS
#endif
//  INITIALIZATION METHODS
////////////////////////////////////////////////////////////////////////////


//designated initializer
- (id)initWithCodonArray:(NSArray *)anArray geneticCode: (BCGeneticCodeName)codeType frame: (NSString *)theFrame {
  if ( (self = [super init]) )
    {
        symbolArray = [[NSMutableArray alloc] init];
        
	DECLARE_INDEX(loopCounter);
        int theLimit = [anArray count];
        id aCodon;
        
        for ( loopCounter = 0 ; loopCounter < theLimit ; loopCounter++ ) {
	  aCodon = (id)ARRAY_GET_VALUE_AT_INDEX(anArray, loopCounter);
	  if ( [aCodon isKindOfClass: [BCCodon class]] )
	    ARRAY_APPEND_VALUE((NSMutableArray *)symbolArray, aCodon);
        }
        
        int testInt = [theFrame intValue];
        if ( testInt == 0 || testInt > 3 || testInt < -3 )
            readingFrame = @"+1";
        else    
            readingFrame = [theFrame copy];
        usedCode = codeType;

		// fill the NSData buffer with the contents of the array of symbols
		sequenceData = [[[self sequenceStringFromSymbolArray: symbolArray] 
							dataUsingEncoding: NSUTF8StringEncoding] retain];
    }
    
    return self;
}

- (id)initWithString:(NSString *)aString skippingUnknownSymbols:(BOOL)skipFlag;
{
	NSMutableString *converted;
	BCSequence *aDNASequence;
	
	//replace uraciles with thymidines
	converted = [NSMutableString stringWithString:aString];
	[converted replaceOccurrencesOfString:@"u"
							   withString:@"T"
								  options:NSCaseInsensitiveSearch
									range:NSMakeRange( 0, [converted length])];
	
	//create a new sequence and use for translation
	aDNASequence=[BCSequence sequenceWithString:aString symbolSet: [BCSymbolSet dnaSymbolSet]];
	// defaults on this are fine
	id theTranslator = [[[BCToolTranslator alloc] initWithSequence:aDNASequence] autorelease];
	
	// fill the NSData buffer with the contents of the NSString
	sequenceData = [[converted dataUsingEncoding: NSUTF8StringEncoding] retain];
	
	// have the tool create the translation
    return [theTranslator codonTranslation];    
}


- (id)initWithSymbolArray:(NSArray *)anArray
{
	BCSequence *aSequence = [BCSequence sequenceWithSymbolArray:anArray];
	
	return [self initWithString: [aSequence sequenceString] skippingUnknownSymbols:YES];
}

- (id)initWithCodonArray:(NSArray *)anArray
{
	return [self initWithCodonArray:anArray geneticCode: BCUniversalCode frame:@"+1"];
}

+ (BCSequenceCodon *)sequenceWithCodonArray:(NSArray *)anArray
{
	return [[[[self class] alloc] initWithCodonArray:anArray] autorelease];
}

//needed for initializations
//overriding the superclass
- (BCSequenceType) sequenceType
{
	return BCSequenceTypeDNA;
}


// convenience methods for translation

- (BCSequence *)translate
{
	return [self translationOfRange: [self longestOpenReadingFrame]];
}


////////////////////////////////////////////////////////////////////////////
#if 0
#pragma mark ‚
#pragma mark ‚ORF/TRANSLATION METHODS
#endif
//  ORF/TRANSLATION METHODS
////////////////////////////////////////////////////////////////////////////

- (NSRange) longestOpenReadingFrame {
    NSArray *theRanges = [self openReadingFramesLongerThanCutoff: 5];
	NSRange tempRange;
	NSRange holdingRange = NSMakeRange (0, 1);
	int loopCounter;
	for (loopCounter = 0; loopCounter < [theRanges count]; loopCounter++ ) {
		tempRange = [[theRanges objectAtIndex: loopCounter] rangeValue];
		if ( tempRange.length > holdingRange.length )
			holdingRange = tempRange;
	}
	
    return holdingRange;
}

- (NSRange) longestOpenReadingFrameUsingStartCodon: (id)codon {
    NSArray *startArray;
    // we could have been fed a codon or an array of codons - we'll make an array of either
    if ( ![codon isKindOfClass: [NSArray class]] ) {
        if ( [codon isKindOfClass: [BCCodon class]] )
            startArray = [NSArray arrayWithObject: codon];
        else
            return NSMakeRange( NSNotFound, 0);
    }
    else
        startArray = codon;
    
    int maxLength = 0;
    int startOfMax = 0;
    int startPos = 0;
    int theLength = 0;
    BOOL inORF = NO;
    DECLARE_INDEX(loopCounter);
    int theLimit = [symbolArray count];
    id aCodon, anAA;
    BCAminoAcid *noAA = [BCAminoAcid undefined];
    
    for ( loopCounter = 0 ; loopCounter < theLimit ; loopCounter++ ) {
      aCodon = (id)ARRAY_GET_VALUE_AT_INDEX(symbolArray, loopCounter);
        anAA = [aCodon codedAminoAcid];
        // if we're in an ORF, we can either terminate it or extend it
        if ( inORF ) {
            if ( anAA == nil || anAA == noAA ) {
            // end the ORF
                inORF = NO;
                if ( theLength > maxLength ) {
                    startOfMax = startPos;
                    maxLength = theLength;
                }
                theLength = 0;
            }
            else {
                theLength++;
            }
        }
        // otherwise, we look to start an ORF
        else {
            // see if our codon shows up in the array of start codons
	  if ( ARRAY_RANGE_CONTAINS_VALUE(startArray, MAKE_RANGE(0, ARRAY_GET_COUNT(startArray)), aCodon) ) {
                startPos = loopCounter;
                inORF = YES;
            }
        }
    }
    
    return NSMakeRange( startOfMax, maxLength);
}



- (NSArray *) openReadingFramesLongerThanCutoff: (unsigned int)cutoff usingStartCodon: (id)codon { 
    NSArray *startArray;
    // we could have been fed a codon or an array of codons - we'll make an array of either
    if ( ![codon isKindOfClass: [NSArray class]] ) {
        if ( [codon isKindOfClass: [BCCodon class]] )
            startArray = [NSArray arrayWithObject: codon];
        else
            return nil;
    }
    else
        startArray = codon;
    
    int startPos = 0;
    int theLength = 0;
    BOOL inORF = NO;
    DECLARE_INDEX(loopCounter);
    int theLimit = [symbolArray count];
    id aCodon, anAA;
    BCAminoAcid *noAA= [BCAminoAcid undefined];
    NSMutableArray *theReturn = [NSMutableArray array];
    
    for ( loopCounter = 0 ; loopCounter < theLimit ; loopCounter++ ) {
        aCodon = (id)ARRAY_GET_VALUE_AT_INDEX(symbolArray, loopCounter);
        anAA = [aCodon codedAminoAcid];
        // if we're in an ORF, we can either terminate it or extend it
        if ( inORF ) {
            if ( anAA == nil || anAA == noAA ) {
            // end the ORF
                inORF = NO;
                if ( theLength > cutoff ) 
                    [theReturn addObject: [NSValue valueWithRange: NSMakeRange(startPos, theLength)]];
                theLength = 0;
            }
            else {
                theLength++;
            }
        }
        // otherwise, we look to start an ORF
        else {
            // see if our codon shows up in the array of start codons
	  if ( ARRAY_RANGE_CONTAINS_VALUE(startArray, MAKE_RANGE(0, ARRAY_GET_COUNT(startArray)), aCodon) ) {
                startPos = loopCounter;
                inORF = YES;
            }
        }
    }

    
    return [[theReturn copy] autorelease];
}



- (NSArray *) openReadingFramesLongerThanCutoff: (unsigned int)cutoff {
    if (cutoff > [self length] )
        return nil;
    
    int startPos = 0;
    int theLength = 0;
    BOOL inORF;
    DECLARE_INDEX(loopCounter);
    int theLimit = [symbolArray count];
    id aCodon, anAA;
    BCAminoAcid *noAA= [BCAminoAcid undefined];
    NSMutableArray *theReturn = [NSMutableArray array];
    
    for ( loopCounter = 0 ; loopCounter < theLimit ; loopCounter++ ) {
        aCodon = (id)ARRAY_GET_VALUE_AT_INDEX(symbolArray, loopCounter);
        anAA = [aCodon codedAminoAcid];
        if ( anAA == nil || anAA == noAA ) {
            // end the ORF
            inORF = NO;
            if ( theLength > cutoff ) 
                [theReturn addObject: [NSValue valueWithRange: NSMakeRange(startPos, theLength)]];
            theLength = 0;
        }
        else {
            if ( inORF )
                theLength++;
            else {
                startPos = loopCounter;
                inORF = YES;
            }
        }
        
    }
    return [[theReturn copy] autorelease];
}


- (BCSequence *) translationOfRange: (NSRange) theRange {
    int theLimit = [symbolArray count];
    if (theRange.length + theRange.location > theLimit )
        return nil; 
    
    NSArray *subsequence = [symbolArray subarrayWithRange: theRange];
    theLimit = [subsequence count];
    DECLARE_INDEX(loopCounter);
    BCAminoAcid *anAA;
    BCAminoAcid *noAA= [BCAminoAcid undefined];
    NSMutableArray *theReturn = [NSMutableArray array];
    for ( loopCounter = 0 ; loopCounter < theLimit ; loopCounter++ ) {
        anAA = [(BCCodon *)ARRAY_GET_VALUE_AT_INDEX(subsequence, loopCounter) codedAminoAcid];
        if ( anAA == nil || anAA == noAA ) 
            return [BCSequence sequenceWithSymbolArray: theReturn];
        else
	  ARRAY_APPEND_VALUE(theReturn, anAA);
    }
    
    return [BCSequence sequenceWithSymbolArray: theReturn symbolSet: [BCSymbolSet proteinSymbolSet]];
}



- (BCSequence *) translationOfRange: (NSRange) theRange usingStartCodon: (id)codon {
    int theLimit = [symbolArray count];
    if (theRange.length + theRange.location > theLimit )
        return nil;
    
    NSArray *startArray;
    if ( ![codon isKindOfClass: [NSArray class]] ) {
        if ( [codon isKindOfClass: [BCCodon class]] )
            startArray = [NSArray arrayWithObject: codon];
        else
            return nil;
    }
    else
        startArray = codon;
    
    NSArray *subsequence = [symbolArray subarrayWithRange: theRange];
    theLimit = [subsequence count];
    
    DECLARE_INDEX(loopCounter);
    BCCodon *aCodon;
    BOOL foundStart = NO;
    for ( loopCounter = 0 ; loopCounter < theLimit ; loopCounter++ ) {
        aCodon = (BCCodon *)ARRAY_GET_VALUE_AT_INDEX(subsequence, loopCounter);
	if ( ARRAY_RANGE_CONTAINS_VALUE(startArray, MAKE_RANGE(0, ARRAY_GET_COUNT(startArray)), aCodon) ) {
			foundStart = YES;
            break;
		}
    }
    
    if ( !foundStart )
        return nil;
    
    return [self translationOfRange: NSMakeRange( theRange.location + loopCounter, theRange.length - loopCounter)];
}


- (NSArray *) translationsLongerThanCutoff: (unsigned int)cutoff {
    NSArray *theRanges = [self openReadingFramesLongerThanCutoff: cutoff];
    NSMutableArray *theReturn = [NSMutableArray array];
    
    DECLARE_INDEX(loopCounter);
    BCSequence *aTranslation;
    NSRange aRange;
    int theLimit = [theRanges count];
    for ( loopCounter = 0 ; loopCounter < theLimit ; loopCounter++ ) {
        aRange = [(NSValue *)ARRAY_GET_VALUE_AT_INDEX(theRanges, loopCounter) rangeValue];
        aTranslation = [self translationOfRange: aRange];
        if ( aTranslation != nil )
	  ARRAY_APPEND_VALUE(theReturn, aTranslation);
    }
    
    return [[theReturn copy] autorelease];
}



- (NSArray *) translationsLongerThanCutoff: (unsigned int)cutoff usingStartCodon: (id)codon {
    
    NSArray *theRanges = [self openReadingFramesLongerThanCutoff: cutoff];
    NSMutableArray *theReturn = [NSMutableArray array];
    
    DECLARE_INDEX(loopCounter);
    BCSequence *aTranslation;
    NSRange aRange;
    int theLimit = [theRanges count];
    for ( loopCounter = 0 ; loopCounter < theLimit ; loopCounter++ ) {
        aRange = [(NSValue *)ARRAY_GET_VALUE_AT_INDEX(theRanges, loopCounter) rangeValue];
        aTranslation = [self translationOfRange: aRange usingStartCodon: codon];
        if ( aTranslation != nil )
	  ARRAY_APPEND_VALUE(theReturn, aTranslation);
    }
    
    return [[theReturn copy] autorelease];
}





////////////////////////////////////////////////////////////////////////////
#if 0
#pragma mark ‚
#pragma mark ‚BASIC INFO
#endif
//  BASIC INFO
////////////////////////////////////////////////////////////////////////////

- (BCGeneticCodeName) usedCode {
    return usedCode;
}



- (NSString *)readingFrame {
    return [[readingFrame copy] autorelease];
}


- (NSRange) convertRangeToOriginalSequence: (NSRange)entry {
    int rfValue = [readingFrame intValue];
    if ( rfValue > 0 ) {
        rfValue = rfValue - 1;
        return NSMakeRange( (entry.location * 3) + rfValue, (entry.length * 3) );
    }
    
    rfValue = rfValue + 1;
    return NSMakeRange( ( ([self length] * 3) - ((entry.length * 3) + entry.location + rfValue) ), entry.length * 3 );
}


@end
