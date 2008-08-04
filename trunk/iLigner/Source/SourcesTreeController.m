//
//  SourcesTreeController.m
//  iLigner
//
//  Created by Andrew Rambaut on 04/08/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SourcesTreeController.h"
#import "NSArray_Extensions.h"
#import "NSTreeController_Extensions.h"
#import "NSTreeNode_Extensions.h"
#import "NSIndexPath_Extensions.h"

@interface SourcesTreeController (Private)
- (void)updateSortOrderOfModelObjects;
@end

@implementation SourcesTreeController (Private)
- (void)updateSortOrderOfModelObjects;
{
	for (NSTreeNode *node in [self flattenedNodes])
		[[node representedObject] setValue:[NSNumber numberWithInt:[[node indexPath] lastIndex]] forKey:@"sortIndex"];
}
@end

@implementation SourcesTreeController

- (void)insertObject:(id)object atArrangedObjectIndexPath:(NSIndexPath *)indexPath;
{
	[super insertObject:object atArrangedObjectIndexPath:indexPath];
	[self updateSortOrderOfModelObjects];
}

- (void)insertObjects:(NSArray *)objects atArrangedObjectIndexPaths:(NSArray *)indexPaths;
{
	[super insertObjects:objects atArrangedObjectIndexPaths:indexPaths];
	[self updateSortOrderOfModelObjects];
}

- (void)removeObjectAtArrangedObjectIndexPath:(NSIndexPath *)indexPath;
{
	[super removeObjectAtArrangedObjectIndexPath:indexPath];
	[self updateSortOrderOfModelObjects];
}

- (void)removeObjectsAtArrangedObjectIndexPaths:(NSArray *)indexPaths;
{
	[super removeObjectsAtArrangedObjectIndexPaths:indexPaths];
	[self updateSortOrderOfModelObjects];
}

- (void)moveNode:(NSTreeNode *)node toIndexPath:(NSIndexPath *)indexPath;
{
	[super moveNode:node toIndexPath:indexPath];
	[self updateSortOrderOfModelObjects];	
}

- (void)moveNodes:(NSArray *)nodes toIndexPath:(NSIndexPath *)indexPath;
{
	[super moveNodes:nodes toIndexPath:indexPath];
	[self updateSortOrderOfModelObjects];
}
@end
