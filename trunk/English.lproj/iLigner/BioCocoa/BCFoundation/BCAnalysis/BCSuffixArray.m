//
//  BCSuffixArray.m
//  BioCocoa
//
//  Created by Scott Christley on 7/20/07.
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

/*
Hybrid suffix-array builder, written by Sean Quinlan and Sean Doward,
distributed under the Plan 9 license, which reads in part

3.3 With respect to Your distribution of Licensed Software (or any
portion thereof), You must include the following information in a
conspicuous location governing such distribution (e.g., a separate
file) and on all copies of any Source Code version of Licensed
Software You distribute:

    "The contents herein includes software initially developed by
    Lucent Technologies Inc. and others, and is subject to the terms
    of the Lucent Technologies Inc. Plan 9 Open Source License
    Agreement.  A copy of the Plan 9 Open Source License Agreement is
    available at: http://plan9.bell-labs.com/plan9dist/download.html
    or by contacting Lucent Technologies at http: //www.lucent.com.
    All software distributed under such Agreement is distributed on,
    obligations and limitations under such Agreement.  Portions of
    the software developed by Lucent Technologies Inc. and others are
    Copyright (c) 2002.  All rights reserved.
    Contributor(s):___________________________"
*/

#import "BCSuffixArray.h"
#import "BCFoundationDefines.h"
#import "BCSequenceArray.h"
#import "BCSequenceReader.h"
#import "BCSymbolSet.h"
#import "BCAnnotation.h"

#include <unistd.h>

// suffix array routines
// static int sarray(int *a, int n);
static int bsarray(const unsigned char *b, int *a, int n);

static long long max_physical_memory();

#define ALL_SEQS 0
#define ONE_SEQ 1
#define ONE_STRAND 2

// memory concatenation of sequences
//static unsigned char* mem_concate(BCSequenceArray *anArray, NSString *strand);

@implementation BCSuffixArray

- init
{
  [super init];

  sequenceArray = nil;
  metaDict = nil;
  dirPath = nil;
  memSequence = NULL;
  numOfSuffixes = 0;
  suffixArray = NULL;
  inMemory = YES;
  maxMemoryUsage = 0;
  memoryState = ALL_SEQS;

  return self;
}

- (void)dealloc
{
  if (sequenceArray) [sequenceArray release];
  if (reverseComplementArray) [reverseComplementArray release];
  if (metaDict) [metaDict release];
  if (dirPath) [dirPath release];
  if (memSequence) free(memSequence);
  if (suffixArray) free(suffixArray);

  [super dealloc];
}

//
// Helper methods for managing in memory sequence
//
- (long long)checkMemoryForSequence:(int)anIndex oneStrand:(BOOL)aFlag
{
  // no sequence then don't need memory
  if (!sequenceArray) return 0;
  BCSequence *aSeq = [sequenceArray sequenceAtIndex: anIndex];
  if (!aSeq) return 0;

  // rough calculation
  long long totSize = [aSeq length];
  if (!aFlag) {
    // other strand
    totSize *= 2;
  }

  // suffix array
  totSize = totSize * 2 * sizeof(int);

  printf("totSize: %llu\n", totSize);

  return totSize;
}

- (BOOL)checkMemory
{
  int i;
  long long maxMem;
  long long totSize = 0;

  // no sequence then don't need memory
  if (!sequenceArray) return YES;
  int cnt = [sequenceArray count];
  if (cnt == 0) return YES;

  BOOL oneStrand;
  NSString *aStrand = [metaDict objectForKey: @"strand"];
  if (!aStrand) oneStrand = NO;
  else oneStrand = YES;

  // max memory we should use
  if (maxMemoryUsage) maxMem = maxMemoryUsage;
  else maxMem = max_physical_memory();

  // rough calculation for all sequences
  // one strand
  for (i = 0; i < cnt; ++i) {
    BCSequence *aSeq = [sequenceArray sequenceAtIndex: i];
    totSize += [aSeq length];
    ++totSize;  // N separator between sequences
  }
  if (!oneStrand) {
    // other strand
    totSize *= 2;
  }

  // suffix array
  totSize = totSize * 2 * sizeof(int);

  printf("totSize: %llu\n", totSize);
  printf("maxMem: %llu\n", maxMem);

  BOOL check = YES;
  if (totSize > maxMem) check = NO;
  if (check) {
    printf("Sufficient memory for all sequences.\n");
    memoryState = ALL_SEQS;
    return YES;
  } else {
    // If all sequences will not fit in memory, check individual
    check = YES;
    // individual sequences, with however many strands
    for (i = 0; i < [sequenceArray count]; ++i) {
      totSize = [self checkMemoryForSequence: i oneStrand: oneStrand];
      if (totSize > maxMem) {
        check = NO;
        break;
      }
    }
    if (check) {
      printf("Sufficient memory for one sequence at a time.\n");
      memoryState = ONE_SEQ;
      return YES;
    } else {
      // if doing both strands, check on strand at a time
      if (!oneStrand) {
        check = YES;
        for (i = 0; i < [sequenceArray count]; ++i) {
          totSize = [self checkMemoryForSequence: i oneStrand: YES];
          if (totSize > maxMem) {
            check = NO;
            break;
          }
        }
      }
      if (check) {
        printf("Sufficient memory for one strand at a time.\n");
        memoryState = ONE_STRAND;
        return YES;
      }
    }
  }
  
  NSLog(@"Insufficient memory to construct suffix array.\n");
  return NO;
}

