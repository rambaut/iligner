//
//  BCSequence.h
//  BioCocoa
//
//  Created by Koen van der Drift on 12/14/2004.
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
#import "BCFoundationDefines.h"

@class BCSymbol;
@class BCSymbolSet;
@class BCAnnotation;


/*!
    @class      BCSequence
    @abstract   Class that holds a biological sequence (DNA, protein, etc.)
    @discussion This class is used for all types of sequences. The sequence type
	* is determined by the symbolset, which defines the BCSymbols that are allowed
	* to be in the sequence. Compare this to NSString, where the encoding determines the
	* type of string that is inside the NSString object.
*/

@interface BCSequence : NSObject <NSCopying>
{
	NSData				*sequenceData;		// holds a char array with the sequence string
	BCSymbolSet			*symbolSet;			// determines the BCSymbols that can be in this sequence
    NSArray				*symbolArray;		// array of BCSymbol objects to represent the sequence
	NSMutableDictionary	*annotations;		// annotations fot this sequence
	BCSequenceType		sequenceType;		// defines the sequence type 
}

////////////////////////////////////////////////////////////////////////////
//  OBJECT METHODS START HERE
//
#if 0
#pragma mark â  
#pragma mark â INITIALIZATION METHODS
#endif
//
//  INITIALIZATION
////////////////////////////////////////////////////////////////////////////

/*!
@method     - (id)initWithSymbolArray:(NSArray *)anArray symbolSet:(BCSymbolSet *)aSet;
 @abstract   initializes a BCSequence object by passing it an NSArray of BCSymbol.
 @discussion
 * The method scans the passed array for all BCSymbol objects, and creates
 * a new BCSequence using them. The symbol set is used to filter the passed symbols.
 * The symbol set instance should be the same sequence type as the sequence, e.g. should
 * contain DNA symbols if used to initialize a DNA sequence. If not the right sequence type,
 * or if the symbolSet is nil, then the implementation guesses the most likely
 * symbolSet based on the symbols in the array.
 */
- (id)initWithSymbolArray:(NSArray *)anArray symbolSet:(BCSymbolSet *)aSet;

- (id)initWithData:(NSData *)aData symbolSet:(BCSymbolSet *)aSet;


/*!
@method     - (id)initWithSymbolArray:(NSArray *)anArray
 @abstract   initializes a BCSequence object by passing it an NSArray of BCSymbol.
 @discussion This method calls '-initWithSymbolArray:symbolSet'
 * using the default symbol set for the class.
 * The method scans the passed array for all BCSymbol objects compatible with the
 * type of sequence being created.
 */
- (id)initWithSymbolArray:(NSArray *)anArray;


/*!
@method     - (id)initWithString:(NSString *)aString symbolSet:(BCSymbolSet *)aSet;
 @abstract   initializes a BCSequence object by passing it an NSString.
 @discussion This is the designated initializer.
 * This method will attempt to create an array of BCSymbols using the
 * characters found in the string.
 * The BCSymbols created will depend on the symbol set passed as argument.
*/
- (id)initWithString:(NSString *)aString symbolSet:(BCSymbolSet *)aSet;


/*!
    @method     - (id)initWithString:(NSString*)aString
 @abstract   initializes a BCSequence object by passing it an NSString.
 @discussion This method calls initWithString:symbolSet:
 * using the default symbol set of the class as argument.
 * The method should only be called on a concrete subclass.
 * This method will create an array of BCSymbols using the
 * characters found in the string. The type of BCSymbols created
 * will depend on the the sequence type, e.g. a DNA sequence
 * will only use DNA bases.
*/
- (id)initWithString:(NSString*)aString;


/*!
    @method     - (id)initWithString:(NSString*)aString range:(NSRange)aRange;
    @abstract   initializes a BCSequence object by passing it an NSString and a range.
    @discussion This method calls '-initWithString:'. Note that the range is 0-based.
*/
- (id)initWithString:(NSString*)aString range:(NSRange)aRange;
- (id)initWithString:(NSString*)aString range:(NSRange)aRange symbolSet:(BCSymbolSet *)aSet;
- (id)initWithThreeLetterString:(NSString*)aString symbolSet:(BCSymbolSet *)aSet;

