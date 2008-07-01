//
//  BCAbstractSequence.h
//  BioCocoa
//
//  Created by Koen van der Drift on 12/14/2004.
//  Copyright 2004 The BioCocoa Project. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BCFoundationDefines.h"

@class BCSymbol;
@class BCSymbolSet;
@class BCAnnotation;


/*!
    @class      BCAbstractSequence
    @abstract   Superclass of all individual sequences (DNA, protein, etc.)
    @discussion This class should not be instantiated, but acts to provide some common methods
    * and variables that are used by all subclasses.
*/

@interface BCAbstractSequence : NSObject <NSCopying>
{
	BCSymbolSet			*symbolSet;
    NSMutableArray		*symbolArray;			 // array of BCSymbol objects to represent the sequence
	NSMutableDictionary	*annotations;			//coming soon!!
}

////////////////////////////////////////////////////////////////////////////
//  OBJECT METHODS START HERE
//
#pragma mark â  
#pragma mark â INITIALIZATION METHODS
//
//  INITIALIZATION
////////////////////////////////////////////////////////////////////////////

/*!
@method     - (id)initWithSymbolArray:(NSArray *)anArray symbolSet:(BCSymbolSet *)aSet;
 @abstract   initializes a BCAbstractSequence object by passing it an NSArray of BCSymbol.
 @discussion This is the designated initializer.
 * The method scans the passed array for all BCSymbol objects, and creates
 * a new BCAbstractSequence using them. The symbol set is used to filter the passed symbols.
 * The symbol set instance should be the same sequence type as the sequence, e.g. should
 * contain DNA symbols if used to initialize a DNA sequence. If not the right sequence type,
 * or if the symbolSet is nil, then the implementation uses the default symbol set
 * for the class, as returned by '+defaultSymbolSet'.
 * The method should only be called on a concrete subclass.
 */
- (id)initWithSymbolArray:(NSArray *)anArray symbolSet:(BCSymbolSet *)aSet;


/*!
@method     - (id)initWithSymbolArray:(NSArray *)anArray
 @abstract   initializes a BCAbstractSequence object by passing it an NSArray of BCSymbol.
 @discussion This method calls '-initWithSymbolArray:symbolSet'
 * using the default symbol set for the class.
 * The method scans the passed array for all BCSymbol objects compatible with the
 * type of sequence being created. The method should only be called on a concrete subclass.
 */
- (id)initWithSymbolArray:(NSArray *)anArray;


/*!
@method     - (id)initWithString:(NSString *)aString symbolSet:(BCSymbolSet *)aSet;
 @abstract   initializes a BCAbstractSequence object by passing it an NSString.
 @discussion This method will attempt to create an array of BCSymbols using the
 * characters found in the string.
 * The BCSymbols created will depend on the symbol set passed as argument.
 * The implementation calls the designated initializer '-initWithSymbolArray:symbolSet'.
 * The method should only be called on a concrete subclass. 
*/
- (id)initWithString:(NSString *)aString symbolSet:(BCSymbolSet *)aSet;


/*!
    @method     - (id)initWithString:(NSString*)aString
 @abstract   initializes a BCAbstractSequence object by passing it an NSString.
 @discussion This method calls initWithString:symbolSet:
 * using the default symbol set of the class as argument.
 * The method should only be called on a concrete subclass.
 * This method will create an array of BCSymbols using the
 * characters found in the string. The type of BCSymbols created
 * will depend on the the sequence type, e.g. the DNA sequence subclass
 * BCSequenceDNA will only use DNA bases.
*/
- (id)initWithString:(NSString*)aString;


/*!
    @method     - (id)initWithString:(NSString*)aString range:(NSRange)aRange skippingUnknownSymbols:(BOOL)skipFlag;
    @abstract   initializes a BCAbstractSequence object by passing it an NSString and a range.
    @discussion This method calls '-initWithString:'.Note that the range is 0-based.
*/
- (id)initWithString:(NSString*)aString range:(NSRange)aRange;

/*!
    @method     + (id)sequenceWithString:(NSString *)aString;
	@abstract   creates and returns an autoreleased sequence object initialized with the string passed as argument
	@discussion This method should not be called on the superclass BCAbstractSequence,
	* but on one of the concrete subclass. This method calls 'initWithString:'
*/
+ (id)sequenceWithString:(NSString *)aString;

/*!
@method     + (id)sequenceWithString:(NSString *)aString symbolSet:(BCSymbolSet *)aSet;
 @abstract   creates and returns an autoreleased sequence object initialized with the string passed as argument
 @discussion This method should not be called on the superclass BCAbstractSequence,
 * but on one of the concrete subclass. This method calls 'initWithString:symbolSet:'.
 */
+ (id)sequenceWithString:(NSString *)aString symbolSet:(BCSymbolSet *)aSet;

/*!
    @method     + (BCAbstractSequence *)sequenceWithSymbolArray:(NSArray *)entry
    @abstract   creates and returns an autoreleased sequence object initialized with the array of BCSymbols passed as argument
	@discussion This method should not be called on the superclass BCAbstractSequence,
	* but on one of the concrete subclass. This method calls 'initWithSymbolArray:'
*/
 + (id)sequenceWithSymbolArray:(NSArray *)entry;

