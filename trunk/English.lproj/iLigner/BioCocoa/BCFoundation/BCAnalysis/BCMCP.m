//
//  BCMCP.m
//  BioCocoa
//
//  Created by Scott Christley on 7/24/07.
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

#import "BCMCP.h"
#import "BCSuffixArray.h"
#import "BCSequence.h"
#import "BCSequenceArray.h"
#import "BCSequenceReader.h"
#import "BCCachedSequenceFile.h"
#import "BCSymbolSet.h"

#define SEQ_IN_MEM 1

// helper class
@interface MCPNode : NSObject
{
  @public
  int maxCnt;
  int numFiles;
  int *file;
  NSRange *sequence;
}

- initWithLength: (int)num;
- (NSComparisonResult)lengthCompare:(MCPNode *)anObject;
@end

static void insert_range(NSMutableArray *a, MCPNode *aNode, NSDictionary *metaDict);

@implementation BCMCP

+ (BOOL)mcpToFile:(NSString *)aPath suffixArray:(BCSuffixArray *)oneArray
  withSuffixArray:(BCSuffixArray *)otherArray lowerBound:(int)lowerBound
{
  BOOL isNucleotide = YES;
  int i;
  
  FILE *sa1 = [oneArray getFILE];
  BCSequenceArray *sa1Seqs = [oneArray sequenceArray];
  BCSequenceArray *sa1Revs = [oneArray reverseComplementArray];
  int sa1Cnt = [sa1Seqs count];
  unsigned char *seqMem1[sa1Cnt];
  unsigned char *revMem1[sa1Cnt];
  int seqLen1[sa1Cnt];
  unsigned char *seqMemPos1[sa1Cnt];
  
  FILE *sa2 = [otherArray getFILE];
  BCSequenceArray *sa2Seqs = [otherArray sequenceArray];
  BCSequenceArray *sa2Revs = [otherArray reverseComplementArray];
  int sa2Cnt = [sa2Seqs count];
  unsigned char *seqMem2[sa2Cnt];
  unsigned char *revMem2[sa2Cnt];
  int seqLen2[sa2Cnt];
  unsigned char *seqMemPos2[sa2Cnt];
  
  NSMutableArray *seqFiles = [NSMutableArray array];
  NSMutableDictionary *seq1Dict = [NSMutableDictionary dictionaryWithDictionary: [oneArray metaDictionary]];
  NSMutableDictionary *seq2Dict = [NSMutableDictionary dictionaryWithDictionary: [otherArray metaDictionary]];
  [seqFiles addObject: seq1Dict];
  [seqFiles addObject: seq2Dict];
  
  for (i = 0; i < sa1Cnt; ++i) {
    BCSequence *aSeq = [sa1Seqs sequenceAtIndex: i];
    BCSequence *revSeq = [sa1Revs sequenceAtIndex: i];
    seqMem1[i] = (unsigned char *)[[aSeq sequenceData] bytes];
    revMem1[i] = (unsigned char *)[[revSeq sequenceData] bytes];
    seqLen1[i] = [aSeq length];
    //seqMemPos1[i] = seqMem1[i];
  }
  
#if 0
  // Eliminate duplicate file names
  int mapSeqs[sa2Cnt];
  int totCnt = sa1Cnt;
  for (i = 0; i < sa2Cnt; ++i) {
    NSString *s = [sa2Seqs objectAtIndex: i];
    unsigned idx = [sa1Seqs indexOfObject: s];
    if (idx == NSNotFound) {
      mapSeqs[i] = totCnt;
      ++totCnt;
    } else mapSeqs[i] = idx;
  }
#else
  int mapSeqs[sa2Cnt];
  int totCnt = sa1Cnt;
  NSArray *a = [seq2Dict objectForKey: @"sequences"];
  for (i = 0; i < sa2Cnt; ++i) {
    NSMutableDictionary *d = [a objectAtIndex: i];
    [d setObject: [NSNumber numberWithInt: totCnt] forKey: @"number"];
    mapSeqs[i] = totCnt;
    ++totCnt;
  }
#endif
  printf("%d total unique sequence files.\n", totCnt);
  
  for (i = 0; i < sa2Cnt; ++i) {
    BCSequence *aSeq = [sa2Seqs sequenceAtIndex: i];
    BCSequence *revSeq = [sa2Revs sequenceAtIndex: i];
    seqMem2[i] = (unsigned char *)[[aSeq sequenceData] bytes];
    revMem2[i] = (unsigned char *)[[revSeq sequenceData] bytes];
    seqLen2[i] = [aSeq length];
    //seqMemPos2[i] = seqMem2[i];
  }
  
  // open output mcp file
  NSString *aString = [aPath stringByAppendingPathExtension: @"mcp"];
  FILE *sa3 = fopen([aString UTF8String], "w");
  if (!sa3) {
    NSLog(@"Could not open output file: %@\n", aString);
    return NO;
  }
  
  // meta mcp file
  NSString *metaFile = [aPath stringByAppendingPathExtension: @"meta_mcp"];
  NSMutableDictionary *mDict = [NSMutableDictionary dictionary];
  [mDict setObject: aString forKey: @"mcp file"];
  [mDict setObject: seqFiles forKey: @"sequence files"];
  [mDict setObject: [NSNumber numberWithInt: lowerBound] forKey: @"lower bound"];
  [mDict writeToFile: metaFile atomically: YES];
  
#if 0
  fprintf(sa3, "%d\n", totCnt);
  for (i = 0; i < sa1Cnt; ++i)
    fprintf(sa3, "%s\n", [[sa1Seqs objectAtIndex: i] UTF8String]);
  for (i = 0; i < sa2Cnt; ++i) {
    if (mapSeqs[i] >= sa1Cnt)
      fprintf(sa3, "%s\n", [[sa2Seqs objectAtIndex: i] UTF8String]);
  }
#endif
  
  // find the maximum common prefix
  int sa1Offset, sa1File;
  fread(&sa1Offset, sizeof(int), 1, sa1);
  fread(&sa1File, sizeof(int), 1, sa1);
  int sa2Offset, sa2File;
  fread(&sa2Offset, sizeof(int), 1, sa2);
  fread(&sa2File, sizeof(int), 1, sa2);
  fpos_t sa2Pos;
  fgetpos(sa2, &sa2Pos);
  do {
    BOOL finish = NO;
    BOOL eofFlag = NO;
    BOOL firstMatch = YES;
    while (!finish) {
      
      //printf("offset: %d file: %s\n", sa1Offset,
      //   [[sa1Seqs objectAtIndex: sa1File] UTF8String]);
      //printf("offset: %d file: %s\n", sa2Offset,
      //   [[sa2Seqs objectAtIndex: sa2File] UTF8String]);
      
      BOOL done = NO;
      int nextMax = 0;
      
#if SEQ_IN_MEM
      if (sa1Offset < seqLen1[sa1File]) {
        // forward strand
        seqMemPos1[sa1File] = seqMem1[sa1File] + sa1Offset;
      } else {
        // reverse strand
        seqMemPos1[sa1File] = revMem1[sa1File] + sa1Offset - seqLen1[sa1File];
      }
      if (sa2Offset < seqLen2[sa2File]) {
        // forward strand
        seqMemPos2[sa2File] = seqMem2[sa2File] + sa2Offset;
      } else {
        // reverse strand
        seqMemPos2[sa2File] = revMem2[sa2File] + sa2Offset - seqLen2[sa2File];
      }
#else
      fseek(seq1[sa1File], sa1Offset, SEEK_SET);
      fseek(seq2[sa2File], sa2Offset, SEEK_SET);
#endif
      
      // get common prefix for two sequences
      int sa1Len = 0, sa2Len = 0;
      BOOL is2Greater = NO;
      BOOL eof2Flag = NO;
      while (!done) {
        char c1, c2;
        
#if SEQ_IN_MEM
        // check end-of-sequence conditions
        if (sa1Offset < seqLen1[sa1File]) {
          // forward strand
          if ((sa1Offset + sa1Len) >= seqLen1[sa1File]) {
            done = YES;
            eofFlag = YES;
          }
        } else {
          // reverse strand
          if ((sa1Offset + sa1Len) >= (2*seqLen1[sa1File])) {
            done = YES;
            eofFlag = YES;
          }
        }
        
        // check end-of-sequence conditions
        if (sa2Offset < seqLen2[sa2File]) {
          // forward strand
          if ((sa2Offset + sa2Len) >= seqLen2[sa2File]) {
            done = YES;
            eof2Flag = YES;
          }
        } else {
          // reverse strand
          if ((sa2Offset + sa2Len) >= (2*seqLen2[sa2File])) {
            done = YES;
            eof2Flag = YES;
          }
        }
        if (done) continue;
        
        c1 = *(seqMemPos1[sa1File] + sa1Len);
        ++sa1Len;
        c2 = *(seqMemPos2[sa2File] + sa2Len);
        ++sa2Len;
        
#else
        fread(&c1, sizeof(char), 1, seq1[sa1File]);
        fread(&c2, sizeof(char), 1, seq2[sa2File]);
        
        // check EOF conditions
        if (feof(seq1[sa1File])) {
          // EOF for first sequence
          done = YES;
          eofFlag = YES;
          continue;
        }
        if (feof(seq2[sa2File])) {
          // EOF for second sequence
          done = YES;
          eof2Flag = YES;
          continue;
        }
#endif
        
        // if comparing the same sequence against itself
        // skip the obvious self match at the same positions
        if ((sa1File == mapSeqs[sa2File]) && (sa1Offset == sa2Offset)) {
          done = YES;
          continue;
        }
        
        //printf("c1: %c c2: %c\n", c1, c2);
        
        // do not look beyond valid letters
        if (isNucleotide) {
          if ((c1 != 'A') && (c1 != 'C') && (c1 != 'G') && (c1 != 'T')) {
            done = YES;
            eofFlag = YES;
          }
          if ((c2 != 'A') && (c2 != 'C') && (c2 != 'G') && (c2 != 'T')) {
            done = YES;
            eof2Flag = YES;
          }
        } else {
          if (c1 == BCSUFFIXARRAY_TERM_CHAR) {
            done = YES;
            eofFlag = YES;
          }
          if (c2 == BCSUFFIXARRAY_TERM_CHAR) {
            done = YES;
            eof2Flag = YES;
          }
        }
        if (done) continue;
        
        if (c1 == c2) {
          ++nextMax;
          continue;
        } else {
          if (c2 > c1) is2Greater = YES;
          done = YES;
        }
      }
      
      // if end of suffix array 2, nothing more to check
      // so move suffix array 1 forward
      if (feof(sa2)) {
        eofFlag = YES;
        nextMax = 0;
      }
      
      if (nextMax >= lowerBound) {
        //printf("write mcp: %d sa1: %d sa2: %d\n", nextMax, sa1Offset, sa2Offset);
        
        // write out mcp
        int numFiles = 2;
        fwrite(&nextMax, sizeof(int), 1, sa3);
        fwrite(&numFiles, sizeof(int), 1, sa3);
        fwrite(&sa1Offset, sizeof(int), 1, sa3);
        fwrite(&sa1File, sizeof(int), 1, sa3);
        fwrite(&sa2Offset, sizeof(int), 1, sa3);
        int currentFile = mapSeqs[sa2File];
        fwrite(&currentFile, sizeof(int), 1, sa3);
        
        if (firstMatch) {
          fgetpos(sa2, &sa2Pos);
          firstMatch = NO;
        }
        
        // next sequence
        fread(&sa2Offset, sizeof(int), 1, sa2);
        fread(&sa2File, sizeof(int), 1, sa2);
      } else {
        // no match so move forward
        
        // determine which to move forward
        // EOS1 and EOS2 -> sa1
        // EOS1 and too short -> sa1
        // too short and EOS2 -> sa2
        // too short and too short -> if is2Greater then sa1 else sa2
        BOOL sa1Move = NO;
        if (eofFlag) sa1Move = YES;
        else if ((!eof2Flag) && (is2Greater)) sa1Move = YES;
        
        if (sa1Move) {
          //printf("too short: %d moving sa1: %d\n", nextMax, sa1Offset);
          
          // next sequence
          fread(&sa1Offset, sizeof(int), 1, sa1);
          fread(&sa1File, sizeof(int), 1, sa1);
          
          // backtrack
          fsetpos(sa2, &sa2Pos);
          fseek(sa2, -2 * sizeof(int), SEEK_CUR);
          fread(&sa2Offset, sizeof(int), 1, sa2);
          fread(&sa2File, sizeof(int), 1, sa2);
          
          finish = YES;
        } else {
          //printf("too short: %d moving sa2: %d\n", nextMax, sa2Offset);
          
          // next sequence
          fread(&sa2Offset, sizeof(int), 1, sa2);
          fread(&sa2File, sizeof(int), 1, sa2);
          
          // move forward in suffix array 2
          // so long as lexically less
          if ((firstMatch) && (!is2Greater)) {
            fgetpos(sa2, &sa2Pos);
          }
        }
      }
      
    }
  } while (!feof(sa1));
  
  fclose(sa1);
  fclose(sa2);
  fclose(sa3);
  
  return YES;
}

