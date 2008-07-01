#import "MainController.h"
#import <BioCocoa/BCFoundation.h>


@implementation MainController

- (void)awakeFromNib
{
    [window setFrameUsingName:@"mainWindow"];
}


- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
    [self readSequenceFile:filename];
    return YES;
}



// Let the user select a text file 
- (IBAction)chooseTextFile:(id)sender
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel beginSheetForDirectory:nil file:nil types:nil modalForWindow:window modalDelegate:self didEndSelector:@selector(openPanelDidEnd:returnCode:contextInfo:) contextInfo:nil];
    [panel setCanChooseDirectories:NO];
    [panel setPrompt:@"Choose File"];
}


- (void)openPanelDidEnd:(NSOpenPanel *)openPanel returnCode:(int)returnCode contextInfo:(void  *)contextInfo
{
    if (returnCode == NSOKButton) {
        [statusField setStringValue:[openPanel filename]];
        [openPanel close];
        [progressBar startAnimation:self];
        [self readSequenceFile:[openPanel filename]];
        [progressBar stopAnimation:self];
    }
}


// Pass the contents of the sequence file as a string to the BCReader
- (void)readSequenceFile:(NSString *)filePath
{
    int i, totalColumns;
    NSMutableString *sequenceFile = [NSMutableString stringWithContentsOfFile:filePath];
    NSDictionary *sequenceDict;
    BCSequenceReader *reader = [[BCSequenceReader alloc]init];

    // The BCReader returns an NSDictionary (see BCReader.h)
    sequenceDict = [reader readFile:sequenceFile];
    [reader release];

    // Remove the old table columns
    totalColumns = [[table tableColumns]count];
    for (i = 1; i < totalColumns  ; i++) {
    [table removeTableColumn:[table tableColumnWithIdentifier:[NSString stringWithFormat:@"%d", i]]];
    }
    
    // Set the matrix and taxonList variables
    [self setMatrix:[sequenceDict objectForKey:@"matrix"]];
    [self setTaxonList:[sequenceDict objectForKey:@"items"]];
    NSLog(@"the matrix: %@", matrix);
	
    // Create new table columns (one for every character)
    [self createTableColumns:[(NSString *)[matrix objectForKey:[taxonList objectAtIndex:1]]length]];
    [table reloadData];

    // Show the number of taxa and characters in the status field
    [statusField setStringValue:[NSString stringWithFormat:@"%d taxa - %d characters", [taxonList count], [(NSString *)[matrix objectForKey:[taxonList objectAtIndex:1]]length] ]];
}



// Method for saving files

- (IBAction)saveFile:(id)sender
{
    // Invoke the saveFile method (see BCCreator.h)
    BCSequenceWriter *creator = [[BCSequenceWriter alloc]init];
    [creator useLineBreakFromSource:matrix];
    [creator saveFile:matrix withComments:@"Test" extraBlocks:@"BEGIN ASSUMPTIONS;\nOPTIONS  DEFTYPE=unord PolyTcount=MINSTEPS ;\nEND;"];
    [creator release];
}




// Table methods

- (int)numberOfRowsInTableView:(NSTableView *)table;
{
    if (matrix) {
        return [taxonList count];
    }
    else {return 0;}
}



- (id)tableView:(NSTableView *)table objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
    NSString *identifier = [aTableColumn identifier];
    NSString *taxon = [taxonList objectAtIndex:rowIndex];
    if (matrix) {
        if ([identifier isEqualTo:@"taxon"]) {
            return taxon;
        }
        else {
            return [[matrix valueForKey:taxon]substringWithRange:NSMakeRange([identifier intValue]-1,1)];
        }
    }
    else { return nil;}
}


-(void)createTableColumns:(int)number
{
    int i;
    NSTableColumn *col;
    for (i = 0; i < number ; i++) {

        col = [[[NSTableColumn alloc] initWithIdentifier:[NSString stringWithFormat:@"%d", i+1]] autorelease];
        [[col headerCell] setTitle:[NSString stringWithFormat:@"%d", i+1]];
        [col setWidth: 30];
        [col setMaxWidth: 30];
        [table addTableColumn: col];

        }
}



- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    if (flag == NO) {
        [window makeKeyAndOrderFront:self];
        return NO;
    }
    else {
        return YES;
    }
}


- (void)windowWillClose:(NSNotification *)notification;
{
    [window saveFrameUsingName:@"mainWindow"];
}


//Accessor methods
- (NSDictionary *) matrix
{
    return matrix;
}

- (void) setMatrix: (NSDictionary *) aMatrix
{
    if (matrix != aMatrix)
    {
        [aMatrix retain];
        [matrix release];
        matrix = aMatrix;
    }
}

- (NSArray *) taxonList
{
    return taxonList;
}

- (void) setTaxonList: (NSArray *) aTaxonList
{
    if (taxonList != aTaxonList)
    {
        [aTaxonList retain];
        [taxonList release];
        taxonList = aTaxonList;
    }
}



@end
