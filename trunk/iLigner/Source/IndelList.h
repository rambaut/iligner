//
//  IndelList.h
//  iLigner
//
//  Created by Andrew Rambaut on 31/07/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Indel;
@class Alignment;
@class Indel;
@class Indel;
@class Sequence;

@interface IndelList :  NSManagedObject  
{
}

@property (retain) Indel * head;
@property (retain) Alignment * alignment;
@property (retain) NSSet* indels;
@property (retain) Indel * tail;
@property (retain) Sequence * sequence;

@end

@interface IndelList (CoreDataGeneratedAccessors)
- (void)addIndelsObject:(Indel *)value;
- (void)removeIndelsObject:(Indel *)value;
- (void)addIndels:(NSSet *)value;
- (void)removeIndels:(NSSet *)value;

@end