- (BOOL)intersectToFile:(NSString *)aPath withMCP:(BCMCP *)anMCP
{
  BOOL isNucleotide = YES;
  int i, j;
  int mallocLength1 = 10000, mallocLength2 = 10000;
  char *seqBuffer1 = (char *)malloc(mallocLength1);
  char *seqBuffer2 = (char *)malloc(mallocLength2);
  
  FILE *mcp1 = [self getFILE];
  NSArray *seqFiles1 = [metaDict objectForKey: @"sequence files"];
  int lb1 = [[metaDict objectForKey: @"lower bound"] intValue];
  int mcp1Cnt = [[[[[seqFiles1 lastObject] objectForKey: @"sequences"] lastObject] objectForKey: @"number"] intValue] + 1;
  
  FILE *mcp2 = [anMCP getFILE];
  NSDictionary *metaDict2 = [anMCP metaDictionary];
  int lb2 = [[metaDict2 objectForKey: @"lower bound"] intValue];
  NSArray *sequenceToMeta2 = [anMCP sequenceToMeta];
  NSArray *cachedFiles2 = [anMCP cachedFiles];
  NSArray *seqFiles2 = [metaDict2 objectForKey: @"sequence files"];
  int mcp2Cnt = [[[[[seqFiles2 lastObject] objectForKey: @"sequences"] lastObject] objectForKey: @"number"] intValue] + 1;
  
  // have to take larger for lower bound
  int lowerBound;
  if (lb1 > lb2) lowerBound = lb1;
  else lowerBound = lb2;
  
  // Eliminate duplicate sequence files
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSMutableArray *seqFiles3 = [NSMutableArray arrayWithArray: seqFiles1];
  int mapSeqs[mcp2Cnt];
  int mapCnt = 0;
  int totCnt = mcp1Cnt;
  for (i = 0; i < [seqFiles2 count]; ++i) {
    NSDictionary *d1 = [seqFiles2 objectAtIndex: i];
    NSString *s1 = [d1 objectForKey: @"sequences file"];
    NSDictionary *fileAttr = [fileManager fileAttributesAtPath: s1 traverseLink: YES];
    NSNumber *fn1 = [fileAttr objectForKey: NSFileSystemFileNumber];
    BOOL found = NO;
    int foundMap = 0;
    for (j = 0; j < [seqFiles1 count]; ++j) {
      NSDictionary *d2 = [seqFiles3 objectAtIndex: j];
      NSString *s2 = [d2 objectForKey: @"sequences file"];
      fileAttr = [fileManager fileAttributesAtPath: s2 traverseLink: YES];
      NSNumber *fn2 = [fileAttr objectForKey: NSFileSystemFileNumber];
      if ([fn1 isEqualToNumber: fn2]) {
        found = YES;
        foundMap = j;
        break;
      }
    }
    
    if (!found) {
      NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary: d1];
      NSArray *oldArray = [newDict objectForKey: @"sequences"];
      NSMutableArray *newArray = [NSMutableArray array];
      for (j = 0; j < [oldArray count]; ++j) {
        mapSeqs[mapCnt] = totCnt;
        NSMutableDictionary *seqDict = [NSMutableDictionary dictionaryWithDictionary: [oldArray objectAtIndex: j]];
        [seqDict setObject: [NSNumber numberWithInt: totCnt] forKey: @"number"];
        [newArray addObject: seqDict];
        ++mapCnt;
        ++totCnt;
      }
      [newDict setObject: newArray forKey: @"sequences"];
      [seqFiles3 addObject: newDict];
    } else {
      NSDictionary *d2 = [seqFiles3 objectAtIndex: foundMap];
      NSArray *oldArray = [d2 objectForKey: @"sequences"];
      for (j = 0; j < [oldArray count]; ++j) {
        mapSeqs[mapCnt] = foundMap + j;
        ++mapCnt;
      }
    }
  }
  printf("%d total unique sequence files.\n", totCnt);
  
  // open output mcp file
  NSString *aString = [aPath stringByAppendingPathExtension: @"mcp"];
  FILE *mcp3 = fopen([aString UTF8String], "w");
  if (!mcp3) {
    NSLog(@"Could not open file: %@\n", aString);
    fclose(mcp1);
    fclose(mcp2);
    free(seqBuffer1);
    free(seqBuffer2);
    return NO;
  }
  
  // meta mcp file
  NSString *metaFile = [aPath stringByAppendingPathExtension: @"meta_mcp"];
  NSMutableDictionary *metaDict3 = [NSMutableDictionary dictionary];
  [metaDict3 setObject: aString forKey: @"mcp file"];
  [metaDict3 setObject: seqFiles3 forKey: @"sequence files"];
  [metaDict3 setObject: [NSNumber numberWithInt: lowerBound] forKey: @"lower bound"];
  [metaDict3 writeToFile: metaFile atomically: YES];
  
  // intersect the maximum common prefix
  int mcp1Length, mcp1NumFiles;
  int mcp1File[totCnt], mcp1Offset[totCnt];
  fread(&mcp1Length, sizeof(int), 1, mcp1);
  fread(&mcp1NumFiles, sizeof(int), 1, mcp1);
  for (i = 0; i < mcp1NumFiles; ++i) {
    fread(&(mcp1Offset[i]), sizeof(int), 1, mcp1);
    fread(&(mcp1File[i]), sizeof(int), 1, mcp1);
  }
  int mcp1Index, seq1Start, mcp1SeqIndex, seq1Len;
  BCCachedSequenceFile *cacheFile1;
  NSArray *mcp1Seqs;
  if (!feof(mcp1)) {
    mcp1Index = [[sequenceToMeta objectAtIndex: mcp1File[0]] intValue];
    cacheFile1 = [cachedFiles objectAtIndex: mcp1Index];
    mcp1Seqs = [[seqFiles1 objectAtIndex: mcp1Index] objectForKey: @"sequences"];
    seq1Start = [[[mcp1Seqs objectAtIndex: 0] objectForKey: @"number"] intValue];
    mcp1SeqIndex = mcp1File[0] - seq1Start;
    seq1Len = [[[mcp1Seqs objectAtIndex: mcp1SeqIndex] objectForKey: @"length"] intValue];
    if (mcp1Length > mallocLength1) {
      mallocLength1 = mcp1Length;
      free(seqBuffer1);
      seqBuffer1 = malloc(mallocLength1);
    }
    [cacheFile1 symbols: seqBuffer1 atPosition: mcp1Offset[0] ofLength: mcp1Length forSequenceNumber: mcp1SeqIndex];
  }
  
  int mcp2Length, mcp2NumFiles;
  int mcp2File[totCnt], mcp2Offset[totCnt];
  fpos_t mcp2Pos;
  fgetpos(mcp2, &mcp2Pos);
  fread(&mcp2Length, sizeof(int), 1, mcp2);
  fread(&mcp2NumFiles, sizeof(int), 1, mcp2);
  for (i = 0; i < mcp2NumFiles; ++i) {
    fread(&(mcp2Offset[i]), sizeof(int), 1, mcp2);
    fread(&(mcp2File[i]), sizeof(int), 1, mcp2);
  }
  int mcp2Index, seq2Start, mcp2SeqIndex, seq2Len;
  BCCachedSequenceFile *cacheFile2;
  NSArray *mcp2Seqs;
  if (!feof(mcp2)) {
    mcp2Index = [[sequenceToMeta2 objectAtIndex: mcp2File[0]] intValue];
    cacheFile2 = [cachedFiles2 objectAtIndex: mcp2Index];
    mcp2Seqs = [[seqFiles2 objectAtIndex: mcp2Index] objectForKey: @"sequences"];
    seq2Start = [[[mcp2Seqs objectAtIndex: 0] objectForKey: @"number"] intValue];
    mcp2SeqIndex = mcp2File[0] - seq2Start;
    seq2Len = [[[mcp2Seqs objectAtIndex: mcp2SeqIndex] objectForKey: @"length"] intValue];
    if (mcp2Length > mallocLength2) {
      mallocLength2 = mcp2Length;
      free(seqBuffer2);
      seqBuffer2 = malloc(mallocLength2);
    }
    [cacheFile2 symbols: seqBuffer2 atPosition: mcp2Offset[0] ofLength: mcp2Length forSequenceNumber: mcp2SeqIndex];
  }
  
  while (!feof(mcp1)) {
    if (feof(mcp2)) break;
    
    BOOL finish = NO;
    BOOL eofFlag = NO;
    BOOL firstMatch = YES;
    int currentMax = 0, currentMaxCount = 0;
    fpos_t currentMaxPos = mcp2Pos;
    while (!finish) {
      
      //printf("offset: %d file: %s\n", mcp1Offset[0],
      //     [[mcp1Seqs objectAtIndex: mcp1File[0]] UTF8String]);
      //printf("offset: %d file: %s\n", mcp2Offset[0],
      //     [[mcp2Seqs objectAtIndex: mcp2File[0]] UTF8String]);
      
      BOOL done = NO;
      int nextMax = 0;
      
#if 0
      fseek(seq1[mcp1File[0]], mcp1Offset[0], SEEK_SET);
      fseek(seq2[mcp2File[0]], mcp2Offset[0], SEEK_SET);
#endif
      
      // get common prefix for two sequences
      int mcp1Len = 0, mcp2Len = 0;
      BOOL is2Greater = NO;
      BOOL eof2Flag = NO;
      while (!done) {
        
        // check end-of-sequence conditions
        if (mcp1Offset[0] < seq1Len) {
          // forward strand
          if ((mcp1Offset[0] + mcp1Len) >= seq1Len) {
            done = YES;
            eofFlag = YES;
          }
        } else {
          // reverse strand
          if ((mcp1Offset[0] + mcp1Len) >= (2*seq1Len)) {
            done = YES;
            eofFlag = YES;
          }
        }
        
        // check end-of-sequence conditions
        if (mcp2Offset[0] < seq2Len) {
          // forward strand
          if ((mcp2Offset[0] + mcp2Len) >= seq2Len) {
            done = YES;
            eof2Flag = YES;
          }
        } else {
          // reverse strand
          if ((mcp2Offset[0] + mcp2Len) >= (2*seq2Len)) {
            done = YES;
            eof2Flag = YES;
          }
        }
        
        // cannot go past the length of the mcp
        if (nextMax == mcp1Length) {
          // end of first sequence
          done = YES;
          eofFlag = YES;
        }
        if (nextMax == mcp2Length) {
          // end of second sequence
          done = YES;
          eof2Flag = YES;
        }
        if (done) continue;
        
        char c1, c2;
        //c1 = [cacheFile1 symbolAtPosition: (mcp1Offset[0] + mcp1Len) forSequenceNumber: mcp1SeqIndex];
        c1 = seqBuffer1[mcp1Len];
        ++mcp1Len;
        //c2 = [cacheFile2 symbolAtPosition: (mcp2Offset[0] + mcp2Len) forSequenceNumber: mcp2SeqIndex];
        c2 = seqBuffer2[mcp2Len];
        ++mcp2Len;
        
        //printf("c1: %c c2: %c\n", c1, c2);
        
        // do not look beyond valid letters
        if (isNucleotide) {
          if ((c1 != 'A') && (c1 != 'C') && (c1 != 'G') && (c1 != 'T')) {
            done = YES;
            eofFlag = YES;
          }
          if ((c2 != 'A') && (c2 != 'C') && (c2 != 'G') && (c2 != 'T')) {
            done = YES;
            eof2Flag = YES;
          }
        } else {
          if (c1 == BCSUFFIXARRAY_TERM_CHAR) {
            done = YES;
            eofFlag = YES;
          }
          if (c2 == BCSUFFIXARRAY_TERM_CHAR) {
            done = YES;
            eof2Flag = YES;
          }
        }
        if (done) continue;
        
        if (c1 == c2) {
          ++nextMax;
          continue;
        } else {
          if (c2 > c1) is2Greater = YES;
          done = YES;
        }
      }
      
      // if end of mcp 2, nothing more to check
      // so move mcp 1 forward
      if (feof(mcp2)) {
        eofFlag = YES;
        nextMax = 0;
        //printf("EOF for mcp2\n");
      }
      
      BOOL read1Flag = NO;
      BOOL read2Flag = NO;
      BOOL getNewPos = NO;
      
      if (nextMax >= lowerBound) {
        //printf("write mcp: %d mcp1: (%d, %d) mcp2: (%d, %d)\n", nextMax, mcp1Offset[0], mcp1Offset[1], mcp2Offset[0], mcp2Offset[1]);
        
        // determine unique sequence references
        int fileCnt = mcp1NumFiles;
        for (j = 0; j < mcp2NumFiles; ++j)
          if (mapSeqs[mcp2File[j]] >= mcp1Cnt) ++fileCnt;
        
        // write mcp
        fwrite(&nextMax, sizeof(int), 1, mcp3);
        fwrite(&fileCnt, sizeof(int), 1, mcp3);
        for (j = 0; j < mcp1NumFiles; ++j) {
          fwrite(&mcp1Offset[j], sizeof(int), 1, mcp3);
          fwrite(&mcp1File[j], sizeof(int), 1, mcp3);
        }
        for (j = 0; j < mcp2NumFiles; ++j) {
          if (mapSeqs[mcp2File[j]] >= mcp1Cnt) {
            int fileNum = mapSeqs[mcp2File[j]];
            fwrite(&mcp2Offset[j], sizeof(int), 1, mcp3);
            fwrite(&fileNum, sizeof(int), 1, mcp3);
          }
        }
        
        if (firstMatch) {
          //fgetpos(mcp2, &mcp2Pos);
          firstMatch = NO;
        }
        
        // next sequence
        read2Flag = YES;
        
      } else {
        // no match so move forward
        
        // determine which to move forward
        // EOS1 and EOS2 -> mcp1
        // EOS1 and too short -> mcp1
        // too short and EOS2 -> mcp2
        // too short and too short -> if is2Greater then mcp1 else mcp2
        BOOL mcp1Move = NO;
        if (eofFlag) mcp1Move = YES;
        else if ((!eof2Flag) && (is2Greater)) mcp1Move = YES;
        
        if (mcp1Move) {
          //printf("too short: %d moving mcp1: %d\n", nextMax, mcp1Offset[0]);
          
          // next sequence
          read1Flag = YES;
          
          // backtrack
          fsetpos(mcp2, &mcp2Pos);
          read2Flag = YES;
          
          finish = YES;
        } else {
          //printf("too short: %d moving mcp2: %d\n", nextMax, mcp2Offset[0]);
          
          // next sequence
          read2Flag = YES;
          
          // move forward in mcp 2
          // so long as lexically less
          if ((firstMatch) && (!is2Greater)) {
            getNewPos = YES;
          }
        }
      }
      
      // next sequence
      if (read1Flag) {
        fread(&mcp1Length, sizeof(int), 1, mcp1);
        fread(&mcp1NumFiles, sizeof(int), 1, mcp1);
        for (i = 0; i < mcp1NumFiles; ++i) {
          fread(&(mcp1Offset[i]), sizeof(int), 1, mcp1);
          fread(&(mcp1File[i]), sizeof(int), 1, mcp1);
        }
        mcp1Index = [[sequenceToMeta objectAtIndex: mcp1File[0]] intValue];
        cacheFile1 = [cachedFiles objectAtIndex: mcp1Index];
        mcp1Seqs = [[seqFiles1 objectAtIndex: mcp1Index] objectForKey: @"sequences"];
        seq1Start = [[[mcp1Seqs objectAtIndex: 0] objectForKey: @"number"] intValue];
        mcp1SeqIndex = mcp1File[0] - seq1Start;
        seq1Len = [[[mcp1Seqs objectAtIndex: mcp1SeqIndex] objectForKey: @"length"] intValue];
        if (mcp1Length > mallocLength1) {
          mallocLength1 = mcp1Length;
          free(seqBuffer1);
          seqBuffer1 = malloc(mallocLength1);
        }
        [cacheFile1 symbols: seqBuffer1 atPosition: mcp1Offset[0] ofLength: mcp1Length forSequenceNumber: mcp1SeqIndex];
      }
      
      // move position forward
      if (getNewPos) {
        fgetpos(mcp2, &mcp2Pos);
      }
      
      // next sequence
      if (read2Flag) {
        fread(&mcp2Length, sizeof(int), 1, mcp2);
        fread(&mcp2NumFiles, sizeof(int), 1, mcp2);
        for (i = 0; i < mcp2NumFiles; ++i) {
          fread(&(mcp2Offset[i]), sizeof(int), 1, mcp2);
          fread(&(mcp2File[i]), sizeof(int), 1, mcp2);
        }
        mcp2Index = [[sequenceToMeta2 objectAtIndex: mcp2File[0]] intValue];
        cacheFile2 = [cachedFiles2 objectAtIndex: mcp2Index];
        mcp2Seqs = [[seqFiles2 objectAtIndex: mcp2Index] objectForKey: @"sequences"];
        seq2Start = [[[mcp2Seqs objectAtIndex: 0] objectForKey: @"number"] intValue];
        mcp2SeqIndex = mcp2File[0] - seq2Start;
        seq2Len = [[[mcp2Seqs objectAtIndex: mcp2SeqIndex] objectForKey: @"length"] intValue];
        if (mcp2Length > mallocLength2) {
          mallocLength2 = mcp2Length;
          free(seqBuffer2);
          seqBuffer2 = malloc(mallocLength2);
        }
        [cacheFile2 symbols: seqBuffer2 atPosition: mcp2Offset[0] ofLength: mcp2Length forSequenceNumber: mcp2SeqIndex];
      }
      
    }
  }
  
  fclose(mcp1);
  fclose(mcp2);
  fclose(mcp3);
  free(seqBuffer1);
  free(seqBuffer2);
  
  return YES;
}