- (BOOL)constructMemorySequence
{
  int i, j, totSize = 0;

  NSString *aStrand = [metaDict objectForKey: @"strand"];
  NSMutableArray *seqMeta = [metaDict objectForKey: @"sequences"];

  // determine total size of sequences
  for (i = 0; i < [sequenceArray count]; ++i) {
    BCSequence *aSeq = [sequenceArray sequenceAtIndex: i];
    totSize += [aSeq length];
    ++totSize;  // N separator between sequences

    NSMutableDictionary *d = [NSMutableDictionary new];
    [d setObject: [NSNumber numberWithInt: [aSeq length]] forKey: @"length"];
    [d setObject: [[aSeq annotationForKey: @">"] content] forKey: @"id"];
    [seqMeta addObject: d];
  }
  printf("%d bytes\n", totSize);

  // allocate memory to create one long sequence
  // from the concatenation of the sequences
  if (memSequence) free(memSequence);
  int n;
  if (aStrand) n = totSize;
  else n = 2 * totSize;
  printf("Allocating %d bytes.\n", n + 2);
  memSequence = (unsigned char *)malloc(sizeof(unsigned char) * (n + 2));
  if (!memSequence) {
    printf("too big\n");
    return NO;
  }
  bzero(memSequence, n + 1);
  
  // concatenate sequences
  int curPos = 0;
  if ((!aStrand) || ([aStrand isEqualToString: @"F"])) {
    for (i = 0; i < [sequenceArray count]; ++i) {
      memSequence[curPos++] = BCSUFFIXARRAY_TERM_CHAR;
      BCSequence *aSeq = [sequenceArray sequenceAtIndex: i];
      const unsigned char *seqBytes = [aSeq bytes];
      NSMutableDictionary *d = [seqMeta objectAtIndex: i];
      [d setObject: [NSNumber numberWithInt: curPos] forKey: @"position"];

      for (j = 0; j < [aSeq length]; ++j) {
        // mask
        switch (seqBytes[j]) {
          case 'A': memSequence[curPos++] = 'A'; break;
          case 'T': memSequence[curPos++] = 'T'; break;
          case 'C': memSequence[curPos++] = 'C'; break;
          case 'G': memSequence[curPos++] = 'G'; break;
          default: memSequence[curPos++] = BCSUFFIXARRAY_TERM_CHAR; break;
        }
      }
    }
    memSequence[curPos] = '\0';
    [metaDict setObject: [NSNumber numberWithInt: curPos] forKey: @"length"];
    //printf("%d %c %c\n", curPos, memSequence[curPos-1], memSequence[curPos]);
  }

  // perform our own reverse complement
  // to avoid doubling the sequences
  if (!aStrand) {
    // calculate reverse strand positions
    int oldPos = curPos - 1;
    int nextPos = curPos + 1;
    for (j = [seqMeta count] - 1; j >= 0; --j) {
      NSMutableDictionary *d = [seqMeta objectAtIndex: j];
      [d setObject: [NSNumber numberWithInt: nextPos] forKey: @"reverse"];
      int aPos = [[d objectForKey: @"position"] intValue];
      nextPos += oldPos - aPos + 2;
      oldPos = aPos - 2;
    }

    // add reverse strand
    int k = curPos;
    memSequence[k] = BCSUFFIXARRAY_TERM_CHAR;
    ++k;
    for (j = curPos-1; j >= 0; --j) {
      switch (memSequence[j]) {
        // mask
        case 'A': memSequence[k] = 'T'; break;
        case 'T': memSequence[k] = 'A'; break;
        case 'C': memSequence[k] = 'G'; break;
        case 'G': memSequence[k] = 'C'; break;
        default: memSequence[k] = BCSUFFIXARRAY_TERM_CHAR; break;
      }
      ++k;
    }
    memSequence[k] = '\0';
    curPos = k;

  } else if ([aStrand isEqualToString: @"R"]) {
    // only reverse strand
    for (i = 0; i < [sequenceArray count]; ++i) {
      memSequence[curPos++] = BCSUFFIXARRAY_TERM_CHAR;
      BCSequence *aSeq = [sequenceArray sequenceAtIndex: i];
      const unsigned char *seqBytes = [aSeq bytes];
      NSMutableDictionary *d = [seqMeta objectAtIndex: i];
      [d setObject: [NSNumber numberWithInt: curPos] forKey: @"position"];

      for (j = [aSeq length] - 1; j >= 0; --j) {
        // mask
        switch (seqBytes[j]) {
          case 'A': memSequence[curPos++] = 'T'; break;
          case 'T': memSequence[curPos++] = 'A'; break;
          case 'C': memSequence[curPos++] = 'G'; break;
          case 'G': memSequence[curPos++] = 'C'; break;
          default: memSequence[curPos++] = BCSUFFIXARRAY_TERM_CHAR; break;
        }
      }
    }
    memSequence[curPos] = '\0';
    [metaDict setObject: [NSNumber numberWithInt: curPos] forKey: @"length"];
  }
  printf("total size %d (bp)\n", curPos);
  //printf("%s\n", memSequence);

  numOfSuffixes = curPos;
  
  return YES;
}

