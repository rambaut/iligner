//
//  BCSequenceReader.m
//  BioCocoa
//
//  Created by Koen van der Drift on 10/16/04.
//  Copyright 2004 The BioCocoa Project. All rights reserved.
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

#import "BCSequenceReader.h"
#import "BCUtilStrings.h"
#import "BCSequence.h"
#import "BCAnnotation.h"
#import "BCSymbolSet.h"
#import "BCSequenceArray.h"

#import "BCFoundationDefines.h"
#import "BCInternal.h"

@implementation BCSequenceReader


- (BCSequenceArray *)readFileUsingPath:(NSString *)filePath
{
	BCSequenceArray	*result = nil;
	
    if([NSHFSTypeOfFile(filePath) isEqualToString: @"'xDNA'"])
	{
		result = [self readStriderFile: filePath];
	}
	
	else if([NSHFSTypeOfFile(filePath) isEqualToString: @"'GCKc'"] || [NSHFSTypeOfFile(filePath) isEqualToString: @"'GCKs'"])
	{
		result = [self readGCKFile: filePath];
	}
	else if ([NSHFSTypeOfFile(filePath) isEqualToString: @"'PROT'"] || [NSHFSTypeOfFile(filePath) isEqualToString: @"'NUCL'"])
	{
		result = [self readMacVectorFile: filePath];
	}
	else	// TEXT file
	{
		NSMutableString	*sequenceFileContents;

		// First test for EXDNA
		if([[filePath pathExtension] isEqualToString: @"exdna"])
		{
			sequenceFileContents = [NSMutableString stringWithContentsOfFile: [filePath stringByAppendingPathComponent: @"sequence.txt"]];
		}
		else
		{
			if ([[NSFileManager defaultManager] fileExistsAtPath: filePath])
			{
				sequenceFileContents = [NSMutableString stringWithContentsOfFile: filePath];
			}
			else
			{
			 // were actually dealing with a string input here, not a file
				sequenceFileContents = [NSMutableString stringWithString: filePath];
			}
		}
	
		result = [self readFileUsingText: sequenceFileContents];
	}
	
	return result;
}

- (BCSequenceArray *)readFileUsingPath:(NSString *)filePath format:(BCFileFormat)aFormat
{
	BCSequenceArray	*result = nil;
  NSMutableString *sequenceFileContents;

  switch (aFormat) {
    case BCFastaFileFormat:
      sequenceFileContents = [NSMutableString stringWithContentsOfFile: filePath];
			result = [self readFastaFile: sequenceFileContents];
      break;
    case BCSwissProtFileFormat:
      sequenceFileContents = [NSMutableString stringWithContentsOfFile: filePath];
      result = [self readSwissProtFile: sequenceFileContents];
      break;
    case BCPDBFileFormat:
      sequenceFileContents = [NSMutableString stringWithContentsOfFile: filePath];
      result = [self readPDBFile: sequenceFileContents];
      break;
    case BCNCBIFileFormat:
      sequenceFileContents = [NSMutableString stringWithContentsOfFile: filePath];
      result = [self readNCBIFile: sequenceFileContents];
      break;
    case BCClustalFileFormat:
      sequenceFileContents = [NSMutableString stringWithContentsOfFile: filePath];
      result = [self readClustalFile: sequenceFileContents];
      break;
    case BCStriderFileFormat:
      result = [self readStriderFile: filePath];
      break;
    case BCGCKFileFormat:
      result = [self readGCKFile: filePath];
      break;
    case BCMacVectorFileFormat:
      result = [self readMacVectorFile: filePath];
      break;
    case BCGDEFFileFormat:
      sequenceFileContents = [NSMutableString stringWithContentsOfFile: filePath];
      result = [self readGDEFile: sequenceFileContents];
      break;
    case BCPirFileFormat:
      sequenceFileContents = [NSMutableString stringWithContentsOfFile: filePath];
			result = [self readPirFile: sequenceFileContents];
      break;
    case BCMSFFileFormat:
      break;
    case BCPhylipFileFormat:
      sequenceFileContents = [NSMutableString stringWithContentsOfFile: filePath];
      result = [self readPhylipFile: sequenceFileContents];
      break;
    case BCNonaFileFormat:
      break;
    case BCHenningFileFormat:
      break;
  }

  return result;
}

- (BCSequenceArray *)readFileUsingData:(NSData *)dataFile
{
	NSString	*entryString = [[NSString alloc] initWithData: dataFile encoding: NSASCIIStringEncoding];	// or NSUTF8StringEncoding ?

	return [self readFileUsingText: [entryString autorelease]];
}

- (BCSequenceArray *)readFileUsingText:(NSString *)entryString
{
	BCSequenceArray	*result = nil;

 // RTF?
	
	if ([entryString hasCaseInsensitivePrefix: @"{\\rtf1"])
	{
	 // convert rtf string to a plain text string
		NSAttributedString *rtfstring = [[NSAttributedString alloc] initWithRTF: [entryString dataUsingEncoding: NSUTF8StringEncoding] documentAttributes: nil];
		entryString = [rtfstring string];
		[rtfstring release];
	}
	
	//		// should we also filter for HTML? Probably the best way to test whether we are dealing for a html file is to check for the last
	//		// html tag, which is alway </html>. Looking for the first tag won't work, since that varies too much.
	
	//		if ([entryString hasCaseInsensitiveSuffix: @"</html>"])
	//		{
	//			NSAttributedString *htmlstring = [[NSAttributedString alloc] initWithHTML: [NSData dataWithContentsOfFile: entryString] documentAttributes: nil];
	//			[sequenceFileContents setString: [htmlstring string]];
	//			[htmlstring release];
	//		}


 // DETERMINE TYPE
	
	if ([entryString hasCaseInsensitivePrefix:@"#NEXUS"] || [entryString hasCaseInsensitivePrefix:@"#PAUP"])
	{
		//result = [self readNexusFileAndBlocks: entryString];
	}
	
	else if ([entryString hasCaseInsensitivePrefix: @"proc/"])
	{
		//result = [self readNonaFile: entryString];
	}   

	else if ([entryString hasCaseInsensitivePrefix: @"xread"])
	{
		//result = [self readHennigFile: entryString];
	}    

	else if ([entryString hasCaseInsensitivePrefix: @"CLUSTAL"])
	{
		result = [self readClustalFile: entryString];
	}
	
	else if ([entryString hasCaseInsensitivePrefix: @"!!NA_"] || [entryString hasCaseInsensitivePrefix: @"!!AA_"] )
	{
		//result = [self readMSFFile: entryString];
	}
	
	else if ([entryString hasPrefix:@">"])
	{
		if ([entryString characterAtIndex: 3] == ';')
		{
			result = [self readPirFile: entryString];
		}
		else
		{
			result = [self readFastaFile: entryString];
		}
	}
	
	else if ([entryString hasPrefix:@"HEADER"])
	{
		result = [self readPDBFile: entryString];
	}
	
	else if ([entryString hasPrefix:@"LOCUS"])
	{
		result = [self readNCBIFile: entryString];
	}
	
	else if ([entryString hasPrefix:@"#"])
	{
		result = [self readGDEFile: entryString];
	}
	
	else if ([entryString hasPrefix:@"ID"])
	{
		result = [self readSwissProtFile: entryString];
	}
	
	else if ([entryString stringBeginsWithTwoNumbers])	
	{
		result = [self readPhylipFile: entryString];
	}

	else
	{
		result = [self readRawFile: entryString];		// Assumes sequences are in plain format
	}
	
	return result;
}

