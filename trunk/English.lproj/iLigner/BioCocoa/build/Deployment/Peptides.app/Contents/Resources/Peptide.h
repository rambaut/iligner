//
//  Peptide.h
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

//#import <Cocoa/Cocoa.h>
#import <BioCocoa/BCFoundation.h>

@interface Peptide : BCSequence
{
    //===========================================================================
    //  Variables and properties
    //===========================================================================
    
    float mw;			// molecular weight
    float diff;			// absolute difference from target MW
	NSRange range;		// range within the searched sequence
}

//===========================================================================
//  Init & Dealloc
//===========================================================================

//- (id)init;
//- (void)dealloc;
//- (id)copyWithZone: (NSZone *)zone;

//===========================================================================
//  Accessor methods
//===========================================================================

- (float)mw;
- (void)setMw:(float)newMw;

- (float)diff;
- (void)setDiff:(float)newDiff;

- (NSRange)range;
- (void)setRange:(NSRange)newRange;


//===========================================================================
//  General methods
//===========================================================================


//===========================================================================
//  Sorting
//===========================================================================

- (NSComparisonResult)compare: (Peptide*) res;

@end