- (int)sequence:(NSArray *)a forMemoryPosition:(int)position isForward:(BOOL)isForward
{
  int cnt = [a count];
  
#if 0
  printf("position: %d %d\n", position, isForward);
#endif
  
  // empty array
  if (cnt == 0) {
    printf("ERROR: empty meta data array.\n");
    return -1;
  }

  // only one sequence
  //if (cnt == 1) return 0;

  // Binary search to find start interval
  int uPos = cnt - 1;
  int lPos = 0;
  int startPos = 0;
  BOOL done = NO;
  while (!done) {
    startPos = (uPos + lPos) / 2;
#if 0
    printf("uPos: %d lPos: %d startPos: %d\n", uPos, lPos, startPos);
#endif
    if (startPos == cnt) break;
    NSDictionary *d = [a objectAtIndex: startPos];
    NSNumber *n;
    if (isForward)
      n = [d objectForKey: @"position"];
    else
      n = [d objectForKey: @"reverse"];
    
    if ([n intValue] == position) return startPos;
    
    if (isForward) {
      // array is in ascending order for forward strand
      if ([n intValue] > position) {
        uPos = startPos;
      } else {
        lPos = startPos;
      }
      
      if (lPos == uPos) {
        if ([n intValue] <= position)
          return startPos;
        else {
          --lPos;
          --uPos;
        }
      }
      
      if ((lPos + 1) == uPos) {
        lPos = uPos;
      }
    } else {
      // array is in descending order for reverse strand
      if ([n intValue] > position) {
        lPos = startPos;
      } else {
        uPos = startPos;
      }
      
      if (lPos == uPos) {
        if ([n intValue] <= position)
          return startPos;
        else {
          ++lPos;
          ++uPos;
        }
      }
      
      if ((lPos + 1) == uPos) {
        uPos = lPos;
      }
    }
  }
  
#if 0
  printf("ERROR uPos: %d lPos: %d startPos: %d count: %d\n", uPos, lPos, startPos, cnt);
#endif
  
  return -1;
}

//
// Build the suffix array
//

- (BOOL)constructFromSequence:(BCSequence *)aSequence strand:(NSString *)aStrand
{
  printf("Building suffix array.\n");

  if (!aSequence) return NO;
  BCSequenceArray *anArray = [[[BCSequenceArray alloc] init] autorelease];
  [anArray addSequence: aSequence];
  
  return [self constructFromSequenceArray: anArray strand: aStrand];
}

- (BOOL)constructFromSequenceArray:(BCSequenceArray *)anArray strand:(NSString *)aStrand
{
  if (!anArray) return NO;
  if ([anArray count] == 0) return NO;

  if (metaDict) [metaDict release];
  metaDict = [NSMutableDictionary new];

  if (aStrand) [metaDict setObject: aStrand forKey: @"strand"];

  NSMutableArray *seqMeta = [NSMutableArray new];
  [metaDict setObject: seqMeta forKey: @"sequences"];

  // put sequences into memory
  sequenceArray = [anArray retain];
  if (![self checkMemory]) return NO;
  switch (memoryState) {
    case ALL_SEQS: {
      // easy, all sequences in memory
      if (![self constructMemorySequence]) return NO;

      // allocate memory for suffix array
      if (suffixArray) {
        free(suffixArray);
        suffixArray = NULL;
      }
      suffixArray = malloc((numOfSuffixes+1) * sizeof(int));
      if (!suffixArray) {
        printf("cannot allocate suffix array\n");
        return NO;
      }

      // construct suffix array
      bsarray(memSequence, suffixArray, numOfSuffixes);
      break;
    }
    case ONE_SEQ: {
      // construct suffix area for each individual sequence
      // then we will union them together
      int i;
      char tmpID[7] = {'X', 'X', 'X', 'X', 'X', 'X', 0};
      mktemp(tmpID);
      printf("tmpID: %s\n", tmpID);
      NSString *s = [NSMutableString stringWithFormat: @"%@/seq.%s", NSTemporaryDirectory(), tmpID];
      printf("tmp file: %s\n", [s UTF8String]);
      for (i = 0; i < [sequenceArray count]; ++i) {
      }
    }
    case ONE_STRAND: {
      // construct suffix area for each strand
      // then we will union them together
      int i;
      char tmpID[7] = {'X', 'X', 'X', 'X', 'X', 'X', 0};
      mktemp(tmpID);
      printf("tmpID: %s\n", tmpID);
      NSString *tmpFile = [NSString stringWithFormat: @"%@/seq.%s", NSTemporaryDirectory(), tmpID];
      printf("tmp file: %s\n", [tmpFile UTF8String]);
      for (i = 0; i < [sequenceArray count]; ++i) {
        BCSequence *aSeq = [sequenceArray sequenceAtIndex: i];
        if (aStrand) {
          // one strand
          BCSuffixArray *sa = [[BCSuffixArray alloc] init];
          [sa constructFromSequence: aSeq strand: aStrand];
          NSString *s = [NSString stringWithFormat: @"%@.%d", tmpFile, i];
          [sa writeToFile: s withMasking: NO];
          [sa release];
        } else {
          // both strands
          BCSuffixArray *sa = [[BCSuffixArray alloc] init];
          [sa constructFromSequence: aSeq strand: @"F"];
          NSString *s = [NSString stringWithFormat: @"%@.F.%d", tmpFile, i];
          [sa writeToFile: s withMasking: NO];
          [sa release];
          
          sa = [[BCSuffixArray alloc] init];
          [sa constructFromSequence: aSeq strand: @"R"];
          s = [NSString stringWithFormat: @"%@.R.%d", tmpFile, i];
          [sa writeToFile: s withMasking: NO];
          [sa release];
        }
      }
      
      // now union them together
    }
  }

  return YES;
}

- (BOOL)constructFromSequenceFile:(NSString *)aPath strand:(NSString *)aStrand
{
  if (!aPath) return NO;
  
  BCSequenceReader *sequenceReader = [[[BCSequenceReader alloc] init] autorelease];
  BCSequenceArray *anArray = [sequenceReader readFileUsingPath: aPath];
  if ([anArray count] == 0) return NO;
  if ([self constructFromSequenceArray: anArray strand: aStrand]) {
    [metaDict setObject: aPath forKey: @"sequences file"];
    return YES;
  } else return NO;
}

