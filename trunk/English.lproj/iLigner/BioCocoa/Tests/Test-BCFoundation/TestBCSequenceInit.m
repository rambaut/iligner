//
//  TestBCSequenceInit.m
//  BioCocoa-test
//
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

/* NEEDS TO BE UPDATED - TEMPORARILY REMOVED FROM Test - BCFoundation TARGET */

#import "TestBCSequenceInit.h"

/*
BCSequenceType SequenceTypeFromString (NSString *aString)
{
	if ([aString isEqualToString:@"BCSequenceTypeDNA"])
		return BCSequenceTypeDNA;
	else if ([aString isEqualToString:@"BCSequenceTypeRNA"])
		return BCSequenceTypeRNA;
	else if ([aString isEqualToString:@"BCSequenceTypeProtein"])
		return BCSequenceTypeProtein;
	else if ([aString isEqualToString:@"BCSequenceTypeCodon"])
		return BCSequenceTypeCodon;
	else
		return BCSequenceTypeOther;
}
*/
/*
 Symbol sets:
 DNA            ABCD--GH--K-MN---RST-VW-Y-
 DNA strict     A-C---G------------T------
 RNA            ABCD--GH--K-MN---RS-UVW-Y-
 RNA strict     A-C---G-------------U-----
 protein        ABCDEFGHI-KLMN-PQRST-VW-YZ
 protein strict A-CDEFGHI-KLMN-PQRST-VW-Y- 
 */

@implementation TestBCSequenceInit

#pragma mark *** Initializers can recognize sequence type ? ***

//initializer with string that should give DNA
//all known DNA symbols
- (void)testInitStringKnownDNASymbols
{
	NSString *initial,*expected,*obtained;
  BCSequence *sequence;
	
	initial= @"ATGTTGGAGGATGGGTTACGACGTRYMKSWHBVDNAGCGT";
	expected=@"ATGTTGGAGGATGGGTTACGACGTRYMKSWHBVDNAGCGT";
	sequence=[BCSequence sequenceWithString:initial];
	obtained=[sequence sequenceString];
	
	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
			expected,obtained];
	if ([sequence sequenceType]!=BCSequenceTypeDNA)
		[error appendFormat:@"Sequence should be DNA but is %d\n",
			[sequence sequenceType]];
	if ([sequence symbolSet]!=[BCSymbolSet dnaSymbolSet])
		[error appendFormat:@"Symbol set should be %@ but is %@\n",
			[BCSymbolSet dnaSymbolSet],[sequence symbolSet]];
	if ([[sequence symbolSet] sequenceType]!=[sequence sequenceType])
		[error appendFormat:@"The symbol set is of type %d but should be of type %d, the same type as the sequence\n",
			[[sequence symbolSet] sequenceType],[sequence sequenceType]];
	//if error!=@"", the test failed
	STAssertTrue ( [error isEqualToString:@""],error);
}

//initializer with string that should give DNA
//all known DNA symbols except for some Us
- (void)testInitStringMostlyDNASymbols1
{
	NSString *initial,*expected,*obtained;
	BCSequence *sequence;
	
	initial= @"ATGTUTGGAGGATUUGGGTTACGACGUTRYMKSWHBVDNAGCGT";
	expected=@"ATGTTGGAGGATGGGTTACGACGTRYMKSWHBVDNAGCGT";
	sequence=[BCSequence sequenceWithString:initial];
	obtained=[sequence sequenceString];
	
	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
			expected,obtained];
	if ([sequence sequenceType]!=BCSequenceTypeDNA)
		[error appendFormat:@"Sequence should be DNA but is %d\n",
			[sequence sequenceType]];
	if ([sequence symbolSet]!=[BCSymbolSet dnaSymbolSet])
		[error appendFormat:@"Symbol set should be %@ but is %@\n",
			[BCSymbolSet dnaSymbolSet],[sequence symbolSet]];
	if ([[sequence symbolSet] sequenceType]!=[sequence sequenceType])
		[error appendFormat:@"The symbol set is of type %d but should be of type %d, the same type as the sequence\n",
			[[sequence symbolSet] sequenceType],[sequence sequenceType]];
	//if error!=@"", the test failed
	STAssertTrue ( [error isEqualToString:@""],error);
}


//initializer with string that should give DNA
//all known DNA symbols except for some Us and unknown symbols
- (void)testInitStringMostlyDNASymbols2
{
	NSString *initial,*expected,*obtained;
	BCSequence *sequence;
	
	initial= @"ATGTUTGGAGGATUUGGGTTACGACGUTRYMK(123)SWHBVDNAGCGT++988{}?[]";
	expected=@"ATGTTGGAGGATGGGTTACGACGTRYMKSWHBVDNAGCGT";
	sequence=[BCSequence sequenceWithString:initial];
	obtained=[sequence sequenceString];
	
	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
			expected,obtained];
	if ([sequence sequenceType]!=BCSequenceTypeDNA)
		[error appendFormat:@"Sequence should be DNA but is %d\n",
			[sequence sequenceType]];
	if ([sequence symbolSet]!=[BCSymbolSet dnaSymbolSet])
		[error appendFormat:@"Symbol set should be %@ but is %@\n",
			[BCSymbolSet dnaSymbolSet],[sequence symbolSet]];
	if ([[sequence symbolSet] sequenceType]!=[sequence sequenceType])
		[error appendFormat:@"The symbol set is of type %d but should be of type %d, the same type as the sequence\n",
			[[sequence symbolSet] sequenceType],[sequence sequenceType]];
	//if error!=@"", the test failed
	STAssertTrue ( [error isEqualToString:@""],error);
}


