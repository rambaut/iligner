//
//  Indel.h
//  iLigner
//
//  Created by Andrew Rambaut on 31/07/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface Indel :  NSManagedObject  
{
}

@property (retain) NSNumber * length;
@property (retain) Indel * next;
@property (retain) Indel * prev;

@end


