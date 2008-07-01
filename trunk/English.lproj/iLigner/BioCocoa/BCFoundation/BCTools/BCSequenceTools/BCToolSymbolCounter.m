//
//  BCToolSymbolCounter.m
//  BioCocoa
//
//  Created by Koen van der Drift on 10/27/04.
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

#import "BCToolSymbolCounter.h"
#import "BCSequence.h"
#import "BCSymbol.h"

#import "BCFoundationDefines.h"
#import "BCInternal.h"

@implementation BCToolSymbolCounter

+ (BCToolSymbolCounter *) symbolCounterWithSequence: (BCSequence *) list
{
     BCToolSymbolCounter *symbolCounter = [[BCToolSymbolCounter alloc] initWithSequence: list];
     
	 return [symbolCounter autorelease];
}

- (NSCountedSet *)countSymbols
{ 	
	return 	[self countSymbolsForRange: NSMakeRange(0, [[self sequence] length])];
}

- (NSCountedSet *)countSymbolsForRange: (NSRange)aRange
{
    DECLARE_INDEX(loopCounter);
    BCSymbol		*aSymbol;
    NSCountedSet	*aCountedSet = [[NSCountedSet alloc] init];
    NSArray			*symbolArray = [[self sequence] symbolArray];
	
    for ( loopCounter = aRange.location; loopCounter < aRange.location + aRange.length; loopCounter++ )
	{
	  aSymbol = (BCSymbol *)ARRAY_GET_VALUE_AT_INDEX(symbolArray, loopCounter);
        [aCountedSet addObject: aSymbol];
    }
	
	return [aCountedSet autorelease];
}

@end
