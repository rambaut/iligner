//
//  BCNucleotideRNA.m
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

#import "BCNucleotideRNA.h"
#import "BCNucleotideDNA.h"


static  BCNucleotideRNA *adenosineRepresentation = nil;
static  BCNucleotideRNA *uridineRepresentation = nil;
static  BCNucleotideRNA *cytidineRepresentation = nil;
static  BCNucleotideRNA *guanidineRepresentation = nil;
static  BCNucleotideRNA *anyBaseRepresentation = nil;
static  BCNucleotideRNA *purineRepresentation = nil;
static  BCNucleotideRNA *pyrimidineRepresentation = nil;
static  BCNucleotideRNA *strongRepresentation = nil;
static  BCNucleotideRNA *weakRepresentation = nil;
static  BCNucleotideRNA *aminoRepresentation = nil;
static  BCNucleotideRNA *ketoRepresentation = nil;
static  BCNucleotideRNA *HRepresentation = nil;
static  BCNucleotideRNA *VRepresentation = nil;
static  BCNucleotideRNA *DRepresentation = nil;
static  BCNucleotideRNA *BRepresentation = nil;
static  BCNucleotideRNA *gapRepresentation = nil;
static  BCNucleotideRNA *undefinedRepresentation = nil;

static  NSMutableDictionary *customBases = nil;


@implementation BCNucleotideRNA


#if 0
#pragma mark â CLASS METHODS
#endif
////////////////////////////////////////////////////////////////////////////
//  THIS METHOD CREATES THE SINGLETON REFERENCES TO ALL THE STANDARD BASES
////////////////////////////////////////////////////////////////////////////
+ (void) initBases {
    // FIND OUR BUNDLE AND LOAD UP THE BASE DEFINITIONS
    NSBundle *biococoaBundle = [NSBundle bundleForClass: [BCNucleotideRNA class]];
    NSString *filePath = [biococoaBundle pathForResource: @"nucleotides" ofType: @"plist"];
    if ( filePath == nil )
        return;
    
    NSMutableString *tempString = [NSMutableString stringWithContentsOfFile: filePath];
    // we adapt the DNA setup for use as RNA by replacing the thymidines with uridines
    [tempString replaceOccurrencesOfString: @">T<" withString: @">U<" options: NSLiteralSearch range: NSMakeRange(0, [tempString length])];
    [tempString replaceOccurrencesOfString: @"thymidine" withString: @"uridine" options: NSLiteralSearch range: NSMakeRange(0, [tempString length])];
    
    
    NSMutableDictionary *baseDefinitions = [tempString propertyList];
    if ( baseDefinitions == nil )
        return;
    
    customBases = [baseDefinitions retain];
    
    // GO THROUGH AND CREATE EACH SINGLETON BASE DEFINITION, USING THE DICTIONARY
    NSDictionary *tempDict = [baseDefinitions objectForKey: @"A"];
    if ( tempDict != nil  && [tempDict isKindOfClass: [NSDictionary class]] ) {
        adenosineRepresentation = [[BCNucleotideRNA alloc] initWithSymbolChar: 'A'];
        [baseDefinitions removeObjectForKey: @"A"];
    }
    
    tempDict = [baseDefinitions objectForKey: @"U"];
    if ( tempDict != nil  && [tempDict isKindOfClass: [NSDictionary class]] ) {
        uridineRepresentation = [[BCNucleotideRNA alloc]  initWithSymbolChar: 'U'];
        [baseDefinitions removeObjectForKey: @"U"];
    }
    
    tempDict = [baseDefinitions objectForKey: @"C"];
    if ( tempDict != nil  && [tempDict isKindOfClass: [NSDictionary class]] ) {
        cytidineRepresentation = [[BCNucleotideRNA alloc]  initWithSymbolChar: 'C'];
        [baseDefinitions removeObjectForKey: @"C"];
    }
    
    tempDict = [baseDefinitions objectForKey: @"G"];
    if ( tempDict != nil  && [tempDict isKindOfClass: [NSDictionary class]] ) {
        guanidineRepresentation = [[BCNucleotideRNA alloc]  initWithSymbolChar: 'G'];
        [baseDefinitions removeObjectForKey: @"G"];
    }
    
    tempDict = [baseDefinitions objectForKey: @"N"];
    if ( tempDict != nil  && [tempDict isKindOfClass: [NSDictionary class]] ) {
        anyBaseRepresentation = [[BCNucleotideRNA alloc]  initWithSymbolChar: 'N'];
        [baseDefinitions removeObjectForKey: @"N"];
    }
    
    tempDict = [baseDefinitions objectForKey: @"R"];
    if ( tempDict != nil  && [tempDict isKindOfClass: [NSDictionary class]] ) {
        purineRepresentation = [[BCNucleotideRNA alloc]  initWithSymbolChar: 'R'];
        [baseDefinitions removeObjectForKey: @"R"];
    }
    
    tempDict = [baseDefinitions objectForKey: @"Y"];
    if ( tempDict != nil  && [tempDict isKindOfClass: [NSDictionary class]] ) {
        pyrimidineRepresentation = [[BCNucleotideRNA alloc]  initWithSymbolChar: 'Y'];
        [baseDefinitions removeObjectForKey: @"Y"];
    }
    
    tempDict = [baseDefinitions objectForKey: @"S"];
    if ( tempDict != nil  && [tempDict isKindOfClass: [NSDictionary class]] ) {
        strongRepresentation = [[BCNucleotideRNA alloc]  initWithSymbolChar: 'S'];
        [baseDefinitions removeObjectForKey: @"S"];
    }
    
    tempDict = [baseDefinitions objectForKey: @"W"];
    if ( tempDict != nil  && [tempDict isKindOfClass: [NSDictionary class]] ) {
        weakRepresentation = [[BCNucleotideRNA alloc]  initWithSymbolChar: 'W'];
        [baseDefinitions removeObjectForKey: @"W"];
    }
    
    tempDict = [baseDefinitions objectForKey: @"M"];
    if ( tempDict != nil  && [tempDict isKindOfClass: [NSDictionary class]] ) {
        aminoRepresentation = [[BCNucleotideRNA alloc]  initWithSymbolChar: 'M'];
        [baseDefinitions removeObjectForKey: @"M"];
    }
    
    tempDict = [baseDefinitions objectForKey: @"K"];
    if ( tempDict != nil  && [tempDict isKindOfClass: [NSDictionary class]] ) {
        ketoRepresentation = [[BCNucleotideRNA alloc]  initWithSymbolChar: 'K'];
        [baseDefinitions removeObjectForKey: @"K"];
    }
    
    tempDict = [baseDefinitions objectForKey: @"H"];
    if ( tempDict != nil  && [tempDict isKindOfClass: [NSDictionary class]] ) {
        HRepresentation = [[BCNucleotideRNA alloc]  initWithSymbolChar: 'H'];
        [baseDefinitions removeObjectForKey: @"H"];
    }
    
    tempDict = [baseDefinitions objectForKey: @"V"];
    if ( tempDict != nil  && [tempDict isKindOfClass: [NSDictionary class]] ) {
        VRepresentation = [[BCNucleotideRNA alloc]  initWithSymbolChar: 'V'];
        [baseDefinitions removeObjectForKey: @"V"];
    }
    
    tempDict = [baseDefinitions objectForKey: @"D"];
    if ( tempDict != nil  && [tempDict isKindOfClass: [NSDictionary class]] ) {
        DRepresentation = [[BCNucleotideRNA alloc]  initWithSymbolChar: 'D'];
        [baseDefinitions removeObjectForKey: @"D"];
    }
    
    tempDict = [baseDefinitions objectForKey: @"B"];
    if ( tempDict != nil  && [tempDict isKindOfClass: [NSDictionary class]] ) {
        BRepresentation = [[BCNucleotideRNA alloc]  initWithSymbolChar: 'B'];
        [baseDefinitions removeObjectForKey: @"B"];
    }
    
    tempDict = [baseDefinitions objectForKey: @"-"];
    if ( tempDict != nil  && [tempDict isKindOfClass: [NSDictionary class]] ) {
        gapRepresentation = [[BCNucleotideRNA alloc]  initWithSymbolChar: '-'];
        [baseDefinitions removeObjectForKey: @"-"];
    }
    
    tempDict = [baseDefinitions objectForKey: @"?"];
    if ( tempDict != nil  && [tempDict isKindOfClass: [NSDictionary class]] ) {
        undefinedRepresentation = [[BCNucleotideRNA alloc]  initWithSymbolChar: '?'];
        [baseDefinitions removeObjectForKey: @"?"];
    }
    
    // hang on to the dictionary, in case there are custom bases
    customBases = [baseDefinitions retain];
}



