//
//  CargoReportTest.m
//  SwitchList
//
//  Created by Robert Bowdidge on 10/28/10.
//
// Copyright (c)2010 Robert Bowdidge,
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

#import "CargoReportTest.h"

#import "Cargo.h"
#import "CargoReport.h"
#import "EntireLayout.h"

@implementation CargoReportTest

- (void) testCargoReport {
	CargoReport *cargoReport = [[[CargoReport alloc] initWithDocument: nil
													   withIndustries: [NSArray array]] autorelease];
	[cargoReport setObjects: [entireLayout_ allValidCargos]];
	STAssertEqualObjects([cargoReport typeString], @"Cargo report", @"Report name not correct");
	STAssertEqualObjects([cargoReport contents], @"No cargos defined", @"Make sure empty report ok");
}

// Make sure we don't fall over with missing car types.
- (void) testTrivialCargoReport {
	[self makeThreeStationLayout];
	[self makeThreeStationTrain];
	NSArray *allIndustries = [entireLayout_ allIndustries];
	STAssertEqualsInt(3, [allIndustries count],  @"Not enough industries for test");
	CargoReport *cargoReport = [[CargoReport alloc] initWithDocument: nil
													  withIndustries: [entireLayout_ allIndustries]];
	STAssertNotNil([entireLayout_ allValidCargos], @"");
	[cargoReport setObjects: [entireLayout_ allValidCargos]];
	STAssertNotNil([cargoReport contents], @"contents should not be empty");
	STAssertContains(@"A-industry", [cargoReport contents], @"Make sure A-industry appears in report");
}

// Make sure we don't fall over with missing car types.
- (void) testSimpleCargoReport {
	[self makeThreeStationLayout];
	[self makeThreeStationTrain];
	NSArray *allIndustries = [entireLayout_ allIndustries];
	STAssertEqualsInt(3, [allIndustries count], @"Not enough industries for test");
	CargoReport *cargoReport = [[CargoReport alloc] initWithDocument: nil
													  withIndustries: [entireLayout_ allIndustries]];
	NSArray *cargos = [entireLayout_ allValidCargos];
	[((Cargo*)[cargos objectAtIndex: 0]) setCarTypeRel: [entireLayout_ carTypeForName: @"XM"]];
	[((Cargo*)[cargos objectAtIndex: 1]) setCarTypeRel: [entireLayout_ carTypeForName: @"XA"]];
	[cargoReport setObjects: [entireLayout_ allValidCargos]];
	NSString *contents = [cargoReport contents];
	STAssertNotNil(contents, @"Contents should not be empty.");
	STAssertContains(@"30/  0", contents, @"Expected 30/0, got %@", contents);
}


@end
