//
//  AlignmentViewController.m
//  iLigner
//
//  Created by Andrew Rambaut on 31/07/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AlignmentViewController.h"

@implementation AlignmentViewController

@dynamic rowCount, columnCount, rowHeight, columnWidth;


- (id)init {
	if (![super initWithNibName:@"AlignmentView" bundle:nil]) {
		return nil;
	}
	return self;
}

- (void)awakeFromNib {
	NSArray *upArray;
	NSArray *downArray;
	
	upArray = [NSArray arrayWithObjects:[NSNumber numberWithFloat:5.0], nil];
	downArray = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.01], nil];
	[NSRulerView registerUnitWithName:@"Nucleotides"
						 abbreviation:NSLocalizedString(@"bp", @"Nucleotides abbreviation string")
		 unitToPointsConversionFactor:10.0
						  stepUpCycle:upArray stepDownCycle:downArray];
	
	NSRulerView *rulerView = [[NSRulerView alloc]init];
	[rulerView setMeasurementUnits:@"Nucleotides"];
	[rulerView setClientView:alignmentEditorView];
	
	[scrollView setHorizontalRulerView:rulerView];
	[scrollView setRulersVisible:YES];
}

- (void) startAlignment: (Alignment*)alignment
{
	[alignmentEditorView startAlignment: alignment];
}
	
@end
