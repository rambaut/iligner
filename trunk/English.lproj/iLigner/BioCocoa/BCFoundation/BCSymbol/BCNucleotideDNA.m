//
//  BCNucleotideDNA.m
//  BioCocoa
//
//  Created by John Timmer on 8/11/04.
//  Copyright 2004 The BioCocoa Project. All rights reserved.
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

#import "BCNucleotideDNA.h"
#import "BCNucleotideRNA.h"


static  BCNucleotideDNA *adenosineRepresentation = nil;
static  BCNucleotideDNA *thymidineRepresentation = nil;
static  BCNucleotideDNA *cytidineRepresentation = nil;
static  BCNucleotideDNA *guanidineRepresentation = nil;
static  BCNucleotideDNA *anyBaseRepresentation = nil;
static  BCNucleotideDNA *purineRepresentation = nil;
static  BCNucleotideDNA *pyrimidineRepresentation = nil;
static  BCNucleotideDNA *strongRepresentation = nil;
static  BCNucleotideDNA *weakRepresentation = nil;
static  BCNucleotideDNA *aminoRepresentation = nil;
static  BCNucleotideDNA *ketoRepresentation = nil;
static  BCNucleotideDNA *HRepresentation = nil;
static  BCNucleotideDNA *VRepresentation = nil;
static  BCNucleotideDNA *DRepresentation = nil;
static  BCNucleotideDNA *BRepresentation = nil;
static  BCNucleotideDNA *gapRepresentation = nil;
static  BCNucleotideDNA *undefinedRepresentation = nil;

static  NSMutableDictionary *customBases = nil;


@implementation BCNucleotideDNA


