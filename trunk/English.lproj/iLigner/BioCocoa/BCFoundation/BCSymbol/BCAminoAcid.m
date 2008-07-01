//
//  BCAminoAcid.m
//  BioCocoa
//
//  Created by Koen van der Drift on Sat May 10 2003.
//  Copyright (c) 2004 The BioCocoa Project. All rights reserved.
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

#import "BCAminoAcid.h"
#import	"BCStringDefinitions.h"

static  BCAminoAcid *alanineRepresentation = nil;
static  BCAminoAcid *arginineRepresentation = nil;
static  BCAminoAcid *asparagineRepresentation = nil;
static  BCAminoAcid *asparticacidRepresentation = nil;
static  BCAminoAcid *cysteineRepresentation = nil;
static  BCAminoAcid *glutamicacidRepresentation = nil;
static  BCAminoAcid *glutamineRepresentation = nil;
static  BCAminoAcid *glycineRepresentation = nil;
static  BCAminoAcid *histidineRepresentation = nil;
static  BCAminoAcid *isoleucineRepresentation = nil;
static  BCAminoAcid *leucineRepresentation = nil;
static  BCAminoAcid *lysineRepresentation = nil;
static  BCAminoAcid *methionineRepresentation = nil;
static  BCAminoAcid *phenylalanineRepresentation = nil;
static  BCAminoAcid *prolineRepresentation = nil;
static  BCAminoAcid *serineRepresentation = nil;
static  BCAminoAcid *threonineRepresentation = nil;
static  BCAminoAcid *tryptophanRepresentation = nil;
static  BCAminoAcid *tyrosineRepresentation = nil;
static  BCAminoAcid *valineRepresentation = nil;
static  BCAminoAcid *glxRepresentation = nil;
static  BCAminoAcid *asxRepresentation = nil;
static  BCAminoAcid *gapRepresentation = nil;
static  BCAminoAcid *undefinedRepresentation = nil;

static NSMutableDictionary  *aminoAcidPropertiesDict = nil;


@implementation BCAminoAcid

- (id)initWithSymbolChar:(unsigned char)aChar
{
    if ([super initWithSymbolChar:aChar])
    {
        symbolInfo = [[[BCAminoAcid aaPropertiesDict] objectForKey:[self symbolString]] copy];

		if ( nil == symbolInfo )
		{
			return nil;
		}
		
		name = [[symbolInfo objectForKey: BCSymbolNameProperty] copy];
		threeLetterCode = [[symbolInfo objectForKey: BCSymbolThreeLetterCodeProperty] copy];
		
		[self setKyteDoolittleValue: [[symbolInfo objectForKey: BCSymbolKyteDoolittleProperty] floatValue]];
		[self setHoppWoodsValue: [[symbolInfo objectForKey: BCSymbolHoppWoodsProperty] floatValue]];
		[self setpKaValue: [[symbolInfo objectForKey: BCSymbolpKaProperty] floatValue]];

		[self setMonoisotopicMass: [[symbolInfo objectForKey: BCSymbolMonoisotopicMassProperty] floatValue]];
		[self setAverageMass: [[symbolInfo objectForKey: BCSymbolAverageMassProperty] floatValue]];
	}

    return self;
}

- (void)dealloc
{   
    [symbolInfo release];
    [name release];
    [threeLetterCode release];
	
	[super dealloc];
}


+ (NSMutableDictionary *) aaPropertiesDict
{
	if ( aminoAcidPropertiesDict == nil )
	{
		NSString *filePath = [[NSBundle bundleForClass: [BCAminoAcid class]]
										pathForResource: @"aminoacids" ofType: @"plist"];
		aminoAcidPropertiesDict = [NSMutableDictionary dictionaryWithContentsOfFile: filePath];
	}
	
	return aminoAcidPropertiesDict;
}

