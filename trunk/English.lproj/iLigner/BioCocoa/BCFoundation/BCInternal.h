//
//  BCInternal.h
//  BioCocoa
//
//  Author: Scott Christley
//  Copyright (c) 2006 The BioCocoa Project. All rights reserved.
//
//  This code is covered by the Creative Commons Share-Alike Attribution license.
//	You are free:
//	to copy, distribute, display, and perform the work
//	to make derivative works
//	to make commercial use of the work
//
//	Under the following conditions:
//	You must attribute the work in the manner specified by the author or licensor.
//	If you alter, transform, or build upon this work, you may distribute the resulting
//      work only under a license identical to this one.
//
//	For any reuse or distribution, you must make clear to others the license terms of this work.
//	Any of these conditions can be waived if you get permission from the copyright holder.
//
//  For more info see: http://creativecommons.org/licenses/by-sa/2.5/


//
// CoreFoundation is significantly faster on Mac than the standard OpenStep API, but GNUstep does not
// have CoreFoundation.  We use macros pick one or the other.
//

#ifdef GNUSTEP

// Variable declarations
#define DECLARE_INDEX(variable) int variable

// Range operations
#define MAKE_RANGE(location, length) \
     NSMakeRange((location), (length))

// Array operations
#define ARRAY_GET_VALUE_AT_INDEX(array, index) \
     [(array) objectAtIndex: (index)]

#define ARRAY_APPEND_VALUE(array, object) \
     [(array) addObject: (object)]

#define ARRAY_INSERT_VALUE_AT_INDEX(array, index, object) \
     [(array) insertObject: (object) atIndex: (index)]

#define ARRAY_RANGE_CONTAINS_VALUE(array, range, object) \
     bsinternal_array_range_contains_value((array), (range), (object))

#define ARRAY_GET_COUNT(array) \
     [(array) count]

static inline BOOL 
bsinternal_array_range_contains_value(NSArray *array, NSRange range, id object)
{
  int i;
  for (i = range.location; i < range.location + range.length; ++i) {
    id o = [array objectAtIndex: i];
    if ([o isEqual: object]) return YES;
  }
  return NO;
}

// Set operations
#define SET_CONTAINS_VALUE(set, object) \
     [(set) containsObject: (object)]

// byte swapping --TODO--
#define CFSwapInt32BigToHost(x) (x)

// HFS file types --TODO--
#define NSHFSTypeOfFile(file) (file)

#else

// Variable declarations
#define DECLARE_INDEX(variable) CFIndex variable

// Range operations
#define MAKE_RANGE(location, length) \
     CFRangeMake( (location), (length) )

// Array operations
#define ARRAY_GET_VALUE_AT_INDEX(array, index) \
     CFArrayGetValueAtIndex( (CFMutableArrayRef) (array), (index) )

#define ARRAY_APPEND_VALUE(array, object) \
     CFArrayAppendValue ( (CFMutableArrayRef) (array), (object) )

#define ARRAY_INSERT_VALUE_AT_INDEX(array, index, object) \
     CFArrayInsertValueAtIndex ( (CFMutableArrayRef) (array), (index), (object) )

#define ARRAY_RANGE_CONTAINS_VALUE(array, range, object) \
     CFArrayContainsValue ( (CFArrayRef) (array), (range), (object) )

#define ARRAY_GET_COUNT(array) \
     CFArrayGetCount ( (CFArrayRef) (array) )

// Set operations
#define SET_CONTAINS_VALUE(set, object) \
     CFSetContainsValue( (CFSetRef) (set), (object));

#endif /* GNUSTEP */

