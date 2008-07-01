//
//  BCUtilStringDNA.m
//  BioCocoa
//
//  Created by John Timmer on Fri Jul 16 2004.
//  Copyright (c) 2004 The BioCocoa Project. All rights reserved.
//

#import "BCUtilStringDNA.h"


@implementation BCUtilStringDNA

static BCUtilStringDNA *sharedDNASequenceObject = nil;


// we create a bunch of objects at allocation so that we don't waste time
// and memory every time we call a method
- (BCUtilStringDNA *) init {
    self = [super init];
    if ( !self )
        return nil;
    
    
    // create a dictionary of the corresponding bases
    NSMutableDictionary *complementaryBases = [NSMutableDictionary dictionary];
    [complementaryBases setObject: @"G" forKey: @"C"];
    [complementaryBases setObject: @"C" forKey: @"G"];
    [complementaryBases setObject: @"A" forKey: @"T"];
    [complementaryBases setObject: @"T" forKey: @"A"];
    [complementaryBases setObject: @"R" forKey: @"Y"];
    [complementaryBases setObject: @"Y" forKey: @"R"];
    [complementaryBases setObject: @"M" forKey: @"K"];
    [complementaryBases setObject: @"K" forKey: @"M"];
    [complementaryBases setObject: @"W" forKey: @"S"];
    [complementaryBases setObject: @"S" forKey: @"W"];
    [complementaryBases setObject: @"H" forKey: @"D"];
    [complementaryBases setObject: @"D" forKey: @"H"];
    [complementaryBases setObject: @"V" forKey: @"B"];
    [complementaryBases setObject: @"B" forKey: @"V"];
    [complementaryBases setObject: @"N" forKey: @"N"];
    
    baseComplements = [complementaryBases copy];
    
    // generate a few character sets
    // we use all caps here and uppercase anything we get sent
    normalBaseSet = [[NSCharacterSet characterSetWithCharactersInString: @"ATCG"] retain];
    strictBaseSet = [[NSCharacterSet characterSetWithCharactersInString: @"GATCN"] retain];
    looseBaseSet = [[NSCharacterSet characterSetWithCharactersInString: @"GATCNMKRYWSHVDB"] retain];
    
    // this is used to return the full list of bases when given a single letter that
    // represents more than one base
    basesAndReplacements = [NSDictionary 
        dictionaryWithObjects: [NSArray arrayWithObjects: @"CA", @"GT", @"AG", @"CT", @"AT", @"GC", @"ACT", @"ACG", @"AGT", @"CGT", @"ACGT", nil]
                      forKeys: [NSArray arrayWithObjects: @"M", @"K" , @"R", @"Y", @"W", @"S", @"H", @"V", @"D", @"B", @"N", nil] ];
    [basesAndReplacements retain];
    
    return self;
}

// preferred method for obtaining this object.
+ (BCUtilStringDNA *)sharedDNAUtilObject {
    if (sharedDNASequenceObject == nil) sharedDNASequenceObject = [[BCUtilStringDNA alloc] init];
    return sharedDNASequenceObject;       
}


// the strict method allows ATCGN
- (NSString *) stripNonDNACharacters_Strict: (NSString *)entry {
    NSMutableString *theReturn = [NSMutableString stringWithString: @""];
    NSString *tempString = nil;
    NSScanner *validBaseScanner = [NSScanner scannerWithString: [entry uppercaseString]];
    while ( ![validBaseScanner isAtEnd] ) {
            // grab valid characters and add them to the string to be used
        if ( [validBaseScanner scanCharactersFromSet: strictBaseSet intoString: &tempString] )
            [theReturn appendString: tempString];
            // move the scanner's index forward to the next valid character
        else
            [validBaseScanner scanUpToCharactersFromSet: strictBaseSet intoString: nil];
    }
    return [[theReturn copy] autorelease];
}



