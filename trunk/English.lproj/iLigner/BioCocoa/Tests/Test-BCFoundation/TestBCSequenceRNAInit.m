//
//  TestBCSequenceRNAInit.m
//  BioCocoa-test
//

/* NEEDS TO BE UPDATED - TEMPORARILY REMOVED FROM Test - BCFoundation TARGET */

#import "TestBCSequenceRNAInit.h"


@implementation TestBCSequenceRNAInit

//initializer with string
//using default symbol set
//all known symbols
- (void)testInitStringKnownSymbols
{
	NSString *initial,*expected,*obtained;
	BCSequenceRNA *sequence;
	
	initial= @"AUGUUGGAGGAUGGGUUACGACGURYMKSWHBVDNAGCGU";
	expected=@"AUGUUGGAGGAUGGGUUACGACGURYMKSWHBVDNAGCGU";
	sequence=[BCSequenceRNA sequenceWithString:initial];
	obtained=[sequence sequenceString];
	
	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
				   expected,obtained];
	if ([sequence sequenceType]!=BCRNASequence)
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
	BCSequenceRNA *sequence;
	
	initial= @"AUG(87)UUGGAGGAUGGGUUACGACGURYMK[128~]SWHBVDNAGCGU";
	expected=@"AUGUUGGAGGAUGGGUUACGACGURYMKSWHBVDNAGCGU";
	sequence=[BCSequenceRNA sequenceWithString:initial];
	obtained=[sequence sequenceString];
	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
			expected,obtained];
	if ([sequence sequenceType]!=BCRNASequence)
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
	BCSequenceRNA *sequence;
	
	initial= @"";
	expected=@"";
	sequence=[BCSequenceRNA sequenceWithString:initial];
	obtained=[sequence sequenceString];
	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
			expected,obtained];
	if ([sequence sequenceType]!=BCRNASequence)
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
	BCSequenceRNA *sequence;
	
	initial= @"123458()%$#@!#";
	expected=@"";
	sequence=[BCSequenceRNA sequenceWithString:initial];
	obtained=[sequence sequenceString];
	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
			expected,obtained];
	if ([sequence sequenceType]!=BCRNASequence)
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
	BCSequenceRNA *sequence;
	
	initial= @"AUGUUGGAGGAUGGGUUACGAGCGU";
	expected=@"AUGUUGGAGGAUGGGUUACGAGCGU";
	sequence=[BCSequenceRNA sequenceWithString:initial symbolSet:[BCSymbolSet rnaStrictSymbolSet]];
	obtained=[sequence sequenceString];

	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
			expected,obtained];
	if ([sequence sequenceType]!=BCRNASequence)
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
	BCSequenceRNA *sequence;
	
	initial= @"AUG(87)UUGGAGGACGURYMKSWHBVDNAUGGGUUACNGAGHBCG123U";
	expected=@"AUGUUGGAGGACGUAUGGGUUACGAGCGU";
	sequence=[BCSequenceRNA sequenceWithString:initial symbolSet:[BCSymbolSet rnaStrictSymbolSet]];
	obtained=[sequence sequenceString];

	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
			expected,obtained];
	if ([sequence sequenceType]!=BCRNASequence)
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
//using symbol set of the wrong type --> default symbol set
//some unknown symbols
- (void)testInitStringWrongSymbolSet
{
	NSString *initial,*expected,*obtained;
	BCSequenceRNA *sequence;
	
	initial= @"AUG(87)UUGGAGGAUGGGUUACGACGURYMK[128~]SWHBVDNAGCG123U";
	expected=@"AUGUUGGAGGAUGGGUUACGACGURYMKSWHBVDNAGCGU";
	sequence=[BCSequenceRNA sequenceWithString:initial symbolSet:[BCSymbolSet dnaSymbolSet]];
	obtained=[sequence sequenceString];

	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
			expected,obtained];
	if ([sequence sequenceType]!=BCRNASequence)
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
//using custom symbol set
- (void)testInitStringCustomSymbolSet
{
	NSString *initial,*expected,*obtained;
	BCSequenceRNA *sequence;
	BCSymbolSet *set;
	
	initial= @"AUG(87)UUGGAGGACGURYMKSWHBVDNAUGGGUUACNGAGHBCG123U";
	expected=@"AAAAAA";
	set=[BCSymbolSet symbolSetWithString:@"A" sequenceType:BCRNASequence];
	sequence=[BCSequenceRNA sequenceWithString:initial symbolSet:set];
	obtained=[sequence sequenceString];

	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
			expected,obtained];
	if ([sequence sequenceType]!=BCRNASequence)
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
	BCSequenceRNA *sequence;
	BCSymbolSet *set;
	
	initial= @"AUG(87)UUGGAGGACGURYMKSWHBVDNAUGGGUUACNGAGHBCG123U";
	expected=@"";
	set=[BCSymbolSet symbolSetWithString:@"" sequenceType:BCRNASequence];
	sequence=[BCSequenceRNA sequenceWithString:initial symbolSet:set];
	obtained=[sequence sequenceString];

	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
			expected,obtained];
	if ([sequence sequenceType]!=BCRNASequence)
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
//using default symbol set, converting thymidines = YES
//all known symbols
//No U, only Ts
- (void)testInitStringKnownSymbolsConvertingThymidinesYes
{
	NSString *initial,*expected,*obtained;
	BCSequenceRNA *sequence;
	
	initial= @"ATGTTGGAGGATGGGTTACGACGTRYMKSWHBVDNAGCGT";
	expected=@"AUGUUGGAGGAUGGGUUACGACGURYMKSWHBVDNAGCGU";
	sequence=[[[BCSequenceRNA alloc] initWithString:initial convertingThymidines:YES] autorelease];
	obtained=[sequence sequenceString];
	
	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
			expected,obtained];
	if ([sequence sequenceType]!=BCRNASequence)
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
//using default symbol set, converting thymidines = NO
//all known symbols
//No U, only Ts
- (void)testInitStringKnownSymbolsConvertingThymidinesNo
{
	NSString *initial,*expected,*obtained;
	BCSequenceRNA *sequence;
	
	initial= @"ATGTTGGAGGATGGGTTACGACGTRYMKSWHBVDNAGCGT";
	expected=@"AGGGAGGAGGGACGACGRYMKSWHBVDNAGCG";
	sequence=[[[BCSequenceRNA alloc] initWithString:initial convertingThymidines:NO] autorelease];
	obtained=[sequence sequenceString];
	
	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
			expected,obtained];
	if ([sequence sequenceType]!=BCRNASequence)
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
//using default symbol set, converting thymidines = YES
//all known symbols
//Some U, some Ts
- (void)testInitStringKnownSymbolsConvertingThymidinesYesMixUT
{
	NSString *initial,*expected,*obtained;
	BCSequenceRNA *sequence;
	
	initial= @"ATGTUGGAGGAUGGGUUACGACGTRYMKSWHBVDNAGCGT";
	expected=@"AUGUUGGAGGAUGGGUUACGACGURYMKSWHBVDNAGCGU";
	sequence=[[[BCSequenceRNA alloc] initWithString:initial convertingThymidines:YES] autorelease];
	obtained=[sequence sequenceString];
	
	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
			expected,obtained];
	if ([sequence sequenceType]!=BCRNASequence)
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


@end