+ (id) objectForSavedRepresentation: (NSString *)aSymbol {
    return [BCNucleotideRNA symbolForChar: [aSymbol characterAtIndex: 0]];
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
            return [BCNucleotideRNA adenosine];
            break;
        }
            
            
        case 'U' : 
        case 'u' : {
            return [BCNucleotideRNA uridine];
            break;
        }
            
        case 'C' : 
        case 'c' : {
            return [BCNucleotideRNA cytidine];
            break;
        }
            
        case 'G' : 
        case 'g' : {
            return [BCNucleotideRNA guanidine];
            break;
        }
            
        case 'N' :
        case 'n' :  {
            return [BCNucleotideRNA anyBase];
            break;
        }
            
            
        case 'R' :
        case 'r' :  {
            return [BCNucleotideRNA purine];
            break;
        }
            
            
        case 'Y' :
        case 'y' :  {
            return [BCNucleotideRNA pyrimidine];
            break;
        }
            
            
        case 'W' :
        case 'w' :  {
            return [BCNucleotideRNA weak];
            break;
        }
            
            
        case 'S' :
        case 's' :  {
            return [BCNucleotideRNA strong];
            break;
        }
            
            
        case 'M' :
        case 'm' :  {
            return [BCNucleotideRNA amino];
            break;
        }
            
            
        case 'K' :
        case 'k' :  {
            return [BCNucleotideRNA keto];
            break;
        }
            
            
        case 'H' :
        case 'h' :  {
            return [BCNucleotideRNA H];
            break;
        }
            
            
        case 'V' :
        case 'v' :  {
            return [BCNucleotideRNA V];
            break;
        }
            
            
        case 'D' :
        case 'd' :  {
            return [BCNucleotideRNA D];
            break;
        }
            
            
        case 'B' :
        case 'b' :  {
            return [BCNucleotideRNA B];
            break;
        }
            
            
        case '-' :  {
            return [BCNucleotideRNA gap];
            break;
        }
            
            
        default :
            return [BCNucleotideRNA undefined];
    } 
}