- (BOOL)unionToFile:(NSString *)aPath withMCP:(BCMCP *)anMCP
{
  int i, j;
  int mallocLength1 = 10000, mallocLength2 = 10000;
  char *seqBuffer1 = (char *)malloc(mallocLength1);
  char *seqBuffer2 = (char *)malloc(mallocLength2);
  
  FILE *mcp1 = [self getFILE];
  NSArray *seqFiles1 = [metaDict objectForKey: @"sequence files"];
  int lb1 = [[metaDict objectForKey: @"lower bound"] intValue];
  int mcp1Cnt = [[[[[seqFiles1 lastObject] objectForKey: @"sequences"] lastObject] objectForKey: @"number"] intValue] + 1;
  
  FILE *mcp2 = [anMCP getFILE];
  NSDictionary *metaDict2 = [anMCP metaDictionary];
  int lb2 = [[metaDict2 objectForKey: @"lower bound"] intValue];
  NSArray *sequenceToMeta2 = [anMCP sequenceToMeta];
  NSArray *cachedFiles2 = [anMCP cachedFiles];
  NSArray *seqFiles2 = [metaDict2 objectForKey: @"sequence files"];
  int mcp2Cnt = [[[[[seqFiles2 lastObject] objectForKey: @"sequences"] lastObject] objectForKey: @"number"] intValue] + 1;
  
  // have to take larger for lower bound
  int lowerBound;
  if (lb1 > lb2) lowerBound = lb1;
  else lowerBound = lb2;
  
  // Eliminate duplicate sequence files
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSMutableArray *seqFiles3 = [NSMutableArray arrayWithArray: seqFiles1];
  int mapSeqs[mcp2Cnt];
  int mapCnt = 0;
  int totCnt = mcp1Cnt;
  for (i = 0; i < [seqFiles2 count]; ++i) {
    NSDictionary *d1 = [seqFiles2 objectAtIndex: i];
    NSString *s1 = [d1 objectForKey: @"sequences file"];
    NSDictionary *fileAttr = [fileManager fileAttributesAtPath: s1 traverseLink: YES];
    NSNumber *fn1 = [fileAttr objectForKey: NSFileSystemFileNumber];
    BOOL found = NO;
    int foundMap = 0;
    for (j = 0; j < [seqFiles1 count]; ++j) {
      NSDictionary *d2 = [seqFiles3 objectAtIndex: j];
      NSString *s2 = [d2 objectForKey: @"sequences file"];
      fileAttr = [fileManager fileAttributesAtPath: s2 traverseLink: YES];
      NSNumber *fn2 = [fileAttr objectForKey: NSFileSystemFileNumber];
      if ([fn1 isEqualToNumber: fn2]) {
        found = YES;
        foundMap = j;
        //printf("%d %s\n", j, [[d2 description] UTF8String]);
        break;
      }
    }
    
    if (!found) {
      NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary: d1];
      NSArray *oldArray = [newDict objectForKey: @"sequences"];
      NSMutableArray *newArray = [NSMutableArray array];
      for (j = 0; j < [oldArray count]; ++j) {
        mapSeqs[mapCnt] = totCnt;
        NSMutableDictionary *seqDict = [NSMutableDictionary dictionaryWithDictionary: [oldArray objectAtIndex: j]];
        [seqDict setObject: [NSNumber numberWithInt: totCnt] forKey: @"number"];
        [newArray addObject: seqDict];
        //printf("not found: %d %d %d\n", j, mapCnt, totCnt);
        ++mapCnt;
        ++totCnt;
      }
      [newDict setObject: newArray forKey: @"sequences"];
      [seqFiles3 addObject: newDict];
    } else {
      NSDictionary *d2 = [seqFiles3 objectAtIndex: foundMap];
      NSArray *oldArray = [d2 objectForKey: @"sequences"];
      for (j = 0; j < [oldArray count]; ++j) {
        mapSeqs[mapCnt] = foundMap + j;
        //printf("found: %d %d %d\n", j, mapCnt, totCnt);
        ++mapCnt;
      }
    }
  }
  printf("%d total unique sequence files.\n", totCnt);
  
