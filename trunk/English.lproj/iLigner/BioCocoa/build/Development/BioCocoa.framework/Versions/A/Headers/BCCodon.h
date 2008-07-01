//
//  BCCodon.h
//  BioCocoa
//
//  Created by John Timmer on 8/31/04.
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

@class BCSymbol, BCAminoAcid;

@interface BCCodon : NSObject {
    BCSymbol            *firstBase;
    BCSymbol            *secondBase;
    BCSymbol            *wobbleBase;
    BCAminoAcid         *codedAminoAcid;
}


/*!
    @method     - (BCAminoAcid *) codedAminoAcid
    @abstract   returns the BCAminoAcid encoded by the reciever.  Returns nil for stop codons.
*/
- (BCAminoAcid *) codedAminoAcid;

/*!
    @method     - (NSString *) aminoAcidSymbolString
    @abstract   returns the symbol string of the amino acid encoded by the receiver.  Returns "*" for stop codons.
*/
- (NSString *) aminoAcidSymbolString;


/*!
    @method     - (NSString *) tripletString
    @abstract   returns a string representing the three bases of the codon.
    @discussion calls "symbolString" on each base of the codon, appending the results to generate a single string
*/
- (NSString *) tripletString;
- (NSString *)symbolString;

/*!
    @method     - (NSString *) description
    @abstract   returns the tripletString
*/
- (NSString *) description;


/*!
    @method     - (id)copyWithZone:(NSZone *)zone
    @abstract   returns self to keep the codon a singleton. This may be dangerous, but i don't entirely understand memory zones.
*/
- (id)copyWithZone:(NSZone *)zone;

@end
