//
//  Sequence.h
//  iLigner
//
//  Created by Andrew Rambaut on 31/07/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Album;

@interface Sequence :  NSManagedObject  
{
}

@property (retain) NSString * notes;
@property (retain) NSString * accession;
@property (retain) NSString * sequence;
@property (retain) NSString * name;
@property (retain) NSSet* albums;

@end

@interface Sequence (CoreDataGeneratedAccessors)
- (void)addAlbumsObject:(Album *)value;
- (void)removeAlbumsObject:(Album *)value;
- (void)addAlbums:(NSSet *)value;
- (void)removeAlbums:(NSSet *)value;

@end

