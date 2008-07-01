//
//  TestBCSequenceReader.m
//  BioCocoa
//
//  Created by Scott Christley on 9/20/07.
//  Copyright 2007 The BioCocoa project. All rights reserved.
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

#import "TestBCSequenceReader.h"


@implementation TestBCSequenceReader

// read fasta format, DNA
- (void)testReadDNAFastaFile
{
  NSBundle *aBundle = [NSBundle bundleForClass: [self class]];
  NSString *fileName = [aBundle pathForResource: @"test" ofType: @"fa"];
	
  BCSequenceReader *sequenceReader = [[[BCSequenceReader alloc] init] autorelease];
  BCSequenceArray *sequenceArray = [sequenceReader readFileUsingPath: fileName format: BCFastaFileFormat];

	// errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
  
  if (sequenceArray == nil)
    [error appendString: @"Sequence array is nil\n"];
  else {
    if ([sequenceArray count] != 2)
      [error appendFormat: @"Number of sequence in array is incorrect, 2 != %d\n", [sequenceArray count]];
    else {
      BCSequence *aSeq = [sequenceArray sequenceAtIndex: 0];
      if ([aSeq length] != 517)
        [error appendFormat: @"Length of sequence is incorrect, 517 != %d\n", [aSeq length]];

      NSString *s = [aSeq sequenceString];
      NSRange r = [s rangeOfString: @"GACGGAGATTGGCCCTCGAGTGC"];
      if ((r.location != 0) || (r.length != 23))
        [error appendString: @"Incorrect sequence data at beginning of sequence\n"];
      r = [s rangeOfString: @"CCCACCCCAAGATGAGTGCTCTCCTATTCC"];
      if ((r.location != 487) || (r.length != 30))
        [error appendString: @"Incorrect sequence data at end of sequence\n"];
      if ([aSeq sequenceType] != BCSequenceTypeDNA)
        [error appendString: @"Sequence is not type BCSequenceTypeDNA\n"];
    }
  }

	// if error!=@"", the test failed
	STAssertTrue ([error isEqualToString:@""], error);
}

// read fasta format, protein
- (void)testReadProteinFastaFile
{
  NSBundle *aBundle = [NSBundle bundleForClass: [self class]];
  NSString *fileName = [aBundle pathForResource: @"transposon" ofType: @"fasta"];
	
  BCSequenceReader *sequenceReader = [[[BCSequenceReader alloc] init] autorelease];
  BCSequenceArray *sequenceArray = [sequenceReader readFileUsingPath: fileName format: BCFastaFileFormat];

	// errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
  
  if (sequenceArray == nil)
    [error appendString: @"Sequence array is nil\n"];
  else {
    if ([sequenceArray count] != 50)
      [error appendFormat: @"Number of sequence in array is incorrect, 50 != %d\n", [sequenceArray count]];
    else {
      BCSequence *aSeq = [sequenceArray sequenceAtIndex: 0];
      if ([aSeq length] != 594)
        [error appendFormat: @"Length of sequence is incorrect, 602 != %d\n", [aSeq length]];

      NSString *s = [aSeq sequenceString];
      NSRange r = [s rangeOfString: @"MGSSLDDEHILSALLQS"];
      if ((r.location != 0) || (r.length != 17))
        [error appendString: @"Incorrect sequence data at beginning of sequence\n"];
      r = [s rangeOfString: @"ICREHNIDMCQSCF"];
      if ((r.location != 580) || (r.length != 14))
        [error appendString: @"Incorrect sequence data at end of sequence\n"];
      if ([aSeq sequenceType] != BCSequenceTypeProtein)
        [error appendString: @"Sequence is not type BCSequenceTypeProtein\n"];
    }
  }

	// if error!=@"", the test failed
	STAssertTrue ([error isEqualToString:@""], error);
}