//initializer with string that should give RNA
//all known RNA symbols
- (void)testInitStringKnownRNASymbols
{
	NSString *initial,*expected,*obtained;
	BCSequence *sequence;
	
	initial= @"AUGUUGGAGGAUGGGUUACGACGURYMKSWHBVDNAGCGU";
	expected=@"AUGUUGGAGGAUGGGUUACGACGURYMKSWHBVDNAGCGU";
	sequence=[BCSequence sequenceWithString:initial];
	obtained=[sequence sequenceString];
	
	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
			expected,obtained];
	if ([sequence sequenceType]!=BCSequenceTypeRNA)
		[error appendFormat:@"Sequence should be RNA but is %d\n",
			[sequence sequenceType]];
	if ([sequence symbolSet]!=[BCSymbolSet rnaSymbolSet])
		[error appendFormat:@"Symbol set should be %@ but is %@\n",
			[BCSymbolSet rnaSymbolSet],[sequence symbolSet]];
	if ([[sequence symbolSet] sequenceType]!=[sequence sequenceType])
		[error appendFormat:@"The symbol set is of type %d but should be of type %d, the same type as the sequence\n",
			[[sequence symbolSet] sequenceType],[sequence sequenceType]];
	//if error!=@"", the test failed
	STAssertTrue ( [error isEqualToString:@""],error);
}


//initializer with string that should give RNA
//all known RNA symbols except for some Ts
- (void)testInitStringMostlyRNASymbols1
{
	NSString *initial,*expected,*obtained;
	BCSequence *sequence;
	
	initial= @"AUGUUTGGAGGAUTTGGGUUACGACGUTRYMKSWHBVDNAGCGU";
	expected=@"AUGUUGGAGGAUGGGUUACGACGURYMKSWHBVDNAGCGU";
	sequence=[BCSequence sequenceWithString:initial];
	obtained=[sequence sequenceString];
	
	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
			expected,obtained];
	if ([sequence sequenceType]!=BCSequenceTypeRNA)
		[error appendFormat:@"Sequence should be RNA but is %d\n",
			[sequence sequenceType]];
	if ([sequence symbolSet]!=[BCSymbolSet rnaSymbolSet])
		[error appendFormat:@"Symbol set should be %@ but is %@\n",
			[BCSymbolSet rnaSymbolSet],[sequence symbolSet]];
	if ([[sequence symbolSet] sequenceType]!=[sequence sequenceType])
		[error appendFormat:@"The symbol set is of type %d but should be of type %d, the same type as the sequence\n",
			[[sequence symbolSet] sequenceType],[sequence sequenceType]];
	//if error!=@"", the test failed
	STAssertTrue ( [error isEqualToString:@""],error);
}


//initializer with string that should give RNA
//all known RNA symbols except for some Ts and unknown symbols
- (void)testInitStringMostlyRNASymbols2
{
	NSString *initial,*expected,*obtained;
	BCSequence *sequence;
	
	initial= @"AUGUUTGGAGGAUT1234567890()[]TGG{-+\\}GUUACGACGUTRYMKSWHBVD%%NAGCGU";
	expected=@"AUGUUGGAGGAUGGGUUACGACGURYMKSWHBVDNAGCGU";
	sequence=[BCSequence sequenceWithString:initial];
	obtained=[sequence sequenceString];
	
	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
			expected,obtained];
	if ([sequence sequenceType]!=BCSequenceTypeRNA)
		[error appendFormat:@"Sequence should be RNA but is %d\n",
			[sequence sequenceType]];
	if ([sequence symbolSet]!=[BCSymbolSet rnaSymbolSet])
		[error appendFormat:@"Symbol set should be %@ but is %@\n",
			[BCSymbolSet rnaSymbolSet],[sequence symbolSet]];
	if ([[sequence symbolSet] sequenceType]!=[sequence sequenceType])
		[error appendFormat:@"The symbol set is of type %d but should be of type %d, the same type as the sequence\n",
			[[sequence symbolSet] sequenceType],[sequence sequenceType]];
	//if error!=@"", the test failed
	STAssertTrue ( [error isEqualToString:@""],error);
}

//initializer with string that should give RNA
//all known prot symbols except for nine U,
//which should give RNA the edge
//	RNA            ABCD--GH--K-MN---RS-UVW-Y-
//	protein        ABCDEFGHI-KLMN-PQRST-VW-YZ
- (void)testInitStringMostlyRNASymbols3
{
	NSString *initial,*expected,*obtained;
	BCSequence *sequence;
	
	initial= @"ABCDEFGHIKLMNPQRSTVWYZUUUUUUUUU";
	expected=@"ABCDGHKMNRSVWYUUUUUUUUU";
	sequence=[BCSequence sequenceWithString:initial];
	obtained=[sequence sequenceString];
	
	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
			expected,obtained];
	if ([sequence sequenceType]!=BCSequenceTypeRNA)
		[error appendFormat:@"Sequence should be RNA but is %d\n",
			[sequence sequenceType]];
	if ([sequence symbolSet]!=[BCSymbolSet rnaSymbolSet])
		[error appendFormat:@"Symbol set should be %@ but is %@\n",
			[BCSymbolSet rnaSymbolSet],[sequence symbolSet]];
	if ([[sequence symbolSet] sequenceType]!=[sequence sequenceType])
		[error appendFormat:@"The symbol set is of type %d but should be of type %d, the same type as the sequence\n",
			[[sequence symbolSet] sequenceType],[sequence sequenceType]];
	//if error!=@"", the test failed
	STAssertTrue ( [error isEqualToString:@""],error);
}


//initializer with string that should give protein
//all known prot symbols
- (void)testInitStringKnownProteinSymbols
{
	NSString *initial,*expected,*obtained;
	BCSequence *sequence;
	
	initial= @"ACDEFGHIKLMNPQRSTVWYBZ";
	expected=@"ACDEFGHIKLMNPQRSTVWYBZ";
	sequence=[BCSequence sequenceWithString:initial];
	obtained=[sequence sequenceString];
	
	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
			expected,obtained];
	if ([sequence sequenceType]!=BCSequenceTypeProtein)
		[error appendFormat:@"Sequence should be protein but is %d\n",
			[sequence sequenceType]];
	if ([sequence symbolSet]!=[BCSymbolSet proteinSymbolSet])
		[error appendFormat:@"Symbol set should be %@ but is %@\n",
			[BCSymbolSet proteinSymbolSet],[sequence symbolSet]];
	if ([[sequence symbolSet] sequenceType]!=[sequence sequenceType])
		[error appendFormat:@"The symbol set is of type %d but should be of type %d, the same type as the sequence\n",
			[[sequence symbolSet] sequenceType],[sequence sequenceType]];
	//if error!=@"", the test failed
	STAssertTrue ( [error isEqualToString:@""],error);
}

