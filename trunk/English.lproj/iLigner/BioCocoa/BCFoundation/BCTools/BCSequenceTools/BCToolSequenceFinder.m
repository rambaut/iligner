//
//  BCToolSequenceFinder.m
//  BioCocoa
//
//  Created by Koen van der Drift on 10/28/04.
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

#import "BCToolSequenceFinder.h"
#import "BCSequence.h"
#import "BCSymbol.h"

#import "BCFoundationDefines.h"
#import "BCInternal.h"

@implementation BCToolSequenceFinder

-(id) initWithSequence:(BCSequence *)list
{
    if ( (self = [super initWithSequence:list]) )
    {
		[self setStrict: YES];
		[self setFirstOnly: YES];
		
		searchSequence = [[BCSequence alloc] init];
		searchRange = NSMakeRange( 0, [sequence length] );
	}
	
	return self;
}


+ (BCToolSequenceFinder *) sequenceFinderWithSequence: (BCSequence *) list
{
     BCToolSequenceFinder *finder = [[BCToolSequenceFinder alloc] initWithSequence: list];
     
	 return [finder autorelease];
}


-(void)dealloc
{
	[searchSequence release];
	
	[super dealloc];
}

- (BCSequence *)searchSequence
{
	return searchSequence;
}

- (void)setSearchSequence:(BCSequence *)s
{
	[s retain];
	[searchSequence release];
	searchSequence = s;
}


- (NSRange)searchRange
{
	return searchRange;
}

- (void)setSearchRange:(NSRange)aRange
{
    searchRange = aRange;
}


- (void)setStrict: (BOOL)value
{
	strict = value;
}


- (void)setFirstOnly: (BOOL)value
{
	firstOnly = value;
}


- (BOOL)compareSymbol: (BCSymbol *)first withSymbol:(BCSymbol *) second
{
 // We should think about a way to merge isEqualToSymbol and isRepresentedBySymbol
 // Maybe a method isRepresentedBySymbol, that is passed the value of 'strict' ? 
 
	BOOL result = YES;
	
	if ( strict )
	{
		result = [first isEqualToSymbol: second];
	}
	else
	{
		result = [first isRepresentedBySymbol: second];
	}
	
	return result;
}

- (NSArray *) findSequence: (BCSequence *)entry {
	BCSymbol		*entrySymbol, *selfSymbol;
	DECLARE_INDEX(loopCounter);
	DECLARE_INDEX(innerCounter);
    BOOL			haveMatch = NO;
    
    NSMutableArray	*theReturn = [NSMutableArray array];
	NSArray			*symbolArray = [[self sequence] symbolArray];
    NSArray			*entryArray = [entry symbolArray];
	
	// do bounds checking
    if ( searchRange.location + searchRange.length > [symbolArray count] )
	{
		return  theReturn;
	}
	
	// get the region to check
    NSArray *selfArray = [symbolArray subarrayWithRange: searchRange];
	
	int aLimit = [selfArray count] - [entryArray count] + 1;
	int innerLimit = [entryArray count];
    
	if ( strict ) {
		
		for ( loopCounter = 0; loopCounter < aLimit; loopCounter++ ) {
			selfSymbol = (BCSymbol *)ARRAY_GET_VALUE_AT_INDEX(selfArray, loopCounter);
			entrySymbol = (BCSymbol *)ARRAY_GET_VALUE_AT_INDEX(entryArray, 0);
			
			// scan through for a match at the first symbol
			if ( selfSymbol == entrySymbol ) {
				haveMatch = YES;
				innerCounter = 1;
				
				// go through and compare each symbol
				while ( innerCounter < innerLimit ) {
					selfSymbol = (BCSymbol *)ARRAY_GET_VALUE_AT_INDEX(selfArray, (loopCounter + innerCounter));
					entrySymbol = (BCSymbol *)ARRAY_GET_VALUE_AT_INDEX(entryArray, innerCounter);
					
					if ( selfSymbol != entrySymbol ){
						// exit without a match if we fail
						innerCounter = innerLimit;
						haveMatch = NO;
					}
					innerCounter ++;
				}
				
				// if we still have a match, we're good.
				if ( haveMatch )
				{
					[theReturn addObject: [NSValue valueWithRange: NSMakeRange( loopCounter, [entry length] )]];
					
					if ( firstOnly) 
						return [[theReturn copy] autorelease];
				}
			}
		}
	}
	else {
		for ( loopCounter = 0; loopCounter < aLimit; loopCounter++ ) {
			selfSymbol = (BCSymbol *)ARRAY_GET_VALUE_AT_INDEX(selfArray, loopCounter);
			entrySymbol = (BCSymbol *)ARRAY_GET_VALUE_AT_INDEX(entryArray, 0);
			
			
			// scan through for a match at the first symbol
			if ( [selfSymbol isRepresentedBySymbol: entrySymbol] || [entrySymbol isRepresentedBySymbol: selfSymbol] ) {
				haveMatch = YES;
				innerCounter = 1;
				
				// go through and compare each symbol
				while ( innerCounter < innerLimit ) {
					selfSymbol = (BCSymbol *)ARRAY_GET_VALUE_AT_INDEX(selfArray, (loopCounter + innerCounter));
					entrySymbol = (BCSymbol *)ARRAY_GET_VALUE_AT_INDEX(entryArray, innerCounter);
					
					if ( ![selfSymbol isRepresentedBySymbol: entrySymbol] && ![entrySymbol isRepresentedBySymbol: selfSymbol] ){
						// exit without a match if we fail
						innerCounter = innerLimit;
						haveMatch = NO;
					}
					innerCounter ++;
				}
				
				// if we still have a match, we're good.
				if ( haveMatch )
				{
					[theReturn addObject: [NSValue valueWithRange: NSMakeRange( loopCounter, [entry length] )]];
					
					if ( firstOnly) 
						return [[theReturn copy] autorelease];
				}
			}
		}
	}
	
    return [[theReturn copy] autorelease];
}


