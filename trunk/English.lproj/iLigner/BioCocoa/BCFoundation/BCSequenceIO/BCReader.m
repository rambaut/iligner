#import "BCReader.h"
#import "../BCUtils/BCUtilStrings.h"


@implementation BCReader


- (NSDictionary *)readFile:(NSString *)textFile
{
    NSMutableDictionary *theContents;
    NSString *lineBreak;
	
    lineBreak = [self detectLineBreak:textFile];
	
    if ([textFile hasCaseInsensitivePrefix:@"#NEXUS"] || [textFile hasCaseInsensitivePrefix:@"#PAUP"])
    {
        theContents =  (NSMutableDictionary*) [self readNexusFileAndBlocks:textFile];
    }
    else if ([textFile hasCaseInsensitivePrefix:@"CLUSTAL"])
    {
        theContents =  (NSMutableDictionary*) [self readClustalFile:textFile];
    }
    else if ([textFile hasCaseInsensitivePrefix:@"Pileup"])
    {
        theContents =  (NSMutableDictionary*) [self readMSFFile:textFile];
    }
    else if ([textFile hasCaseInsensitivePrefix:@">DL"])
    {
        theContents =  (NSMutableDictionary*) [self readPirFile:textFile];
    }
    else if ([textFile hasPrefix:@">"])
    {
        theContents =  (NSMutableDictionary*) [self readFastaFile:textFile];
    }
    else if ([textFile hasPrefix:@"HEADER"])
    {
        theContents =  (NSMutableDictionary*) [self readPDBFile:textFile];
    }
    else if ([textFile hasPrefix:@"LOCUS"])
    {
        theContents =  (NSMutableDictionary*) [self readNCBIFile:textFile];
    }
    else if ([textFile hasPrefix:@"#"])
    {
        theContents = (NSMutableDictionary*)  [self readGDEFile:textFile];
    }
    else if ([textFile hasPrefix:@"ID"])	// also works for EMBL files, both have the same prefix in the first line
    {
        theContents =  (NSMutableDictionary*) [self readSwissProtFile:textFile];
    }
    else if ([textFile stringBeginsWithTwoNumbers])	
	{
        theContents =  (NSMutableDictionary*) [self readPhylipFile:textFile];
    }
	else
	{
		return nil;		// should we have a error message here?
	}
	
    [theContents setObject:lineBreak forKey:@"lineBreak"];
    
	return theContents;
}


- (NSDictionary *)readPhylipFile:(NSString *)textFile
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
        if ([(NSString *)[linesArray objectAtIndex:i]length] < 1 || [[linesArray objectAtIndex:i] isEqualTo:@""]) {
            [linesArray removeObjectAtIndex:i];
            i--;
        }
    }

    //Read item names and sequences and put them in the matrixDictionary. We can ignore the first line.
    for (i = 1; i < [linesArray count]; i++) {

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
        [tempSequence replaceOccurrencesOfString:@" " withString:@"" options:NULL range:NSMakeRange(0, [tempSequence length])];
        [tempSequence replaceOccurrencesOfString:@"\t" withString:@"" options:NULL range:NSMakeRange(0, [tempSequence length])];
        [matrixDictionary setObject:tempSequence forKey:[itemArray objectAtIndex:i]];
    }

    //Put the matrixDictionary and the items Array in the phylipDictionary
    [phylipDictionary setObject:matrixDictionary forKey:@"matrix"];
    [phylipDictionary setObject:itemArray forKey:@"items"];
    [phylipDictionary setObject:@"phylip" forKey:@"fileType"];

    return phylipDictionary;
}