/*!
    @method     + (BCSequence)sequenceWithString:(NSString *)aString;
	@abstract   creates and returns an autoreleased sequence object initialized with the string passed as argument
	@discussion This method calls 'initWithString:'
*/
+ (BCSequence *)sequenceWithString:(NSString *)aString;

/*!
	@method     + (BCSequence *)sequenceWithString:(NSString *)aString symbolSet:(BCSymbolSet *)aSet;
	@abstract   creates and returns an autoreleased sequence object initialized with the string passed as argument
	@discussion This method calls 'initWithString:symbolSet:'.
 */
+ (BCSequence *)sequenceWithString:(NSString *)aString symbolSet:(BCSymbolSet *)aSet;

/*!
	@method     + (BCSequence *)sequenceWithThreeLetterString:(NSString *)aString symbolSet:(BCSymbolSet *)aSet;
	@abstract   creates and returns an autoreleased sequence object initialized with a three-letter code string passed as argument
	@discussion This method calls 'initWithString:symbolSet:'.
*/
+ (BCSequence *)sequenceWithThreeLetterString:(NSString *)aString symbolSet:(BCSymbolSet *)aSet;

	/*!
    @method     + (BCSequence *)sequenceWithSymbolArray:(NSArray *)entry
    @abstract   creates and returns an autoreleased sequence object initialized with the array of BCSymbols passed as argument
	@discussion This method calls 'initWithSymbolArray:'
*/
+ (BCSequence *)sequenceWithSymbolArray:(NSArray *)entry;

/*!
    @method     + (BCSequence *)sequenceWithSymbolArray:(NSArray *)entry
    @abstract   creates and returns an autoreleased sequence object initialized with the array of BCSymbols passed as argument
	@discussion This method calls 'initWithSymbolArray:symbolSet'
*/
+ (BCSequence *)sequenceWithSymbolArray:(NSArray *)entry symbolSet: (BCSymbolSet *)aSet;

/*!
    @method     + (BCSequence *) objectForSavedRepresentation:(NSString *)sequence
    @abstract   Returns a BCSequence object representing the sequence submitted 
    @discussion all BC classes should implement a "savableRepresentation" and an 
    *  "objectForSavedRepresentation" method to allow archiving/uncarchiving in
    *  .plist formatted files.
*/
+ (BCSequence *)objectForSavedRepresentation:(NSString *)sequence;

/*!
    @method    - (NSString *)convertThreeLetterStringToOneLetterString: (NSString *)aString symbolSet: (BCSymbolSet *)aSet
	@abstract  Converts a 3-letter code string to a 1-letter code string 
*/
- (NSString *)convertThreeLetterStringToOneLetterString:(NSString *)aString symbolSet: (BCSymbolSet *)aSet;

////////////////////////////////////////////////////////////////////////////
#if 0
#pragma mark â  
#pragma mark â SEQUENCE TYPE DETERMINATION
#endif
//
//  INFORMATIONAL METHODS
////////////////////////////////////////////////////////////////////////////

/*!
    @method     - (BCSequenceType)sequenceTypeForString:(NSString *)string;
	@abstract   Returns the guessed sequence type of an arbitrary string.
*/
- (BCSequenceType)sequenceTypeForString:(NSString *)string;

/*!
    @method     - (BCSequenceType)sequenceTypeForData:(NSData *)aData;
	@abstract   Returns the guessed sequence type from sequence data.
*/
- (BCSequenceType)sequenceTypeForData:(NSData *)aData;

/*!
    @method     - (BCSequenceType)sequenceTypeForSymbolArray:(NSArray *)anArray;
	@abstract   Returns the guessed sequence type of an array of BCSymbols.
*/
- (BCSequenceType)sequenceTypeForSymbolArray:(NSArray *)anArray;


////////////////////////////////////////////////////////////////////////////
#if 0
#pragma mark â  
#pragma mark â OBTAINING SEQUENCE INFORMATION
#endif
//
//  INFORMATIONAL METHODS
////////////////////////////////////////////////////////////////////////////


/*!
    @method     - (NSData *) sequenceData
    @abstract   returns and NSData object containing the sequenceData
*/
- (NSData *) sequenceData;


