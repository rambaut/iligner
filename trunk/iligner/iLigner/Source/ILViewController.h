//
//  ILViewController.h
//  iLigner
//
//  Created by Andrew Rambaut on 31/07/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ILEngine;

@interface ILViewController : NSViewController {
	ILEngine *alignmentEngine;
}

@property (assign) ILEngine *alignmentEngine;

@end