#if 0
  for (i = 0; i < totCnt; ++i) {
    NSDictionary *d = [seqFiles3 objectAtIndex: i];
    printf("%s\n\n", [[d description] UTF8String]);
  }
  for (i = 0; i < mcp1Cnt; ++i) {
    NSDictionary *d = [seqFiles3 objectAtIndex: i];
    printf("%s\n\n", [[d description] UTF8String]);
  }
  for (i = 0; i < mcp2Cnt; ++i) {
    NSDictionary *d = [seqFiles3 objectAtIndex: mapSeqs[i]];
    printf("%d %s\n\n", mapSeqs[i], [[d description] UTF8String]);
  }
#endif
  
  // open output mcp file
  NSString *aString = [aPath stringByAppendingPathExtension: @"mcp"];
  FILE *mcp3 = fopen([aString UTF8String], "w");
  if (!mcp3) {
    NSLog(@"Could not open file: %@\n", aString);
    fclose(mcp1);
    fclose(mcp2);
    free(seqBuffer1);
    free(seqBuffer2);
    return NO;
  }
  
  // meta mcp file
  NSString *metaFile = [aPath stringByAppendingPathExtension: @"meta_mcp"];
  NSMutableDictionary *metaDict3 = [NSMutableDictionary dictionary];
  [metaDict3 setObject: aString forKey: @"mcp file"];
  [metaDict3 setObject: seqFiles3 forKey: @"sequence files"];
  [metaDict3 setObject: [NSNumber numberWithInt: lowerBound] forKey: @"lower bound"];
  [metaDict3 writeToFile: metaFile atomically: YES];
  
  // union the mcp arrays by merging the sorted lists
  int mcp1Length, mcp1NumFiles;
  int mcp1File[totCnt], mcp1Offset[totCnt];
  fread(&mcp1Length, sizeof(int), 1, mcp1);
  fread(&mcp1NumFiles, sizeof(int), 1, mcp1);
  for (i = 0; i < mcp1NumFiles; ++i) {
    fread(&(mcp1Offset[i]), sizeof(int), 1, mcp1);
    fread(&(mcp1File[i]), sizeof(int), 1, mcp1);
  }
  int mcp1Index, seq1Start, mcp1SeqIndex, seq1Len;
  NSArray *mcp1Seqs;
  BCCachedSequenceFile *cacheFile1;
  if (!feof(mcp1)) {
    mcp1Index = [[sequenceToMeta objectAtIndex: mcp1File[0]] intValue];
    cacheFile1 = [cachedFiles objectAtIndex: mcp1Index];
    mcp1Seqs = [[seqFiles1 objectAtIndex: mcp1Index] objectForKey: @"sequences"];
    seq1Start = [[[mcp1Seqs objectAtIndex: 0] objectForKey: @"number"] intValue];
    mcp1SeqIndex = mcp1File[0] - seq1Start;
    seq1Len = [[[mcp1Seqs objectAtIndex: mcp1SeqIndex] objectForKey: @"length"] intValue];
    if (mcp1Length > mallocLength1) {
      mallocLength1 = mcp1Length;
      free(seqBuffer1);
      seqBuffer1 = malloc(mallocLength1);
    }
    [cacheFile1 symbols: seqBuffer1 atPosition: mcp1Offset[0] ofLength: mcp1Length forSequenceNumber: mcp1SeqIndex];
  }
  
  int mcp2Length, mcp2NumFiles;
  int mcp2File[totCnt], mcp2Offset[totCnt];
  fread(&mcp2Length, sizeof(int), 1, mcp2);
  fread(&mcp2NumFiles, sizeof(int), 1, mcp2);
  for (i = 0; i < mcp2NumFiles; ++i) {
    fread(&(mcp2Offset[i]), sizeof(int), 1, mcp2);
    fread(&(mcp2File[i]), sizeof(int), 1, mcp2);
  }
  int mcp2Index, seq2Start, mcp2SeqIndex, seq2Len;
  NSArray *mcp2Seqs;
  BCCachedSequenceFile *cacheFile2;
  if (!feof(mcp2)) {
    mcp2Index = [[sequenceToMeta2 objectAtIndex: mcp2File[0]] intValue];
    cacheFile2 = [cachedFiles2 objectAtIndex: mcp2Index];
    mcp2Seqs = [[seqFiles2 objectAtIndex: mcp2Index] objectForKey: @"sequences"];
    seq2Start = [[[mcp2Seqs objectAtIndex: 0] objectForKey: @"number"] intValue];
    mcp2SeqIndex = mcp2File[0] - seq2Start;
    seq2Len = [[[mcp2Seqs objectAtIndex: mcp2SeqIndex] objectForKey: @"length"] intValue];
    if (mcp2Length > mallocLength2) {
      mallocLength2 = mcp2Length;
      free(seqBuffer2);
      seqBuffer2 = malloc(mallocLength2);
    }
    [cacheFile2 symbols: seqBuffer2 atPosition: mcp2Offset[0] ofLength: mcp2Length forSequenceNumber: mcp2SeqIndex];
  }
  
  while (!feof(mcp1)) {
    if (feof(mcp2)) break;
    
    //printf("offset: %d file: %s\n", mcp1Offset,
    //   [[mcp1Seqs objectAtIndex: mcp1File] UTF8String]);
    //printf("offset: %d file: %s\n", mcp2Offset,
    //   [[mcp2Seqs objectAtIndex: mcp2File] UTF8String]);
    
    BOOL done = NO;
    int offsetToWrite = 0;
    
#if 0
    fseek(seq1[mcp1File[0]], mcp1Offset[0], SEEK_SET);
    fseek(seq2[mcp2File[0]], mcp2Offset[0], SEEK_SET);
#endif
    
    // files and offsets may be identical
    // if same sequence matches in multiple places
    // of other organism
    if ((mcp1Offset[0] == mcp2Offset[0]) && (mcp1File[0] == mapSeqs[mcp2File[0]])) {
      done = YES;
      offsetToWrite = 3;
    }
    
    int nextMax = 0;
    int mcp1Len = 0, mcp2Len = 0;
    while (!done) {
      
      // check end-of-sequence conditions
      BOOL eos1 = NO, eos2 = NO;
      
      if (mcp1Offset[0] < seq1Len) {
        // forward strand
        if ((mcp1Offset[0] + mcp1Len) >= seq1Len) {
          eos1 = YES;
        }
      } else {
        // reverse strand
        if ((mcp1Offset[0] + mcp1Len) >= (2*seq1Len)) {
          eos1 = YES;
        }
      }
      
      if (mcp2Offset[0] < seq2Len) {
        // forward strand
        if ((mcp2Offset[0] + mcp2Len) >= seq2Len) {
          eos2 = YES;
        }
      } else {
        // reverse strand
        if ((mcp2Offset[0] + mcp2Len) >= (2*seq2Len)) {
          eos2 = YES;
        }
      }
      
      if (eos1 && eos2) {
        // both at end-of-sequence, so strings must be identical
        done = YES;
        offsetToWrite = 3;
        continue;
      } else {
        if (eos1) {
          // end of first sequence, it is lower
          done = YES;
          offsetToWrite = 1;
          continue;
        }
        if (eos2) {
          // end of second sequence, it is lower
          done = YES;
          offsetToWrite = 2;
          continue;
        }
      }
      
      // cannot go past the length of the mcp
      if (nextMax == mcp1Length) {
        if (nextMax == mcp2Length) {
          // both at length, so strings must be identical
          done = YES;
          offsetToWrite = 3;
          continue;
        }
        
        // end of first sequence, it is lower
        done = YES;
        offsetToWrite = 1;
        continue;
      }
      if (nextMax == mcp2Length) {
        // end of second sequence, it is lower
        done = YES;
        offsetToWrite = 2;
        continue;
      }
      
      char c1, c2;
      //c1 = [cacheFile1 symbolAtPosition: (mcp1Offset[0] + mcp1Len) forSequenceNumber: mcp1SeqIndex];
      c1 = seqBuffer1[mcp1Len];
      ++mcp1Len;
      //c2 = [cacheFile2 symbolAtPosition: (mcp2Offset[0] + mcp2Len) forSequenceNumber: mcp2SeqIndex];
      c2 = seqBuffer2[mcp2Len];
      ++mcp2Len;
      
      //printf("c1: %c c2: %c\n", c1, c2);
      
      if (c1 == c2) {
        ++nextMax;
        continue;
      }
      if (c1 > c2) {
        done = YES;
        offsetToWrite = 2;
      } else {
        done = YES;
        offsetToWrite = 1;
      }
    }
    
    if (offsetToWrite == 1) {
      // sequence is lower, so write it out
      fwrite(&mcp1Length, sizeof(int), 1, mcp3);
      fwrite(&mcp1NumFiles, sizeof(int), 1, mcp3);
      for (i = 0; i < mcp1NumFiles; ++i) {
        fwrite(&mcp1Offset[i], sizeof(int), 1, mcp3);
        fwrite(&mcp1File[i], sizeof(int), 1, mcp3);
      }
      
      // next sequence
      fread(&mcp1Length, sizeof(int), 1, mcp1);
      fread(&mcp1NumFiles, sizeof(int), 1, mcp1);
      for (i = 0; i < mcp1NumFiles; ++i) {
        fread(&(mcp1Offset[i]), sizeof(int), 1, mcp1);
        fread(&(mcp1File[i]), sizeof(int), 1, mcp1);
      }
      mcp1Index = [[sequenceToMeta objectAtIndex: mcp1File[0]] intValue];
      cacheFile1 = [cachedFiles objectAtIndex: mcp1Index];
      mcp1Seqs = [[seqFiles1 objectAtIndex: mcp1Index] objectForKey: @"sequences"];
      seq1Start = [[[mcp1Seqs objectAtIndex: 0] objectForKey: @"number"] intValue];
      mcp1SeqIndex = mcp1File[0] - seq1Start;
      seq1Len = [[[mcp1Seqs objectAtIndex: mcp1SeqIndex] objectForKey: @"length"] intValue];
      if (mcp1Length > mallocLength1) {
        mallocLength1 = mcp1Length;
        free(seqBuffer1);
        seqBuffer1 = malloc(mallocLength1);
      }
      [cacheFile1 symbols: seqBuffer1 atPosition: mcp1Offset[0] ofLength: mcp1Length forSequenceNumber: mcp1SeqIndex];
      
    } else if (offsetToWrite == 2) {
      // sequence is lower, so write it out
      fwrite(&mcp2Length, sizeof(int), 1, mcp3);
      fwrite(&mcp2NumFiles, sizeof(int), 1, mcp3);
      for (i = 0; i < mcp2NumFiles; ++i) {
        int fileNum = mapSeqs[mcp2File[i]];
        fwrite(&mcp2Offset[i], sizeof(int), 1, mcp3);
        fwrite(&fileNum, sizeof(int), 1, mcp3);
      }
      
      // next sequence
      fread(&mcp2Length, sizeof(int), 1, mcp2);
      fread(&mcp2NumFiles, sizeof(int), 1, mcp2);
      for (i = 0; i < mcp2NumFiles; ++i) {
        fread(&(mcp2Offset[i]), sizeof(int), 1, mcp2);
        fread(&(mcp2File[i]), sizeof(int), 1, mcp2);
      }
      mcp2Index = [[sequenceToMeta2 objectAtIndex: mcp2File[0]] intValue];
      cacheFile2 = [cachedFiles2 objectAtIndex: mcp2Index];
      mcp2Seqs = [[seqFiles2 objectAtIndex: mcp2Index] objectForKey: @"sequences"];
      seq2Start = [[[mcp2Seqs objectAtIndex: 0] objectForKey: @"number"] intValue];
      mcp2SeqIndex = mcp2File[0] - seq2Start;
      seq2Len = [[[mcp2Seqs objectAtIndex: mcp2SeqIndex] objectForKey: @"length"] intValue];
      if (mcp2Length > mallocLength2) {
        mallocLength2 = mcp2Length;
        free(seqBuffer2);
        seqBuffer2 = malloc(mallocLength2);
      }
      [cacheFile2 symbols: seqBuffer2 atPosition: mcp2Offset[0] ofLength: mcp2Length forSequenceNumber: mcp2SeqIndex];
      
    } else if (offsetToWrite == 3) {
      // both sequences identical
      //printf("Identical string: (%d, %s):(%d, %s) and (%d, %s):(%d, %s)\n",
      //     mcp1Offset1, [[mcp1Seqs objectAtIndex: mcp1File1] UTF8String],
      //     mcp1Offset2, [[mcp1Seqs objectAtIndex: mcp1File2] UTF8String],
      //     mcp2Offset1, [[mcp2Seqs objectAtIndex: mcp2File1] UTF8String],
      //     mcp2Offset2, [[mcp2Seqs objectAtIndex: mcp2File2] UTF8String]);
      
      // write out both
      fwrite(&mcp1Length, sizeof(int), 1, mcp3);
      fwrite(&mcp1NumFiles, sizeof(int), 1, mcp3);
      for (i = 0; i < mcp1NumFiles; ++i) {
        fwrite(&mcp1Offset[i], sizeof(int), 1, mcp3);
        fwrite(&mcp1File[i], sizeof(int), 1, mcp3);
      }
      
      fwrite(&mcp2Length, sizeof(int), 1, mcp3);
      fwrite(&mcp2NumFiles, sizeof(int), 1, mcp3);
      for (i = 0; i < mcp2NumFiles; ++i) {
        int fileNum = mapSeqs[mcp2File[i]];
        fwrite(&mcp2Offset[i], sizeof(int), 1, mcp3);
        fwrite(&fileNum, sizeof(int), 1, mcp3);
      }
      
      // next sequence
      fread(&mcp1Length, sizeof(int), 1, mcp1);
      fread(&mcp1NumFiles, sizeof(int), 1, mcp1);
      for (i = 0; i < mcp1NumFiles; ++i) {
        fread(&(mcp1Offset[i]), sizeof(int), 1, mcp1);
        fread(&(mcp1File[i]), sizeof(int), 1, mcp1);
      }
      mcp1Index = [[sequenceToMeta objectAtIndex: mcp1File[0]] intValue];
      cacheFile1 = [cachedFiles objectAtIndex: mcp1Index];
      mcp1Seqs = [[seqFiles1 objectAtIndex: mcp1Index] objectForKey: @"sequences"];
      seq1Start = [[[mcp1Seqs objectAtIndex: 0] objectForKey: @"number"] intValue];
      mcp1SeqIndex = mcp1File[0] - seq1Start;
      seq1Len = [[[mcp1Seqs objectAtIndex: mcp1SeqIndex] objectForKey: @"length"] intValue];
      if (mcp1Length > mallocLength1) {
        mallocLength1 = mcp1Length;
        free(seqBuffer1);
        seqBuffer1 = malloc(mallocLength1);
      }
      [cacheFile1 symbols: seqBuffer1 atPosition: mcp1Offset[0] ofLength: mcp1Length forSequenceNumber: mcp1SeqIndex];
      
      fread(&mcp2Length, sizeof(int), 1, mcp2);
      fread(&mcp2NumFiles, sizeof(int), 1, mcp2);
      for (i = 0; i < mcp2NumFiles; ++i) {
        fread(&(mcp2Offset[i]), sizeof(int), 1, mcp2);
        fread(&(mcp2File[i]), sizeof(int), 1, mcp2);
      }
      mcp2Index = [[sequenceToMeta2 objectAtIndex: mcp2File[0]] intValue];
      cacheFile2 = [cachedFiles2 objectAtIndex: mcp2Index];
      mcp2Seqs = [[seqFiles2 objectAtIndex: mcp2Index] objectForKey: @"sequences"];
      seq2Start = [[[mcp2Seqs objectAtIndex: 0] objectForKey: @"number"] intValue];
      mcp2SeqIndex = mcp2File[0] - seq2Start;
      seq2Len = [[[mcp2Seqs objectAtIndex: mcp2SeqIndex] objectForKey: @"length"] intValue];
      if (mcp2Length > mallocLength2) {
        mallocLength2 = mcp2Length;
        free(seqBuffer2);
        seqBuffer2 = malloc(mallocLength2);
      }
      [cacheFile2 symbols: seqBuffer2 atPosition: mcp2Offset[0] ofLength: mcp2Length forSequenceNumber: mcp2SeqIndex];
      
    } else {
      printf("ERROR: offsetToWrite is %d.\n", offsetToWrite);
      return NO;
    }
  }
  
  if (feof(mcp1)) {
    // write out remaining sequences
    while (!feof(mcp2)) {
      fwrite(&mcp2Length, sizeof(int), 1, mcp3);
      fwrite(&mcp2NumFiles, sizeof(int), 1, mcp3);
      for (i = 0; i < mcp2NumFiles; ++i) {
        int fileNum = mapSeqs[mcp2File[i]];
        fwrite(&mcp2Offset[i], sizeof(int), 1, mcp3);
        fwrite(&fileNum, sizeof(int), 1, mcp3);
      }
      
      fread(&mcp2Length, sizeof(int), 1, mcp2);
      fread(&mcp2NumFiles, sizeof(int), 1, mcp2);
      for (i = 0; i < mcp2NumFiles; ++i) {
        fread(&(mcp2Offset[i]), sizeof(int), 1, mcp2);
        fread(&(mcp2File[i]), sizeof(int), 1, mcp2);
      }
    }
  } else if (feof(mcp2)) {
    // write out remaining sequences
    while (!feof(mcp1)) {
      fwrite(&mcp1Length, sizeof(int), 1, mcp3);
      fwrite(&mcp1NumFiles, sizeof(int), 1, mcp3);
      for (i = 0; i < mcp1NumFiles; ++i) {
        fwrite(&mcp1Offset[i], sizeof(int), 1, mcp3);
        fwrite(&mcp1File[i], sizeof(int), 1, mcp3);
      }
      
      fread(&mcp1Length, sizeof(int), 1, mcp1);
      fread(&mcp1NumFiles, sizeof(int), 1, mcp1);
      for (i = 0; i < mcp1NumFiles; ++i) {
        fread(&(mcp1Offset[i]), sizeof(int), 1, mcp1);
        fread(&(mcp1File[i]), sizeof(int), 1, mcp1);
      }
    }
  } else {
    printf("ERROR: not at EOF for either file.\n");
    return NO;
  }
  
  fclose(mcp1);
  fclose(mcp2);
  fclose(mcp3);
  free(seqBuffer1);
  free(seqBuffer2);
  
  return YES;
}

