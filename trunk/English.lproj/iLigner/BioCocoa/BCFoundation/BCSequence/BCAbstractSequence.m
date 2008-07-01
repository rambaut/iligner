//
//  BCAbstractSequence.m
//  BioCocoa
//
//  Created by Koen van der Drift on 12/14/2004.
//  Copyright 2004 The BioCocoa Project. All rights reserved.
//

#import "BCAbstractSequence.h"
#import "BCAnnotation.h"
#import "BCFoundationDefines.h"
#import "BCSymbol.h"
#import "BCSymbolSet.h"
#import "BCToolSequenceFinder.h"

#import "BCInternal.h"

@implementation BCAbstractSequence

////////////////////////////////////////////////////////////////////////////
#pragma mark â  
#pragma mark â INITIALIZATION METHODS
//
//  INITIALIZATION METHODS
////////////////////////////////////////////////////////////////////////////

//designated initializer
- (id)initWithSymbolArray:(NSArray *)anArray symbolSet:(BCSymbolSet *)aSet
{
    self=[super init];
    if (self!=nil) {
		//check that the symbol set is the right type, otherwise use default
		//it is important to test symbolSet==nil as this is part of
		// the specifications of the method in the headerdoc
		if ( ([aSet sequenceType]!=[self sequenceType]) || (aSet==nil) )
			aSet=[[self class] defaultSymbolSet];
		//let the set check the symbols
		NSArray *finalArray=[aSet arrayByRemovingUnknownSymbolsFromArray:anArray];
		symbolArray=[[NSMutableArray alloc] initWithArray:finalArray];
		symbolSet=[aSet retain];
		//annotations
		annotations=nil;
    }
    return self;
}

//uses the default symbol set as provided by the subclass
- (id)initWithSymbolArray:(NSArray *)anArray
{
    return [self initWithSymbolArray:anArray symbolSet:[[self class] defaultSymbolSet]];
}

//returns an empty sequence by calling the designated initializer
- (id)init
{    
    return [self initWithSymbolArray:[NSArray array] symbolSet:[[self class] defaultSymbolSet]];
}

//creates an array of BCSymbols using the symbol set passed as argument
- (id)initWithString:(NSString *)aString symbolSet:(BCSymbolSet *)aSet;
{
    int i,n;
    NSMutableArray *anArray;
    BCSymbol *aSymbol;
	
    //check that the symbol set is the right type, otherwise use default
	//it is important to test symbolSet==nil as this is part of
	// the specifications of the method in the headerdoc
    if ( ([aSet sequenceType]!=[self sequenceType]) || (aSet==nil) )
		aSet=[[self class] defaultSymbolSet];
	
    //creates a symbol array
	n=[aString length];
	anArray=[NSMutableArray arrayWithCapacity:[aString length]];
	for (i=0;i<n;i++) {
		unsigned char aChar=[aString characterAtIndex:i];
		if (aSymbol=[aSet symbolForChar:aChar])
			[anArray addObject:aSymbol];
	}
	
    //calls the designated initializer
	return [self initWithSymbolArray:anArray symbolSet:aSet];
}

//uses the default symbol set as provided by the subclass
- (id)initWithString:(NSString*)aString
{
    return [self initWithString:aString symbolSet:[[self class] defaultSymbolSet]];
}


- (id)initWithString:(NSString*)aString range:(NSRange)aRange;
{
    return [self initWithString:[aString substringWithRange:aRange]];
}


+ (BCAbstractSequence *)sequenceWithString: (NSString *)aString;
{
	return [[[[self class] alloc] initWithString:aString] autorelease];
}

+ (id)sequenceWithString:(NSString *)aString symbolSet:(BCSymbolSet *)aSet;
{
	return [[[[self class] alloc] initWithString:aString symbolSet:aSet] autorelease];
}

+ (BCAbstractSequence *)sequenceWithSymbolArray:(NSArray *)entry 
{
	return [[[[self class] alloc] initWithSymbolArray:entry] autorelease];
}