- (NSDictionary *)readPirFile:(NSString *)textFile
{
    int i;
    NSScanner *itemScanner;
    NSString *stringWithMacLineBreaks;
    NSMutableString *item, *sequence, *tempSequence;
    NSMutableArray *linesArray;
    NSMutableDictionary *matrixDictionary = [NSMutableDictionary dictionary];
    NSMutableDictionary *pirDictionary = [NSMutableDictionary dictionary];
    NSMutableArray *itemArray = [NSMutableArray arrayWithCapacity:10];

    //Convert all line breaks to Mac line breaks (\r)
    stringWithMacLineBreaks = [self convertLineBreaksToMac:textFile];

    //Isolate individual lines based on >DL;
    linesArray = (NSMutableArray*)[textFile componentsSeparatedByString:@">DL;"];

    //Trim lines from surrounding whitespaces and remove empty lines
    for (i = [linesArray count]-1; i >= 0 ; i--) {
        [linesArray insertObject:[[linesArray objectAtIndex:i]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] atIndex:i];
        [linesArray removeObjectAtIndex:i+1];
        if ([[linesArray objectAtIndex:i]isEqualTo:@""]) {
            [linesArray removeObjectAtIndex:i];
        }
    }


    //Read item names and sequences and put them in the matrixDictionary
    for (i = 0; i < [linesArray count]; i++) {
        itemScanner = [[NSScanner alloc] initWithString:[linesArray objectAtIndex:i]];
        [itemScanner scanUpToString:@"\r" intoString:&item];
        [itemScanner scanUpToString:@"\r" intoString:NULL];  //there is an additional line of information containing a textual description before the sequence begins, not sure how to store with sequence
        sequence = (NSMutableString*)[[linesArray objectAtIndex:i]substringFromIndex:[itemScanner scanLocation]];
        [matrixDictionary setObject:sequence forKey:item];
        [itemArray addObject:item];
        [itemScanner release];
    }


    //Remove spaces, carriage returns and * from the sequences in the matrixDictionary
    for (i = 0; i < [itemArray count]; i++) {
        tempSequence = [NSMutableString stringWithString:[matrixDictionary objectForKey:[itemArray objectAtIndex:i]]];
        [tempSequence replaceOccurrencesOfString:@" " withString:@"" options:NULL range:NSMakeRange(0, [tempSequence length])];
        [tempSequence replaceOccurrencesOfString:@"*" withString:@"" options:NULL range:NSMakeRange(0, [tempSequence length])];
        [tempSequence replaceOccurrencesOfString:@"\r" withString:@"" options:NULL range:NSMakeRange(0, [tempSequence length])];
        [matrixDictionary setObject:tempSequence forKey:[itemArray objectAtIndex:i]];
    }

    //Put the matrixDictionary and the items Array in the fastaDictionary
    [pirDictionary setObject:matrixDictionary forKey:@"matrix"];
    [pirDictionary setObject:itemArray forKey:@"items"];
    [pirDictionary setObject:@"pir" forKey:@"fileType"];

    return pirDictionary;
}




