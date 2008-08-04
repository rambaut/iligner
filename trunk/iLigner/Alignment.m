// 
//  Alignment.m
//  iLigner
//
//  Created by Andrew Rambaut on 04/08/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Alignment.h"

#import "IndelList.h"

@implementation Alignment 

@dynamic name;
@dynamic indelLists;

- (void)awakeFromInsert;
{
	self.isLeaf = [NSNumber numberWithBool:YES];
}

@end