#if 0
#pragma mark ‚ CLASS METHODS
#endif
////////////////////////////////////////////////////////////////////////////
//  THIS METHOD CREATES THE SINGLETON REFERENCES TO ALL THE STANDARD BASES
////////////////////////////////////////////////////////////////////////////
+ (void) initBases {
    // FIND OUR BUNDLE AND LOAD UP THE BASE DEFINITIONS
    NSBundle *biococoaBundle = [NSBundle bundleForClass: [BCNucleotideDNA class]];
    NSString *filePath = [biococoaBundle pathForResource: @"nucleotides" ofType: @"plist"];
    if ( filePath == nil )
        return;
    
    NSMutableDictionary *baseDefinitions = [NSMutableDictionary dictionaryWithContentsOfFile: filePath];
    if ( baseDefinitions == nil )
        return;
    
    customBases = [baseDefinitions retain];
    
    // GO THROUGH AND CREATE EACH SINGLETON BASE DEFINITION, USING THE DICTIONARY
    NSDictionary *tempDict = [baseDefinitions objectForKey: @"A"];
    if ( tempDict != nil  && [tempDict isKindOfClass: [NSDictionary class]] ) {
        adenosineRepresentation = [[BCNucleotideDNA alloc] initWithSymbolChar:  'A'];
        [baseDefinitions removeObjectForKey: @"A"];
    }
    
    tempDict = [baseDefinitions objectForKey: @"T"];
    if ( tempDict != nil  && [tempDict isKindOfClass: [NSDictionary class]] ) {
        thymidineRepresentation = [[BCNucleotideDNA alloc]  initWithSymbolChar:  'T'];
        [baseDefinitions removeObjectForKey: @"T"];
    }
    
    tempDict = [baseDefinitions objectForKey: @"C"];
    if ( tempDict != nil  && [tempDict isKindOfClass: [NSDictionary class]] ) {
        cytidineRepresentation = [[BCNucleotideDNA alloc]  initWithSymbolChar:  'C'];
        [baseDefinitions removeObjectForKey: @"C"];
    }
    
    tempDict = [baseDefinitions objectForKey: @"G"];
    if ( tempDict != nil  && [tempDict isKindOfClass: [NSDictionary class]] ) {
        guanidineRepresentation = [[BCNucleotideDNA alloc]  initWithSymbolChar:  'G'];
        [baseDefinitions removeObjectForKey: @"G"];
    }
    
    tempDict = [baseDefinitions objectForKey: @"N"];
    if ( tempDict != nil  && [tempDict isKindOfClass: [NSDictionary class]] ) {
        anyBaseRepresentation = [[BCNucleotideDNA alloc]  initWithSymbolChar:  'N'];
        [baseDefinitions removeObjectForKey: @"N"];
    }

    tempDict = [baseDefinitions objectForKey: @"R"];
    if ( tempDict != nil  && [tempDict isKindOfClass: [NSDictionary class]] ) {
        purineRepresentation = [[BCNucleotideDNA alloc]  initWithSymbolChar:  'R'];
        [baseDefinitions removeObjectForKey: @"R"];
    }
    
    tempDict = [baseDefinitions objectForKey: @"Y"];
    if ( tempDict != nil  && [tempDict isKindOfClass: [NSDictionary class]] ) {
        pyrimidineRepresentation = [[BCNucleotideDNA alloc]  initWithSymbolChar:  'Y'];
        [baseDefinitions removeObjectForKey: @"Y"];
    }
    
    tempDict = [baseDefinitions objectForKey: @"S"];
    if ( tempDict != nil  && [tempDict isKindOfClass: [NSDictionary class]] ) {
        strongRepresentation = [[BCNucleotideDNA alloc]  initWithSymbolChar:  'S'];
        [baseDefinitions removeObjectForKey: @"S"];
    }
    
    tempDict = [baseDefinitions objectForKey: @"W"];
    if ( tempDict != nil  && [tempDict isKindOfClass: [NSDictionary class]] ) {
        weakRepresentation = [[BCNucleotideDNA alloc]  initWithSymbolChar:  'W'];
        [baseDefinitions removeObjectForKey: @"W"];
    }
    
    tempDict = [baseDefinitions objectForKey: @"M"];
    if ( tempDict != nil  && [tempDict isKindOfClass: [NSDictionary class]] ) {
        aminoRepresentation = [[BCNucleotideDNA alloc]  initWithSymbolChar:  'M'];
        [baseDefinitions removeObjectForKey: @"M"];
    }
    
    tempDict = [baseDefinitions objectForKey: @"K"];
    if ( tempDict != nil  && [tempDict isKindOfClass: [NSDictionary class]] ) {
        ketoRepresentation = [[BCNucleotideDNA alloc]  initWithSymbolChar:  'K'];
        [baseDefinitions removeObjectForKey: @"K"];
    }
    
    tempDict = [baseDefinitions objectForKey: @"H"];
    if ( tempDict != nil  && [tempDict isKindOfClass: [NSDictionary class]] ) {
        HRepresentation = [[BCNucleotideDNA alloc]  initWithSymbolChar:  'H'];
        [baseDefinitions removeObjectForKey: @"H"];
    }
    
    tempDict = [baseDefinitions objectForKey: @"V"];
    if ( tempDict != nil  && [tempDict isKindOfClass: [NSDictionary class]] ) {
        VRepresentation = [[BCNucleotideDNA alloc]  initWithSymbolChar:  'V'];
        [baseDefinitions removeObjectForKey: @"V"];
    }
    
    tempDict = [baseDefinitions objectForKey: @"D"];
    if ( tempDict != nil  && [tempDict isKindOfClass: [NSDictionary class]] ) {
        DRepresentation = [[BCNucleotideDNA alloc]  initWithSymbolChar:  'D'];
        [baseDefinitions removeObjectForKey: @"D"];
    }
    
    tempDict = [baseDefinitions objectForKey: @"B"];
    if ( tempDict != nil  && [tempDict isKindOfClass: [NSDictionary class]] ) {
        BRepresentation = [[BCNucleotideDNA alloc]  initWithSymbolChar:  'B'];
        [baseDefinitions removeObjectForKey: @"B"];
    }
    
    tempDict = [baseDefinitions objectForKey: @"-"];
    if ( tempDict != nil  && [tempDict isKindOfClass: [NSDictionary class]] ) {
        gapRepresentation = [[BCNucleotideDNA alloc]  initWithSymbolChar:  '-'];
        [baseDefinitions removeObjectForKey: @"-"];
    }
    
    tempDict = [baseDefinitions objectForKey: @"?"];
    if ( tempDict != nil  && [tempDict isKindOfClass: [NSDictionary class]] ) {
        undefinedRepresentation = [[BCNucleotideDNA alloc]  initWithSymbolChar:  '?'];
        [baseDefinitions removeObjectForKey: @"?"];
    }
    
    // hang on to the dictionary, in case there are custom bases
    customBases = [baseDefinitions retain];
}



