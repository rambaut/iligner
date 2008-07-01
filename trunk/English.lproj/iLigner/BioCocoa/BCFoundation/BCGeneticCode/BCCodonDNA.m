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

#import "BCCodonDNA.h"
#import "BCSequence.h"
#import "BCAminoAcid.h"
#import "BCSymbol.h"
#import "BCNucleotideDNA.h"


static BCCodonDNA *unmatchedCodon = nil;



@implementation BCCodonDNA



- (BCCodonDNA *)initWithDNASequenceString: (NSString *)sequenceString andAminoAcidString: (NSString *)aaString {
    self = [super init];
    if ( self == nil )
        return self;
    
    if ( ![aaString isEqualToString: @"stop"] )
        codedAminoAcid = [BCAminoAcid performSelector: NSSelectorFromString( aaString )];
    else
        codedAminoAcid = nil;
    
    if ( [sequenceString length] != 3)
        return nil;
    
    firstBase = [BCNucleotideDNA symbolForChar: [sequenceString characterAtIndex: 0]];
    if ( firstBase == nil || firstBase == [BCNucleotideDNA undefined] )
        return nil;
    
    secondBase = [BCNucleotideDNA symbolForChar: [sequenceString characterAtIndex: 1]];
    if ( secondBase == nil || secondBase == [BCNucleotideDNA undefined] )
        return nil;
    
    wobbleBase = [BCNucleotideDNA symbolForChar: [sequenceString characterAtIndex: 2]];
    if ( wobbleBase == nil || wobbleBase == [BCNucleotideDNA undefined] )
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



+ (BCCodonDNA *)unmatched {
    if ( unmatchedCodon == nil)
        unmatchedCodon = [[BCCodonDNA alloc] initWithDNASequenceString: @"---" andAminoAcidString: @"undefined"];
    return unmatchedCodon;
}


- (BOOL) matchesTriplet: (NSArray *)entry {
    if ( ![(BCNucleotideDNA *)[entry objectAtIndex: 0] isRepresentedBySymbol: (BCNucleotideDNA *)firstBase] )
        return NO;
    
    if ( ![(BCNucleotideDNA *)[entry objectAtIndex: 1] isRepresentedBySymbol: (BCNucleotideDNA *)secondBase] )
        return NO;
    
    if ( ![(BCNucleotideDNA *)[entry objectAtIndex: 2] isRepresentedBySymbol: (BCNucleotideDNA *)wobbleBase] )
        return NO;
    
    return YES;
}





- (BCSequence *) triplet {
    NSArray *tempArray = [NSArray arrayWithObjects: firstBase, secondBase, wobbleBase, nil];
    return [BCSequence sequenceWithSymbolArray: tempArray];
}


@end
