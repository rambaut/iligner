//
//  BCToolHydropathyCalculator.m
//  BioCocoa
//
//  Created by Koen van der Drift on 4/30/2005.
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

#import "BCToolHydropathyCalculator.h"
#import "BCSequence.h"
#import "BCAminoAcid.h"


@implementation BCToolHydropathyCalculator

+ (BCToolHydropathyCalculator *) hydropathyCalculatorWithSequence: (BCSequence *) list
{
	BCToolHydropathyCalculator *hydropathyCalculator = [[BCToolHydropathyCalculator alloc] initWithSequence: list];
	[hydropathyCalculator setSlidingWindowSize: 1];	// default value

	return [hydropathyCalculator autorelease];
}

- (BCHydropathyType)hydropathyType
{
	return hydropathyType;
}

- (void)setHydropathyType:(BCHydropathyType)type
{
	hydropathyType = type;
}

- (int)slidingWindowSize
{
	return slidingWindowSize;
}

- (void)setSlidingWindowSize:(int)newSize
{
	slidingWindowSize = newSize;
}

-(NSArray *)calculateHydropathy
{
	return [self calculateHydropathyForRange: NSMakeRange(0, [[self sequence] length])];
}


-(NSArray *)calculateHydropathyForRange: (NSRange)aRange
{
	unsigned int	len, start, i, j;
	BCAminoAcid		*aa;
	NSMutableArray	*tempArray = [NSMutableArray array];
//	NSArray			*sequenceArray = [[self sequence] symbolArray];
//	CFIndex			i, j;
	float			sum;
	
	len = [[self sequence] length];
	
	if ( len > 0 )
	{
		start = aRange.location + 1;
		
		for ( i = 0; i < (len - [self slidingWindowSize]); i++ )
		{
			sum = 0.0;
			
			for ( j = 0; j < [self slidingWindowSize]; j++ )
			{
	//			aa = (BCAminoAcid *)CFArrayGetValueAtIndex((CFArrayRef) sequenceArray, i+j );				// use NSData instead ?
				aa = (BCAminoAcid *) [[self sequence] symbolAtIndex: (i+j)];
				sum += (hydropathyType == BCKyteDoolittle ? [aa kyteDoolittleValue] : [aa hoppWoodsValue]);
			}
			
			[tempArray addObject: NSStringFromPoint( NSMakePoint( (float) (start + i), (float) (sum / [self slidingWindowSize] ) ) ) ];
		}
	}
	
	return	[NSArray arrayWithArray: tempArray];
}


@end