+ (id) symbolForChar: (unsigned char)aSymbol
{
    switch ( aSymbol ) {
        
        case 'A' :
        case 'a' : {
            return [BCAminoAcid alanine];
            break;
        }

        case 'R' : 
        case 'r' : {
            return [BCAminoAcid arginine];
            break;
        }
            
        case 'N' : 
        case 'n' : {
            return [BCAminoAcid asparagine];
            break;
        }
			
        case 'D' : 
        case 'd' : {
            return [BCAminoAcid asparticacid];
            break;
        }
            
        case 'C' :
        case 'c' :  {
            return [BCAminoAcid cysteine];
            break;
        }

        case 'E' :
        case 'e' :  {
            return [BCAminoAcid glutamicacid];
            break;
        }

        case 'Q' :
        case 'q' :  {
            return [BCAminoAcid glutamine];
            break;
        }
            
        case 'G' :
        case 'g' :  {
            return [BCAminoAcid glycine];
            break;
        }

        case 'H' :
        case 'h' :  {
            return [BCAminoAcid histidine];
            break;
        }

        case 'I' :
        case 'i' :  {
            return [BCAminoAcid isoleucine];
            break;
        }

        case 'L' :
        case 'l' :  {
            return [BCAminoAcid leucine];
            break;
        }

        case 'K' :
        case 'k' :  {
            return [BCAminoAcid lysine];
            break;
        }

        case 'M' :
        case 'm' :  {
            return [BCAminoAcid methionine];
            break;
        }

        case 'F' :
        case 'f' :  {
            return [BCAminoAcid phenylalanine];
            break;
        }

        case 'P' :
        case 'p' :  {
            return [BCAminoAcid proline];
            break;
        }

        case 'S' :
        case 's' :  {
            return [BCAminoAcid serine];
            break;
        }

        case 'T' :
        case 't' :  {
            return [BCAminoAcid threonine];
            break;
        }
            
            
        case 'W' :
        case 'w' :  {
            return [BCAminoAcid tryptophan];
            break;
        }

		case 'Y' :
        case 'y' :  {
            return [BCAminoAcid tyrosine];
            break;
        }

        case 'V' :
        case 'v' :  {
            return [BCAminoAcid valine];
            break;
        }
            
        case 'B' :
        case 'b' : {
            return [BCAminoAcid asx];
            break;
        }
			
        case 'Z' :
        case 'z' : {
            return [BCAminoAcid glx];
            break;
        }
			
        case '-' :  {
            return [BCAminoAcid gap];
            break;
        }
		
        case '*' :  {
            return nil; // stop amino acid
            break;
        }

        default :
            return [BCAminoAcid undefined];
    } 
}



+ (id) objectForSavedRepresentation: (NSString *)aSymbol {
    return [BCAminoAcid symbolForChar: [aSymbol characterAtIndex: 0]];
}


