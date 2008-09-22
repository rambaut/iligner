//
// File:	   ChildNode.h
//
// Abstract:   Generic child node object used with NSOutlineView and NSTreeController.
//
// Version:    1.0
//

#import <Cocoa/Cocoa.h>
#import "BaseNode.h"

@class Alignment;

@interface ChildNode : BaseNode
{
	Alignment*			alignment;
}

@property (readwrite, assign) Alignment* alignment;

@end
