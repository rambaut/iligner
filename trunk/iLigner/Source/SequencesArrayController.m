//
//  SequencesArrayController.m
//  iLigner
//
//  Created by Andrew Rambaut on 31/07/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SequencesArrayController.h"


@implementation SequencesArrayController

- (id)newObject {
	id newObj = [super newObject];
	[newObj setValue:@"untitled" forKey:@"name"];
	return newObj;
}

@end
