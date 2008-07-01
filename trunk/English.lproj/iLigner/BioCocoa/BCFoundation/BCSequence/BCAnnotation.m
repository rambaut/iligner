//
//  BCAnnotation.m
//  BioCocoa
//
//  Created by Alexander Griekspoor on 22/2/2005.
//  Copyright 2005 The BioCocoa Project. All rights reserved.
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

#import "BCAnnotation.h"


@implementation BCAnnotation

////////////////////////////////////////////////////////////////////////////
//
#if 0
#pragma mark â  
#pragma mark â INITIALIZATION METHODS
#endif
//
////////////////////////////////////////////////////////////////////////////

- (id)initWithName: (NSString *)aName content: (id)theContent{
	if ( (self = [super init]) ) {
		[self setName: aName];
		[self setContent: theContent];
    }
    return self;	
}


- (id)initWithName: (NSString *)aName intValue: (int)theContent{
	return [self initWithName: aName content: [NSNumber numberWithInt:theContent]];
}

- (id)initWithName: (NSString *)aName floatValue: (float)theContent{
	return [self initWithName: aName content: [NSNumber numberWithFloat:theContent]];
}

- (id)initWithName: (NSString *)aName doubleValue: (double)theContent{
	return [self initWithName: aName content: [NSNumber numberWithDouble:theContent]];
}

- (id)initWithName: (NSString *)aName boolValue: (BOOL)theContent{
	return [self initWithName: aName content: [NSNumber numberWithBool:theContent]];
}


+ (id)annotationWithName: (NSString *)aName content: (id)theContent{
	return [[[[self class] alloc] initWithName: aName content: theContent] autorelease];
}

+ (id)annotationWithName: (NSString *)aName intValue: (int)theContent{
	return [[[[self class] alloc] initWithName: aName intValue: theContent] autorelease];
}

+ (id)annotationWithName: (NSString *)aName floatValue: (float)theContent{
	return [[[[self class] alloc] initWithName: aName floatValue: theContent] autorelease];
}

+ (id)annotationWithName: (NSString *)aName doubleValue: (double)theContent{
	return [[[[self class] alloc] initWithName: aName doubleValue: theContent] autorelease];
}

+ (id)annotationWithName: (NSString *)aName boolValue: (BOOL)theContent{
	return [[[[self class] alloc] initWithName: aName boolValue: theContent] autorelease];
}


- (id)copyWithZone:(NSZone *)zone{
	BCAnnotation *copy = [[BCAnnotation allocWithZone: zone] initWithName: [self name] content: [self content]];	
	return copy;	
}	


- (void)dealloc{    
	[name release];
	[content release];
  
    [super dealloc];
}


////////////////////////////////////////////////////////////////////////////
//
#if 0
#pragma mark â  
#pragma mark â ACCESSOR METHODS
#endif
//
////////////////////////////////////////////////////////////////////////////

- (NSString *)name{
	return name;
}

- (void)setName:(NSString *)newName{
	[newName retain];
	[name release];
	name = newName;
}


- (NSObject *)content
{
	return content;
}

- (void)setContent:(NSObject *)newContent
{
	[newContent retain];
	[content release];
	content = newContent;
}


////////////////////////////////////////////////////////////////////////////
//
#if 0
#pragma mark â  
#pragma mark â GENERAL METHODS
#endif
//
////////////////////////////////////////////////////////////////////////////

- (NSString *) description{
	return [NSString stringWithFormat: @"%@ - %@ (%@)", [self name], [self content], [self datatype]];
}

- (NSString *)datatype{
	return [[self content]className];
}


- (NSString *) stringValue{
	if([[self content]isKindOfClass: [NSString class]]) 
		return (NSString *)[self content];
	else
		return [content description];
}


- (int)intValue{
	// Set default value
	int val = 0;
	// Check if content supports intValue method
	NSMethodSignature *sig = [[[self content]class] instanceMethodSignatureForSelector: @selector(intValue)];
	if(sig){
		// Create invocation to get integer (must go through invocation if return type is of normal c type)
		NSInvocation* invocation = [NSInvocation invocationWithMethodSignature: sig];
		[invocation setSelector: @selector(intValue)];
		[invocation invokeWithTarget: [self content]];
		// Get return value of invocation into val
		[invocation getReturnValue: &val];	
	}
	return val;	
}

