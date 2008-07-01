//
//  BCAlignment.m
//  BioCocoa
//
//  Created by Philipp Seibel on 09.03.05.
//  Copyright (c) 2005 The BioCocoa Project. All rights reserved.
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

#import "BCSequenceAlignment.h"
#import "BCStringDefinitions.h"


@implementation BCSequenceAlignment

- (id)initWithSequenceArray:(NSArray *)theSequenceArray {
	self = [super init];
	if ( self ) {
		sequenceArray = [theSequenceArray retain];
	}
	return self;
}

- (void)dealloc {
	[sequenceArray release];
	[super dealloc];
}

@end

@implementation BCSequenceAlignment ( AlignmentQuerying )

- (BCSequence *)sequenceAtIndex:(unsigned int)aIndex {
	return (BCSequence *)[sequenceArray objectAtIndex: aIndex];
}

- (BCSequenceAlignment *)alignmentInRange:(NSRange)aRange {
	return nil;
}

- (NSArray *)symbolsForColumnAtIndex:(unsigned int)aColumn {
	return nil;
}

- (unsigned int)length {
	return [[self sequenceAtIndex: 0] length];
}

- (unsigned int)sequenceCount {
	return [sequenceArray count];
}

- (BCSymbolSet *)symbolSet {
	return nil;
}

@end
