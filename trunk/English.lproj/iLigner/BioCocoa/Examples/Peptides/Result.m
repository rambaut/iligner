//
//  Result.m
//  Peptides
//
//  Created by Alexander Griekspoor on Zat Mar 19 2005.
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

#import "Result.h"

@implementation Result

//===========================================================================
//  Init & Dealloc
//===========================================================================

- (id)init
{
    if (self = [super init]){
	
    }
    
    return self;
}


- (void)dealloc				
{
    [super dealloc];
}


- copyWithZone:(NSZone *)zone {
    Result *copy = [[Result alloc]init];
    [copy setMw: [self mw]];
    [copy setDiff: [self diff]];
    [copy setRange: [self range]];
    return copy;
}


//===========================================================================
//  Accessor methods
//===========================================================================

- (float)mw
{
	return mw;
}

- (void)setMw:(float)newMw
{
	mw = newMw;
}

- (float)diff
{
	return diff;
}

- (void)setDiff:(float)newDiff
{
	diff = newDiff;
}

- (NSRange)range
{
	return range;
}

- (void)setRange:(NSRange)newRange
{
	range = newRange;
}



//===========================================================================
//  General methods
//===========================================================================

- (NSString *)description{
	return [NSString stringWithFormat: @"Peptide: %3.d-%3.d\t MW: %.3f\t (%.4f)", range.location + 1, range.location + range.length, mw, diff];
}


//===========================================================================
//  Sorting
//===========================================================================

- (NSComparisonResult)compare: (Result*) res{
    if ([self diff] > [res diff]){
        return NSOrderedDescending;
    }else if([self diff] < [res diff]){
        return NSOrderedAscending;
    }else{
        return NSOrderedSame;
    }
}

@end
