//
//  MyDocument.h
//  iLigner
//
//  Created by Andrew Rambaut on 01/07/2008.
//  Copyright __MyCompanyName__ 2008 . All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ILEngine;
@class AlignmentViewController;
@class SequencesViewController;

@interface ILDocument : NSPersistentDocument {
	IBOutlet NSBox*				box;
	
	ILEngine*					alignmentEngine;

	AlignmentViewController*	alignmentViewController;
	SequencesViewController*	sequencesViewController;
} 

@property (assign) ILEngine *alignmentEngine;

@end


