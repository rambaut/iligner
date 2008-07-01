//
//  TestBCSequenceProteinInit.m
//  BioCocoa-test
//

/* NEEDS TO BE UPDATED - TEMPORARILY REMOVED FROM Test - BCFoundation TARGET */

#import "TestBCSequenceProteinInit.h"


@implementation TestBCSequenceProteinInit

//initializer with string
//using default symbol set
//all known symbols
- (void)testInitStringKnownSymbols
{
	NSString *initial,*expected,*obtained;
	BCSequenceProtein *sequence;
	
	initial= @"ACDEFGHIKLMNPQRSTVWYBZ";
	expected=@"ACDEFGHIKLMNPQRSTVWYBZ";
	sequence=[BCSequenceProtein sequenceWithString:initial];
	obtained=[sequence sequenceString];
	
	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
			expected,obtained];
	if ([sequence sequenceType]!=BCProteinSequence)
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
	BCSequenceProtein *sequence;
	
	initial= @"ABCDEFGHIJKLMNOPQRSTUVWXYZ(123)ACDEFGHIKL[87~!]MNPQRSTVWYBZ";
	expected=@"ABCDEFGHIKLMNPQRSTVWYZACDEFGHIKLMNPQRSTVWYBZ";
	sequence=[BCSequenceProtein sequenceWithString:initial];
	obtained=[sequence sequenceString];
	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
			expected,obtained];
	if ([sequence sequenceType]!=BCProteinSequence)
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
	BCSequenceProtein *sequence;
	
	initial= @"";
	expected=@"";
	sequence=[BCSequenceProtein sequenceWithString:initial];
	obtained=[sequence sequenceString];
	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
			expected,obtained];
	if ([sequence sequenceType]!=BCProteinSequence)
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
	BCSequenceProtein *sequence;
	
	initial= @"JOUX123458()%$#@!#";
	expected=@"";
	sequence=[BCSequenceProtein sequenceWithString:initial];
	obtained=[sequence sequenceString];
	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
			expected,obtained];
	if ([sequence sequenceType]!=BCProteinSequence)
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
	BCSequenceProtein *sequence;
	
	initial= @"ACDEFGHIKLMNPQRSTVWY";
	expected=@"ACDEFGHIKLMNPQRSTVWY";
	sequence=[BCSequenceProtein sequenceWithString:initial symbolSet:[BCSymbolSet proteinStrictSymbolSet]];
	obtained=[sequence sequenceString];
	
	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
			expected,obtained];
	if ([sequence sequenceType]!=BCProteinSequence)
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
	BCSequenceProtein *sequence;
	
	initial= @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	expected=@"ACDEFGHIKLMNPQRSTVWY";
	sequence=[BCSequenceProtein sequenceWithString:initial symbolSet:[BCSymbolSet proteinStrictSymbolSet]];
	obtained=[sequence sequenceString];
	
	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
			expected,obtained];
	if ([sequence sequenceType]!=BCProteinSequence)
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
//using symbol set of the wrong type --> default symbol set
//some unknown symbols
- (void)testInitStringWrongSymbolSet
{
	NSString *initial,*expected,*obtained;
	BCSequenceProtein *sequence;
	
	initial= @"ABCDEFGHIJKLMNOPQRSTUVWXYZ(123)ACDEFGHIKL[87~!]MNPQRSTVWYBZ";
	expected=@"ABCDEFGHIKLMNPQRSTVWYZACDEFGHIKLMNPQRSTVWYBZ";
	sequence=[BCSequenceProtein sequenceWithString:initial symbolSet:[BCSymbolSet rnaSymbolSet]];
	obtained=[sequence sequenceString];
	
	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
			expected,obtained];
	if ([sequence sequenceType]!=BCProteinSequence)
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
//using custom symbol set
- (void)testInitStringCustomSymbolSet
{
	NSString *initial,*expected,*obtained;
	BCSequenceProtein *sequence;
	BCSymbolSet *set;
	
	initial= @"ATGJOUX(87)TTGGAGGACGTRYMKSWHBVDNATGGGTTACNGAGHBCG123T";
	expected=@"AAAAAA";
	set=[BCSymbolSet symbolSetWithString:@"A" sequenceType:BCProteinSequence];
	sequence=[BCSequenceProtein sequenceWithString:initial symbolSet:set];
	obtained=[sequence sequenceString];
	
	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
			expected,obtained];
	if ([sequence sequenceType]!=BCProteinSequence)
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
	BCSequenceProtein *sequence;
	BCSymbolSet *set;
	
	initial= @"ATGJOUX(87)TTGGAGGACGTRYMKSWHBVDNATGGGTTACNGAGHBCG123T";
	expected=@"";
	set=[BCSymbolSet symbolSetWithString:@"" sequenceType:BCProteinSequence];
	sequence=[BCSequenceProtein sequenceWithString:initial symbolSet:set];
	obtained=[sequence sequenceString];
	
	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
			expected,obtained];
	if ([sequence sequenceType]!=BCProteinSequence)
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
