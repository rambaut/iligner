/* MainController */
/*
This is the controller class of the sample application, it handles the interface elements and is the target for the button actions
*/

#import <Cocoa/Cocoa.h>

@interface MainController : NSObject
{
IBOutlet id statusField;
IBOutlet id window;
IBOutlet id table;
IBOutlet id progressBar;
NSDictionary *matrix;
NSArray *taxonList;
}

//Target of the Open button
- (IBAction)chooseTextFile:(id)sender;

//Passess the string from the textfile to the BCReader
- (void)readSequenceFile:(NSString *)filePath;

// Creates as many columns as there are bases
- (void)createTableColumns:(int)number;

//Target of the Save button
- (IBAction)saveFile:(id)sender;

//Accessor methods
- (NSDictionary *) matrix;
- (void) setMatrix: (NSDictionary *) aMatrix;
- (NSArray *) taxonList;
- (void) setTaxonList: (NSArray *) aTaxonList;


@end
