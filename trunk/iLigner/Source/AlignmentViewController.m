//
// File:	   AlignmentViewController.m
//
// Abstract:   Controls the collection view of icons.
//
// Version:    1.0
//

#import "AlignmentViewController.h"

@implementation IconViewBox

// -------------------------------------------------------------------------------
//	hitTest:aPoint
// -------------------------------------------------------------------------------
- (NSView *)hitTest:(NSPoint)aPoint
{
	// don't allow any mouse clicks for subviews in this NSBox
	return nil;
}

@end


@implementation MyScrollView

// -------------------------------------------------------------------------------
//	awakeFromNib:
// -------------------------------------------------------------------------------
- (void)awakeFromNib
{
	// set up the background gradient for this custom scrollView
	backgroundGradient = [[NSGradient alloc] initWithStartingColor:
							[NSColor colorWithDeviceRed:.349 green:.6 blue:.898 alpha:0.0]
							endingColor:[NSColor colorWithDeviceRed:.349 green:.6 blue:.898 alpha:0.6]];
}
											
// -------------------------------------------------------------------------------
//	drawRect:rect
// -------------------------------------------------------------------------------
- (void)drawRect:(NSRect)rect
{
	// draw our special background as a gradient
	[backgroundGradient drawInRect:[self bounds] angle:90.0];
}

// -------------------------------------------------------------------------------
//	dealloc:
// -------------------------------------------------------------------------------
- (void)dealloc
{
	[backgroundGradient release];
	[super dealloc];
}

@end


@implementation AlignmentViewController

@synthesize images, sortingMode, alternateColors;

#define KEY_IMAGE	@"icon"
#define KEY_NAME	@"name"

