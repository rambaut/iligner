//
//  TestBCSequenceProperties.m
//  BioCocoa
//
//  Created by Koen van der Drift on 4/5/05.
//  Copyright 2005 The BioCocoa Project. All rights reserved.
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

#import "TestBCSequenceProperties.h"


@implementation TestBCSequenceProperties

- (void)testSequenceProperties
{
	BCSequence				*sequence;
	BCToolMassCalculator	*calculator;
	NSNumber				*expected, *obtained;
	float					accuracy;
	
	sequence = [BCSequence sequenceWithString:@"KPYTREDFRQWERTYIPLKHGFDSACVNM"];
	calculator = [BCToolMassCalculator massCalculatorWithSequence: sequence];
	accuracy = 0.05;
	
	[calculator setMassType: BCMonoisotopic];	
	expected = [NSNumber numberWithFloat: (3587.7316 - hydrogenMonoisotopicMass)];
	obtained = [[calculator calculateMass] objectAtIndex: 0];
	
	STAssertEqualsWithAccuracy([expected floatValue], [obtained floatValue], accuracy, @"The MW should be %f but is %f",
				   [expected floatValue], [obtained floatValue] );

	[calculator setMassType: BCAverage];	
	expected = [NSNumber numberWithFloat: (3590.1056 - hydrogenAverageMass)];
	obtained = [[calculator calculateMass] objectAtIndex: 0];
	
	STAssertEqualsWithAccuracy([expected floatValue], [obtained floatValue], accuracy, @"The MW should be %f but is %f",
				   [expected floatValue], [obtained floatValue] );
}


@end