// read MacVector format, DNA
- (void)testReadDNAMacVectorFile
{
  NSBundle *aBundle = [NSBundle bundleForClass: [self class]];
  NSString *fileName = [aBundle pathForResource: @"pBR322" ofType: nil];
	
  BCSequenceReader *sequenceReader = [[[BCSequenceReader alloc] init] autorelease];
  BCSequenceArray *sequenceArray = [sequenceReader readFileUsingPath: fileName format: BCMacVectorFileFormat];

	// errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
  
  if (sequenceArray == nil)
    [error appendString: @"Sequence array is nil\n"];
  else {
    if ([sequenceArray count] != 1)
      [error appendFormat: @"Number of sequence in array is incorrect, 1 != %d\n", [sequenceArray count]];
    else {
      BCSequence *aSeq = [sequenceArray sequenceAtIndex: 0];
      if ([aSeq length] != 4361)
        [error appendFormat: @"Length of sequence is incorrect, 4361 != %d\n", [aSeq length]];

      NSString *s = [aSeq sequenceString];
      NSRange r = [s rangeOfString: @"TTCTCATGTTTGACAGCTTA"];
      if ((r.location != 0) || (r.length != 20))
        [error appendString: @"Incorrect sequence data at beginning of sequence\n"];
      r = [s rangeOfString: @"GGCGTATCACGAGGCCCTTTCGTCTTCAAGAA"];
      if ((r.location != 4329) || (r.length != 32))
        [error appendString: @"Incorrect sequence data at end of sequence\n"];
      if ([aSeq sequenceType] != BCSequenceTypeDNA)
        [error appendString: @"Sequence is not type BCSequenceTypeDNA\n"];
    }
  }

	// if error!=@"", the test failed
	STAssertTrue ([error isEqualToString:@""] ,error);
}

// read MacVector format, protein
- (void)testReadProteinMacVectorFile
{
  NSBundle *aBundle = [NSBundle bundleForClass: [self class]];
  NSString *fileName = [aBundle pathForResource: @"UBBYB" ofType: nil];
	
  BCSequenceReader *sequenceReader = [[[BCSequenceReader alloc] init] autorelease];
  BCSequenceArray *sequenceArray = [sequenceReader readFileUsingPath: fileName format: BCMacVectorFileFormat];

	// errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
  
  if (sequenceArray == nil)
    [error appendString: @"Sequence array is nil\n"];
  else {
    if ([sequenceArray count] != 1)
      [error appendFormat: @"Number of sequence in array is incorrect, 1 != %d\n", [sequenceArray count]];
    else {
      BCSequence *aSeq = [sequenceArray sequenceAtIndex: 0];
      if ([aSeq length] != 457)
        [error appendFormat: @"Length of sequence is incorrect, 457 != %d\n", [aSeq length]];

      NSString *s = [aSeq sequenceString];
      NSRange r = [s rangeOfString: @"MREIIHISTGQC"];
      if ((r.location != 0) || (r.length != 12))
        [error appendString: @"Incorrect sequence data at beginning of sequence\n"];
      r = [s rangeOfString: @"QNQDEPITENFE"];
      if ((r.location != 445) || (r.length != 12))
        [error appendString: @"Incorrect sequence data at end of sequence\n"];
      if ([aSeq sequenceType] != BCSequenceTypeProtein)
        [error appendString: @"Sequence is not type BCSequenceTypeProtein\n"];
    }
  }

	// if error!=@"", the test failed
	STAssertTrue ([error isEqualToString:@""] ,error);
}

// read Strider format, DNA
- (void)testReadDNAStriderFile
{
  NSBundle *aBundle = [NSBundle bundleForClass: [self class]];
  NSString *fileName = [aBundle pathForResource: @"hB2AR-CDS" ofType: @"xdna"];
	
  BCSequenceReader *sequenceReader = [[[BCSequenceReader alloc] init] autorelease];
  BCSequenceArray *sequenceArray = [sequenceReader readFileUsingPath: fileName format: BCStriderFileFormat];

	// errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
  
  if (sequenceArray == nil)
    [error appendString: @"Sequence array is nil\n"];
  else {
    if ([sequenceArray count] != 1)
      [error appendFormat: @"Number of sequence in array is incorrect, 1 != %d\n", [sequenceArray count]];
    else {
      BCSequence *aSeq = [sequenceArray sequenceAtIndex: 0];
      if ([aSeq length] != 1242)
        [error appendFormat: @"Length of sequence is incorrect, 1242 != %d\n", [aSeq length]];

      NSString *s = [aSeq sequenceString];
      NSRange r = [s rangeOfString: @"ATGGGGCAACCCGGGAACGG"];
      if ((r.location != 0) || (r.length != 20))
        [error appendString: @"Incorrect sequence data at beginning of sequence\n"];
      r = [s rangeOfString: @"AGGAATTGTAGTACAAATGACTCACTGCTGTAG"];
      if ((r.location != 1209) || (r.length != 33))
        [error appendString: @"Incorrect sequence data at end of sequence\n"];
      if ([aSeq sequenceType] != BCSequenceTypeDNA)
        [error appendString: @"Sequence is not type BCSequenceTypeDNA\n"];
    }
  }

	// if error!=@"", the test failed
	STAssertTrue ([error isEqualToString:@""] ,error);
}

