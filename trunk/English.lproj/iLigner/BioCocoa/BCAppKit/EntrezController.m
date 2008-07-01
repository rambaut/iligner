//
//  EntrezController.m
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

/* This (shared) window controller is all you need to search and fetch entrez. In comes 
with its own nib file and generates EntrezResult objects which are displayed in a 
tableview. We make use of NSConnection and NSURLDownload for asynchronous fetching of
results and sequences.
The flow of the program is in short:
- retrieve results for query, generates an xml file with IDs (using NCBI's eSearch eUtil).
- parse this file and retrieve summaries for each ID (using NCBI's eSummary's eUtil).
- parse xml file with summaries, create for each one a EntrezResult object and display 
  those in the Tableview.
- if the user selects one, it is fetched (using NCBI's eFetch eUtil).
- the response is parsed and forwarded to the delegate, this controller is cleaned-up 
  afterwards.
*/

#import "EntrezController.h"

// The delegate only has to implement one method to receive the fetched sequence: 
@protocol EntrezControllerDelegate <NSObject>
- (void)insertFetchedSequence: (NSString *)seq withName: (NSString *)title;
@end


@implementation EntrezController  

//===========================================================================
#pragma mark -
#pragma mark ¥ Init & Dealloc
//===========================================================================

- (EntrezController *)init
{
    self = [super initWithWindowNibName: @"Entrez"];
    prefs = [NSUserDefaults standardUserDefaults];
    searchResults = [[NSMutableArray array] retain];
    
    return self;
    
}

- (void)awakeFromNib{    

    //TEXTVIEW SETUP
    [preview setFont: [NSFont fontWithName: @"Courier" size: 11.0]];

    //SEARCHFIELD SETUP
    [searchField setRecentsAutosaveName: @"RecentEntrezSearches"];
    [searchField setTarget:self];
    [searchField setDelegate:self];
    
    [self showPreview: self];
    
    // PROGRESS SETUP
    [progressTextField setStringValue: @""];
    [self cleanupDownload];
    
    // STATUS
    searchInProgress = NO;
    summaryFetchInProgress = NO;
    fetchInProgress  = NO;
    fetchedResults = 0;

    // DOWNLOAD SETUP
    receivedData = nil;
}

- (void)dealloc{
 
    if(receivedData != nil){
        [receivedData release];
        receivedData = nil;
    }
    
    if ( connection != nil ) {
        [connection release];
        connection = nil;
    }
    
    [webenv release];
    [querykey release];
    
    [searchResults release];
    
    [super dealloc];
}

-(void)setDelegate:(id) newDelegate {
    delegate = newDelegate;
}

-(id)delegate {
    return delegate;
}


//===========================================================================
#pragma mark -
#pragma mark ¥ ACTIONS
//===========================================================================

- (IBAction)searchForQuery:(id)sender{
	if([[sender stringValue]isEqualToString:@""]){
		[self cleanupDownload];	
		[progressTextField setStringValue: @""];
		fetchedResults = 0;
		[searchResults removeAllObjects];
		[tv reloadData];
	}
    else if(searchInProgress || summaryFetchInProgress || fetchInProgress){
        // cancel
        [self cleanupDownload];
        // go again
        [self retrieveSearchResultsForQuery: [sender stringValue]];
        
    } else {
        [self retrieveSearchResultsForQuery: [sender stringValue]];
    }
}

- (IBAction)fetch:(id)sender{
    int row = [tv selectedRow];
        
    if (row == -1) {
        NSBeep();
    } else {
        [self fetchResult: [searchResults objectAtIndex: row]];
    }
        
}

- (IBAction)cancel:(id)sender{
    [self cleanupDownload];
    fetchedResults = 0;
    [progressTextField setStringValue: @""];

    [NSApp endSheet: [self window] returnCode: 1];
    [[self window] orderOut: self];
}


