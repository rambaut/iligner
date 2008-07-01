//
//  BCSequence.m
//  BioCocoa
//
//  Created by Koen van der Drift on 12/14/2004.
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

#import "BCSequence.h"
#import "BCAnnotation.h"
#import "BCFoundationDefines.h"
#import "BCSymbol.h"
#import "BCAminoAcid.h"
#import "BCSymbolSet.h"
#import "BCToolSequenceFinder.h"
#import "BCToolComplement.h"
#import "BCUtilData.h"

#import "BCInternal.h"

@implementation BCSequence

// TODO:

// MOVE MUTABLE METHODS TO ...

// UPDATE THE REVERSE METHOD - SHOULD THIS BE DONE STRING-BASED?

// UPDATE MORE HEADERDOC INFORMATION

// LOOK AGAIN AT SYMBOLATINDEX METHOD

// ADD METHODS FOR NSDATA <-> NSSTRING CONVERSIONS, PROBABLY NOT IN THIS CLASS

// FIX COMPILER WARNINGS

// ....

////////////////////////////////////////////////////////////////////////////
#if 0
#pragma mark â  
#pragma mark â INITIALIZATION METHODS
#endif
//
//  INITIALIZATION METHODS
////////////////////////////////////////////////////////////////////////////

// designated initializer
- (id)initWithString:(NSString *)aString symbolSet:(BCSymbolSet *)aSet
{	
    if ( (self = [super init]) )
    {
		if ( aString != nil )
		{ 
			if ( aSet == nil )
			{
				aSet = [BCSymbolSet symbolSetForSequenceType: [self sequenceTypeForString: aString]];
			}

		 //let the set check the chars
			NSString *finalString = [aSet stringByRemovingUnknownCharsFromString: aString];

		 // fill the NSData buffer with the contents of the NSString
			sequenceData = [[finalString dataUsingEncoding: NSUTF8StringEncoding] retain];
		}
		else
		{
			sequenceData = nil;
		}
		
		symbolSet = [aSet retain];
		sequenceType = [aSet sequenceType];

		annotations = nil;
		symbolArray = nil;
	}
	
	return self;
}

- (id)initWithData:(NSData *)aData symbolSet:(BCSymbolSet *)aSet
{	
  if ( (self = [super init]) ) {
		if ( aData != nil ) {
			if ( aSet == nil ) {
				aSet = [BCSymbolSet symbolSetForSequenceType: [self sequenceTypeForData: aData]];
			}
      
      // let the set check the chars
      sequenceData = [aSet dataByRemovingUnknownCharsFromData: aData];
			[sequenceData retain];
		} else {
			sequenceData = nil;
		}
		
		symbolSet = [aSet retain];
		sequenceType = [aSet sequenceType];
    
		annotations = nil;
		symbolArray = nil;
	}
	
	return self;
}

- (id)initWithSymbolArray:(NSArray *)anArray symbolSet:(BCSymbolSet *)aSet
{
    if ( (self = [super init]) )
    {           
		if ( aSet==nil )
		{
			aSet = [BCSymbolSet symbolSetForSequenceType: [self sequenceTypeForSymbolArray: anArray]];
		}
		
	  //let the set check the symbols

		NSArray *finalArray=[aSet arrayByRemovingUnknownSymbolsFromArray:anArray];
		symbolArray=[[NSMutableArray alloc] initWithArray:finalArray];
					
	 // fill the NSData buffer with the contents of the array of symbols
		sequenceData = [[[self sequenceStringFromSymbolArray: symbolArray] 
							dataUsingEncoding: NSUTF8StringEncoding] retain];

		symbolSet=[aSet retain];
		annotations=nil;
		sequenceType = [symbolSet sequenceType];
    }

    return self;
}

- (id)initWithSymbolArray:(NSArray *)anArray
{
    return [self initWithSymbolArray:anArray symbolSet: nil];
}

// returns an empty sequence by calling the designated initializer
- (id)init
{    
    return [self initWithString:[NSString string] symbolSet:[BCSymbolSet unknownSymbolSet]];
}

- (id)initWithString:(NSString*)aString
{
    return [self initWithString:aString symbolSet: nil];
}

