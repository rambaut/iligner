//
//  BCUtilValueAdditions.m
//  BioCocoa
//
//  Created by John Timmer on 9/18/04.
//  Copyright 2004 John Timmer. All rights reserved.
//

#import "BCUtilValueAdditions.h"


@implementation NSValue (BCUtilValueAdditions)


- (NSComparisonResult) compareRanges: (NSValue *)entry {
    NSRange entryRange = [entry rangeValue];
    NSRange selfRange = [self rangeValue];
    
    
    if ( entryRange.length > selfRange.length )
        return NSOrderedAscending;
    if ( entryRange.length < selfRange.length )
        return NSOrderedDescending;
    
    // they must be equal, so sort based on location
    if ( entryRange.location > selfRange.location )
        return NSOrderedAscending;
    if ( entryRange.location < selfRange.location )
        return NSOrderedDescending;
    
    return NSOrderedSame;
}


- (NSComparisonResult) compareRangeLocations: (NSValue *)entry {
    NSRange entryRange = [entry rangeValue];
    NSRange selfRange = [self rangeValue];
    
    if ( entryRange.location > selfRange.location )
        return NSOrderedAscending;
    if ( entryRange.location < selfRange.location )
        return NSOrderedDescending;
    
    return NSOrderedSame;
}




- (NSComparisonResult) compareRangeLengths: (NSValue *)entry {
    NSRange entryRange = [entry rangeValue];
    NSRange selfRange = [self rangeValue];
    
    
    if ( entryRange.length > selfRange.length )
        return NSOrderedAscending;
    if ( entryRange.length < selfRange.length )
        return NSOrderedDescending;
    
    return NSOrderedSame;
}




@end
