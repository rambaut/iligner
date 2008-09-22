//
//  SourcesController.m
//  iLigner
//
//  Created by Andrew Rambaut on 04/08/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SourcesController.h"
#import "AlignmentViewController.h"
#import "SequencesViewController.h"
#import "Alignment.h"

#import "ChildNode.h"
#import "ImageAndTextCell.h"
#import "SeparatorCell.h"

#define COLUMNID_NAME			@"NameColumn"	// the single column name in our outline view

#define UNTITLED_NAME			@"Untitled"		// default name for added leafs
#define HTTP_PREFIX				@"http://"

// default section titles
#define ALIGNMENTS_NAME			@"ALIGNMENTS"
#define SEQUENCES_NAME			@"SEQUENCES"

NSString *kNodesPBoardType = @"ILNodePasteBoardType";

// -------------------------------------------------------------------------------
//	TreeAdditionObj
//
//	This object is used for passing data between the main and secondary thread
//	which populates the outline view.
// -------------------------------------------------------------------------------
@interface TreeAdditionObj : NSObject
{
	NSIndexPath *indexPath;
	NSString	*nodeName;
	Alignment	*alignment;
	BOOL		selectItsParent;
}

@property (readonly) NSIndexPath *indexPath;
@property (readonly) NSString *nodeName;
@property (readonly) Alignment *alignment;
@property (readonly) BOOL selectItsParent;
@end

@implementation TreeAdditionObj
@synthesize indexPath, nodeName, alignment, selectItsParent;

// -------------------------------------------------------------------------------
- (id)initWithName:(NSString *)name selectItsParent:(BOOL)select
{
	return [self initWithName:name withAlignment:nil selectItsParent:select];
}

// -------------------------------------------------------------------------------
- (id)initWithName:(NSString *)name withAlignment:(Alignment *)a selectItsParent:(BOOL)select
{
	self = [super init];
	
	nodeName = name;
	selectItsParent = select;
	alignment = a;
	
	return self;
}
@end

@implementation SourcesController

@synthesize dragNodesArray;

