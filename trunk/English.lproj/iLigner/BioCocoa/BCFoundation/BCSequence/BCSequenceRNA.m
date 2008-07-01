//
//  BCSequenceRNA.m
//  BioCocoa
//
//  Created by John Timmer on 8/12/04.
//  Copyright 2004 John Timmer. All rights reserved.
//

 
#import "BCSequenceRNA.h"
#import "BCNucleotideRNA.h"
#import "BCSequenceDNA.h"
#import "BCToolComplement.h"
#import "BCSymbolSet.h"

@implementation BCSequenceRNA

////////////////////////////////////////////////////////////////////////////
#pragma mark ‚ 
#pragma mark ‚INITIALIZATION METHODS
//  INITIALIZATION METHODS
////////////////////////////////////////////////////////////////////////////

- (id)initWithString:(NSString *)entry convertingThymidines:(BOOL)convert
{
    if ( convert ) {
        NSMutableString *converted = [[entry mutableCopy] autorelease];
        [converted replaceOccurrencesOfString: @"t" withString: @"U" options: NSCaseInsensitiveSearch range: NSMakeRange( 0, [converted length])];
        return [self initWithString:converted];
    }
    else 
        return [self initWithString:entry];
    
    return nil;
}


+ (id) objectForSavedRepresentation: (NSString *)aSequence {
    BCSequenceRNA *theReturn = [[BCSequenceRNA alloc] initWithString: aSequence];
    return [theReturn autorelease];
}

//needed for initializations
//overriding the superclas
+ (BCSymbolSet *)defaultSymbolSet
{
	return [BCSymbolSet rnaSymbolSet];
}

//needed for initializations
//overriding the superclas
- (BCSequenceType) sequenceType
{
	return BCRNASequence;
}

////////////////////////////////////////////////////////////////////////////
#pragma mark ‚ 
#pragma mark ‚SEQUENCE INFORMATION
//  OBTAINING INFORMATION ABOUT THE SEQUENCE
////////////////////////////////////////////////////////////////////////////


- (BOOL) containsNonBaseSymbols {
    
    CFIndex loopCounter;
    int theLimit = [symbolArray count];
    BCNucleotideRNA *aSymbol;
    BCNucleotideRNA *anUndefined = [BCNucleotideRNA undefined];
    BCNucleotideRNA *aGap = [BCNucleotideRNA gap];
    
    for ( loopCounter = 0 ; loopCounter < theLimit ; loopCounter++ ) {
        aSymbol = (BCNucleotideRNA *)CFArrayGetValueAtIndex( (CFMutableArrayRef) symbolArray,  loopCounter);
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


- (BCSequenceDNA *) dnaSequenceEquivalent {
    
    CFIndex loopCounter;
    int aLimit = [self length];
    NSMutableArray *tempSequence = [NSMutableArray array];
    BCNucleotideRNA *aBase;
    for ( loopCounter = 0; loopCounter < aLimit ; loopCounter++ ) {
        aBase = (id)CFArrayGetValueAtIndex( (CFArrayRef) symbolArray,  loopCounter);
        
        CFArrayAppendValue ( (CFMutableArrayRef) tempSequence, [aBase DNABaseEquivalent] );
        
    }
    
    return [BCSequenceDNA sequenceWithSymbolArray: tempSequence];
}


 
@end
