//
//  BCSequenceTransformer.h
//  BioCocoa
//
//  Created by Koen van der Drift on 9/16/2005.
//  Copyright 2005 The BioCocoa Project. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <BioCocoa/BCFoundation.h>


/*!
@class      BCSequenceTransformer
@abstract   Subclass of NSValueTransformer to convert between a BCSequence and an NSString
@discussion This class can be used eg with bindings. For now it only converts
* from a BCSequence object to a NSString object, but it can/should be extended
* to do the reverse.
*/

@interface BCSequenceTransformer : NSValueTransformer
{
	
}

@end