// -------------------------------------------------------------------------------
//	init
// -------------------------------------------------------------------------------
-(id)init
{
	self = [super init];
	if (self)
	{
		contents = [[NSMutableArray alloc] init];
		
		// cache the reused icon images
		folderImage = [[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(kGenericFolderIcon)];
		[folderImage setSize:NSMakeSize(16,16)];
		
		urlImage = [[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(kGenericURLIcon)];
		[urlImage setSize:NSMakeSize(16,16)];
	}
	
	return self;
}

// -------------------------------------------------------------------------------
//	awakeFromNib:
// -------------------------------------------------------------------------------
- (void)awakeFromNib
{	
	// apply our custom ImageAndTextCell for rendering the first column's cells
	NSTableColumn *tableColumn = [outlineView tableColumnWithIdentifier:COLUMNID_NAME];
	ImageAndTextCell *imageAndTextCell = [[ImageAndTextCell alloc] init];
	[imageAndTextCell setEditable:YES];
	[tableColumn setDataCell:imageAndTextCell];
	
	separatorCell = [[SeparatorCell alloc] init];
    [separatorCell setEditable:NO];
	
	// build our default tree on a separate thread,
	// some portions are from disk which could get expensive depending on the size of the dictionary file:
	[NSThread detachNewThreadSelector:	@selector(populateOutlineContents:)
							 toTarget:self		// we are the target
						   withObject:nil];
	
	
	// scroll to the top in case the outline contents is very long
	[[[outlineView enclosingScrollView] verticalScroller] setFloatValue:0.0];
	[[[outlineView enclosingScrollView] contentView] scrollToPoint:NSMakePoint(0,0)];
	
	// make our outline view appear with gradient selection, and behave like the Finder, iTunes, etc.
	[outlineView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleSourceList];
	
	// drag and drop support
	[outlineView registerForDraggedTypes:[NSArray arrayWithObjects:
											kNodesPBoardType,			// our internal drag type
											NSURLPboardType,			// single url from pasteboard
											NSFilenamesPboardType,		// from Safari or Finder
											NSFilesPromisePboardType,	// from Safari or Finder (multiple URLs)
											nil]];
}

// -------------------------------------------------------------------------------
//	setContents:newContents
// -------------------------------------------------------------------------------
- (void)setContents:(NSArray*)newContents
{
	if (contents != newContents)
	{
		[contents release];
		contents = [[NSMutableArray alloc] initWithArray:newContents];
	}
}

// -------------------------------------------------------------------------------
//	contents:
// -------------------------------------------------------------------------------
- (NSMutableArray *)contents
{
	return contents;
}

// -------------------------------------------------------------------------------
//	selectParentFromSelection:
//
//	Take the currently selected node and select its parent.
// -------------------------------------------------------------------------------
- (void)selectParentFromSelection
{
	if ([[treeController selectedNodes] count] > 0)
	{
		NSTreeNode* firstSelectedNode = [[treeController selectedNodes] objectAtIndex:0];
		NSTreeNode* parentNode = [firstSelectedNode parentNode];
		if (parentNode)
		{
			// select the parent
			NSIndexPath* parentIndex = [parentNode indexPath];
			[treeController setSelectionIndexPath:parentIndex];
		}
		else
		{
			// no parent exists (we are at the top of tree), so make no selection in our outline
			NSArray* selectionIndexPaths = [treeController selectionIndexPaths];
			[treeController removeSelectionIndexPaths:selectionIndexPaths];
		}
	}
}

// -------------------------------------------------------------------------------
//	performAddSection:treeAddition
// -------------------------------------------------------------------------------
-(void)performAddSection:(TreeAdditionObj *)treeAddition
{
	// NSTreeController inserts objects using NSIndexPath, so we need to calculate this
	NSIndexPath *indexPath = nil;
	
	// if there is no selection, we will add a new group to the end of the contents array
	if ([[treeController selectedObjects] count] == 0)
	{
		// there's no selection so add the folder to the top-level and at the end
		indexPath = [NSIndexPath indexPathWithIndex:[contents count]];
	}
	else
	{
		// get the index of the currently selected node, then add the number its children to the path -
		// this will give us an index which will allow us to add a node to the end of the currently selected node's children array.
		//
		indexPath = [treeController selectionIndexPath];
		if ([[[treeController selectedObjects] objectAtIndex:0] isLeaf])
		{
			// user is trying to add a folder on a selected child,
			// so deselect child and select its parent for addition
			[self selectParentFromSelection];
		}
		else
		{
			indexPath = [indexPath indexPathByAddingIndex:[[[[treeController selectedObjects] objectAtIndex:0] children] count]];
		}
	}
	
	ChildNode *node = [[ChildNode alloc] init];
	[node setNodeTitle:[treeAddition nodeName]];
	
	// the user is adding a child node, tell the controller directly
	[treeController insertObject:node atArrangedObjectIndexPath:indexPath];
}

// -------------------------------------------------------------------------------
//	addSection:sectionName:
// -------------------------------------------------------------------------------
- (void)addSection:(NSString *)sectionName
{
	TreeAdditionObj *treeObjInfo = [[TreeAdditionObj alloc] initWithName:sectionName selectItsParent:NO];
	
	if (buildingOutlineView)
	{
		// add the folder to the tree controller, but on the main thread to avoid lock ups
		[self performSelectorOnMainThread:@selector(performAddSection:) withObject:treeObjInfo waitUntilDone:YES];
	}
	else
	{
		[self performAddSection:treeObjInfo];
	}
}

// -------------------------------------------------------------------------------
//	performAddChild:treeAddition
// -------------------------------------------------------------------------------
-(void)performAddChild:(TreeAdditionObj *)treeAddition
{
	if ([[treeController selectedObjects] count] > 0)
	{
		// we have a selection
		if ([[[treeController selectedObjects] objectAtIndex:0] isLeaf])
		{
			// trying to add a child to a selected leaf node, so select its parent for add
			[self selectParentFromSelection];
		}
	}
	
	// find the selection to insert our node
	NSIndexPath *indexPath;
	if ([[treeController selectedObjects] count] > 0)
	{
		// we have a selection, insert at the end of the selection
		indexPath = [treeController selectionIndexPath];
		indexPath = [indexPath indexPathByAddingIndex:[[[[treeController selectedObjects] objectAtIndex:0] children] count]];
	}
	else
	{
		// no selection, just add the child to the end of the tree
		indexPath = [NSIndexPath indexPathWithIndex:[contents count]];
	}
	
	// create a leaf node
	ChildNode *node = [[ChildNode alloc] initLeaf];
	[node setNodeTitle:[treeAddition nodeName]];
	[node setAlignment:[treeAddition alignment]];
	
	// the user is adding a child node, tell the controller directly
	[treeController insertObject:node atArrangedObjectIndexPath:indexPath];
	
	// adding a child automatically becomes selected by NSOutlineView, so keep its parent selected
	if ([treeAddition selectItsParent])
		[self selectParentFromSelection];
}

// -------------------------------------------------------------------------------
//	addChild:withName:
// -------------------------------------------------------------------------------
- (void)addChild:(NSString *)nameStr withAlignment:(Alignment *)alignment selectParent:(BOOL)select
{
	TreeAdditionObj *treeObjInfo = [[TreeAdditionObj alloc] initWithName:nameStr withAlignment:(Alignment *)alignment selectItsParent:select];
	
	if (buildingOutlineView)
	{
		// add the child node to the tree controller, but on the main thread to avoid lock ups
		[self performSelectorOnMainThread:@selector(performAddChild:) withObject:treeObjInfo waitUntilDone:YES];
	}
	else
	{
		[self performAddChild:treeObjInfo];
	}
}

// -------------------------------------------------------------------------------
//	addSeparator
// -------------------------------------------------------------------------------
- (void)addSeparator
{
	[self addChild:@"" withAlignment:nil selectParent:YES];
}

// -------------------------------------------------------------------------------
//	addAlignmentsSection:
// -------------------------------------------------------------------------------
- (void)addAlignmentsSection
{
	// insert the "Alignments" group at the top of our tree
	[self addSection:ALIGNMENTS_NAME];
	
	// add its children:
	[self addChild:@"alignment1" withAlignment:[[Alignment alloc]init] selectParent:YES];
	[self addChild:@"alignment2" withAlignment:[[Alignment alloc]init] selectParent:YES];
	[self addChild:@"alignment3" withAlignment:[[Alignment alloc]init] selectParent:YES];
	
	[self selectParentFromSelection];
}

// -------------------------------------------------------------------------------
//	addSequencesSection:
// -------------------------------------------------------------------------------
- (void)addSequencesSection
{
	// add the "Sequences" section
	[self addSection:SEQUENCES_NAME];
	
	// add its children
	[self addChild:@"All Sequences" withAlignment:nil selectParent:YES];
	[self addChild:@"Recently Added" withAlignment:nil selectParent:YES];
	
	// [self addSeparator];
	
	[self selectParentFromSelection];
}

// -------------------------------------------------------------------------------
//	populateOutlineContents:inObject
//
//	This method is being called on a separate thread to avoid blocking the UI
//	a startup time.
// -------------------------------------------------------------------------------
- (void)populateOutlineContents:(id)inObject
{
	buildingOutlineView = YES;		// indicate to ourselves we are building the default tree at startup
	
	[outlineView setHidden:YES];	// hide the outline view - don't show it as we are building the contents
	
	[self addSequencesSection];		// add the "Sequences" section
	[self addAlignmentsSection];	// add the "Alignments" section
	
	buildingOutlineView = NO;		// we're done building our default tree
	
	// remove the current selection
	NSArray *selection = [treeController selectionIndexPaths];
	[treeController removeSelectionIndexPaths:selection];
	
	[outlineView setHidden:NO];	// we are done populating the outline view content, show it again
}

// -------------------------------------------------------------------------------
//	isSpecialGroup:
// -------------------------------------------------------------------------------
- (BOOL)isSpecialGroup:(BaseNode *)groupNode
{ 
	return ([groupNode nodeIcon] == nil &&
			[[groupNode nodeTitle] isEqualToString:ALIGNMENTS_NAME] || [[groupNode nodeTitle] isEqualToString:SEQUENCES_NAME]);
}


// -------------------------------------------------------------------------------
//	newAlignment:sender
// -------------------------------------------------------------------------------
- (IBAction)newAlignment:(id)sender;
{
//	Alignment *alignment = [document newAlignment];
//	static NSUInteger count = 0;
//	alignment.displayName = [NSString stringWithFormat:@"Alignment %i",++count];
//	[treeController insertObject:alignment atArrangedObjectIndexPath:[treeController indexPathForInsertion]];
}

@end

#pragma mark - NSOutlineView delegate
@implementation SourcesController (NSOutlineViewDelegate)
// -------------------------------------------------------------------------------
//	shouldSelectItem:item
// -------------------------------------------------------------------------------
- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item;
{
	// don't allow special group nodes (Devices and Places) to be selected
	BaseNode* node = [item representedObject];
	return (![self isSpecialGroup:node]);
}

// -------------------------------------------------------------------------------
//	dataCellForTableColumn:tableColumn:row
// -------------------------------------------------------------------------------
- (NSCell *)outlineView:(NSOutlineView *)outlineView dataCellForTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
	NSCell* returnCell = [tableColumn dataCell];
	
	if ([[tableColumn identifier] isEqualToString:COLUMNID_NAME])
	{
		// we are being asked for the cell for the single and only column
		BaseNode* node = [item representedObject];
		if ([node nodeIcon] == nil && [[node nodeTitle] length] == 0)
			returnCell = separatorCell;
	}
	
	return returnCell;
}

// -------------------------------------------------------------------------------
//	textShouldEndEditing:
// -------------------------------------------------------------------------------
- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
{
	if ([[fieldEditor string] length] == 0)
	{
		// don't allow empty node names
		return NO;
	}
	else
	{
		return YES;
	}
}

// -------------------------------------------------------------------------------
//	shouldEditTableColumn:tableColumn:item
//
//	Decide to allow the edit of the given outline view "item".
// -------------------------------------------------------------------------------
- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
	BOOL result = YES;
	
	item = [item representedObject];
	if ([self isSpecialGroup:item])
	{
		result = NO; // don't allow special group nodes to be renamed
	}
	
	return result;
}