- (BOOL)trimToFile:(NSString *)aPath
{
  int i;
  NSMutableArray *rangeList = [NSMutableArray new];
  
  FILE *mcp = [self getFILE];
  NSArray *seqFiles = [metaDict objectForKey: @"sequence files"];
  int mcpCnt = [[[[[seqFiles lastObject] objectForKey: @"sequences"] lastObject] objectForKey: @"number"] intValue] + 1;
  
  while (!feof(mcp)) {
    int mcpLength, mcpNumFiles;
    int mcpFile[mcpCnt], mcpOffset[mcpCnt];
    fread(&mcpLength, sizeof(int), 1, mcp);
    fread(&mcpNumFiles, sizeof(int), 1, mcp);
    for (i = 0; i < mcpNumFiles; ++i) {
      fread(&(mcpOffset[i]), sizeof(int), 1, mcp);
      fread(&(mcpFile[i]), sizeof(int), 1, mcp);
    }
    
    MCPNode *aNode = [[MCPNode alloc] initWithLength: mcpCnt];
    aNode->numFiles = mcpNumFiles;
    for (i = 0; i < mcpNumFiles; ++i) {
      aNode->file[i] = mcpFile[i];
      aNode->sequence[i].location = mcpOffset[i];
      aNode->sequence[i].length = mcpLength;
    }
    insert_range(rangeList, aNode, metaDict);
  }
  
  // open output mcp file
  NSString *aString = [aPath stringByAppendingPathExtension: @"mcp"];
  FILE *mcp3 = fopen([aString UTF8String], "w");
  if (!mcp3) {
    NSLog(@"Could not open file: %@\n", aString);
    fclose(mcp);
    return NO;
  }
  
  // meta mcp file
  NSString *metaFile = [aPath stringByAppendingPathExtension: @"meta_mcp"];
  NSMutableDictionary *metaDict3 = [NSMutableDictionary dictionaryWithDictionary: metaDict];
  [metaDict3 setObject: aString forKey: @"mcp file"];
  [metaDict3 writeToFile: metaFile atomically: YES];
  
  // sort by length
  NSArray *sortedArray = [rangeList sortedArrayUsingSelector:@selector(lengthCompare:)];
  
  // write out trimmed mcps
  printf("%d trimmed sequences\n", [sortedArray count]);
  int j;
  for (i = [sortedArray count] - 1; i >= 0; --i) {
    MCPNode *n = [sortedArray objectAtIndex: i];
    //printf("range (%d, %d)\n", n->sequence[0].location, n->sequence[0].length);
    fwrite(&(n->sequence[0].length), sizeof(int), 1, mcp3);
    fwrite(&(n->numFiles), sizeof(int), 1, mcp3);
    for (j = 0; j < n->numFiles; ++j) {
      fwrite(&(n->sequence[j].location), sizeof(int), 1, mcp3);
      fwrite(&(n->file[j]), sizeof(int), 1, mcp3);
    }
  }
  fclose(mcp3);
  fclose(mcp);
  
  return YES;
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
  cachedFiles = nil;
  sequenceArray = nil;
  
  // read meta file
  NSString *metaFile = [aPath stringByAppendingPathExtension: @"meta_mcp"];
  metaDict = [[NSMutableDictionary alloc] initWithContentsOfFile: metaFile];
  if (!metaDict) return nil;
  
  sequenceToMeta = [NSMutableArray new];
  
  int i, j;
  NSArray *seqFiles = [metaDict objectForKey: @"sequence files"];
  if (inMemory) {
    // load sequences into memory
    sequenceArray = [BCSequenceArray new];
    BCSequenceReader *sequenceReader = [[[BCSequenceReader alloc] init] autorelease];
    for (i = 0; i < [seqFiles count]; ++i) {
      NSDictionary *d = [seqFiles objectAtIndex: i];
      NSString *s = [d objectForKey: @"sequences file"];
      BCSequenceArray *seqArray = [sequenceReader readFileUsingPath: s];
      for (j = 0; j < [seqArray count]; ++j) {
        [sequenceArray addSequence: [seqArray sequenceAtIndex: j]];
        [sequenceToMeta addObject: [NSNumber numberWithInt: i]];
      }
    }
    [self buildReverseComplementArray];
  } else {
    // cache the sequence files
    cachedFiles = [NSMutableArray new];
    for (i = 0; i < [seqFiles count]; ++i) {
      NSDictionary *d = [seqFiles objectAtIndex: i];
      NSString *s = [d objectForKey: @"sequences file"];
      BCCachedSequenceFile *cachedFile = [BCCachedSequenceFile readCachedFileUsingPath: s];
      [cachedFiles addObject: cachedFile];
      for (j = 0; j < [cachedFile numberOfSequences]; ++j) {
        [sequenceToMeta addObject: [NSNumber numberWithInt: i]];
      }
    }
  }
  
  return self;
}

