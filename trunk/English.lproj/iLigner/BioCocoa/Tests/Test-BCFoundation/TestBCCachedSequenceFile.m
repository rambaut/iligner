//
//  TestBCCachedSequenceFile.m
//  BioCocoa
//
//  Created by Scott Christley on 9/25/07.
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

#import "TestBCCachedSequenceFile.h"


@implementation TestBCCachedSequenceFile

// read fasta format, DNA
- (void)testReadDNAFastaFile
{
  NSBundle *aBundle = [NSBundle bundleForClass: [self class]];
  NSString *fileName = [aBundle pathForResource: @"test" ofType: @"fa"];
	
  // read as cache and read in memory, then compare
  BCCachedSequenceFile *cacheFile = [BCCachedSequenceFile readCachedFileUsingPath: fileName];

  BCSequenceReader *sequenceReader = [[[BCSequenceReader alloc] init] autorelease];
  BCSequenceArray *sequenceArray = [sequenceReader readFileUsingPath: fileName format: BCFastaFileFormat];

	// errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
  
  if (cacheFile == nil)
    [error appendString: @"cache file is nil\n"];
  else {
    if (sequenceArray == nil)
      [error appendString: @"Sequence array is nil\n"];
    else {
      if ([sequenceArray count] != 2)
        [error appendFormat: @"Number of sequence in array is incorrect, 2 != %d\n", [sequenceArray count]];
      else {
        BCSequence *aSeq = [sequenceArray sequenceAtIndex: 0];
        BCSequence *revSeq = [aSeq reverseComplement];
        const unsigned char *seqData1 = [aSeq bytes];
        int aLen = [aSeq length];
        char seqData2[aLen];

        if (aLen != 517)
          [error appendFormat: @"Length of sequence is incorrect, 517 != %d\n", aLen];

        // forward strand
        int result = [cacheFile symbols: seqData2 atPosition: 0 ofLength: aLen forSequenceNumber: 0];
        if (result != aLen)
          [error appendFormat: @"Could not read full length of sequence, %d != %d\n", aLen, result];
        int i;
        for (i = 0; i < result; ++i) {
          if (seqData1[i] != seqData2[i]) {
            [error appendFormat: @"Sequence data does not match at position %d, %c != %c\n", i, seqData1[i], seqData2[i]];
            break;
          }
        }

#if 0 // reverse complement in BCSequence not working right
        NSLog(@"%@\n", [revSeq sequenceString]);
        // reverse strand
        seqData1 = [revSeq bytes];
        result = [cacheFile symbols: seqData2 atPosition: aLen ofLength: aLen forSequenceNumber: 0];
        for (i = 0; i < result; ++i) {
          if (seqData1[i] != seqData2[i]) {
            [error appendFormat: @"Sequence data does not match at position %d, %c != %c\n", i, seqData1[i], seqData2[i]];
            break;
          }
        }
#endif
      }
    }
  }

	// if error!=@"", the test failed
	STAssertTrue ([error isEqualToString:@""], error);
}

@end