// -------------------------------------------------------------------------------
//	outlineView:willDisplayCell
// -------------------------------------------------------------------------------
- (void)outlineView:(NSOutlineView *)olv willDisplayCell:(NSCell*)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{	 
	if ([[tableColumn identifier] isEqualToString:COLUMNID_NAME])
	{
		// we are displaying the single and only column
		if ([cell isKindOfClass:[ImageAndTextCell class]])
		{
			item = [item representedObject];
			if (item)
			{
				if ([item isLeaf])
				{

					[item setNodeIcon:urlImage];
					
//					// does it have a URL string?
//					NSString *urlStr = [item urlString];
//					if (urlStr)
//					{
//						if ([item isLeaf])
//						{
//							NSImage *iconImage;
//							if ([[item urlString] hasPrefix:HTTP_PREFIX])
//								iconImage = urlImage;
//							else
//								iconImage = [[NSWorkspace sharedWorkspace] iconForFile:urlStr];
//							[item setNodeIcon:iconImage];
//						}
//						else
//						{
//							NSImage* iconImage = [[NSWorkspace sharedWorkspace] iconForFile:urlStr];
//							[item setNodeIcon:iconImage];
//						}
//					}
//					else
//					{
//						// it's a separator, don't bother with the icon
//					}
				}
				else
				{
					// check if it's a special folder (DEVICES or PLACES), we don't want it to have an icon
					if ([self isSpecialGroup:item])
					{
						[item setNodeIcon:nil];
					}
					else
					{
						// it's a folder, use the folderImage as its icon
						[item setNodeIcon:folderImage];
					}
				}
			}
			
			// set the cell's image
			[(ImageAndTextCell*)cell setImage:[item nodeIcon]];
		}
	}
}