// This method allows the full spectrum of possible nucleotides:  ATCGNMKRYWSHVDB
- (NSString *) stripNonDNACharacters: (NSString *)entry {
    NSMutableString *theReturn = [NSMutableString stringWithString: @""];
    NSString *tempString = nil;
    NSScanner *validBaseScanner = [NSScanner scannerWithString: [entry uppercaseString]];
    while ( ![validBaseScanner isAtEnd] ) {
            // grab valid characters and add them to the string to be used
        if ( [validBaseScanner scanCharactersFromSet: looseBaseSet intoString: &tempString] )
            [theReturn appendString: tempString];
            // move the scanner's index forward to the next valid character
        else
            [validBaseScanner scanUpToCharactersFromSet: looseBaseSet intoString: nil];
    }
    return [[theReturn copy] autorelease];
}


// Useful for pasted sequences or file reads - determines whether things need to be stripped out
// before using a sequence string for analysis.
- (BOOL) hasNonDNACharacters_Strict: (NSString *)entry {
    if ( [strictBaseSet isSupersetOfSet: [NSCharacterSet characterSetWithCharactersInString: [entry uppercaseString]]] ) 
        return NO;
    
    return YES;
}

- (BOOL) hasNonDNACharacters: (NSString *)entry {
    if ( [looseBaseSet isSupersetOfSet: [NSCharacterSet characterSetWithCharactersInString: [entry uppercaseString]]] ) 
        return NO;
    return YES;
}



//  Complement and reverse complement should be self explanatory

- (NSString *) complementOfSequence: (NSString *)entry {
    NSString *sequenceString = [entry uppercaseString];
    NSMutableString *theReturn = [NSMutableString stringWithString: @""];
    NSString *aBaseString;
    int loopCounter;
    for (loopCounter = 0; loopCounter < [sequenceString length]; loopCounter++ ) {
        aBaseString = [sequenceString substringWithRange: NSMakeRange( loopCounter, 1) ];
        [theReturn appendString: [baseComplements objectForKey: aBaseString]];
    }
    return theReturn;
}



- (NSString *) reverseComplementOfSequence: (NSString *)entry {
    NSString *sequenceString = [entry uppercaseString];
    NSMutableString *theReturn = [NSMutableString stringWithString: @""];
    NSString *aBaseString;
    int loopCounter;
    for (loopCounter = 0; loopCounter < [sequenceString length]; loopCounter++ ) {
        aBaseString = [sequenceString substringWithRange: NSMakeRange( loopCounter, 1) ];
        [theReturn insertString: [baseComplements objectForKey: aBaseString] atIndex: 0]; 
    }
    return theReturn;
}



// given an ambiguous (but valid) sequence such as ATRNYGG, this will return an array
// where each entry represents a possible equivalent sequence using only ATCG.

- (NSArray *) getAllSitesForSequence: (NSString *) entry {
    // we build up an array of possible sites, one base at a time.
    int loopCounter, innerLoopCounter;
    unsigned char aBase;
    NSString *aBaseString, *tempString, *theReplacements;
    NSString *theSequence = [entry uppercaseString];
    NSEnumerator *theArrayEnumerator;
    NSMutableArray *tempArray;
    NSMutableArray *theReturn = [NSMutableArray arrayWithObject: [NSMutableString stringWithString: @""]];
    
    for (loopCounter = 0; loopCounter < [theSequence length]; loopCounter++ ) {
        // we need both the char and the string for different reasons
        aBase = [theSequence characterAtIndex: loopCounter];
        aBaseString = [theSequence substringWithRange: NSMakeRange( loopCounter, 1) ];
        
        // first case - a regular base that we can tack on
        if ( [normalBaseSet characterIsMember: aBase] ) {
            for (innerLoopCounter = 0; innerLoopCounter < [theReturn count]; innerLoopCounter++ ) {
                [theReturn replaceObjectAtIndex: innerLoopCounter withObject:
                    [[theReturn objectAtIndex: innerLoopCounter] stringByAppendingString: aBaseString] ];
                
            }
        }
        // we append a number of bases, depending on what the character is, expanding the array to handle 
        // all the options.
        else {
            tempArray = [NSMutableArray array];
            theArrayEnumerator = [theReturn objectEnumerator];
            theReplacements = [basesAndReplacements objectForKey: aBaseString];
            while ( tempString = [theArrayEnumerator nextObject] ) {
                
                for (innerLoopCounter = 0; innerLoopCounter < [theReplacements length]; innerLoopCounter++ ) {
                    [tempArray addObject: [tempString stringByAppendingString: [theReplacements substringWithRange: NSMakeRange( innerLoopCounter, 1) ] ]];
                }
            }
            theReturn = tempArray;
        }
        
    }
    
    return theReturn;
}

