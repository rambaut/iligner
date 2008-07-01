//
//  BCSymbolSet.m
//  BioCocoa
//
//  Created by Alexander Griekspoor on Fri Sep 10 2004.
//  Copyright (c) 2004 The BioCocoa Project. All rights reserved.
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

#import "BCSymbolSet.h"
#import "BCSymbol.h"
#import "BCNucleotideDNA.h"
#import "BCNucleotideRNA.h"
#import "BCAminoAcid.h"
#import "BCUtilStrings.h"

static  BCSymbolSet *dnaSymbolSetRepresentation = nil;
static  BCSymbolSet *dnaStrictSymbolSetRepresentation = nil;
static  BCSymbolSet *rnaSymbolSetRepresentation = nil;
static  BCSymbolSet *rnaStrictSymbolSetRepresentation = nil;
static  BCSymbolSet *proteinSymbolSetRepresentation = nil;
static  BCSymbolSet *proteinStrictSymbolSetRepresentation = nil;
static  BCSymbolSet *unknownSymbolSetRepresentation = nil;
static  BCSymbolSet *unknownAndGapSymbolSetRepresentation = nil;


// From NSSet documentation:

// Objects in a set must respond to the NSObject protocol methods hash and isEqual:. 
// See the NSObject protocol for more information.


@implementation BCSymbolSet //<NSCopying, NSMutableCopying, NSCoding>

//THIS IS A FUNCTION ! (as opposed to a method...)
//returns the sequence type of a given symbol, based on its class
//called by various symbolSet methods to check the validity of a symbol
//(TO DO : symbols should have a sequence type ?)
BCSequenceType SequenceTypeOfSymbol(BCSymbol *aSymbol)
{
	if ([aSymbol isKindOfClass:[BCNucleotideDNA class]])
		return BCSequenceTypeDNA;
	else if ([aSymbol isKindOfClass:[BCNucleotideRNA class]])
		return BCSequenceTypeRNA;
	else if ([aSymbol isKindOfClass:[BCAminoAcid class]])
		return BCSequenceTypeProtein;
	else
		return BCSequenceTypeOther;
}

////////////////////////////////////////////////////////////////////////////
#if 0
#pragma mark ‚ 
#pragma mark ‚INITIALIZATION METHODS
#endif
////////////////////////////////////////////////////////////////////////////


- (id)initWithArray:(NSArray *)symbols sequenceType:(BCSequenceType)type
{
	NSEnumerator *e;
	BCSymbol *aSymbol;
	NSMutableSet *aSet;
    if ( (self = [super init]) ) {
		sequenceType=type;
		aSet=[NSMutableSet setWithCapacity:[symbols count]];
		e=[symbols objectEnumerator];
		while ( (aSymbol=[e nextObject]) ) {
			//(TO DO : symbols should have a sequence type ?)
			if (SequenceTypeOfSymbol(aSymbol)==sequenceType)
				[aSet addObject:aSymbol];
		}
		symbolSet=[[NSMutableSet alloc] initWithSet:aSet];
	}
	
	return self;
}

//initializes the symbol sets using the string --> character set --> symbols
//very useful for the factory methods for the prebuilt sets
// ** NOTE : works only for symbols with stringRepresentation length = 1 **
- (id)initWithString:(NSString *)stringOfCharacters sequenceType:(BCSequenceType)type
{
	int i,n;
	NSMutableArray *symbolArray;
	unsigned char oneChar;
	BCSymbol *oneSymbol;
	Class symbolClass=nil;
	
	//to create a new symbol from a character, you need to call a class method
	//so you need to know the class of BCSymbol to use
	//this class is determined by the sequence type passed as argument
	if (type==BCSequenceTypeDNA)
		symbolClass=[BCNucleotideDNA class];
	else if (type==BCSequenceTypeRNA)
		symbolClass=[BCNucleotideRNA class];
	else if (type==BCSequenceTypeProtein)
		symbolClass=[BCAminoAcid class];
	else
		return [self initWithArray:[NSArray array] sequenceType:type];
	
	//now loop over the characters in the passed string
	//to populate an array with BCSymbol objects
	n=[stringOfCharacters length];
	symbolArray=[NSMutableArray arrayWithCapacity:n];
	const char *utf8string = [stringOfCharacters UTF8String];
	
	for (i=0;i<n;i++) {
		oneChar=utf8string[i];
		oneSymbol=[symbolClass symbolForChar:oneChar];
		[symbolArray addObject:oneSymbol];
	}
	
	//use that array to call the designated initializer
	return [self initWithArray:[NSArray arrayWithArray:symbolArray] sequenceType:type];
}

