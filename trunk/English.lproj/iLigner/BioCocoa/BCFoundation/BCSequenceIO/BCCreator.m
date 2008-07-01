#import "BCCreator.h"
#import "../BCUtils/BCUtilStrings.h"

@implementation BCCreator


- (void)saveFile:matrix withComments:comments extraBlocks:eb
{
    int runResult;
    NSSavePanel *sp;
    NSString *fileString, *fileFormat, *fileType;
    [NSBundle loadNibNamed:@"View" owner:self];
    sp = [NSSavePanel savePanel];
    [sp setAccessoryView:formatPopupView];

    runResult = [sp runModalForDirectory:[@"~/" stringByExpandingTildeInPath] file:@"Untitled"];
    if (runResult == NSOKButton) {
        fileFormat = [formatPopup titleOfSelectedItem];

        if ([fileFormat isEqualTo:@"Nexus"]) {
            fileString = [self createNexusFile:matrix withComments:comments extraBlocks:eb];
            fileType = @"nex";
        }
        else if ([fileFormat isEqualTo:@"Clustal"]) {
            fileString = [self createClustalFile:matrix];
            fileType = @"aln";
        }
        else if ([fileFormat isEqualTo:@"GCG-MSF"]) {
            fileString = [self createMSFFile:matrix];
            fileType = @"msf";
        }        
        else if ([fileFormat isEqualTo:@"PIR"]) {
            fileString = [self createPirFile:matrix];
            fileType = @"pir";
        }
        else if ([fileFormat isEqualTo:@"GDE"]) {
            fileString = [self createGDEFile:matrix];
            fileType = @"gde";
        }
        else if ([fileFormat isEqualTo:@"Fasta"]) {
            fileString = [self createFastaFile:matrix];
            fileType = @"fst";
        }
        else if ([fileFormat isEqualTo:@"SwissProt"]) {
            fileString = [self createSwissProtFile:matrix];
            fileType = @"fst";
        }
        else {
            fileString = [self createPhylipFile:matrix];
            fileType = @"phy";
        }

        if (![fileString writeToFile:[NSString stringWithFormat:@"%@.%@",[sp filename],fileType] atomically:YES])
            NSBeep();
    }
}




//Method that creates a Nexus file NSString
- (NSString *)createNexusFile:(NSDictionary *)matrix withComments:(NSString *)comments extraBlocks:(NSString *)eb
{
    int i;
    NSString *exportString;
    if (comments) {
        exportString = [NSString stringWithFormat:@"#NEXUS%@[!Nexus file created with the cocoaNexus framework. %@]%@%@BEGIN DATA;%@DIMENSIONS NTAX=%d NCHAR=%d;%@FORMAT DATATYPE=DNA MISSING=? GAP=- MATCHCHAR=. ;%@%@MATRIX%@%@", lineBreak, comments, lineBreak, lineBreak, lineBreak, [[matrix allKeys] count], [(NSString *)[matrix objectForKey:[[matrix allKeys]objectAtIndex:1]]length], lineBreak, lineBreak, lineBreak, lineBreak, lineBreak];
    }
    else {
        exportString = [NSString stringWithFormat:@"#NEXUS%@[!Nexus file created with the cocoaNexus framework.]%@%@BEGIN DATA;%@DIMENSIONS NTAX=%d NCHAR=%d;%@FORMAT DATATYPE=DNA MISSING=? GAP=- MATCHCHAR=. ;%@%@MATRIX%@%@", lineBreak, lineBreak, lineBreak, lineBreak, [[matrix allKeys] count], [(NSString *)[matrix objectForKey:[[matrix allKeys]objectAtIndex:1]]length], lineBreak, lineBreak, lineBreak, lineBreak, lineBreak];
    }

    for (i = 0; i < [[matrix allKeys] count]; i++) {
        exportString = [exportString stringByAppendingString:[NSString stringWithFormat:@"%@   %@%@%@", [[[matrix allKeys] objectAtIndex:i]stringByReplacingSpaceWithUnderscore], [matrix objectForKey:[[matrix allKeys]objectAtIndex:i]], lineBreak, lineBreak ]];
    }

    exportString = [exportString stringByAppendingString:[NSString stringWithFormat:@"%@;%@END;%@%@", lineBreak, lineBreak, lineBreak, lineBreak]];
    if (eb) {
        exportString = [exportString stringByAppendingString:[NSString stringWithFormat:@"%@%@", eb, lineBreak]];
    }
    return exportString;
}