// -------------------------------------------------------------------------------
//	outlineViewSelectionDidChange:notification
// -------------------------------------------------------------------------------
- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
	if (buildingOutlineView)	// we are currently building the outline view, don't change any view selections
		return;
	
	// ask the tree controller for the current selection
	NSArray *selection = [treeController selectedObjects];
	[document sourcesSelected:selection];
}

// ----------------------------------------------------------------------------------------
// outlineView:isGroupItem:item
// ----------------------------------------------------------------------------------------
-(BOOL)outlineView:(NSOutlineView*)outlineView isGroupItem:(id)item
{
	if ([self isSpecialGroup:[item representedObject]])
	{
		return YES;
	}
	else
	{
		return NO;
	}
}


#pragma mark - NSOutlineView drag and drop

// ----------------------------------------------------------------------------------------
// draggingSourceOperationMaskForLocal <NSDraggingSource override>
// ----------------------------------------------------------------------------------------
- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)isLocal
{
	return NSDragOperationMove;
}

// ----------------------------------------------------------------------------------------
// outlineView:writeItems:toPasteboard
// ----------------------------------------------------------------------------------------
- (BOOL)outlineView:(NSOutlineView *)ov writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pboard
{
	[pboard declareTypes:[NSArray arrayWithObjects:kNodesPBoardType, nil] owner:self];
	
	// keep track of this nodes for drag feedback in "validateDrop"
	self.dragNodesArray = items;
	
	return YES;
}