//decide the sequence type based on the first symbol in the passed array
- (id)initWithArray:(NSArray *)symbols
{
	BCSequenceType guess=BCSequenceTypeOther;
	if ([symbols count]>0)
		guess=SequenceTypeOfSymbol([symbols objectAtIndex:0]);
	return [self initWithArray:symbols sequenceType:guess];
}

- (id)init
{
	return [self initWithArray:[NSArray array] sequenceType:BCSequenceTypeOther];
}


- (void)dealloc
{   
	[symbolSet release];
	
    [super dealloc];
}

//BCSymbolSet is immutable, no need to copy anything
//just retain and return self
- (id)copyWithZone:(NSZone *)zone
{
	return [self retain];
}

+ (BCSymbolSet *)symbolSetWithArray:(NSArray *)symbols
{
	return [[[self alloc] initWithArray:symbols] autorelease];
}

+ (BCSymbolSet *)symbolSetWithArray:(NSArray *)symbols sequenceType:(BCSequenceType)type
{
	return [[[self alloc] initWithArray:symbols sequenceType:type] autorelease];
}

+ (BCSymbolSet *)symbolSetWithString:(NSString *)aString sequenceType:(BCSequenceType)type
{
	return [[[self alloc] initWithString:aString sequenceType:type] autorelease];
}

+ (BCSymbolSet *)symbolSetForSequenceType:(BCSequenceType)type
{
	if ( type == BCSequenceTypeDNA )
		return [self dnaSymbolSet];
		
	else if ( type == BCSequenceTypeRNA )
		return [self rnaSymbolSet];
		
	else if ( type == BCSequenceTypeProtein )
		return [self proteinSymbolSet];

	else
		return [self unknownSymbolSet];
}

////////////////////////////////////////////////////////////////////////////
#if 0
#pragma mark ‚ 
#pragma mark ‚FACTORY METHODS FOR THE PREBUILT SETS
#endif
////////////////////////////////////////////////////////////////////////////

+ (BCSymbolSet *)dnaSymbolSet
{
	if ( dnaSymbolSetRepresentation == nil ) {
		dnaSymbolSetRepresentation = [[BCSymbolSet alloc] initWithString:@"ACGTRYMKSWHBVDN"
															sequenceType:BCSequenceTypeDNA];
	}
	return dnaSymbolSetRepresentation;
}

+ (BCSymbolSet *)dnaStrictSymbolSet
{
	if ( dnaStrictSymbolSetRepresentation == nil ) {
		dnaStrictSymbolSetRepresentation = [[BCSymbolSet alloc] initWithString:@"ACGT"
																  sequenceType:BCSequenceTypeDNA];
	}
	return dnaStrictSymbolSetRepresentation;
}

+ (BCSymbolSet *)rnaSymbolSet
{
	if ( rnaSymbolSetRepresentation == nil )
	{
		rnaSymbolSetRepresentation = [[BCSymbolSet alloc] initWithString:@"ACGURYMKSWHBVDN" 
															sequenceType:BCSequenceTypeRNA];
	}
	return rnaSymbolSetRepresentation;
}

+ (BCSymbolSet *)rnaStrictSymbolSet
{
	if ( rnaStrictSymbolSetRepresentation == nil ) {
		rnaStrictSymbolSetRepresentation = [[BCSymbolSet alloc] initWithString:@"ACGU" 
																  sequenceType:BCSequenceTypeRNA];
	}
	return rnaStrictSymbolSetRepresentation;
}

