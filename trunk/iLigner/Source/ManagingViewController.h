//
//  ManagingViewController.h
//  iLigner
//
//  Created by Andrew Rambaut on 31/07/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ManagingViewController : NSViewController {
	NSManagedObjectContext *managedObjectContext;
}

@property (retain) NSManagedObjectContext *managedObjectContext;

@end
