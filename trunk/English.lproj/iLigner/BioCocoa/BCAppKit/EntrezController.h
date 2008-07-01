//
//  EntrezController.h
//  BioCocoa
//
//  Created by Alexander Griekspoor
//  Copyright (c) 2006 Mekentosj.com. All rights reserved.
//  http://creativecommons.org/licenses/by-nc/2.0/
//
//  Permission to use, copy, modify and distribute this software and its documentation
//  is hereby granted, provided that both the copyright notice and this permission
//  notice appear in all copies of the software, derivative works or modified versions,
//  and any portions thereof, and that both notices appear in supporting documentation,
//  and that credit is given to Mekentosj.com in all documents and publicity
//  pertaining to direct or indirect use of this code or its derivatives.
//
//  THIS IS EXPERIMENTAL SOFTWARE AND IT IS KNOWN TO HAVE BUGS, SOME OF WHICH MAY HAVE
//  SERIOUS CONSEQUENCES. THE COPYRIGHT HOLDER ALLOWS FREE USE OF THIS SOFTWARE IN ITS
//  "AS IS" CONDITION. THE COPYRIGHT HOLDER DISCLAIMS ANY LIABILITY OF ANY KIND FOR ANY
//  DAMAGES WHATSOEVER RESULTING DIRECTLY OR INDIRECTLY FROM THE USE OF THIS SOFTWARE
//  OR OF ANY DERIVATIVE WORK.
//---------------------------------------------------------------------------------------

#import <AppKit/AppKit.h>
#import "EntrezResult.h"
#import <SXML/SXML.h>
#import <SystemConfiguration/SystemConfiguration.h>


@interface EntrezController : NSWindowController{

    //===========================================================================
    //  Outlets
    //===========================================================================
    
    IBOutlet NSSearchField *searchField;
    IBOutlet NSMenu *searchMenu;
    IBOutlet NSButton *fetchButton;
    IBOutlet NSButton *cancelButton;
    IBOutlet NSTableView *tv;
    IBOutlet NSTextView *preview;
    IBOutlet NSProgressIndicator *progress;
    IBOutlet NSTextField *progressTextField;
    
    //===========================================================================
    //  Variables
    //===========================================================================
    
    NSUserDefaults *prefs;

    NSMutableArray *searchResults;
    SXMLTree *hits;
    
    NSURLConnection *connection;
    NSMutableData *receivedData;
    NSURLResponse *response;
    long long bytesReceived;
    BOOL searchInProgress;
    BOOL summaryFetchInProgress;
    BOOL fetchInProgress;
    int searchcount;
    int fetchedResults;
    
    NSString *webenv;
    NSString *querykey;
    
    id delegate;
}



//===========================================================================
#pragma mark -
#pragma mark • Init & Dealloc
//===========================================================================

- (void)awakeFromNib;
- (void)dealloc;

- (void)setDelegate:(id)newDelegate;
- (id)delegate;

//===========================================================================
#pragma mark -
#pragma mark • ACTIONS
//===========================================================================

- (IBAction)searchForQuery:(id)sender;
- (IBAction)fetch:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)showPreview:(id)sender;


//===========================================================================
#pragma mark -
#pragma mark • TABLEVIEW METHODS
//===========================================================================

- (int)numberOfRowsInTableView:(NSTableView *)theTableView;
- (id)tableView:(NSTableView *)theTableView objectValueForTableColumn:(NSTableColumn *)theColumn row:(int)rowIndex;
- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex;
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification;
- (void)tableView:(NSTableView*)tv didClickTableColumn:(NSTableColumn *)tableColumn;
- (void)clearIndicatorImages;


// ================================================================
#pragma mark --- DOWNLOAD METHODS
// ================================================================

- (void)retrieveSearchResultsForQuery: (NSString *)q;
- (BOOL)parseSearchResults: (NSData *)results;

- (void)retrieveSummaries;
- (BOOL)parseSummaries: (NSData *)results;

- (void)fetchResult: (EntrezResult *)result;
- (BOOL)parseFetch: (NSData *)results;

- (void)cleanupDownload;

- (void)reportDownloadFailureWithError: (NSString *)errorstring;

- (void) NCBIconnectionError: (id) anError;

// ================================================================
#pragma mark --- DOWNLOAD ACCESSORS
// ================================================================

- (NSURLResponse *)response;
- (void)setResponse:(NSURLResponse *)newResponse;

- (NSString *)webenv;
- (void)setWebenv:(NSString *)newWebenv;

- (NSString *)querykey;
- (void)setQuerykey:(NSString *)newQuerykey;



// ================================================================
#pragma mark --- CONNECTION DELEGATES
// ================================================================

- (void)connection: (NSURLConnection *)theConnection didReceiveResponse: (NSURLResponse *)theresponse;
- (void)connection: (NSURLConnection *)connection didReceiveData: (NSData *)data;
- (void)connection: (NSURLConnection *)connection didFailWithError: (NSError *)error;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;


//===========================================================================
#pragma mark -
#pragma mark --- DELEGATES
//===========================================================================

- (BOOL)validateMenuItem:(NSMenuItem *)anItem;

//===========================================================================
#pragma mark -
#pragma mark --- GENERAL METHODS
//===========================================================================

- (BOOL)parseOutput: (NSData *)output;
- (BOOL) _canConnect;


@end
