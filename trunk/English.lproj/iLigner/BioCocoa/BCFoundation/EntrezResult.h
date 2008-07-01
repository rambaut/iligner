//
//  EntrezResult.h
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

#import <Cocoa/Cocoa.h>

@interface EntrezResult : NSObject <NSCoding>
{
    //===========================================================================
    //  Variables and properties
    //===========================================================================
    
    NSString* accession;
    NSString* description;
    NSString* species;
    NSString* extra;

    int db_id;

}

//===========================================================================
//  Init & Dealloc
//===========================================================================

- (id)initWithID: (int)value;
- (id)initWithCoder: (NSCoder*) coder;
- (void)dealloc;

//===========================================================================
//  Archiving and Unarchiving
//===========================================================================

- (void)encodeWithCoder: (NSCoder *) coder;

//===========================================================================
//  Accessor methods
//===========================================================================

- (NSString *)accession;
- (void)setAccession:(NSString *)newAccession;

- (NSString *)description;
- (void)setDescription:(NSString *)newDescription;

- (NSString *)species;
- (void)setSpecies:(NSString *)newSpecies;

- (int)db_id;
- (void)setDb_id:(int)newDb_id;

- (NSString *)extra;
- (void)setExtra:(NSString *)newExtra;


//===========================================================================
//  General methods
//===========================================================================


//===========================================================================
//  Sorting
//===========================================================================

- (NSComparisonResult)sortResultsOnIdAscending: (EntrezResult*) aResult;
- (NSComparisonResult)sortResultsOnIdDescending:(EntrezResult*) aResult;

- (NSComparisonResult)sortResultsOnAccessionAscending: (EntrezResult*) aResult;
- (NSComparisonResult)sortResultsOnAccessionDescending:(EntrezResult*) aResult;

- (NSComparisonResult)sortResultsOnDescriptionAscending: (EntrezResult*) aResult;
- (NSComparisonResult)sortResultsOnDescriptionDescending:(EntrezResult*) aResult;

- (NSComparisonResult)sortResultsOnSpeciesAscending: (EntrezResult*) aResult;
- (NSComparisonResult)sortResultsOnSpeciesDescending:(EntrezResult*) aResult;

@end
