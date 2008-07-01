//
//  BCUtilStrings.m
//  was StringAdditions.m
//
//  Created by Peter Schols on Wed Oct 22 2003.
//  Copyright 2003 The BioCocoa Project. All rights reserved.
//
//  This code is covered by the Creative Commons Share-Alike Attribution license.
//	You are free:
//	to copy, distribute, display, and perform the work
//	to make derivative works
//	to make commercial use of the work
//
//	Under the following conditions:
//	You must attribute the work in the manner specified by the author or licensor.
//	If you alter, transform, or build upon this work, you may distribute the resulting work only under a license identical to this one.
//
//	For any reuse or distribution, you must make clear to others the license terms of this work.
//	Any of these conditions can be waived if you get permission from the copyright holder.
//
//  For more info see: http://creativecommons.org/licenses/by-sa/2.5/

//  portions of this code Copyright (c) 1997-2000 by Erik Doernenburg. All rights reserved.
//
//  Permission to use, copy, modify and distribute this software and its documentation
//  is hereby granted, provided that both the copyright notice and this permission
//  notice appear in all copies of the software, derivative works or modified versions,
//  and any portions thereof, and that both notices appear in supporting documentation,
//  and that credit is given to Erik Doernenburg in all documents and publicity
//  pertaining to direct or indirect use of this code or its derivatives.


#import "BCUtilStrings.h"


@implementation NSString (StringAdditions)

+(NSString *)stringWithBytes:(const void *)bytes length: (unsigned)length encoding: (NSStringEncoding) encoding 
{
	return [[[NSString alloc] initWithBytes: bytes length: length encoding: encoding] autorelease];
}

-(BOOL)hasCaseInsensitivePrefix:(NSString *)prefix
{
    return [self rangeOfString: prefix options: (NSCaseInsensitiveSearch | NSAnchoredSearch) range: NSMakeRange(0, [prefix length])].location != NSNotFound;
}

-(BOOL)hasCaseInsensitiveSuffix:(NSString *)suffix
{
    return [self rangeOfString: suffix options: (NSCaseInsensitiveSearch | NSAnchoredSearch) range: NSMakeRange(0, [suffix length])].location != NSNotFound;
}

-(NSString *)stringByReplacingSpaceWithUnderscore
{
    NSMutableString *ms = [NSMutableString stringWithString:self];
    [ms replaceOccurrencesOfString:@" " withString:@"_" options:nil range:NSMakeRange(0, [self length])];
    return ms;
}

#ifndef GNUSTEP
-(NSString *)stringByAddingURLEscapesUsingEncoding: (CFStringEncodings) enc
{
    NSString* str2 = (id) CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, nil, nil, enc);
    if( str2 == self )
        [self release];		// CF just bumped its refcount
    else
        [str2 autorelease];
    return str2;
}
#endif

-(BOOL)stringContainsString:(NSString *)s
{
    NSRange	aRange;
    
    aRange = [self rangeOfString:s];
    
    return (aRange.location != NSNotFound);
}

-(BOOL)stringContainsCharactersFromString:(NSString *)s
{
	NSCharacterSet	*set = [NSCharacterSet characterSetWithCharactersInString: s];

	return [self stringContainsCharactersFromSet: set];
}


-(BOOL)stringContainsCharactersFromSet:(NSCharacterSet *)set
{
	return ( [self rangeOfCharacterFromSet: set].location != NSNotFound );
}


-(BOOL)stringBeginsWithTwoNumbers
{
	NSScanner   *scanner = [NSScanner scannerWithString: self];
	
	if ([scanner scanInt:nil])
	{
		if ([scanner scanInt:nil])
			return YES;
		else
			return NO;
	}
	
	else
		return NO;
}


-(NSMutableArray *)splitLines
{
    NSMutableArray	*arrayOfLines = [[NSMutableArray alloc] init];

/* 
	unsigned	start;
	unsigned	stringLength = [self length];
    NSRange		lineRange = NSMakeRange(0, 0);
    NSRange		searchRange = NSMakeRange(0, 0);
    
    while ( searchRange.location < stringLength )
    {
		[self getLineStart:&start end: &searchRange.location contentsEnd: &end forRange: searchRange];
		lineRange.length = searchRange.location - lineRange.location;

		[arrayOfLines addObject:[self substringWithRange: lineRange]];
		lineRange.location = searchRange.location;
    }
*/

	unsigned start; 
	unsigned end; 
	unsigned next; 
	unsigned stringLength; 
	NSRange range; 

	stringLength = [self length]; 
	range.location = 0; 
	range.length = 1; 

	do
	{ 
		[self getLineStart:&start end:&next contentsEnd:&end forRange:range]; 

		range.location = start; 
		range.length = end-start; 

		[arrayOfLines addObject: [self substringWithRange:range]]; 

		range.location = next; 
		range.length = 1; 
	} while (next < stringLength); 

    return [arrayOfLines autorelease];
}