// read Strider format, circular DNA
- (void)testReadCircularDNAStriderFile
{
  NSBundle *aBundle = [NSBundle bundleForClass: [self class]];
  NSString *fileName = [aBundle pathForResource: @"pCDNA3" ofType: @"xdna"];
	
  BCSequenceReader *sequenceReader = [[[BCSequenceReader alloc] init] autorelease];
  BCSequenceArray *sequenceArray = [sequenceReader readFileUsingPath: fileName format: BCStriderFileFormat];

	// errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
  
  if (sequenceArray == nil)
    [error appendString: @"Sequence array is nil\n"];
  else {
    if ([sequenceArray count] != 1)
      [error appendFormat: @"Number of sequence in array is incorrect, 1 != %d\n", [sequenceArray count]];
    else {
      BCSequence *aSeq = [sequenceArray sequenceAtIndex: 0];
      if ([aSeq length] != 5446)
        [error appendFormat: @"Length of sequence is incorrect, 5446 != %d\n", [aSeq length]];

      NSString *s = [aSeq sequenceString];
      NSRange r = [s rangeOfString: @"GACGGATCGGGAGATCTCCCGATCCCCT"];
      if ((r.location != 0) || (r.length != 28))
        [error appendString: @"Incorrect sequence data at beginning of sequence\n"];
      r = [s rangeOfString: @"TTTCCCCGAAAAGTGCCACCTGACGTC"];
      if ((r.location != 5419) || (r.length != 27))
        [error appendString: @"Incorrect sequence data at end of sequence\n"];
      if ([aSeq sequenceType] != BCSequenceTypeDNA)
        [error appendString: @"Sequence is not type BCSequenceTypeDNA\n"];
    }
  }

	// if error!=@"", the test failed
	STAssertTrue ([error isEqualToString:@""] ,error);
}

// read Strider format, protein
- (void)testReadProteinStriderFile
{
  NSBundle *aBundle = [NSBundle bundleForClass: [self class]];
  NSString *fileName = [aBundle pathForResource: @"hB2AR-protein" ofType: @"xprt"];
	
  BCSequenceReader *sequenceReader = [[[BCSequenceReader alloc] init] autorelease];
  BCSequenceArray *sequenceArray = [sequenceReader readFileUsingPath: fileName format: BCStriderFileFormat];

	// errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
  
  if (sequenceArray == nil)
    [error appendString: @"Sequence array is nil\n"];
  else {
    if ([sequenceArray count] != 1)
      [error appendFormat: @"Number of sequence in array is incorrect, 1 != %d\n", [sequenceArray count]];
    else {
      BCSequence *aSeq = [sequenceArray sequenceAtIndex: 0];
      if ([aSeq length] != 413)
        [error appendFormat: @"Length of sequence is incorrect, 413 != %d\n", [aSeq length]];

      NSString *s = [aSeq sequenceString];
      NSRange r = [s rangeOfString: @"MGQPGNGSAFLLAP"];
      if ((r.location != 0) || (r.length != 14))
        [error appendString: @"Incorrect sequence data at beginning of sequence\n"];
      r = [s rangeOfString: @"PSDNIDSQGRNCSTNDSLL"];
      if ((r.location != 394) || (r.length != 19))
        [error appendString: @"Incorrect sequence data at end of sequence\n"];
      if ([aSeq sequenceType] != BCSequenceTypeProtein)
        [error appendString: @"Sequence is not type BCSequenceTypeProtein\n"];
    }
  }

	// if error!=@"", the test failed
	STAssertTrue ([error isEqualToString:@""] ,error);
}