+ (BCSymbolSet *)proteinSymbolSet
{
	if ( proteinSymbolSetRepresentation == nil ) {
		proteinSymbolSetRepresentation = [[BCSymbolSet alloc] initWithString:@"ACDEFGHIKLMNPQRSTVWYBZ" 
																sequenceType:BCSequenceTypeProtein];
	}
	return proteinSymbolSetRepresentation;
}

+ (BCSymbolSet *)proteinStrictSymbolSet
{
	if ( proteinStrictSymbolSetRepresentation == nil ) {
		proteinStrictSymbolSetRepresentation = [[BCSymbolSet alloc] initWithString:@"ACDEFGHIKLMNPQRSTVWY" 
																	  sequenceType:BCSequenceTypeProtein];
	}
	return proteinStrictSymbolSetRepresentation;
}

+ (BCSymbolSet *)unknownSymbolSet	// is this aa or base ???
{
	if ( unknownSymbolSetRepresentation == nil )
	{
		unknownSymbolSetRepresentation = [[BCSymbolSet alloc] initWithArray:[NSArray array]
															   sequenceType:BCSequenceTypeOther];
	}
	
	return unknownSymbolSetRepresentation;
}

+ (BCSymbolSet *)unknownAndGapSymbolSet	// is this aa or base ???
{
	if ( unknownAndGapSymbolSetRepresentation == nil )
	{
		unknownAndGapSymbolSetRepresentation = [self unknownSymbolSet];
	}
	
	return unknownAndGapSymbolSetRepresentation;
}

////////////////////////////////////////////////////////////////////////////
#if 0
#pragma mark ‚ 
#pragma mark ‚CREATING NEW SYMBOL SETS
#endif
////////////////////////////////////////////////////////////////////////////

- (BCSymbolSet *)symbolSetByFormingUnionWithSymbolSet:(BCSymbolSet *)otherSet
{
	NSMutableSet *temp;
	//cases where we don't need to create a new object
	if ( (sequenceType!=[otherSet sequenceType])
		 || [symbolSet isSubsetOfSet:[otherSet symbolSet]]
		 || [[otherSet symbolSet] isSubsetOfSet:symbolSet] )
		return self;
	//create a temporary NSSet to form the union
	temp=[NSMutableSet setWithSet:symbolSet];
	[temp unionSet:[otherSet symbolSet]];
	return [[self class] symbolSetWithArray:[temp allObjects] sequenceType:sequenceType];
}

- (BCSymbolSet *)symbolSetByFormingIntersectionWithSymbolSet:(BCSymbolSet *)otherSet
{
	NSMutableSet *temp;
	//cases where we don't need to create a new object
	if ( (sequenceType!=[otherSet sequenceType])
		 || [symbolSet isSubsetOfSet:[otherSet symbolSet]]
		 || [[otherSet symbolSet] isSubsetOfSet:symbolSet] )
		return self;
	temp=[NSMutableSet setWithSet:symbolSet];
	[temp intersectSet:[otherSet symbolSet]];
	return [[self class] symbolSetWithArray:[temp allObjects] sequenceType:sequenceType];
}

/*
 - (BCSymbolSet *)complementSet
 {
 }
 
 - (BCSymbolSet *)expandedSet
 {
	 // ambigous symbols expanded
 }
 */


////////////////////////////////////////////////////////////////////////////
#if 0
#pragma mark ‚ 
#pragma mark ‚SYMBOL SETS IN OTHERS FORMATS
#endif
////////////////////////////////////////////////////////////////////////////

- (NSSet *)symbolSet
{
	return [[symbolSet copy] autorelease];
}

- (NSArray *)allSymbols
{
	return [symbolSet allObjects];
}

- (NSCharacterSet *)characterSetRepresentation
{
	NSMutableString	*symbols = [NSMutableString string];
	NSEnumerator	*symbolEnumerator = [[self symbolSet] objectEnumerator];
	BCSymbol		*symbol;
	
	while ( (symbol = [symbolEnumerator nextObject]) )
	{
		[symbols appendString: [symbol symbolString]];
	}
	
	return [NSCharacterSet characterSetWithCharactersInString:symbols];
}