- (BOOL)writeToFile:(NSString *)aPath
{
  return NO;
}

- (FILE *)getFILE
{
  if (!metaDict) return NULL;
  NSString *s = [metaDict objectForKey: @"mcp file"];
  if (!s) return NULL;
  FILE *mcp = fopen([s UTF8String], "r");
  return mcp;
}

- (BOOL)isInMemory { return inMemory; }
- (BCSequenceArray *)sequenceArray { return sequenceArray; }
- (BCSequenceArray *)reverseComplementArray { return reverseComplementArray; }
- (NSDictionary *)metaDictionary { return metaDict; }
- (NSArray *)sequenceToMeta { return sequenceToMeta; }
- (NSArray *)cachedFiles { return cachedFiles; }

  //
  // Output methods
  //

#define FASTA_FORMAT 1
#define SUMMARY_FORMAT 2
#define TABLE_FORMAT 3
#define RAW_FORMAT 4

- (void)printHeaderFormat:(int)aFormat number:(int)aNum length:(int)aLen
{
  switch (aFormat) {
    case FASTA_FORMAT:
      printf(">mcp%d length: %d files:", aNum, aLen);
      break;
    case SUMMARY_FORMAT:
      printf("length: %d files:", aLen);
      break;
    case TABLE_FORMAT:
      printf("%d", aLen);
  }
}