// read GCK format, DNA
- (void)testReadDNAGCKFile
{
  NSBundle *aBundle = [NSBundle bundleForClass: [self class]];
  NSString *fileName = [aBundle pathForResource: @"hB26H-N,S oligos" ofType: nil];
	
  BCSequenceReader *sequenceReader = [[[BCSequenceReader alloc] init] autorelease];
  BCSequenceArray *sequenceArray = [sequenceReader readFileUsingPath: fileName format: BCGCKFileFormat];

	// errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
  
  if (sequenceArray == nil)
    [error appendString: @"Sequence array is nil\n"];
  else {
    if ([sequenceArray count] != 1)
      [error appendFormat: @"Number of sequence in array is incorrect, 1 != %d\n", [sequenceArray count]];
    else {
      BCSequence *aSeq = [sequenceArray sequenceAtIndex: 0];
      if ([aSeq length] != 1278)
        [error appendFormat: @"Length of sequence is incorrect, 1278 != %d\n", [aSeq length]];

      NSString *s = [aSeq sequenceString];
      NSRange r = [s rangeOfString: @"AAGGACGATGATGACGCCATG"];
      if ((r.location != 0) || (r.length != 21))
        [error appendString: @"Incorrect sequence data at beginning of sequence\n"];
      r = [s rangeOfString: @"CATCATCACCATCACTAG"];
      if ((r.location != 1260) || (r.length != 18))
        [error appendString: @"Incorrect sequence data at end of sequence\n"];
      if ([aSeq sequenceType] != BCSequenceTypeDNA)
        [error appendString: @"Sequence is not type BCSequenceTypeDNA\n"];
    }
  }

	// if error!=@"", the test failed
	STAssertTrue ([error isEqualToString:@""] ,error);
}

// read GCK format, circular DNA
- (void)testReadCircularDNAGCKFile
{
  NSBundle *aBundle = [NSBundle bundleForClass: [self class]];
  NSString *fileName = [aBundle pathForResource: @"pvL1392-SFhB26H" ofType: nil];
	
  BCSequenceReader *sequenceReader = [[[BCSequenceReader alloc] init] autorelease];
  BCSequenceArray *sequenceArray = [sequenceReader readFileUsingPath: fileName format: BCGCKFileFormat];

	// errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
  
  if (sequenceArray == nil)
    [error appendString: @"Sequence array is nil\n"];
  else {
    if ([sequenceArray count] != 1)
      [error appendFormat: @"Number of sequence in array is incorrect, 1 != %d\n", [sequenceArray count]];
    else {
      BCSequence *aSeq = [sequenceArray sequenceAtIndex: 0];
      if ([aSeq length] != 10998)
        [error appendFormat: @"Length of sequence is incorrect, 10998 != %d\n", [aSeq length]];

      NSString *s = [aSeq sequenceString];
      NSRange r = [s rangeOfString: @"AGCTTTACTCGTAAAGCGAGTTGAAGGATCATATTTA"];
      if ((r.location != 0) || (r.length != 37))
        [error appendString: @"Incorrect sequence data at beginning of sequence\n"];
      r = [s rangeOfString: @"CGACGTTGTAAAACGACGGCCAGTGCC"];
      if ((r.location != 10971) || (r.length != 27))
        [error appendString: @"Incorrect sequence data at end of sequence\n"];
      if ([aSeq sequenceType] != BCSequenceTypeDNA)
        [error appendString: @"Sequence is not type BCSequenceTypeDNA\n"];
    }
  }

	// if error!=@"", the test failed
	STAssertTrue ([error isEqualToString:@""] ,error);
}

// read Clustal format
#if 0 // not working
- (void)testReadClustalFile
{
  NSBundle *aBundle = [NSBundle bundleForClass: [self class]];
  NSString *fileName = [aBundle pathForResource: @"transposon" ofType: @"clustalw"];
	
  BCSequenceReader *sequenceReader = [[[BCSequenceReader alloc] init] autorelease];
  BCSequenceArray *sequenceArray = [sequenceReader readFileUsingPath: fileName format: BCClustalFileFormat];

	// errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
  
  if (sequenceArray == nil)
    [error appendString: @"Sequence array is nil\n"];
  else {
    if ([sequenceArray count] != 1)
      [error appendFormat: @"Number of sequence in array is incorrect, 1 != %d\n", [sequenceArray count]];
    else {
      BCSequence *aSeq = [sequenceArray sequenceAtIndex: 0];
      if ([aSeq length] != 10998)
        [error appendFormat: @"Length of sequence is incorrect, 10998 != %d\n", [aSeq length]];

      NSString *s = [aSeq sequenceString];
      NSRange r = [s rangeOfString: @"AGCTTTACTCGTAAAGCGAGTTGAAGGATCATATTTA"];
      if ((r.location != 0) || (r.length != 37))
        [error appendString: @"Incorrect sequence data at beginning of sequence\n"];
      r = [s rangeOfString: @"CGACGTTGTAAAACGACGGCCAGTGCC"];
      if ((r.location != 10971) || (r.length != 27))
        [error appendString: @"Incorrect sequence data at end of sequence\n"];
    }
  }

	// if error!=@"", the test failed
	STAssertTrue ([error isEqualToString:@""] ,error);
}
#endif

@end
