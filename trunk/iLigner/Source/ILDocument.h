//
//  MyDocument.h
//  iLigner
//
//  Created by Andrew Rambaut on 01/07/2008.
//  Copyright __MyCompanyName__ 2008 . All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Alignment;

@interface ILDocument : NSPersistentDocument {
}

- (Alignment *)newAlignment;

@end