- (NSDictionary *)readFastaFile:(NSString *)textFile
{
    int i;
    NSMutableArray *linesArray;
    NSMutableDictionary *matrixDictionary = [NSMutableDictionary dictionary];
    NSMutableDictionary *fastaDictionary = [NSMutableDictionary dictionary];
    NSMutableArray *itemArray = [NSMutableArray arrayWithCapacity:10];

#if 0
    NSMutableString *item, *sequence, *tempSequence;
    NSScanner *itemScanner;
    NSString *stringWithMacLineBreaks;

    //Convert all line breaks to Mac line breaks (\r)
    stringWithMacLineBreaks = [self convertLineBreaksToMac:textFile];

    //Isolate individual lines based on >
    linesArray = (NSMutableArray*)[textFile componentsSeparatedByString:@">"];

    //Trim lines from surrounding whitespaces and remove empty lines
    for (i = [linesArray count]; i = 0 ; i--) {
        if ([[linesArray objectAtIndex:i]isEqualTo:@""]) {
            [linesArray removeObjectAtIndex:i];
        }
        [linesArray insertObject:[[linesArray objectAtIndex:i]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] atIndex:i];
        [linesArray removeObjectAtIndex:i+1];
    }


    //Read item names and sequences and put them in the matrixDictionary
    for (i = 1; i < [linesArray count]; i++) {
        itemScanner = [[NSScanner alloc] initWithString:[linesArray objectAtIndex:i]];
        [itemScanner scanUpToString:@"\r" intoString:&item];
        sequence = (NSMutableString*)[[linesArray objectAtIndex:i]substringFromIndex:[itemScanner scanLocation]];
        [matrixDictionary setObject:sequence forKey:item];
        [itemArray addObject:item];
        [itemScanner release];
    }


    //Remove spaces, carriage returns and tabs from the sequences in the matrixDictionary
    for (i = 0; i < [itemArray count]; i++) {
        tempSequence = [NSMutableString stringWithString:[matrixDictionary objectForKey:[itemArray objectAtIndex:i]]];
        [tempSequence replaceOccurrencesOfString:@" " withString:@"" options:NULL range:NSMakeRange(0, [tempSequence length])];
        [tempSequence replaceOccurrencesOfString:@"\t" withString:@"" options:NULL range:NSMakeRange(0, [tempSequence length])];
        [tempSequence replaceOccurrencesOfString:@"\r" withString:@"" options:NULL range:NSMakeRange(0, [tempSequence length])];
        [matrixDictionary setObject:tempSequence forKey:[itemArray objectAtIndex:i]];
    }

#else

	NSString	*line, *item, *sequence;
	
	linesArray = [textFile splitLines];
	
    for (i = 0; i < [linesArray count]; i++)
	{
		line = [linesArray objectAtIndex: i];
		
		if ([line hasPrefix: @">"] )
		{
			item = [line substringFromIndex:1];
			line = [linesArray objectAtIndex: ++i];
			
			sequence = @"";
			
			while (![line hasPrefix:@">"] )
			{			
				sequence = [sequence stringByAppendingString:[line stringByRemovingWhitespace]];
				
				i++;
				if ( i < [linesArray count])
					line = [linesArray objectAtIndex: i];
				else
					break;
			}
			
			[matrixDictionary setObject:sequence forKey:item];
			[itemArray addObject: item];
			
			i--;
		}
	}

#endif

    //Put the matrixDictionary and the items Array in the fastaDictionary
    [fastaDictionary setObject:matrixDictionary forKey:@"matrix"];
    [fastaDictionary setObject:itemArray forKey:@"items"];
    [fastaDictionary setObject:@"fasta" forKey:@"fileType"];

    return fastaDictionary;
}


