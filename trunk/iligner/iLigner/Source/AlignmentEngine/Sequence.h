//
//  Sequence.h
//  iLigner
//
//  Created by Andrew Rambaut on 04/08/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface Sequence :  NSManagedObject  
{
}

@property (retain) NSString * notes;
@property (retain) NSString * accession;
@property (retain) NSString * name;
@property (retain) NSString * sequence;

@end


