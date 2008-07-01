//
//  BCSequenceWriter.m
//  BioCocoa
//
//  Created by Koen van der Drift on 8/12/06.
//  Copyright 2006 The BioCocoa Project. All rights reserved.
//
//  This code is covered by the Creative Commons Share-Alike Attribution license.
//	You are free:
//	to copy, distribute, display, and perform the work
//	to make derivative works
//	to make commercial use of the work
//
//	Under the following conditions:
//	You must attribute the work in the manner specified by the author or licensor.
//	If you alter, transform, or build upon this work, you may distribute the resulting work only under a license identical to this one.
//
//	For any reuse or distribution, you must make clear to others the license terms of this work.
//	Any of these conditions can be waived if you get permission from the copyright holder.
//
//  For more info see: http://creativecommons.org/licenses/by-sa/2.5/

#import "BCSequenceWriter.h"
#import "BCSequenceArray.h"
#import "BCSequence.h"


@implementation BCSequenceWriter

- (NSString *)writeFastaFile:(BCSequenceArray *)sequenceArray
{
	int				i;
	BCSequence		*aSequence;
	NSString		*sequenceString;
	NSString		*sequenceIdentifier;
	
	NSMutableString	*result = [NSMutableString string];
	[result setString: @""];
	
	for (i = 0; i < [sequenceArray count]; i++)
	{
		aSequence = [sequenceArray sequenceAtIndex: i];
		
		sequenceString = [aSequence sequenceString];
		
		if ([aSequence annotations] != nil)
		{
			sequenceIdentifier = (NSString *) [aSequence annotationForKey: @">"];
			
			[result appendString: @"> "];
			[result appendString: sequenceIdentifier];
			[result appendString: @"\r"];
		}

		[result appendString: sequenceString];
	}

	return result;
}



@end