- (void)buildReverseComplementArray
{
  int cnt = [sequenceArray count];
  int i;
  
  if (reverseComplementArray) [reverseComplementArray release];
  reverseComplementArray = [[BCSequenceArray alloc] init];

  for (i = 0; i < cnt; ++i) {
    BCSequence *aSeq = [sequenceArray sequenceAtIndex: i];
    int j;
    char *seqData = (char *)[[aSeq sequenceData] bytes];
    int seqLen = [aSeq length];
    char *revData = (char *)malloc(seqLen * sizeof(char));
    for (j = 0; j < seqLen; ++j) {
      char c = seqData[j];
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
      revData[seqLen - j - 1] = c;
    }
    NSData *finalData = [NSData dataWithBytes: revData length: seqLen];
    BCSequence *newSequence = [[BCSequence alloc] initWithData: finalData symbolSet: [BCSymbolSet dnaSymbolSet]];
    [reverseComplementArray addSequence: newSequence];
  }
}

- initWithContentsOfFile:(NSString *)aPath inMemory:(BOOL)aFlag
{
  [super init];

  inMemory = aFlag;

  // read meta file
  NSString *metaFile = [aPath stringByAppendingPathExtension: @"meta_sa"];
  metaDict = [[NSMutableDictionary alloc] initWithContentsOfFile: metaFile];
  if (!metaDict) {
    NSLog(@"Failed to load meta-data file: %@\n", metaFile);
    return nil;
  }

  // fix up paths
  dirPath = [[metaFile stringByDeletingLastPathComponent] retain];
  NSString *s = [metaDict objectForKey: @"sequences file"];
  if (!s) {
    NSLog(@"Meta-data file is corrupt, missing path to 'sequences file'.\n");
    return nil;
  }
  if (![s isAbsolutePath]) {
    s = [dirPath stringByAppendingPathComponent: s];
    [metaDict setObject: s forKey: @"sequences file"];
  }
  s = [metaDict objectForKey: @"suffix array file"];
  if (!s) {
    NSLog(@"Meta-data file is corrupt, missing path to 'suffix array file'.\n");
    return nil;
  }
  if (![s isAbsolutePath]) {
    s = [dirPath stringByAppendingPathComponent: s];
    [metaDict setObject: s forKey: @"suffix array file"];
  }

  // load up sequences
  s = [metaDict objectForKey: @"sequences file"];
  BCSequenceReader *sequenceReader = [[[BCSequenceReader alloc] init] autorelease];
  sequenceArray = [sequenceReader readFileUsingPath: s];
  [self buildReverseComplementArray];
  //if (![self constructMemorySequence]) return nil;

  // load up suffix array into memory
  if (inMemory) {
  }

  return self;
}

//
// Suffix array file operations
//

- (BOOL)memoryWriteToFile:(NSString *)aPath withMasking:(BOOL)aFlag
{
  int i, j;

  if (!memSequence) return NO;
  if (!aPath) return NO;

  // save size
  int totSize = [[metaDict objectForKey: @"length"] intValue];

  // write meta file
  NSString *saFile = [aPath stringByAppendingPathExtension: @"sa"];
  [metaDict setObject: saFile forKey: @"suffix array file"];
  NSString *metaFile = [aPath stringByAppendingPathExtension: @"meta_sa"];
  NSArray *seqMeta = [metaDict objectForKey: @"sequences"];

  int totLength = 0;
  NSMutableArray *newSeqMeta = [NSMutableArray new];
  for (j = 0; j < [seqMeta count]; ++j) {
    NSDictionary *d = [seqMeta objectAtIndex: j];
    NSMutableDictionary *nd = [NSMutableDictionary dictionaryWithDictionary: d];
    [nd setObject: [NSNumber numberWithInt: j] forKey: @"number"];
    [nd removeObjectForKey: @"position"];
    [nd removeObjectForKey: @"reverse"];
    totLength += [[d objectForKey: @"length"] intValue];
    [newSeqMeta addObject: nd];
  }
  [metaDict setObject: [NSNumber numberWithInt: totLength] forKey: @"length"];
  [metaDict setObject: newSeqMeta forKey: @"sequences"];
  [metaDict writeToFile: metaFile atomically: YES];

  FILE *g1 = fopen([saFile cString], "w");
  if (!g1) {
    printf("Could not open file: %s\n", [saFile cString]);
    return NO;
  }
  //fprintf(g1, "1\n");
  //fprintf(g1, "%s\n", [[metaFile lastPathComponent] cString]);

  for (i = 0; i <= numOfSuffixes; ++i) {
    int sid = 0;
    int suffixPos = suffixArray[i];
    char c = memSequence[suffixArray[i]];

    // skip separator chars
    if ((c != 'A') && (c != 'C') && (c != 'G') && (c != 'T')) continue;

    if (suffixPos > totSize) {
      sid = [self sequence: seqMeta forMemoryPosition: suffixPos isForward: NO];
      NSDictionary *d = [seqMeta objectAtIndex: sid];
      NSNumber *length = [d objectForKey: @"length"];
      NSNumber *reverse = [d objectForKey: @"reverse"];
      suffixPos = suffixPos - [reverse intValue] + [length intValue];
    } else {
      sid = [self sequence: seqMeta forMemoryPosition: suffixPos isForward: YES];
      NSDictionary *d = [seqMeta objectAtIndex: sid];
      NSNumber *position = [d objectForKey: @"position"];
      suffixPos = suffixPos - [position intValue];
    }

    fwrite(&suffixPos, sizeof(int), 1, g1);
    fwrite(&sid, sizeof(int), 1, g1);
  }
  fclose(g1);

  return YES;
}