- (float)floatValue{
	float val = 0.0;
	NSMethodSignature *sig = [[[self content]class] instanceMethodSignatureForSelector: @selector(floatValue)];
	if(sig){
		NSInvocation* invocation = [NSInvocation invocationWithMethodSignature: sig];
		[invocation setSelector: @selector(floatValue)];
		[invocation invokeWithTarget: [self content]];
		[invocation getReturnValue: &val];		
	}
	return val;
}

- (double)doubleValue{
	double val = 0.0;
	NSMethodSignature *sig = [[[self content]class] instanceMethodSignatureForSelector: @selector(doubleValue)];
	if(sig){
		NSInvocation* invocation = [NSInvocation invocationWithMethodSignature: sig];
		[invocation setSelector: @selector(doubleValue)];
		[invocation invokeWithTarget: [self content]];
		[invocation getReturnValue: &val];		
	}
	return val;
}

- (BOOL)boolValue{
	BOOL val = NO;
	NSMethodSignature *sig = [[[self content]class] instanceMethodSignatureForSelector: @selector(boolValue)];
	if(sig){
		NSInvocation* invocation = [NSInvocation invocationWithMethodSignature: sig];
		[invocation setSelector: @selector(boolValue)];
		[invocation invokeWithTarget: [self content]];
		[invocation getReturnValue: &val];		
	}
	return val;
}


////////////////////////////////////////////////////////////////////////////
//
#if 0
#pragma mark â  
#pragma mark â COMPARISON & SORTING METHODS
#endif
//
////////////////////////////////////////////////////////////////////////////

- (BOOL)isEqualTo: (BCAnnotation *) otherAnnotation{
	return [[self name] isEqualToString: [otherAnnotation name]];
}

- (BOOL)isEqualToAnnotation: (BCAnnotation *) otherAnnotation{
	return [[self content] isEqualTo: [otherAnnotation content]];
}


- (NSComparisonResult)sortAnnotationsOnNameAscending:(BCAnnotation *) ann{
	return [[self name] compare: [ann name]];	
}

- (NSComparisonResult)sortAnnotationsOnNameDescending:(BCAnnotation *) ann{
	return [[ann name] compare: [self name]];		
}

- (NSComparisonResult)sortAnnotationsOnContentAscending:(BCAnnotation *) ann{
	NSComparisonResult val = NSOrderedSame;
	// Are both contents of the same class?
	if([[self content] isKindOfClass: [[ann content]class]]){
		// Do they respond to compare:?
		NSMethodSignature *sig = [[[self content]class] instanceMethodSignatureForSelector: @selector(compare:)];
		if(sig){
			id cont = [ann content];
			// Invoke compare and get return value
			NSInvocation* invocation = [NSInvocation invocationWithMethodSignature: sig];
			[invocation setSelector: @selector(compare:)];
			[invocation setArgument: &cont atIndex: 2];
			[invocation invokeWithTarget: [self content]];
			[invocation getReturnValue: &val];		
		}
	}
	return val;
}

- (NSComparisonResult)sortAnnotationsOnContentDescending:(BCAnnotation *) ann{
	NSComparisonResult val = NSOrderedSame;
	// Are both contents of the same class?
	if([[self content] isKindOfClass: [[ann content]class]]){
		// Do they respond to compare:?
		NSMethodSignature *sig = [[[ann content]class] instanceMethodSignatureForSelector: @selector(compare:)];
		if(sig){
			// Invoke compare and get return value
			NSInvocation* invocation = [NSInvocation invocationWithMethodSignature: sig];
			[invocation setSelector: @selector(compare:)];
			[invocation setArgument: &content atIndex: 2];
			[invocation invokeWithTarget: [ann content]];
			[invocation getReturnValue: &val];		
		}
	}
	return val;
}

@end