+ (void) initAminoAcids
{
	NSDictionary	*aaDefinitions = [BCAminoAcid aaPropertiesDict];
	
	NSDictionary *tempDict = [aaDefinitions objectForKey: @"A"];
    if ( tempDict != nil  && [tempDict isKindOfClass: [NSDictionary class]] ) {
        alanineRepresentation = [[BCAminoAcid alloc] initWithSymbolChar: 'A'];
    }
    
    tempDict = [aaDefinitions objectForKey: @"R"];
    if ( tempDict != nil  && [tempDict isKindOfClass: [NSDictionary class]] ) {
        arginineRepresentation = [[BCAminoAcid alloc]  initWithSymbolChar: 'R'];
    }
    
    tempDict = [aaDefinitions objectForKey: @"N"];
    if ( tempDict != nil  && [tempDict isKindOfClass: [NSDictionary class]] ) {
        asparagineRepresentation = [[BCAminoAcid alloc]  initWithSymbolChar: 'N'];
    }

    tempDict = [aaDefinitions objectForKey: @"D"];
    if ( tempDict != nil  && [tempDict isKindOfClass: [NSDictionary class]] ) {
        asparticacidRepresentation = [[BCAminoAcid alloc]  initWithSymbolChar: 'D'];
    }
    
    tempDict = [aaDefinitions objectForKey: @"C"];
    if ( tempDict != nil  && [tempDict isKindOfClass: [NSDictionary class]] ) {
        cysteineRepresentation = [[BCAminoAcid alloc]  initWithSymbolChar: 'C'];
    }
    
    tempDict = [aaDefinitions objectForKey: @"E"];
    if ( tempDict != nil  && [tempDict isKindOfClass: [NSDictionary class]] ) {
        glutamicacidRepresentation = [[BCAminoAcid alloc]  initWithSymbolChar: 'E'];
    }
	
    tempDict = [aaDefinitions objectForKey: @"Q"];
    if ( tempDict != nil  && [tempDict isKindOfClass: [NSDictionary class]] ) {
        glutamineRepresentation = [[BCAminoAcid alloc]  initWithSymbolChar: 'Q'];
    }
    
    tempDict = [aaDefinitions objectForKey: @"G"];
    if ( tempDict != nil  && [tempDict isKindOfClass: [NSDictionary class]] ) {
        glycineRepresentation = [[BCAminoAcid alloc]  initWithSymbolChar: 'G'];
    }
    
    tempDict = [aaDefinitions objectForKey: @"H"];
    if ( tempDict != nil  && [tempDict isKindOfClass: [NSDictionary class]] ) {
        histidineRepresentation = [[BCAminoAcid alloc]  initWithSymbolChar: 'H'];
    }
    
    tempDict = [aaDefinitions objectForKey: @"I"];
    if ( tempDict != nil  && [tempDict isKindOfClass: [NSDictionary class]] ) {
        isoleucineRepresentation = [[BCAminoAcid alloc]  initWithSymbolChar: 'I'];
    }
    
    tempDict = [aaDefinitions objectForKey: @"L"];
    if ( tempDict != nil  && [tempDict isKindOfClass: [NSDictionary class]] ) {
        leucineRepresentation = [[BCAminoAcid alloc]  initWithSymbolChar: 'L'];
    }
    
    tempDict = [aaDefinitions objectForKey: @"K"];
    if ( tempDict != nil  && [tempDict isKindOfClass: [NSDictionary class]] ) {
        lysineRepresentation = [[BCAminoAcid alloc]  initWithSymbolChar: 'K'];
    }
    
    tempDict = [aaDefinitions objectForKey: @"M"];
    if ( tempDict != nil  && [tempDict isKindOfClass: [NSDictionary class]] ) {
        methionineRepresentation = [[BCAminoAcid alloc]  initWithSymbolChar: 'M'];
    }
    
    tempDict = [aaDefinitions objectForKey: @"F"];
    if ( tempDict != nil  && [tempDict isKindOfClass: [NSDictionary class]] ) {
        phenylalanineRepresentation = [[BCAminoAcid alloc]  initWithSymbolChar: 'F'];
    }
    
    tempDict = [aaDefinitions objectForKey: @"P"];
    if ( tempDict != nil  && [tempDict isKindOfClass: [NSDictionary class]] ) {
        prolineRepresentation = [[BCAminoAcid alloc]  initWithSymbolChar: 'P'];
    }
    
    tempDict = [aaDefinitions objectForKey: @"S"];
    if ( tempDict != nil  && [tempDict isKindOfClass: [NSDictionary class]] ) {
        serineRepresentation = [[BCAminoAcid alloc]  initWithSymbolChar: 'S'];
    }
    
    tempDict = [aaDefinitions objectForKey: @"T"];
    if ( tempDict != nil  && [tempDict isKindOfClass: [NSDictionary class]] ) {
        threonineRepresentation = [[BCAminoAcid alloc]  initWithSymbolChar: 'T'];
    }
    
    tempDict = [aaDefinitions objectForKey: @"W"];
    if ( tempDict != nil  && [tempDict isKindOfClass: [NSDictionary class]] ) {
        tryptophanRepresentation = [[BCAminoAcid alloc]  initWithSymbolChar: 'W'];
    }
    
    tempDict = [aaDefinitions objectForKey: @"Y"];
    if ( tempDict != nil  && [tempDict isKindOfClass: [NSDictionary class]] ) {
        tyrosineRepresentation = [[BCAminoAcid alloc]  initWithSymbolChar: 'Y'];
    }
    
	tempDict = [aaDefinitions objectForKey: @"V"];
    if ( tempDict != nil  && [tempDict isKindOfClass: [NSDictionary class]] ) {
        valineRepresentation = [[BCAminoAcid alloc]  initWithSymbolChar: 'V'];
    }

    tempDict = [aaDefinitions objectForKey: @"B"];
    if ( tempDict != nil  && [tempDict isKindOfClass: [NSDictionary class]] ) {
        asxRepresentation = [[BCAminoAcid alloc]  initWithSymbolChar: 'B'];
    }

    tempDict = [aaDefinitions objectForKey: @"Z"];
    if ( tempDict != nil  && [tempDict isKindOfClass: [NSDictionary class]] ) {
        glxRepresentation = [[BCAminoAcid alloc]  initWithSymbolChar: 'Z'];
    }

    tempDict = [aaDefinitions objectForKey: @"-"];
    if ( tempDict != nil  && [tempDict isKindOfClass: [NSDictionary class]] ) {
        gapRepresentation = [[BCAminoAcid alloc]  initWithSymbolChar: '-'];
    }

    tempDict = [aaDefinitions objectForKey: @"?"];
    if ( tempDict != nil  && [tempDict isKindOfClass: [NSDictionary class]] ) {
        undefinedRepresentation = [[BCAminoAcid alloc]  initWithSymbolChar: '?'];
    }
}

+ (BCAminoAcid *) alanine {
    if ( alanineRepresentation == nil )
        [BCAminoAcid initAminoAcids];
    return alanineRepresentation;
}

