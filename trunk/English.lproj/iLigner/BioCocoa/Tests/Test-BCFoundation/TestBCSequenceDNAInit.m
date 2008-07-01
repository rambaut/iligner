//
//  TestBCSequenceDNAInit.m
//  BioCocoa-test
//

#import "TestBCSequenceDNAInit.h"


@implementation TestBCSequenceDNAInit

//initializer with string
//using default symbol set
//all known symbols
- (void)testInitStringKnownSymbols
{
	NSString *initial,*expected,*obtained;
	BCSequenceDNA *sequence;
	
	initial= @"ATGTTGGAGGATGGGTTACGACGTRYMKSWHBVDNAGCGT";
	expected=@"ATGTTGGAGGATGGGTTACGACGTRYMKSWHBVDNAGCGT";
	sequence=[BCSequenceDNA sequenceWithString:initial];
	obtained=[sequence sequenceString];
	
	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
				   expected,obtained];
	if ([sequence sequenceType]!=BCDNASequence)
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
	BCSequenceDNA *sequence;
	
	initial= @"ATG(87)TTGGAGGATGGGTTAACGTRYMK[128~]SWHBVDNCNGAGHBCG123T";
	expected=@"ATGTTGGAGGATGGGTTAACGTRYMKSWHBVDNCNGAGHBCGT";
	sequence=[BCSequenceDNA sequenceWithString:initial];
	obtained=[sequence sequenceString];
	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
			expected,obtained];
	if ([sequence sequenceType]!=BCDNASequence)
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
	BCSequenceDNA *sequence;
	
	initial= @"";
	expected=@"";
	sequence=[BCSequenceDNA sequenceWithString:initial];
	obtained=[sequence sequenceString];
	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
			expected,obtained];
	if ([sequence sequenceType]!=BCDNASequence)
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
	BCSequenceDNA *sequence;
	
	initial= @"123458()%$#@!#";
	expected=@"";
	sequence=[BCSequenceDNA sequenceWithString:initial];
	obtained=[sequence sequenceString];
	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
			expected,obtained];
	if ([sequence sequenceType]!=BCDNASequence)
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
	BCSequenceDNA *sequence;
	
	initial= @"ATGTTGGAGGATGGGTTACGAGCGT";
	expected=@"ATGTTGGAGGATGGGTTACGAGCGT";
	sequence=[BCSequenceDNA sequenceWithString:initial symbolSet:[BCSymbolSet dnaStrictSymbolSet]];
	obtained=[sequence sequenceString];

	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
			expected,obtained];
	if ([sequence sequenceType]!=BCDNASequence)
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
	BCSequenceDNA *sequence;
	
	initial= @"ATG(87)TTGGAGGACGTRYMKSWHBVDNATGGGTTACNGAGHBCG123T";
	expected=@"ATGTTGGAGGACGTATGGGTTACGAGCGT";
	sequence=[BCSequenceDNA sequenceWithString:initial symbolSet:[BCSymbolSet dnaStrictSymbolSet]];
	obtained=[sequence sequenceString];

	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
			expected,obtained];
	if ([sequence sequenceType]!=BCDNASequence)
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
//using symbol set of the wrong type --> default symbol set
//some unknown symbols
- (void)testInitStringWrongSymbolSet
{
	NSString *initial,*expected,*obtained;
	BCSequenceDNA *sequence;
	
	initial= @"ATG(87)TTGGAGGATGGGTTAACGTRYMK[128~]SWHBVDNCNGAGHBCG123T";
	expected=@"ATGTTGGAGGATGGGTTAACGTRYMKSWHBVDNCNGAGHBCGT";
	sequence=[BCSequenceDNA sequenceWithString:initial symbolSet:[BCSymbolSet rnaSymbolSet]];
	obtained=[sequence sequenceString];

	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
			expected,obtained];
	if ([sequence sequenceType]!=BCDNASequence)
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
//using custom symbol set
- (void)testInitStringCustomSymbolSet
{
	NSString *initial,*expected,*obtained;
	BCSequenceDNA *sequence;
	BCSymbolSet *set;
	
	initial= @"ATG(87)TTGGAGGACGTRYMKSWHBVDNATGGGTTACNGAGHBCG123T";
	expected=@"AAAAAA";
	set=[BCSymbolSet symbolSetWithString:@"A" sequenceType:BCDNASequence];
	sequence=[BCSequenceDNA sequenceWithString:initial symbolSet:set];
	obtained=[sequence sequenceString];

	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
			expected,obtained];
	if ([sequence sequenceType]!=BCDNASequence)
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
	BCSequenceDNA *sequence;
	BCSymbolSet *set;
	
	initial= @"ATG(87)TTGGAGGACGTRYMKSWHBVDNATGGGTTACNGAGHBCG123T";
	expected=@"";
	set=[BCSymbolSet symbolSetWithString:@"" sequenceType:BCDNASequence];
	sequence=[BCSequenceDNA sequenceWithString:initial symbolSet:set];
	obtained=[sequence sequenceString];

	//all the errors are concatenated
	NSMutableString *error=[NSMutableString stringWithString:@""];
	if (sequence==nil)
		[error appendString:@"Sequence is nil\n"];
	if (![obtained isEqual:expected])
		[error appendFormat:@"Sequence should be %@, but is %@\n",
			expected,obtained];
	if ([sequence sequenceType]!=BCDNASequence)
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
