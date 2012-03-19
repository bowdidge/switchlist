//
//  ScheduledTrainTest.h
//  SwitchList
//
//  Created by Robert Bowdidge on 2/23/12.
//
// Copyright (c)2012 Robert Bowdidge,
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


#import "EntireLayout.h"
#import "FreightCar.h"
#import "ScheduledTrain.h"
#import "ScheduledTrainTest.h"


@implementation ScheduledTrainTest
- (void) setUp {
	[super setUp];
	[self makeThreeStationLayout];
}

- (void) testStationStrings {
	[self makeThreeStationTrain];
	
	ScheduledTrain *train = [entireLayout_ trainWithName: @"MyTrain"];
	// Test raw string is the old form with commas.
	STAssertEqualObjects(@"A,B,C", [train stops], @"Station stops not as expected.");
	
	// Test that the parsing code correctly handles the old-style separator.
	NSArray *stationStops = [train stationStopObjects];
	NSLog(@"%d", [stationStops count]);
	STAssertEqualsInt(3, [stationStops count], @"Wrong number of items in station stop array");
	STAssertEqualObjects(@"A", [[stationStops objectAtIndex: 0] name], @"station stops array wrong");
	STAssertEqualObjects(@"B", [[stationStops objectAtIndex: 1] name], @"station stops array wrong");
	STAssertEqualObjects(@"C", [[stationStops objectAtIndex: 2] name], @"station stops array wrong");
}	

- (void) testStationStringsWithComma {
	[self makeThreeStationTrain];
	Place *p1 = [self makePlaceWithName: @"Erie, Pennsylvania"];
	Place *p2 = [self makePlaceWithName: @"Pasco, WA"];
	Place *p3 = [self makePlaceWithName: @"College Park Yard, San Jose"];
	ScheduledTrain *train = [entireLayout_ trainWithName: @"MyTrain"];
	[train setStationStopObjects: [NSArray arrayWithObjects: p1, p2, p3, nil]];

	NSArray *stationStops = [train stationStopObjects];
	STAssertEqualsInt(3, [stationStops count], @"Wrong number of items in station stop array");
	STAssertEqualObjects(p1, [stationStops objectAtIndex: 0], @"station stops array wrong");
	STAssertEqualObjects(p2, [stationStops objectAtIndex: 1], @"station stops array wrong");
	STAssertEqualObjects(p3, [stationStops objectAtIndex: 2], @"station stops array wrong");
}	
@end