+ (id) objectForSavedRepresentation: (NSString *)aSymbol {
    return [BCNucleotideDNA symbolForChar: [aSymbol characterAtIndex: 0]];
}


////////////////////////////////////////////////////////////////////////////
//  THE FOLLOWING IS A METHOD FOR OBTAINING REFERENCES TO THE 
//  INDIVIDUAL BASE REPRESENTATIONS WHEN GIVEN A SINGLE LETTER CODE
//  
//  THIS WILL NOT WORK WITH CUSTOM BASES, SINCE THEIR SYMBOLS ARE NOT KNOWN IN ADVACE
////////////////////////////////////////////////////////////////////////////
+ (id) symbolForChar: (unsigned char)entry {
    switch ( entry ) {
        
        case 'A' :
        case 'a' : {
            return [BCNucleotideDNA adenosine];
            break;
        }
            
        
        case 'T' : 
        case 't' : {
            return [BCNucleotideDNA thymidine];
            break;
        }
            
        case 'C' : 
        case 'c' : {
            return [BCNucleotideDNA cytidine];
            break;
        }
        
        case 'G' : 
        case 'g' : {
            return [BCNucleotideDNA guanidine];
            break;
        }
            
        case 'N' :
        case 'n' :  {
            return [BCNucleotideDNA anyBase];
            break;
        }
            
            
        case 'R' :
        case 'r' :  {
            return [BCNucleotideDNA purine];
            break;
        }
            
            
        case 'Y' :
        case 'y' :  {
            return [BCNucleotideDNA pyrimidine];
            break;
        }
            
            
        case 'W' :
        case 'w' :  {
            return [BCNucleotideDNA weak];
            break;
        }
            
            
        case 'S' :
        case 's' :  {
            return [BCNucleotideDNA strong];
            break;
        }
            
            
        case 'M' :
        case 'm' :  {
            return [BCNucleotideDNA amino];
            break;
        }
            
            
        case 'K' :
        case 'k' :  {
            return [BCNucleotideDNA keto];
            break;
        }
            
            
        case 'H' :
        case 'h' :  {
            return [BCNucleotideDNA H];
            break;
        }
            
            
        case 'V' :
        case 'v' :  {
            return [BCNucleotideDNA V];
            break;
        }
            
            
        case 'D' :
        case 'd' :  {
            return [BCNucleotideDNA D];
            break;
        }
            
            
        case 'B' :
        case 'b' :  {
            return [BCNucleotideDNA B];
            break;
        }
            
            
        case '-' :  {
            return [BCNucleotideDNA gap];
            break;
        }
            
            
        default :
            return [BCNucleotideDNA undefined];
    } 
}



////////////////////////////////////////////////////////////////////////////
//  THE FOLLOWING ARE METHODS FOR OBTAINING REFERENCES TO THE 
//  INDIVIDUAL BASE REPRESENTATIONS
////////////////////////////////////////////////////////////////////////////

+ (BCNucleotideDNA *) adenosine {
    if ( adenosineRepresentation == nil )
        [BCNucleotideDNA initBases];
    return adenosineRepresentation;
}


+ (BCNucleotideDNA *) thymidine {
    if ( thymidineRepresentation == nil )
        [BCNucleotideDNA initBases];
    return thymidineRepresentation;
}


+ (BCNucleotideDNA *) cytidine {
    if ( cytidineRepresentation == nil )
        [BCNucleotideDNA initBases];    
    return cytidineRepresentation;
}

+ (BCNucleotideDNA *) guanidine {
    if ( guanidineRepresentation == nil )
        [BCNucleotideDNA initBases];
    return guanidineRepresentation;
}

+ (BCNucleotideDNA *) anyBase {
    if ( anyBaseRepresentation == nil )
        [BCNucleotideDNA initBases];
    return anyBaseRepresentation;
}


+ (BCNucleotideDNA *) purine {
    if ( purineRepresentation == nil )
        [BCNucleotideDNA initBases];
    return purineRepresentation;
}


