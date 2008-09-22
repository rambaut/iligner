//
//  ILEngine.m
//  iLigner
//
//  Created by Andrew Rambaut on 09/08/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//
//  The central alignment 'engine'. This acts as a wrapper to the CoreData's ManagedObjectContext
//

#import "ILEngine.h"
#import "Alignment.h"



@implementation ILEngine

@synthesize managedObjectContext;

- (Alignment *)createAlignment
{
	Alignment *alignment = [NSEntityDescription insertNewObjectForEntityForName:@"Alignment" inManagedObjectContext:[self managedObjectContext]];
	return alignment;
}

@end
