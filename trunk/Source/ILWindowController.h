//
//  ILWindowController.h
//  iLigner
//
//  Created by Andrew Rambaut on 04/08/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ILDocument;
@class SourcesController;

@interface ILWindowController : NSWindowController {
    IBOutlet ILDocument			*document;
	IBOutlet SourcesController	*sourcesController;
}

@end
