//
//  BCSequenceDNA.m
//  BioCocoa
//
//  Created by John Timmer on 8/12/04.
//  Copyright 2004 The BioCocoa Project. All rights reserved.
//


#import "BCSequenceDNA.h"
#import "BCNucleotideDNA.h"
#import "BCSequenceRNA.h"
#import "BCToolComplement.h"
#import "BCSymbolSet.h"

@implementation BCSequenceDNA

////////////////////////////////////////////////////////////////////////////
#pragma mark ‚ 
#pragma mark ‚INITIALIZATION METHODS
//  INITIALIZATION METHODS
////////////////////////////////////////////////////////////////////////////

//needed for initializations
//overriding the superclas
+ (BCSymbolSet *)defaultSymbolSet
{
	return [BCSymbolSet dnaSymbolSet];
}

//needed for initializations
//overriding the superclas
- (BCSequenceType) sequenceType
{
	return BCDNASequence;
}


 + (id) objectForSavedRepresentation: (NSString *)aSequence {
    BCSequenceDNA *theReturn = [[BCSequenceDNA alloc] initWithString: aSequence];
    return [theReturn autorelease];
}

////////////////////////////////////////////////////////////////////////////
#pragma mark ‚ 
#pragma mark ‚SEQUENCE INFORMATION
//  OBTAINING INFORMATION ABOUT THE SEQUENCE
////////////////////////////////////////////////////////////////////////////


- (BOOL) containsNonBaseSymbols {
    
    CFIndex loopCounter;
    int theLimit = [symbolArray count];
    BCNucleotideDNA *aSymbol;
    BCNucleotideDNA *anUndefined = [BCNucleotideDNA undefined];
    BCNucleotideDNA *aGap = [BCNucleotideDNA gap];
    
    for ( loopCounter = 0 ; loopCounter < theLimit ; loopCounter++ ) {
        aSymbol = (BCNucleotideDNA *)CFArrayGetValueAtIndex( (CFMutableArrayRef) symbolArray,  loopCounter);
        if ( aSymbol == anUndefined ||
             aSymbol == aGap )
            return YES;
    }
    
    return NO;
}




////////////////////////////////////////////////////////////////////////////
#pragma mark ‚ 
#pragma mark ‚DERIVING RELATED SEQUENCES
//  DERIVING OTHER SEQUENCES
////////////////////////////////////////////////////////////////////////////

- (BCSequenceRNA *) rnaSequenceEquivalent {
    
    CFIndex loopCounter;
    int aLimit = [self length];
    NSMutableArray *tempSequence = [NSMutableArray array];
    BCNucleotideDNA *aBase;
    for ( loopCounter = 0; loopCounter < aLimit ; loopCounter++ ) {
        aBase = (id)CFArrayGetValueAtIndex( (CFArrayRef) symbolArray,  loopCounter);
        
        CFArrayAppendValue ( (CFMutableArrayRef) tempSequence, [aBase RNABaseEquivalent] );
        
    }
    
    return [BCSequenceRNA sequenceWithSymbolArray: tempSequence];
}


 

@end