+ (BCAminoAcid *) arginine {
    if ( arginineRepresentation == nil )
        [BCAminoAcid initAminoAcids];
    return arginineRepresentation;
}

+ (BCAminoAcid *) asparagine {
    if ( asparagineRepresentation == nil )
        [BCAminoAcid initAminoAcids];    
    return asparagineRepresentation;
}

+ (BCAminoAcid *) asparticacid {
    if ( asparticacidRepresentation == nil )
        [BCAminoAcid initAminoAcids];    
    return asparticacidRepresentation;
}

+ (BCAminoAcid *) cysteine {
    if ( cysteineRepresentation == nil )
        [BCAminoAcid initAminoAcids];
    return cysteineRepresentation;
}

+ (BCAminoAcid *) glutamicacid {
    if ( glutamicacidRepresentation == nil )
        [BCAminoAcid initAminoAcids];
    return glutamicacidRepresentation;
}


+ (BCAminoAcid *) glutamine {
    if ( glutamineRepresentation == nil )
        [BCAminoAcid initAminoAcids];
    return glutamineRepresentation;
}


+ (BCAminoAcid *) glycine {
    if ( glycineRepresentation == nil )
        [BCAminoAcid initAminoAcids];
    return glycineRepresentation;
}


+ (BCAminoAcid *) histidine {
    if ( histidineRepresentation == nil )
        [BCAminoAcid initAminoAcids];
    return histidineRepresentation;
}


+ (BCAminoAcid *) isoleucine {
    if ( isoleucineRepresentation == nil )
        [BCAminoAcid initAminoAcids];
    return isoleucineRepresentation;
}


+ (BCAminoAcid *) leucine {
    if ( leucineRepresentation == nil )
        [BCAminoAcid initAminoAcids];
    return leucineRepresentation;
}


+ (BCAminoAcid *) lysine {
    if ( lysineRepresentation == nil )
        [BCAminoAcid initAminoAcids];
    return lysineRepresentation;
}

+ (BCAminoAcid *) methionine {
    if ( methionineRepresentation == nil )
        [BCAminoAcid initAminoAcids];
    return methionineRepresentation;
}

+ (BCAminoAcid *) phenylalanine {
    if ( phenylalanineRepresentation == nil )
        [BCAminoAcid initAminoAcids];
    return phenylalanineRepresentation;
}

+ (BCAminoAcid *) proline {
    if ( prolineRepresentation == nil )
        [BCAminoAcid initAminoAcids];
    return prolineRepresentation;
}

+ (BCAminoAcid *) serine {
    if ( serineRepresentation == nil )
        [BCAminoAcid initAminoAcids];
    return serineRepresentation;
}

+ (BCAminoAcid *) threonine {
    if ( threonineRepresentation == nil )
        [BCAminoAcid initAminoAcids];
    return threonineRepresentation;
}

+ (BCAminoAcid *) tryptophan {
    if ( tryptophanRepresentation == nil )
        [BCAminoAcid initAminoAcids];
    return tryptophanRepresentation;
}

+ (BCAminoAcid *) tyrosine {
    if ( tyrosineRepresentation == nil )
        [BCAminoAcid initAminoAcids];
    return tyrosineRepresentation;
}

+ (BCAminoAcid *) valine {
    if ( valineRepresentation == nil )
        [BCAminoAcid initAminoAcids];
    return valineRepresentation;
}

+ (BCAminoAcid *) asx {
    if ( asxRepresentation == nil )
        [BCAminoAcid initAminoAcids];
    return asxRepresentation;
}

+ (BCAminoAcid *) glx {
    if ( glxRepresentation == nil )
        [BCAminoAcid initAminoAcids];
    return glxRepresentation;
}

+ (BCAminoAcid *) gap {
    if ( gapRepresentation == nil )
        [BCAminoAcid initAminoAcids];
    return gapRepresentation;
}

+ (BCAminoAcid *) undefined {
    if ( undefinedRepresentation == nil )
        [BCAminoAcid initAminoAcids];
    return undefinedRepresentation;
}


- (NSString *)threeLetterCode
{
	return threeLetterCode;
}

- (float)kyteDoolittleValue
{
	return kyteDoolittleValue;
}

- (void)setKyteDoolittleValue:(float)value
{
	kyteDoolittleValue = value;
}

- (float)hoppWoodsValue
{
	return hoppWoodsValue;
}

- (void)setHoppWoodsValue:(float)value
{
	hoppWoodsValue = value;
}

- (float)pKaValue
{
	return pKaValue;
}

- (void)setpKaValue:(float)value
{
	pKaValue = value;
}


@end