//initializer with string that should give protein
//all known prot symbols except for one U
- (void)testInitStringMostlyProteinSymbols1
{
	NSString *initial,*expected,*obtained;
	BCSequence *sequence;
	
	initial= @"ACDEFGHIKLMNPQRSTVWYBZU";
	expected=@"ACDEFGHIKLMNPQRSTVWYBZ";
	sequence=[BCSequence sequenceWithString:initial];
	obtained=[sequence sequenceString];
	
	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
			expected,obtained];
	if ([sequence sequenceType]!=BCSequenceTypeProtein)
		[error appendFormat:@"Sequence should be protein but is %d\n",
			[sequence sequenceType]];
	if ([sequence symbolSet]!=[BCSymbolSet proteinSymbolSet])
		[error appendFormat:@"Symbol set should be %@ but is %@\n",
			[BCSymbolSet proteinSymbolSet],[sequence symbolSet]];
	if ([[sequence symbolSet] sequenceType]!=[sequence sequenceType])
		[error appendFormat:@"The symbol set is of type %d but should be of type %d, the same type as the sequence\n",
			[[sequence symbolSet] sequenceType],[sequence sequenceType]];
	//if error!=@"", the test failed
	STAssertTrue ( [error isEqualToString:@""],error);
}


//initializer with string that should give protein
//all known prot symbols except for seven U
//which should give protein the edge
//	RNA            ABCD--GH--K-MN---RS-UVW-Y-
//	protein        ABCDEFGHI-KLMN-PQRST-VW-YZ
- (void)testInitStringMostlyProteinSymbols2
{
	NSString *initial,*expected,*obtained;
	BCSequence *sequence;
	
	initial= @"ACDEFGHIKLMNPQRSTVWYBZUUUUUUU";
	expected=@"ACDEFGHIKLMNPQRSTVWYBZ";
	sequence=[BCSequence sequenceWithString:initial];
	obtained=[sequence sequenceString];
	
	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
			expected,obtained];
	if ([sequence sequenceType]!=BCSequenceTypeProtein)
		[error appendFormat:@"Sequence should be protein but is %d\n",
			[sequence sequenceType]];
	if ([sequence symbolSet]!=[BCSymbolSet proteinSymbolSet])
		[error appendFormat:@"Symbol set should be %@ but is %@\n",
			[BCSymbolSet proteinSymbolSet],[sequence symbolSet]];
	if ([[sequence symbolSet] sequenceType]!=[sequence sequenceType])
		[error appendFormat:@"The symbol set is of type %d but should be of type %d, the same type as the sequence\n",
			[[sequence symbolSet] sequenceType],[sequence sequenceType]];
	//if error!=@"", the test failed
	STAssertTrue ( [error isEqualToString:@""],error);
}


@end

/*
 These tests are the same as TestBCSequenceDNAInit,
 except for test 'testInitStringWrongSymbolSet' that was removed
*/

@implementation TestBCSequenceInit (TestBCSequenceInitDNACategory)
//initializer with string
//using default symbol set
//all known symbols
- (void)testInitStringKnownSymbols
{
	NSString *initial,*expected,*obtained;
	BCSequence *sequence;
	
	initial= @"ATGTTGGAGGATGGGTTACGACGTRYMKSWHBVDNAGCGT";
	expected=@"ATGTTGGAGGATGGGTTACGACGTRYMKSWHBVDNAGCGT";
	sequence=[BCSequence sequenceWithString:initial symbolSet: [BCSymbolSet dnaSymbolSet]];
	obtained=[sequence sequenceString];
	
	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
			expected,obtained];
	if ([sequence sequenceType]!=BCSequenceTypeDNA)
		[error appendFormat:@"Sequence should be DNA but is %d\n",
			[sequence sequenceType]];
	if ([sequence symbolSet]!=[BCSymbolSet dnaSymbolSet])
		[error appendFormat:@"Symbol set should be %@ but is %@\n",
			[BCSymbolSet dnaSymbolSet],[sequence symbolSet]];
	if ([[sequence symbolSet] sequenceType]!=[sequence sequenceType])
		[error appendFormat:@"The symbol set is of type %d but should be of type %d, the same type as the sequence\n",
			[[sequence symbolSet] sequenceType],[sequence sequenceType]];
	//if error!=@"", the test failed
	STAssertTrue ( [error isEqualToString:@""],error);
}

//initializer with string
//using default symbol set
//some unknown symbols
- (void)testInitStringUnknownSymbols
{
	NSString *initial,*expected,*obtained;
	BCSequence *sequence;
	
	initial= @"ATG(87)TTGGAGGATGGGTTAACGTRYMK[128~]SWHBVDNCNGAGHBCG123T";
	expected=@"ATGTTGGAGGATGGGTTAACGTRYMKSWHBVDNCNGAGHBCGT";
	sequence=[BCSequence sequenceWithString:initial symbolSet: [BCSymbolSet dnaSymbolSet]];
	obtained=[sequence sequenceString];
	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
			expected,obtained];
	if ([sequence sequenceType]!=BCSequenceTypeDNA)
		[error appendFormat:@"Sequence should be DNA but is %d\n",
			[sequence sequenceType]];
	if ([sequence symbolSet]!=[BCSymbolSet dnaSymbolSet])
		[error appendFormat:@"Symbol set should be %@ but is %@\n",
			[BCSymbolSet dnaSymbolSet],[sequence symbolSet]];
	if ([[sequence symbolSet] sequenceType]!=[sequence sequenceType])
		[error appendFormat:@"The symbol set is of type %d but should be of type %d, the same type as the sequence\n",
			[[sequence symbolSet] sequenceType],[sequence sequenceType]];
	//if error!=@"", the test failed
	STAssertTrue ( [error isEqualToString:@""],error);
}