//string = concatenated characters corresponding to the symbols
//e.g. [dnaSrictSymbolSet stringRepresentation] = @"ATGC" (not sure about the order)
- (NSString*)stringRepresentation
{
	NSMutableString	*symbols = [NSMutableString string];
	NSEnumerator	*symbolEnumerator = [symbolSet objectEnumerator];
	BCSymbol		*symbol;
	
	while ( (symbol = [symbolEnumerator nextObject]) )
		[symbols appendString: [symbol symbolString]];
	
	return [NSString stringWithString:symbols];
}

//description is e.g.
// <BCSymbolSet:0x3b6340>=ATCG(DNA)
- (NSString *)description
{
	NSString *type;
	if (sequenceType==BCSequenceTypeDNA)
		type=@"DNA";
	else if (sequenceType==BCSequenceTypeRNA)
		type=@"RNA";
	else if (sequenceType==BCSequenceTypeProtein)
		type=@"Protein";
	else
		type=@"unknown type";
	return [NSString stringWithFormat:@"<%@:%p>=%@(%@)",
		[self class], self, [self stringRepresentation], type];
}

////////////////////////////////////////////////////////////////////////////
#if 0
#pragma mark ‚ 
#pragma mark ‚FILTERING SYMBOLS WITH SYMBOL SETS
#endif
////////////////////////////////////////////////////////////////////////////
- (NSArray *)arrayByRemovingUnknownSymbolsFromArray:(NSArray *)anArray
{
	NSEnumerator *e;
	BCSymbol *aSymbol;
	NSMutableArray *result;
	
	result=[NSMutableArray arrayWithCapacity:[anArray count]];
	e=[anArray objectEnumerator];
	while ( (aSymbol=[e nextObject]) ) {
		if ([symbolSet containsObject:aSymbol])
			[result addObject:aSymbol];
	}
	return [NSArray arrayWithArray:result];
}

- (NSString *)stringByRemovingUnknownCharsFromString:(NSString *)aString
{
	int i, len;
	unsigned char c;

	NSMutableString *result = [NSMutableString stringWithCapacity: [aString length]];
	
	const char *utfString = [aString UTF8String]; 
	len = strlen(utfString);
	
	for ( i = 0; i < len; i++ )
	{		
		c = utfString[i];
	
		if ([self containsSymbol: [self symbolForChar: c]])
		{
			[result appendString: [NSString stringWithBytes: (const void *) &c 
						length: 1 encoding: NSUTF8StringEncoding]];
		}
	}
	
	return [NSString stringWithString:result];
}

- (NSData *)dataByRemovingUnknownCharsFromData:(NSData *)aData
{
  NSMutableData *newData = [NSMutableData data];
  const char *seqData = (const char *)[aData bytes];
  unsigned i, len = [aData length];
  
  for (i = 0; i < len; ++i) {
		if ([self containsSymbol: [self symbolForChar: seqData[i]]]) {
			[newData appendBytes: (const void *) &(seqData[i]) length: 1];
		}
  }
  
  return newData;
}

//maybe that should be cached in the future??
//the implementation of this method somehow defeats the symbol set design...
- (BCSymbol *)symbolForChar:(unsigned char)aChar
{
	Class symbolClass;
	BCSymbol *result;
	
	//to create a new symbol from a character, you need to call a class method
	//so you need to know the class of BCSymbol to use
	//this class is determined by the sequence type passed as argument
	if (sequenceType==BCSequenceTypeDNA)
		symbolClass=[BCNucleotideDNA class];
	else if (sequenceType==BCSequenceTypeRNA)
		symbolClass=[BCNucleotideRNA class];
	else if (sequenceType==BCSequenceTypeProtein)
		symbolClass=[BCAminoAcid class];
	else
		return nil;
	
	//Now use that class to get the symbol
	//and check if it is in the symbol set
	result=[symbolClass symbolForChar:aChar];
	if ([symbolSet containsObject:result])
		return result;
	else
		return nil;
}

