//
//  BCUtilValueAdditions.h
//  BioCocoa
//
//  Created by John Timmer on 9/18/04.
//  Copyright 2004 John Timmer. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface NSValue (BCUtilValueAdditions)


/*!
    @method     - (NSComparisonResult) compareRanges: (NSValue *)entry
    @abstract   allows sorting of arrays based on NSRanges stored in them
    @discussion All NSValues this is sent to are treated as NSRanges.  The ranges are sorted
    *   based on a primary key of the length, secondarily based on their locations
*/
- (NSComparisonResult) compareRanges: (NSValue *)entry;


/*!
    @method     - (NSComparisonResult) compareRangeLocations: (NSValue *)entry
    @abstract   allows sorting of arrays based on NSRange locations stored in them
*/
- (NSComparisonResult) compareRangeLocations: (NSValue *)entry;

    
/*!
    @method     - (NSComparisonResult) compareRangeLengths: (NSValue *)entry
    @abstract   allows sorting of arrays based on NSRange lengths stored in them
*/
- (NSComparisonResult) compareRangeLengths: (NSValue *)entry;




@end