- (id)initWithString:(NSString*)aString range:(NSRange)aRange
{
    return [self initWithString:[aString substringWithRange:aRange]];
}

- (id)initWithString:(NSString*)aString range:(NSRange)aRange symbolSet:(BCSymbolSet *)aSet
{
    return [self initWithString:[aString substringWithRange:aRange] symbolSet: aSet];
}

- (id)initWithThreeLetterString:(NSString*)aString symbolSet:(BCSymbolSet *)aSet
{
    return [self initWithString:
					[self convertThreeLetterStringToOneLetterString: aString symbolSet: aSet] symbolSet: aSet];
}

+ (BCSequence *)sequenceWithString: (NSString *)aString
{
	return [[[BCSequence alloc] initWithString:aString] autorelease];
}

+ (BCSequence *)sequenceWithString:(NSString *)aString symbolSet:(BCSymbolSet *)aSet
{
	return [[[BCSequence alloc] initWithString:aString symbolSet:aSet] autorelease];
}

+ (BCSequence *)sequenceWithThreeLetterString:(NSString *)aString symbolSet:(BCSymbolSet *)aSet
{	
	return [[[BCSequence alloc] initWithThreeLetterString: aString symbolSet:aSet] autorelease];
}

+ (BCSequence *)sequenceWithSymbolArray:(NSArray *)entry 
{
	return [[[BCSequence alloc] initWithSymbolArray:entry] autorelease];
}

+ (BCSequence *)sequenceWithSymbolArray:(NSArray *)entry symbolSet: (BCSymbolSet *)aSet;
{
	return [[[BCSequence alloc] initWithSymbolArray:entry symbolSet: aSet] autorelease];
}

+ (BCSequence *) objectForSavedRepresentation: (NSString *)aSequence 
{
	return [[[BCSequence alloc] initWithString: aSequence] autorelease];
}

- (NSString *)convertThreeLetterStringToOneLetterString:(NSString *)aString symbolSet: (BCSymbolSet *)aSet
{
	int				i;
	NSArray			*anArray = [aString componentsSeparatedByString:@" "];
	NSString		*oneLetterCode, *threeLetterCode;
	NSMutableString	*convertedString = [[NSMutableString alloc] initWithString: @""];
	
	// build a temporary dictionary with the one-letter code as objects and the three-letter code as keys
	// the easiest seems to use a symbolset and iterate over all the symbols
	// for now only works for amino acids. However, if 3-letter codes are also available
	// for nucleotides, the code can be extended to use BCSymbol. That means that the ivar threeLetterCode 
	// should be moved to BCSymbol from BCAminoAcid
	
	NSArray			*symArray = [[BCSymbolSet proteinSymbolSet] allSymbols];
	BCAminoAcid		*symbol;
	
	NSMutableDictionary	*symbolDict = [NSMutableDictionary dictionaryWithCapacity: [symArray count]];
	
	for (i = 0; i < [symArray count]; i++)
	{
		symbol = [symArray objectAtIndex: i];
		[symbolDict setObject: [symbol symbolString] forKey: [symbol threeLetterCode]];
	}
	
	// now we have the temp symbolDict, iterate over the sequence (in 3-letter code)
	// and create a new string using the 1-letter code
	
	for (i = 0; i < [anArray count]; i++)
	{
		threeLetterCode = [anArray objectAtIndex: i];
		oneLetterCode = [symbolDict objectForKey: [threeLetterCode capitalizedString]];
		
		if ( oneLetterCode )
		{
			[convertedString appendString: oneLetterCode];
		}
	}
	
	return [convertedString autorelease]; 
}


// BCSequence is immutable, no need to copy anything just retain and return self
- (id)copyWithZone:(NSZone *)zone
{
	return [self retain];
}

- (void)dealloc
{
	[sequenceData release];
	[symbolSet release];
	[annotations release];

	[self clearSymbolArray];
	[super dealloc];
}


////////////////////////////////////////////////////////////////////////////
#if 0
#pragma mark â  
#pragma mark â SEQUENCE TYPE DETERMINATION
#endif
//
//  INFORMATIONAL METHODS
////////////////////////////////////////////////////////////////////////////