- (BCSequenceArray *) readFastaFile:(NSString *)entryString
{
#if 1
	BCSequenceArray	*result;
  NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

  int cnt = [entryString length];
  
	result = [[BCSequenceArray alloc] init];

  //printf("Allocating %d bytes.\n", cnt + 1);
  char *seq1 = (char *)malloc(sizeof(char) * (cnt + 1));
  if (!seq1) {
    NSLog(@"Not enough memory to load sequence file.\n");
    return nil;
  }
  bzero(seq1, cnt + 1);

  //printf("Loading file.\n");
	unsigned start, end, next; 
	NSRange range; 
  BCAnnotation *d = nil;
  int seqLen = 0;
  const char *dataBuffer = [entryString UTF8String];
	unsigned stringLength = [entryString length]; 
	range.location = 0; 
	range.length = 1; 
	do { 
		[entryString getLineStart:&start end:&next contentsEnd:&end forRange:range]; 

		range.location = start; 
		range.length = end-start; 

    if ([entryString characterAtIndex: start] == '>') {
      // FASTA header, separate sequences

      // save the previous sequence that just ended
      if (d) {
        NSData *finalData = [NSData dataWithBytes: seq1 length: seqLen];
        BCSequence *newSequence = [[BCSequence alloc] initWithData: finalData symbolSet: nil];
        [newSequence addAnnotation: d];
        [result addSequence: newSequence];
      }
      seqLen = 0;

      // FASTA header annotation
      ++range.location;
      --range.length;
      d = [BCAnnotation annotationWithName: @">" content: [entryString substringWithRange: range]];

    } else {
      // sequence segment
      memcpy(&(seq1[seqLen]), &(dataBuffer[range.location]), range.length);
      seqLen += range.length;
    }

		range.location = next; 
		range.length = 1; 
	} while (next < stringLength); 

  // save the last sequence
  NSData *finalData = [NSData dataWithBytes: seq1 length: seqLen];
  free(seq1);
  BCSequence *newSequence = [[BCSequence alloc] initWithData: finalData symbolSet: nil];
  [newSequence addAnnotation: d];
	[result addSequence: newSequence];
  [pool release];
#else
	BCSequence		*newSequence;
	NSMutableArray	*linesArray, *annotationsArray;
	BCSequenceArray	*result;
	NSString		*line, *sequenceString;
	int				i, j;

	linesArray = [entryString splitLines];
	result = [[BCSequenceArray alloc] init];
	annotationsArray = [NSMutableArray array];
	
	for (i = 0; i < [linesArray count]; i++)
	{
		line = [linesArray objectAtIndex: i];

		if ([line hasPrefix: @">"] )
		{
			[annotationsArray addObject: [BCAnnotation annotationWithName: @">" content: [line substringFromIndex: 1]]];		

			line = [linesArray objectAtIndex: ++i];

			sequenceString = @"";
		
		// until the next sequence
			while (![line hasPrefix:@">"] )
			{			
				sequenceString = [sequenceString stringByAppendingString: [line stringByRemovingWhitespace]];

				i++;
				
				if ( i < [linesArray count])
				{
					line = [linesArray objectAtIndex: i];
				}
				else
					break;
			}

		// we don't know what the sequence type is going to be, so we will let the
		// creation code figure that out
			newSequence = [BCSequence sequenceWithString: sequenceString];

			for (j = 0; j < [annotationsArray count]; j++)
			{
				[newSequence addAnnotation: [annotationsArray objectAtIndex:j]];
			}

			[result addSequence: newSequence];
			[annotationsArray removeAllObjects];

			i--;
		}
	}
#endif

	return result;
}


- (BCSequenceArray *) readSwissProtFile:(NSString *)entryString
{
// TODO: need to make a nested annotation for the reference entries

	NSString			*line, *sequenceString;
	NSMutableArray		*linesArray, *annotationsArray;
	BCSequenceArray		*result;
	BCSequence			*newSequence;
	int					i, j;
	
	linesArray = [entryString splitLines];
	annotationsArray = [NSMutableArray array];
	result = [[BCSequenceArray alloc] init];
	    
	for (i = 0; i < [linesArray count]; i++)
	{
		line = [linesArray objectAtIndex: i];

		if (![line hasPrefix:@"SQ"])
		{
			if ( ![line hasPrefix:@"XX"])
			{
				[annotationsArray addObject:[BCAnnotation annotationWithName: [line substringToIndex: 2] 
							content: [line substringFromIndex: 3]]];
			}
		}
		else
		{
		  // will extract the sequence here
			line = [linesArray objectAtIndex: ++i];
			sequenceString = @"";
					
			while (![line hasPrefix:@"//"] )
			{			
				sequenceString = [sequenceString stringByAppendingString:[line stringByRemovingWhitespace]];
				line = [linesArray objectAtIndex: ++i];
			}
		}
	}
	
	if ( [sequenceString length])
	{
	 // if it's an embl file it could be a dna or rna sequence,
	 // so don't set symbolset to protein, even though it's called the swiss prot format
	 
		newSequence = [BCSequence sequenceWithString: sequenceString];
		
		for (j = 0; j < [annotationsArray count]; j++)
		{
			[newSequence addAnnotation:[annotationsArray objectAtIndex:j]];
		}
		
		[result addSequence: newSequence];
		[annotationsArray removeAllObjects];
	}
	
	return result;
}


- (BCSequenceArray *)readPDBFile:(NSString *)entryString
{
	NSString			*line, *sequenceString;
	NSMutableArray	*linesArray, *annotationsArray;
	BCSequenceArray	*result;
	BCSequence			*newSequence;
	int					i, j;

	linesArray = [entryString splitLines];
	result = [[BCSequenceArray alloc] init];
	annotationsArray = [NSMutableArray array];
	
	sequenceString  = @"";
	
	for (i = 0; i < [linesArray count]; i++)
	{
		line = [linesArray objectAtIndex:i];

		if ( ![line hasPrefix:@"SEQRES"] )
		{
			[annotationsArray addObject:[BCAnnotation annotationWithName: [line substringToIndex: 10] 
				content: [line substringFromIndex: 11]]];		
		}
		else
        {
			sequenceString = [sequenceString stringByAppendingString:[line substringWithRange:NSMakeRange(19, 52)]];
        }
	}
	
	if ( [sequenceString length])
	{
		newSequence = [BCSequence sequenceWithThreeLetterString: sequenceString symbolSet: [BCSymbolSet proteinSymbolSet]];
	 
		for (j = 0; j < [annotationsArray count]; j++)
		{
			[newSequence addAnnotation:[annotationsArray objectAtIndex:j]];
		}
		
		[result addSequence: newSequence];
		[annotationsArray removeAllObjects];
	}
	
	return result;
}