+ (id) objectForSavedRepresentation: (NSString *)aSequence 
{
	BCAbstractSequence *theReturn = [[BCAbstractSequence alloc] initWithString: aSequence];
	return [theReturn autorelease];
}


- (id)copyWithZone:(NSZone *)zone
{
	NSArray *copiedSymbolArray=[[[self symbolArray] copy] autorelease];
	id copy = [[[self class] allocWithZone:zone] initWithSymbolArray:copiedSymbolArray
														   symbolSet:[self symbolSet]];
    return copy;
}


- (void)dealloc
{
    [symbolArray release];
	[symbolSet release];
	[annotations release];
    [super dealloc];
}




////////////////////////////////////////////////////////////////////////////
#pragma mark â  
#pragma mark â OBTAINING SEQUENCE INFORMATION
//
//  INFORMATIONAL METHODS
////////////////////////////////////////////////////////////////////////////

//should be overriden by subclasses
+ (BCSymbolSet *)defaultSymbolSet
{
	return [BCSymbolSet unknownSymbolSet];
}

- (BCSymbolSet *)symbolSet
{
	return symbolSet;
}

/*
- (void)setSymbolSet:(BCSymbolSet *)set
{
	[set retain];
	[symbolSet release];
	symbolSet = set;
}
*/

//should be overriden by subclasses
- (BCSequenceType)sequenceType
{
    return BCOtherSequence;
}

/*
- (void) setSequenceType:(BCSequenceType)aType
{
	sequenceType = aType;
}
*/

- (unsigned int) length {
    return [symbolArray count];
}


- (BCSymbol *)symbolAtIndex: (int)theIndex {
    if ( theIndex >= [symbolArray count] )
        return nil;
    return [symbolArray objectAtIndex: theIndex];
}


- (BOOL) containsAmbiguousSymbols {    
    BCSymbol *aSymbol;
    int theLimit = [symbolArray count];

    DECLARE_INDEX(loopCounter);
    for ( loopCounter = 0 ; loopCounter < theLimit ; loopCounter++ ) {
      aSymbol = (BCSymbol *)ARRAY_GET_VALUE_AT_INDEX(symbolArray, loopCounter);
      if ( [aSymbol isCompoundSymbol] )
	return YES;
    }
    
    return NO;
}

- (NSString*)sequenceString
{
    return [self subSequenceStringInRange: NSMakeRange( 0, [symbolArray count] ) ];
}


//For performance reason, the original ivar is returned.
//The user is warned in the headerdoc that this array should not be messed up with.
- (NSMutableArray *)symbolArray
{
	return symbolArray;
}


// TO DO : use BCSymbolSet for filtering //
- (void) setSymbolArray: (NSArray *) anArray
{
    [symbolArray release];
    symbolArray = [[NSMutableArray alloc] init];
    
    id		aSymbol;
    DECLARE_INDEX(loopCounter);
    int		theLimit = [anArray count];
    
    for ( loopCounter = 0 ; loopCounter < theLimit ; loopCounter++ ) {
      aSymbol = (id)ARRAY_GET_VALUE_AT_INDEX(anArray, loopCounter);
      ARRAY_APPEND_VALUE(symbolArray, aSymbol);
    }
}


- (NSString *)subSequenceStringInRange:(NSRange)aRange {
    if ( aRange.location + aRange.length > [symbolArray count] )
        return nil;
    
    NSMutableString *theReturn = [NSMutableString stringWithString: @""];
    
    NSArray *tempArray = [symbolArray subarrayWithRange: aRange];
    DECLARE_INDEX(loopCounter);
    int theLimit = [tempArray count];
    id aSymbol;
    NSString *aSymbolString;
    
    for ( loopCounter = 0 ; loopCounter < theLimit ; loopCounter++ ) {
      aSymbol = (BCSymbol *)ARRAY_GET_VALUE_AT_INDEX( tempArray, loopCounter);
        aSymbolString = [aSymbol symbolString];
        if ( aSymbolString != nil )
            [theReturn appendString: aSymbolString];
    }
    return [[theReturn copy] autorelease];
}


