//
//  Album.h
//  iLigner
//
//  Created by Andrew Rambaut on 31/07/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Sequence;

@interface Album :  NSManagedObject  
{
}

@property (retain) NSString * name;
@property (retain) NSString * notes;
@property (retain) NSSet* sequences;

@end

@interface Album (CoreDataGeneratedAccessors)
- (void)addSequencesObject:(Sequence *)value;
- (void)removeSequencesObject:(Sequence *)value;
- (void)addSequences:(NSSet *)value;
- (void)removeSequences:(NSSet *)value;

@end