////////////////////////////////////////////////////////////////////////////
#if 0
#pragma mark ‚ 
#pragma mark ‚EXPLORING SYMBOL SETS
#endif
////////////////////////////////////////////////////////////////////////////

- (BCSequenceType)sequenceType
{
	return sequenceType;
}

// aSymbol=W and contains A --> no
- (BOOL)containsSymbol:(BCSymbol *)aSymbol
{
	return [symbolSet containsObject:aSymbol];
}

// aSymbol=W and contains A --> yes
- (BOOL)containsSymbolRepresentedBy:(BCSymbol *)aSymbol
{
	return [symbolSet intersectsSet:[[aSymbol symbolSetOfRepresentedSymbols] symbolSet]];
}

// aSymbol=W and contains A,T --> yes
- (BOOL)containsAllSymbolsRepresentedBy:(BCSymbol *)aSymbol
{
	NSSet *representedSymbols=[[aSymbol symbolSetOfRepresentedSymbols] symbolSet];
	return [representedSymbols isSubsetOfSet:symbolSet];
}

// aSymbol=A and contains W --> yes
- (BOOL)containsSymbolRepresenting:(BCSymbol *)aSymbol
{
	NSSet *representingSymbols=[[aSymbol symbolSetOfRepresentingSymbols] symbolSet];
	return [representingSymbols isSubsetOfSet:symbolSet];
}

-(BOOL)containsCharactersFromString: (NSString *) aString
{
	int i, len;
	unsigned char c;
	
	const char *utfString = [aString UTF8String]; 
	len = strlen(utfString);
	
 // return NO if we find a character that is not part of the symbolset
 // useful for validating an input

	for ( i = 0; i < len; i++ )
	{		
		c = utfString[i];
		if (![self containsSymbol: [self symbolForChar: c]])
		{
			return NO;
		}
	}
	
	return YES;
}

- (BOOL)isSupersetOfSet:(BCSymbolSet *)theOtherSet
{
	return [[theOtherSet symbolSet] isSubsetOfSet: [self symbolSet]];
}


