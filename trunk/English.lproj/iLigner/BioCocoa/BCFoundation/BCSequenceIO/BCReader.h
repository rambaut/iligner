/* BCReader */

#import <Cocoa/Cocoa.h>

@interface BCReader : NSObject
{
}

- (NSDictionary *)readFile:(NSString *)textFile;
/*
This method automatically detects the file format and passes the NSString containing the contents of the textfile to the appropriate method. 
In most cases, this method will be the only one in this class that will be used directly. 

For an overview of the contents of the NSDictionary returned by this method, see the Overview section in the readNexusFile method comment.
*/


- (NSDictionary *)readNexusFile:(NSString *)textFile;
/*
This method reads a Nexus file. 
You need to pass it the entire Nexus file as a NSString and it will return a root NSDictionary that contains several objects. 
The most important of these is matrixDictionary, another NSDictionary with the item names as keys and the characters (sequence) in an NSString as the value object. 
Additionally, the root NSDictionary also contains a 'comments' key that returns the Nexus file's main comment, 
and a 'items' key that returns an array of items in the Nexus file.

 Overview:
 This method returns a root NSDictionary containing the following Keys and Objects:
 - Key: matrix Value: NSDictionary with item names as keys and characters as values
 - Key: comments Value: NSString containing the Nexus file's main comment
 - Key: items Value: NSArray containing all item names
 - Key: trees Value: NSArray containing all tree descriptions as Newick strings
 - Key: lineBreak Value: NSString containing the line break used in textFile
 - Key: fileType Value: NSString containing the fileType
*/

- (NSDictionary *)readNexusFileAndBlocks:(NSString *)textFile;
/*
This method invokes the readNexusFile file method but it additionally returns an extra key in the root NSDictionary (see overview). 
The extra key is called blocks and it points to an NSDictionary holding all Nexus blocks. 
The names of the blocks are used as the keys in this blocks dictionary.

 Overview:
 This method returns a root NSDictionary containing the following Keys and Objects:
 - Key: matrix Value: NSDictionary with item names as keys and characters as values
 - Key: comments Value: NSString containing the Nexus file's main comment
 - Key: items Value: NSArray containing all item names
 - Key: trees Value: NSArray containing all tree descriptions as Newick strings
 - Key: lineBreak Value: NSString containing the line break used in textFile
 - Key: blocks Value: NSDictionary with Nexus block names as keys and their contents as values
*/

- (NSDictionary *)readPhylipFile:(NSString *)textFile;
/*
This method returns a similar NSDictionary as with the readNexusFile method (see Overview). 
There is one difference: the comments key is not present since this file format does not support comments.
*/

- (NSDictionary *)readPirFile:(NSString *)textFile;
/*
This method returns a similar NSDictionary as with the readNexusFile method (see Overview). 
There is one difference: the comments key is not present since this file format does not support comments.
*/

- (NSDictionary *)readFastaFile:(NSString *)textFile;
/*
This method returns a similar NSDictionary as with the readNexusFile method (see Overview). 
There is one difference: the comments key is not present since this file format does not support comments.
*/

- (NSDictionary *)readGDEFile:(NSString *)textFile;
/*
This method returns a similar NSDictionary as with the readNexusFile method (see Overview). 
There is one difference: the comments key is not present since this file format does not support comments.
*/

- (NSDictionary *)readClustalFile:(NSString *)textFile;
/*
This method returns a similar NSDictionary as with the readNexusFile method (see Overview). 
There is one difference: the comments key is not present since this file format does not support comments.
*/

- (NSDictionary *)readMSFFile:(NSString *)textFile;
/*
This method returns a similar NSDictionary as with the readNexusFile method (see Overview). 
There is one difference: the comments key is not present since this file format does not support comments.
*/

- (NSDictionary *)readSwissProtFile:(NSString *)textFile;
/*
This method reads a SwissProt or EMBL file. 
You need to pass it the entire SwissProt or EMBL file as a NSString and it will return a root NSDictionary that contains several objects.

Overview:
 This method returns a root NSDictionary containing the following Keys and Objects:
 - Key: matrix Value: NSDictionary with the ID-field as key and the sequence as value
 - Key: comments Value: NSString containing the file's description
 - Key: organism Value: NSString containing the file's organism
 - Key: items Value: NSArray containing all item names
 - Key: lineBreak Value: NSString containing the line break used in textFile
 - Key: fileType Value: NSString containing the fileType
*/

- (NSDictionary *)readPDBFile:(NSString *)textFile;
/*
This method reads a PDB file. 
You need to pass it the entire PDB file as a NSString and it will return a root NSDictionary that contains several objects.

Overview:
 This method returns a root NSDictionary containing the following Keys and Objects:
 - Key: matrix Value: NSDictionary with the header as key and the sequence as value
 - Key: comments Value: NSString containing the file's title
 - Key: organism Value: NSString containing the file's source
 - Key: items Value: NSArray containing all item names
 - Key: lineBreak Value: NSString containing the line break used in textFile
 - Key: fileType Value: NSString containing the fileType
*/

- (NSDictionary *)readNCBIFile:(NSString *)textFile;
/*
This method reads a NCBI file. 
You need to pass it the entire NCBI file as a NSString and it will return a root NSDictionary that contains several objects.

Overview:
 This method returns a root NSDictionary containing the following Keys and Objects:
 - Key: matrix Value: NSDictionary with the locus as key and sequence as value
 - Key: comments Value: NSString containing the file's definition
 - Key: organism Value: NSString containing the file's organism
 - Key: items Value: NSArray containing all item names
 - Key: lineBreak Value: NSString containing the line break used in textFile
 - Key: fileType Value: NSString containing the fileType
*/

- (NSMutableString *)convertLineBreaksToMac:(NSString *)textFile;
- (NSString *)detectLineBreak:(NSString *)srcNStr;


@end
