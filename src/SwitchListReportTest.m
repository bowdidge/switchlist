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
#import "FreightCar.h"
#import "Industry.h"
#import "Report.h"
#import "ScheduledTrain.h"
#import "SwitchListDocumentInterface.h"
#import "SwitchListReport.h"



@interface MockSwitchListDocument : NSObject<SwitchListDocumentInterface> {
	EntireLayout *layout;
	DoorAssignmentRecorder *recorder;
}
- (EntireLayout*) entireLayout;
- (DoorAssignmentRecorder*) doorAssignmentRecorder;
@end

@implementation MockSwitchListDocument 
- (id) initWithLayout: (EntireLayout*) entireLayout {
	[super init];
	layout = [entireLayout retain];
	recorder = [[DoorAssignmentRecorder alloc] init];
	return self;
}

- (void) dealloc {
	[layout release];
	[recorder release];
	[super dealloc];
}

- (EntireLayout*) entireLayout {
	return layout;
}
- (DoorAssignmentRecorder*) doorAssignmentRecorder {
	return recorder;
}
@end

@implementation SwitchListReportTest
	
- (void) testSimpleReport {
	[self makeThreeStationLayout];
	MockSwitchListDocument *mockDocument = [[[MockSwitchListDocument alloc] initWithLayout: entireLayout_] autorelease];
	[self makeThreeStationTrain];
	ScheduledTrain *train = [entireLayout_ trainWithName: @"MyTrain"]; 

	SwitchListReport *report = [[[SwitchListReport alloc] init] autorelease];
	[report setTrain: train];
	[report setObjects: [[train freightCars] allObjects]];
	[report setOwningDocument:  mockDocument]; 
	NSString *result = [report contents];
	STAssertTrue([result rangeOfString: FREIGHT_CAR_1_NAME].length > 0, @"Car entry not found.");
	// TODO(bowdidge): Wrong test. Looking for regexp of industry # number.
	STAssertTrue([result rangeOfString: @"door"].length == 0, 
				 [NSString stringWithFormat: @"Door indicators should not be set:%@", report]);
}

- (void) testReportShowsDoor {
	[self makeThreeStationLayout];
	MockSwitchListDocument *mockDocument = [[[MockSwitchListDocument alloc] initWithLayout: entireLayout_] autorelease];
	[self makeThreeStationTrain];
	ScheduledTrain *train = [entireLayout_ trainWithName: @"MyTrain"]; 
	
	SwitchListReport *report = [[[SwitchListReport alloc] init] autorelease];
	[report setTrain: train];
	[report setObjects: [[train freightCars] allObjects]];
	
	Industry *industryB = [self industryAtStation: @"B"];
	[industryB setHasDoors: YES];
	[industryB setNumberOfDoors: [NSNumber numberWithInt: 1]];
	[[mockDocument doorAssignmentRecorder] setCar: [self freightCarWithReportingMarks: FREIGHT_CAR_1_NAME]
			   destinedForIndustry: [self industryAtStation: @"B"]
							  door: 1];

	[report setOwningDocument: mockDocument]; 
	NSString *result = [report contents];
	STAssertTrue([result rangeOfString: FREIGHT_CAR_1_NAME].length > 0, @"Car entry not found.");
	STAssertTrue([result rangeOfString: @"B-industry #1"].length > 0, 
				 [NSString stringWithFormat: @"Door indicators should be set:%@", report]);
}
@end
