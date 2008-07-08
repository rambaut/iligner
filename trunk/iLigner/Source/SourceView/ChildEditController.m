//
// File:	   ChildEditController.m
//
// Abstract:   Controller object for the edit sheet panel.
//
// Version:    1.0
//

#import "ChildEditController.h"

@implementation ChildEditController

// -------------------------------------------------------------------------------
//	init:
// -------------------------------------------------------------------------------
- (id)init
{
	self = [super init];
	return self;
}

// -------------------------------------------------------------------------------
//	windowNibName:
// -------------------------------------------------------------------------------
- (NSString*)windowNibName
{
	return @"ChildEdit";
}

// -------------------------------------------------------------------------------
//	dealloc:
// -------------------------------------------------------------------------------
- (void)dealloc
{
	[super dealloc];
	[savedFields release];
}

// -------------------------------------------------------------------------------
//	edit:startingValues:from
// -------------------------------------------------------------------------------
- (NSMutableDictionary*)edit:(NSDictionary*)startingValues from:(ILDocumentController*)sender
{
	NSWindow* window = [self window];

	cancelled = NO;

	NSArray* editFields = [editForm cells];
	if (startingValues != nil)
	{
		// we are editing current entry, use its values as the default
		savedFields = [startingValues retain];

		[[editFields objectAtIndex:0] setStringValue:[startingValues objectForKey:@"name"]];
		[[editFields objectAtIndex:1] setStringValue:[startingValues objectForKey:@"url"]];
	}
	else
	{
		// we are adding a new entry,
		// make sure the form fields are empty due to the fact that this controller is recycled
		// each time the user opens the sheet -
		[[editFields objectAtIndex:0] setStringValue:@""];
		[[editFields objectAtIndex:1] setStringValue:@""];
	}
	
	[NSApp beginSheet:window modalForWindow:[sender window] modalDelegate:nil didEndSelector:nil contextInfo:nil];
	[NSApp runModalForWindow:window];
	// sheet is up here...

	[NSApp endSheet:window];
	[window orderOut:self];

	return savedFields;
}

// -------------------------------------------------------------------------------
//	done:sender
// -------------------------------------------------------------------------------
- (IBAction)done:(id)sender
{
	NSArray* editFields = [editForm cells];
	if ([[[editFields objectAtIndex:1] stringValue] length] == 0)
	{
		// you must provide a URL
		NSBeep();
		return;
	}
	
	// save the values for later
	[savedFields release];
	
	NSString* urlStr;
	if (![[[editFields objectAtIndex:1] stringValue] hasPrefix:@"http://"])
	{
		urlStr = [NSString stringWithFormat:@"http://%@", [[editFields objectAtIndex:1] stringValue]];
	}
	else
	{
		urlStr = [[editFields objectAtIndex:1] stringValue];
	}
	savedFields = [NSMutableDictionary dictionaryWithObjectsAndKeys:
							 [[editFields objectAtIndex:0] stringValue], @"name",
							 urlStr, @"url",
							 nil];
	[savedFields retain];
	
	[NSApp stopModal];
}

// -------------------------------------------------------------------------------
//	cancel:sender
// -------------------------------------------------------------------------------
- (IBAction)cancel:(id)sender
{
	[NSApp stopModal];
	cancelled = YES;
}

// -------------------------------------------------------------------------------
//	wasCancelled:
// -------------------------------------------------------------------------------
- (BOOL)wasCancelled
{
	return cancelled;
}

@end