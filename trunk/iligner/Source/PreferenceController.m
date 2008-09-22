//
//  PreferenceController.m
//  iLigner
//
//  Created by Andrew Rambaut on 01/08/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PreferenceController.h"

NSString * const ILAlignmentBgColorKey = @"AlignmentBgColorKey";
NSString * const ILEmptyDocKey = @"EmptyDocumentFlag";
NSString * const ILSequenceNameFontSizeKey = @"SequenceNameFontSize";

@implementation PreferenceController

- (id)init
{
	if (![super initWithWindowNibName:@"Preferences"])
		return nil;
	return self;
}

- (NSColor *)alignmentBGColor
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSData *colorAsData = [defaults objectForKey:ILAlignmentBgColorKey];
	return [NSKeyedUnarchiver unarchiveObjectWithData:colorAsData];
}

- (BOOL)emptyDoc
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	return [defaults boolForKey:ILEmptyDocKey];
}

- (int)sequenceNameFontSize
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	return [defaults integerForKey:ILSequenceNameFontSizeKey];
}

- (void)windowDidLoad
{
}

@end
