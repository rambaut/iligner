//
//  TestBCSuffixArray.m
//  BioCocoa
//
//  Created by Scott Christley on 9/24/07.
//  Copyright 2007 The BioCocoa Project. All rights reserved.
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
//

#import "TestBCSuffixArray.h"


@implementation TestBCSuffixArray

// test construct suffix array
#if 0
// disable for now as inMemory suffix array needs to be reworked
- (void)testMemoryConstructSuffixArray
{
  NSBundle *aBundle = [NSBundle bundleForClass: [self class]];
  NSString *fileName = [aBundle pathForResource: @"test" ofType: @"fa"];

  BCSuffixArray *anArray = [[BCSuffixArray alloc] init];

	// errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
  
  if (anArray == nil)
    [error appendString: @"Suffix array is nil\n"];
  else {
    // construct the suffix array
    if (![anArray constructFromSequenceFile: fileName strand: nil])
      [error appendString: @"Error while constructing suffix array\n"];

    if ([anArray numberOfSequences] != 2)
      [error appendFormat: @"Number of sequence in array is incorrect, 2 != %d\n", [anArray numberOfSequences]];
    else {
      BCSequenceArray *sequenceArray = [anArray sequenceArray];
      NSDictionary *metaDictionary = [anArray metaDictionary];
      if (metaDictionary == nil)
        [error appendString: @"Meta dictionary is nil\n"];
      else {
        if ([[metaDictionary objectForKey: @"length"] intValue] != 619)
          [error appendFormat: @"Total length of sequences is incorrect, 619 != %@\n", [metaDictionary objectForKey: @"length"]];

        BCSequence *aSeq = [sequenceArray sequenceAtIndex: 0];
        if ([aSeq length] != 517)
          [error appendFormat: @"Length of sequence is incorrect, 517 != %d\n", [aSeq length]];
      }
    }
  }

	// if error!=@"", the test failed
	STAssertTrue ([error isEqualToString:@""], error);
}
#endif

// test construct suffix array
- (void)testFileConstructSuffixArray
{
  NSBundle *aBundle = [NSBundle bundleForClass: [self class]];
  NSString *fileName = [aBundle pathForResource: @"test" ofType: @"fa"];

  // delete temporary files
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSString *s = [fileName stringByAppendingPathExtension: @"sa"];
  if ([fileManager fileExistsAtPath: s]) [fileManager removeFileAtPath: s handler: nil];
  s = [fileName stringByAppendingPathExtension: @"meta_sa"];
  if ([fileManager fileExistsAtPath: s]) [fileManager removeFileAtPath: s handler: nil];

  BCSuffixArray *anArray = [[BCSuffixArray alloc] init];

	// errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
  
  if (anArray == nil)
    [error appendString: @"Suffix array is nil\n"];
  else {
    // construct the suffix array
    if (![anArray constructFromSequenceFile: fileName strand: nil])
      [error appendString: @"Error while constructing suffix array\n"];

    // write to disk
    if (![anArray writeToFile: fileName withMasking: YES])
      [error appendFormat: @"Error while writing suffix array to file: %@\n", fileName];
    [anArray release];

    // read from disk
    anArray = [[BCSuffixArray alloc] initWithContentsOfFile: fileName inMemory: NO];
    if (anArray == nil)
      [error appendFormat: @"Could not read suffix array from file: %@\n", fileName];
    else {
      if ([anArray numberOfSequences] != 2)
        [error appendFormat: @"Number of sequence in array is incorrect, 2 != %d\n", [anArray numberOfSequences]];
      else {
        BCSequenceArray *sequenceArray = [anArray sequenceArray];
        NSDictionary *metaDictionary = [anArray metaDictionary];
        if (metaDictionary == nil)
          [error appendString: @"Meta-dictionary is nil\n"];
        else {
          if ([[metaDictionary objectForKey: @"length"] intValue] != 619)
            [error appendFormat: @"Total length of sequences in meta-dictionary is incorrect, 619 != %@\n",
              [metaDictionary objectForKey: @"length"]];

          NSArray *seqs = [metaDictionary objectForKey: @"sequences"];
          if (!seqs) [error appendString: @"Meta-dictionary missing sequences\n"];

          NSDictionary *d = [seqs objectAtIndex: 0];
          int aValue = [[d objectForKey: @"length"] intValue];
          if (aValue != 517)
            [error appendFormat: @"Length of sequence in meta-dictionary is incorrect, 517 != %d\n", aValue];
          aValue = [[d objectForKey: @"number"] intValue];
          if (aValue != 0)
            [error appendFormat: @"Sequence number in meta-dictionary is incorrect, 0 != %d\n", aValue];

          d = [seqs objectAtIndex: 1];
          aValue = [[d objectForKey: @"length"] intValue];
          if (aValue != 102)
            [error appendFormat: @"Length of sequence in meta-dictionary is incorrect, 102 != %d\n", aValue];
          aValue = [[d objectForKey: @"number"] intValue];
          if (aValue != 1)
            [error appendFormat: @"Sequence number in meta-dictionary is incorrect, 1 != %d\n", aValue];

          BCSequence *aSeq = [sequenceArray sequenceAtIndex: 0];
          if ([aSeq length] != 517)
            [error appendFormat: @"Length of sequence is incorrect, 517 != %d\n", [aSeq length]];

          aSeq = [sequenceArray sequenceAtIndex: 1];
          if ([aSeq length] != 102)
            [error appendFormat: @"Length of sequence is incorrect, 102 != %d\n", [aSeq length]];
          
        }
      }
    }
  }

	// if error!=@"", the test failed
	STAssertTrue ([error isEqualToString:@""], error);
}

@end
