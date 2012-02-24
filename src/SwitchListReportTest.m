//
//  SwitchListReportTest.m
//  SwitchList
//
//  Created by bowdidge on 12/11/10.
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

#import "SwitchListReportTest.h"

#import "Cargo.h"
#import "DoorAssignmentRecorder.h"
#import "EntireLayout.h";
#import "FakeSwitchListDocument.h"
#import "FreightCar.h"
#import "Industry.h"
#import "Report.h"
#import "ScheduledTrain.h"
#import "SwitchListDocumentInterface.h"
#import "SwitchListReport.h"

@implementation SwitchListReportTest
	
- (void) testSimpleReport {
	[self makeThreeStationLayout];
	FakeSwitchListDocument *mockDocument = [[[FakeSwitchListDocument alloc] initWithLayout: entireLayout_] autorelease];
	[self makeThreeStationTrain];
	ScheduledTrain *train = [entireLayout_ trainWithName: @"MyTrain"]; 

	SwitchListReport *report = [[[SwitchListReport alloc] initWithFrame: NSMakeRect(0,0,400,400) withDocument: mockDocument] autorelease];
	[report setTrain: train];
	NSString *result = [report contents];
	STAssertContains(FREIGHT_CAR_1_NAME, result, @"Car entry not found.");
	// TODO(bowdidge): Wrong test. Looking for regexp of industry # number.
	STAssertNotContains(@"door", result,
						[NSString stringWithFormat: @"Door indicators should not be set:%@", report]);
}

- (void) testReportShowsDoor {
	[self makeThreeStationLayout];
	FakeSwitchListDocument *mockDocument = [[[FakeSwitchListDocument alloc] initWithLayout: entireLayout_] autorelease];
	[self makeThreeStationTrain];
	ScheduledTrain *train = [entireLayout_ trainWithName: @"MyTrain"]; 
	
	SwitchListReport *report = [[[SwitchListReport alloc] initWithFrame: NSMakeRect(0, 0, 400, 400) withDocument: mockDocument] autorelease];
	[report setTrain: train];
	
	Industry *industryB = [self industryAtStation: @"B"];
	[industryB setHasDoors: YES];
	[industryB setNumberOfDoors: [NSNumber numberWithInt: 1]];
	[[mockDocument doorAssignmentRecorder] setCar: [self freightCarWithReportingMarks: FREIGHT_CAR_2_NAME]
			   destinedForIndustry: [self industryAtStation: @"B"]
							  door: 1];

	NSString *result = [report contents];
	STAssertContains(FREIGHT_CAR_1_NAME, result, @"Car entry not found.");
	STAssertContains(@"B-industry #1", result,
					 [NSString stringWithFormat: @"Door indicators should be set:%@", report]);
}
@end