- (BCSequenceArray *)readNCBIFile:(NSString *)entryString
{
	NSString		*line, *sequenceString;
	NSMutableArray	*linesArray, *annotationsArray;
	BCSequenceArray	*result;
	BCSequence		*newSequence;
	int				i, j;
	
	linesArray = [entryString splitLines];
	result = [[BCSequenceArray alloc] init];
	annotationsArray = [NSMutableArray array];
	
	sequenceString = @"";
	
	for (i = 0; i < [linesArray count]; i++)
	{
		line = [linesArray objectAtIndex:i];
		
		if (![line hasPrefix:@"ORIGIN"] )
		{		
			[annotationsArray addObject:[BCAnnotation annotationWithName: [line substringToIndex:10] 
				content: [line substringFromIndex:11]]];
		}
        else
		{
			line = [linesArray objectAtIndex: ++i];
			
			while (![line hasPrefix:@"//"] )
			{			
				sequenceString = [sequenceString stringByAppendingString:[[line substringFromIndex:10] stringByRemovingWhitespace]];
				line = [linesArray objectAtIndex: ++i];
			}

			if ( [sequenceString length])
			{
				newSequence = [BCSequence sequenceWithString: sequenceString];
				
				for (j = 0; j < [annotationsArray count]; j++)
				{
					[newSequence addAnnotation:[annotationsArray objectAtIndex:j]];
				}
				
				[result addSequence: newSequence];
				[annotationsArray removeAllObjects];
			}
        }
	}
	
	return result;
}

- (BCSequenceArray *)readStriderFile:(NSString *)textFile
{
/*
	Binary file format, read in header, determine features and sequence -> create dictionary.
*/
	STRIDER_HEADER *signature;
	
	BCSequence		*newSequence;
	BCSequenceArray	*result;
	NSString		*sequenceString;
	NSMutableArray	*annotationsArray;
	int				i;
	
	result = [[BCSequenceArray alloc] init];
	annotationsArray = [NSMutableArray array];
	sequenceString = @"";

	NSData *data  = [NSData dataWithContentsOfFile: textFile];

 // Memory alloc and read in struct
    signature = malloc(sizeof(STRIDER_HEADER));
    [data getBytes: signature length: sizeof(STRIDER_HEADER)];
	
 // Sequence
    NSData *seqdata = [data subdataWithRange: NSMakeRange(sizeof(STRIDER_HEADER), CFSwapInt32BigToHost(signature->nLength))];
    sequenceString = [sequenceString stringByAppendingString: [NSString stringWithBytes: [seqdata bytes] length: [seqdata length] encoding: NSASCIIStringEncoding]];
	[annotationsArray addObject: [BCAnnotation annotationWithName: @"name" content: [[textFile lastPathComponent]stringByDeletingPathExtension]]];		
	
 // Comments
    if(signature->com_length > 0)
	{
        NSData *comdata = [data subdataWithRange: NSMakeRange([data length] - CFSwapInt32BigToHost(signature->com_length), CFSwapInt32BigToHost(signature->com_length))];
		NSString *comments = [[NSString alloc] initWithBytes: [comdata bytes] length: [comdata length] encoding: NSASCIIStringEncoding];
		[annotationsArray addObject: [BCAnnotation annotationWithName: @"comments" content: comments]];		
		[comments release];
    }

	if ( [sequenceString length])
	{
		newSequence = [BCSequence sequenceWithString: sequenceString];
		
		for (i = 0; i < [annotationsArray count]; i++)
		{
			[newSequence addAnnotation: [annotationsArray objectAtIndex: i]];
		}
		
		[result addSequence: newSequence];
		[annotationsArray removeAllObjects];
	}    

 // Clean up
    free(signature);
    
    return result;
}



- (BCSequenceArray *)readGCKFile:(NSString *)textFile
{
/*
	Binary file format, read in header, determine features and sequence -> create dictionary.
	Same as DNA strider but comments are ignored
*/
 
	GCK_HEADER *signature;
	
	BCSequence		*newSequence;
	BCSequenceArray	*result;
	NSString		*sequenceString;
	NSMutableArray	*annotationsArray;
	int				i;
	
	result = [[BCSequenceArray alloc] init];
	annotationsArray = [NSMutableArray array];
	sequenceString = @"";
	
	NSData *data  = [NSData dataWithContentsOfFile: textFile];
	
 // Memory alloc and read in struct
    signature = malloc(sizeof(GCK_HEADER));
    [data getBytes: signature length: sizeof(GCK_HEADER)];
	
 // Sequence
    NSData *seqdata = [data subdataWithRange: NSMakeRange(sizeof(GCK_HEADER), CFSwapInt32BigToHost(signature->nLength))];
    sequenceString = [sequenceString stringByAppendingString: [NSString stringWithBytes: [seqdata bytes] length: [seqdata length] encoding: NSASCIIStringEncoding]];
	[annotationsArray addObject: [BCAnnotation annotationWithName: @"name" content: [[textFile lastPathComponent]stringByDeletingPathExtension]]];		
	
	if ( [sequenceString length])
	{
		newSequence = [BCSequence sequenceWithString: sequenceString];
		
		for (i = 0; i < [annotationsArray count]; i++)
		{
			[newSequence addAnnotation: [annotationsArray objectAtIndex: i]];
		}
		
		[result addSequence: newSequence];
		[annotationsArray removeAllObjects];
	}
    
 // Clean up
    free(signature);
    
    return result;
}

- (BCSequenceArray *)readMacVectorFile:(NSString *)textFile
{
	MACVECTOR_HEADER *signature;
	
	BCSequence		*newSequence;
	BCSequenceArray *result;
	NSMutableArray	*annotationsArray;
	NSString		*alphabet;
	unsigned char	*seqBuffer;
	int i, s;
	
	NSMutableString	*sequenceString = [NSMutableString string];
	
	result = [[BCSequenceArray alloc] init];
	annotationsArray = [NSMutableArray array];
	
	
	NSData *data = [NSData dataWithContentsOfFile: textFile];
	
	// get header data
	signature = malloc(sizeof(MACVECTOR_HEADER));
	[data getBytes: signature length: sizeof(MACVECTOR_HEADER)];
	
	/* 
		define the alphabet so that we can read proteins, DNA and RNA
		I'm not sure this is the most elegant way to do things...
		It works, anyway.
		Bytes in MacVector files corresponds to letters in alphabet
		The idea is to use the alphabet as an array so that 
		when one reads, say 0x02, has just to get character at index
		2 in the alphabet...
	 */
	
  if (signature->seqType)
	{
		// Protein
		alphabet = @"-ACDEFGHIKLMNPQRSTVWYB*X";
	}
	else if (signature->ntType == 1) 
	{
		// RNA, there are no T's, only U's
		alphabet = @"-ACMGRSVUWYHKDBN";
	}
	else 
	{
		// DNA
		alphabet = @"-ACMGRSVTWYHKDBN";
	}
	
	// get the length in a variable, so that we don't have to convert every time...
	s = CFSwapInt32BigToHost(signature->seqLength);
	
	// read the sequence into a data object
	NSData *seqdata = [data subdataWithRange:NSMakeRange(sizeof(MACVECTOR_HEADER),s)];

	//	Now I need to read the data bytes
	//seqBuffer = malloc(s);
	seqBuffer = (unsigned char *)[seqdata bytes];
	for (i = 0; i < s; i++)
	{
		//	append each character
		[sequenceString appendFormat:@"%c", [alphabet characterAtIndex:seqBuffer[i]]];
	}

	/* 
		What follows is copied from the method above, readGCKFile
		I've only commented lines that have to do with reading
		annotations.
	*/
	
	if ([sequenceString length])
	{
		newSequence = [BCSequence sequenceWithString: sequenceString];
		
		[result addSequence: newSequence];
	}
	
	free(signature);

	return result;
}


