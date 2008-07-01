//
//  EntrezResult.m
//  BioCocoa
//
//  Created by Alexander Griekspoor
//  Copyright (c) 2006 Mekentosj.com. All rights reserved.
//  http://creativecommons.org/licenses/by-nc/2.0/
//
//  Permission to use, copy, modify and distribute this software and its documentation
//  is hereby granted, provided that both the copyright notice and this permission
//  notice appear in all copies of the software, derivative works or modified versions,
//  and any portions thereof, and that both notices appear in supporting documentation,
//  and that credit is given to Mekentosj.com in all documents and publicity
//  pertaining to direct or indirect use of this code or its derivatives.
//
//  THIS IS EXPERIMENTAL SOFTWARE AND IT IS KNOWN TO HAVE BUGS, SOME OF WHICH MAY HAVE
//  SERIOUS CONSEQUENCES. THE COPYRIGHT HOLDER ALLOWS FREE USE OF THIS SOFTWARE IN ITS
//  "AS IS" CONDITION. THE COPYRIGHT HOLDER DISCLAIMS ANY LIABILITY OF ANY KIND FOR ANY
//  DAMAGES WHATSOEVER RESULTING DIRECTLY OR INDIRECTLY FROM THE USE OF THIS SOFTWARE
//  OR OF ANY DERIVATIVE WORK.
//---------------------------------------------------------------------------------------

/* This class encapsulates a result retrieved from Entrez using the controller class 
   It makes life very easy to display results in a tableview */

#import "EntrezResult.h"

#define kVersionNumber 1

@implementation EntrezResult

//===========================================================================
//  Init & Dealloc
//===========================================================================

- (id)initWithID: (int)value;
{
    if (self = [super init]){
        [self setDb_id: value];
    }
    
    return self;
}


- (id)initWithCoder: (NSCoder*) coder
{
    self = [super init];
    
    [self setAccession:  [coder decodeObject]];		// restore name
    [self setDescription:  [coder decodeObject]];       // restore type
    [self setSpecies: [coder decodeObject]];		// restore query
    [self setExtra: [coder decodeObject]];		// restore query

    [coder decodeValueOfObjCType: "i" at: &db_id];		

    return self;
}


- (void)dealloc				// Object deallocation
{
    [accession release];
    [description release];
    [species release];
    [extra release];
    
    [super dealloc];
}


//===========================================================================
//  Archiving and Unarchiving
//===========================================================================

- (void)encodeWithCoder: (NSCoder *) coder
{
    [coder encodeObject:accession];
    [coder encodeObject:description];
    [coder encodeObject:species];
    [coder encodeObject:extra];
    
    [coder encodeValueOfObjCType: "i" at: &db_id];		// store state of logging

}


//===========================================================================
//  Accessor methods
//===========================================================================


- (NSString *)accession
{
	return accession;
}

- (void)setAccession:(NSString *)newAccession
{
	[newAccession retain];
	[accession release];
	accession = newAccession;
}

- (NSString *)description
{
	return description;
}

- (void)setDescription:(NSString *)newDescription
{
	[newDescription retain];
	[description release];
	description = newDescription;
}

- (NSString *)species
{
	return species;
}

- (void)setSpecies:(NSString *)newSpecies
{
	[newSpecies retain];
	[species release];
	species = newSpecies;
}

- (int)db_id
{
	return db_id;
}

- (void)setDb_id:(int)newDb_id
{
	db_id = newDb_id;
}

- (NSString *)extra
{
	return extra;
}

- (void)setExtra:(NSString *)newExtra
{
	[newExtra retain];
	[extra release];
	extra = newExtra;
}


//===========================================================================
//  General methods
//===========================================================================




//===========================================================================
//  Sorting
//===========================================================================

- (NSComparisonResult)sortResultsOnIdAscending: (EntrezResult*) aResult{
    
    if([self db_id] > [aResult db_id]){
        return NSOrderedAscending;
    } else if([self db_id] < [aResult db_id]){
        return NSOrderedDescending;
    } else return NSOrderedSame;
}

- (NSComparisonResult)sortResultsOnIdDescending:(EntrezResult*) aResult{
    
    if([self db_id] < [aResult db_id]){
        return NSOrderedAscending;
    } else if([self db_id] > [aResult db_id]){
        return NSOrderedDescending;
    } else return NSOrderedSame;
}

- (NSComparisonResult)sortResultsOnAccessionAscending: (EntrezResult*) aResult{

    return [[self accession] caseInsensitiveCompare: [aResult accession]];
}

- (NSComparisonResult)sortResultsOnAccessionDescending:(EntrezResult*) aResult{

    return [[aResult accession] caseInsensitiveCompare: [self accession]];
}


- (NSComparisonResult)sortResultsOnDescriptionAscending: (EntrezResult*) aResult{
    
    return [[self description] caseInsensitiveCompare: [aResult description]];
}

- (NSComparisonResult)sortResultsOnDescriptionDescending:(EntrezResult*) aResult{
    
    return [[aResult description] caseInsensitiveCompare: [self description]];
}


- (NSComparisonResult)sortResultsOnSpeciesAscending: (EntrezResult*) aResult{
    
    return [[self species] caseInsensitiveCompare: [aResult species]];
}

- (NSComparisonResult)sortResultsOnSpeciesDescending:(EntrezResult*) aResult{
    
    return [[aResult species] caseInsensitiveCompare: [self species]];
}

@end
