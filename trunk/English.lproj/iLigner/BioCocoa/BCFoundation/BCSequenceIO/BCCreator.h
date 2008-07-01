/* BCCreator */

#import <Cocoa/Cocoa.h>

@interface BCCreator : NSObject
{
    IBOutlet id formatPopup;
    IBOutlet id formatPopupView;
    NSString *lineBreak;
}

- (void)saveFile:matrix withComments:comments extraBlocks:eb;
/*
This method will bring up a save dialog in which the user can select the format he wants to use to save the data. Once a file format is chosen, this method invokes the corresponding method below to actually save the file.
*/


- (NSString *)createNexusFile:(NSDictionary *)matrix withComments:(NSString *)comments extraBlocks:(NSString *)eb;
/*
Returns an NSString containing a Nexus file. Matrix is an NSDictionary with the items as keys and all characters (without spaces) as values. Comments and extraBlocks are two optional parameters. Comments specifies the Nexus file comments this method should add to the Nexus file. With extraBlocks, one can add its own Nexus file blocks as an NSString.
*/


- (NSString *)createNexusFile:(NSDictionary *)matrix;
// Invokes the createNexusFile:withComments:extraBlocks: method, using nil for both the comments and eb arguments.

- (NSString *)createPirFile:(NSDictionary *)matrix;
// Returns an NSString containing a Pir file. Matrix is an NSDictionary with the items as keys and all characters (without spaces) as values.

- (NSString *)createFastaFile:(NSDictionary *)matrix;
// Returns an NSString containing a Fasta file. Matrix is an NSDictionary with the items as keys and all characters (without spaces) as values.

- (NSString *)createPhylipFile:(NSDictionary *)matrix;
// Returns an NSString containing a Phylip file. Matrix is an NSDictionary with the items as keys and all characters (without spaces) as values. item names are automatically trimmed to 10 characters since Phylip can't handle longer item names

- (NSString *)createClustalFile:(NSDictionary *)matrix;
// Returns an NSString containing a Clustal file. Matrix is an NSDictionary with the items as keys and all characters (without spaces) as values. The sequences are automatically interleaved in rows of 100.

- (NSString *)createGDEFile:(NSDictionary *)matrix;
// Returns an NSString containing a GDE file. Matrix is an NSDictionary with the items as keys and all characters (without spaces) as values.

- (NSString *)createMSFFile:(NSDictionary *)matrix;
// Returns an NSString containing an MSF file. Matrix is an NSDictionary with the items as keys and all characters (without spaces) as values.

- (NSString *)createSwissProtFile:(NSDictionary *)matrix;
// Method that creates a SwissProt file NSString


- (void)useUnixLineBreak;
- (void)useWindowsLineBreak;
- (void)useLineBreakFromSource:(NSDictionary *)matrix;
/*
These methods ensure cross-platform compatibility by offering the possbility to set the preferred line break. The default is set to Mac line breaks. If you want exported files to have DOS line breaks, call the useDOSLineBreak method before saving the file. Or use the useUnixLineBreak method for Unix. If you want to use the line break used in the source file the matrix was written from, call useLineBreakFromSource passing it the matrix as the only argument. All three methods call the setLineBreak method.
*/

- (NSString *) lineBreak;
// Returns the line break that is currently in use.

- (void) setLineBreak: (NSString *) aLineBreak;
-(int)GCGCheckSum:(NSString *)seq;
@end
