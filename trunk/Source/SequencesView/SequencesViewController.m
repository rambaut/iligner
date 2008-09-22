//
//  SequencesViewController.m
//  iLigner
//
//  Created by Andrew Rambaut on 31/07/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SequencesViewController.h"


@implementation SequencesViewController

- (id)init {
	if (![super initWithNibName:@"SequencesView" bundle:nil]) {
		return nil;
	}
	[self setTitle:@"Sequences"];
	return self;
}

@end