- (NSDictionary *)readGDEFile:(NSString *)textFile
{
    int i;
    NSScanner *itemScanner;
    NSString *stringWithMacLineBreaks;
    NSMutableString *item, *sequence, *tempSequence;
    NSMutableArray *linesArray;
    NSMutableDictionary *matrixDictionary = [NSMutableDictionary dictionary];
    NSMutableDictionary *gdeDictionary = [NSMutableDictionary dictionary];
    NSMutableArray *itemArray = [NSMutableArray arrayWithCapacity:10];

    //Convert all line breaks to Mac line breaks (\r)
    stringWithMacLineBreaks = [self convertLineBreaksToMac:textFile];

    //Isolate individual lines based on #
    linesArray = (NSMutableArray*)[stringWithMacLineBreaks componentsSeparatedByString:@"#"];

    //Trim lines from surrounding whitespaces and remove empty lines
    for (i = [linesArray count]; i = 0 ; i--) {
        if ([[linesArray objectAtIndex:i]isEqualTo:@""]) {
            [linesArray removeObjectAtIndex:i];
        }
        [linesArray insertObject:[[linesArray objectAtIndex:i]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] atIndex:i];
        [linesArray removeObjectAtIndex:i+1];
    }


    //Read item names and sequences and put them in the matrixDictionary
    for (i = 1; i < [linesArray count]; i++) {
        itemScanner = [[NSScanner alloc] initWithString:[linesArray objectAtIndex:i]];
        [itemScanner scanUpToString:@"\r" intoString:&item];
        sequence = (NSMutableString*)[[linesArray objectAtIndex:i]substringFromIndex:[itemScanner scanLocation]];
        [matrixDictionary setObject:sequence forKey:item];
        [itemArray addObject:item];
        [itemScanner release];
    }


    //Remove spaces, carriage returns and tabs from the sequences in the matrixDictionary
    for (i = 0; i < [itemArray count]; i++) {
        tempSequence = [NSMutableString stringWithString:[matrixDictionary objectForKey:[itemArray objectAtIndex:i]]];
        [tempSequence replaceOccurrencesOfString:@" " withString:@"" options:NULL range:NSMakeRange(0, [tempSequence length])];
        [tempSequence replaceOccurrencesOfString:@"\t" withString:@"" options:NULL range:NSMakeRange(0, [tempSequence length])];
        [tempSequence replaceOccurrencesOfString:@"\r" withString:@"" options:NULL range:NSMakeRange(0, [tempSequence length])];
        [matrixDictionary setObject:tempSequence forKey:[itemArray objectAtIndex:i]];
    }

    //Put the matrixDictionary and the items Array in the fastaDictionary
    [gdeDictionary setObject:matrixDictionary forKey:@"matrix"];
    [gdeDictionary setObject:itemArray forKey:@"items"];
    [gdeDictionary setObject:@"gde" forKey:@"fileType"];

    return gdeDictionary;
}



- (NSDictionary *)readClustalFile:(NSString *)textFile
{
    int i;
    NSScanner *itemScanner;
    NSString *stringWithMacLineBreaks;
    NSMutableString *item, *sequence, *tempSequence;
    NSMutableArray *linesArray;
    NSMutableDictionary *matrixDictionary = [NSMutableDictionary dictionary];
    NSMutableDictionary *clustalDictionary = [NSMutableDictionary dictionary];
    NSMutableArray *itemArray = [NSMutableArray arrayWithCapacity:10];

    //Convert all line breaks to Mac line breaks (\r)
    stringWithMacLineBreaks = [self convertLineBreaksToMac:textFile];
    //Isolate individual lines based on \r
    linesArray = (NSMutableArray *)[stringWithMacLineBreaks componentsSeparatedByString:@"\r"];


    //Trim lines from surrounding whitespaces and remove empty lines
    for (i = 0; i < [linesArray count]; i++) {
        if ([[linesArray objectAtIndex:i]isEqualTo:@""] || [[linesArray objectAtIndex:i]hasPrefix:@"  "]) {
            [linesArray removeObjectAtIndex:i];
            i--;
        }
        [linesArray insertObject:[[linesArray objectAtIndex:i]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] atIndex:i];
        [linesArray removeObjectAtIndex:i+1];
    }


    //Read item names and sequences and put them in the matrixDictionary
    for (i = 1; i < [linesArray count]; i++) {
        itemScanner = [[NSScanner alloc] initWithString:[linesArray objectAtIndex:i]];
        [itemScanner scanUpToString:@" " intoString:&item];
        sequence = (NSMutableString*)[[linesArray objectAtIndex:i]substringFromIndex:[itemScanner scanLocation]];

        if ([matrixDictionary objectForKey:item]) {	//If the item already exists
            tempSequence = (NSMutableString*)[[matrixDictionary objectForKey:item] stringByAppendingString:sequence];
            [matrixDictionary setObject:tempSequence forKey:item];
        }
        else {						//If the item does not yet exist
            [matrixDictionary setObject:sequence forKey:item];
            [itemArray addObject:item];
        }
        [itemScanner release];
    }


    //Remove spaces and tabs from the sequences in the matrixDictionary
    //itemArray = [matrixDictionary allKeys];
    for (i = 0; i < [itemArray count]; i++) {
        tempSequence = [NSMutableString stringWithString:[matrixDictionary objectForKey:[itemArray objectAtIndex:i]]];
        [tempSequence replaceOccurrencesOfString:@" " withString:@"" options:NULL range:NSMakeRange(0, [tempSequence length])];
        [tempSequence replaceOccurrencesOfString:@"\t" withString:@"" options:NULL range:NSMakeRange(0, [tempSequence length])];
        [matrixDictionary setObject:tempSequence forKey:[itemArray objectAtIndex:i]];
    }

    //Put the matrixDictionary and the items Array in the clustalDictionary
    [clustalDictionary setObject:matrixDictionary forKey:@"matrix"];
    [clustalDictionary setObject:itemArray forKey:@"items"];
    [clustalDictionary setObject:@"clustal" forKey:@"fileType"];

    return clustalDictionary;
}


