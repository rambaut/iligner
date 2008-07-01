//
//  BCSymbol.m
//  BioCocoa
//
//  Created by Koen van der Drift on Sun Aug 15 2004.
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

#import "BCSymbol.h"
#import "BCSymbolSet.h"
#import "BCUtilStrings.h"

#import	"BCStringDefinitions.h"
#import "BCInternal.h"

@implementation BCSymbol

- (id)initWithSymbolChar:(unsigned char)aChar
{
    if ( (self = [super init]) )
    {           
        symbolChar = aChar;
		symbolString = [[NSString stringWithBytes: &aChar length: 1 encoding: NSUTF8StringEncoding] retain];
		symbolInfo = nil;
		represents = nil;
		representedBy = nil;
    }
    
    return self;
}


- (void) initializeSymbolRelationships
{
    // THIS METHOD IS CALLED AFTER OBJECT INITIALIZATION BECAUSE IT 
    // REQUIRES THE EXISTENCE OF ALL THE OTHER SYMBOLS IN ORDER TO WORK
    // IT SHOULD BE CALLED THE FIRST TIME ONE OF THESE INSTANCE OBJECTS IS NEEDED
    
    NSString		*symbolReference;
	NSArray			*infoArray;
	NSEnumerator	*objectEnumerator;
	NSMutableArray	*tempArray;
	BCSymbol		*tempSymbol;
	
	
	infoArray = [[self symbolInfo] objectForKey: BCSymbolRepresentsProperty];

    if ( infoArray != nil || [infoArray count] > 0 )
	{
		objectEnumerator = [infoArray objectEnumerator];
		tempArray = [NSMutableArray array];

		while ( (symbolReference = [objectEnumerator nextObject]) )
		{
			if ( symbolReference != nil || [symbolReference length] > 0 )
			{
				tempSymbol = [(BCSymbol*)[self class] performSelector: NSSelectorFromString( symbolReference )];

				if ( tempSymbol != nil )
					[tempArray addObject: tempSymbol];
			}
		}
		
		represents = [[NSSet setWithArray: tempArray] retain];
	}
    
    infoArray = [[self symbolInfo] objectForKey: BCSymbolRepresentedByProperty];

    if ( infoArray != nil || [infoArray count] > 0 )
	{
		objectEnumerator = [infoArray objectEnumerator];
		tempArray = [NSMutableArray array];

		while ( (symbolReference = [objectEnumerator nextObject]) )
		{
			if ( symbolReference != nil || [symbolReference length] > 0 )
			{
				tempSymbol = [(BCSymbol*)[self class] performSelector: NSSelectorFromString( symbolReference )];

				if ( tempSymbol != nil )
					[tempArray addObject: tempSymbol];
			}
		}
		
		representedBy = [[NSSet setWithArray: tempArray] retain];
	}
}


- (void)dealloc
{   
	[represents release];
	[representedBy release];
	[name release];
	[symbolString release];
	[symbolInfo release];
	
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}
    


- (NSString *) name{
    return [[name copy] autorelease];
}



- (unsigned char) symbolChar {
    return symbolChar;
}


- (NSString *)symbolString {
//    return [[symbolString copy] autorelease];
    return symbolString;
}

- (NSString *) savableRepresentation {
    return [self symbolString];
}


- (NSString *) description {
    return [self name];
}

- (NSDictionary	*) symbolInfo
{
	return symbolInfo;
}

- (id) valueForKey: (NSString *)aKey {
    return [symbolInfo objectForKey: aKey];
}

- (void) setValue: (id)aValue forKey: (NSString *)theKey {
    return;
}

    

- (float)monoisotopicMass
{
	return monoisotopicMass;
}

- (void)setMonoisotopicMass:(float)value
{
	monoisotopicMass = value;
}

- (float)averageMass
{
	return averageMass;
}

- (void)setAverageMass:(float)value
{
	averageMass = value;
}


- (float)massUsingType:(BCMassType) aType
{
	if ( aType == BCMonoisotopic )
		return  [self monoisotopicMass];
	else if ( aType == BCAverage )
		return [self averageMass];

	return 0;
}

