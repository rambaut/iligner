//
//  BCSequenceTransformer.m
//  BioCocoa
//
//  Created by Koen van der Drift on 9/16/2005.
//  Copyright 2005 The BioCocoa Project. All rights reserved.
//

//#import "BCSequenceTransformer.h"
#import "BCSequence.h"

@implementation BCSequenceTransformer

+ (Class)transformedValueClass
{
	return [NSString class];
}

+ (BOOL)allowsReverseTransformation
{
	return NO;	// later change to yes
}

- (id)transformedValue:(id)value
{
	NSString	*returnString;
	
	if ( value == nil ) return nil;
	
	if ( [value isKindOfClass: [BCSequence class]] )
	{
		returnString = [value sequenceString];
	}
	
	return returnString;
}


@end
