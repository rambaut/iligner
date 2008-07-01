//
//  BCSequenceRNA.h
//  BioCocoa
//
//  Created by John Timmer on 8/12/04.
//  Copyright 2004 John Timmer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BCSequenceNucleotide.h"

@class BCNucleotideDNA, BCNucleotideRNA, BCSequenceDNA;

/*!
    @class      BCSequenceRNA
    @abstract   wrapper for RNA sequences composed of a series of BCNucleotideRNA objects
    @discussion BCSequnceRNA provides a container for RNA sequences composed of BCNucleotideRNA
    * objects.  In addition to the methods provided by the BCAbstractSequence superclass, it provides some 
    * methods for querying the sequence, such as "reverseComplementOfSequence" and will eventually
    * provide methods for finding the location of subsequences and translation
*/

@class BCSequenceRNA;

@interface BCSequenceRNA : BCSequenceNucleotide {
    
}

 
////////////////////////////////////////////////////////////////////////////
#pragma mark ‚ 
#pragma mark ‚INITIALIZATION METHODS
//  INITIALIZATION METHODS
////////////////////////////////////////////////////////////////////////////

/*!
@method     - (id)initWithString:(NSString *)entry convertingThymidines:(BOOL)convertFlag
@abstract   initializes a BCSequenceRNA object by passing it an NSString
@discussion  The implementation calls '-initWithString:' after
* modifying the sequence according to the convertFlag value.
* If convertFlag is YES, thymidines (T or t) are replaced by uraciles (U).
*/
- (id)initWithString:(NSString *)entry convertingThymidines:(BOOL)convertFlag;


/*!
@method     + (id) objectForSavedRepresentation: (NSString *)aSequence
@abstract   Returns a BCSequenceRNA object representing the sequence submitted 
@discussion all BC classes should implement a "savableRepresentation" and an 
*  "objectForSavedRepresentation" method to allow archiving/uncarchiving in
*  .plist formatted files.
*/
+ (id) objectForSavedRepresentation: (NSString *)aSequence;


////////////////////////////////////////////////////////////////////////////
#pragma mark ‚ 
#pragma mark ‚SEQUENCE INFORMATION
//  OBTAINING INFORMATION ABOUT THE SEQUENCE
////////////////////////////////////////////////////////////////////////////

/*!
    @method     - (BOOL) containsNonBaseSymbols
    @abstract   returns YES of any component is a gap or undefined.
*/
- (BOOL) containsNonBaseSymbols;

 
 
////////////////////////////////////////////////////////////////////////////
#pragma mark ‚ 
#pragma mark ‚DERIVING RELATED SEQUENCES
//  DERIVING OTHER SEQUENCES
////////////////////////////////////////////////////////////////////////////


/*!
    @method     - (BCSequenceDNA *) dnaSequenceEquivalent
    @abstract   Generates a BCSequenceDNA with each base of the receiver replaced with a BCSymbolDNA equivalent
*/
- (BCSequenceDNA *) dnaSequenceEquivalent;


@end