/*!
    @method     - (const unsigned char *) bytes;
    @abstract   returns the raw bytes representing the sequence
*/
- (const unsigned char *) bytes;


/*!
    @method     - (BCSymbolSet) symbolSet
    @abstract   returns the symbolSet associated with this sequence
*/
- (BCSymbolSet *) symbolSet;

/*
@method     - (void) setSymbolSet(BCSymbolSet):symbolSet
@abstract   sets the smbolSet associated with this sequence
*/
- (void) setSymbolSet:(BCSymbolSet *)symbolSet;



/*!
    @method     - (BCSequenceType) sequenceType
    @abstract   returns the type of sequence
*/
- (BCSequenceType) sequenceType;


/*!
@method     - (unsigned int) length
@abstract   returns the length of the sequence
*/
- (unsigned int) length;


/*!
    @method     - (id)symbolAtIndex: (int)theIndex
    @abstract   returns the BCSymbol object at index.  Returns nil if index is out of bounds.
*/
- (BCSymbol *)symbolAtIndex: (int)theIndex;




/*!
    @method     - (BOOL) containsAmbiguousSymbols
    @abstract   determines whether any symbols in the sequence are compound symbols.
*/
- (BOOL) containsAmbiguousSymbols;


/*!
    @method     - (NSString *)sequenceString
    @abstract   returns the sequence string of the object.
    @discussion returns an NSString containing a one letter-code string of the sequence.
	* This method is useful when the sequence needs to be displayed in a view.
*/
- (NSString*)sequenceString;


/*!
    @method    - (NSArray *)symbolArray
      @abstract   returns a ponter to the array of BCSymbol objects that make up the sequence.
      @discussion The array returned is the object used internally by BCSequence.
	  * The array obtained should only be used for reading, and should not be modified by the caller.	 
      * To modify the sequence, instead use one of the
	  * convenience methods setSymbolArray, removeSymbolsInRange, removeSymbolsAtIndex,
	  * or insertSymbolsFromSequence:atIndex. 
*/
- (NSArray *)symbolArray;


/*!
    @method    - (void)clearSymbolArray
    @abstract   clears the symbol array
    @discussion Removes all symbols from the symbol array and sets the array to nil.
    *   Call this method first to re-generate the symbolArray after the sequence has been modified.
*/
- (void)clearSymbolArray;

/*!
    @method    - (NSString *)subSequenceStringInRange:(NSRange)aRange
    @abstract   returns a subsequence in string form
    @discussion returns an NSString containing a subsequence specified by aRange (0-based).
    *   Returns nil if any part of aRange is out of bounds.
*/
- (NSString *)subSequenceStringInRange:(NSRange)aRange;

/*!
    @method    - (NSString *)sequenceStringFromSymbolArray:(NSArray *)anArray
    @abstract   returns an NSString representation of a symbolArray
*/
- (NSString *)sequenceStringFromSymbolArray:(NSArray *)anArray;

/*!
    @method    - (NSArray *)subSymbolArrayInRange:(NSRange)aRange
    @abstract   returns a sub-symbolarray form
    @discussion returns an NSArray containing a subsequence specified by aRange (0-based).
    *   Returns nil if any part of aRange is out of bounds.
*/
- (NSArray *)subSymbolArrayInRange:(NSRange)aRange;

/*!
    @method    - (BCSequence *)subSequenceInRange:(NSRange)aRange
    @abstract   returns a sub-symbollist
    @discussion returns an BCSequence containing a sub-symbollist specified by aRange (0-based).
    *   Returns nil if any part of aRange is out of bounds.
*/
- (BCSequence *)subSequenceInRange:(NSRange)aRange;


/*!
     @method     - (NSString *) savableRepresentation
     @abstract   Returns the sequenceString for saving.
     @discussion All BCSymbol classes implement this method to provide a standard way of
     *  accessing their data in a format that can be stored in Apple .plist files within
     *  arrays or dictionaries.
*/
- (NSString *) savableRepresentation;


/*!
     @method     - (NSString *) description
     @abstract   Overrides NSObject's description - describes the object in string form
     @discussion In the default implementation, returns the sequence string.  Useful primarily
     *  for debugging.
*/
- (NSString *) description;

