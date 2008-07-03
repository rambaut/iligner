//
// File:	   NSArray_Extensions.h
//
// Abstract:   Category extension to NSArray.
//
// Version:	   1.0
//

#import <Foundation/Foundation.h>

@interface NSArray (MyArrayExtensions)
- (BOOL)containsObjectIdenticalTo:(id)object;
- (BOOL)containsAnyObjectsIdenticalTo:(NSArray*)objects;
- (NSIndexSet*)indexesOfObjects:(NSArray*)objects;
@end