//Method that creates a Nexus file NSString
- (NSString *)createNexusFile:(NSDictionary *)matrix
{
    return [self createNexusFile:matrix withComments:nil extraBlocks:nil];
}

//Method that creates a Fasta file NSString
- (NSString *)createFastaFile:(NSDictionary *)matrix
{
    int i;
    NSString *exportString;
    exportString = @"";

    for (i = 0; i < [[matrix allKeys] count]; i++) {
        exportString = [exportString stringByAppendingString:[NSString stringWithFormat:@">%@%@%@%@", [[matrix allKeys] objectAtIndex:i], lineBreak, [matrix objectForKey:[[matrix allKeys]objectAtIndex:i]], lineBreak ]];
    }

    return exportString;
}


//Method that creates a Phylip file NSString
- (NSString *)createPhylipFile:(NSDictionary *)matrix
{
    int i;
    NSString *exportString, *itemName;

    exportString = [NSString stringWithFormat:@"%d   %d%@", [[matrix allKeys] count], [(NSString *)[matrix objectForKey:[[matrix allKeys]objectAtIndex:1]]length], lineBreak];

    for (i = 0; i < [[matrix allKeys] count]; i++) {
        itemName = [[matrix allKeys] objectAtIndex:i];
        if ([itemName length] > 10) {
            itemName = [itemName substringToIndex:10];
        }
        exportString = [exportString stringByAppendingString:[NSString stringWithFormat:@"%@   %@%@%@", itemName, [matrix objectForKey:[[matrix allKeys]objectAtIndex:i]], lineBreak, lineBreak ]];
    }

    return exportString;
}


//Method that creates a PIR file NSString
- (NSString *)createPirFile:(NSDictionary *)matrix
{
    int i;
    NSString *exportString;
    exportString = @"";

    for (i = 0; i < [[matrix allKeys] count]; i++) {
        exportString = [exportString stringByAppendingString:[NSString stringWithFormat:@">DL; %@%@%@%@%@*%@", [[matrix allKeys] objectAtIndex:i], lineBreak, [[matrix allKeys] objectAtIndex:i], lineBreak, [matrix objectForKey:[[matrix allKeys]objectAtIndex:i]], lineBreak]];
    }
    return exportString;
}


//Method that creates a Clustal file NSString
- (NSString *)createClustalFile:(NSDictionary *)matrix
{
    int i, j, numberOfChars;
    NSString *exportString;
    exportString = [NSString stringWithFormat:@"CLUSTAL X (1.81) multiple sequence alignment%@%@%@", lineBreak, lineBreak, lineBreak];
    numberOfChars = [(NSString *)[matrix objectForKey:[[matrix allKeys]objectAtIndex:1]]length];

    for (j = 0; j < numberOfChars; j=j+100) {

        for (i = 0; i < [[matrix allKeys] count]; i++) {

            if (j+100 < numberOfChars) {
                exportString = [exportString stringByAppendingString:[NSString stringWithFormat:@"%@  %@%@", [[matrix allKeys] objectAtIndex:i], [[matrix objectForKey:[[matrix allKeys]objectAtIndex:i]]substringWithRange:NSMakeRange(j, 100)], lineBreak ]];
            }
            else {
                exportString = [exportString stringByAppendingString:[NSString stringWithFormat:@"%@  %@%@", [[matrix allKeys] objectAtIndex:i], [[matrix objectForKey:[[matrix allKeys]objectAtIndex:i]]substringWithRange:NSMakeRange(j, numberOfChars-j)], lineBreak ]];
            }

        }
        exportString = [exportString stringByAppendingString:lineBreak];
    }
    exportString = [exportString stringByAppendingString:lineBreak];
    return exportString;
}


