//
//  BCGeneticCode.m
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


#import "BCFoundationDefines.h"
#import "BCSequence.h"
//#import "BCSequenceRNA.h"
#import "BCAminoAcid.h"
#import "BCNucleotideDNA.h"
#import "BCNucleotideRNA.h"
#import "BCCodon.h"
#import "BCCodonDNA.h"
#import "BCCodonRNA.h"

#import "BCGeneticCode.h"

#import "BCInternal.h"

static NSArray *universalGeneticCodeDNA = nil;
static NSArray *universalGeneticCodeRNA = nil;
static NSArray *vertebrateMitochondrialGeneticCodeDNA = nil;
static NSArray *vertebrateMitochondrialGeneticCodeRNA = nil;


@interface BCGeneticCode (private)

///////////////////////////////////////////////////////////////////////
// private methods below
///////////////////////////////////////////////////////////////////////
+ (NSMutableDictionary *) priv_createCodonArraysFromDictionary: (NSDictionary *)entry;
+ (NSMutableDictionary *) priv_modifyTemplateInfo: (NSDictionary *)template usingInfo: (NSDictionary *)revisions;

@end



@implementation BCGeneticCode


+ (NSArray *) geneticCode: (BCGeneticCodeName)codeType forSequenceType: (BCSequenceType)seqType {
    
    switch ( codeType ) {
        
        case BCUniversalCode : {
			if ( seqType == BCSequenceTypeDNA )
				return [BCGeneticCode universalGeneticCodeDNA];
			else if ( seqType == BCSequenceTypeRNA )
				return [BCGeneticCode universalGeneticCodeRNA];
			else
				return nil;
			
            break;
        }
			
        case BCVertebrateMitochondrial : {
			if ( seqType == BCSequenceTypeDNA )
				return [BCGeneticCode vertebrateMitochondrialGeneticCodeDNA];
			else if ( seqType == BCSequenceTypeRNA )
				return [BCGeneticCode vertebrateMitochondrialGeneticCodeRNA];
			else
				return nil;
			
            break;
        }
    }
    return nil;
}



+ (BCCodon *) codon: (BCSequence*)aCodon inGeneticCode: (BCGeneticCodeName)codeType {
    if ( [aCodon length] != 3 )
        return nil;
    NSArray *theCode;
    
    if ( [aCodon isKindOfClass: [BCSequence class]] ) {
        theCode = [BCGeneticCode geneticCode: codeType forSequenceType: BCSequenceTypeDNA];
        DECLARE_INDEX(loopCounter);
        int aLimit = [theCode count];
        BCCodonDNA *aKey;
        for ( loopCounter = 0; loopCounter < aLimit ; loopCounter++ ) {
            aKey = (BCCodonDNA *)ARRAY_GET_VALUE_AT_INDEX(theCode, loopCounter);
            if ( [aKey matchesTriplet: [aCodon symbolArray]] )
                return aKey;
        }
    }
//    else if ( [aCodon isKindOfClass: [BCSequenceRNA class]] ) {
//		theCode = [BCGeneticCode geneticCode: codeType forSequenceType: BCSequenceTypeRNA];
//        CFIndex loopCounter;
//        int aLimit = [theCode count];
//        BCCodonRNA *aKey;
//        for ( loopCounter = 0; loopCounter < aLimit ; loopCounter++ ) {
//            aKey = (BCCodonRNA *)CFArrayGetValueAtIndex( (CFArrayRef) theCode,  loopCounter) ;
//            if ( [aKey matchesTriplet: [aCodon symbolArray]] )
//                return aKey;
//        }
//    }
    return nil;
}




+ (NSArray *) universalGeneticCodeDNA {
    
    if ( universalGeneticCodeDNA == nil )
        [BCGeneticCode initUniversalGeneticCode];
    
    return universalGeneticCodeDNA;
}

+ (NSArray *) universalGeneticCodeRNA {
    if ( universalGeneticCodeRNA == nil )
        [BCGeneticCode initUniversalGeneticCode];
    
    return universalGeneticCodeRNA;
}

+ (void) initUniversalGeneticCode {
    
    // initialize the genetic code from a dictionary stored as a file
    NSBundle *biococoaBundle = [NSBundle bundleForClass: [BCGeneticCode class]];
    NSString *filePath = [biococoaBundle pathForResource: @"universal genetic code" ofType: @"plist"];
    if ( filePath == nil )
        return;
    
    NSMutableDictionary *transDict = [NSMutableDictionary dictionaryWithContentsOfFile: filePath];
    if ( transDict == nil )
        return;
    transDict = [BCGeneticCode priv_createCodonArraysFromDictionary: transDict];
    if ( transDict == nil )
        return;
    
    universalGeneticCodeDNA = [[transDict objectForKey: @"DNA"] copy];
    universalGeneticCodeRNA = [[transDict objectForKey: @"RNA"] copy];
}