-(BCSequenceArray *)readClustalFile:(NSString *)entryString
{
/*
	The clustal format can have a sequence that is displayed over several lines, each starting with an identifier:

	CLUSTAL_FORMAT W(1.60) multiple sequence alignment


	JC2395          NVSDVNLNK---YIWRTAEKMK---ICDAKKFARQHKIPESKIDEIEHNSPQDAAE----
	KPEL_DROME      MAIRLLPLPVRAQLCAHLDAL-----DVWQQLATAVKLYPDQVEQISSQKQRGRS-----
	FASA_MOUSE      NASNLSLSK---YIPRIAEDMT---IQEAKKFARENNIKEGKIDEIMHDSIQDTAE----


	JC2395          -------------------------QKIQLLQCWYQSHGKT--GACQALIQGLRKANRCD
	KPEL_DROME      -------------------------ASNEFLNIWGGQYN----HTVQTLFALFKKLKLHN
	FASA_MOUSE      -------------------------QKVQLLLCWYQSHGKS--DAYQDLIKGLKKAECRR


	JC2395          IAEEIQAM
	KPEL_DROME      AMRLIKDY
	FASA_MOUSE      TLDKFQDM

	so the algorithm is:

	scan name, until space. scan sequencestring
	store name-sequence pair in a dictionary
	scan next line, if key exists, append string, otherwise, add new key-value pair

	If done, gone through dictionary, and extract the name and sequence
	make BCSequence, and add name as an attribute

	store BCSequence in array to return
*/

	int					i;
	NSString			*line, *name, *sequenceString, *tempString;
	NSMutableArray		*linesArray;
	NSScanner			*lineScanner;
	BCSequence			*newSequence;
	NSCharacterSet		*alignmentSet, *symbolSet;
	BCSequenceArray		*result;
	NSMutableDictionary	*sequenceDictionary;
	NSRange				sequenceRange;
	
	alignmentSet = [NSCharacterSet characterSetWithCharactersInString: @"*:."];
	symbolSet = [[NSCharacterSet whitespaceCharacterSet] invertedSet];	// or actually all BCSymbolSets!
	sequenceDictionary = [NSMutableDictionary dictionary];
	
	result = [[BCSequenceArray alloc] init];
	linesArray = [entryString splitLines];

 // remove empty lines
    for (i = [linesArray count] - 1; i >= 0 ; i--)
	{
        if ([[linesArray objectAtIndex: i] isEqualTo: @""])
		{
            [linesArray removeObjectAtIndex: i];
        }
    }

 // since this is an alignment, we need to determine where the first whitespace is that belongs to the sequence
 	
	for (i = 1; i < [linesArray count]; i++)
	{
		line = [linesArray objectAtIndex: i];
		
	 // we now have the first sequence line, let's determine where the sequence starts.
		
	 // first scan past the name
		lineScanner = [NSScanner scannerWithString: line];
		[lineScanner scanUpToString:@" " intoString: nil];
		
	 // put the left-over in a tempstring
		tempString = [line substringFromIndex: [lineScanner scanLocation]];
		
	 // now check where the first non-whitecharacter is
		sequenceRange = [tempString rangeOfCharacterFromSet: symbolSet];
		
	 // add the scanLocation - this is where the sequence starts
		sequenceRange.location += [lineScanner scanLocation];
		
	 // found it, no need to continue	
		break;
	}

	for (i = 1; i < [linesArray count]; i++)
	{
		line = [linesArray objectAtIndex:i];
		
	 // scan the name   
		lineScanner = [NSScanner scannerWithString: line];
		[lineScanner scanUpToString: @" " intoString: &name];
		
	 // the rest of the line after the whitespace is the sequence
		sequenceString = [line substringFromIndex: sequenceRange.location];
		
	 // make sure we actually have a string
		if ( [sequenceString length])
		{
			// if it's the alignment line, name it "alignment"
			if ( [sequenceString stringContainsCharactersFromSet: alignmentSet] )
			{
				name = [NSString stringWithString: @"alignment"];
			}
			
			if ( [sequenceDictionary objectForKey: name] )
			{
				tempString = (NSMutableString*)[[sequenceDictionary objectForKey: name]
								stringByAppendingString:sequenceString];
				
				[sequenceDictionary setObject: tempString forKey: name];				
			}
			else
			{
				[sequenceDictionary setObject: sequenceString forKey: name];				
			}
		}
	}

 // now replace the sequencestrings in the dictionary with BCSequenceObjects
	NSEnumerator *enumerator = [sequenceDictionary keyEnumerator];

	while ( (name = [enumerator nextObject]) )
	{
		sequenceString = [[sequenceDictionary objectForKey: name] stringByRemovingWhitespace];
		
		newSequence = [BCSequence sequenceWithString:sequenceString];
		[newSequence addAnnotation: [BCAnnotation annotationWithName: @"name" content: name]];
		
		[result addSequence: newSequence];
	}	

	return result;
}


-(BCSequenceArray *)readGDEFile:(NSString *)entryString
{
/*
	#sf170-A3

	atgggaccagagtctaaagccatgtgtaaagttaacccctctctgcgttactttaaattgtagccat-

	#br20-B1

	atgggatcaaagcctaaagccttgtgtaaagttaaccccactctgtgttactttaaattgcattgatttgaa
*/
	
	NSString		*line, *sequenceString;
	NSMutableArray	*linesArray, *annotationsArray;
	BCSequenceArray	*result;
	BCSequence		*newSequence;
	int				i, j;
	
	linesArray = [entryString splitLines];
	result = [[BCSequenceArray alloc] init];
	annotationsArray = [NSMutableArray array];
	
	sequenceString = @"";
	
 // remove empty lines
    for (i = [linesArray count] - 1; i >= 0 ; i--)
	{
        if ([[linesArray objectAtIndex: i] isEqualTo: @""])
		{
            [linesArray removeObjectAtIndex: i];
        }
    }

	for (i = 0; i < [linesArray count]; i++)
	{
		line = [linesArray objectAtIndex:i];

		if ([line hasPrefix: @"#"] )
		{
			[annotationsArray addObject:[BCAnnotation annotationWithName: @"name" content: line]];
			
			line = [linesArray objectAtIndex: ++i];

			sequenceString = @"";
			
			// until the next sequence
			while (![line hasPrefix: @"#"] )
			{
				sequenceString = [sequenceString stringByAppendingString: [line stringByRemovingWhitespace]];
				
				i++;
				
				if ( i < [linesArray count])
				{
					line = [linesArray objectAtIndex: i];
				}
				else
					break;
			}
				
			// we don't know what the sequence type is going to be, so we will let the
			// creation code figure that out
			newSequence = [BCSequence sequenceWithString: sequenceString];
			
			for (j = 0; j < [annotationsArray count]; j++)
			{
				[newSequence addAnnotation: [annotationsArray objectAtIndex:j]];
			}
			
			[result addSequence: newSequence];
			[annotationsArray removeAllObjects];
			
			i--;
		}
	}
	
	return result;
}