- (BOOL)fileWriteToFile:(NSString *)aPath withMasking:(BOOL)aFlag
{
  printf("fileWriteToFile:withMasking: not implemented\n");
  return NO;
}

- (BOOL)writeToFile:(NSString *)aPath withMasking:(BOOL)aFlag
{
  if (inMemory) return [self memoryWriteToFile: aPath withMasking: aFlag];
  else return [self fileWriteToFile: aPath withMasking: aFlag];
}

- (FILE *)getFILE
{
  if (!metaDict) return NULL;
  NSString *s = [metaDict objectForKey: @"suffix array file"];
  if (!s) return NULL;
  FILE *sa = fopen([s UTF8String], "r");
  return sa;
}

//
// Accessor methods
//

- (int)numberOfSequences { return [sequenceArray count]; }
- (int)numOfSuffixes { return numOfSuffixes; }
- (const int *)suffixArray { return suffixArray; }
- (unsigned char *)memoryForSequence:(int)aNum { return memSequence; }
- (BCSequenceArray *)sequenceArray { return sequenceArray; }
- (BCSequenceArray *)reverseComplementArray { return reverseComplementArray; }
- (NSDictionary *)metaDictionary { return metaDict; }

//
// Debugging methods
//

- (void)dumpSuffixArray
{
  //if (!memSequence) return;

  if (inMemory) {
    int i;
    for (i = 0; i <= numOfSuffixes; ++i) {
      printf("offset: %d seq: ", suffixArray[i]);
      
      int seqLen = 0;
      while ((suffixArray[i] + seqLen) < numOfSuffixes) {
        printf("%c", memSequence[suffixArray[i] + seqLen]);
        ++seqLen;
        if (seqLen > 50) {
          printf(" ... ");
          break;
        }
      }
      printf("\n");
    }
  } else {
    FILE *sa1 = [self getFILE];
    if (!sa1) return;

    int sa1Offset, sa1File;
    fread(&sa1Offset, sizeof(int), 1, sa1);
    fread(&sa1File, sizeof(int), 1, sa1);
    while (!feof(sa1)) {
      BCSequence *aSeq = [sequenceArray sequenceAtIndex: sa1File];
      BCSequence *revSeq = [reverseComplementArray sequenceAtIndex: sa1File];
      BCAnnotation *anno = [aSeq annotationForKey: @">"];
      int seqLen = [aSeq length];
      //int revLen = 2 * seqLen;
      //printf("%d\n", seqLen);

      char *seqData;
      int seqStart = 0;
      if (sa1Offset < seqLen) {
        // forward strand
        printf("offset: %d strand: F id: %s\n", sa1Offset, [[anno stringValue] UTF8String]);
        seqData = (char *)[[aSeq sequenceData] bytes];
        seqStart = sa1Offset;
      } else {
        // reverse strand
        printf("offset: %d strand: R id: %s\n", sa1Offset, [[anno stringValue] UTF8String]);
        seqData = (char *)[[revSeq sequenceData] bytes];
        seqStart = sa1Offset - seqLen;
      }
        
      int seqPos = 0;
      while ((seqStart + seqPos) < seqLen) {
        printf("%c", seqData[seqStart + seqPos]);
        ++seqPos;
        if (seqPos > 50) {
          printf(" ... ");
          break;
        }
      }
      printf("\n");
      
      // next sequence
      fread(&sa1Offset, sizeof(int), 1, sa1);
      fread(&sa1File, sizeof(int), 1, sa1);
    }

    fclose(sa1);
  }
}

- (void)dumpSuffixArrayForSequence:(int)aSeq position:(int)aPos length:(int)aLen;
{
  BCSequence *forSeq = [sequenceArray sequenceAtIndex: aSeq];
  if (!forSeq) return;
  BCAnnotation *anno = [forSeq annotationForKey: @">"];
  BCSequence *revSeq = [reverseComplementArray sequenceAtIndex: aSeq];
  int seqLen = [forSeq length];
  const char *seqData;
  
  int seqStart = 0;
  if (aPos < seqLen) {
    // forward strand
    printf("offset: %d strand: F id: %s\n", aPos, [[anno stringValue] UTF8String]);
    seqData = [[forSeq sequenceData] bytes];
    seqStart = aPos;
  } else {
    // reverse strand
    printf("offset: %d strand: R id: %s\n", aPos, [[anno stringValue] UTF8String]);
    seqData = [[revSeq sequenceData] bytes];
    seqStart = aPos - seqLen;
  }
  
  int seqPos = 0;
  while ((seqStart + seqPos) < seqLen) {
    printf("%c", seqData[seqStart + seqPos]);
    ++seqPos;
    if (seqPos == aLen) break;
  }
  printf("\n");
}

@end

//
// Suffix array routines
// These are made internal functions
//

/*	
	int sarray(int a[], int n)
Purpose
	Return in a[] a suffix array for the original
	contents of a[].  (The original values in a[]
	are typically serial numbers of distinct tokens
	in some list.)

Precondition
	Array a[] holds n values, with n>=1.  Exactly k 
	distinct values, in the range 0..k-1, are present.
	Value 0, an endmark, appears exactly once, at a[n-1].

Postcondition
	Array a[] is a copy of the internal array p[]
	that records the sorting permutation: if i<j
	then the original suffix a[p[i]..n-1] is
	lexicographically less than a[p[j]..n-1].

Return value
	-1 on error.
	Otherwise index i such that a[i]==0, i.e. the
        index of the whole-string suffix, used in
	Burrows-Wheeler data compression.
*/

