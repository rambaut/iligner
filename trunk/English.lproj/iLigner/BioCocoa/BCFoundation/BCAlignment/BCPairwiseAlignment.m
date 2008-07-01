//
//  BCPairwiseAlignment.m
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

#import "BCSequenceAlignment.h"
#import "BCStringDefinitions.h"

#define DIAG (idxB - 1) * lenA + (idxA - 1)
#define LEFT idxB * lenA + (idxA - 1)
#define UP  (idxB - 1) * lenA + idxA


//Pointer for backtracking matrix
typedef enum {
    kNone = 0,
	kDiagonal,
    kLeft,
    kUp
} Pointers;

@interface BCSequenceAlignment ( PairwiseAlignment_Private )



@end

@implementation BCSequenceAlignment ( PairwiseAlignment )

+ (BCSequenceAlignment *)needlemanWunschAlignmentWithSequences:(NSArray *)theSequences properties:(NSDictionary *)properties {
	
	
	// obtaining substitution matrix
	BCScoreMatrix *substitutionMatrix = [properties objectForKey: BCSubstitutionMatrixProperty];
	
	// sequences 
	BCSequence *sequenceA = [theSequences objectAtIndex:0];
	BCSequence *sequenceB = [theSequences objectAtIndex:1];
	
	// converting sequences to c char pointer
	const char * seqA = [[sequenceA sequenceString] cString];
	const char * seqB = [[sequenceB sequenceString] cString];
	
	// currently only default gap penalties possible
	int gapCosts = [(NSNumber *)[properties objectForKey: BCDefaultGapPenaltyProperty] intValue];
	
	
	unsigned int lenA = [sequenceA length];
	unsigned int lenB = [sequenceB length];
	
	// initialize matrices
	int *backtracking = (int *)malloc( sizeof( int ) * ( lenA + 1 ) * ( lenB + 1 ) );
	int *dynMatrix    = (int *)malloc( sizeof( int ) * ( lenA + 1 ) * ( lenB + 1 ) );
	
	unsigned int idxA;
	unsigned int idxB;
	
	// upper left corner 
	dynMatrix[ 0 ] = [substitutionMatrix substituteChar:seqA[0] forChar:seqB[0]];
	backtracking[ 0 ] = kNone;
	
	// initialize first column & row
	for ( idxA = 1; idxA <= lenA; idxA++ ) {
	    backtracking[ idxA ] = kLeft; 
		dynMatrix[ idxA ] = idxA * gapCosts;
	}
	
	for ( idxB = 1; idxB <= lenB; idxB++ ) { 
		backtracking[ idxB * lenA ] = kUp;
		dynMatrix[ idxB * lenA ] = idxB * gapCosts;
	}
	
	
	// dynamic programming -- filling up the matrix
	for ( idxA = 1; idxA <= lenA; idxA++ ) {
		for ( idxB = 1; idxB <= lenB; idxB++ ) {
			unsigned int currPos = idxB * lenA + idxA;
		
			int substitutionScore = [substitutionMatrix substituteChar:seqA[idxA - 1] forChar:seqB[idxB - 1]];
			int diagScore = dynMatrix[ DIAG ] + substitutionScore;
			int rightScore = dynMatrix[ LEFT ] + gapCosts;
			int downScore = dynMatrix[ UP ] + gapCosts;
			
			// looking for the direction with the highest score
			// storing direction in backtracking matrix
			if ( diagScore >= rightScore ) {
				if ( diagScore > downScore ) {
				    backtracking[ currPos ] = kDiagonal;
					dynMatrix[ currPos ] = diagScore;
				}
				else {
					backtracking[ currPos ] = kUp;
					dynMatrix[ currPos ] = downScore;
				}
			}
			else {
				if ( rightScore > downScore ) {
					backtracking[ currPos ] = kLeft;
					dynMatrix[ currPos ] = rightScore;
				}
				else {
					backtracking[ currPos ] = kUp;
					dynMatrix[ currPos ] = downScore;
				}
			}
		}
	}
	
	// preparing for the walk back through the backtracking matrix
	int i = lenA;
	int j = lenB;
	int k = 0;
	char *a = ( char * ) malloc( (lenA + lenB) * sizeof(char));
	char *b = ( char * ) malloc( (lenA + lenB) * sizeof(char));
	
	// walk back and build up the alignment
	while ( backtracking[j * lenA + i ] != kNone ) {
		switch(backtracking[j * lenA + i ]){
			case kDiagonal :
				a[k] = seqA[i - 1];
				b[k] = seqB[j - 1];
				i--;
				j--;
				k++;
				break;
				
			case kLeft :
				a[k] = seqA[i - 1];
				b[k] = '-';
				i--;
				k++;
				break;
				
			case kUp :
				a[k] = '-';
				b[k] = seqB[j - 1];
				j--;
				k++;
				break;
		}
	}
	
	// get the reverse versions ( form tail > head to head > tail )
	char *an = (char *)malloc( sizeof(char) * k );
	char *bn = (char *)malloc( sizeof(char) * k );
	
	for(i=k-1;i>=0;i--) an[k-i-1] = a[i];
	for(j=k-1;j>=0;j--) bn[k-j-1] = b[j];

	// converting back to objc class
	// to prevent a compiler warning, the usingType argument has been removed - this needs to be reviewed
	//	BCSequence *alnA = [BCSequence sequenceWithString:[NSString stringWithCString:an length:k] usingType:BCSequenceTypeOther];
	//	BCSequence *alnB = [BCSequence sequenceWithString:[NSString stringWithCString:bn length:k] usingType:BCSequenceTypeOther];
	BCSequence *alnA = [BCSequence sequenceWithString:[NSString stringWithCString:an length:k]];
	BCSequence *alnB = [BCSequence sequenceWithString:[NSString stringWithCString:bn length:k]];
	
	//building up the alignment 
	return [[[BCSequenceAlignment alloc] initWithSequenceArray:[NSArray arrayWithObjects:alnA,alnB,nil]] autorelease];
}


+ (BCSequenceAlignment *)smithWatermanAlignmentWithSequences:(NSArray *)theSequences properties:(NSDictionary *)properties {
	return nil;
}


@end
