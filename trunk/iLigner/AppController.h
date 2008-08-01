//
//  AppController.h
//  iLigner
//
//  Created by Andrew Rambaut on 01/08/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PreferenceController;

@interface AppController : NSObject {
	PreferenceController *preferenceController;
}

-(IBAction)showPreferencePanel:(id)sender;

@end