// This method guesses the sequence type based on a string.
// The method creates new sequences of the different types
//	and checks which one results in the longer sequence,
//	which is also the one having the lowest number of unknown symbols.
- (BCSequenceType)sequenceTypeForString:(NSString *)string
{
	// bestSequenceType = best sequence type so far
	// bestSymbolCount = the length of the best sequence type so far
	BCSequence *testSequence;
	BCSequenceType bestSequenceType;
	unsigned int bestSymbolCount;
	
	// use a DNA sequence to initialize the values of bestSequenceType and bestSymbolCount
	testSequence=[BCSequence sequenceWithString:string symbolSet: [BCSymbolSet dnaSymbolSet]];
	bestSequenceType=BCSequenceTypeDNA;
	bestSymbolCount=[testSequence length];
	
	// test RNA sequence
	testSequence=[BCSequence sequenceWithString:string symbolSet: [BCSymbolSet rnaSymbolSet]];
	if ([testSequence length]>bestSymbolCount) {
		bestSequenceType=BCSequenceTypeRNA;
		bestSymbolCount=[testSequence length];
	}
	
	// test Protein sequence
	testSequence=[BCSequence sequenceWithString:string symbolSet: [BCSymbolSet proteinSymbolSet]];
	if ([testSequence length]>bestSymbolCount) {
		bestSequenceType=BCSequenceTypeProtein;
		bestSymbolCount=[testSequence length];
	}
	
	//TO DO: is it a BCSequenceCodon?
	// * symbols = DNA or RNA > protein
	// * length = multiple of three
	// * first 3 letters = ATG / AUG
	// * no stop codon, except at the end
	
	return bestSequenceType;
}

// This method guesses the sequence type for data
- (BCSequenceType)sequenceTypeForData:(NSData *)aData
{
  unsigned char *seqData = (unsigned char *)[aData bytes];
  unsigned i, len = [aData length];

  // hopefully can determine in first 10,000 symbols
  if (len > 10000) len = 10000;

  BCSymbolSet *dna = [BCSymbolSet dnaSymbolSet];
  BCSymbolSet *rna = [BCSymbolSet rnaSymbolSet];
  BCSymbolSet *prot = [BCSymbolSet proteinSymbolSet];
  unsigned dnaCount = 0, rnaCount = 0, protCount = 0;

	// bestSequenceType = best sequence type so far
	// bestSymbolCount = the length of the best sequence type so far
	BCSequenceType bestSequenceType;
	
	// use a DNA sequence to initialize the values of bestSequenceType and bestSymbolCount
  for (i = 0; i < len; ++i) {
    if ([dna symbolForChar: seqData[i]]) ++dnaCount;
    if ([rna symbolForChar: seqData[i]]) ++rnaCount;
    if ([prot symbolForChar: seqData[i]]) ++protCount;
  }

  // Note that the DNA and RNA symbols is a subset of protein symbols
  // so assume DNA/RNA and only use protein if count is higher
  if (dnaCount > rnaCount) {
    if (protCount > dnaCount) {
      bestSequenceType = BCSequenceTypeProtein;
    } else {
      bestSequenceType = BCSequenceTypeDNA;
    }
  } else {
    if (protCount > rnaCount) {
      bestSequenceType = BCSequenceTypeProtein;
    } else {
      bestSequenceType = BCSequenceTypeRNA;
    }
  }
    
	//TO DO: is it a BCSequenceCodon?
	// * symbols = DNA or RNA > protein
	// * length = multiple of three
	// * first 3 letters = ATG / AUG
	// * no stop codon, except at the end
	
	return bestSequenceType;
}


