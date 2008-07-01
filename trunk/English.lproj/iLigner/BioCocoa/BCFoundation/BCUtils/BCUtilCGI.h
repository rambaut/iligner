//
//  BCUtilCGI.h
//  BioCocoa
//////////////////////////////////////////////////////////////////////////////////
//
//  Static methods that are useful when called from main() within the
//  context of a CGI app
//
//////////////////////////////////////////////////////////////////////////////////
//  Created by John Timmer on Fri Jul 30 2004.
//  Copyright (c) 2004 The BioCocoa Project. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BCUtilCGI : NSObject {

}

// finds any data sent to the CGI application from the form which triggers it
// each data item is a dictionary entry with its name as the key.
// this will return nil if there was no input or trouble readin the input.
+ (NSDictionary *) retrieveFormData;

// allows an informative error message to be sent as HTML output, typically prior
// to exiting the application (it allows you to avoid having your whole application
// be a series of nested if statements before dumping any output to stdout).
+ (void) errorOutWithMessage: (NSString *)theMessage;


@end