- (NSRange) findLongestORFInSequence: (NSString *)entry startingWithATG: (BOOL)atgStart inBothDirections: (BOOL)bothDirections {
    
    int currentORFStartLocation = -1;
    int currentORFLength = 0;
    int maxORFStartLocation = 0;
    int maxORFLength = 0;
    int outerLoopCounter, innerLoopCounter, currentCodonStart;
    NSString *aCodon;
    NSCharacterSet *aCodonsBases;
    
        // set up some values to check against
    NSSet *stopCodonSet = [NSSet setWithObjects: @"TAA", @"TAG", @"TGA", nil];
    NSSet *reversedStopCodonSet = [NSSet setWithObjects: @"TTA", @"CTA", @"TCA", nil];
    
    
    // to simplify searches, we capitalize the string
    NSString *theSequence = [entry uppercaseString];
    
        // Now that we have our copies, we can analyze the sequence
    
    ////////////////////////////////////////
    // Two possible ways to analyze - one with a ATG start
    // one with any ORF
    //
    // this one is the ATG start
    ////////////////////////////////////////
    if ( atgStart ) {
        NSRange currentATGRange;
        
        // we'll do this once forward and (possibly) once reverse - this is the forward
        currentATGRange = [theSequence rangeOfString: @"ATG"];
        
        while ( currentATGRange.location != NSNotFound ) {
            currentORFStartLocation = currentATGRange.location;
            currentORFLength = 3;
            innerLoopCounter = currentORFStartLocation + 3;
            
            while ( innerLoopCounter + 3 < [theSequence length] ) {
                // find the closest stop codon
                
                aCodon = [theSequence substringWithRange: NSMakeRange( innerLoopCounter, 3 ) ];
                
                // if the sequence is ambiguous, we call an end to any open ORFs
                aCodonsBases = [NSCharacterSet characterSetWithCharactersInString: aCodon];
                if ( ![strictBaseSet isSupersetOfSet: aCodonsBases] ) {
                    // see if we've got the longest one yet
                    if ( currentORFLength > maxORFLength ) {
                        maxORFLength = currentORFLength - 1;
                        maxORFStartLocation = currentORFStartLocation;
                    }
                    // now, reset our values
                    currentORFLength = 0;
                    currentORFStartLocation = -1;
                    break;
                }
                // do the same thing if it's a stop codon
                else if ( [stopCodonSet containsObject: aCodon]  ) {
                    // see if we've got the longest one yet
                    if ( currentORFLength > maxORFLength ) {
                        maxORFLength = currentORFLength - 1;
                        maxORFStartLocation = currentORFStartLocation;
                    }
                    // now, reset our values
                    currentORFLength = 0;
                    currentORFStartLocation = -1;
                    break;
                }
                
                    // otherwise, we just keep going to the next codon
                currentORFLength = currentORFLength + 3;
                innerLoopCounter = innerLoopCounter + 3;
                
            }
                // the loop through the sequence has ended
                // we need to confirm that we haven't run off the far end of the sequence within an ORF
            if ( currentORFStartLocation != -1 ) {
                if ( currentORFLength > maxORFLength ) {
                    maxORFLength = currentORFLength;
                    maxORFStartLocation = currentORFStartLocation;
                }
            }
            
                // move on to the next ATG
            currentATGRange = [theSequence rangeOfString: @"ATG" options: NSCaseInsensitiveSearch range:  NSMakeRange( currentATGRange.location + 1, [theSequence length] - currentATGRange.location - 2  ) ];
        }
        
        
        
        if ( bothDirections ) {             
            // we do everything in reverse, though the logic is largely the same
            currentATGRange = [theSequence rangeOfString: @"CAT" options: NSBackwardsSearch range: NSMakeRange( 0, [theSequence length]) ];
            
            while ( currentATGRange.location != NSNotFound ) {
                currentORFStartLocation = currentATGRange.location;
                currentORFLength = 3;
                innerLoopCounter = currentORFStartLocation - 3;
                
                while ( innerLoopCounter - 3 > 0 ) {
                // find the closest stop codon
                    
                    aCodon = [theSequence substringWithRange: NSMakeRange( innerLoopCounter, 3 ) ];
                    
                // if the sequence is ambiguous, we call an end to any open ORFs
                    aCodonsBases = [NSCharacterSet characterSetWithCharactersInString: aCodon];
                    if ( ![strictBaseSet isSupersetOfSet: aCodonsBases] ) {
                    // see if we've got the longest one yet
                        if ( currentORFLength > maxORFLength ) {
                            maxORFLength = currentORFLength;
                        // the start location is actually wrong, since it's the far end - we need the start
                            maxORFStartLocation = currentORFStartLocation - currentORFLength + 2;
                        }
                    // now, reset our values
                        currentORFLength = 0;
                        currentORFStartLocation = -1;
                        break;
                    }
                // do the same thing if it's a stop codon
                    else if ( [reversedStopCodonSet containsObject: aCodon]  ) {
                    // see if we've got the longest one yet
                        if ( currentORFLength > maxORFLength ) {
                            maxORFLength = currentORFLength;
                            // the start location is actually wrong, since it's the far end - we need the start
                            maxORFStartLocation = currentORFStartLocation - currentORFLength + 2;
                        }
                    // now, reset our values
                        currentORFLength = 0;
                        currentORFStartLocation = -1;
                        break;
                    }
                    
                    // otherwise, we just keep going to the next codon
                    currentORFLength = currentORFLength + 3;
                    innerLoopCounter = innerLoopCounter - 3;
                }
                
                // we need to confirm that we haven't run off the far end of the sequence within an ORF
                if ( currentORFStartLocation != -1 ) {
                    if ( currentORFLength > maxORFLength ) {
                        maxORFLength = currentORFLength;
                        // the start location is actually wrong, since it's the far end - we need the start
                        maxORFStartLocation = 0;
                    }
                }
                currentATGRange = [theSequence rangeOfString: @"CAT" options: NSBackwardsSearch range:  NSMakeRange( 0, currentATGRange.location) ];
            }
            
        }
    }
    
    
    ////////////////////////////////////////
    // ORFs without an ATG found here
    ////////////////////////////////////////
    else {
        
        // we'll do this once forward and once reverse - this is the forward
        for ( outerLoopCounter=0; outerLoopCounter < 3; outerLoopCounter++ ) {
            // we miss the very last codon this way, but it's an acceptable risk, since it'll mostly be low quality trace
            for (innerLoopCounter = 0; innerLoopCounter < (([theSequence length] / 3) - 1); innerLoopCounter++ ) {
                
                currentCodonStart = innerLoopCounter * 3 + outerLoopCounter;
                aCodon = [theSequence substringWithRange: NSMakeRange( currentCodonStart, 3 ) ];
                
                // if the sequence is ambiguous, we skip it and call an end to any open ORFs
                aCodonsBases = [NSCharacterSet characterSetWithCharactersInString: aCodon];
                if ( ![strictBaseSet isSupersetOfSet: aCodonsBases] ) {
                    // see if we've got the longest one yet
                    if ( currentORFLength > maxORFLength ) {
                        maxORFLength = currentORFLength - 1;
                        maxORFStartLocation = currentORFStartLocation;
                    }
                    // now, reset our values
                    currentORFLength = 0;
                    currentORFStartLocation = -1;
                }
                // do the same thing if it's a stop codon
                else if ( [stopCodonSet containsObject: aCodon]  ) {
                    // see if we've got the longest one yet
                    if ( currentORFLength > maxORFLength ) {
                        maxORFLength = currentORFLength - 1;
                        maxORFStartLocation = currentORFStartLocation;
                    }
                    // now, reset our values
                    currentORFLength = 0;
                    currentORFStartLocation = -1;
                }
                // must have a plain old codon
                else {
                    // two choices - starting an ORF, or continuing it
                    if ( currentORFStartLocation == -1 ) { // start a new one
                        currentORFStartLocation = currentCodonStart;
                        currentORFLength = 3;
                    }
                    else {
                        currentORFLength = currentORFLength + 3;   
                    }
                }
                
            }  
            
            
            // we've finished a pass of the inner loop (a run through of one reading frame
            // see if the ORF is still open
            if ( currentORFLength > maxORFLength ) {
                maxORFLength = currentORFLength;
                maxORFStartLocation = currentORFStartLocation;
            }
                    // reset the values
            currentORFLength = 0;
            currentORFStartLocation = -1;
            
        }
        
        
        //////////////////////////////////////////////////
        // do it over again, looking for the reverse of stop codons.
        //////////////////////////////////////////////////
        if ( bothDirections ) { 
            
            for ( outerLoopCounter=0; outerLoopCounter < 3; outerLoopCounter++ ) {
            // we miss the very last codon this way, but it's an acceptable risk, since it'll mostly be low quality trace
                for (innerLoopCounter = 0; innerLoopCounter < (([theSequence length] / 3) - 1); innerLoopCounter++ ) {
                    
                    currentCodonStart = innerLoopCounter * 3 + outerLoopCounter;
                    aCodon = [theSequence substringWithRange: NSMakeRange( currentCodonStart, 3 ) ];
                    
                // if the sequence is ambiguous, we skip it and call an end to any open ORFs
                    aCodonsBases = [NSCharacterSet characterSetWithCharactersInString: aCodon];
                    if ( ![strictBaseSet isSupersetOfSet: aCodonsBases] ) {
                    // see if we've got the longest one yet
                        if ( currentORFLength > maxORFLength ) {
                            maxORFLength = currentORFLength - 1;
                            maxORFStartLocation = currentORFStartLocation;
                        }
                    // now, reset our values
                        currentORFLength = 0;
                        currentORFStartLocation = - 1;
                    }
                // do the same thing if it's a stop codon
                    else if ( [reversedStopCodonSet containsObject: aCodon]  ) {
                    // see if we've got the longest one yet
                        if ( currentORFLength > maxORFLength ) {
                            maxORFLength = currentORFLength - 1;
                            maxORFStartLocation = currentORFStartLocation;
                        }
                    // now, reset our values
                        currentORFLength = 0;
                        currentORFStartLocation = - 1;
                    }
                // must have a plain old codon
                    else {
                    // two choices - starting an ORF, or continuing it
                        if ( currentORFStartLocation == -1 ) { // start a new one
                            currentORFStartLocation = currentCodonStart;
                            currentORFLength = 3;
                        }
                        else {
                            currentORFLength = currentORFLength + 3;   
                        }
                    }
                    
                }    
                
            // we've finished a pass of the inner loop (a run through of one reading frame
            // see if the ORF is still open
                if ( currentORFLength > maxORFLength ) {
                    maxORFLength = currentORFLength;
                    maxORFStartLocation = currentORFStartLocation;
                }
                    // reset the values
                currentORFLength = 0;
                currentORFStartLocation = -1;
                
                }   
            }
        }
    
        /////////  WE'RE DONE!  //////////////////
    return NSMakeRange( maxORFStartLocation, maxORFLength);
}




@end