// This method guesses the sequence type based on an NSArray of BCSymbol.
// The method creates new sequences of the different types
//	and checks which one results in the longer sequence,
//	which is also the one having the lowest number of unknown symbols.
- (BCSequenceType)sequenceTypeForSymbolArray:(NSArray *)anArray;
{
	// bestSequenceType = best sequence type so far
	// bestSymbolCount = the length of the best sequence type so far
	BCSequence *testSequence;
	BCSequenceType bestSequenceType;
	unsigned int bestSymbolCount;
	
	// use DNA sequence to initialize the values of bestSequenceType and bestSymbolCount
	testSequence=[BCSequence sequenceWithSymbolArray:anArray symbolSet: [BCSymbolSet dnaSymbolSet]];
	bestSequenceType=BCSequenceTypeDNA;
	bestSymbolCount=[testSequence length];
	
	// test RNA sequence
	testSequence=[BCSequence sequenceWithSymbolArray:anArray symbolSet: [BCSymbolSet rnaSymbolSet]];
	if ([testSequence length]>bestSymbolCount) {
		bestSequenceType=BCSequenceTypeRNA;
		bestSymbolCount=[testSequence length];
	}
	
	// test protein sequence
	testSequence=[BCSequence sequenceWithSymbolArray:anArray symbolSet: [BCSymbolSet proteinSymbolSet]];
	if ([testSequence length]>bestSymbolCount) {
		bestSequenceType=BCSequenceTypeProtein;
		bestSymbolCount=[testSequence length];
	}
	
	//TO DO: is it a BCSequenceCodon?
	// * symbols = DNA or RNA > protein
	// * length = multiple of three
	// * first 3 letters = ATG / AUG
	// * no stop codon, except at the end
	
	return bestSequenceType;
}


////////////////////////////////////////////////////////////////////////////
#if 0
#pragma mark â  
#pragma mark â OBTAINING SEQUENCE INFORMATION
#endif
//
//  INFORMATIONAL METHODS
////////////////////////////////////////////////////////////////////////////

- (NSData *) sequenceData
{
	return sequenceData;
}

- (const unsigned char *) bytes
{
	return (const unsigned char *)[[self sequenceData] bytes];
}


- (BCSymbolSet *)symbolSet
{
	return symbolSet;
}


// we can now allow to modify a symbolset, eg from strict -> non strict

- (void)setSymbolSet:(BCSymbolSet *)set
{
	[set retain];
	[symbolSet release];
	symbolSet = set;
}


- (BCSequenceType)sequenceType
{
    return sequenceType;
}

// should this be commented out?
/*
- (void) setSequenceType:(BCSequenceType)aType
{
	sequenceType = aType;
}
*/

- (unsigned int) length
{
    return [[self sequenceData] length];
}


- (BCSymbol *)symbolAtIndex: (int)theIndex 
{
	if ( theIndex < [self length] )
	{
		BCSymbol	*aSymbol;
	
#if 1
		unsigned char	c = [[self sequenceData] charAtIndex: theIndex];
		aSymbol = [[self symbolSet] symbolForChar: c];
#else
	// or maybe use getBytes - not faster according to reply on CocoaDev-list
	
		unsigned char buffer;
		
		[[self sequenceData] getBytes: &buffer range: NSMakeRange( theIndex, 1 )];
		aSymbol = [[self symbolSet] symbolForChar: buffer];
		
#endif
		return aSymbol;
	}
	
	return nil;
}


- (BOOL) containsAmbiguousSymbols {    
    BCSymbol *aSymbol;
    DECLARE_INDEX(loopCounter);
    int theLimit = [symbolArray count];
    
    for ( loopCounter = 0 ; loopCounter < theLimit ; loopCounter++ ) {
        aSymbol = (BCSymbol *)ARRAY_GET_VALUE_AT_INDEX(symbolArray, loopCounter);
        if ( [aSymbol isCompoundSymbol] )
            return YES;
    }
    
    return NO;
}

- (NSArray *)symbolArray
{	
	if ( sequenceData == nil )
	{
		return nil;
	}
	
    if ( symbolArray == nil )
	{
	 // creates a symbol array from the NSData sequence

		const unsigned char	*data;
		unsigned int		i, len;
		BCSymbol			*aSymbol;

		data = [self bytes];
		len = strlen((char *)data);
		
		NSMutableArray *anArray = [NSMutableArray array];

		for (i = 0; i < len; i++)
		{
		  if ( (aSymbol = [[self symbolSet] symbolForChar: data[i]]) )
			{
				[anArray addObject: aSymbol];
			}
		}

		symbolArray = [[NSArray alloc] initWithArray: anArray];
	}
	
    return symbolArray;
}


