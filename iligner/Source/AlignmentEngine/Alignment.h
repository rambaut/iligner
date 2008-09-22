//
//  Alignment.h
//  iLigner
//
//  Created by Andrew Rambaut on 04/08/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class IndelList;

@interface Alignment :  NSManagedObject  
{
}

@property (retain) NSString * name;
@property (retain) NSSet* indelLists;

@end

@interface Alignment (CoreDataGeneratedAccessors)
- (void)addIndelListsObject:(IndelList *)value;
- (void)removeIndelListsObject:(IndelList *)value;
- (void)addIndelLists:(NSSet *)value;
- (void)removeIndelLists:(NSSet *)value;

@end