//The old versions of the factory methods for the prebuilt sets
/*
////////////////////////////////////////////////////////////////////////////
#pragma mark ‚ 
#pragma mark ‚FACTORY METHODS FOR THE PREBUILT SETS
////////////////////////////////////////////////////////////////////////////

//this method should temporarily be used for the prebuilt symbol sets
//it is not meant to be public
//the prebuil sets should eventually use the designated initializer instead
- (void)setSequenceType:(BCSequenceType)type
{
	sequenceType=type;
}

+ (BCSymbolSet *)dnaSymbolSet
{
	if ( dnaSymbolSetRepresentation == nil )
	{
		dnaSymbolSetRepresentation = [[BCSymbolSet alloc] init];
		[dnaSymbolSetRepresentation setSequenceType:BCSequenceTypeDNA];
		
		[dnaSymbolSetRepresentation addSymbol: [BCNucleotideDNA symbolForChar: 'A']];
		[dnaSymbolSetRepresentation addSymbol: [BCNucleotideDNA symbolForChar: 'C']];
		[dnaSymbolSetRepresentation addSymbol: [BCNucleotideDNA symbolForChar: 'G']];
		[dnaSymbolSetRepresentation addSymbol: [BCNucleotideDNA symbolForChar: 'T']];
		[dnaSymbolSetRepresentation addSymbol: [BCNucleotideDNA symbolForChar: 'R']];
		[dnaSymbolSetRepresentation addSymbol: [BCNucleotideDNA symbolForChar: 'Y']];
		[dnaSymbolSetRepresentation addSymbol: [BCNucleotideDNA symbolForChar: 'M']];
		[dnaSymbolSetRepresentation addSymbol: [BCNucleotideDNA symbolForChar: 'K']];
		[dnaSymbolSetRepresentation addSymbol: [BCNucleotideDNA symbolForChar: 'S']];
		[dnaSymbolSetRepresentation addSymbol: [BCNucleotideDNA symbolForChar: 'W']];
		[dnaSymbolSetRepresentation addSymbol: [BCNucleotideDNA symbolForChar: 'H']];
		[dnaSymbolSetRepresentation addSymbol: [BCNucleotideDNA symbolForChar: 'B']];
		[dnaSymbolSetRepresentation addSymbol: [BCNucleotideDNA symbolForChar: 'V']];
		[dnaSymbolSetRepresentation addSymbol: [BCNucleotideDNA symbolForChar: 'D']];
		[dnaSymbolSetRepresentation addSymbol: [BCNucleotideDNA symbolForChar: 'N']];
	}
	
	return dnaSymbolSetRepresentation;
}

+ (BCSymbolSet *)dnaStrictSymbolSet
{
	if ( dnaStrictSymbolSetRepresentation == nil )
	{
		dnaStrictSymbolSetRepresentation = [[BCSymbolSet alloc] init];
		[dnaStrictSymbolSetRepresentation setSequenceType:BCSequenceTypeDNA];
		
		[dnaStrictSymbolSetRepresentation addSymbol: [BCNucleotideDNA symbolForChar: 'A']];
		[dnaStrictSymbolSetRepresentation addSymbol: [BCNucleotideDNA symbolForChar: 'C']];
		[dnaStrictSymbolSetRepresentation addSymbol: [BCNucleotideDNA symbolForChar: 'G']];
		[dnaStrictSymbolSetRepresentation addSymbol: [BCNucleotideDNA symbolForChar: 'T']];
	}
	
	return dnaStrictSymbolSetRepresentation;
}

+ (BCSymbolSet *)rnaSymbolSet
{
	if ( rnaSymbolSetRepresentation == nil )
	{
		rnaSymbolSetRepresentation = [[BCSymbolSet alloc] init];
		[rnaSymbolSetRepresentation setSequenceType:BCSequenceTypeRNA];
		
		[rnaSymbolSetRepresentation addSymbol: [BCNucleotideRNA symbolForChar: 'A']];
		[rnaSymbolSetRepresentation addSymbol: [BCNucleotideRNA symbolForChar: 'C']];
		[rnaSymbolSetRepresentation addSymbol: [BCNucleotideRNA symbolForChar: 'G']];
		[rnaSymbolSetRepresentation addSymbol: [BCNucleotideRNA symbolForChar: 'T']];
		[rnaSymbolSetRepresentation addSymbol: [BCNucleotideRNA symbolForChar: 'R']];
		[rnaSymbolSetRepresentation addSymbol: [BCNucleotideRNA symbolForChar: 'Y']];
		[rnaSymbolSetRepresentation addSymbol: [BCNucleotideRNA symbolForChar: 'M']];
		[rnaSymbolSetRepresentation addSymbol: [BCNucleotideRNA symbolForChar: 'K']];
		[rnaSymbolSetRepresentation addSymbol: [BCNucleotideRNA symbolForChar: 'S']];
		[rnaSymbolSetRepresentation addSymbol: [BCNucleotideRNA symbolForChar: 'W']];
		[rnaSymbolSetRepresentation addSymbol: [BCNucleotideRNA symbolForChar: 'H']];
		[rnaSymbolSetRepresentation addSymbol: [BCNucleotideRNA symbolForChar: 'B']];
		[rnaSymbolSetRepresentation addSymbol: [BCNucleotideRNA symbolForChar: 'V']];
		[rnaSymbolSetRepresentation addSymbol: [BCNucleotideRNA symbolForChar: 'D']];
		[rnaSymbolSetRepresentation addSymbol: [BCNucleotideRNA symbolForChar: 'N']];
	}
	
	return dnaSymbolSetRepresentation;
}

+ (BCSymbolSet *)rnaStrictSymbolSet
{
	if ( rnaStrictSymbolSetRepresentation == nil )
	{
		rnaStrictSymbolSetRepresentation = [[BCSymbolSet alloc] init];
		[rnaStrictSymbolSetRepresentation setSequenceType:BCSequenceTypeRNA];
		
		[rnaStrictSymbolSetRepresentation addSymbol: [BCNucleotideRNA symbolForChar: 'A']];
		[rnaStrictSymbolSetRepresentation addSymbol: [BCNucleotideRNA symbolForChar: 'C']];
		[rnaStrictSymbolSetRepresentation addSymbol: [BCNucleotideRNA symbolForChar: 'G']];
		[rnaStrictSymbolSetRepresentation addSymbol: [BCNucleotideRNA symbolForChar: 'T']];
	}
	
	return rnaStrictSymbolSetRepresentation;
}

+ (BCSymbolSet *)proteinSymbolSet
{
	if ( proteinSymbolSetRepresentation == nil )
	{
		proteinSymbolSetRepresentation = [[BCSymbolSet alloc] init];
		[proteinSymbolSetRepresentation setSequenceType:BCSequenceTypeProtein];
		
		[proteinSymbolSetRepresentation addSymbol: [BCAminoAcid symbolForChar: 'A']];
		[proteinSymbolSetRepresentation addSymbol: [BCAminoAcid symbolForChar: 'C']];
		[proteinSymbolSetRepresentation addSymbol: [BCAminoAcid symbolForChar: 'D']];
		[proteinSymbolSetRepresentation addSymbol: [BCAminoAcid symbolForChar: 'E']];
		[proteinSymbolSetRepresentation addSymbol: [BCAminoAcid symbolForChar: 'F']];
		[proteinSymbolSetRepresentation addSymbol: [BCAminoAcid symbolForChar: 'G']];
		[proteinSymbolSetRepresentation addSymbol: [BCAminoAcid symbolForChar: 'H']];
		[proteinSymbolSetRepresentation addSymbol: [BCAminoAcid symbolForChar: 'I']];
		[proteinSymbolSetRepresentation addSymbol: [BCAminoAcid symbolForChar: 'K']];
		[proteinSymbolSetRepresentation addSymbol: [BCAminoAcid symbolForChar: 'L']];
		[proteinSymbolSetRepresentation addSymbol: [BCAminoAcid symbolForChar: 'M']];
		[proteinSymbolSetRepresentation addSymbol: [BCAminoAcid symbolForChar: 'N']];
		[proteinSymbolSetRepresentation addSymbol: [BCAminoAcid symbolForChar: 'P']];
		[proteinSymbolSetRepresentation addSymbol: [BCAminoAcid symbolForChar: 'Q']];
		[proteinSymbolSetRepresentation addSymbol: [BCAminoAcid symbolForChar: 'R']];
		[proteinSymbolSetRepresentation addSymbol: [BCAminoAcid symbolForChar: 'S']];
		[proteinSymbolSetRepresentation addSymbol: [BCAminoAcid symbolForChar: 'T']];
		[proteinSymbolSetRepresentation addSymbol: [BCAminoAcid symbolForChar: 'V']];
		[proteinSymbolSetRepresentation addSymbol: [BCAminoAcid symbolForChar: 'W']];
		[proteinSymbolSetRepresentation addSymbol: [BCAminoAcid symbolForChar: 'Y']];
		[proteinSymbolSetRepresentation addSymbol: [BCAminoAcid symbolForChar: 'B']];
		[proteinSymbolSetRepresentation addSymbol: [BCAminoAcid symbolForChar: 'Z']];
	}
	
	return proteinSymbolSetRepresentation;
}


+ (BCSymbolSet *)proteinStrictSymbolSet
{
	if ( proteinStrictSymbolSetRepresentation == nil )
	{
		proteinStrictSymbolSetRepresentation = [[BCSymbolSet alloc] init];
		[proteinStrictSymbolSetRepresentation setSequenceType:BCSequenceTypeProtein];
		
		[proteinStrictSymbolSetRepresentation addSymbol: [BCAminoAcid symbolForChar: 'A']];
		[proteinStrictSymbolSetRepresentation addSymbol: [BCAminoAcid symbolForChar: 'C']];
		[proteinStrictSymbolSetRepresentation addSymbol: [BCAminoAcid symbolForChar: 'D']];
		[proteinStrictSymbolSetRepresentation addSymbol: [BCAminoAcid symbolForChar: 'E']];
		[proteinStrictSymbolSetRepresentation addSymbol: [BCAminoAcid symbolForChar: 'F']];
		[proteinStrictSymbolSetRepresentation addSymbol: [BCAminoAcid symbolForChar: 'G']];
		[proteinStrictSymbolSetRepresentation addSymbol: [BCAminoAcid symbolForChar: 'H']];
		[proteinStrictSymbolSetRepresentation addSymbol: [BCAminoAcid symbolForChar: 'I']];
		[proteinStrictSymbolSetRepresentation addSymbol: [BCAminoAcid symbolForChar: 'K']];
		[proteinStrictSymbolSetRepresentation addSymbol: [BCAminoAcid symbolForChar: 'L']];
		[proteinStrictSymbolSetRepresentation addSymbol: [BCAminoAcid symbolForChar: 'M']];
		[proteinStrictSymbolSetRepresentation addSymbol: [BCAminoAcid symbolForChar: 'N']];
		[proteinStrictSymbolSetRepresentation addSymbol: [BCAminoAcid symbolForChar: 'P']];
		[proteinStrictSymbolSetRepresentation addSymbol: [BCAminoAcid symbolForChar: 'Q']];
		[proteinStrictSymbolSetRepresentation addSymbol: [BCAminoAcid symbolForChar: 'R']];
		[proteinStrictSymbolSetRepresentation addSymbol: [BCAminoAcid symbolForChar: 'S']];
		[proteinStrictSymbolSetRepresentation addSymbol: [BCAminoAcid symbolForChar: 'T']];
		[proteinStrictSymbolSetRepresentation addSymbol: [BCAminoAcid symbolForChar: 'V']];
		[proteinStrictSymbolSetRepresentation addSymbol: [BCAminoAcid symbolForChar: 'W']];
		[proteinStrictSymbolSetRepresentation addSymbol: [BCAminoAcid symbolForChar: 'Y']];
	}
	
	return proteinStrictSymbolSetRepresentation;
}

+ (BCSymbolSet *)unknownSymbolSet	// is this aa or base ???
{
	if ( unknownSymbolSetRepresentation == nil )
	{
		unknownSymbolSetRepresentation = [[BCSymbolSet alloc] init];
	}
	
	return unknownSymbolSetRepresentation;
}

+ (BCSymbolSet *)unknownAndGapSymbolSet	// is this aa or base ???
{
	if ( unknownAndGapSymbolSetRepresentation == nil )
	{
		unknownAndGapSymbolSetRepresentation = [[BCSymbolSet alloc] init];
	}
	
	return unknownAndGapSymbolSetRepresentation;
}
*/


