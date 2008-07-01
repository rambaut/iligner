//
//  BCUtilCGI.m
//  BioCocoa
//
//  Created by John Timmer on Fri Jul 30 2004.
//  Copyright (c) 2004 The BioCocoa Project. All rights reserved.
//

#import "BCUtilCGI.h"
#import "BCUtilStrings.h"

@implementation BCUtilCGI


+ (NSDictionary *) retrieveFormData {
    // first, we find out if we received information from a "get" or a "post"
    // get places its information in the "QUERY_STRING" environment variable.
    
    NSDictionary *theEnvironment = [[NSProcessInfo processInfo] environment];
    NSString *rawData = [theEnvironment objectForKey: @"QUERY_STRING"];
    
    if ( rawData == nil || [rawData length] == 0 ) {
        // if it's equal to nil, then we've received our data from a "post" form
        // in this case, the data's been sent to stdin, and the environment variable 
        // "CONTENT_LENGTH" tells us how much data's there.
        
        NSNumber *theLength = [theEnvironment objectForKey: @"CONTENT_LENGTH"];
        if ( theLength == nil || [theLength intValue] == 0  )
            return nil;
        
        NSFileHandle *inputReader = [NSFileHandle fileHandleWithStandardInput];
        
        NSData *tempData;
        //////////////////////////////////////////////////////////////////////////////////
        // WARNING - it may be possible for stdin's buffer to fill and the app stall
        // in which case we'll try to read more than we can here
        //////////////////////////////////////////////////////////////////////////////////
        tempData = [inputReader readDataOfLength: [theLength intValue]];
        [inputReader closeFile];
        rawData= [[[NSString alloc] initWithData: tempData  encoding: NSUTF8StringEncoding] autorelease];
        
    }
    if ( rawData == nil || [rawData length] == 0 )
        return nil;
    
    rawData = [rawData stringByAddingURLEscapesUsingEncoding: NSISOLatin1StringEncoding];
    
    NSMutableDictionary *theReturn = [NSMutableDictionary dictionary];
    
    NSArray *theEntries = [rawData componentsSeparatedByString: @"&"];
    // check to see if the separator is a ; instead
    // if there is only one form element, the second method will return the same thing
    // as the first, so no harm done.
    if ( [theEntries count] == 1 )
        theEntries = [rawData componentsSeparatedByString: @";"];
    
    NSEnumerator *entryEnumerator = [theEntries objectEnumerator];
    NSString *anEntry, *tempKey, *tempValue;
    NSRange equalLocation;
    
    while ( anEntry = [entryEnumerator nextObject] ) {
        equalLocation = [anEntry rangeOfString: @"="];
        tempKey = [anEntry substringToIndex: equalLocation.location];
        
        // see if the location is the last character in the string.
        if ( equalLocation.location == [anEntry length] - 1 ) 
            [theReturn setObject: @"" forKey: tempKey];
        else {
            tempKey = [anEntry substringToIndex: equalLocation.location];
            tempValue = [anEntry substringFromIndex: equalLocation.location + 1];
            [theReturn setObject: tempValue forKey: tempKey];
        }
    }
    
    // we promised a non-mutable dictionary, so that's what we'll send
    return [[theReturn copy] autorelease];
}



+ (void) errorOutWithMessage: (NSString *)theMessage {
    // we simply stick the message between some necessary formatting for HTML output
    NSString *someOutput = @"Content-type: text/html\n\n\n\n<html><body><p><b><font size=\"+1\">";
    someOutput = [someOutput stringByAppendingString: theMessage];
    someOutput = [someOutput stringByAppendingString : @"</font></b></p></body></html>"];
    
    // create data from it and send it to stdout
    NSFileHandle *outHandle = [NSFileHandle fileHandleWithStandardOutput];
    NSData *writeBytes = [NSData dataWithBytes: [someOutput UTF8String] length: [someOutput length]];
    [outHandle writeData: writeBytes];
    [outHandle closeFile];
}







@end