-(BCSequenceArray *)readPirFile:(NSString *)entryString
{
/*
	>P1;CRAB_ANAPL
	ALPHA CRYSTALLIN B CHAIN (ALPHA(B)-CRYSTALLIN).
	MDITIHNPLI RRPLFSWLAP SRIFDQIFGE HLQESELLPA SPSLSPFLMR 
	SPIFRMPSWL ETGLSEMRLE KDKFSVNLDV KHFSPEELKV KVLGDMVEIH 
	GKHEERQDEH GFIAREFNRK YRIPADVDPL TITSSLSLDG VLTVSAPRKQ 
	SDVPERSIPI TREEKPAIAG AQRK*

	>P1;CRAB_BOVIN
	ALPHA CRYSTALLIN B CHAIN (ALPHA(B)-CRYSTALLIN).
	MDIAIHHPWI RRPFFPFHSP SRLFDQFFGE HLLESDLFPA STSLSPFYLR 
	PPSFLRAPSW IDTGLSEMRL EKDRFSVNLD VKHFSPEELK VKVLGDVIEV 
	HGKHEERQDE HGFISREFHR KYRIPADVDP LAITSSLSSD GVLTVNGPRK 
	QASGPERTIP ITREEKPAVT AAPKK*
*/
 
	NSString		*line, *sequenceString;
	NSMutableArray	*linesArray, *annotationsArray;
	BCSequenceArray	*result;
	BCSequence		*newSequence;
	int				i, j;
	
	linesArray = [entryString splitLines];
	result = [[BCSequenceArray alloc] init];
	annotationsArray = [NSMutableArray array];
	
	sequenceString = @"";
	
 // remove empty lines
    for (i = [linesArray count] - 1; i >= 0 ; i--)
	{
        if ([[linesArray objectAtIndex: i] isEqualTo: @""])
		{
            [linesArray removeObjectAtIndex: i];
        }
    }

	for (i = 0; i < [linesArray count]; i++)
	{
		line = [linesArray objectAtIndex: i];
		
		if ([line hasPrefix: @">"] )
		{
			[annotationsArray addObject:[BCAnnotation annotationWithName: @"name" content: [line substringFromIndex: 4]]];
			line = [linesArray objectAtIndex: ++i];
			
			[annotationsArray addObject:[BCAnnotation annotationWithName: @"description" content: line]];
			line = [linesArray objectAtIndex: ++i];

			sequenceString = @"";
			
		 // until the next sequence
			while (![line hasPrefix: @">"] )
			{
				if ( [line hasSuffix: @"*"])
				{
					line = [line stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString: @"*"]];
				}
				
				sequenceString = [sequenceString stringByAppendingString: [line stringByRemovingWhitespace]];
				
				i++;
				
				if ( i < [linesArray count])
				{
					line = [linesArray objectAtIndex: i];
				}
				else
					break;
			} 
			
		 // we don't know what the sequence type is going to be, so we will let the
		 // creation code figure that out
			newSequence = [BCSequence sequenceWithString: sequenceString];
						
			for (j = 0; j < [annotationsArray count]; j++)
			{
				[newSequence addAnnotation: [annotationsArray objectAtIndex:j]];
			}
			
			[result addSequence: newSequence];
			[annotationsArray removeAllObjects];

			i--;
		}
	}
	
	return result;
}


-(BCSequenceArray *)readMSFFile:(NSString *)entryString
{
/*
	msf formatted multiple sequence files are most often created when using programs of the GCG suite. 
	msf files include the sequence name and the sequence itself, which is usually aligned with other sequences in the file.
	You can specify a single sequence or many sequences within an msf file.

	An example of part of an msf file, created using the GCG multiple sequence alignment program:

	!!AA_MULTIPLE_ALIGNMENT 1.0
	PileUp of: @hsp70.list

	Symbol comparison table: GenRunData:blosum62.cmp CompCheck: 6430

	GapWeight: 8
	GapLengthWeight: 2

	hsp70.msf MSF: 743 Type: P October 6, 1998 18:23 Check: 7784 ..

	Name: S11448 Len: 743 Check: 3635 Weight: 1.00
	Name: S06443 Len: 743 Check: 5861 Weight: 1.00
	Name: S29261 Len: 743 Check: 7748 Weight: 1.00

	//

	1                                                   50
	S11448 ~~~~~~~~~~ ~~~~~~~~~~ ~~~~~~MTFD GAIGIDLGTT YSCVGVWQNE
	S06443 ~~~~~~~~~~ ~~~~~~~~~~ ~~~~~~MTFD GAIGIDLGTT YSCVGVWQNE
	S29261 ~~~~~~~~~~ ~~~~~~~~~~ ~~~~~~~~MG KIIGIDLGTT NSCVAIMDGT

	Some of the hallmarks of a msf formatted sequence are the same as a single sequence gcg format file:

	Begins with the line (all uppercase) !!NA_MULTIPLE_ALIGNMENT 1.0 for nucleic acid sequences or !!AA_MULTIPLE_ALIGNMENT 1.0 for amino acid sequences. 
	Do not edit or delete the file type if its present.(optional)
	A description line which contains informative text describing what is in the file. 
	You can add this information to the top of the MSF file using a text editor.(optional)
	A dividing line which contains the number of bases or residues in the sequence, when the file was created, and importantly, two dots (..) 
	which act as a divider between the descriptive information and the following sequence information.(required)

	msf files contain some other information as well:

	Name/Weight: The name of each sequence included in the alignment, as well as its length and checksum (both non-editable) and weight (editable).(required)
	Separating Line. Must include two slashes (//) to divide the name/weight information from the sequence alignment.(required)
	Multiple Sequence Alignment. Each sequence named in the above Name/Weight lines is included. The alignment allows you to view the relationship among sequences. 
											
*/											

	BCSequenceArray	*result = nil;
	
	return result;
}