//initializer with string
//using default symbol set
//empty string
- (void)testInitStringEmptyString
{
	NSString *initial,*expected,*obtained;
	BCSequence *sequence;
	
	initial= @"";
	expected=@"";
	sequence=[BCSequence sequenceWithString:initial symbolSet: [BCSymbolSet dnaSymbolSet]];
	obtained=[sequence sequenceString];
	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
			expected,obtained];
	if ([sequence sequenceType]!=BCSequenceTypeDNA)
		[error appendFormat:@"Sequence should be DNA but is %d\n",
			[sequence sequenceType]];
	if ([sequence symbolSet]!=[BCSymbolSet dnaSymbolSet])
		[error appendFormat:@"Symbol set should be %@ but is %@\n",
			[BCSymbolSet dnaSymbolSet],[sequence symbolSet]];
	if ([[sequence symbolSet] sequenceType]!=[sequence sequenceType])
		[error appendFormat:@"The symbol set is of type %d but should be of type %d, the same type as the sequence\n",
			[[sequence symbolSet] sequenceType],[sequence sequenceType]];
	//if error!=@"", the test failed
	STAssertTrue ( [error isEqualToString:@""],error);
}

//initializer with string
//using default symbol set
//string composed only of unknown symbols
- (void)testInitStringAllUnknown
{
	NSString *initial,*expected,*obtained;
	BCSequence *sequence;
	
	initial= @"123458()%$#@!#";
	expected=@"";
	sequence=[BCSequence sequenceWithString:initial symbolSet: [BCSymbolSet dnaSymbolSet]];
	obtained=[sequence sequenceString];
	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
			expected,obtained];
	if ([sequence sequenceType]!=BCSequenceTypeDNA)
		[error appendFormat:@"Sequence should be DNA but is %d\n",
			[sequence sequenceType]];
	if ([sequence symbolSet]!=[BCSymbolSet dnaSymbolSet])
		[error appendFormat:@"Symbol set should be %@ but is %@\n",
			[BCSymbolSet dnaSymbolSet],[sequence symbolSet]];
	if ([[sequence symbolSet] sequenceType]!=[sequence sequenceType])
		[error appendFormat:@"The symbol set is of type %d but should be of type %d, the same type as the sequence\n",
			[[sequence symbolSet] sequenceType],[sequence sequenceType]];
	//if error!=@"", the test failed
	STAssertTrue ( [error isEqualToString:@""],error);
}

//initializer with string
//using strict symbol set
//all known symbols
- (void)testInitStringStrictSymbolSetKnownSymbols
{
	NSString *initial,*expected,*obtained;
	BCSequence *sequence;
	
	initial= @"ATGTTGGAGGATGGGTTACGAGCGT";
	expected=@"ATGTTGGAGGATGGGTTACGAGCGT";
	sequence=[BCSequence sequenceWithString:initial symbolSet:[BCSymbolSet dnaStrictSymbolSet]];
	obtained=[sequence sequenceString];
	
	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
			expected,obtained];
	if ([sequence sequenceType]!=BCSequenceTypeDNA)
		[error appendFormat:@"Sequence should be DNA but is %d\n",
			[sequence sequenceType]];
	if ([sequence symbolSet]!=[BCSymbolSet dnaStrictSymbolSet])
		[error appendFormat:@"Symbol set should be %@ but is %@\n",
			[BCSymbolSet dnaStrictSymbolSet],[sequence symbolSet]];
	if ([[sequence symbolSet] sequenceType]!=[sequence sequenceType])
		[error appendFormat:@"The symbol set is of type %d but should be of type %d, the same type as the sequence\n",
			[[sequence symbolSet] sequenceType],[sequence sequenceType]];
	//if error!=@"", the test failed
	STAssertTrue ( [error isEqualToString:@""],error);
}

//initializer with string
//using strict symbol set
//some unknown symbols
- (void)testInitStringStrictSymbolSetUnknownSymbols
{
	NSString *initial,*expected,*obtained;
	BCSequence *sequence;
	
	initial= @"ATG(87)TTGGAGGACGTRYMKSWHBVDNATGGGTTACNGAGHBCG123T";
	expected=@"ATGTTGGAGGACGTATGGGTTACGAGCGT";
	sequence=[BCSequence sequenceWithString:initial symbolSet:[BCSymbolSet dnaStrictSymbolSet]];
	obtained=[sequence sequenceString];
	
	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
			expected,obtained];
	if ([sequence sequenceType]!=BCSequenceTypeDNA)
		[error appendFormat:@"Sequence should be DNA but is %d\n",
			[sequence sequenceType]];
	if ([sequence symbolSet]!=[BCSymbolSet dnaStrictSymbolSet])
		[error appendFormat:@"Symbol set should be %@ but is %@\n",
			[BCSymbolSet dnaStrictSymbolSet],[sequence symbolSet]];
	if ([[sequence symbolSet] sequenceType]!=[sequence sequenceType])
		[error appendFormat:@"The symbol set is of type %d but should be of type %d, the same type as the sequence\n",
			[[sequence symbolSet] sequenceType],[sequence sequenceType]];
	//if error!=@"", the test failed
	STAssertTrue ( [error isEqualToString:@""],error);
}


