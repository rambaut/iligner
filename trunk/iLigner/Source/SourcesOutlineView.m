//
//  SourcesOutlineView.m
//  iLigner
//
//  Created by Andrew Rambaut on 04/08/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SourcesOutlineView.h"


@implementation SourcesOutlineView

- (void)reloadData;
{
	[super reloadData];
	NSUInteger row;
	for (row = 0 ; row < [self numberOfRows] ; row++) {
		NSTreeNode *item = [self itemAtRow:row];
		if (![item isLeaf] && [[[item representedObject] valueForKey:@"isExpanded"] boolValue])
			[self expandItem:item];
	}
}

@end