- (void)printEntryFormat:(int)aFormat file:(NSString *)fileName seq:(NSString *)seqID
                  strand:(NSString *)theStrand position:(int)aPos
{
  switch (aFormat) {
    case FASTA_FORMAT:
    case SUMMARY_FORMAT:
      printf(" %s(%s,%s:%d)", [fileName UTF8String], [seqID UTF8String], [theStrand UTF8String], aPos);
      break;
    case TABLE_FORMAT:
      printf("\t%s\t%s\t%s\t%d", [fileName UTF8String], [seqID UTF8String], [theStrand UTF8String], aPos);
  }
}

- (void)outputFormat:(int)outputFormat withMinimumLength:(int)minLength
{
  FILE *mcp = [self getFILE];
  if (!mcp) return;
  
  NSArray *seqFiles = [metaDict objectForKey: @"sequence files"];
  int mcpCnt = [sequenceToMeta count];
  
  // max MCP
  int maxLength = 0, maxNumFiles = 0, maxNumOfMCP = 0;
  int maxFile[mcpCnt], maxOffset[mcpCnt];
  
  int numOfMCP = 1;
  int mcpLength, mcpNumFiles;
  int mcpFile[mcpCnt], mcpOffset[mcpCnt];
  fread(&mcpLength, sizeof(int), 1, mcp);
  fread(&mcpNumFiles, sizeof(int), 1, mcp);
  int i;
  for (i = 0; i < mcpNumFiles; ++i) {
    fread(&(mcpOffset[i]), sizeof(int), 1, mcp);
    fread(&(mcpFile[i]), sizeof(int), 1, mcp);
  }
  
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  while (!feof(mcp)) {
    
    // free up temporary data for large MCP files
    if ((numOfMCP % 100000) == 0) {
      [pool release];
      pool = [NSAutoreleasePool new];
    }
    
    // not just the maximum
    if ((minLength != 0) && (mcpLength >= minLength)) {
      
      // output MCP meta data
      [self printHeaderFormat: outputFormat number: numOfMCP length: mcpLength];
      for (i = 0; i < mcpNumFiles; ++i) {
        
        // get sequence info
        NSString *seqFile, *seqID, *theStrand;
        int aPos, seqLen;
        if (inMemory) {
          // sequences in memory
          NSNumber *n = [sequenceToMeta objectAtIndex: mcpFile[i]];
          NSDictionary *aDict = [seqFiles objectAtIndex: [n intValue]];
          seqFile = [[aDict objectForKey: @"sequences file"] lastPathComponent];
          BCSequence *aSeq = [sequenceArray sequenceAtIndex: mcpFile[i]];
          seqLen = [aSeq length];
          seqID = [[aSeq annotationForKey: @">"] stringValue];
        } else {
          // cached sequences on disk
          int mcpIndex = [[sequenceToMeta objectAtIndex: mcpFile[i]] intValue];
          seqFile = [[[seqFiles objectAtIndex: mcpIndex] objectForKey: @"sequences file"] lastPathComponent];
          NSArray *mcpSeqs = [[seqFiles objectAtIndex: mcpIndex] objectForKey: @"sequences"];
          int seqStart = [[[mcpSeqs objectAtIndex: 0] objectForKey: @"number"] intValue];
          int mcpSeqIndex = mcpFile[i] - seqStart;
          seqLen = [[[mcpSeqs objectAtIndex: mcpSeqIndex] objectForKey: @"length"] intValue];
          seqID = [[mcpSeqs objectAtIndex: mcpSeqIndex] objectForKey: @"id"];
        }
        
        if (mcpOffset[i] < seqLen) {
          theStrand = @"F";
          aPos = mcpOffset[i];
        } else {
          theStrand = @"R";
          aPos = 2*seqLen - mcpOffset[i] - mcpLength;
        }
        NSRange aRange = [seqID rangeOfString: @" "];
        if (aRange.location != NSNotFound) {
          aRange.length = aRange.location;
          aRange.location = 0;
          seqID = [seqID substringWithRange: aRange];
        }
        
        [self printEntryFormat: outputFormat file: seqFile seq: seqID strand: theStrand position: aPos];
      }
      if (outputFormat == FASTA_FORMAT) printf("\n");
      if (outputFormat == SUMMARY_FORMAT) printf("\nsequence:\n");
      if (outputFormat == TABLE_FORMAT) printf("\n");
      
      // output sequence data
      if ((outputFormat == FASTA_FORMAT) || (outputFormat == SUMMARY_FORMAT)) {
        char *seqData;
        BCCachedSequenceFile *cacheFile;
        int aPos, mcpSeqIndex;
        
        if (inMemory) {
          BCSequence *aSeq = [sequenceArray sequenceAtIndex: mcpFile[0]];
          int seqLen = [aSeq length];
          if (mcpOffset[0] < seqLen) {
            seqData = (char *)[[aSeq sequenceData] bytes];
            aPos = mcpOffset[0];
          } else {
            aSeq = [reverseComplementArray sequenceAtIndex: mcpFile[0]];
            seqData = (char *)[[aSeq sequenceData] bytes];
            aPos = 2*seqLen - mcpOffset[0] - mcpLength;
          }
        } else {
          int mcpIndex = [[sequenceToMeta objectAtIndex: mcpFile[0]] intValue];
          cacheFile = [cachedFiles objectAtIndex: mcpIndex];
          NSArray *mcpSeqs = [[seqFiles objectAtIndex: mcpIndex] objectForKey: @"sequences"];
          int seqStart = [[[mcpSeqs objectAtIndex: 0] objectForKey: @"number"] intValue];
          mcpSeqIndex = mcpFile[0] - seqStart;
          aPos = mcpOffset[0];
        }
        
        int j;
        int lineLen = 0;
        for (j = 0; j < mcpLength; ++j) {
          if (inMemory) printf("%c", seqData[aPos + j]);
          else printf("%c", [cacheFile symbolAtPosition: (aPos + j) forSequenceNumber: mcpSeqIndex]);
          ++lineLen;
          if ((outputFormat == FASTA_FORMAT) && (lineLen == 50) && (mcpLength > 70)) {
            printf("\n");
            lineLen = 0;
          }
        }
        
        if (outputFormat == FASTA_FORMAT) printf("\n");
        else printf("\n\n");
      }
    }
    
    // new maximum?
    if (mcpLength > maxLength) {
      maxLength = mcpLength;
      maxNumFiles = mcpNumFiles;
      maxNumOfMCP = numOfMCP;
      for (i = 0; i < mcpNumFiles; ++i) {
        maxOffset[i] = mcpOffset[i];
        maxFile[i] = mcpFile[i];
      }
    }
    
    // next sequence
    ++numOfMCP;
    fread(&mcpLength, sizeof(int), 1, mcp);
    fread(&mcpNumFiles, sizeof(int), 1, mcp);
    for (i = 0; i < mcpNumFiles; ++i) {
      fread(&(mcpOffset[i]), sizeof(int), 1, mcp);
      fread(&(mcpFile[i]), sizeof(int), 1, mcp);
    }
  }
  
  // only print max if no min length specified
  if (maxLength == 0)
    printf("Empty mcp file.\n");
  else if (minLength == 0) {
    [self printHeaderFormat: outputFormat number: maxNumOfMCP length: maxLength];
    
    // output MCP meta data
    for (i = 0; i < maxNumFiles; ++i) {
      
      // get sequence info
      NSString *seqFile, *seqID, *theStrand;
      int aPos, seqLen;
      if (inMemory) {
        // sequences in memory
        NSNumber *n = [sequenceToMeta objectAtIndex: maxFile[i]];
        NSDictionary *aDict = [seqFiles objectAtIndex: [n intValue]];
        seqFile = [[aDict objectForKey: @"sequences file"] lastPathComponent];
        BCSequence *aSeq = [sequenceArray sequenceAtIndex: maxFile[i]];
        seqLen = [aSeq length];
        seqID = [[aSeq annotationForKey: @">"] stringValue];
      } else {
        // cached sequences on disk
        int mcpIndex = [[sequenceToMeta objectAtIndex: maxFile[i]] intValue];
        seqFile = [[[seqFiles objectAtIndex: mcpIndex] objectForKey: @"sequences file"] lastPathComponent];
        NSArray *mcpSeqs = [[seqFiles objectAtIndex: mcpIndex] objectForKey: @"sequences"];
        int seqStart = [[[mcpSeqs objectAtIndex: 0] objectForKey: @"number"] intValue];
        int mcpSeqIndex = maxFile[i] - seqStart;
        seqLen = [[[mcpSeqs objectAtIndex: mcpSeqIndex] objectForKey: @"length"] intValue];
        seqID = [[mcpSeqs objectAtIndex: mcpSeqIndex] objectForKey: @"id"];
      }
      
      if (maxOffset[i] < seqLen) {
        theStrand = @"F";
        aPos = maxOffset[i];
      } else {
        theStrand = @"R";
        aPos = 2*seqLen - maxOffset[i] - maxLength;
      }
      NSRange aRange = [seqID rangeOfString: @" "];
      if (aRange.location != NSNotFound) {
        aRange.length = aRange.location;
        aRange.location = 0;
        seqID = [seqID substringWithRange: aRange];
      }
      
      [self printEntryFormat: outputFormat file: seqFile seq: seqID strand: theStrand position: aPos];
    }
    if (outputFormat == FASTA_FORMAT) printf("\n");
    if (outputFormat == SUMMARY_FORMAT) printf("\nsequence:\n");
    if (outputFormat == TABLE_FORMAT) printf("\n");
    
    // output sequence data
    if ((outputFormat == FASTA_FORMAT) || (outputFormat == SUMMARY_FORMAT)) {
      char *seqData;
      BCCachedSequenceFile *cacheFile;
      int aPos, mcpSeqIndex;
      
      if (inMemory) {
        BCSequence *aSeq = [sequenceArray sequenceAtIndex: maxFile[0]];
        int seqLen = [aSeq length];
        if (maxOffset[0] < seqLen) {
          seqData = (char *)[[aSeq sequenceData] bytes];
          aPos = maxOffset[0];
        } else {
          aSeq = [reverseComplementArray sequenceAtIndex: maxFile[0]];
          seqData = (char *)[[aSeq sequenceData] bytes];
          aPos = 2*seqLen - maxOffset[0] - maxLength;
        }
      } else {
        int mcpIndex = [[sequenceToMeta objectAtIndex: maxFile[0]] intValue];
        cacheFile = [cachedFiles objectAtIndex: mcpIndex];
        NSArray *mcpSeqs = [[seqFiles objectAtIndex: mcpIndex] objectForKey: @"sequences"];
        int seqStart = [[[mcpSeqs objectAtIndex: 0] objectForKey: @"number"] intValue];
        mcpSeqIndex = maxFile[0] - seqStart;
        aPos = maxOffset[0];
      }
      
      int j;
      int lineLen = 0;
      for (j = 0; j < maxLength; ++j) {
        if (inMemory) printf("%c", seqData[aPos + j]);
        else printf("%c", [cacheFile symbolAtPosition: (aPos + j) forSequenceNumber: mcpSeqIndex]);
        ++lineLen;
        if ((outputFormat == FASTA_FORMAT) && (lineLen == 50) && (maxLength > 70)) {
          printf("\n");
          lineLen = 0;
        }
      }
      printf("\n");
    }
  }
  [pool release];
  
  fclose(mcp);
}