- (IBAction)showPreview:(id)sender{
    NSAttributedString* newStorage;
    NSMutableDictionary* attDict  = [NSMutableDictionary dictionary];

    int row = [tv selectedRow];
    
    NSMutableString *resultsstring = [NSMutableString stringWithCapacity: 1000];
    
    if (row == -1) {
        [resultsstring appendString: @"\nNo Record Selected"];
        NSMutableParagraphStyle *modifiedStyle = [[NSMutableParagraphStyle alloc] init];
        [modifiedStyle setAlignment: NSCenterTextAlignment]; 
        [attDict setObject: modifiedStyle forKey: NSParagraphStyleAttributeName];
        [attDict setObject: [NSFont systemFontOfSize: 16.0] forKey: NSFontAttributeName];
        [attDict setObject: [NSColor lightGrayColor] forKey: NSForegroundColorAttributeName];
        [modifiedStyle release]; 
        
        newStorage = [[NSAttributedString alloc] initWithString: resultsstring attributes:attDict];
        [fetchButton setEnabled: NO];
        
    } else {
               
        [resultsstring appendString:   [NSString stringWithFormat: @"%@ %@", [[searchResults objectAtIndex: row] extra], [[searchResults objectAtIndex: row] description]]];
        
        [attDict setObject: [NSFont fontWithName: @"Courier" size: 12] forKey: NSFontAttributeName];
        [attDict setObject: [NSColor blackColor] forKey: NSForegroundColorAttributeName];
        [attDict setObject: [NSColor whiteColor] forKey: NSBackgroundColorAttributeName];
        
        newStorage = [[NSAttributedString alloc] initWithString: resultsstring attributes:attDict];
        [fetchButton setEnabled: YES];
    }
    
    [[preview textStorage] setAttributedString: newStorage];  
    [newStorage release];   
}


//===========================================================================
#pragma mark -
#pragma mark ¥ TABLEVIEW METHODS
//===========================================================================

- (int)numberOfRowsInTableView:(NSTableView *)theTableView{
    return [searchResults count];
}

