//
//  BCSequenceCodon.h
//  BioCocoa
//
//  Created by John Timmer on 9/17/04.
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

#import <Foundation/Foundation.h>
#import "BCSequence.h"

/*!
    @class          BCSequenceCodon
    @abstract       Wrapper for an ordered array of BCCodons, either DNA- or RNA-based
    @discussion     A subclass of BCSequence, this class handles access to an ordered list 
    *   of BCCodons.  In addition to the usual BCSequence objects, it contains references to the 
    *   genetic code used to generate the BCSequenceCodon, and the reading frame as a string 
    *   (ie - +1, -2).  Typically, BCCodonSequences are not created directly, but via the BCUtilTranslator
    *   class methods.
*/

@interface BCSequenceCodon : BCSequence {
    BCGeneticCodeName   usedCode;
    NSString            *readingFrame;
}


////////////////////////////////////////////////////////////////////////////
#if 0
#pragma mark �
#pragma mark �INITIALIZATION METHODS
#endif
//  INITIALIZATION METHODS
////////////////////////////////////////////////////////////////////////////

/*!
@method     - (id)initWithCodonArray:(NSArray *)anArray geneticCode:(BCGeneticCodeName)codeType frame:(NSString *)theFrame
 @abstract   Designated class initializer.  Arguments should be self explanatory.
	@discussion This is the designated initializer: other initializers call this method.
	* The designated initializer is thus different from the superclass.
	* It calls the designated initializer for the superclass.
 */
- (id)initWithCodonArray:(NSArray *)anArray geneticCode: (BCGeneticCodeName)codeType frame: (NSString *)theFrame;

/*!
	@method     - (id)initWithString:(NSString *)aString skippingUnknownSymbols:(BOOL)skipFlag;
	@abstract   initializes a BCSequenceCodon object by passing it an NSString.
	@discussion  The implementation overrides the superclass. If skipFlag 
	* is YES, any character that cannot be converted to a BCNucleotideDNA object is eliminated
	* from the final symbolArray.  Otherwise, they are replaced by "undefined" symbols.
	* As codons cannot be easily represented as single characters, this method attempts to determine if 
	* the sequence is likely to be RNA (no T's, U's present), and creates a BCSequenceRNA from it if so.  If not,
	* it creates a BCSequence.  Once a sequence is made, it sends it for translation,
	* and the returned codon array is sent to the designated initializer
	* 'initWithCodonArray:geneticCode:frame:'
*/
- (id)initWithString:(NSString *)aString skippingUnknownSymbols:(BOOL)skipFlag;

///*!
//	@method     - (id)initWithSymbolArray:(NSArray *)anArray
//	@abstract   initializes a BCSequenceCodon object by passing it an NSArray of BCSymbol.
//	@discussion The implementation overrides the superclass.
//	* This method scans the passed array for all BCSymbol objects, and creates
//	* a new BCSequence using them. Once a sequence is made, it sends it for translation,
//	* and the returned codon array is sent to the designated initializer
//	* 'initWithCodonArray:geneticCode:frame:'
//*/
//- (id)initWithSymbolArray:(NSArray *)anArray;


/*!
    @method     - (id)initWithCodonArray:(NSArray *)anArray
    @abstract   nitializes a BCSequenceCodon object by passing it an array of BCCodon objects
    @discussion Scans the provided array for BCSequenceCodons and adds them to the resulting sequence.  
    *   If the first codon is RNA, it will assume a BCUnversalCodeRNA origin, otherwise the DNA version.
    *   The reading frame is assumed to be +1.
*/
- (id)initWithCodonArray:(NSArray *)anArray;


/*!
	@method      + (BCSequenceCodon *)sequenceWithCodonArray:(NSArray *)anArray
	@abstract   creates and returns an autoreleased BCSequenceCodon object initialized with the codon array passed as argument
*/
+ (BCSequenceCodon *)sequenceWithCodonArray:(NSArray *)anArray;

- (BCSequence *)translate;

////////////////////////////////////////////////////////////////////////////
#if 0
#pragma mark �
#pragma mark �ORF/TRANSLATION METHODS
#endif
//  ORF/TRANSLATION METHODS
////////////////////////////////////////////////////////////////////////////

