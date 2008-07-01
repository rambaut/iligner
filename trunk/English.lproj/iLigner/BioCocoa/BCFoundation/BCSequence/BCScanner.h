//
//  BCScanner.h
//  BioCocoa
//
//  Created by Alexander Griekspoor on Fri Sep 10 2004.
//  Copyright (c) 2004 The BioCocoa Project. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BCAbstractSequence, BCSymbolSet;

/*!
@class      BCScanner
@abstract   Scans through BCSequences (DNA, protein, etc.)
@discussion BCScanner allows scanning through the individual symbols of native BCAbstractSequenceobjects
* 
*/

@interface BCScanner : NSObject{ //<NSCopying>
	
	BCAbstractSequence	*sequence;
	BCSymbolSet			*symbolsToBeSkipped;
	unsigned			scanLocation;
	BOOL				strict;
	
}

	////////////////////////////////////////////////////////////////////////////
	//  OBJECT METHODS START HERE
	//
#pragma mark ‚ 
#pragma mark ‚INITIALIZATION METHODS
	//
	//  INITIALIZATION
	////////////////////////////////////////////////////////////////////////////

	/*!
	 @method     - (id)initWithSequence:(BCAbstractSequence*)sequence;
	 @abstract   root initialization method
	 @discussion 
	*/
- (id)initWithSequence:(BCAbstractSequence*)sequence;

	/*!
	 @method     + (id)scannerWithSequence:(BCAbstractSequence*)sequence;
	 @abstract   convenience initialization method
	 @discussion returns an autoreleased BCScanner object initialized with
	 * BCAbstractSequencesequence.
	 */
+ (id)scannerWithSequence:(BCAbstractSequence*)sequence;


	////////////////////////////////////////////////////////////////////////////
#pragma mark ‚ 
#pragma mark ‚GETTING/SETTING INTERNAL VARIABLES
	//
	//  OBTAINING AND MODIFYING INTERNAL INFORMATION
	////////////////////////////////////////////////////////////////////////////

- (BCAbstractSequence*)sequence;

- (unsigned)scanLocation;
- (void)setScanLocation:(unsigned)pos;

- (BCSymbolSet *)setSymbolsToBeSkipped;
- (void)setSymbolsToBeSkipped:(BCSymbolSet *)set;

- (BOOL)strict;
- (void)setStrict:(BOOL)flag;


	////////////////////////////////////////////////////////////////////////////
#pragma mark ‚ 
#pragma mark ‚SCANNER METHODS
	//
	//  MOVING AND SETTING SCANNER
	////////////////////////////////////////////////////////////////////////////

- (BOOL)scanSequence:(BCAbstractSequence*)subSequence intoSequence:(BCAbstractSequence **)value;
- (BOOL)scanSymbolsFromSet:(BCSymbolSet *)set intoSequence:(BCAbstractSequence **)value;

- (BOOL)scanUpToSequence:(BCAbstractSequence*)sequence intoSequence:(BCAbstractSequence **)value;
- (BOOL)scanUpToSymbolsFromSet:(BCSymbolSet *)set intoSequence:(BCAbstractSequence **)value;

- (BOOL)isAtEnd;



@end