+ (BCNucleotideDNA *) pyrimidine {
    if ( pyrimidineRepresentation == nil )
        [BCNucleotideDNA initBases];
    return pyrimidineRepresentation;
}


+ (BCNucleotideDNA *) strong {
    if ( strongRepresentation == nil )
        [BCNucleotideDNA initBases];
    return strongRepresentation;
}


+ (BCNucleotideDNA *) weak {
    if ( weakRepresentation == nil )
        [BCNucleotideDNA initBases];
    return weakRepresentation;
}


+ (BCNucleotideDNA *) amino {
    if ( aminoRepresentation == nil )
        [BCNucleotideDNA initBases];
    return aminoRepresentation;
}


+ (BCNucleotideDNA *) keto {
    if ( ketoRepresentation == nil )
        [BCNucleotideDNA initBases];
    return ketoRepresentation;
}

+ (BCNucleotideDNA *) H {
    if ( HRepresentation == nil )
        [BCNucleotideDNA initBases];
    return HRepresentation;
}

+ (BCNucleotideDNA *) V {
    if ( VRepresentation == nil )
        [BCNucleotideDNA initBases];
    return VRepresentation;
}

+ (BCNucleotideDNA *) D {
    if ( DRepresentation == nil )
        [BCNucleotideDNA initBases];
    return DRepresentation;
}

+ (BCNucleotideDNA *) B {
    if ( BRepresentation == nil )
        [BCNucleotideDNA initBases];
    return BRepresentation;
}

+ (BCNucleotideDNA *) gap {
    if ( gapRepresentation == nil )
        [BCNucleotideDNA initBases];
    return gapRepresentation;
}

+ (BCNucleotideDNA *) undefined {
    if ( undefinedRepresentation == nil )
        [BCNucleotideDNA initBases];
    return undefinedRepresentation;
}



+ (BCNucleotideDNA *) customBase: (NSString *)baseName {
    if ( customBases == nil )
        [BCNucleotideDNA initBases];
    id aBase = [customBases objectForKey: baseName];
    if ( aBase == nil)
        return nil;
    
    if (  [aBase isKindOfClass: [BCNucleotideDNA class]] ) 
        return aBase;
    
    
    if (  [aBase isKindOfClass: [NSDictionary class]] ) {
        aBase = [[[BCNucleotideDNA alloc] initWithDictionary: aBase] autorelease];
        if ( aBase != nil ) {
            [customBases setObject: aBase forKey: baseName];
            return aBase;
        }
    }
    return nil;
}




////////////////////////////////////////////////////////////////////////////
// OBJECT METHODS
////////////////////////////////////////////////////////////////////////////
#if 0
#pragma mark ‚ 
#pragma mark ‚ OBJECT METHODS
#pragma mark ‚ 
#pragma mark ‚INITIALIZATION METHODS
#endif


- (id) initWithSymbolChar: (unsigned char)aSymbol {
    self = [super initWithSymbolChar: aSymbol];
    if ( self == nil )
        return nil;
    
    // we hang onto the dictionary in order to establish complement realtionships
    // once all the bases are generated
    symbolInfo = [[customBases objectForKey: symbolString] copy];
    
    // get basic information about this base
    name = [symbolInfo objectForKey: @"Name"];
    if (name == nil)
        return nil;
    else
    [name retain];
    
	[self setMonoisotopicMass: [[symbolInfo objectForKey:@"MonoisotopicMass"] floatValue]];
	[self setAverageMass: [[symbolInfo objectForKey:@"AverageMass"] floatValue]];
	
    return self;
}

#if 0
#pragma mark ‚BASE INFORMATION METHODS
#endif

- (BOOL) isBase {
    if ( self == [BCNucleotideDNA gap] || self == [BCNucleotideDNA undefined] )
        return NO;
    return YES;
}

#if 0
#pragma mark ‚BASE RELATIONSHIP METHODS
#endif

- (BCNucleotideRNA *) RNABaseEquivalent {
    if ( self != [BCNucleotideDNA thymidine] )
        return [BCNucleotideRNA performSelector: NSSelectorFromString( name )];
    return [BCNucleotideRNA uridine] ;
}


@end