// -------------------------------------------------------------------------------
//	awakeFromNib:
// -------------------------------------------------------------------------------
-(void)awakeFromNib
{
	// save this for later when toggling between alternate colors
	savedAlternateColors = [[collectionView backgroundColors] retain];
	
	[self setSortingMode:0];		// icon collection in ascending sort order
	[self setAlternateColors:NO];	// no alternate background colors (initially use gradient background)
	
	// Determine the content of the collection view by reading in the plist "icons.plist",
	// and add extra "named" template images with the help of NSImage class.
	//
	NSBundle		*bundle = [NSBundle mainBundle];
	NSString		*path = [bundle pathForResource: @"icons" ofType: @"plist"];
	NSArray			*iconEntries = [NSArray arrayWithContentsOfFile: path];
	NSMutableArray	*tempArray = [[NSMutableArray alloc] init];
	
	// read the list of icons from disk in 'icons.plist'
	if (iconEntries != nil)
	{
		for (NSDictionary *entry in iconEntries)
		{
			if (entry != nil)
			{
				NSString *codeStr = [entry valueForKey: KEY_IMAGE];
				NSString *iconName = [entry valueForKey: KEY_NAME];

				OSType code = UTGetOSTypeFromString((CFStringRef)codeStr);
				NSImage *picture = [[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(code)];
				[tempArray addObject: [NSMutableDictionary dictionaryWithObjectsAndKeys:
											picture, KEY_IMAGE,
											iconName, KEY_NAME,
											nil]];
			}
		}
	}
	
	// now add named image templates
	[tempArray addObject: [NSMutableDictionary dictionaryWithObjectsAndKeys:
									[NSImage imageNamed:NSImageNameIconViewTemplate], KEY_IMAGE,
									NSImageNameIconViewTemplate, KEY_NAME,
									nil]];
									
	[tempArray addObject: [NSMutableDictionary dictionaryWithObjectsAndKeys:
									[NSImage imageNamed:NSImageNameBluetoothTemplate], KEY_IMAGE,
									NSImageNameBluetoothTemplate, KEY_NAME,
									nil]];
	
	[tempArray addObject: [NSMutableDictionary dictionaryWithObjectsAndKeys:
									[NSImage imageNamed:NSImageNameIChatTheaterTemplate], KEY_IMAGE,
									NSImageNameIChatTheaterTemplate, KEY_NAME,
									nil]];

	[tempArray addObject: [NSMutableDictionary dictionaryWithObjectsAndKeys:
									[NSImage imageNamed:NSImageNameSlideshowTemplate], KEY_IMAGE,
									NSImageNameSlideshowTemplate, KEY_NAME,
									nil]];
	
	[tempArray addObject: [NSMutableDictionary dictionaryWithObjectsAndKeys:
									[NSImage imageNamed:NSImageNameActionTemplate], KEY_IMAGE,
									NSImageNameActionTemplate, KEY_NAME,
									nil]];
									
	[tempArray addObject: [NSMutableDictionary dictionaryWithObjectsAndKeys:
									[NSImage imageNamed:NSImageNameSmartBadgeTemplate], KEY_IMAGE,
									NSImageNameSmartBadgeTemplate, KEY_NAME,
									nil]];
	
	// Finder icon templates
	[tempArray addObject: [NSMutableDictionary dictionaryWithObjectsAndKeys:
									[NSImage imageNamed:NSImageNameListViewTemplate], KEY_IMAGE,
									NSImageNameListViewTemplate, KEY_NAME,
									nil]];
	[tempArray addObject: [NSMutableDictionary dictionaryWithObjectsAndKeys:
									[NSImage imageNamed:NSImageNameColumnViewTemplate], KEY_IMAGE,
									NSImageNameColumnViewTemplate, KEY_NAME,
									nil]];
	[tempArray addObject: [NSMutableDictionary dictionaryWithObjectsAndKeys:
									[NSImage imageNamed:NSImageNameFlowViewTemplate], KEY_IMAGE,
									NSImageNameFlowViewTemplate, KEY_NAME,
									nil]];
	[tempArray addObject: [NSMutableDictionary dictionaryWithObjectsAndKeys:
									[NSImage imageNamed:NSImageNamePathTemplate], KEY_IMAGE,
									NSImageNamePathTemplate, KEY_NAME,
									nil]];
	
	[tempArray addObject: [NSMutableDictionary dictionaryWithObjectsAndKeys:
									[NSImage imageNamed:NSImageNameInvalidDataFreestandingTemplate], KEY_IMAGE,
									NSImageNameInvalidDataFreestandingTemplate, KEY_NAME,
									nil]];
	[tempArray addObject: [NSMutableDictionary dictionaryWithObjectsAndKeys:
									[NSImage imageNamed:NSImageNameLockLockedTemplate], KEY_IMAGE,
									NSImageNameLockLockedTemplate, KEY_NAME,
									nil]];
	[tempArray addObject: [NSMutableDictionary dictionaryWithObjectsAndKeys:
									[NSImage imageNamed:NSImageNameLockUnlockedTemplate], KEY_IMAGE,
									NSImageNameLockUnlockedTemplate, KEY_NAME,
									nil]];
									
	[self setImages:tempArray];
	[tempArray release];
}


// -------------------------------------------------------------------------------
//	dealloc:
// -------------------------------------------------------------------------------
- (void)dealloc
{
	[savedAlternateColors release];
	[super dealloc];
}

// -------------------------------------------------------------------------------
//	setAlternateColors
// -------------------------------------------------------------------------------
- (void)setAlternateColors:(BOOL)useAlternateColors
{
	alternateColors = useAlternateColors;
	if (alternateColors)
	{
		[collectionView setBackgroundColors:[NSArray arrayWithObjects:[NSColor gridColor], [NSColor lightGrayColor], nil]];
	}
	else
	{
		[collectionView setBackgroundColors:savedAlternateColors];
	}
}

// -------------------------------------------------------------------------------
//	setSortingMode:newMode
// -------------------------------------------------------------------------------
- (void)setSortingMode:(NSUInteger)newMode
{
	sortingMode = newMode;
	NSSortDescriptor *sort = [[[NSSortDescriptor alloc]
								initWithKey:KEY_NAME
								ascending:(sortingMode == 0)
								selector:@selector(caseInsensitiveCompare:)] autorelease];
	[arrayController setSortDescriptors:[NSArray arrayWithObject:sort]];
}

@end