- (float)minMassUsingType:(BCMassType) aType
{
	if ([represents count] == 1)
	{
		return [self massUsingType: aType];
	}
	else
	{
		float			tempMin, symbolMass;
		DECLARE_INDEX(j);
		NSArray			*representedSymbols;
		BCSymbol		*aSymbol;
		
		representedSymbols = [[self representedSymbols] allObjects];

		aSymbol = (BCSymbol *)ARRAY_GET_VALUE_AT_INDEX(representedSymbols, 0);
		tempMin = [aSymbol massUsingType:aType];	
		
		for ( j = 1; j < [representedSymbols count]; j++ )
		{
			aSymbol = (BCSymbol *)ARRAY_GET_VALUE_AT_INDEX(representedSymbols, j);
			symbolMass = [aSymbol massUsingType:aType];	
			
			if ( symbolMass )
			{
				tempMin = ( tempMin < symbolMass ? tempMin : symbolMass );
			}
		}
		
		return tempMin;
	}
}


- (float)maxMassUsingType:(BCMassType) aType
{
	if ([represents count] == 1)
	{
		return [self massUsingType: aType];
	}
	else
	{
		float			tempMax, symbolMass;
		DECLARE_INDEX(j);
		NSArray			*representedSymbols;
		BCSymbol		*aSymbol;
		
		representedSymbols = [[self representedSymbols] allObjects];
		
		aSymbol = (BCSymbol *)ARRAY_GET_VALUE_AT_INDEX(representedSymbols, 0);
		tempMax = [aSymbol massUsingType:aType];	
		
		for ( j = 1; j < [representedSymbols count]; j++ )
		{
			aSymbol = (BCSymbol *)ARRAY_GET_VALUE_AT_INDEX(representedSymbols, j);
			symbolMass = [aSymbol massUsingType:aType];	
			
			if ( symbolMass )
			{
				tempMax = ( tempMax > symbolMass ? tempMax : symbolMass );
			}
		}
		
		return tempMax;
	}
}


- (BOOL)isEqualToSymbol:(BCSymbol *)aSymbol
{
	return (self == aSymbol);
}


-(BOOL) isCompoundSymbol {
    if ( [represents count] > 1 )
        return YES;
    return NO;
}


#if 0
#pragma mark ‚SYMBOL RELATIONSHIP METHODS
#endif


///////////////////////////////////////////////////////////
//  REPRESENTATION METHODS FOR AMBIGUOUS SYMBOLS
///////////////////////////////////////////////////////////

- (NSSet *) representedSymbols {
    if ( represents == nil )
        [self initializeSymbolRelationships];
    
    return [[represents copy] autorelease];
}

- (NSSet *) representingSymbols {
    if ( representedBy == nil )
        [self initializeSymbolRelationships];
    
    return [[representedBy copy] autorelease];
}

- (BOOL) representsSymbol: (BCSymbol *) entry {
    if ( represents == nil )
        [self initializeSymbolRelationships];
    
    // the following is the equivalent of return [represents containsObject: entry];
    return SET_CONTAINS_VALUE(represents, entry);
}


- (BOOL) isRepresentedBySymbol: (BCSymbol *) entry {
    if ( representedBy == nil )
        [self initializeSymbolRelationships];
    
    // the following is the equivalent of return [representedBy containsObject: entry];
    return SET_CONTAINS_VALUE(representedBy, entry);
}

- (BCSymbolSet *)symbolSetOfRepresentedSymbols
{
    if ( represents == nil )
        [self initializeSymbolRelationships];
    return [BCSymbolSet symbolSetWithArray: [represents allObjects]];
}

- (BCSymbolSet *)symbolSetOfRepresentingSymbols
{
    if ( representedBy == nil )
        [self initializeSymbolRelationships];
    return [BCSymbolSet symbolSetWithArray: [representedBy allObjects]];
}


//- (BOOL) isRepresentedBySymbol: (BCSymbol *) aSymbol
//{
//	return YES;
//}

@end
