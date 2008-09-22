//
//  ILEngine.h
//  iLigner
//
//  Created by Andrew Rambaut on 09/08/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//
//  The central alignment 'engine'. This acts as a wrapper to the CoreData's ManagedObjectContext
//

#import <Cocoa/Cocoa.h>

@class Alignment;

@interface ILEngine : NSObject {
	NSManagedObjectContext *managedObjectContext;
}

@property (retain) NSManagedObjectContext *managedObjectContext;

- (Alignment *)createAlignment;

@end