/*!
    @method     + (id) objectForSavedRepresentation:(NSString *)sequence
    @abstract   Returns a BCAbstractSequence object representing the sequence submitted 
    @discussion all BC classes should implement a "savableRepresentation" and an 
    *  "objectForSavedRepresentation" method to allow archiving/uncarchiving in
    *  .plist formatted files.
*/
+ (id)objectForSavedRepresentation:(NSString *)sequence;


////////////////////////////////////////////////////////////////////////////
#pragma mark â  
#pragma mark â OBTAINING SEQUENCE INFORMATION
//
//  INFORMATIONAL METHODS
////////////////////////////////////////////////////////////////////////////

/*!
	@method     + (BCSymbolSet)defaultSymbolSet;
	@abstract   returns the default symbol set for the class
	@discussion The default symbol set is used to initialize sequences when 
	* no symbol set is provided, or the symbol set provided is not compatible
	* See the default initializer '-initWithSymbolArray:symbolSet'.
*/
+ (BCSymbolSet *)defaultSymbolSet;


/*!
    @method     - (BCSymbolSet) symbolSet
    @abstract   returns the type of sequence
*/
- (BCSymbolSet *) symbolSet;

/*
@method     - (void) setSymbolSet(BCSymbolSet):symbolSet
@abstract   sets the type of sequence
- (void) setSymbolSet:(BCSymbolSet *)symbolSet;
*/


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
*/
- (NSString*)sequenceString;



/*!
    @method    - (NSMutableArray *)symbolArray
      @abstract   returns a ponter to the array of BCSymbol objects that make up the sequence.
      @discussion The array returned is the object used internally by BCSequence.
	  * The array obtained should only be used for reading, and should not be modified by the caller.	 
      * To modify the sequence, instead use one of the
	  * convenience methods setSymbolArray, removeSymbolsInRange, removeSymbolsAtIndex,
	  * or insertSymbolsFromSequence:atIndex. 
*/
- (NSMutableArray *)symbolArray;


/*!
    @method    - (NSString *)subSequenceStringInRange:(NSRange)aRange
    @abstract   returns a subsequence in string form
    @discussion returns an NSString conatining a subsequence specified by aRange (0-based).
 *   Returns nil if any part of aRange is out of bounds.
*/
- (NSString *)subSequenceStringInRange:(NSRange)aRange;

/*!
    @method    - (NSArray *)subSymbolArrayInRange:(NSRange)aRange
    @abstract   returns a sub-symbollist in array form
 @discussion returns an Array conatining a subsequence specified by aRange (0-based).
 *   Returns nil if any part of aRange is out of bounds.
*/
- (NSArray *)subSymbolArrayInRange:(NSRange)aRange;

/*!
    @method    - (BCAbstractSequence *)subSequenceInRange:(NSRange)aRange
    @abstract   returns a sub-symbollist
    @discussion returns an NSString containing a sub-symbollist specified by aRange (0-based).
    *   Returns nil if any part of aRange is out of bounds.
*/
- (BCAbstractSequence *)subSequenceInRange:(NSRange)aRange;


/*!
     @method     - (NSString *) savableRepresentation
     @abstract   Returns the sequenceString for saving.
     @discussion All BCSymbol classes implement this method to provide a standard way of
     *  accessing their data in a format that can be stored in Apple .plist files within
     *  arrays or dictionaries.  Subclasses should provide a method of converting this information
     *  back into the appropriate Symbol object.
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
#pragma mark â  
#pragma mark â MANIPULATING THE SEQUENCE
//
//  SEQUENCE MANIPULATION METHODS
////////////////////////////////////////////////////////////////////////////


/*!
    @method    - (void)setSymbolArray:(NSMutableArray *)anArray
    @abstract   sets the symbollist as an array of BCSymbol objects.
*/
- (void)setSymbolArray:(NSMutableArray *)anArray;


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
    @method   - (void)insertSymbolsFromSequence:(BCAbstractSequence *)seq atIndex:(int)index
    @abstract   inserts a BCAbstractSequence into the current symbollist, starting at index (0-based)
    @discussion inserts the BCAbstractSequence that is in the first argument in the current BCAbstractSequence.
*/
- (void)insertSymbolsFromSequence:(BCAbstractSequence *)seq atIndex:(int)index;



////////////////////////////////////////////////////////////////////////////
#pragma mark â  
#pragma mark â DERIVING RELATED SEQUENCES
//  DERIVING OTHER SEQUENCES
////////////////////////////////////////////////////////////////////////////

- (BCAbstractSequence *) reverse;


////////////////////////////////////////////////////////////////////////////
#pragma mark â  
#pragma mark â FINDING SUBSEQUENCES
//  FINDING SUBSEQUENCES
////////////////////////////////////////////////////////////////////////////

- (NSArray *) findSequence: (BCAbstractSequence *) entry;
- (NSArray *) findSequence: (BCAbstractSequence *) entry usingStrict: (BOOL) strict;
- (NSArray *) findSequence: (BCAbstractSequence *) entry usingStrict: (BOOL) strict firstOnly: (BOOL) firstOnly;
- (NSArray *) findSequence: (BCAbstractSequence *) entry usingStrict: (BOOL) strict firstOnly: (BOOL) firstOnly usingSearchRange: (NSRange) range;

@end