//initializer with string
//using custom symbol set
- (void)testInitStringCustomSymbolSet
{
	NSString *initial,*expected,*obtained;
	BCSequence *sequence;
	BCSymbolSet *set;
	
	initial= @"ATG(87)TTGGAGGACGTRYMKSWHBVDNATGGGTTACNGAGHBCG123T";
	expected=@"AAAAAA";
	set=[BCSymbolSet symbolSetWithString:@"A" sequenceType:BCSequenceTypeDNA];
	sequence=[BCSequence sequenceWithString:initial symbolSet:set];
	obtained=[sequence sequenceString];
	
	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
			expected,obtained];
	if ([sequence sequenceType]!=BCSequenceTypeDNA)
		[error appendFormat:@"Sequence should be DNA but is %d\n",
			[sequence sequenceType]];
	if ([sequence symbolSet]!=set)
		[error appendFormat:@"Symbol set should be %@ but is %@\n",
			set,[sequence symbolSet]];
	if ([[sequence symbolSet] sequenceType]!=[sequence sequenceType])
		[error appendFormat:@"The symbol set is of type %d but should be of type %d, the same type as the sequence\n",
			[[sequence symbolSet] sequenceType],[sequence sequenceType]];
	//if error!=@"", the test failed
	STAssertTrue ( [error isEqualToString:@""],error);
}


//initializer with string
//using empty symbol set
- (void)testInitStringEmptySymbolSet
{
	NSString *initial,*expected,*obtained;
	BCSequence *sequence;
	BCSymbolSet *set;
	
	initial= @"ATG(87)TTGGAGGACGTRYMKSWHBVDNATGGGTTACNGAGHBCG123T";
	expected=@"";
	set=[BCSymbolSet symbolSetWithString:@"" sequenceType:BCSequenceTypeDNA];
	sequence=[BCSequence sequenceWithString:initial symbolSet:set];
	obtained=[sequence sequenceString];
	
	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
			expected,obtained];
	if ([sequence sequenceType]!=BCSequenceTypeDNA)
		[error appendFormat:@"Sequence should be DNA but is %d\n",
			[sequence sequenceType]];
	if ([sequence symbolSet]!=set)
		[error appendFormat:@"Symbol set should be %@ but is %@\n",
			set,[sequence symbolSet]];
	if ([[sequence symbolSet] sequenceType]!=[sequence sequenceType])
		[error appendFormat:@"The symbol set is of type %d but should be of type %d, the same type as the sequence\n",
			[[sequence symbolSet] sequenceType],[sequence sequenceType]];
	//if error!=@"", the test failed
	STAssertTrue ( [error isEqualToString:@""],error);
}

@end

/*
 These tests are the same as TestBCSequenceRNAInit except:
 testInitStringWrongSymbolSet
 testInitStringKnownSymbolsConvertingThymidinesYes
 testInitStringKnownSymbolsConvertingThymidinesNo
 testInitStringKnownSymbolsConvertingThymidinesYesMixUT
 */

@implementation TestBCSequenceInit (TestBCSequenceInitRNACategory)
//initializer with string
//using default symbol set
//all known symbols
- (void)testInitStringKnownSymbols
{
	NSString *initial,*expected,*obtained;
	BCSequence *sequence;
	
	initial= @"AUGUUGGAGGAUGGGUUACGACGURYMKSWHBVDNAGCGU";
	expected=@"AUGUUGGAGGAUGGGUUACGACGURYMKSWHBVDNAGCGU";
	sequence=[BCSequence sequenceWithString:initial symbolSet: [BCSymbolSet rnaSymbolSet]];
	obtained=[sequence sequenceString];
	
	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
			expected,obtained];
	if ([sequence sequenceType]!=BCSequenceTypeRNA)
		[error appendFormat:@"Sequence should be RNA but is %d\n",
			[sequence sequenceType]];
	if ([sequence symbolSet]!=[BCSymbolSet rnaSymbolSet])
		[error appendFormat:@"Symbol set should be %@ but is %@\n",
			[BCSymbolSet rnaSymbolSet],[sequence symbolSet]];
	if ([[sequence symbolSet] sequenceType]!=[sequence sequenceType])
		[error appendFormat:@"The symbol set is of type %d but should be of type %d, the same type as the sequence\n",
			[[sequence symbolSet] sequenceType],[sequence sequenceType]];
	//if error!=@"", the test failed
	STAssertTrue ( [error isEqualToString:@""],error);
}

//initializer with string
//using default symbol set
//some unknown symbols
- (void)testInitStringUnknownSymbols
{
	NSString *initial,*expected,*obtained;
	BCSequence *sequence;
	
	initial= @"AUG(87)UUGGAGGAUGGGUUACGACGURYMK[128~]SWHBVDNAGCGU";
	expected=@"AUGUUGGAGGAUGGGUUACGACGURYMKSWHBVDNAGCGU";
	sequence=[BCSequence sequenceWithString:initial symbolSet: [BCSymbolSet rnaSymbolSet]];
	obtained=[sequence sequenceString];
	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
			expected,obtained];
	if ([sequence sequenceType]!=BCSequenceTypeRNA)
		[error appendFormat:@"Sequence should be RNA but is %d\n",
			[sequence sequenceType]];
	if ([sequence symbolSet]!=[BCSymbolSet rnaSymbolSet])
		[error appendFormat:@"Symbol set should be %@ but is %@\n",
			[BCSymbolSet rnaSymbolSet],[sequence symbolSet]];
	if ([[sequence symbolSet] sequenceType]!=[sequence sequenceType])
		[error appendFormat:@"The symbol set is of type %d but should be of type %d, the same type as the sequence\n",
			[[sequence symbolSet] sequenceType],[sequence sequenceType]];
	//if error!=@"", the test failed
	STAssertTrue ( [error isEqualToString:@""],error);
}