+ (NSArray *) vertebrateMitochondrialGeneticCodeDNA {
    
    if ( vertebrateMitochondrialGeneticCodeDNA == nil )
        [BCGeneticCode initVertebrateMitochondrialGeneticCode];
    
    return vertebrateMitochondrialGeneticCodeDNA;
}

+ (NSArray *) vertebrateMitochondrialGeneticCodeRNA {
    if ( vertebrateMitochondrialGeneticCodeRNA == nil )
        [BCGeneticCode initVertebrateMitochondrialGeneticCode];
    
    return vertebrateMitochondrialGeneticCodeRNA;
}

+ (void) initVertebrateMitochondrialGeneticCode {
    
    // initialize the genetic code from a dictionary stored as a file
    NSBundle *biococoaBundle = [NSBundle bundleForClass: [BCGeneticCode class]];
    NSString *filePath = [biococoaBundle pathForResource: @"universal genetic code" ofType: @"plist"];
    if ( filePath == nil )
        return;
    
    NSDictionary *transDict = [NSMutableDictionary dictionaryWithContentsOfFile: filePath];
    if ( transDict == nil )
        return;
    
    filePath = [biococoaBundle pathForResource: @"vertebrate mitochondrial genetic code" ofType: @"plist"];
    NSDictionary *revisions = [NSMutableDictionary dictionaryWithContentsOfFile: filePath];
    
    transDict = [BCGeneticCode priv_modifyTemplateInfo: transDict usingInfo: revisions];
    transDict = [BCGeneticCode priv_createCodonArraysFromDictionary: transDict];
    if ( transDict == nil )
        return;
    
    vertebrateMitochondrialGeneticCodeDNA = [[transDict objectForKey: @"DNA"] copy];
    vertebrateMitochondrialGeneticCodeRNA = [[transDict objectForKey: @"RNA"] copy];
    
}




///////////////////////////////////////////////////////////////////////
// private methods below
///////////////////////////////////////////////////////////////////////

+ (NSMutableDictionary *) priv_createCodonArraysFromDictionary: (NSDictionary *)entry {
    NSMutableArray *DNAArray = [NSMutableArray array];
    NSMutableArray *RNAArray = [NSMutableArray array];
    NSEnumerator *keyEnumerator = [entry keyEnumerator];
    NSString *aKey;
    NSMutableString *anotherString;
    BCCodon *aCodon, *RNACodon;
    while ( (aKey = [keyEnumerator nextObject]) ) {
        aCodon = [[[BCCodonDNA alloc] initWithDNASequenceString: aKey andAminoAcidString: [entry objectForKey: aKey]] autorelease];
        if ( aCodon != nil )
            [DNAArray addObject: aCodon];
        anotherString = [[aKey mutableCopy] autorelease];
        [anotherString replaceOccurrencesOfString: @"T" withString: @"U" options: NSCaseInsensitiveSearch range: NSMakeRange(0, 3)];
        RNACodon = [[[BCCodonRNA alloc] initWithRNASequenceString: anotherString andAminoAcidString: [entry objectForKey: aKey]] autorelease];
        if ( aCodon != nil )
            [RNAArray addObject: aCodon];
        
    }
    
    if ( [DNAArray count] < 21 )
        return nil;
    
    NSMutableDictionary *theReturn = [NSMutableDictionary dictionaryWithObject: DNAArray forKey: @"DNA"];
    [theReturn setObject: RNAArray forKey: @"RNA"];
    return theReturn;
}



+ (NSMutableDictionary *) priv_modifyTemplateInfo: (NSDictionary *)template usingInfo: (NSDictionary *)revisions {
    NSMutableDictionary *theReturn = [template mutableCopy];
    NSArray *deletions = [revisions objectForKey: @"keys to delete"];
    if ( deletions == nil )
        return nil;
    
    DECLARE_INDEX(loopCounter);
    int aLimit = [deletions count];
    NSString *aKey;
    for ( loopCounter = 0; loopCounter < aLimit ; loopCounter++ ) {
      aKey = (NSString *)ARRAY_GET_VALUE_AT_INDEX(deletions, loopCounter);
        
        [theReturn removeObjectForKey: aKey];
    }
    
    [theReturn addEntriesFromDictionary: [revisions objectForKey: @"keys to add"]];
    
    return [theReturn autorelease];
}

@end