////////////////////////////////////////////////////////////////////////////
//  THE FOLLOWING ARE METHODS FOR OBTAINING REFERENCES TO THE 
//  INDIVIDUAL BASE REPRESENTATIONS
////////////////////////////////////////////////////////////////////////////

+ (BCNucleotideRNA *) adenosine {
    if ( adenosineRepresentation == nil )
        [BCNucleotideRNA initBases];
    return adenosineRepresentation;
}


+ (BCNucleotideRNA *) uridine {
    if ( uridineRepresentation == nil )
        [BCNucleotideRNA initBases];
    return uridineRepresentation;
}


+ (BCNucleotideRNA *) cytidine {
    if ( cytidineRepresentation == nil )
        [BCNucleotideRNA initBases];    
    return cytidineRepresentation;
}

+ (BCNucleotideRNA *) guanidine {
    if ( guanidineRepresentation == nil )
        [BCNucleotideRNA initBases];
    return guanidineRepresentation;
}

+ (BCNucleotideRNA *) anyBase {
    if ( anyBaseRepresentation == nil )
        [BCNucleotideRNA initBases];
    return anyBaseRepresentation;
}


+ (BCNucleotideRNA *) purine {
    if ( purineRepresentation == nil )
        [BCNucleotideRNA initBases];
    return purineRepresentation;
}


+ (BCNucleotideRNA *) pyrimidine {
    if ( pyrimidineRepresentation == nil )
        [BCNucleotideRNA initBases];
    return pyrimidineRepresentation;
}


+ (BCNucleotideRNA *) strong {
    if ( strongRepresentation == nil )
        [BCNucleotideRNA initBases];
    return strongRepresentation;
}


+ (BCNucleotideRNA *) weak {
    if ( weakRepresentation == nil )
        [BCNucleotideRNA initBases];
    return weakRepresentation;
}


+ (BCNucleotideRNA *) amino {
    if ( aminoRepresentation == nil )
        [BCNucleotideRNA initBases];
    return aminoRepresentation;
}


+ (BCNucleotideRNA *) keto {
    if ( ketoRepresentation == nil )
        [BCNucleotideRNA initBases];
    return ketoRepresentation;
}

+ (BCNucleotideRNA *) H {
    if ( HRepresentation == nil )
        [BCNucleotideRNA initBases];
    return HRepresentation;
}

+ (BCNucleotideRNA *) V {
    if ( VRepresentation == nil )
        [BCNucleotideRNA initBases];
    return VRepresentation;
}

+ (BCNucleotideRNA *) D {
    if ( DRepresentation == nil )
        [BCNucleotideRNA initBases];
    return DRepresentation;
}

+ (BCNucleotideRNA *) B {
    if ( BRepresentation == nil )
        [BCNucleotideRNA initBases];
    return BRepresentation;
}

+ (BCNucleotideRNA *) gap {
    if ( gapRepresentation == nil )
        [BCNucleotideRNA initBases];
    return gapRepresentation;
}

+ (BCNucleotideRNA *) undefined {
    if ( undefinedRepresentation == nil )
        [BCNucleotideRNA initBases];
    return undefinedRepresentation;
}



+ (BCNucleotideRNA *) customBase: (NSString *)baseName {
    if ( customBases == nil )
        [BCNucleotideRNA initBases];
    id aBase = [customBases objectForKey: baseName];
    if ( aBase == nil)
        return nil;
    
    if (  [aBase isKindOfClass: [BCNucleotideRNA class]] ) 
        return aBase;
    
    
    if (  [aBase isKindOfClass: [NSDictionary class]] ) {
        aBase = [[[BCNucleotideRNA alloc] initWithDictionary: aBase] autorelease];
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
#pragma mark â 
#pragma mark â OBJECT METHODS
#pragma mark â
#pragma mark âINITIALIZATION METHODS
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
#pragma mark âBASE INFORMATION METHODS
#endif


- (BOOL) isBase {
    if ( self == [BCNucleotideRNA gap] || self == [BCNucleotideRNA undefined] )
        return NO;
    return YES;
}

#if 0
#pragma mark âBASE RELATIONSHIP METHODS
#endif

///////////////////////////////////////////////////////////
//  BASE RELATIONSHIP METHODS
///////////////////////////////////////////////////////////


- (BCNucleotideDNA *) DNABaseEquivalent {
    if ( self != [BCNucleotideRNA uridine] )
        return [BCNucleotideDNA performSelector: NSSelectorFromString( name )];
    return [BCNucleotideDNA thymidine];
}


@end
