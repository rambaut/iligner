//
// File:	   AlignmentViewController.h
//
// Abstract:   Controls the collection view of icons.
//
// Version:    1.0
//

#import <Cocoa/Cocoa.h>

@interface IconViewBox : NSBox
@end

@interface MyScrollView : NSScrollView
{
	NSGradient *backgroundGradient;
}
@end

@interface AlignmentViewController : NSViewController
{
	IBOutlet NSCollectionView	*collectionView;
	IBOutlet NSArrayController	*arrayController;
    NSMutableArray				*images;
	
	NSUInteger					sortingMode;
	BOOL						alternateColors;
	
	NSArray						*savedAlternateColors;
}

@property(retain) NSMutableArray *images;
@property(assign) NSUInteger sortingMode;
@property(assign) BOOL alternateColors;

@end