- (NSArray *) slow_findSequence: (BCSequence *)entry
{
	BCSymbol		*entrySymbol, *selfSymbol;
	DECLARE_INDEX(loopCounter);
	DECLARE_INDEX(innerCounter);
    BOOL			haveMatch = NO;
    
    NSMutableArray	*theReturn = [NSMutableArray array];
	NSArray			*symbolArray = [[self sequence] symbolArray];
    NSArray			*entryArray = [entry symbolArray];
	
	// do bounds checking
    if ( searchRange.location + searchRange.length > [symbolArray count] )
	{
		return  theReturn;
	}
	
	// get the region to check
    NSArray *selfArray = [symbolArray subarrayWithRange: searchRange];
	
	int aLimit = [selfArray count] - [entryArray count] + 1;
	int innerLimit = [entryArray count];
    
	for ( loopCounter = 0; loopCounter < aLimit; loopCounter++ )
	{
	  selfSymbol = (BCSymbol *)ARRAY_GET_VALUE_AT_INDEX(selfArray, loopCounter);
	  entrySymbol = (BCSymbol *)ARRAY_GET_VALUE_AT_INDEX(entryArray, 0);
        
		// scan through for a match at the first symbol
        if ( [self compareSymbol: selfSymbol withSymbol:entrySymbol] || [self compareSymbol: entrySymbol withSymbol:selfSymbol] )
		{
            haveMatch = YES;
            innerCounter = 1;
			
			// go through and compare each symbol
            while ( innerCounter < innerLimit ) {
	      selfSymbol = (BCSymbol *)ARRAY_GET_VALUE_AT_INDEX(selfArray, (loopCounter + innerCounter));
	      entrySymbol = (BCSymbol *)ARRAY_GET_VALUE_AT_INDEX(entryArray, innerCounter);
                
                if ( ![self compareSymbol: selfSymbol withSymbol:entrySymbol] && 
					 ![self compareSymbol: entrySymbol withSymbol:selfSymbol])
				{
					// exit without a match if we fail
                    innerCounter = innerLimit;
                    haveMatch = NO;
                }
                innerCounter ++;
            }
			
			// if we still have a match, we're good.
            if ( haveMatch )
            {
                [theReturn addObject: [NSValue valueWithRange: NSMakeRange( loopCounter, [entry length] )]];
				
				if ( firstOnly) 
					return [[theReturn copy] autorelease];
            }
        }
    }
	
    return [[theReturn copy] autorelease];
}




@end
