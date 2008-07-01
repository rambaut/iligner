//
//  BCNucleotide.m
//  BioCocoa
//
//  Created by John Timmer on 2/25/05.
//  Copyright 2005 The BioCocoa Project. All rights reserved.
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

#import "BCNucleotide.h"
#import	"BCStringDefinitions.h"

#import "BCInternal.h"

@implementation BCNucleotide

- (id)initWithSymbolChar:(unsigned char)aChar
{
    if ( (self = [super initWithSymbolChar: aChar]) )
    {
        complement = nil;
        complements = nil;
    }
    
    return self;
}


- (void)dealloc
{   
    [complement release];
    [complements release];
	
	[super dealloc];
}



- (void) initializeComplementRelationships {
    // THIS METHOD IS CALLED AFTER OBJECT INITIALIZATION BECAUSE IT 
    // REQUIRES THE EXISTENCE OF ALL THE OTHER SYMBOLS IN ORDER TO WORK
    // IT SHOULD BE CALLED THE FIRST TIME ONE OF THESE INSTANCE OBJECTS IS NEEDED
    
    NSString		*symbolReference;
    NSArray			*infoArray;
    NSEnumerator	*objectEnumerator;
    NSMutableArray	*tempArray;
    BCSymbol		*tempSymbol;
    
    symbolReference = [[self symbolInfo] objectForKey: BCSymbolComplementProperty];
    
    if ( symbolReference != nil || [symbolReference length] > 0 )
    {
        complement = [(BCNucleotide *)[self class] performSelector: NSSelectorFromString( symbolReference )];
    }
    
    infoArray = [[self symbolInfo] objectForKey: BCSymbolAllComplementsProperty];
    
    if ( infoArray != nil || [infoArray count] > 0 )
    {
        objectEnumerator = [infoArray objectEnumerator];
        tempArray = [NSMutableArray array];
        
        while ( (symbolReference = [objectEnumerator nextObject]) )
        {
            if ( symbolReference != nil || [symbolReference length] > 0 )
            {
                tempSymbol = [(BCNucleotide *)[self class] performSelector: NSSelectorFromString( symbolReference )];
                
                if ( tempSymbol != nil )
                    [tempArray addObject: tempSymbol];
            }
        }
        
        complements = [[NSSet setWithArray: tempArray] retain];
    }
    
}



///////////////////////////////////////////////////////////
//  COMPLEMENTATION METHODS
///////////////////////////////////////////////////////////


- (BCNucleotide  *)complement  {
    if ( complement == nil )
        [self initializeComplementRelationships];
    
    return (BCNucleotide  *)complement;
}


- (NSSet *)complements  {
    if ( complements == nil )
        [self initializeComplementRelationships];
    
    return complements;
}


- (BOOL) complementsSymbol: (BCNucleotide *)entry {
    if ( complements == nil )
        [self initializeComplementRelationships];
        
// the following is the equivalent of return [complements containsObject: entry];
    return SET_CONTAINS_VALUE(complements, entry);
}


- (BOOL) isComplementOfSymbol: (BCNucleotide *)entry {
    return [entry complementsSymbol: self];
}



@end