- (void)clearSymbolArray
{
    [symbolArray release];
    symbolArray = nil;
}


// TO DO : use BCSymbolSet for filtering
// DO WE STILL NEED THIS METHOD ??

- (void) setSymbolArray: (NSArray *) anArray
{
    [symbolArray release];
    symbolArray = [[NSMutableArray alloc] init];
    
    id		aSymbol;
    DECLARE_INDEX(loopCounter);
    int		theLimit = [anArray count];
    
    for ( loopCounter = 0 ; loopCounter < theLimit ; loopCounter++ ) {
      aSymbol = (id)ARRAY_GET_VALUE_AT_INDEX(anArray, loopCounter);
      ARRAY_APPEND_VALUE((NSMutableArray *)symbolArray, aSymbol);
    }
}


- (NSArray *)subSymbolArrayInRange:(NSRange)aRange
{
    if ( aRange.location + aRange.length > [symbolArray count] )
        return nil;

    return [symbolArray subarrayWithRange: aRange];
}


- (NSString*)sequenceString
{
	unsigned int length = [self length];
	
	if ( length )
		return [self subSequenceStringInRange: NSMakeRange( 0, length ) ];
	else
	        return @"";	// return empty string, not nil.
}


- (NSString *)subSequenceStringInRange:(NSRange)aRange
{
    if ( aRange.location + aRange.length > [self length] )
        return nil;
    
	NSData		*data = [[self sequenceData] subdataWithRange: aRange];	// Man, I love Cocoa !!
	NSString	*theReturn = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
   
	return theReturn;
}


- (NSString *)sequenceStringFromSymbolArray:(NSArray *)anArray
{
	NSMutableString	*symbols = [NSMutableString string];
	BCSymbol		*symbol;
	int				i;
	
	for ( i = 0; i < [anArray count]; i++)
	{
		symbol = [anArray objectAtIndex: i];
		[symbols appendString: [symbol symbolString]];
	}
	
	return symbols;
}

- (BCSequence *)subSequenceInRange:(NSRange)aRange {
    if ( aRange.location + aRange.length > [symbolArray count] )
        return nil;

	return [BCSequence sequenceWithSymbolArray: [symbolArray subarrayWithRange: aRange]];
}


- (NSString *) savableRepresentation {
    return [self sequenceString];
}


- (NSString *) description  {
    return [self sequenceString];
}

- (void) addAnnotation:(BCAnnotation *)annotation
{
	[self addAnnotation: (id)[annotation content] forKey: [annotation name]];
}


- (void) addAnnotation:(NSString *)annotation forKey: (NSString *) key
{
	NSMutableString	*oldValue;
	BCAnnotation	*oldAnnotation, *newAnnotation;
	
	if ( annotations == nil )
	{
		annotations = [[NSMutableDictionary alloc] init];
	}

 // If key already exists, then we need to append the value, instead of replacing it. 
 // This will happen when annotations are in the entry in multiple lanes.
	
	oldAnnotation = (BCAnnotation *) [[self annotations] valueForKey: key];

	if ( oldAnnotation )
	{
		oldValue = [[oldAnnotation content] mutableCopy];
		
		[oldValue appendString: @"\n"];
		[oldValue appendString: annotation];

		newAnnotation = [[BCAnnotation alloc] initWithName: key content: oldValue];
	}
	else
	{
		newAnnotation = [[BCAnnotation alloc] initWithName: key content: annotation];
	}
	
	[[self annotations] setObject: newAnnotation forKey: key];
}


- (id) annotationForKey: (NSString *) key
{
	return [[self annotations] objectForKey: key];
}


- (NSMutableDictionary *) annotations
{
	return annotations;
}


//- (void) setAnnotations:(NSMutableDictionary *)aDict
//{
//    [aDict retain];
//    [annotations release];
//    annotations=aDict;
//}



////////////////////////////////////////////////////////////////////////////
#if 0
#pragma mark â  
#pragma mark â DERIVING RELATED SEQUENCES
#endif
//  DERIVING OTHER SEQUENCES
////////////////////////////////////////////////////////////////////////////

