//
//  ReportTest.m
//  SwitchList
//
//  Tests for the Report class.
//
//  Created by Robert Bowdidge on 2/25/11.
//
// Copyright (c)2011 Robert Bowdidge,
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
// 
// THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
// OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
// HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
// LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
// OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
// SUCH DAMAGE.

#import "ReportTest.h"

#import "EntireLayout.h"
#import "Report.h"
#import "SwitchlistDocumentInterface.h"

// Fake the NSTextView to test line lengths.
@interface MockTextView : NSObject {
}
- (NSSize) maxSize;
@end

@implementation MockTextView
- (NSSize) maxSize {
	return NSMakeSize(60, 400);
}
@end

// Fake the document to make sure layoutName is correctly accessed.
@interface MockDocument : NSDocument<SwitchListDocumentInterface> {
@public
	EntireLayout *entireLayout_;
}
- (EntireLayout*) entireLayout;
@end

@implementation MockDocument 
- (EntireLayout*) entireLayout {
	return entireLayout_;
}
- (id) doorAssignmentRecorder {
	return nil;
}
@end

@implementation ReportTest
- (void) setUp {
	[super setUp];
	[self makeSimpleLayout];
	MockDocument *mockDoc = [[[MockDocument alloc] init] autorelease];
	mockDoc->entireLayout_ = entireLayout_;
	[entireLayout_ setLayoutName: @"My layout"];
	[entireLayout_ setCurrentDate: [NSDate dateWithTimeIntervalSince1970: 0]];
	
	report_ = [[Report alloc] initWithDocument: mockDoc];
	[report_ setReportTextView: [[[MockTextView alloc] init] autorelease]];
	[report_ setTypedFont: [NSFont userFixedPitchFontOfSize: 10.0]];
}

- (void) testLineLength {
	STAssertEqualsInt(10, [report_ lineLength], @"Line length was %d, not 100", [report_ lineLength]);
}

- (void) testCenteredString {
	STAssertEqualObjects(@"   AAAA", [report_ centeredString: @"AAAA"], @"AAAA not centered, was '%@'.", [report_ centeredString: @"AAAA"]);
	STAssertEqualObjects(@"    A", [report_ centeredString: @"A"], @"A not centered, was '%@'.", [report_ centeredString: @"A"]);
	STAssertEqualObjects(@"1234567890", [report_ centeredString: @"1234567890"], @"filling string not centered");
	STAssertEqualObjects(@"12345678901", [report_ centeredString: @"12345678901"], @"long string not centered");
	STAssertEqualObjects(@"Generic Report", [report_ centeredString: @"Generic Report"], @"long string not centered.");
}

- (void) testLayoutName {
	STAssertEqualObjects(@"My layout", [report_ layoutName], @"");
	STAssertEqualObjects(@"Generic report", [report_ typeString], @"");
}

- (void) testCurrentDate {
	STAssertEqualObjects(@"12/31/69", [report_ currentDate], @"");
}

- (void) testHeader {
	NSString *header = [report_ headerString];
	STAssertContains(@"MY LAYOUT", header, @"");
}

- (NSString*) nLines: (int) count {
	NSMutableString *string = [NSMutableString string];
	int i;
	for (i=0; i<count; i++) {
		[string appendFormat: @"%d\n", i];
	}
	return string;
}

- (void) testTwoColumn {
	//NSString *contents = [self nLines: 100];
	//NSString *result = [report_ convertToTwoColumn: contents];
	//STFail(result);
}
	
	

// TODO(bowdidge): Add tests for nextDestinationForFreightCar:
@end