- (id)tableView:(NSTableView *)theTableView objectValueForTableColumn:(NSTableColumn *)theColumn row:(int)rowIndex{
    
        if([[theColumn identifier]isEqualToString: @"accession"]){
            return [[searchResults objectAtIndex: rowIndex] accession];
            
        } else if([[theColumn identifier]isEqualToString: @"description"]){
            return [[searchResults objectAtIndex: rowIndex] description];
            
        } else if([[theColumn identifier]isEqualToString: @"species"]){
            return [[searchResults objectAtIndex: rowIndex] species];
        }
    
    return nil;
    
}

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex{
        // TO COMPENSATE FOR ADJUSTED iTABLEVIEW
        if([(NSCell *)aCell type] == NSTextCellType){
            [aCell setTextColor: [NSColor blackColor]];
        }
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification{
    [self showPreview: self];
}

- (void)tableView:(NSTableView*)tv didClickTableColumn:(NSTableColumn *)tableColumn{
    
}

- (void)clearIndicatorImages{
    
}

// ================================================================
#pragma mark -
#pragma mark ¥ DOWNLOAD METHODS
// ================================================================

- (void)retrieveSearchResultsForQuery: (NSString *)q{   
    //NSString *field = nil;
    
    if([[searchField stringValue]isEqualToString: @""]){
        NSBeep();
        return;
    }
    
    // PREPARE
    [progress startAnimation: self];
    [progressTextField setStringValue: @"Contacting NCBI..."];
    
    searchInProgress = YES;
    
    /*
    // PREVIOUS SEARCH?  -> support for Search more using webenv, not implemented here...
    if(fetchedResults > 0 && webenv != nil){
    } else {
    */
	//NSLog(@"%@", q);

    NSMutableString *str = [NSMutableString stringWithString: [NSString stringWithFormat: @"http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=nucleotide&retmode=xml&usehistory=y&retmax=150&tool=EnzymeX&retstart=%d&term=", fetchedResults]];
   	NSMutableString *query = [NSMutableString stringWithString: q];

    // Replace spaces by +
    [query replaceOccurrencesOfString: @" " withString: @"+" options:  NSCaseInsensitiveSearch range: NSMakeRange(0, [query length])];
	[str appendString: query];

	/*
	// Add field, unused here, but would allow searches in specific categories only
	// Contains [] already? -> ALL, otherwise check title of menu
	if([query rangeOfString: @"["].location == NSNotFound){
		id eObject;
		NSEnumerator *e = [[searchMenu itemArray] objectEnumerator];
		while (eObject = [e nextObject]){
			if([eObject state] == NSOnState){
				field = [eObject title];
				break;
			}
		}
		
        if([field isEqualToString: @"All"]) field = nil;
        else if([field isEqualToString: @"Accession"])   field = @"[ACCN]";
        else if([field isEqualToString: @"Author(s)"])   field = @"[AUTH]";
        else if([field isEqualToString: @"Property"])    field = @"[PROP]";
        else if([field isEqualToString: @"Definition"])  field = @"[TITL]";
        else if([field isEqualToString: @"Feature"])     field = @"[FKEY]";
        else if([field isEqualToString: @"Gene"])        field = @"[GENE]";
        else if([field isEqualToString: @"Organism"])    field = @"[ORGN]";
        else if([field isEqualToString: @"Protein"])     field = @"[PROT]";
        else if([field isEqualToString: @"UID"])         field = @"[UID]";
        
        //NSLog(@"Field: %@", field);
		
	}
	
    if(field) [str appendString: field];
	*/
	
	
	// QUERY

    // Remove other strange characters
    // query = [NSMutableString stringWithString: (NSString *) CFURLCreateStringByAddingPercentEscapes (NULL, (CFStringRef) query, NULL, NULL, kCFStringEncodingMacRoman)];
     
	//NSLog(@"Search: %@", str);

         
    if ( ![self _canConnect] ) {
        [progressTextField setStringValue: @"Unable to contact NCBI. Please provide an internet connection."];
        [self NCBIconnectionError: @"not reachable"]; 
        return;
    }
    
    receivedData = [[NSMutableData alloc] init];
    
    NSURLRequest *theRequest = [NSURLRequest requestWithURL: [NSURL URLWithString: str]
                                                cachePolicy:  NSURLRequestReloadIgnoringCacheData
                                            timeoutInterval:  20.0];
    
    if ( !theRequest) {
        [progressTextField setStringValue: @"Unable to generate query. Check for any inapropriate characters in your query."];
        [self NCBIconnectionError: @"no request"]; 
        return;
    }
    
    connection = [NSURLConnection connectionWithRequest: theRequest delegate:self];
    
    if ( !connection ) {
        [progressTextField setStringValue: @"Unable to generate query. Check for any inapropriate characters in your query."];
        [self NCBIconnectionError: @"connection failure"];
        return;
    }
    
    [connection retain];
    
}


- (BOOL)parseSearchResults: (NSData *)results{
    SXMLTree *xmldata = nil;
    BOOL success = YES;
    searchcount = 0;
    
    NS_DURING
        xmldata = [[SXMLTree alloc] initFromData: results usingEncoding: NSASCIIStringEncoding];
        //NSLog(@"XML: %@", xmldata);
    NS_HANDLER
        //NSLog(@"Error initializing SXMLTree from output");
        success = NO;
    NS_ENDHANDLER
    
    if([xmldata findRoot] == nil) return NO;
    
    // First check for found items
    
    NS_DURING
        [self setWebenv:   [[xmldata childWithPath: @"/eSearchResult/WebEnv"]nodeText]];
        [self setQuerykey: [[xmldata childWithPath: @"/eSearchResult/QueryKey"]nodeText]];
            searchcount = [[[xmldata childWithPath: @"/eSearchResult/Count"]nodeText] intValue];
        
        //NSLog(@"%@", [[xmldata childWithPath: @"/eSearchResult/Count"]nodeText]);
        //NSLog(@"%@", [[xmldata childWithPath: @"/eSearchResult/WebEnv"]nodeText]);
        //NSLog(@"%@", [[xmldata childWithPath: @"/eSearchResult/QueryKey"]nodeText]);
    NS_HANDLER
        //NSLog(@"Error extracting webenv");
        success = NO;
    NS_ENDHANDLER
    
    [self cleanupDownload];
    return success;

}

- (void)retrieveSummaries{
    // PREPARE
    //[progress setIndeterminate: YES];
    [progress startAnimation: self];
    [progressTextField setStringValue: @"Receiving results from NCBI..."];
 
    summaryFetchInProgress = YES;
    
    NSString *query = [NSString stringWithFormat: @"http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=nucleotide&retmode=xml&retmax=150&retstart=%d&WebEnv=%@&query_key=%@",
        fetchedResults, [self webenv], [self querykey]];

    //NSLog(@"Retrieve: %@", query);
    
    if(!query || [query isEqualToString: @""]){
        NSBeep();
        [progressTextField setStringValue: @"Error while retrieving summaries. Please try again."];
        [self cleanupDownload];
        return;   
    }
    
    if ( ![self _canConnect] ) {
        [self NCBIconnectionError: @"not reachable"]; 
        [progressTextField setStringValue: @"Unable to contact NCBI. Please provide an internet connection."];
        return;
    }
    
    receivedData = [[NSMutableData alloc] init];
    
    NSURLRequest *theRequest = [NSURLRequest requestWithURL: [NSURL URLWithString: query]
                                                cachePolicy:  NSURLRequestReloadIgnoringCacheData
                                            timeoutInterval:  20.0];
    
    
    if ( !theRequest) {
        [progressTextField setStringValue: @"Unable to generate query. Check for any inapropriate characters in your query."];
        [self NCBIconnectionError: @"no request"]; 
        return;
    }
    
    connection = [NSURLConnection connectionWithRequest: theRequest delegate:self];
    
    if ( !connection ) {
        [progressTextField setStringValue: @"Unable to generate query. Check for any inapropriate characters in your query."];
        [self NCBIconnectionError: @"connection failure"];
        return;
    }
    
    [connection retain];
}


- (BOOL)parseSummaries: (NSData *)results{
    SXMLTree *xmldata = nil;
    SXMLTree *theXMLHitSet = nil;
    NSString *db_id = nil;
    NSString *accession = nil;
    NSString *extra = nil;
    NSString *description = nil;
    NSString *species = nil;

    BOOL success = YES;

    NS_DURING
        xmldata = [[SXMLTree alloc] initFromData: results usingEncoding: NSASCIIStringEncoding];
        //NSLog(@"XML: %@", xmldata);
    NS_HANDLER
        //NSLog(@"Error initializing SXMLTree from output");
        success = NO;
    NS_ENDHANDLER
    
    if([xmldata findRoot] == nil) return NO;
    
    // First check for found items
    
    // REMOVE PREVIOUS RESULTS
    [searchResults removeAllObjects];
    
     //TEST
     //Fetch important data from the XML entry
     //SXMLTree *theXMLOutput = [results childWithPath:@"/BlastOutput"];
     NS_DURING
     theXMLHitSet = [xmldata childWithPath: @"/eSummaryResult"];
     NS_HANDLER
     //NSLog(@"Error initializing SXMLTree from output");
     success = NO;
     NS_ENDHANDLER
     
     if(!success) return NO;        // DO THESE KIND OF CHECKS!
     
     int theHitCount  = [theXMLHitSet childCount];
     int i;
     for (i=0; i< theHitCount; i++) {
         NS_DURING
             SXMLTree *theXMLHit = [theXMLHitSet childAtIndex:i];
             db_id = [[theXMLHit childWithPath: @"Id"] nodeText];
             
             accession = [[theXMLHit childAtIndex: 1] nodeText];
           description = [[theXMLHit childAtIndex: 2] nodeText];
                 extra = [[theXMLHit childAtIndex: 3] nodeText];
               species = [[theXMLHit childAtIndex: 8] nodeText];
             
         NS_HANDLER
             //NSLog(@"Error initializing SXMLTree from output");
             success = NO;
         NS_ENDHANDLER
         
         if(db_id){
             EntrezResult *result = [[EntrezResult alloc] initWithID: [db_id intValue]];
             
             if(accession)  [result setAccession: accession];
             if(extra)      [result setExtra: extra];
             if(description)[result setDescription: description];
             if(species)    [result setSpecies: species];
             
             [searchResults addObject: result];
             [result release];
             
         } else success = NO;

     }
    
     [searchResults sortUsingSelector: @selector(sortResultsOnIdAscending:)];
     [tv reloadData];
     
     /*
     if(success && searchcount > fetchedResults + 50){
         fetchedResults += 50;
         //[searchButton setTitle: @"More"];
     } else {
         fetchedResults = 0;
         //[searchButton setTitle: @"Search"];
     }
     */
     
     [self showPreview: self];
     [self cleanupDownload];

     return success;

}

- (void)fetchResult: (EntrezResult *)result{
    // PREPARE
    [progress startAnimation: self];
    [progressTextField setStringValue: @"Retrieving record..."];
    
    fetchInProgress = YES;
    
    NSString *query = [NSString stringWithFormat: @"http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nucleotide&id=%d&retmode=xml&rettype=fasta",
        [result db_id]];
    
    //NSLog(@"Retrieve: %@", query);
    
    if(!query || [query isEqualToString: @""]){
        NSBeep();
        [progressTextField setStringValue: @"Error while retrieving record. Please try again."];
        [self cleanupDownload];
        return;   
    }
    
    if ( ![self _canConnect] ) {
        [progressTextField setStringValue: @"Unable to contact NCBI. Please provide an internet connection."];
        [self NCBIconnectionError: @"not reachable"]; 
        return;
    }
    
    receivedData = [[NSMutableData alloc] init];
    
    NSURLRequest *theRequest = [NSURLRequest requestWithURL: [NSURL URLWithString: query]
                                                cachePolicy:  NSURLRequestReloadIgnoringCacheData
                                            timeoutInterval:  20.0];
    
    if ( !theRequest) {
        [progressTextField setStringValue: @"Unable to generate query. Check for any inapropriate characters in your query."];
        [self NCBIconnectionError: @"no request"]; 
        return;
    }
    
    connection = [NSURLConnection connectionWithRequest: theRequest delegate:self];
    
    if ( !connection ) {
        [progressTextField setStringValue: @"Unable to generate query. Check for any inapropriate characters in your query."];
        [self NCBIconnectionError: @"connection failure"];
        return;
    }
    
    [connection retain];
}

- (BOOL)parseFetch: (NSData *)results{
    SXMLTree *xmldata = nil;
    NSString *seq = nil;
    
    BOOL success = YES;
    
    NS_DURING
        xmldata = [[SXMLTree alloc] initFromData: results usingEncoding: NSASCIIStringEncoding];
        //NSLog(@"XML: %@", xmldata);
    NS_HANDLER
        //NSLog(@"Error initializing SXMLTree from output");
        success = NO;
    NS_ENDHANDLER
    
    if([xmldata findRoot] == nil) return NO;
    
    // First check for found items    
    if(!success) return NO;        // DO THESE KIND OF CHECKS!
    
    //Fetch important data from the XML entry
    NS_DURING
        seq = [[xmldata childWithPath: @"/TSeqSet/TSeq/TSeq_sequence"] nodeText];
    NS_HANDLER
        success = NO;
        //NSLog(@"Error extracting sequence");
    NS_ENDHANDLER
    
    if(seq){
        int row = [tv selectedRow];
        EntrezResult *res = [searchResults objectAtIndex: row];
        NSString *name = [NSString stringWithFormat: @"%@ %@", [res accession], [res description]];
        if([name length] > 50) name = [NSString stringWithFormat: @"%@...", [name substringWithRange: NSMakeRange(0, 50)]];
                 
		id <EntrezControllerDelegate> del = [self delegate];
		if ([del respondsToSelector:@selector(insertFetchedSequence:withName:)]){
			[del insertFetchedSequence: seq withName: name]; 
		}
		
    } else success = NO;
    
    [self cleanupDownload];
    
    [NSApp endSheet: [self window] returnCode: 1];
    [[self window] orderOut: self];
    
    return success;
}

- (void)cleanupDownload{
        
    [progress stopAnimation: self];
    //[progress setIndeterminate: NO];
    //[progress setDoubleValue: 0.0];
    //[progressTextField setStringValue: @""];
    
    searchInProgress = NO;
    summaryFetchInProgress = NO;
    fetchInProgress = NO;
    
    if(receivedData != nil){
        [receivedData release];
        receivedData = nil;
    }
    
    if ( connection != nil ) {
        [connection cancel];
        [connection release];
        connection = nil;
    }
    
    if ( response != nil ) {
        [response release];
         response = nil;
    }
    
    
}

- (void)reportDownloadFailureWithError: (NSString *)errorstring{
	
}

- (void) NCBIconnectionError: (id) anError {
    /*
	// Unused now, but in case we really want to use it it would be in line with the following 
	// (taken from John Timmer's 4Peaks Ensembl plugin implementation)
    // the argument will either come in as a string, or as the NSURLConnection's
    // NSError, which we reformat
    NSMutableDictionary *tempDict;
    
    
    if ( [anError isKindOfClass: [NSError class] ] ) {
        tempDict = [NSMutableDictionary dictionaryWithObject: [anError localizedDescription] forKey: @"title"];
        [tempDict setObject: 
            NSLocalizedString( @"There were problems loading a URL from ENSEMBL.  Please check whether the ENSEMBL website is working.", @"ENSEMBL URL Loading Error description" )
                     forKey: @"description"];
        theBLASTError = [[NSError errorWithDomain: @"4Peaks  Analysis error" code: 100 userInfo: tempDict] retain];
        
    }
    else {
        if ( [anError isEqualToString: @"not reachable"] ) {
            tempDict = [NSMutableDictionary dictionaryWithObject: NSLocalizedString( @"Network Unavailable", @"No Network Error title" ) forKey: @"title"];
            [tempDict setObject: 
                NSLocalizedString( @"This search requires an active network and there is no connection currently available.  Please try again when you have network access.", @"No Network Error description" )
                         forKey: @"description"];
            theBLASTError = [ [NSError errorWithDomain: @"4Peaks  Analysis error" code: 100 userInfo: tempDict] retain];
        }
        
        if ( [anError isEqualToString: @"connection failure"] ) {
            tempDict = [NSMutableDictionary dictionaryWithObject: NSLocalizedString( @"Network Timeout", @"Network Timeout Error title") forKey: @"title"];
            [tempDict setObject: 
                NSLocalizedString( @"The attempt to reach ENSEMBL has timed out.  Please ensure that you can connect to ENSEMBL and then try again.", @"Network Timeout Error description")
                         forKey: @"description"];
            theBLASTError = [ [NSError errorWithDomain: @"4Peaks  Analysis error" code: 102 userInfo: tempDict] retain];
        }
        
    */
}



// ================================================================
#pragma mark --- DOWNLOAD ACCESSORS
// ================================================================

- (NSURLResponse *)response
{
    return response;
}

- (void)setResponse:(NSURLResponse *)newResponse
{
    [newResponse retain];
    [response release];
    response = newResponse;
}

- (NSString *)webenv
{
	return webenv;
}

- (void)setWebenv:(NSString *)newWebenv
{
	[newWebenv retain];
	[webenv release];
	webenv = newWebenv;
}

- (NSString *)querykey
{
	return querykey;
}

- (void)setQuerykey:(NSString *)newQuerykey
{
	[newQuerykey retain];
	[querykey release];
	querykey = newQuerykey;
}



// ================================================================
#pragma mark --- CONNECTION DELEGATES
// ================================================================

- (void) connection: (NSURLConnection *)theConnection didReceiveResponse: (NSURLResponse *)theresponse {
    // NSLog(@"Response: %@", theresponse);
    
    // Apple says to clear the data in the case of a redirect
    // we pretty much trust Apple on this
    [receivedData setLength: 0];
    
    // retain the response to use later
    [self setResponse: theresponse];
        
    bytesReceived = 0;
    
    [progressTextField setStringValue: @"Connected to NCBI..."];
    
}

- (void) connection: (NSURLConnection *)connection didReceiveData: (NSData *)data {
    //NSLog(@"Bytes received - %d", [data length]);

    // append the new data to the receivedData
    [receivedData appendData:data];

    bytesReceived = bytesReceived + [data length];

	if(searchInProgress) [progressTextField setStringValue: [NSString stringWithFormat: @"Receiving results from NCBI... (%dKb)", bytesReceived/1024]];
	else if (summaryFetchInProgress) [progressTextField setStringValue: [NSString stringWithFormat: @"Receiving record from NCBI... (%dKb)", bytesReceived/1024]];

		

}

- (void)connection: (NSURLConnection *)connection didFailWithError: (NSError *)error {

    // forward the actual error to our error generation routine
    [self NCBIconnectionError: error];
    [progressTextField setStringValue: [NSString stringWithFormat: @"Error: %@", [error localizedDescription]]];

    [self cleanupDownload];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    //NSLog(@"Received: %@", [NSString stringWithUTF8String: [receivedData bytes]]);
    
    if(searchInProgress){
        if([self parseSearchResults: receivedData]){
            [self cleanupDownload];
			[progressTextField setStringValue: @"Parsing received records..."];
            [self retrieveSummaries];
            
        } else {
            [self NCBIconnectionError: @"error parsing search results"];
            [progressTextField setStringValue: @"No results found."];
            [self cleanupDownload];
        }
    
    } else if (summaryFetchInProgress){
        
        if([self parseSummaries: receivedData]){
            [self cleanupDownload];
            [progressTextField setStringValue: [NSString stringWithFormat: @"%d records found.", searchcount]];
        } else {
            [self NCBIconnectionError: @"error parsing summaries"];
            [progressTextField setStringValue: @"No results found."];
            [self cleanupDownload];
        }
        
    } else if (fetchInProgress){
        if([self parseFetch: receivedData]){
            [self cleanupDownload];
            [progressTextField setStringValue: @""];
        } else {
            [self NCBIconnectionError: @"error parsing record"];
            [progressTextField setStringValue: @"Error parsing record."];
            [self cleanupDownload];
        }        
    }
}



//===========================================================================
#pragma mark -
#pragma mark ¥ GENERAL METHODS
//===========================================================================

- (BOOL)parseOutput: (NSData *)output{
	// Debugging method to parse the output, disabled here.
    /*
    SXMLTree *xmldata, *theXMLHitSet;
    NS_DURING
        xmldata = [[SXMLTree alloc] initFromData: output usingEncoding:NSASCIIStringEncoding];
    NS_HANDLER
        NSLog(@"Error initializing SXMLTree from output");
    NS_ENDHANDLER
    
    if([xmldata findRoot] == nil) return NO;
    
    [self setResults: xmldata]; 
    [xmldata release];
    
    //TEST
    //Fetch important data from the XML entry
    //SXMLTree *theXMLOutput = [results childWithPath:@"/BlastOutput"];
    NS_DURING
        theXMLHitSet = [[self results] childWithPath: @"/BlastOutput/BlastOutput_iterations/Iteration/Iteration_hits"];
    NS_HANDLER
        NSLog(@"Error initializing SXMLTree from output");
    NS_ENDHANDLER
    
    int theHitCount  = [theXMLHitSet childCount];
    int i;
    for (i=0; i< theHitCount; i++) {
        NS_DURING
            SXMLTree *theXMLHit = [theXMLHitSet childAtIndex:i];
        NS_HANDLER
            NSLog(@"Error initializing SXMLTree from output");
        NS_ENDHANDLER
        //NSLog(@"%@", [[theXMLHit childWithPath: @"Hit_def"]nodeText]);
    }
    
    // runstatistics
    
    // results
    
    // querystatistics
    return [self resultsAvailable];
     */
    return YES;
}


- (BOOL)validateMenuItem:(NSMenuItem *)anItem{
    if([[anItem title] isEqualToString: @"Recent Searches"])
		return NO;
     else return YES;
}
		

/////////////////////////////////////////////////////
// a private method to determine network availability
/////////////////////////////////////////////////////
- (BOOL) _canConnect {
    Boolean result;
    SCNetworkConnectionFlags flags;
    assert(sizeof(SCNetworkConnectionFlags) == sizeof(int));
    result = NO;
    if ( SCNetworkCheckReachabilityByName([[NSString stringWithString:@"eutils.ncbi.nlm.nih.gov"] UTF8String], &flags) ) {
        result = (flags & kSCNetworkFlagsReachable);
    }
    return result;
}

@end
