//
//  BCToolComplement.m
//  BioCocoa
//
//  Created by Koen van der Drift on 11/19/04.
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

#import "BCToolComplement.h"
#import "BCSequence.h"
#import "BCSymbol.h"
#import "BCNucleotide.h"

#import "BCFoundationDefines.h"

#import "BCInternal.h"

@implementation BCToolComplement

-(id) initWithSequence:(BCSequence *)list
{
    if ( (self = [super initWithSequence:list]) )
    {
		[self setReverse: NO];
	}
	
	return self;
}


+ (BCToolComplement *) complementToolWithSequence: (BCSequence *) list
{
     BCToolComplement *complementTool = [[BCToolComplement alloc] initWithSequence: list];
     
	 return [complementTool autorelease];
}


- (void)setReverse: (BOOL)value
{
	reverse = value;
}

- (BCSequence *) sequenceComplement
{
	BCNucleotide		*symbol;
	NSArray			*symbolArray;
	NSMutableArray	*theComplement;
	DECLARE_INDEX(loopCounter);
	int				theLimit, newLocation;
	BCSymbol		*symbolComplement;
	
	// if it's a protein, we return the same sequence.
	
	// why a negative test here? It could also be BCSequenceTypeCodon or BCSequenceTypeOther.
	// maybe we should test for BCSequenceTypeProtein ?
	
	if ( [sequence sequenceType] != BCSequenceTypeDNA && [sequence sequenceType] != BCSequenceTypeRNA )
            return [[sequence copy] autorelease];
        
        
	symbolArray = [[self sequence] symbolArray];
	theComplement = [NSMutableArray array];
	theLimit = [symbolArray count];
    
    for ( loopCounter = 0 ; loopCounter < theLimit ; loopCounter++ )
	{
	symbol = (id)ARRAY_GET_VALUE_AT_INDEX(symbolArray, loopCounter);
        symbolComplement = [symbol complement];
		
		if ( symbolComplement != nil )
		{
			newLocation = ( reverse == NO ? loopCounter : 0 );

			ARRAY_INSERT_VALUE_AT_INDEX(theComplement, newLocation, symbolComplement);
		}
	 }
	 
     return [BCSequence sequenceWithSymbolArray: theComplement symbolSet: [[self sequence] symbolSet]];
}

@end