- (NSArray *)subSymbolArrayInRange:(NSRange)aRange
{
    if ( aRange.location + aRange.length > [symbolArray count] )
        return nil;

    return [symbolArray subarrayWithRange: aRange];
}


- (BCAbstractSequence *)subSequenceInRange:(NSRange)aRange {
    if ( aRange.location + aRange.length > [symbolArray count] )
        return nil;
    
    return [[[BCAbstractSequence alloc] initWithArray: [symbolArray subarrayWithRange: aRange]] autorelease];
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
#pragma mark â  
#pragma mark â DERIVING RELATED SEQUENCES
//  DERIVING OTHER SEQUENCES
////////////////////////////////////////////////////////////////////////////

- (BCAbstractSequence *) reverse
{
    NSMutableArray	*theReverse = [NSMutableArray array];
    id				aSymbol;
    DECLARE_INDEX(loopCounter);
    int				theLimit = [symbolArray count];
    
    for ( loopCounter = 0 ; loopCounter < theLimit ; loopCounter++ ) {
      aSymbol = (id)ARRAY_GET_VALUE_AT_INDEX(symbolArray, loopCounter);
      ARRAY_INSERT_VALUE_AT_INDEX(theReverse, 0, aSymbol);
    }
    
    return [BCAbstractSequence sequenceWithSymbolArray: theReverse];
}

//these methods is implemented here to allow sequence classes other than nucleotides
//to respond to that message at runtime, and hence to allow the placeholder class
//BCSequence to behave as properly at runtime
//On anything other than nucleotides, this will return an empty sequence
- (id)complement
{
	return [[self class] sequenceWithString:@""];
}
- (id) reverseComplement
{
	return [[self class] sequenceWithString:@""];
}


////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
#pragma mark â  
#pragma mark â MANIPULATING SEQUENCE CONTENTS
//
//  INFORMATIONAL METHODS
////////////////////////////////////////////////////////////////////////////


- (void)removeSymbolsInRange:(NSRange)aRange
{
    if ( aRange.location + aRange.length > [symbolArray count] )
        return;
    [symbolArray removeObjectsInRange: aRange];
}

- (void)removeSymbolAtIndex:(int)index
{
    if ( index > [symbolArray count] - 1 )
        return;
    [symbolArray removeObjectAtIndex:index];
}

// TO DO : use BCSymbolSet for filtering //
- (void)insertSymbolsFromSequence:(BCAbstractSequence *)entry atIndex:(int)index
{
    if ( index > [symbolArray count] - 1 )
        return;
    [symbolArray replaceObjectsInRange:NSMakeRange(index,0) 
               withObjectsFromArray:[entry symbolArray]];
}



////////////////////////////////////////////////////////////////////////////
#pragma mark â  
#pragma mark â FINDING SUBSEQUENCES
//  FINDING SUBSEQUENCES
////////////////////////////////////////////////////////////////////////////


- (NSArray *) findSequence: (BCAbstractSequence *) entry
{
	return [self findSequence: entry usingStrict: NO];
}

- (NSArray *) findSequence: (BCAbstractSequence *) entry usingStrict: (BOOL) strict
{
	return [self findSequence: entry usingStrict: strict firstOnly: NO];
}

- (NSArray *) findSequence: (BCAbstractSequence *) entry usingStrict: (BOOL) strict firstOnly: (BOOL) firstOnly
{
	return [self findSequence: entry usingStrict: strict 
					firstOnly: NO usingSearchRange: NSMakeRange(0, [self length])];
}

- (NSArray *) findSequence: (BCAbstractSequence *) entry usingStrict: (BOOL) strict 
				firstOnly: (BOOL) firstOnly usingSearchRange: (NSRange) range
{
	BCToolSequenceFinder *sequenceFinder = [BCToolSequenceFinder sequenceFinderWithSequence: self];
	
	[sequenceFinder setStrict: strict];
	[sequenceFinder setFirstOnly: firstOnly];
	[sequenceFinder setSearchRange: range];
	
	return [sequenceFinder findSequence: entry];
}



@end
