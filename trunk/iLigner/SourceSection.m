// 
//  SourceSection.m
//  iLigner
//
//  Created by Andrew Rambaut on 04/08/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SourceSection.h"


@implementation SourceSection 

@dynamic canExpand;
@dynamic isExpanded;
@dynamic isSpecialSection;
@dynamic canCollapse;

- (void)awakeFromInsert;
{
	self.isLeaf = [NSNumber numberWithBool:NO];
}

@end