//initializer with string
//using default symbol set
//empty string
- (void)testInitStringEmptyString
{
	NSString *initial,*expected,*obtained;
	BCSequence *sequence;
	
	initial= @"";
	expected=@"";
	sequence=[BCSequence sequenceWithString:initial symbolSet: [BCSymbolSet rnaSymbolSet]];
	obtained=[sequence sequenceString];
	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
			expected,obtained];
	if ([sequence sequenceType]!=BCSequenceTypeRNA)
		[error appendFormat:@"Sequence should be RNA but is %d\n",
			[sequence sequenceType]];
	if ([sequence symbolSet]!=[BCSymbolSet rnaSymbolSet])
		[error appendFormat:@"Symbol set should be %@ but is %@\n",
			[BCSymbolSet rnaSymbolSet],[sequence symbolSet]];
	if ([[sequence symbolSet] sequenceType]!=[sequence sequenceType])
		[error appendFormat:@"The symbol set is of type %d but should be of type %d, the same type as the sequence\n",
			[[sequence symbolSet] sequenceType],[sequence sequenceType]];
	//if error!=@"", the test failed
	STAssertTrue ( [error isEqualToString:@""],error);
}
//initializer with string
//using default symbol set
//string composed only of unknown symbols
- (void)testInitStringAllUnknown
{
	NSString *initial,*expected,*obtained;
	BCSequence *sequence;
	
	initial= @"123458()%$#@!#";
	expected=@"";
	sequence=[BCSequence sequenceWithString:initial symbolSet: [BCSymbolSet rnaSymbolSet]];
	obtained=[sequence sequenceString];
	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
			expected,obtained];
	if ([sequence sequenceType]!=BCSequenceTypeRNA)
		[error appendFormat:@"Sequence should be RNA but is %d\n",
			[sequence sequenceType]];
	if ([sequence symbolSet]!=[BCSymbolSet rnaSymbolSet])
		[error appendFormat:@"Symbol set should be %@ but is %@\n",
			[BCSymbolSet rnaSymbolSet],[sequence symbolSet]];
	if ([[sequence symbolSet] sequenceType]!=[sequence sequenceType])
		[error appendFormat:@"The symbol set is of type %d but should be of type %d, the same type as the sequence\n",
			[[sequence symbolSet] sequenceType],[sequence sequenceType]];
	//if error!=@"", the test failed
	STAssertTrue ( [error isEqualToString:@""],error);
}

//initializer with string
//using strict symbol set
//all known symbols
- (void)testInitStringStrictSymbolSetKnownSymbols
{
	NSString *initial,*expected,*obtained;
	BCSequence *sequence;
	
	initial= @"AUGUUGGAGGAUGGGUUACGAGCGU";
	expected=@"AUGUUGGAGGAUGGGUUACGAGCGU";
	sequence=[BCSequence sequenceWithString:initial symbolSet:[BCSymbolSet rnaStrictSymbolSet]];
	obtained=[sequence sequenceString];
	
	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
			expected,obtained];
	if ([sequence sequenceType]!=BCSequenceTypeRNA)
		[error appendFormat:@"Sequence should be RNA but is %d\n",
			[sequence sequenceType]];
	if ([sequence symbolSet]!=[BCSymbolSet rnaStrictSymbolSet])
		[error appendFormat:@"Symbol set should be %@ but is %@\n",
			[BCSymbolSet rnaStrictSymbolSet],[sequence symbolSet]];
	if ([[sequence symbolSet] sequenceType]!=[sequence sequenceType])
		[error appendFormat:@"The symbol set is of type %d but should be of type %d, the same type as the sequence\n",
			[[sequence symbolSet] sequenceType],[sequence sequenceType]];
	//if error!=@"", the test failed
	STAssertTrue ( [error isEqualToString:@""],error);
}

//initializer with string
//using strict symbol set
//some unknown symbols
- (void)testInitStringStrictSymbolSetUnknownSymbols
{
	NSString *initial,*expected,*obtained;
	BCSequence *sequence;
	
	initial= @"AUG(87)UUGGAGGACGURYMKSWHBVDNAUGGGUUACNGAGHBCG123U";
	expected=@"AUGUUGGAGGACGUAUGGGUUACGAGCGU";
	sequence=[BCSequence sequenceWithString:initial symbolSet:[BCSymbolSet rnaStrictSymbolSet]];
	obtained=[sequence sequenceString];
	
	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
			expected,obtained];
	if ([sequence sequenceType]!=BCSequenceTypeRNA)
		[error appendFormat:@"Sequence should be RNA but is %d\n",
			[sequence sequenceType]];
	if ([sequence symbolSet]!=[BCSymbolSet rnaStrictSymbolSet])
		[error appendFormat:@"Symbol set should be %@ but is %@\n",
			[BCSymbolSet rnaStrictSymbolSet],[sequence symbolSet]];
	if ([[sequence symbolSet] sequenceType]!=[sequence sequenceType])
		[error appendFormat:@"The symbol set is of type %d but should be of type %d, the same type as the sequence\n",
			[[sequence symbolSet] sequenceType],[sequence sequenceType]];
	//if error!=@"", the test failed
	STAssertTrue ( [error isEqualToString:@""],error);
}


//initializer with string
//using custom symbol set
- (void)testInitStringCustomSymbolSet
{
	NSString *initial,*expected,*obtained;
	BCSequence *sequence;
	BCSymbolSet *set;
	
	initial= @"AUG(87)UUGGAGGACGURYMKSWHBVDNAUGGGUUACNGAGHBCG123U";
	expected=@"AAAAAA";
	set=[BCSymbolSet symbolSetWithString:@"A" sequenceType:BCSequenceTypeRNA];
	sequence=[BCSequence sequenceWithString:initial symbolSet:set];
	obtained=[sequence sequenceString];
	
	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
			expected,obtained];
	if ([sequence sequenceType]!=BCSequenceTypeRNA)
		[error appendFormat:@"Sequence should be RNA but is %d\n",
			[sequence sequenceType]];
	if ([sequence symbolSet]!=set)
		[error appendFormat:@"Symbol set should be %@ but is %@\n",
			set,[sequence symbolSet]];
	if ([[sequence symbolSet] sequenceType]!=[sequence sequenceType])
		[error appendFormat:@"The symbol set is of type %d but should be of type %d, the same type as the sequence\n",
			[[sequence symbolSet] sequenceType],[sequence sequenceType]];
	//if error!=@"", the test failed
	STAssertTrue ( [error isEqualToString:@""],error);
}