- (NSDictionary *)readMSFFile:(NSString *)textFile
{
    int i;
    NSScanner *itemScanner;
    NSString *stringWithMacLineBreaks, *trimmedString;
    NSMutableString *item, *sequence, *tempSequence;
    NSMutableArray *linesArray;
    NSMutableDictionary *matrixDictionary = [NSMutableDictionary dictionary];
    NSMutableDictionary *MSFDictionary = [NSMutableDictionary dictionary];
    NSMutableArray *itemArray = [NSMutableArray arrayWithCapacity:10];

    //Convert all line breaks to Mac line breaks (\r)
    stringWithMacLineBreaks = [self convertLineBreaksToMac:textFile];
    //Trim the first part of the string
    trimmedString = [[stringWithMacLineBreaks componentsSeparatedByString:@"//"]objectAtIndex:1];

    //Isolate individual lines based on \r
    linesArray = (NSMutableArray *)[trimmedString componentsSeparatedByString:@"\r"];


    //Trim lines from surrounding whitespaces and remove empty lines
    for (i = [linesArray count]-1; i >= 0 ; i--) {
        [linesArray insertObject:[[linesArray objectAtIndex:i]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] atIndex:i];
        [linesArray removeObjectAtIndex:i+1];
        if ([[linesArray objectAtIndex:i]isEqualTo:@""] || [[linesArray objectAtIndex:i]hasPrefix:@"  "]) {
            [linesArray removeObjectAtIndex:i];
        }
    }


    //Read item names and sequences and put them in the matrixDictionary
    for (i = 0; i < [linesArray count]; i++) {
        itemScanner = [[NSScanner alloc] initWithString:[linesArray objectAtIndex:i]];
        [itemScanner scanUpToString:@" " intoString:&item];
        sequence = (NSMutableString*)[[linesArray objectAtIndex:i]substringFromIndex:[itemScanner scanLocation]];

        if ([matrixDictionary objectForKey:item]) {	//If the item already exists
            tempSequence = (NSMutableString*)[[matrixDictionary objectForKey:item] stringByAppendingString:sequence];
            [matrixDictionary setObject:tempSequence forKey:item];

        }
        else {						//If the item does not yet exist
            [matrixDictionary setObject:sequence forKey:item];
            [itemArray addObject:item];
        }
        [itemScanner release];
    }


    //Remove spaces and tabs from the sequences in the matrixDictionary
    //itemArray = [matrixDictionary allKeys];
    for (i = 0; i < [itemArray count]; i++) {
        tempSequence = [NSMutableString stringWithString:[matrixDictionary objectForKey:[itemArray objectAtIndex:i]]];
        [tempSequence replaceOccurrencesOfString:@" " withString:@"" options:NULL range:NSMakeRange(0, [tempSequence length])];
        [tempSequence replaceOccurrencesOfString:@"\t" withString:@"" options:NULL range:NSMakeRange(0, [tempSequence length])];
        [matrixDictionary setObject:tempSequence forKey:[itemArray objectAtIndex:i]];
    }

    //Put the matrixDictionary and the items Array in the clustalDictionary
    [MSFDictionary setObject:matrixDictionary forKey:@"matrix"];
    [MSFDictionary setObject:itemArray forKey:@"items"];
    [MSFDictionary setObject:@"msf" forKey:@"fileType"];

    return MSFDictionary;
}


