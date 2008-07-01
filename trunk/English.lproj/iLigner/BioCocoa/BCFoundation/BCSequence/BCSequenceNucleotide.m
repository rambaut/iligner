//
//  BCSequenceNucleotide.m
//  BioCocoa
//
//  Created by John Timmer on 2/24/05.
//  Copyright 2005 John Timmer. All rights reserved.
//

#import "BCSequenceNucleotide.h"
#import "BCToolComplement.h"
#import "BCSymbol.h"

@implementation BCSequenceNucleotide



- (BCSequenceNucleotide *) complement
{
    BCToolComplement *complementTool = [BCToolComplement complementToolWithSequence: self];
    
    return (BCSequenceNucleotide *)[complementTool sequenceComplement];
}


- (BCSequenceNucleotide *) reverseComplement
{
    BCToolComplement *complementTool = [BCToolComplement complementToolWithSequence: self];
    
    [complementTool setReverse: YES];
    
    return (BCSequenceNucleotide *)[complementTool sequenceComplement];
}



@end