#include <stdlib.h>
#include <string.h>

typedef unsigned char uchar;

#define pred(i, h) ((t=(i)-(h))<0?  t+n: t)
#define succ(i, h) ((t=(i)+(h))>=n? t-n: t)

enum
{
	BUCK = ~(~0u>>1),	/* high bit */
	MAXI = ~0u>>1,		/* biggest int */
};

static	void	qsort2(int*, int*, int n);
static	int	ssortit(int a[], int p[], int n, int h, int *pe, int nbuck);

#if 0 // not currently used
static int
sarray(int a[], int n)
{
	int i, l;
	int c, cc, ncc, lab, cum, nbuck;
	int k;
	int *p = 0;
	int result = -1;
	int *al;
	int *pl;

	for(k=0,i=0; i<n; i++)	
		if(a[i] > k)
			k = a[i];	/* max element */
	k++;
	if(k>n)
		goto out;

	nbuck = 0;
	p = malloc(n*sizeof(int));
	if(p == 0)
		goto out;


	pl = p + n - k;
	al = a;
	memset(pl, -1, k*sizeof(int));

	for(i=0; i<n; i++) {		/* (1) link */
		l = a[i];
		al[i] = pl[l];
		pl[l] = i;
	}

	for(i=0; i<k; i++)		/* check input - no holes */
		if(pl[i]<0)
			goto out;

	
	lab = 0;			/* (2) create p and label a */
	cum = 0;
	i = 0;
	for(c = 0; c < k; c++){	
		for(cc = pl[c]; cc != -1; cc = ncc){
			ncc = al[cc];
			al[cc] = lab;
			cum++;
			p[i++] = cc;
		}
		if(lab + 1 == cum) {
			i--;
		} else {
			p[i-1] |= BUCK;
			nbuck++;
		}
		lab = cum;
	}

	result = ssortit(a, p, n, 1, p+i, nbuck);
	memcpy(a, p, n*sizeof(int));
	
out:
	free(p);
	return result;
}
#endif

/* bsarray(uchar buf[], int p[], int n)
 * The input, buf, is an arbitrary byte array of length n.
 * The input is copied to temporary storage, relabeling 
 * pairs of input characters and appending a unique end marker 
 * having a value that is effectively less than any input byte.
 * The suffix array of this extended input is computed and
 * stored in p, which must have length at least n+1.
 *
 * Returns the index of the identity permutation (regarding
 * the suffix array as a list of circular shifts),
 * or -1 if there was an error.
 */
static int
bsarray(const uchar buf[], int p[], int n)
{
	int *a, buckets[256*256];
	int i, last, cum, c, cc, ncc, lab, id, nbuck;

	a = malloc((n+1)*sizeof(int));
	if(a == 0)
		return -1;


	memset(buckets, -1, sizeof(buckets));
	c = buf[n-1] << 8;
	last = c;
	for(i = n - 2; i >= 0; i--){
		c = (buf[i] << 8) | (c >> 8);
		a[i] = buckets[c];
		buckets[c] = i;
	}

	/*
	 * end of string comes before anything else
	 */
	a[n] = 0;

	lab = 1;
	cum = 1;
	i = 0;
	nbuck = 0;
	for(c = 0; c < 256*256; c++) {
		/*
		 * last character is followed by unique end of string
		 */
		if(c == last) {
			a[n-1] = lab;
			cum++;
			lab++;
		}

		for(cc = buckets[c]; cc != -1; cc = ncc) {
			ncc = a[cc];
			a[cc] = lab;
			cum++;
			p[i++] = cc;
		}
		if(lab == cum)
			continue;
		if(lab + 1 == cum)
			i--;
		else {
			p[i - 1] |= BUCK;
			nbuck++;
		}
		lab = cum;
	}

	id = ssortit(a, p, n+1, 2, p+i, nbuck);
	free(a);
	return id;
}

static int
ssortit(int a[], int p[], int n, int h, int *pe, int nbuck)
{
	int *s, *ss, *packing, *sorting;
	int v, sv, vv, packed, lab, t, i;

	for(; h < n && p < pe; h=2*h) {
		packing = p;
		nbuck = 0;

		for(sorting = p; sorting < pe; sorting = s){
			/*
			 * find length of stuff to sort
			 */
			lab = a[*sorting];
			for(s = sorting; ; s++) {
				sv = *s;
				v = a[succ(sv & ~BUCK, h)];
				if(v & BUCK)
					v = lab;
				a[sv & ~BUCK] = v | BUCK;
				if(sv & BUCK)
					break;
			}
			*s++ &= ~BUCK;
			nbuck++;

			qsort2(sorting, a, s - sorting);

			v = a[*sorting];
			a[*sorting] = lab;
			packed = 0;
			for(ss = sorting + 1; ss < s; ss++) {
				sv = *ss;
				vv = a[sv];
				if(vv == v) {
					*packing++ = ss[-1];
					packed++;
				} else {
					if(packed) {
						*packing++ = ss[-1] | BUCK;
					}
					lab += packed + 1;
					packed = 0;
					v = vv;
				}
				a[sv] = lab;
			}
			if(packed) {
				*packing++ = ss[-1] | BUCK;
			}
		}
		pe = packing;
	}

	/*
	 * reconstuct the permutation matrix
	 * return index of the entire string
	 */
	v = a[0];
	for(i = 0; i < n; i++)
		p[a[i]] = i;

	return v;
}

/*
 * qsort from Bentley and McIlroy, Software--Practice and Experience
   23 (1993) 1249-1265, specialized for sorting permutations based on
   successors
 */
