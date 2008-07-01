//
//  BCCachedFastaFile.m
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

#import "BCCachedFastaFile.h"
#import "BCSymbolSet.h"

#include <stdio.h>

@implementation BCCachedFastaFile

- initWithContentsOfFile:(NSString *)filePath
{
  [super initWithContentsOfFile: filePath];
  
  // read file and get sequence meta-data
  FILE *g1 = fopen([filePath UTF8String], "r");
  if (!g1) {
    NSLog(@"Could not open file: %@\n", filePath);
    [self dealloc];
    return nil;
  }

  int seqNumber = 0;
  int seqLen = 0;
  int lineLen = 0;
  BOOL needLineLen = YES;
  NSMutableDictionary *d = nil;
  unsigned long long filePos;
  char c;
  while (!feof(g1)) {
    fread(&c, sizeof(char), 1, g1);
    if (feof(g1)) break;

    if (c == '>') {
      // fasta header

      // save length and end position of
      if (d) {
        [d setObject: [NSNumber numberWithInt: seqLen] forKey: @"length"];
        [d setObject: [NSNumber numberWithInt: lineLen] forKey: @"line length"];
        [d setObject: [NSNumber numberWithUnsignedLongLong: (filePos - 1)] forKey: @"end"];
      }

      d = [NSMutableDictionary dictionary];
      NSMutableString *fastaHeader = [NSMutableString string];
      fread(&c, sizeof(char), 1, g1);
      while (c != '\n') {
        [fastaHeader appendFormat: @"%c", c];
        fread(&c, sizeof(char), 1, g1);
      }

      [d setObject: fastaHeader forKey: @"id"];
      [d setObject: [NSNumber numberWithInt: seqNumber] forKey: @"number"];
      filePos = (unsigned long long)ftello(g1);
      [d setObject: [NSNumber numberWithUnsignedLongLong: filePos] forKey: @"start"];

      [sequenceInfo setObject: d forKey: fastaHeader];
      [sequenceList addObject: d];

      seqLen = 0;
      lineLen = 0;
      needLineLen = YES;
      ++seqNumber;
    } else {
      // sequence data
      while ((c != '\n') && (!feof(g1))) {
        ++seqLen;
        if (needLineLen) ++lineLen;
        filePos = (unsigned long long)ftello(g1);
        fread(&c, sizeof(char), 1, g1);
      }
      needLineLen = NO;
    }
  }
  [d setObject: [NSNumber numberWithInt: seqLen] forKey: @"length"];
  [d setObject: [NSNumber numberWithInt: lineLen] forKey: @"line length"];
  [d setObject: [NSNumber numberWithUnsignedLongLong: (filePos - 1)] forKey: @"end"];

  fclose(g1);

  //NSLog(@"%@\n", [sequenceInfo description]);
  //NSLog(@"sequences %d\n", [sequenceList count]);
  return self;
}

- (int)symbols:(char *)aBuffer ForCurrentSequenceAtPosition:(unsigned long long)aPos ofLength:(unsigned)aLen
{
  int result = 0;
  BOOL doForward = YES;

  long seqLen = [[currentSequence objectForKey: @"length"] longValue];
  long lineLen = [[currentSequence objectForKey: @"line length"] longValue];

  unsigned long newPos;
  if (aPos < seqLen) {
    // forward strand
    newPos = aPos;
    if ((aPos + aLen) > seqLen) {
      NSLog(@"Attempting to read past end of forward stand: (%lu)\n", aPos);
      return 0;
    }
  } else {
    // reverse strand
    newPos = 2*seqLen - aPos - aLen;
    if (newPos < 0) {
      NSLog(@"Attempting to read past end of reverse strand: (%lu)\n", aPos);
      return 0;
    }
    doForward = NO;
  }

  int theLine = newPos / lineLen;
  int thePos = newPos % lineLen;
  int offset = theLine * (lineLen + 1) + thePos;
  unsigned long long filePos = [[currentSequence objectForKey: @"start"] unsignedLongLongValue];
  //fsetpos(fileHandle, &filePos);
  fseeko(fileHandle, filePos, SEEK_SET);
  fseek(fileHandle, offset, SEEK_CUR);

  char c;
  while (result < aLen) {
    fread(&c, sizeof(char), 1, fileHandle);
    if (feof(fileHandle)) break;
    
    // skip invalid symbols
    if ([[BCSymbolSet dnaSymbolSet] symbolForChar: c]) {
      if (doForward) {
        // reading forward strand
        aBuffer[result] = c;
        ++result;
      } else {
        // reading reverse strand
        // reverse complement
        switch (c) {
          case 'a': c = 't'; break;
          case 't': c = 'a'; break;
          case 'c': c = 'g'; break;
          case 'g': c = 'c'; break;
          case 'A': c = 'T'; break;
          case 'T': c = 'A'; break;
          case 'C': c = 'G'; break;
          case 'G': c = 'C'; break;
          default: break;
        }
        aBuffer[aLen - result - 1] = c;
        ++result;
      }
    }
  }
  
  return result;
}

- (int)symbols:(char *)aBuffer atPosition:(unsigned long long)aPos ofLength:(unsigned)aLen forSequence:(NSString *)seqID
{
  if (!fileHandle) {
    fileHandle = fopen([sequenceFile UTF8String], "r");
    if (!fileHandle) {
      NSLog(@"Could not open file: %@\n", sequenceFile);
      return 0;
    }
  }

  NSDictionary *d = [sequenceInfo objectForKey: seqID];
  if (!d) {
    NSLog(@"Unknown sequence: %@\n", seqID);
    return 0;
  }

  currentSequenceNumber = [[d objectForKey: @"number"] intValue];
  currentSequence = d;

  return [self symbols: aBuffer ForCurrentSequenceAtPosition: aPos ofLength: aLen];
}

- (int)symbols:(char *)aBuffer atPosition:(unsigned long long)aPos ofLength:(unsigned)aLen forSequenceNumber:(int)seqNum
{
  if (currentSequenceNumber == seqNum)
    return [self symbols: aBuffer ForCurrentSequenceAtPosition: aPos ofLength: aLen];

  if (!fileHandle) {
    fileHandle = fopen([sequenceFile UTF8String], "r");
    if (!fileHandle) {
      NSLog(@"Could not open file: %@\n", sequenceFile);
      return 0;
    }
  }

  NSDictionary *d = [sequenceList objectAtIndex: seqNum];
  if (!d) {
    NSLog(@"Unknown sequence number: %d\n", seqNum);
    return 0;
  }
  currentSequenceNumber = seqNum;
  currentSequence = d;

  return [self symbols: aBuffer ForCurrentSequenceAtPosition: aPos ofLength: aLen];
}

@end