/*!
    @method     - (NSRange) longestOpenReadingFrame
    @abstract   returns the longest stretch of codons that don't code for a stop or undefined aa.
*/
- (NSRange) longestOpenReadingFrame;

/*!
    @method      - (NSRange) longestOpenReadingFrameUsingStartCodon: (id)codon
    @abstract   returns the longest stretch of codons that starts with (codon) and doesn't contain a stop or undefined aa.
    @discussion the start codon argument can be provided as a single BCCodon or as an array of codons, for situations/sepcies
    *   where there is more than one start codon.  
*/
- (NSRange) longestOpenReadingFrameUsingStartCodon: (id)codon;


/*!
    @method     - (NSArray *) openReadingFramesLongerThanCutoff: (unsigned int)cutoff
    @abstract   returns all open reading frames longer than the supplied cutoff
    @discussion The return array contains NSValues, coding for NSRanges.  if no open reading
    *   frames are found, it will return an empty array.  Note the BioCocoa provides a method
    *   in BCUtilValueAdditions that allows the sorting of these values based on the range length.
*/
- (NSArray *) openReadingFramesLongerThanCutoff: (unsigned int)cutoff;

/*!
    @method      - (NSArray *) openReadingFramesLongerThanCutoff: (unsigned int)cutoff usingStartCodon: (id)codon
    @abstract   behaves identically to "openReadingFramesLongerThanCutoff:", but requires a start codon to initiate the ORF
*/
- (NSArray *) openReadingFramesLongerThanCutoff: (unsigned int)cutoff usingStartCodon: (id)codon;


/*!
    @method     - (BCSequence *) translationOfRange: (NSRange) theRange
    @abstract   provides a protein sequence code for by the sub-sequence of codons within theRange
    @discussion This method will terminate short of the end of theRange if a stop codon or an undefined codon
    *   is encountered
*/
- (BCSequence *) translationOfRange: (NSRange) theRange;


/*!
    @method      - (BCSequence *) translationOfRange: (NSRange) theRange usingStartCodon: (id)codon
    @abstract   behaves identically to "translationOfRange:" but requires a start codon to initiate translation
*/
- (BCSequence *) translationOfRange: (NSRange) theRange usingStartCodon: (id)codon;


/*!
    @method     - (NSArray *) translationsLongerThanCutoff: (unsigned int)cutoff
    @abstract   provides an array of BCSequences encoded by the receiver which are longer than cutoff
*/
- (NSArray *) translationsLongerThanCutoff: (unsigned int)cutoff;


/*!
    @method      - (NSArray *) translationsLongerThanCutoff: (unsigned int)cutoff usingStartCodon: (id)codon
    @abstract   behaves identically to "translationsLongerThanCutoff:", but requires a start codon to initiate translation
*/
- (NSArray *) translationsLongerThanCutoff: (unsigned int)cutoff usingStartCodon: (id)codon;




////////////////////////////////////////////////////////////////////////////
#if 0
#pragma mark �
#pragma mark �BASIC INFO
#endif
//  BASIC INFO
////////////////////////////////////////////////////////////////////////////

/*!
    @method     - (BCGeneticCodeName) usedCode
    @abstract   returns the genetic code used to generate the codon sequence
 */
- (BCGeneticCodeName) usedCode;


/*!
    @method     - (NSString *)readingFrame
    @abstract   returns the reading frame ("+2", "-1", etc.) used to generate the codon sequence
*/
- (NSString *)readingFrame;


/*!
    @method     - (NSRange) convertRangeToOriginalSequence: (NSRange)entry
    @abstract   converts a range in the codon sequence to the equivalent range in the coding sequence
    @discussion in many cases, the ranges of locations in a codon sequence (ie - ORF locations) need to be
    *   located in the coding sequence of DNA or RNA bases.  This method should allow the ranges generated by
    *   methods in this class to be converted to the equivalent ranges for use with BCSequence or RNA classes.
    *   The method accounts for reading frame.
*/
- (NSRange) convertRangeToOriginalSequence: (NSRange)entry;

@end