//BCSymbolSet is immutable
//Keep this for a future BCMutableSymbolSet, if ever needed
/*
////////////////////////////////////////////////////////////////////////////
#pragma mark ‚ 
#pragma mark ‚MUTABILITY METHODS
////////////////////////////////////////////////////////////////////////////

- (void)addSymbol:(BCSymbol *)symbol
{
	[symbolSet addObject: symbol];
}

- (void)addSymbols:(NSArray *)symbols
{
	[symbolSet addObjectsFromArray: symbols];
}

- (void)addSymbolsInString:(NSString *)aString
{
}

- (void)removeSymbol:(BCSymbol *)symbol
{
	[symbolSet removeObject: symbol];
}

- (void)removeSymbols:(NSArray *)symbols
{
	NSSet	*temp = [NSSet setWithArray: symbols];
	
	[symbolSet minusSet: temp];
}

- (void)removeSymbolsInString:(NSString *)aString
{
}

- (void)formUnionWithSymbolSet:(BCSymbolSet *)otherSet
{
	[symbolSet unionSet: [otherSet symbolSet]];
}

- (void)formIntersectionWithSymbolSet:(BCSymbolSet *)otherSet
{
	[symbolSet intersectSet: [otherSet symbolSet]];
}

- (void)makeComplementary
{
}
*/

@end