- (NSString *)stringByRemovingWhitespace
{
    return [self stringByRemovingCharactersFromSet:[NSCharacterSet whitespaceCharacterSet]];
}


- (NSString *)stringByRemovingWhitespaceAndNewline
{
    return [self stringByRemovingCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)stringByRemovingCharactersFromSet:(NSCharacterSet *)set
{
    NSMutableString	*temp;

    if ( [self rangeOfCharacterFromSet:set options: NSLiteralSearch].length == 0 )
        return self;
    
    temp = [[self mutableCopyWithZone:[self zone]] autorelease];
    [temp removeCharactersInSet:set];

    return temp;
}

//- (NSString *) stringByRemovingRichTextFromString: (NSString *) inputString
//{
//	if ([inputString hasCaseInsensitivePrefix: @"{\\rtf1"])
//	{
//		NSAttributedString *rtfstring = [[NSAttributedString alloc]initWithRTF: inputString documentAttributes: nil];
//		inputString = [rtfstring string];
//		[rtfstring release];
//	}
//	
//	return inputString;
//}

- (NSString *) bracketedStringWithLeftBracket: (NSString *)leftBracket rightBracket: (NSString *)rightBracket caseSensitive: (BOOL)caseSensitive {
    
    if ( caseSensitive ) {
        NSRange startRange = [self rangeOfString: leftBracket];
        if ( startRange.location == NSNotFound ) return nil;
        int  startPosition = startRange.location + startRange.length;
        
        NSRange endRange = [self rangeOfString: rightBracket options: 0 range: NSMakeRange(startPosition, ([self length] - startPosition))];
        if ( endRange.location == NSNotFound ) return nil;
        
        if ( startPosition >= endRange.location ) return @"";
        
        return [self substringWithRange: NSMakeRange( startPosition, endRange.location - startPosition) ];
        
    } else {
        NSRange startRange = [self rangeOfString: leftBracket options: NSCaseInsensitiveSearch];
        if ( startRange.location == NSNotFound ) return nil;
        int  startPosition = startRange.location + startRange.length;
        
        NSRange endRange = [self rangeOfString: rightBracket options: NSCaseInsensitiveSearch range: NSMakeRange(startPosition, ([self length] - startPosition))];
        if ( endRange.location == NSNotFound ) return nil;
        
        if ( startPosition >= endRange.location ) return @"";
        
        return [self substringWithRange: NSMakeRange( startPosition, endRange.location - startPosition) ];
    }
    
    return nil;
}

- (NSString *)addSpacesToStringWithInterval:(int)interval
{
	return [self addSpacesToStringWithInterval: interval removeOldWhitespaces:NO];
}

- (NSString *)addSpacesToStringWithInterval:(int)interval removeOldWhitespaces:(BOOL)remove
{
    NSMutableString	*newString;
    int				i;
	
    if ( remove )
        self = [self stringByRemovingWhitespace];
	
    newString = [[self mutableCopy] autorelease];
    i = [ newString length ] - 1;
    
    while ( i > 0 )
    {
        if ( i % interval == 0 )
        {
            [newString insertString: @" " atIndex:i];
            i -= interval;
        }
        else
			i--;
    }
	
    return newString;
}

- (NSMutableString *)convertLineBreaksToMac
{
    // \r\n (Windows) becomes \r\r - \n (Unix) becomes \r
    NSMutableString *theString = [[NSMutableString alloc] initWithString: self];
	
    [theString replaceOccurrencesOfString:@"\r\n" withString:@"\r" options:nil range:NSMakeRange(0, [theString length])];
    [theString replaceOccurrencesOfString:@"\n" withString:@"\r" options:nil range:NSMakeRange(0, [theString length])];
    
	return [theString autorelease];
}

@end

@implementation NSMutableString(StringAdditions)

- (void)removeCharactersInSet:(NSCharacterSet *)set
{
    NSRange		matchRange, searchRange, replaceRange;
    unsigned int	length;

    length = [self length];
    matchRange = [self rangeOfCharacterFromSet:set options:NSLiteralSearch range:NSMakeRange(0, length)];
    
    while(matchRange.length > 0)
    {
        replaceRange = matchRange;
        searchRange.location = NSMaxRange(replaceRange);
        searchRange.length = length - searchRange.location;
        
        for(;;)
        {
            matchRange = [self rangeOfCharacterFromSet:set options:NSLiteralSearch range:searchRange];
            if((matchRange.length == 0) || (matchRange.location != searchRange.location))
                break;
            replaceRange.length += matchRange.length;
            searchRange.length -= matchRange.length;
            searchRange.location += matchRange.length;
        }
        
        [self deleteCharactersInRange:replaceRange];
        matchRange.location -= replaceRange.length;
        length -= replaceRange.length;
    }
}






@end
