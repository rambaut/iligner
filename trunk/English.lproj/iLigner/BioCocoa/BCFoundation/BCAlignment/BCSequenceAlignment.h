//
//  BCAlignment.h
//  BioCocoa
//
//  Created by Philipp Seibel on 09.03.05.
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

#import <Foundation/Foundation.h>
#import "BCSequence.h"
#import "BCScoreMatrix.h"

@class BCSymbolSet, BCAnnotation;


/*!
@class      BCAlignment
@abstract   Represents a alignment of BCSequences
@discussion 
*/

@interface BCSequenceAlignment : NSObject {
  NSArray *sequenceArray;
}

- (id)initWithSequenceArray:(NSArray *)theSequenceArray;

@end

@interface BCSequenceAlignment ( AlignmentQuerying )

/*!
@method     - (BCSequence *)sequenceAtIndex:(unsigned int)aIndex;
@abstract   obtaining the BCSequence at the given index
@discussion 
*/
- (BCSequence *)sequenceAtIndex:(unsigned int)aIndex;

/*!
@method     - (BCAlignment *)alignmentInRange:(NSRange)aRange;
@abstract   returns a subalignment
@discussion 
*/
- (BCSequenceAlignment *)alignmentInRange:(NSRange)aRange;

/*!
@method     - (NSArray *)symbolsForColumnAtIndex:(unsigned int)aColumn;
@abstract   returns a NSArray containing the symbols at the given alignment column
@discussion 
*/
- (NSArray *)symbolsForColumnAtIndex:(unsigned int)aColumn;

/*!
@method     - (unsigned int)length;
@abstract   obtaining the length of the alignment
@discussion 
*/
- (unsigned int)length;

- (unsigned int)sequenceCount;

/*!
@method     - (BCSymbolSet *)symbolSet;
@abstract   obtaining the BCSymbolSet corresponding to the aligned BCSequences
@discussion 
*/
- (BCSymbolSet *)symbolSet;

@end

@interface BCSequenceAlignment ( AlignmentAnnotation )

/*!
@method     - (BCAnnotation *)annotationForKey:(NSString *)theKey;
@abstract   obtaining the BCAnnotation for the given key
@discussion 
*/
- (BCAnnotation *)annotationForKey:(NSString *)theKey;

@end


@interface BCSequenceAlignment ( PairwiseAlignment )

+ (BCSequenceAlignment *)needlemanWunschAlignmentWithSequences:(NSArray *)theSequences properties:(NSDictionary *)properties;
+ (BCSequenceAlignment *)smithWatermanAlignmentWithSequences:(NSArray *)theSequences properties:(NSDictionary *)properties;

@end