//initializer with string
//using empty symbol set
- (void)testInitStringEmptySymbolSet
{
	NSString *initial,*expected,*obtained;
	BCSequence *sequence;
	BCSymbolSet *set;
	
	initial= @"AUG(87)UUGGAGGACGURYMKSWHBVDNAUGGGUUACNGAGHBCG123U";
	expected=@"";
	set=[BCSymbolSet symbolSetWithString:@"" sequenceType:BCSequenceTypeRNA];
	sequence=[BCSequence sequenceWithString:initial symbolSet:set];
	obtained=[sequence sequenceString];
	
	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
			expected,obtained];
	if ([sequence sequenceType]!=BCSequenceTypeRNA)
		[error appendFormat:@"Sequence should be RNA but is %d\n",
			[sequence sequenceType]];
	if ([sequence symbolSet]!=set)
		[error appendFormat:@"Symbol set should be %@ but is %@\n",
			set,[sequence symbolSet]];
	if ([[sequence symbolSet] sequenceType]!=[sequence sequenceType])
		[error appendFormat:@"The symbol set is of type %d but should be of type %d, the same type as the sequence\n",
			[[sequence symbolSet] sequenceType],[sequence sequenceType]];
	//if error!=@"", the test failed
	STAssertTrue ( [error isEqualToString:@""],error);
}

@end

/*
 These tests are the same as TestBCSequenceProteinInit except:
 testInitStringWrongSymbolSet
 */
@implementation TestBCSequenceInit (TestBCSequenceInitProteinCategory)
//initializer with string
//using default symbol set
//all known symbols
- (void)testInitStringKnownSymbols
{
	NSString *initial,*expected,*obtained;
	BCSequence *sequence;
	
	initial= @"ACDEFGHIKLMNPQRSTVWYBZ";
	expected=@"ACDEFGHIKLMNPQRSTVWYBZ";
	sequence=[BCSequence sequenceWithString:initial symbolSet: [BCSymbolSet proteinSymbolSet]];
	obtained=[sequence sequenceString];
	
	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
			expected,obtained];
	if ([sequence sequenceType]!=BCSequenceTypeProtein)
		[error appendFormat:@"Sequence should be protein but is %d\n",
			[sequence sequenceType]];
	if ([sequence symbolSet]!=[BCSymbolSet proteinSymbolSet])
		[error appendFormat:@"Symbol set should be %@ but is %@\n",
			[BCSymbolSet proteinSymbolSet],[sequence symbolSet]];
	if ([[sequence symbolSet] sequenceType]!=[sequence sequenceType])
		[error appendFormat:@"The symbol set is of type %d but should be of type %d, the same type as the sequence\n",
			[[sequence symbolSet] sequenceType],[sequence sequenceType]];
	//if error!=@"", the test failed
	STAssertTrue ( [error isEqualToString:@""],error);
}

//initializer with string
//using default symbol set
//some unknown symbols
- (void)testInitStringUnknownSymbols
{
	NSString *initial,*expected,*obtained;
	BCSequence *sequence;
	
	initial= @"ABCDEFGHIJKLMNOPQRSTUVWXYZ(123)ACDEFGHIKL[87~!]MNPQRSTVWYBZ";
	expected=@"ABCDEFGHIKLMNPQRSTVWYZACDEFGHIKLMNPQRSTVWYBZ";
	sequence=[BCSequence sequenceWithString:initial symbolSet: [BCSymbolSet proteinSymbolSet]];
	obtained=[sequence sequenceString];
	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
			expected,obtained];
	if ([sequence sequenceType]!=BCSequenceTypeProtein)
		[error appendFormat:@"Sequence should be protein but is %d\n",
			[sequence sequenceType]];
	if ([sequence symbolSet]!=[BCSymbolSet proteinSymbolSet])
		[error appendFormat:@"Symbol set should be %@ but is %@\n",
			[BCSymbolSet proteinSymbolSet],[sequence symbolSet]];
	if ([[sequence symbolSet] sequenceType]!=[sequence sequenceType])
		[error appendFormat:@"The symbol set is of type %d but should be of type %d, the same type as the sequence\n",
			[[sequence symbolSet] sequenceType],[sequence sequenceType]];
	//if error!=@"", the test failed
	STAssertTrue ( [error isEqualToString:@""],error);
}

//initializer with string
//using default symbol set
//empty string
- (void)testInitStringEmptyString
{
	NSString *initial,*expected,*obtained;
	BCSequence *sequence;
	
	initial= @"";
	expected=@"";
	sequence=[BCSequence sequenceWithString:initial symbolSet: [BCSymbolSet proteinSymbolSet]];
	obtained=[sequence sequenceString];
	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
			expected,obtained];
	if ([sequence sequenceType]!=BCSequenceTypeProtein)
		[error appendFormat:@"Sequence should be protein but is %d\n",
			[sequence sequenceType]];
	if ([sequence symbolSet]!=[BCSymbolSet proteinSymbolSet])
		[error appendFormat:@"Symbol set should be %@ but is %@\n",
			[BCSymbolSet proteinSymbolSet],[sequence symbolSet]];
	if ([[sequence symbolSet] sequenceType]!=[sequence sequenceType])
		[error appendFormat:@"The symbol set is of type %d but should be of type %d, the same type as the sequence\n",
			[[sequence symbolSet] sequenceType],[sequence sequenceType]];
	//if error!=@"", the test failed
	STAssertTrue ( [error isEqualToString:@""],error);
}

