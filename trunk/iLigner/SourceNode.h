//
//  SourceNode.h
//  iLigner
//
//  Created by Andrew Rambaut on 04/08/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface SourceNode :  NSManagedObject  
{
}

@property (retain) NSNumber * isSelectable;
@property (retain) NSNumber * isLeaf;
@property (retain) NSNumber * sortIndex;
@property (retain) NSString * displayName;
@property (retain) NSSet* children;
@property (retain) NSManagedObject * parent;

@end

@interface SourceNode (CoreDataGeneratedAccessors)
- (void)addChildrenObject:(NSManagedObject *)value;
- (void)removeChildrenObject:(NSManagedObject *)value;
- (void)addChildren:(NSSet *)value;
- (void)removeChildren:(NSSet *)value;

@end