/*!
    @method     addAnnotation
    @abstract   Add a BCAnnotation object to the annotations dictionary
*/

- (void) addAnnotation:(BCAnnotation *)annotation;
/*!
    @method     addAnnotation:forKey: key
    @abstract   Add an annotation to the annotations dictionary
    @discussion Using two strings for the key and value, this method adds an annotation
*/
- (void) addAnnotation:(NSString *)annotation forKey: (NSString *) key;

/*!
    @method     annotationForKey:key:
    @abstract   Get the annpotation for a specific key
    @discussion Returns the annotation for a given key, which is passed as an NSString
*/
- (id) annotationForKey: (NSString *) key;

/*!
    @method      annotations
    @abstract   Returns the annotations dictionary
*/
- (NSMutableDictionary *) annotations;

/*!
    @method     setAnnotations:
    @abstract   Set the annotations dictionary
    @discussion This will completely replace the current annotations dictaionry. All key-value pairs will be lost
	* and replaced by those in the new dictionary.
*/
//- (void)setAnnotations:(NSMutableDictionary *)aDict;


////////////////////////////////////////////////////////////////////////////
#if 0
#pragma mark â  
#pragma mark â MANIPULATING THE SEQUENCE
#endif
//
//  SEQUENCE MANIPULATION METHODS
////////////////////////////////////////////////////////////////////////////


/*!
    @method    - (void)setSymbolArray:(NSArray *)anArray
    @abstract   sets the symbollist as an array of BCSymbol objects.
*/
- (void)setSymbolArray:(NSArray *)anArray;


/*!
    @method   - (void)removeSymbolsInRange:(NSRange)aRange
    @abstract   deletes a sub-symbollist.
    @discussion deletes the BCSymbols in the sub-symbollist specified by aRange (0-based).
*/
- (void)removeSymbolsInRange:(NSRange)aRange;


/*!
    @method   - (void)removeSymbolAtIndex:(int)index
    @abstract   deletes one symbol.
    @discussion deletes a BCSymbol located at index (0-based).
*/
- (void)removeSymbolAtIndex:(int)index;


/*!
    @method   - (void)insertSymbolsFromSequence:(BCSequence *)seq atIndex:(int)index
    @abstract   inserts a BCSequence into the current symbolarray, starting at index (0-based)
    @discussion inserts the BCSequence that is in the first argument in the current BCSequence.
*/
- (void)insertSymbolsFromSequence:(BCSequence *)seq atIndex:(int)index;



////////////////////////////////////////////////////////////////////////////
#if 0
#pragma mark â  
#pragma mark â DERIVING RELATED SEQUENCES
#endif
//  DERIVING OTHER SEQUENCES
////////////////////////////////////////////////////////////////////////////

/*!
    @method      - (BCSequence *) complement
	@abstract   returns a BCSequence that is the reverse of the one queried.
*/
- (BCSequence *) reverse;


/*!
    @method      - (BCSequence *) complement
	@abstract   returns a BCSequence that is the complement of the one queried.
    @discussion This is a convenience method that calls BCToolComplement.
*/
- (BCSequence *) complement;


/*!
    @method      - (BCSequence *) reverseComplement
	@abstract   returns a BCSequence that is the reverse complement of the one queried.
    @discussion This is a convenience method that calls BCToolComplement.
*/
- (BCSequence *) reverseComplement;

////////////////////////////////////////////////////////////////////////////
#if 0
#pragma mark â  
#pragma mark â FINDING SUBSEQUENCES
#endif
//  FINDING SUBSEQUENCES
////////////////////////////////////////////////////////////////////////////

- (NSArray *) findSequence: (BCSequence *) entry;
- (NSArray *) findSequence: (BCSequence *) entry usingStrict: (BOOL) strict;
- (NSArray *) findSequence: (BCSequence *) entry usingStrict: (BOOL) strict firstOnly: (BOOL) firstOnly;
- (NSArray *) findSequence: (BCSequence *) entry usingStrict: (BOOL) strict firstOnly: (BOOL) firstOnly usingSearchRange: (NSRange) range;

@end