static void
vecswap2(int *a, int *b, int n)
{
	while (n-- > 0) {
        	int t = *a;
		*a++ = *b;
		*b++ = t;
	}
}

#define swap2(a, b) { t = *(a); *(a) = *(b); *(b) = t; }

static int*
med3(int *a, int *b, int *c, int *asucc)
{
	int va, vb, vc;

	if ((va=asucc[*a]) == (vb=asucc[*b]))
		return a;
	if ((vc=asucc[*c]) == va || vc == vb)
		return c;	   
	return va < vb ?
		  (vb < vc ? b : (va < vc ? c : a))
		: (vb > vc ? b : (va < vc ? a : c));
}

static void
inssort(int *a, int *asucc, int n)
{
	int *pi, *pj, t;

	for (pi = a + 1; --n > 0; pi++)
		for (pj = pi; pj > a; pj--) {
			if(asucc[pj[-1]] <= asucc[*pj])
				break;
			swap2(pj, pj-1);
		}
}

static void
qsort2(int *a, int *asucc, int n)
{
	int d, r, partval;
	int *pa, *pb, *pc, *pd, *pl, *pm, *pn, t;

	if (n < 15) {
		inssort(a, asucc, n);
		return;
	}
	pl = a;
	pm = a + (n >> 1);
	pn = a + (n-1);
	if (n > 30) { /* On big arrays, pseudomedian of 9 */
		d = (n >> 3);
		pl = med3(pl, pl+d, pl+2*d, asucc);
		pm = med3(pm-d, pm, pm+d, asucc);
		pn = med3(pn-2*d, pn-d, pn, asucc);
	}
	pm = med3(pl, pm, pn, asucc);
	swap2(a, pm);
	partval = asucc[*a];
	pa = pb = a + 1;
	pc = pd = a + n-1;
	for (;;) {
		while (pb <= pc && (r = asucc[*pb]-partval) <= 0) {
			if (r == 0) {
				swap2(pa, pb);
				pa++;
			}
			pb++;
		}
		while (pb <= pc && (r = asucc[*pc]-partval) >= 0) {
			if (r == 0) {
				swap2(pc, pd);
				pd--;
			}
			pc--;
		}
		if (pb > pc)
			break;
		swap2(pb, pc);
		pb++;
		pc--;
	}
	pn = a + n;
	r = pa-a;
	if(pb-pa < r)
		r = pb-pa;
	vecswap2(a, pb-r, r);
	r = pn-pd-1;
	if(pd-pc < r)
		r = pd-pc;
	vecswap2(pb, pn-r, r);
	if ((r = pb-pa) > 1)
		qsort2(a, asucc, r);
	if ((r = pd-pc) > 1)
		qsort2(a + n-r, asucc, r);
}

// Get
#ifdef __APPLE__
#include <sys/types.h>
#include <sys/sysctl.h>
static long long max_physical_memory()
{
#if 1
  int mib[2];
  size_t len;
  unsigned int *p;
  long long max;
  
  mib[0] = CTL_HW;
  mib[1] = HW_PHYSMEM;
  sysctl(mib, 2, NULL, &len, NULL, 0);
  p = malloc(len);
  sysctl(mib, 2, p, &len, NULL, 0);

  // leave 100Mb spare
  max = (long long)*p;
  max = max - 100000000;
  free(p);
  return max;
#else
  // actual physical memory
  int      ret;
  size_t   oldlen;
  uint64_t physmem_size;
  oldlen = sizeof(physmem_size);
  ret = sysctlbyname("hw.memsize", &physmem_size, &oldlen, NULL, 0);
  return physmem_size;
#endif
 }
#else
// not __APPLE__                                                                                                                                                                                      

