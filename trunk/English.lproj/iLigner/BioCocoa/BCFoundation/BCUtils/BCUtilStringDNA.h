//
//  BCUtilStringDNA.h
//
//  Created by John Timmer on Fri Jul 16 2004.
//  Copyright (c) 2004 The BioCocoa Project. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BCUtilStringDNA : NSObject {

    NSDictionary *baseComplements;
    NSCharacterSet *strictBaseSet;
    NSCharacterSet *normalBaseSet;
    NSCharacterSet *looseBaseSet;
    NSDictionary *basesAndReplacements;
}



//////////////////////////////////////////////////////////////////////////////////
//  A note on usage - 
//  Most of these methods require the use of character sets and dictionaries.
//  To save a bit of energy, we create a single shared instance, so we only make
//  them once.  Use "sharedDNAUtilObject" to get it.
//////////////////////////////////////////////////////////////////////////////////
// creation of this object
- (BCUtilStringDNA *) init;
+ (BCUtilStringDNA *) sharedDNAUtilObject;


//////////////////////////////////////////////////////////////////////////////////
// A note on the strings returned -
// These methods handle differences in case by uppercasing everything, so the 
// string returned will be uppercase.
// This should be an invitation for someone to write a case preserving version!
//////////////////////////////////////////////////////////////////////////////////

// handling the composition of a string in terms of valid DNA characters
// the strict methods allow ATCGN
// the others allow the full spectrum:  ATCGNMKRYWSHVDB
- (BOOL) hasNonDNACharacters: (NSString *)entry;
- (BOOL) hasNonDNACharacters_Strict: (NSString *)entry;
- (NSString *) stripNonDNACharacters: (NSString *)entry;
- (NSString *) stripNonDNACharacters_Strict: (NSString *)entry;

// complementing DNA sequences
- (NSString *) complementOfSequence: (NSString *)entry;
- (NSString *) reverseComplementOfSequence: (NSString *)entry;


// building a list of all possible sequences from a sequence with ambiguous bases
- (NSArray *) getAllSitesForSequence: (NSString *) entry;

// finding ORFs
- (NSRange) findLongestORFInSequence: (NSString *)entry startingWithATG: (BOOL)atgStart inBothDirections: (BOOL)bothDirections;

@end

