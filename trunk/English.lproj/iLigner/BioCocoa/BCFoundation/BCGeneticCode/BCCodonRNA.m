//
//  BCCodon.m
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

#import "BCCodonRNA.h"
//#import "BCSequenceRNA.h"
#import "BCSequence.h"
#import "BCAminoAcid.h"
#import "BCNucleotideRNA.h"


static BCCodonRNA *unmatchedCodon = nil;


@implementation BCCodonRNA




- (BCCodonRNA *)initWithRNASequenceString: (NSString *)sequenceString andAminoAcidString: (NSString *)aaString {
    self = [super init];
    if ( self == nil )
        return self;
    
    if ( ![aaString isEqualToString: @"stop"] )
        codedAminoAcid = [BCAminoAcid performSelector: NSSelectorFromString( aaString )];
    else
        codedAminoAcid = nil;
    
    if ( [sequenceString length] != 3)
        return nil;
    
    firstBase = [BCNucleotideRNA symbolForChar: [sequenceString characterAtIndex: 0]];
    if ( firstBase == nil || firstBase == [BCNucleotideRNA undefined] )
        return nil;
    
    secondBase = [BCNucleotideRNA symbolForChar: [sequenceString characterAtIndex: 1]];
    if ( secondBase == nil || secondBase == [BCNucleotideRNA undefined] )
        return nil;
    
    wobbleBase = [BCNucleotideRNA symbolForChar: [sequenceString characterAtIndex: 2]];
    if ( wobbleBase == nil || wobbleBase == [BCNucleotideRNA undefined] )
        return nil;
    
    return self;
}


- (BCCodon *) init {
    return nil;
}

//- (void) dealloc {
//    
//    [super release];
//}


- (BOOL) matchesTriplet: (NSArray *)entry {
    if ( ![(BCNucleotideRNA *)[entry objectAtIndex: 0] isRepresentedBySymbol: (BCNucleotideRNA *)firstBase] )
        return NO;
    
    if ( ![(BCNucleotideRNA *)[entry objectAtIndex: 1] isRepresentedBySymbol: (BCNucleotideRNA *)secondBase] )
        return NO;
    
    if ( ![(BCNucleotideRNA *)[entry objectAtIndex: 2] isRepresentedBySymbol: (BCNucleotideRNA *)wobbleBase] )
        return NO;
    
    return YES;
}


+ (BCCodonRNA *)unmatched {
    if ( unmatchedCodon == nil)
        unmatchedCodon = [[BCCodonRNA alloc] initWithRNASequenceString: @"---" andAminoAcidString: @"undefined"];
    return unmatchedCodon;
}



- (BCSequence *) triplet {
    NSArray *tempArray = [NSArray arrayWithObjects: firstBase, secondBase, wobbleBase, nil];
    return [BCSequence sequenceWithSymbolArray: tempArray];
}



@end
