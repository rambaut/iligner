//
//  BCSequenceProtein.m
//  BioCocoa
//
//  Created by Koen van der Drift on Fri Aug 20 2004.
//  Copyright (c) 2004 The BioCocoa Project. All rights reserved.
//

#import "BCSequenceProtein.h"
#import "BCAminoAcid.h"
#import "BCSymbolSet.h"


@implementation BCSequenceProtein


//needed for initializations
//overriding the superclas
+ (BCSymbolSet *)defaultSymbolSet
{
	return [BCSymbolSet proteinSymbolSet];
}

//needed for initializations
//overriding the superclas
- (BCSequenceType) sequenceType
{
	return BCProteinSequence;
}


- (id)copyWithZone:(NSZone *)zone
{
	return [super copyWithZone: zone];
}


@end
