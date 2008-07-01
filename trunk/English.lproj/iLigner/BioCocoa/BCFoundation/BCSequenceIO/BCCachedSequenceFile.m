//
//  BCCachedSequenceFile.m
//  BioCocoa
//
//  Created by Scott Christley on 9/10/07.
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

#import "BCCachedSequenceFile.h"
#import "BCCachedFastaFile.h"

@implementation BCCachedSequenceFile

+ readCachedFileUsingPath:(NSString *)filePath
{
  id result = nil;
  NSFileHandle *seqFile = [NSFileHandle fileHandleForReadingAtPath: filePath];
  
  if (!seqFile) {
    NSLog(@"Could not open file: %@\n", filePath);
    return nil;
  }

  // determine file type by reading some data
  NSData *someData = [seqFile readDataOfLength: 10000];
  NSString *entryString = [[NSString alloc] initWithData: someData encoding: NSASCIIStringEncoding];	// or NSUTF8StringEncoding ?
  [seqFile closeFile];

  // TODO: currently only handle FASTA
	if ([entryString hasPrefix:@">"]) {
    result = [[BCCachedFastaFile alloc] initWithContentsOfFile: filePath];
	} else {
    NSLog(@"Unsupported cached sequence file type.\n");
    return nil;
  }

  return result;
}

- initWithContentsOfFile:(NSString *)filePath
{
  [super init];
  
  sequenceFile = filePath;
  fileHandle = NULL;
  sequenceInfo = [NSMutableDictionary new];
  sequenceList = [NSMutableArray new];
  currentSequenceNumber = -1;
  currentSequence = nil;

  return self;
}

- (void)dealloc
{
  if (fileHandle) fclose(fileHandle);
  if (sequenceInfo) [sequenceInfo release];
  if (sequenceList) [sequenceList release];

  [super dealloc];
}

- (unsigned)numberOfSequences { return [sequenceList count]; }
- (NSDictionary *)infoForSequence:(NSString *)seqID { return [sequenceInfo objectForKey: seqID]; }
- (NSDictionary *)infoForSequenceNumber:(int)seqNum { return [sequenceList objectAtIndex: seqNum]; }

- (char)symbolAtPosition:(unsigned long long)aPos forSequence:(NSString *)seqID
{
  char c = 0;
  [self symbols: &c atPosition: aPos ofLength: 1 forSequence: seqID];

  return c;
}

- (char)symbolAtPosition:(unsigned long long)aPos forSequenceNumber:(int)seqNum
{
  char c = 0;
  [self symbols: &c atPosition: aPos ofLength: 1 forSequenceNumber: seqNum];

  return c;
}

- (int)symbols:(char *)aBuffer atPosition:(unsigned long long)aPos ofLength:(unsigned)aLen forSequenceNumber:(int)seqNum
{
  return 0;
}

- (int)symbols:(char *)aBuffer atPosition:(unsigned long long)aPos ofLength:(unsigned)aLen forSequence:(NSString *)seqID
{
  return 0;
}

- (void)closeFileHandle
{
  if (fileHandle) fclose(fileHandle);
  fileHandle = NULL;
  currentSequenceNumber = -1;
  currentSequence = nil;
}

@end