- (NSDictionary *)readNexusFile:(NSString *)textFile
{
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


- (NSDictionary *)readSwissProtFile:(NSString *)textFile
{
    NSString			*line, *sequence, *ID, *description, *organism;
    NSMutableArray		*linesArray;
    NSMutableDictionary *swissProtDictionary = [NSMutableDictionary dictionary];
    NSMutableDictionary *matrixDictionary = [NSMutableDictionary dictionary];
    NSMutableArray		*itemArray = [NSMutableArray arrayWithCapacity:10];
	int					i;
	
	linesArray = [textFile splitLines];
	    
 // to be sure, make all strings empty

    ID = @"";
	organism = @"";
	sequence = @"";
	description = @"";
    
	for (i = 0; i < [linesArray count]; i++)
	{
		line = [linesArray objectAtIndex:i];
		
		if ( [line hasPrefix:@"ID"] )
		{
			ID = [ID stringByAppendingString: [line substringFromIndex:2]];
		}
		
		else if ( [line hasPrefix:@"OS"] )
		{
			organism = [organism stringByAppendingString: [line substringFromIndex:2]];
		}

		else if ( [line hasPrefix:@"DE"] )
		{
			description = [description stringByAppendingString: [line substringFromIndex:2]];
		}

		else if ([line hasPrefix:@"SQ"] )
        {
			line = [linesArray objectAtIndex: ++i];
			
			while (![line hasPrefix:@"//"] )
			{			
				sequence = [sequence stringByAppendingString:[line stringByRemovingWhitespace]];
				line = [linesArray objectAtIndex: ++i];
			}
        }
	}

 // Put the key-value pairs in the swissProtDictionary
	
	[itemArray addObject:ID];
	[matrixDictionary setObject:sequence forKey:ID];
	
    [swissProtDictionary setObject:matrixDictionary forKey:@"matrix"];
    [swissProtDictionary setObject:itemArray forKey:@"items"];
    [swissProtDictionary setObject:description forKey:@"comments"];
    [swissProtDictionary setObject:organism forKey:@"organism"];
    [swissProtDictionary setObject:@"swissprot" forKey:@"fileType"];

	return swissProtDictionary;
}

- (NSDictionary *)readPDBFile:(NSString *)textFile
{
    NSString			*line, *sequence, *header, *title, *source;
    NSMutableArray		*linesArray;
    NSMutableDictionary *pdbDictionary = [NSMutableDictionary dictionary];
    NSMutableDictionary *matrixDictionary = [NSMutableDictionary dictionary];
    NSMutableArray		*itemArray = [NSMutableArray arrayWithCapacity:10];
	int					i;
	
	linesArray = [textFile splitLines];
	    
  // to be sure, make all strings empty

    header = @"";
	source = @"";
	sequence = @"";
	title = @"";
    
	for (i = 0; i < [linesArray count]; i++)
	{
		line = [linesArray objectAtIndex:i];
		
		if ( [line hasPrefix:@"HEADER"] )
		{
			header = [header stringByAppendingString: [line substringFromIndex:10]];
		}
		
		else if ( [line hasPrefix:@"SOURCE"] )
		{
			source = [source stringByAppendingString: [line substringFromIndex:10]];
		}

		else if ( [line hasPrefix:@"TITLE"] )
		{
			title = [title stringByAppendingString: [line substringFromIndex:10]];
		}

		else if ([line hasPrefix:@"SEQRES"] )
        {
			sequence = [sequence stringByAppendingString:[line substringWithRange:NSMakeRange(19, 52)]];
        }
	}

 // Put the key-value pairs in the ncbiDictionary
	
	[itemArray addObject:header];
	[matrixDictionary setObject:sequence forKey:header];

    [pdbDictionary setObject:matrixDictionary forKey:@"matrix"];
    [pdbDictionary setObject:itemArray forKey:@"items"];
    [pdbDictionary setObject:title forKey:@"comments"];
    [pdbDictionary setObject:source forKey:@"organism"];
    [pdbDictionary setObject:@"pdb" forKey:@"fileType"];

	return pdbDictionary;
}


- (NSDictionary *)readNCBIFile:(NSString *)textFile
{
    NSString			*line, *sequence, *locus, *definition, *organism;
    NSMutableArray		*linesArray;
    NSMutableDictionary *ncbiDictionary = [NSMutableDictionary dictionary];
    NSMutableDictionary *matrixDictionary = [NSMutableDictionary dictionary];
    NSMutableArray		*itemArray = [NSMutableArray arrayWithCapacity:10];
	int					i;
	
	linesArray = [textFile splitLines];

 // to be sure, make all strings empty
 
    locus = @"";
	organism = @"";
	sequence = @"";
	definition = @"";
    
	for (i = 0; i < [linesArray count]; i++)
	{
		line = [linesArray objectAtIndex:i];
		
		if ( [line hasPrefix:@"LOCUS"] )
		{
			locus = [locus stringByAppendingString: [line substringFromIndex:11]];
		}
		
		else if ( [line hasPrefix:@"ORGANISM"] )
		{
			organism = [organism stringByAppendingString: [line substringFromIndex:11]];
		}

		else if ( [line hasPrefix:@"DEFINITION"] )
		{
			definition = [definition stringByAppendingString: [line substringFromIndex:11]];
		}

		else if ([line hasPrefix:@"ORIGIN"] )
        {
			line = [linesArray objectAtIndex: ++i];
			
			while (![line hasPrefix:@"//"] )
			{			
				sequence = [sequence stringByAppendingString:[[line substringFromIndex:10] stringByRemovingWhitespace]];
				line = [linesArray objectAtIndex: ++i];
			}
        }
	}

 // Put the key-value pairs in the ncbiDictionary
	
	[itemArray addObject:locus];
	[matrixDictionary setObject:sequence forKey:locus];

    [ncbiDictionary setObject:matrixDictionary forKey:@"matrix"];
    [ncbiDictionary setObject:itemArray forKey:@"items"];
    [ncbiDictionary setObject:definition forKey:@"comments"];
    [ncbiDictionary setObject:organism forKey:@"organism"];
    [ncbiDictionary setObject:@"ncbi" forKey:@"fileType"];

	return ncbiDictionary;
}


- (NSMutableString *)convertLineBreaksToMac:(NSString *)textFile
{
    // \r\n (Windows) becomes \r\r - \n (Unix) becomes \r
    NSMutableString *theString = [NSMutableString stringWithString:textFile];
    [theString replaceOccurrencesOfString:@"\r\n" withString:@"\r" options:NULL range:NSMakeRange(0, [theString length])];
    [theString replaceOccurrencesOfString:@"\n" withString:@"\r" options:NULL range:NSMakeRange(0, [theString length])];
    return theString;
}


- (NSString *)detectLineBreak:(NSString *)srcNStr
{
    // search for dos
    if ([srcNStr rangeOfString: @"\r\n"].location != NSNotFound)
        return @"\r\n";
    // search for mac
    else if ([srcNStr rangeOfString: @"\n"].location != NSNotFound)
        return @"\n";
    // search for unix
    else if ([srcNStr rangeOfString: @"\n"].location != NSNotFound)
        return @"\n";
    // otherwise unknown
    else
        return @"\r";
}


// Memory management

- (id)init
{
    if (self = [super init]) {
    }
    return self;
}


- (void)dealloc
{
    [super dealloc];
}



@end
