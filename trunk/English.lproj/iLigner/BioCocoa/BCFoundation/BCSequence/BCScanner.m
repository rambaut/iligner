//
//  BCScanner.m
//  BioCocoa
//
//  Created by Alexander Griekspoor on Fri Sep 10 2004.
//  Copyright (c) 2004 The BioCocoa Project. All rights reserved.
//

#import "BCScanner.h"
#import "BCSymbol.h"
#import "BCSymbolSet.h"
#import "BCAbstractSequence.h"
#import	"BCToolSequenceFinder.h"


////////////////////////////////////////////////////////////////////////////
#pragma mark ‚ 
#pragma mark ‚PRIVATE METHODS
////////////////////////////////////////////////////////////////////////////

@interface BCScanner(Private)
- (void)setSequence: (BCAbstractSequence*)seq;
@end



@implementation BCScanner

	////////////////////////////////////////////////////////////////////////////
	#pragma mark ‚ 
	#pragma mark ‚INITIALIZATION METHODS
	////////////////////////////////////////////////////////////////////////////

- (id)initWithSequence:(BCAbstractSequence*)entry
{
	if ( self = [super init] )
	{
		[self setSequence: entry];
    }
    return self;	
}

+ (id)scannerWithSequence:(BCAbstractSequence*)entry
{
	return [[[[self class] alloc] initWithSequence:entry] autorelease];
}


	////////////////////////////////////////////////////////////////////////////
	#pragma mark ‚ 
	#pragma mark ‚GETTING/SETTING INTERNAL VARIABLES
	////////////////////////////////////////////////////////////////////////////

- (BCAbstractSequence*)sequence
{
	return sequence;
}

- (void)setSequence: (BCAbstractSequence*)seq
{
	[seq retain];
	[sequence release];
	sequence = seq;	
}

- (unsigned)scanLocation
{
	return scanLocation;
}

- (void)setScanLocation:(unsigned)pos
{
	scanLocation = pos;
}

- (BCSymbolSet *)setSymbolsToBeSkipped{
}

- (void)setSymbolsToBeSkipped:(BCSymbolSet *)set{
}

- (BOOL)strict
{
	return strict;
}

- (void)setStrict:(BOOL)flag
{
	strict = flag;
}

	////////////////////////////////////////////////////////////////////////////
	#pragma mark ‚ 
	#pragma mark ‚SCANNER METHODS
	////////////////////////////////////////////////////////////////////////////

- (BOOL)scanSequence:(BCAbstractSequence*)subSequence intoSequence:(BCAbstractSequence **)value
{
	BCToolSequenceFinder	*finder = [BCToolSequenceFinder sequenceFinderWithSequence: [self sequence]];
	
	[finder setFirstOnly: YES];
	NSArray	*result = [finder findSequence: subSequence];
	
	if ( [result count] )
	{
		if ( value != nil)
			value = &subSequence;
		
		return YES;
	}
	
	value = nil;
	return NO;
	
	// TODO need to update the scanlocation
}

- (BOOL)scanSymbolsFromSet:(BCSymbolSet *)set intoSequence:(BCAbstractSequence **)value{
}

- (BOOL)scanUpToSequence:(BCAbstractSequence*)sequence intoSequence:(BCAbstractSequence **)value{
}

- (BOOL)scanUpToSymbolsFromSet:(BCSymbolSet *)set intoSequence:(BCAbstractSequence **)value{
}

- (BOOL)isAtEnd{
}


@end