// -------------------------------------------------------------------------------
//	outlineView:validateDrop:proposedItem:proposedChildrenIndex:
//
//	This method is used by NSOutlineView to determine a valid drop target.
// -------------------------------------------------------------------------------
- (NSDragOperation)outlineView:(NSOutlineView *)ov
				  validateDrop:(id <NSDraggingInfo>)info
				  proposedItem:(id)item
			proposedChildIndex:(NSInteger)index
{
	NSDragOperation result = NSDragOperationNone;
	
	if (!item)
	{
		// no item to drop on
		result = NSDragOperationGeneric;
	}
	else
	{
		if ([self isSpecialGroup:[item representedObject]])
		{
			// don't allow dragging into special grouped sections (i.e. Devices and Places)
			result = NSDragOperationNone;
		}
		else
		{	
			if (index == -1)
			{
				// don't allow dropping on a child
				result = NSDragOperationNone;
			}
			else
			{
				// drop location is a container
				result = NSDragOperationMove;
			}
		}
	}
	
	return result;
}

// -------------------------------------------------------------------------------
//	handleWebURLDrops:pboard:withIndexPath:
//
//	The user is dragging URLs from Safari.
// -------------------------------------------------------------------------------
- (void)handleWebURLDrops:(NSPasteboard *)pboard withIndexPath:(NSIndexPath *)indexPath
{
	NSArray *pbArray = [pboard propertyListForType:@"WebURLsWithTitlesPboardType"];
	NSArray *urlArray = [pbArray objectAtIndex:0];
	NSArray *nameArray = [pbArray objectAtIndex:1];
	
	NSInteger i;
	for (i = ([urlArray count] - 1); i >=0; i--)
	{
		ChildNode *node = [[ChildNode alloc] init];
		
		[node setLeaf:YES];
		[node setNodeTitle:[nameArray objectAtIndex:i]];
//		[node setURL:[urlArray objectAtIndex:i]];
		[treeController insertObject:node atArrangedObjectIndexPath:indexPath];
		
		[node release];
	}
}

// -------------------------------------------------------------------------------
//	handleInternalDrops:pboard:withIndexPath:
//
//	The user is doing an intra-app drag within the outline view.
// -------------------------------------------------------------------------------
- (void)handleInternalDrops:(NSPasteboard*)pboard withIndexPath:(NSIndexPath*)indexPath
{
	// user is doing an intra app drag within the outline view:
	//
	NSArray* newNodes = self.dragNodesArray;
	
	// move the items to their new place (we do this backwards, otherwise they will end up in reverse order)
	NSInteger i;
	for (i = ([newNodes count] - 1); i >=0; i--)
	{
		[treeController moveNode:[newNodes objectAtIndex:i] toIndexPath:indexPath];
	}
	
	// keep the moved nodes selected
	NSMutableArray* indexPathList = [NSMutableArray array];
	for (i = 0; i < [newNodes count]; i++)
	{
		[indexPathList addObject:[[newNodes objectAtIndex:i] indexPath]];
	}
	[treeController setSelectionIndexPaths: indexPathList];
}

// -------------------------------------------------------------------------------
//	handleFileBasedDrops:pboard:withIndexPath:
//
//	The user is dragging file-system based objects (probably from Finder)
// -------------------------------------------------------------------------------
- (void)handleFileBasedDrops:(NSPasteboard*)pboard withIndexPath:(NSIndexPath*)indexPath
{
	NSArray *fileNames = [pboard propertyListForType:NSFilenamesPboardType];
	if ([fileNames count] > 0)
	{
		NSInteger i;
		NSInteger count = [fileNames count];
		
		for (i = (count - 1); i >=0; i--)
		{
			NSURL* url = [NSURL fileURLWithPath:[fileNames objectAtIndex:i]];
			
			ChildNode *node = [[ChildNode alloc] init];
			
			NSString* name = [[NSFileManager defaultManager] displayNameAtPath:[url path]];
			[node setLeaf:YES];
			[node setNodeTitle:name];
//			[node setURL:[url path]];
			[treeController insertObject:node atArrangedObjectIndexPath:indexPath];
		}
	}
}

