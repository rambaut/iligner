//
//  BCToolTranslatorDNA.m
//  BioCocoa
//
//  Created by John Timmer on 8/29/04.
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

#import "BCToolTranslatorDNA.h"

#import "BCNucleotideDNA.h"
#import "BCAminoAcid.h"
#import "BCSequenceCodon.h"
#import "BCCodonDNA.h"
#import "BCGeneticCode.h"

@implementation BCToolTranslatorDNA


+ (BCToolTranslatorDNA *) dnaTranslatorToolWithSequence: (BCSequence *) list
{
     BCToolTranslatorDNA *translatorTool = [[BCToolTranslatorDNA alloc] initWithSequence: list];
     
	 return [translatorTool autorelease];
}

/*
+ (BCSequenceCodon *) translateSequence: (BCSequence*) entry usingGeneticCode: (BCGeneticCodeName) codeName
{
    return nil;
}
*/

- (NSArray *)translateDNASequence
{
	return [BCToolTranslatorDNA translateDNASequence: [self sequence] usingGeneticCode: [self codeName]];
}


- (BCGeneticCodeName) codeName
{
	return codeName;
}


- (void)setCodeName: (BCGeneticCodeName)aName
{
	codeName = aName;
}

+ (id) translateSequence: (BCSequence*) entry usingGeneticCode: (BCGeneticCodeName) codeName {
    return nil;
}

+ (NSArray *) translateDNASequence: (BCSequence *) entry usingGeneticCode: (BCGeneticCodeName) codeName {
    NSArray *theCode = [BCGeneticCode universalGeneticCodeDNA];
    if ( theCode == nil )
        return nil;
    
    int codonCount = [theCode count];
    int loopCounter, innerCounter;
    NSArray *theSequenceArray = [entry symbolArray];
    NSMutableArray *returnArray = [NSMutableArray array];
    NSArray *tempCodon;
    BCCodonDNA *aCodon;
    BOOL oneMatch;
    for ( loopCounter = 0 ; loopCounter + 2 < [entry length] ; loopCounter = loopCounter + 3 ) {
        tempCodon = [theSequenceArray subarrayWithRange: NSMakeRange( loopCounter, 3 ) ];
        oneMatch = NO;
        
        for ( innerCounter = 0 ; innerCounter < codonCount ; innerCounter++ ) {
            aCodon = [theCode objectAtIndex: innerCounter];
            if ( [aCodon matchesTriplet: tempCodon] ) {
                [returnArray addObject: aCodon];
                oneMatch = YES;
                break;
            }
        }
        
        if ( !oneMatch )
            [returnArray addObject: [BCCodonDNA unmatched]];
        
    }
    
    return [[returnArray copy] autorelease];
}
@end
