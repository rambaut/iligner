//
// File:	   ChildNode.m
//
// Abstract:   Generic child node object used with NSOutlineView and NSTreeController.
//
// Version:    1.0
//

#import "ChildNode.h"

@implementation ChildNode

// -------------------------------------------------------------------------------
//	init:
// -------------------------------------------------------------------------------
- (id)init
{
	if (self = [super init])
	{
		alignment = nil;
		nodeTitle = [[NSString alloc] initWithString:@""];
	}
	return self;
}

@synthesize alignment;

@end
