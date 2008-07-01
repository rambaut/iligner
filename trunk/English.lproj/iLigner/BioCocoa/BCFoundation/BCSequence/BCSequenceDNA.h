//
//  BCSequenceDNA.h
//  BioCocoa
//
//  Created by John Timmer on 8/12/04.
//  Copyright 2004 The BioCocoa Project. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BCSequenceNucleotide.h"



/*!
    @class      BCSequenceDNA
    @abstract   wrapper for DNA sequences composed of a series of BCNucleotideDNA objects
    @discussion BCSequenceDNA provides a container for DNA sequences composed of BCNucleotideDNA
    * objects.  In addition to the methods provided by the BCAbstractSequence superclass, it provides some 
    * methods for querying the sequence, such as "reverseComplementOfSequence" and will eventually
    * provide methods for finding the location of subsequences and translation
*/

@class BCSequenceRNA;

@interface BCSequenceDNA : BCSequenceNucleotide {
    
}

 
////////////////////////////////////////////////////////////////////////////
#pragma mark ‚ 
#pragma mark ‚INITIALIZATION METHODS
//  INITIALIZATION METHODS
////////////////////////////////////////////////////////////////////////////

/*!
@method     + (id) objectForSavedRepresentation: (NSString *)aSequence
@abstract   Returns a BCSequenceDNA object representing the sequence submitted 
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
    @method     - (BCSequenceRNA *) rnaSequenceEquivalent
     @abstract   Generates a BCSequenceRNA with each base of the receiver replaced with a BCSymbolRNA equivalent
*/
- (BCSequenceRNA *) rnaSequenceEquivalent;



@end