// should work for Linux systems with /proc/meminfo
static long long max_physical_memory()
{
  long long availMem = 0;

  NSFileManager *fileManager = [NSFileManager defaultManager];

  if ([fileManager fileExistsAtPath: @"/proc/meminfo"]) {
    NSString *memInfo = [NSString stringWithContentsOfFile: @"/proc/meminfo"];
    NSRange r = [memInfo rangeOfString: @"MemTotal:"];
    if (r.location == NSNotFound) {
      NSLog(@"Cannot determine amount of physical memory.");
      return 0;
    }
    NSString *s = [[memInfo substringFromIndex: (r.location + r.length)]
                    stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSArray *a = [s componentsSeparatedByString: @" "];
    s = [a objectAtIndex: 0];
    availMem = [s intValue];
    availMem *= 1024;
  } else {
    NSLog(@"Cannot determine amount of physical memory.");
  }

  return availMem;
}
#endif

//
// Suffix array enumeration classes
//

@implementation BCSuffixArrayUnionEnumerator

- initWithSuffixArrays:(NSArray *)arrays
{
  [super init];
  
  if ([arrays count] == 0) return nil;

  suffixArrays = [arrays retain];
  suffixPositions = (int *)malloc(sizeof(int) * [suffixArrays count]);
  suffixSequences = (int *)malloc(sizeof(int) * [suffixArrays count]);
  saSeqs = (BCSequenceArray **)malloc(sizeof(BCSequenceArray *) * [suffixArrays count]);
  saRevs = (BCSequenceArray **)malloc(sizeof(BCSequenceArray *) * [suffixArrays count]);
  arrayFiles = (FILE **)malloc(sizeof(FILE *) * [suffixArrays count]);
  eofFlags = (BOOL *)malloc(sizeof(BOOL) * [suffixArrays count]);
  int i;
  for (i = 0; i < [suffixArrays count]; ++i) {
    suffixPositions[i] = -1;
    arrayFiles[i] = NULL;
    eofFlags[i] = NO;
    BCSuffixArray *sa = [suffixArrays objectAtIndex: i];
    saSeqs[i] = [sa sequenceArray];
    saRevs[i] = [sa reverseComplementArray];
  }
  currentSuffix = -1;
  currentArray = nil;
  
  return self;
}

- (void)dealloc
{
  if (suffixPositions) free(suffixPositions);
  if (suffixSequences) free(suffixSequences);
  if (saSeqs) free(saSeqs);
  if (saRevs) free(saRevs);
  if (arrayFiles) {
    int i;
    for (i = 0; i < [suffixArrays count]; ++i) fclose(arrayFiles[i]);
    free(arrayFiles);
  }
  [suffixArrays release];
  
  [super dealloc];
}

- (BOOL)nextSuffixPosition:(int *)aPos sequence:(int *)aSeq suffixArray:(int *)anArray
{
  int i;

  // if haven't started yet or at the end
  // setup files and read in first suffixes
  if (currentSuffix < 0) {
    for (i = 0; i < [suffixArrays count]; ++i) {
      if (arrayFiles[i]) {
        rewind(arrayFiles[i]);
      } else {
        BCSuffixArray *sa = [suffixArrays objectAtIndex: i];
        arrayFiles[i] = [sa getFILE];
      }
    }

    // read in first suffix for each suffix array
    for (i = 0; i < [suffixArrays count]; ++i) {
      fread(&(suffixPositions[i]), sizeof(int), 1, arrayFiles[i]);
      fread(&(suffixSequences[i]), sizeof(int), 1, arrayFiles[i]);
    }
  }

  // determine EOF conditions
  int cnt = [suffixArrays count];
  BOOL allEOF = YES;
  for (i = 0; i < cnt; ++i) {
    if (feof(arrayFiles[i])) {
      eofFlags[i] = YES;
    } else {
      eofFlags[i] = NO;
    }
    allEOF &= eofFlags[i];
  }
  
  // all EOF then done
  if (allEOF) {
    currentSuffix = -1;
    return NO;
  }

  // get sequence data for each suffix array
  BCSequence *seqs[cnt];
  int seqPos[cnt];
  int seqLen[cnt];
  for (i = 0; i < cnt; ++i) {
    seqs[i] = [saSeqs[i] sequenceAtIndex: suffixSequences[i]];
    seqLen[i] = [seqs[i] length];
    if (suffixPositions[i] < seqLen[i]) {
      // forward strand
      seqPos[i] = suffixPositions[i];
    } else {
      // reverse strand
      seqPos[i] = suffixPositions[i] - seqLen[i] - 1;
      seqs[i] = [saRevs[i] sequenceAtIndex: suffixSequences[i]];
    }
  }

  // get initial
  for (i = 0; i < cnt; ++i) {
    if (!eofFlags[i]) {
      currentSuffix = i;
      break;
    }
  }

  // union of the suffixes to determine which is lexigraphically first
  for (i = currentSuffix + 1; i < cnt; ++i) {

    if (eofFlags[i]) continue;

    const char *currentData = [[seqs[currentSuffix] sequenceData] bytes];
    const char *checkData = [[seqs[i] sequenceData] bytes];
    int currentPos = 0;
    int offsetToWrite = 0;
    BOOL done = NO;
    while (!done) {

      // check EOF conditions
      if ((seqPos[currentSuffix] + currentPos) >= seqLen[currentSuffix]) {
        if ((seqPos[i] + currentPos) >= seqLen[i]) {
          // both at EOF, so strings must be identical
          done = YES;
          offsetToWrite = 3;
          continue;
        }

        // EOF for first sequence, it is lower
        done = YES;
        offsetToWrite = 1;
        continue;
      }
      if ((seqPos[i] + currentPos) >= seqLen[i]) {
        // EOF for second sequence, it is lower
        done = YES;
        offsetToWrite = 2;
        continue;
      }

      char c1 = currentData[seqPos[currentSuffix] + currentPos];
      char c2 = checkData[seqPos[i] + currentPos];
      ++currentPos;
      
      // stop at invalid characters
      if ((c1 != 'A') && (c1 != 'C') && (c1 != 'G') && (c1 != 'T')) {
        done = YES;
        offsetToWrite = 1;
        continue;
      }
      if ((c2 != 'A') && (c2 != 'C') && (c2 != 'G') && (c2 != 'T')) {
        done = YES;
        offsetToWrite = 2;
        continue;
      }

      if (c1 == c2) continue;
      if (c1 > c2) {
        done = YES;
        offsetToWrite = 2;
      } else {
        done = YES;
        offsetToWrite = 1;
      }
    }

    switch(offsetToWrite) {
      case 1:
        // current is lower so keep it
        break;
      case 2:
        // other sequence is lower
        currentSuffix = i;
        break;
      case 3:
        // identical so keep the current
        break;
      default:
        printf("ERROR: invalid result %d\n", offsetToWrite);
        return NO;
    }
  }

  // provide return values
  if (aPos) *aPos = suffixPositions[currentSuffix];
  if (aSeq) *aSeq = suffixSequences[currentSuffix];
  if (anArray) *anArray = currentSuffix;

  // move forward for the current suffix
  fread(&(suffixPositions[currentSuffix]), sizeof(int), 1, arrayFiles[currentSuffix]);
  fread(&(suffixSequences[currentSuffix]), sizeof(int), 1, arrayFiles[currentSuffix]);
  
  return YES;
}

- (NSArray *)suffixArrays { return suffixArrays; }

@end