- (void)summaryFormatWithMinimumLength:(int)minLength
{
  [self outputFormat: SUMMARY_FORMAT withMinimumLength: minLength];
}

- (void)fastaFormatWithMinimumLength:(int)minLength
{
  [self outputFormat: FASTA_FORMAT withMinimumLength: minLength];
}

- (void)tableFormatWithMinimumLength:(int)minLength
{
  [self outputFormat: TABLE_FORMAT withMinimumLength: minLength];
}

@end

//
// Helper class for MCP trim
//
@implementation MCPNode
- initWithLength: (int)num
{
  self = [super init];
  
  maxCnt = num;
  file = (int *)malloc(sizeof(int) * maxCnt);
  if (!file) {
    printf("ERROR: out of memory\n");
    return nil;
  }
  sequence = (NSRange *)malloc(sizeof(NSRange) * maxCnt);
  if (!sequence) {
    printf("ERROR: out of memory\n");
    return nil;
  }
  
  return self;
}

- (NSComparisonResult)lengthCompare:(MCPNode *)anObject
{
  NSRange nr = sequence[0];
  NSRange or = anObject->sequence[0];
  if (nr.length > or.length) return NSOrderedDescending;
  if (nr.length < or.length) return NSOrderedAscending;
  return NSOrderedSame;
}
@end

static void insert_range(NSMutableArray *a, MCPNode *aNode, NSDictionary *metaDict)
{
  int i, j, k;
  int cnt = [a count];
  
  //printf("insert range (%d, %d)\n", aNode->sequence[0].location, aNode->sequence[0].length);
  MCPNode *swapNode = nil;
  BOOL found = NO;
  MCPNode *n;
  for (i = 0;i < cnt; ++i) {
    n = [a objectAtIndex: i];
    
    // only compare if in same files
    if (aNode->numFiles != n->numFiles) continue;
    for (j = 0; j < aNode->numFiles; ++j) {
      BOOL done = NO;
      for (k = 0; k < n->numFiles; ++k) {
        if (aNode->file[j] == n->file[k]) {
          done = YES;
          break;
        }
      }
      if (!done) {
        found = YES;
        break;
      }
    }
    if (found) {
      found = NO;
      continue;
    }
    // check each range
    for (j = 0; j < aNode->numFiles; ++j) {
      for (k = 0; k < n->numFiles; ++k) {
        if (aNode->file[j] == n->file[k]) break;
      }
      if (k == n->numFiles) {
        printf("ERROR: could not match files.\n");
        exit(1);
      }
      
      MCPNode *newSwap = nil;
      found = NO;
      NSRange nr1 = aNode->sequence[j];
      NSRange nr2 = n->sequence[k];
      
      if (NSLocationInRange(nr1.location, nr2)
          && NSLocationInRange(nr1.location + nr1.length - 1, nr2)) {
        // aNode's sequence is inside n's sequence
        found = YES;
      } else if (NSLocationInRange(nr2.location, nr1)
                 && NSLocationInRange(nr2.location + nr2.length - 1, nr1)) {
        // n's sequence is inside aNode's sequence
        found = YES;
        newSwap = n;
      }
      
      if (j == 0) swapNode = newSwap;
      if (!found) break;
      else {
        // all ranges have to be same comparison
        if (newSwap != swapNode) break;
      }
    }
    
    if (found) break;
  }
  
  if (!found) {
    [a addObject: aNode];
#if 0
    printf("ADD length: %d files: %s(%d)", aNode->sequence[0].length,
           names[aNode->file[0]], aNode->sequence[0].location);
    for (i = 1; i < aNode->numFiles; ++i)
      printf(", %s(%d)", names[aNode->file[i]], aNode->sequence[i].location);
    printf("\n");
#endif
  } else if (swapNode) {
    [a removeObject: swapNode];
    [a addObject: aNode];
#if 0
    printf("SWAP length: %d files: %s(%d)", aNode->sequence[0].length,
           names[aNode->file[0]], aNode->sequence[0].location);
    for (i = 1; i < aNode->numFiles; ++i)
      printf(", %s(%d)", names[aNode->file[i]], aNode->sequence[i].location);
    printf("\n");
    
    printf("WITH length: %d files: %s(%d)", swapNode->sequence[0].length,
           names[swapNode->file[0]], swapNode->sequence[0].location);
    for (i = 1; i < swapNode->numFiles; ++i)
      printf(", %s(%d)", names[swapNode->file[i]], swapNode->sequence[i].location);
    printf("\n");
  } else {
    printf("FOUND length: %d files: %s(%d)", aNode->sequence[0].length,
           names[aNode->file[0]], aNode->sequence[0].location);
    for (i = 1; i < aNode->numFiles; ++i)
      printf(", %s(%d)", names[aNode->file[i]], aNode->sequence[i].location);
    printf("\n");
    
    printf("INSIDE length: %d files: %s(%d)", n->sequence[0].length,
           names[n->file[0]], n->sequence[0].location);
    for (i = 1; i < n->numFiles; ++i)
      printf(", %s(%d)", names[n->file[i]], n->sequence[i].location);
    printf("\n");
#endif
  }
}
