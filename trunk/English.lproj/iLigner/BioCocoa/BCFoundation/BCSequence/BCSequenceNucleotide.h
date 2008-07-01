//
//  BCSequenceNucleotide.h
//  BioCocoa
//
//  Created by John Timmer on 2/24/05.
//  Copyright 2005 John Timmer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BCAbstractSequence.h"


@interface BCSequenceNucleotide : BCAbstractSequence {

}


/*!
    @method      - (BCSequenceNucleotide *) complement
	@abstract   returns a BCSequenceNucleotide that is the complement of the one queried.
*/
- (BCSequenceNucleotide *) complement;


/*!
    @method      - (BCSequenceNucleotide *) reverseComplement
	@abstract   returns a BCSequenceNucleotide that is the reverse complement of the one queried.
*/
- (BCSequenceNucleotide *) reverseComplement;

@end
