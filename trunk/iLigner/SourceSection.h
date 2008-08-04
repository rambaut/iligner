//
//  SourceSection.h
//  iLigner
//
//  Created by Andrew Rambaut on 04/08/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "SourceNode.h"


@interface SourceSection :  SourceNode  
{
}

@property (retain) NSNumber * canExpand;
@property (retain) NSNumber * isExpanded;
@property (retain) NSNumber * isSpecialSection;
@property (retain) NSNumber * canCollapse;

@end