//initializer with string
//using default symbol set
//string composed only of unknown symbols
- (void)testInitStringAllUnknown
{
	NSString *initial,*expected,*obtained;
	BCSequence *sequence;
	
	initial= @"JOUX123458()%$#@!#";
	expected=@"";
	sequence=[BCSequence sequenceWithString:initial symbolSet: [BCSymbolSet proteinSymbolSet]];
	obtained=[sequence sequenceString];
	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
			expected,obtained];
	if ([sequence sequenceType]!=BCSequenceTypeProtein)
		[error appendFormat:@"Sequence should be protein but is %d\n",
			[sequence sequenceType]];
	if ([sequence symbolSet]!=[BCSymbolSet proteinSymbolSet])
		[error appendFormat:@"Symbol set should be %@ but is %@\n",
			[BCSymbolSet proteinSymbolSet],[sequence symbolSet]];
	if ([[sequence symbolSet] sequenceType]!=[sequence sequenceType])
		[error appendFormat:@"The symbol set is of type %d but should be of type %d, the same type as the sequence\n",
			[[sequence symbolSet] sequenceType],[sequence sequenceType]];
	//if error!=@"", the test failed
	STAssertTrue ( [error isEqualToString:@""],error);
}

//initializer with string
//using strict symbol set
//all known symbols
- (void)testInitStringStrictSymbolSetKnownSymbols
{
	NSString *initial,*expected,*obtained;
	BCSequence *sequence;
	
	initial= @"ACDEFGHIKLMNPQRSTVWY";
	expected=@"ACDEFGHIKLMNPQRSTVWY";
	sequence=[BCSequence sequenceWithString:initial symbolSet:[BCSymbolSet proteinStrictSymbolSet]];
	obtained=[sequence sequenceString];
	
	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
			expected,obtained];
	if ([sequence sequenceType]!=BCSequenceTypeProtein)
		[error appendFormat:@"Sequence should be protein but is %d\n",
			[sequence sequenceType]];
	if ([sequence symbolSet]!=[BCSymbolSet proteinStrictSymbolSet])
		[error appendFormat:@"Symbol set should be %@ but is %@\n",
			[BCSymbolSet proteinStrictSymbolSet],[sequence symbolSet]];
	if ([[sequence symbolSet] sequenceType]!=[sequence sequenceType])
		[error appendFormat:@"The symbol set is of type %d but should be of type %d, the same type as the sequence\n",
			[[sequence symbolSet] sequenceType],[sequence sequenceType]];
	//if error!=@"", the test failed
	STAssertTrue ( [error isEqualToString:@""],error);
}

//initializer with string
//using strict symbol set
//some unknown symbols
- (void)testInitStringStrictSymbolSetUnknownSymbols
{
	NSString *initial,*expected,*obtained;
	BCSequence *sequence;
	
	initial= @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	expected=@"ACDEFGHIKLMNPQRSTVWY";
	sequence=[BCSequence sequenceWithString:initial symbolSet:[BCSymbolSet proteinStrictSymbolSet]];
	obtained=[sequence sequenceString];
	
	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
			expected,obtained];
	if ([sequence sequenceType]!=BCSequenceTypeProtein)
		[error appendFormat:@"Sequence should be protein but is %d\n",
			[sequence sequenceType]];
	if ([sequence symbolSet]!=[BCSymbolSet proteinStrictSymbolSet])
		[error appendFormat:@"Symbol set should be %@ but is %@\n",
			[BCSymbolSet proteinStrictSymbolSet],[sequence symbolSet]];
	if ([[sequence symbolSet] sequenceType]!=[sequence sequenceType])
		[error appendFormat:@"The symbol set is of type %d but should be of type %d, the same type as the sequence\n",
			[[sequence symbolSet] sequenceType],[sequence sequenceType]];
	//if error!=@"", the test failed
	STAssertTrue ( [error isEqualToString:@""],error);
}


//initializer with string
//using custom symbol set
- (void)testInitStringCustomSymbolSet
{
	NSString *initial,*expected,*obtained;
	BCSequence *sequence;
	BCSymbolSet *set;
	
	initial= @"ATGJOUX(87)TTGGAGGACGTRYMKSWHBVDNATGGGTTACNGAGHBCG123T";
	expected=@"AAAAAA";
	set=[BCSymbolSet symbolSetWithString:@"A" sequenceType:BCSequenceTypeProtein];
	sequence=[BCSequence sequenceWithString:initial symbolSet:set];
	obtained=[sequence sequenceString];
	
	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
			expected,obtained];
	if ([sequence sequenceType]!=BCSequenceTypeProtein)
		[error appendFormat:@"Sequence should be protein but is %d\n",
			[sequence sequenceType]];
	if ([sequence symbolSet]!=set)
		[error appendFormat:@"Symbol set should be %@ but is %@\n",
			set,[sequence symbolSet]];
	if ([[sequence symbolSet] sequenceType]!=[sequence sequenceType])
		[error appendFormat:@"The symbol set is of type %d but should be of type %d, the same type as the sequence\n",
			[[sequence symbolSet] sequenceType],[sequence sequenceType]];
	//if error!=@"", the test failed
	STAssertTrue ( [error isEqualToString:@""],error);
}


//initializer with string
//using empty symbol set
- (void)testInitStringEmptySymbolSet
{
	NSString *initial,*expected,*obtained;
	BCSequence *sequence;
	BCSymbolSet *set;
	
	initial= @"ATGJOUX(87)TTGGAGGACGTRYMKSWHBVDNATGGGTTACNGAGHBCG123T";
	expected=@"";
	set=[BCSymbolSet symbolSetWithString:@"" sequenceType:BCSequenceTypeProtein];
	sequence=[BCSequence sequenceWithString:initial symbolSet:set];
	obtained=[sequence sequenceString];
	
	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
			expected,obtained];
	if ([sequence sequenceType]!=BCSequenceTypeProtein)
		[error appendFormat:@"Sequence should be protein but is %d\n",
			[sequence sequenceType]];
	if ([sequence symbolSet]!=set)
		[error appendFormat:@"Symbol set should be %@ but is %@\n",
			set,[sequence symbolSet]];
	if ([[sequence symbolSet] sequenceType]!=[sequence sequenceType])
		[error appendFormat:@"The symbol set is of type %d but should be of type %d, the same type as the sequence\n",
			[[sequence symbolSet] sequenceType],[sequence sequenceType]];
	//if error!=@"", the test failed
	STAssertTrue ( [error isEqualToString:@""],error);
}

@end