- (BCSequence *) reverse
{
#if 1
    NSMutableArray	*theReverse = [NSMutableArray array];
    BCSymbol		*aSymbol;
    DECLARE_INDEX(loopCounter);
    int				theLimit = [[self symbolArray] count];	// or use [self length] ???
    
    for ( loopCounter = 0 ; loopCounter < theLimit ; loopCounter++ ) {
      aSymbol = (id)ARRAY_GET_VALUE_AT_INDEX(symbolArray, loopCounter);
      ARRAY_INSERT_VALUE_AT_INDEX(theReverse, 0, aSymbol);
    }

    return [BCSequence sequenceWithSymbolArray: theReverse symbolSet: [self symbolSet]];

#else
	
	NSMutableData *reverseSequence = [[NSMutableData alloc] initWithLength: [self length]];
	
	const unsigned char *normal = [self bytes];
	unsigned char *reverse = [reverseSequence mutableBytes];
	
	unsigned int len = strlen( (char *)normal );
	
	unsigned i, j;
	j = 0;
	
	for(i = len; i >= 0; --i)
	{
		reverse[j] = normal[i];
		j++;
	}

	NSString	*reverseString = [[NSString alloc] initWithData: reverseSequence encoding: NSUTF8StringEncoding];

    return [[BCSequence alloc] initWithString: [reverseString autorelease] symbolSet: [self symbolSet]];

#endif
    
}

- (BCSequence *)complement
{
    BCToolComplement *complementTool = [BCToolComplement complementToolWithSequence: self];
    
    return [complementTool sequenceComplement];
}

- (BCSequence *) reverseComplement
{
    BCToolComplement *complementTool = [BCToolComplement complementToolWithSequence: self];
    
    [complementTool setReverse: YES];
    
    return [complementTool sequenceComplement];
}


////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
#if 0
#pragma mark â  
#pragma mark â MANIPULATING SEQUENCE CONTENTS
#endif
//
//  INFORMATIONAL METHODS
////////////////////////////////////////////////////////////////////////////

// THIS SHOULD ALL GO INTO THE MUTABLE SEQUENCE CLASS
- (void)removeSymbolsInRange:(NSRange)aRange
{
    if ( aRange.location + aRange.length > [symbolArray count] )
        return;
	//    [symbolArray removeObjectsInRange: aRange];
}

- (void)removeSymbolAtIndex:(int)index
{
    if ( index > [symbolArray count] - 1 )
        return;
	//    [symbolArray removeObjectAtIndex:index];
}

// TO DO : use BCSymbolSet for filtering //
- (void)insertSymbolsFromSequence:(BCSequence *)entry atIndex:(int)index
{
    if ( index > [symbolArray count] - 1 )
        return;
	//    [symbolArray replaceObjectsInRange:NSMakeRange(index,0) withObjectsFromArray:[entry symbolArray]];
}


////////////////////////////////////////////////////////////////////////////
#if 0
#pragma mark â  
#pragma mark â FINDING SUBSEQUENCES
#endif
//  FINDING SUBSEQUENCES
////////////////////////////////////////////////////////////////////////////


- (NSArray *) findSequence: (BCSequence *) entry
{
	return [self findSequence: entry usingStrict: NO];
}

- (NSArray *) findSequence: (BCSequence *) entry usingStrict: (BOOL) strict
{
	return [self findSequence: entry usingStrict: strict firstOnly: NO];
}

- (NSArray *) findSequence: (BCSequence *) entry usingStrict: (BOOL) strict firstOnly: (BOOL) firstOnly
{
	return [self findSequence: entry usingStrict: strict 
					firstOnly: NO usingSearchRange: NSMakeRange(0, [self length])];
}

- (NSArray *) findSequence: (BCSequence *) entry usingStrict: (BOOL) strict 
				firstOnly: (BOOL) firstOnly usingSearchRange: (NSRange) range
{
	BCToolSequenceFinder *sequenceFinder = [BCToolSequenceFinder sequenceFinderWithSequence: self];
	
	[sequenceFinder setStrict: strict];
	[sequenceFinder setFirstOnly: firstOnly];
	[sequenceFinder setSearchRange: range];
	
	return [sequenceFinder findSequence: entry];
}



@end