-(BCSequenceArray *)readPhylipFile:(NSString *)entryString
{
/*
	The first line of the input file contains the number of species and the number of characters separated by blanks. 
	The information for each species follows, starting with a ten-character species name (which can include punctuation marks and blanks), 
	and continuing with the characters for that species. 
	Phylip format files can be interleaved, as in the example below, or sequential.
	More information about phylip format is available from the authors at University of Washington. An example phylip format file:
 
	5 100
	Rabbit    ?????????? ?????????C CAATCTACAC ACGGG-GTAG GGATTACATA
	Human     AGCCACACCC TAGGGTTGGC CAATCTACTC CCAGGAGCAG GGAGGGCAGG
	Opossum   AGCCACACCC CAACCTTAGC CAATAGACAT CCAGAAGCCC AAAAGGCAAG
	Chicken   GCCCGGGGAA GAGGAGGGGC CCGGCGG-AG GCGATAAAAG TGGGGACACA
	Frog      GGATGGAGAA TTAGAGCACT TGTTCTTTTT GCAGAAGCTC AGAATAAACG

	TTTGGATGGT AG---GATAT GGGCCTACCA TGGCGTTAAC GGGT-AACGY
	TTTCGACGGT AA---GGTAT TGGCTTACCG TGGCAATGAC AGGT-GACGG
	TTTCGACGGT AA---GGTAT TGGCTTACCG TGGCAATGAC AGGT-GACGY
	TTTCGACGGT AA---GGTAT TGGCTTACCG TGGCAATGAC AGGT-GACGG
	TTTCGATGGT AA---GGTAT TGGCTTACCG TGGCAATGAC AGGT-GACGG
*/
 	 
	NSString		*line, *sequenceString, *firstLine;
	NSMutableArray	*linesArray, *annotationsArray, *namesArray, *sequenceArray;
	NSScanner		*lineScanner;
	BCSequenceArray	*result;
	BCSequence		*newSequence;
	int				i, j, numSequences, sequenceIndex;	

	linesArray = [entryString splitLines];
	result = [[BCSequenceArray alloc] init];
	annotationsArray = [NSMutableArray array];
	namesArray = [NSMutableArray array];
	sequenceArray = [NSMutableArray array];
	
	sequenceString = @"";
	
 // remove empty lines
    for (i = [linesArray count] - 1; i >= 0 ; i--)
	{
        if ([[linesArray objectAtIndex: i] isEqualTo: @""])
		{
            [linesArray removeObjectAtIndex: i];
        }
    }
	
	firstLine = [linesArray objectAtIndex: 0];
	lineScanner = [NSScanner scannerWithString: firstLine];
	[lineScanner scanInt: &numSequences];
	
	j = 0;
	
	for ( i = 1; i < [linesArray count]; i++)
	{		
		if ( i <= numSequences )
		{
			line = [linesArray objectAtIndex: i];
			
			[namesArray	addObject: [line substringToIndex: 9]];
			[sequenceArray addObject: [[line substringFromIndex: 10] stringByRemovingWhitespace]];
		}
		else
		{
			line = [linesArray objectAtIndex: i];

			sequenceIndex = i - ( j * numSequences ) - 1;
			sequenceString = [sequenceArray objectAtIndex: sequenceIndex];
			sequenceString = [sequenceString stringByAppendingString: [line stringByRemovingWhitespace]];
			[sequenceArray replaceObjectAtIndex: sequenceIndex withObject: sequenceString];
		}

		if ( i % numSequences == 0 )
		{
			j++;
		}
	}

 // finally, populate the BCSequenceArray	
	for (i = 0; i < numSequences; i++)
	{
		newSequence = [BCSequence sequenceWithString: (NSString *)[sequenceArray objectAtIndex: i]];
		[newSequence addAnnotation: [BCAnnotation annotationWithName: @"name" content: (NSString *)[namesArray objectAtIndex: i]]];
		
		[result addSequence: newSequence];
	}
	
	return result;
}

 - (BCSequenceArray *)readRawFile:(NSString *)entryString
 {
	NSString		*line, *sequenceString;
	NSMutableArray	*linesArray;
	BCSequenceArray	*result;
	BCSequence		*newSequence;
	int				i;	

	linesArray = [entryString splitLines];
	result = [[BCSequenceArray alloc] init];

	sequenceString = @"";

	// remove empty lines
	for (i = [linesArray count] - 1; i >= 0 ; i--)
	{
		if ([[linesArray objectAtIndex: i] isEqualTo: @""])
		{
			[linesArray removeObjectAtIndex: i];
		}
	}

	for (i = 1; i < [linesArray count]; i++)
	{
		line = [linesArray objectAtIndex: i];
		sequenceString = [sequenceString stringByAppendingString: [line stringByRemovingWhitespace]];
	}

	newSequence = [BCSequence sequenceWithString: sequenceString];
	[result addSequence: newSequence];

	return result;
 }



