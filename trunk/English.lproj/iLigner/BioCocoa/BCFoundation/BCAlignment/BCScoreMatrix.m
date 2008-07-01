//
//  BCScoreMatrix.m
//  BioCocoa
//
//  Created by Philipp Seibel on 10.03.05.
//  Copyright (c) 2005 The BioCocoa Project. All rights reserved.
//
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

#import "BCScoreMatrix.h"


@implementation BCScoreMatrix

- (id)initWithSymbolSet:(BCSymbolSet *)symbolSet matrix:(int *)aMatrix {
	self = [super init];
	if ( self ) {
		symbols = [symbolSet allSymbols];
		symbolCount = [symbols count];
		
		scoreMatrix = (int *)malloc( sizeof( int ) * 128 * 128 );
		memcpy( scoreMatrix, aMatrix, sizeof( int ) * 128 * 128 );
	}
	return self;
}

- (BOOL)containsSymbol:(BCSymbol *)aSymbol {
	return [symbols containsObject: aSymbol];
}

- (int)substituteSymbol:(BCSymbol *)symbolA forSymbol:(BCSymbol *)symbolB {
	if ( ![self containsSymbol:symbolA] || ![self containsSymbol:symbolB] ) {
		// handle wrong symbols !!!
	}
	
	char idxA = [symbolA symbolChar];
	char idxB = [symbolB symbolChar];
	
	return [self substituteChar:idxA forChar:idxB];
}

- (int)substituteChar:(char)charA forChar:(char)charB {
	return scoreMatrix[ charA * 128 + charB ];
}

- (void)dealloc {
	[symbols release];
	[super dealloc];
}

@end
