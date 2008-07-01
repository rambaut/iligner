//
//  BCToolMassCalculator.m
//  BioCocoa
//
//  Created by Koen van der Drift on Wed Aug 25 2004.
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

#import "BCToolMassCalculator.h"
#import "BCToolSymbolCounter.h"
#import "BCSequence.h"
#import "BCSymbol.h"

#import "BCFoundationDefines.h"

@implementation BCToolMassCalculator


-(id) initWithSequence:(BCSequence *)list
{
    if ( (self = [super initWithSequence:list]) )
    {
		[self setMassType: BCMonoisotopic];
	}
	
	return self;
}


+ (BCToolMassCalculator *) massCalculatorWithSequence: (BCSequence *)list
{
     BCToolMassCalculator *massCalculator = [[BCToolMassCalculator alloc] initWithSequence: list];
     
	 return [massCalculator autorelease];
}


- (void)setMassType:(BCMassType)type
{
	massType = type;
}

-(NSArray *)calculateMass{
	return [self calculateMassForRange: NSMakeRange(0, [[self sequence] length])];
}


-(NSArray *)calculateMassForRange: (NSRange)aRange
{
	float			totalMin, totalMax;
    BCSymbol		*aSymbol;
	
	totalMin = totalMax = 0.0;

#if 1
	unsigned		symbolCount;
	BCToolSymbolCounter	*symbolCounter = [BCToolSymbolCounter symbolCounterWithSequence: [self sequence]];
	NSCountedSet	*sequenceSet = [symbolCounter countSymbolsForRange: aRange];
   
	NSEnumerator *objectEnumerator = [sequenceSet objectEnumerator];

    while ( (aSymbol = [objectEnumerator nextObject]) )
	{		
		symbolCount = [sequenceSet countForObject: aSymbol];

		totalMin += ((float)symbolCount * [aSymbol minMassUsingType: massType]);
		totalMax += ((float)symbolCount * [aSymbol maxMassUsingType: massType]);
	}

#else
    CFIndex			i;
	NSArray			*array = [sequence symbolArray];
	for ( i = 0; i < [array count]; i++ )
	{
		aSymbol = (BCSymbol *)CFArrayGetValueAtIndex( (CFArrayRef) array, i);				// use NSData instead ?

		totalMin += [aSymbol minMassUsingType: massType];
		totalMax += [aSymbol maxMassUsingType: massType];
	}
#endif	
	if ( totalMin )
	{
		totalMin += [self addWater];
		totalMax += [self addWater];
	}
	
	return [NSArray arrayWithObjects: 
				[NSNumber numberWithFloat:totalMin], [NSNumber numberWithFloat: totalMax], nil];
}


-(float) addWater
{
	// add water - cheers!
	if ( massType == BCMonoisotopic )
		return 2 * hydrogenMonoisotopicMass + oxygenMonoisotopicMass;
	else if ( massType == BCAverage )
		return 2 * hydrogenAverageMass + oxygenAverageMass;
	else
		return 0;
}


@end