// TO BE CONVERTED TO BCSEQUENCEARRAY FORMAT:
/*
 
 - (NSDictionary *)readNexusFile:(NSString *)textFile
 {
	 Nexus interleaved format, also known as PAUP format is the default output for the PAUP suite of phylogeny programs 
	 and is designed to represent DNA sequence only. 
	 The entry is headed by the #NEXUS comment line followed on the next line by the application and creation date. 
	 There is a blank line between this information and the start of the sequence data including the number of sequences 
	 (in this case 1), length, datatype and representation on missing bases (n) and gaps (-). 
	 Each of these information lines is ended with a semi-colon (;). 
	 A further blank line separates this information from the matrix comment. 
	 The sequence is represented on the succeeding lines starting with the sequence identifier and a block of 50 bases. 
	 The end of the sequence is denoted by a semi-colon (;). There follows a blank line and further comment lines ending with a semi-colon (;).
	
	#NEXUS
		 [TITLE: Written by EMBOSS 28/06/04]
		 
		 begin data;
		 dimensions ntax=1 nchar=450;
		 format interleave datatype=DNA missing=N gap=-;
		 
		 matrix
			 BT006818             atggctgatcagctgaccgaagaacagattgctgaattcaaggaagcctt
			 
			 BT006818             ctccctatttgataaagatggcgatggcaccatcacaacaaaggaacttg
			 
			 BT006818             gaactgtcatgaggtcactgggtcagaacccaacagaagctgaattgcag
			 
			 BT006818             gatatgatcaatgaagtggatgctgatggtaatggcaccattgacttccc
			 
			 BT006818             cgaatttttgactatgatggctagaaaaatgaaagatacagatagtgaag
			 
			 BT006818             aagaaatccgtgaggcattccgagtctttgacaaggatggcaatggttat
			 
			 BT006818             atcagtgcagcagaactacgtcacgtcatgacaaacttaggagaaaaact
			 
			 BT006818             aacagatgaagaagtagatgaaatgatcagagaagcagatattgatggag
			 
			 BT006818             acggacaagtcaactatgaagaattcgtacagatgatgactgcaaaatag
			 ;
		 
		 end;
		 begin assumptions;
		 options deftype=unord;
		 end;
		 
	int i;
	 NSScanner *matrixScanner, *itemScanner, *commentScanner, *treeScanner;
	 NSString *comments = @"";
	 NSString *treeString = @"";
	 NSString *stringWithMacLineBreaks;
	 NSMutableString *item, *sequence, *tempSequence, *matrix, *bracketsString;
	 NSMutableArray *linesArray, *bracketsArray;
	 NSMutableDictionary *matrixDictionary = [NSMutableDictionary dictionary];
	 NSMutableDictionary *nexusDictionary = [NSMutableDictionary dictionary];
	 NSMutableArray *itemArray = [NSMutableArray arrayWithCapacity:10];
	 NSMutableArray *treesArray = [NSMutableArray arrayWithCapacity:10];
	 
	 //Extract the Nexus file's main comments
	 commentScanner = [[NSScanner alloc] initWithString:textFile];
	 [commentScanner scanUpToString:@"[!" intoString:nil];
	 [commentScanner scanString:@"[!" intoString:nil];
	 [commentScanner scanUpToString:@"]" intoString:&comments];
	 [commentScanner release];
	 //Put the comments in the nexusDictionary
	 if (![comments isEqualTo:@""]) {
		 [nexusDictionary setObject:comments forKey:@"comments"];
	 }
	 
	 
	 //Check whether a treeblock exists and extract it
	 if ([textFile rangeOfString:@"begin trees;" options:NSCaseInsensitiveSearch||NSBackwardsSearch].length != 0) {
		 treeScanner = [[NSScanner alloc] initWithString:textFile];
		 [treeScanner scanUpToString:@"begin trees;" intoString:nil];
		 [treeScanner scanString:@"begin trees;" intoString:nil];
		 [treeScanner scanUpToString:@"end;" intoString:&treeString];
		 [treeScanner release];
		 treesArray = [NSMutableArray arrayWithArray:[treeString componentsSeparatedByString:@";"]];
		 //Put the trees in the treesArray
		 if ([treesArray count] > 0) {
			 [treesArray removeObjectAtIndex:0];
			 [treesArray removeObjectAtIndex:[treesArray count]-1];
			 //NSLog(@"%@", treesArray);
			 [nexusDictionary setObject:treesArray forKey:@"trees"];
		 }
	 }
	 
	 
	 //Remove other comments (in sequences) between the []
	 bracketsString = [NSMutableString stringWithString:textFile];
	 [bracketsString replaceOccurrencesOfString:@"[" withString:@"!!!*" options:NULL range:NSMakeRange(0, [bracketsString length])];
	 [bracketsString replaceOccurrencesOfString:@"]" withString:@"!!!" options:NULL range:NSMakeRange(0, [bracketsString length])];
	 bracketsArray = (NSMutableArray *)[bracketsString componentsSeparatedByString:@"!!!"];
	 for (i = 0; i < [bracketsArray count]; i++) {
		 if ([[bracketsArray objectAtIndex:i]hasPrefix:@"*"]){
			 [bracketsArray removeObjectAtIndex:i];
		 }
	 }
	 matrix = (NSMutableString *)[bracketsArray componentsJoinedByString:@""];
	 
	 
	 //Isolate the matrix
	 matrixScanner = [[NSScanner alloc] initWithString:matrix];
	 [matrixScanner scanUpToString:@"matrix" intoString:nil];
	 [matrixScanner scanUpToString:@";" intoString:&matrix];
	 [matrixScanner release];
	 
	 
	 //Convert all line breaks to Mac line breaks (\r)
	 stringWithMacLineBreaks = [self convertLineBreaksToMac:matrix];
	 //Isolate individual lines based on \r
	 linesArray = (NSMutableArray *)[stringWithMacLineBreaks componentsSeparatedByString:@"\r"];
	 
	 
	 //Trim lines from surrounding whitespaces and remove empty lines
	 for (i = 0; i < [linesArray count]; i++) {
		 [linesArray insertObject:[[linesArray objectAtIndex:i]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] atIndex:i];
		 [linesArray removeObjectAtIndex:i+1];
		 if ([[linesArray objectAtIndex:i]isEqualTo:@""]) {
			 [linesArray removeObjectAtIndex:i];
			 i--;
		 }
	 }
	 
	 
	 //Read item names and sequences and put them in the matrixDictionary
	 for (i = 1; i < [linesArray count]; i++) {
		 itemScanner = [[NSScanner alloc] initWithString:[linesArray objectAtIndex:i]];
		 [itemScanner scanUpToString:@" " intoString:&item];
		 sequence = (NSMutableString *)[[linesArray objectAtIndex:i]substringFromIndex:[itemScanner scanLocation]];
		 
		 if ([matrixDictionary objectForKey:item]) {	//If the item already exists
			 tempSequence = [NSMutableString stringWithString:[[matrixDictionary objectForKey:item] stringByAppendingString:sequence]];
			 [matrixDictionary setObject:tempSequence forKey:item];
			 
		 }
		 else {						//If the item does not yet exist
			 [matrixDictionary setObject:sequence forKey:item];
			 [itemArray addObject:item]; //Put the item name in the itemArray
		 }
		 [itemScanner release];
	 }
	 
	 
	 //Remove spaces and tabs from the sequences in the matrixDictionary
	 for (i = 0; i < [itemArray count]; i++) {
		 tempSequence = [NSMutableString stringWithString:[matrixDictionary objectForKey:[itemArray objectAtIndex:i]]];
		 [tempSequence replaceOccurrencesOfString:@" " withString:@"" options:NULL range:NSMakeRange(0, [tempSequence length])];
		 [tempSequence replaceOccurrencesOfString:@"\t" withString:@"" options:NULL range:NSMakeRange(0, [tempSequence length])];
		 [matrixDictionary setObject:tempSequence forKey:[itemArray objectAtIndex:i]];
	 }
	 
	 //Put the matrixDictionary and the items Array in the nexusDictionary
	 [nexusDictionary setObject:matrixDictionary forKey:@"matrix"];
	 [nexusDictionary setObject:itemArray forKey:@"items"];
	 [nexusDictionary setObject:@"nexus" forKey:@"fileType"];
	 
	 return nexusDictionary;
 }
 
 
 - (NSDictionary *)readNexusFileAndBlocks:(NSString *)textFile
 {
	 int i;
	 NSMutableDictionary *dict;
	 NSScanner *scanner;
	 NSArray *blocksArray;
	 NSString *blockName, *blockContents;
	 NSMutableDictionary *blocksDictionary = [NSMutableDictionary dictionary];
	 dict = (NSMutableDictionary*)[self readNexusFile:textFile];
	 
	 //Separate every block
	 blocksArray = [textFile componentsSeparatedByString:@"BEGIN "];
	 //Use the block name as the key and the contents as the value
	 for (i = 1; i < [blocksArray count]; i++) {
		 scanner = [[NSScanner alloc] initWithString:[blocksArray objectAtIndex:i]];
		 [scanner scanUpToString:@";" intoString:&blockName];
		 [scanner scanUpToString:@"end;" intoString:&blockContents];
		 [scanner release];
		 [blocksDictionary setObject:blockContents forKey:blockName];
	 }
	 [dict setObject:blocksDictionary forKey:@"blocks"];
	 return dict;
 }

 - (NSDictionary *)readNonaFile:(NSString *)textFile
 {
	 int i, j;
	 NSScanner *itemScanner;
	 NSString *stringWithMacLineBreaks;
	 NSMutableString *item, *sequence, *tempSequence;
	 NSMutableArray *linesArray;
	 NSMutableDictionary *matrixDictionary = [NSMutableDictionary dictionary];
	 NSMutableDictionary *phylipDictionary = [NSMutableDictionary dictionary];
	 NSMutableArray *itemArray = [NSMutableArray arrayWithCapacity:10];
	 j = 0;
	 
	 //Convert all line breaks to Mac line breaks (\r)
	 stringWithMacLineBreaks = [self convertLineBreaksToMac:textFile];
	 //Isolate individual lines based on \r
	 linesArray = (NSMutableArray*)[stringWithMacLineBreaks componentsSeparatedByString:@"\r"];
	 
	 //Remove empty lines
	 for (i = 0; i < [linesArray count]; i++) {
		 NSString *string = [linesArray objectAtIndex:i];
		 if ((![string stringContainsOneSpace] && [string length] < 20) || [string isEqualToString:@""] || [string stringBeginsWithTwoNumbers] || [string stringContainsHyphen]) {
			 [linesArray removeObjectAtIndex:i];
			 i--;
		 }
	 }
	 
	 //Read item names and sequences and put them in the matrixDictionary.
	 for (i = 0; i < [linesArray count]; i++) {
		 
		 if ([[linesArray objectAtIndex:i] hasPrefix:@" "]) {	//If the item name is not present
			 sequence = [linesArray objectAtIndex:i];
			 tempSequence = (NSMutableString*)[[matrixDictionary objectForKey:[itemArray objectAtIndex:j]] stringByAppendingString:sequence];
			 [matrixDictionary setObject:tempSequence forKey:[itemArray objectAtIndex:j]];
			 j++;
			 
			 if (j == [itemArray count]) { j = 0;}
		 }
		 else {							//If the item name precedes the sequence
			 itemScanner = [[NSScanner alloc] initWithString:[linesArray objectAtIndex:i]];
			 [itemScanner scanUpToString:@" " intoString:&item];
			 sequence = (NSMutableString*)[[linesArray objectAtIndex:i]substringFromIndex:[itemScanner scanLocation]];
			 [matrixDictionary setObject:sequence forKey:item];
			 [itemArray addObject:item];
			 //NSLog(@"Adding item %@", item);
			 [itemScanner release];
		 }
	 }
	 
	 //Remove spaces and tabs from the sequences in the matrixDictionary
	 for (i = 0; i < [itemArray count]; i++) {
		 tempSequence = [NSMutableString stringWithString:[matrixDictionary objectForKey:[itemArray objectAtIndex:i]]];
		 [tempSequence replaceOccurrencesOfString:@" " withString:@"" options:(unsigned)NULL range:NSMakeRange(0, [tempSequence length])];
		 [tempSequence replaceOccurrencesOfString:@"\t" withString:@"" options:(unsigned)NULL range:NSMakeRange(0, [tempSequence length])];
		 [matrixDictionary setObject:tempSequence forKey:[itemArray objectAtIndex:i]];
	 }
	 
	 //Put the matrixDictionary and the items Array in the nonaDictionary
	 [phylipDictionary setObject:matrixDictionary forKey:@"matrix"];
	 [phylipDictionary setObject:itemArray forKey:@"items"];
	 [phylipDictionary setObject:@"Nona" forKey:@"fileType"];
	 
	 return phylipDictionary;
 }
 
 
 - (NSDictionary *)readHennigFile:(NSString *)textFile
 {

 Designed for DNA data, the Hennig86 format translates each base into a number where A = 0; T = 1; G = 2; C =3. 
 The start is denoted by the comment xread and is followed on a separate line
 by the application and creation date of the file enclosed in single quotes separated from the text by whitespace. 
 A separate line records the sequence length and number of sequence files represented (in this case 1). 
 Immediately below this line is the identifier line and below this the sequence in numerical form. 
 The end of the entry is denoted by a semi-colon (;). The entire sequence is displayed on a single line.
 
 xread
 ' Written by EMBOSS 28/06/04 '
 450 1
 BT006818
 012231201302312033200200302011231200113002200233113133310111201000201223201223033013030030002200311220031213012022130312221302003330030200231200112302201012013001200212201231201221001223033011203113333200111112031012012231020000012000201030201021200200200013321202230113320213111203002201223001221101013021230230200310321303213012030003110220200000310030201200200210201200012013020200230201011201220203220300213003101200200113210302012012031230000102
 ;

	 int i, j;
	 NSScanner *itemScanner;
	 NSString *stringWithMacLineBreaks;
	 NSMutableString *item, *sequence, *tempSequence;
	 NSMutableArray *linesArray;
	 NSMutableDictionary *matrixDictionary = [NSMutableDictionary dictionary];
	 NSMutableDictionary *phylipDictionary = [NSMutableDictionary dictionary];
	 NSMutableArray *itemArray = [NSMutableArray arrayWithCapacity:10];
	 j = 0;
	 
	 //Convert all line breaks to Mac line breaks (\r)
	 stringWithMacLineBreaks = [self convertLineBreaksToMac:textFile];
	 //Isolate individual lines based on \r
	 linesArray = (NSMutableArray*)[stringWithMacLineBreaks componentsSeparatedByString:@"\r"];
	 
	 //Remove empty lines
	 for (i = 0; i < [linesArray count]; i++) {
		 NSString *string = [linesArray objectAtIndex:i];
		 if ((![string stringContainsOneSpace] && [string length] < 20) || [string isEqualToString:@""] || [string stringBeginsWithTwoNumbers] || [string stringContainsHyphen]) {
			 [linesArray removeObjectAtIndex:i];
			 i--;
		 }
	 }
	 
	 //Read item names and sequences and put them in the matrixDictionary.
	 for (i = 0; i < [linesArray count]; i++) {
		 
		 if ([[linesArray objectAtIndex:i] hasPrefix:@" "]) {	//If the item name is not present
			 sequence = [linesArray objectAtIndex:i];
			 tempSequence = (NSMutableString*)[[matrixDictionary objectForKey:[itemArray objectAtIndex:j]] stringByAppendingString:sequence];
			 [matrixDictionary setObject:tempSequence forKey:[itemArray objectAtIndex:j]];
			 j++;
			 
			 if (j == [itemArray count]) { j = 0;}
		 }
		 else {							//If the item name precedes the sequence
			 itemScanner = [[NSScanner alloc] initWithString:[linesArray objectAtIndex:i]];
			 [itemScanner scanUpToString:@" " intoString:&item];
			 sequence = (NSMutableString*)[[linesArray objectAtIndex:i]substringFromIndex:[itemScanner scanLocation]];
			 [matrixDictionary setObject:sequence forKey:item];
			 [itemArray addObject:item];
			 //NSLog(@"Adding item %@", item);
			 [itemScanner release];
		 }
	 }
	 
	 //Remove spaces and tabs from the sequences in the matrixDictionary
	 for (i = 0; i < [itemArray count]; i++) {
		 tempSequence = [NSMutableString stringWithString:[matrixDictionary objectForKey:[itemArray objectAtIndex:i]]];
		 [tempSequence replaceOccurrencesOfString:@" " withString:@"" options:(unsigned)NULL range:NSMakeRange(0, [tempSequence length])];
		 [tempSequence replaceOccurrencesOfString:@"\t" withString:@"" options:(unsigned)NULL range:NSMakeRange(0, [tempSequence length])];
		 [matrixDictionary setObject:tempSequence forKey:[itemArray objectAtIndex:i]];
	 }
	 
	 //Put the matrixDictionary and the items Array in the nonaDictionary
	 [phylipDictionary setObject:matrixDictionary forKey:@"matrix"];
	 [phylipDictionary setObject:itemArray forKey:@"items"];
	 [phylipDictionary setObject:@"Hennig86" forKey:@"fileType"];
	 
	 return phylipDictionary;
 }
*/ 

@end
