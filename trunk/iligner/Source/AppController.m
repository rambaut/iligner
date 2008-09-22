//
//  AppController.m
//  iLigner
//
//  Created by Andrew Rambaut on 01/08/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AppController.h"
#import "PreferenceController.h"

@implementation AppController

+ (void)initialize
{
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
	
	NSData *colorAsData = [NSKeyedArchiver archivedDataWithRootObject: [NSColor whiteColor]];
	
	[defaultValues setObject: colorAsData forKey: ILAlignmentBgColorKey];
	[defaultValues setObject: [NSNumber numberWithBool:YES]  forKey: ILEmptyDocKey];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults: defaultValues];
}

- (IBAction)showPreferencePanel:(id)sender
{
	// is preferenceController nil?
	if (!preferenceController) {
		preferenceController = [[PreferenceController alloc] init];
	}
	[preferenceController showWindow:self];
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:ILEmptyDocKey];
}
@end