// -------------------------------------------------------------------------------
//	handleURLBasedDrops:pboard:withIndexPath:
//
//	Handle dropping a raw URL.
// -------------------------------------------------------------------------------
- (void)handleURLBasedDrops:(NSPasteboard*)pboard withIndexPath:(NSIndexPath*)indexPath
{
	NSURL *url = [NSURL URLFromPasteboard:pboard];
	if (url)
	{
		ChildNode *node = [[ChildNode alloc] init];
		
		if ([url isFileURL])
		{
			// url is file-based, use it's display name
			NSString *name = [[NSFileManager defaultManager] displayNameAtPath:[url path]];
			[node setNodeTitle:name];
//			[node setURL:[url path]];
		}
		else
		{
			// url is non-file based (probably from Safari)
			//
			// the url might not end with a valid component name, use the best possible title from the URL
			if ([[[url path] pathComponents] count] == 1)
			{
				if ([[url absoluteString] hasPrefix:HTTP_PREFIX])
				{
					// use the url portion without the prefix
					NSRange prefixRange = [[url absoluteString] rangeOfString:HTTP_PREFIX];
					NSRange newRange = NSMakeRange(prefixRange.length, [[url absoluteString] length]- prefixRange.length - 1);
					[node setNodeTitle:[[url absoluteString] substringWithRange:newRange]];
				}
				else
				{
					// prefix unknown, just use the url as its title
					[node setNodeTitle:[url absoluteString]];
				}
			}
			else
			{
				// use the last portion of the URL as its title
				[node setNodeTitle:[[url path] lastPathComponent]];
			}
			
//			[node setURL:[url absoluteString]];
		}
		[node setLeaf:YES];
		
		[treeController insertObject:node atArrangedObjectIndexPath:indexPath];
	}
}

// -------------------------------------------------------------------------------
//	outlineView:acceptDrop:item:childIndex
//
//	This method is called when the mouse is released over an outline view that previously decided to allow a drop
//	via the validateDrop method. The data source should incorporate the data from the dragging pasteboard at this time.
//	'index' is the location to insert the data as a child of 'item', and are the values previously set in the validateDrop: method.
//
// -------------------------------------------------------------------------------
- (BOOL)outlineView:(NSOutlineView*)ov acceptDrop:(id <NSDraggingInfo>)info item:(id)targetItem childIndex:(NSInteger)index
{
	// note that "targetItem" is a NSTreeNode proxy
	//
	BOOL result = NO;
	
	// find the index path to insert our dropped object(s)
	NSIndexPath *indexPath;
	if (targetItem)
	{
		// drop down inside the tree node:
		// feth the index path to insert our dropped node
		indexPath = [[targetItem indexPath] indexPathByAddingIndex:index];
	}
	else
	{
		// drop at the top root level
		if (index == -1)	// drop area might be ambibuous (not at a particular location)
			indexPath = [NSIndexPath indexPathWithIndex:[contents count]];		// drop at the end of the top level
		else
			indexPath = [NSIndexPath indexPathWithIndex:index]; // drop at a particular place at the top level
	}
	
	NSPasteboard *pboard = [info draggingPasteboard];	// get the pasteboard
	
	// check the dragging type -
	if ([pboard availableTypeFromArray:[NSArray arrayWithObject:kNodesPBoardType]])
	{
		// user is doing an intra-app drag within the outline view
		[self handleInternalDrops:pboard withIndexPath:indexPath];
		result = YES;
	}
	else if ([pboard availableTypeFromArray:[NSArray arrayWithObject:@"WebURLsWithTitlesPboardType"]])
	{
		// the user is dragging URLs from Safari
		[self handleWebURLDrops:pboard withIndexPath:indexPath];		
		result = YES;
	}
	else if ([pboard availableTypeFromArray:[NSArray arrayWithObject:NSFilenamesPboardType]])
	{
		// the user is dragging file-system based objects (probably from Finder)
		[self handleFileBasedDrops:pboard withIndexPath:indexPath];
		result = YES;
	}
	else if ([pboard availableTypeFromArray:[NSArray arrayWithObject:NSURLPboardType]])
	{
		// handle dropping a raw URL
		[self handleURLBasedDrops:pboard withIndexPath:indexPath];
		result = YES;
	}
	
	return result;
}



@end