//Method that creates a MSF file NSString
- (NSString *)createMSFFile:(NSDictionary *)matrix
{
    int i, j, numberOfChars, totalCheckSum;
    NSString *exportString;
    NSMutableString *sequence;
    numberOfChars = [(NSString *)[matrix objectForKey:[[matrix allKeys]objectAtIndex:1]]length];

    //Calculate the total checksum 
    totalCheckSum = 0;
    for (i = 0; i < [[matrix allKeys] count]; i++) {
        sequence = [matrix objectForKey:[[matrix allKeys]objectAtIndex:i]];
        [sequence replaceOccurrencesOfString:@"-" withString:@"." options:NULL range:NSMakeRange(0, [sequence length])];
        totalCheckSum = totalCheckSum + (int)[self GCGCheckSum:sequence];
    }
    totalCheckSum = totalCheckSum % 10000;

    //Create the header with the total cheksum and length
    exportString = [NSString stringWithFormat:@"PileUp%@%@%@%@MSF: %d  Type: N    Check:  %d   ..%@%@", lineBreak, lineBreak, lineBreak, lineBreak, numberOfChars, totalCheckSum, lineBreak, lineBreak];

    //Add a line for every item with length and checksum
    for (i = 0; i < [[matrix allKeys] count]; i++) {
        sequence = [matrix objectForKey:[[matrix allKeys]objectAtIndex:i]];
exportString = [exportString stringByAppendingString:[NSString stringWithFormat:@"Name: %@ oo  Len: %d  Check:  %d  Weight:  100.0%@", [[matrix allKeys] objectAtIndex:i], [sequence length], [self GCGCheckSum:sequence], lineBreak ]];
    }

    //Add the //
    exportString = [exportString stringByAppendingString:[NSString stringWithFormat:@"%@//%@%@%@%@", lineBreak, lineBreak, lineBreak, lineBreak, lineBreak]];
    

    for (j = 0; j < numberOfChars; j=j+100) {
        for (i = 0; i < [[matrix allKeys] count]; i++) {

            if (j+100 < numberOfChars) {
                exportString = [exportString stringByAppendingString:[NSString stringWithFormat:@"%@  %@%@", [[matrix allKeys] objectAtIndex:i], [[matrix objectForKey:[[matrix allKeys]objectAtIndex:i]]substringWithRange:NSMakeRange(j, 100)], lineBreak ]];
            }
            else {
                exportString = [exportString stringByAppendingString:[NSString stringWithFormat:@"%@  %@%@", [[matrix allKeys] objectAtIndex:i], [[matrix objectForKey:[[matrix allKeys]objectAtIndex:i]]substringWithRange:NSMakeRange(j, numberOfChars-j)], lineBreak ]];
            }
        }
        exportString = [exportString stringByAppendingString:lineBreak];
    }
    exportString = [exportString stringByAppendingString:lineBreak];
    return exportString;
}



//Method that creates a SwissProt file NSString
- (NSString *)createSwissProtFile:(NSDictionary *)matrix
{
    int i;
    NSString *exportString;
    exportString = @"";

    for (i = 0; i < [[matrix allKeys] count]; i++) 
	{
//        exportString = [exportString stringByAppendingString:[NSString stringWithFormat:@"#%@%@%@%@", 
//						[[matrix allKeys] objectAtIndex:i], lineBreak, 
//						[matrix objectForKey:[[matrix allKeys]objectAtIndex:i]], lineBreak ]];
    }

    return exportString;
}


//Method that creates a GDE file NSString
- (NSString *)createGDEFile:(NSDictionary *)matrix
{
    int i;
    NSString *exportString;
    exportString = @"";

    for (i = 0; i < [[matrix allKeys] count]; i++) {
        exportString = [exportString stringByAppendingString:[NSString stringWithFormat:@"#%@%@%@%@", [[matrix allKeys] objectAtIndex:i], lineBreak, [matrix objectForKey:[[matrix allKeys]objectAtIndex:i]], lineBreak ]];
    }

    return exportString;
}


-(int)GCGCheckSum:(NSString *)seq
{
    const char *sequence = [seq lossyCString];
    long i, check, count;
    int len, val;

    check = count = 0;
    len = [seq length];
    for(i = 0; i < len; i++)  {
        val = sequence[i];
        if((val == -3) || (val == 253)) break;
        count++;
        check += count * toupper((int) sequence[i]);
        if(count == 57) {
            count = 0;
        }
    }
    check %= 10000;
    return check;
}



- (void)useLineBreakFromSource:(NSDictionary *)matrix
{
    if ([matrix objectForKey:@"lineBreak"]) {
        [self setLineBreak:[matrix objectForKey:@"lineBreak"]];
    }
}

- (void)useUnixLineBreak
{
    [self setLineBreak:@"\n"];
}

- (void)useWindowsLineBreak
{
    [self setLineBreak:@"\r\n"];
}



//Accessors for the line break
- (NSString *) lineBreak
{
    return lineBreak;
}

- (void) setLineBreak: (NSString *) aLineBreak
{
    if (lineBreak != aLineBreak)
    {
        [aLineBreak retain];
        [lineBreak release];
        lineBreak = aLineBreak;
    }
}



// Memory management

- (id)init
{
    if (self = [super init]) {
        [self setLineBreak:@"\r"];
    }
    return self;
}


- (void)dealloc
{
    [lineBreak release];
    [super dealloc];
}



@end
