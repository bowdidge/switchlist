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
- (void) testStationStrings {
	[self makeThreeStationLayout];
	[self makeThreeStationTrain];
	
	ScheduledTrain *train = [entireLayout_ trainWithName: @"MyTrain"];
	
	STAssertEqualObjects(@"A,B,C", [train stops], @"Station stops not as expected.");
	NSArray *stationStops = [train stationStopStrings];
	NSLog(@"%d", [stationStops count]);
	STAssertEqualsInt(3, [stationStops count], @"Wrong number of items in stationStopStrings");
	STAssertEqualObjects(@"A", [stationStops objectAtIndex: 0], @"station stops array wrong");
	STAssertEqualObjects(@"B", [stationStops objectAtIndex: 1], @"station stops array wrong");
	STAssertEqualObjects(@"C", [stationStops objectAtIndex: 2], @"station stops array wrong");
}	

- (void) testChangeInTrainLengthArray {
	[self makeThreeStationLayout];
	[self makeThreeStationTrain];

	ScheduledTrain *train = [entireLayout_ trainWithName: @"MyTrain"];

	NSLog(@"%@", [train allFreightCarsInVisitOrder]);

	NSArray *changeInLength = [train changeInTrainLengthArray];
	STAssertEqualsInt(3, [changeInLength count], @"");
	// Car1 goes a to b, car2 goes b to c.
	STAssertEqualsInt(1, [[changeInLength objectAtIndex: 0] intValue], @"");
	STAssertEqualsInt(0, [[changeInLength objectAtIndex: 1] intValue], @"");
	STAssertEqualsInt(-1, [[changeInLength objectAtIndex: 2] intValue], @"");
}

- (void) testTrainLengthArrayCorrectlyHandlesCarsNotMovedBetweenTowns {
	[self makeThreeStationLayout];
	[self makeThreeStationTrain];
	
	ScheduledTrain *train = [entireLayout_ trainWithName: @"MyTrain"];
	// Cars 1 stays at A, car 2 goes A-> B.
	[[entireLayout_ freightCarWithName: FREIGHT_CAR_1_NAME] setIsLoaded: NO];
	[[entireLayout_ freightCarWithName: FREIGHT_CAR_1_NAME] setIsLoaded: NO];
	
	NSLog(@"%@", [train allFreightCarsInVisitOrder]);
	
	NSArray *changeInLength = [train changeInTrainLengthArray];
	STAssertEqualsInt(3, [changeInLength count], @"");
	STAssertEqualsInt(1, [[changeInLength objectAtIndex: 0] intValue], @"");
	STAssertEqualsInt(-1, [[changeInLength objectAtIndex: 1] intValue], @"");
	STAssertEqualsInt(0, [[changeInLength objectAtIndex: 2] intValue], @"");
}

- (void) testTrain2 {
	[self makeThreeStationLayout];
	[self makeThreeStationTrain];
	
	ScheduledTrain *train = [entireLayout_ trainWithName: @"MyTrain"];
	// Cars 1 stays at A, car 2 goes A-> B.
	[[entireLayout_ freightCarWithName: FREIGHT_CAR_1_NAME] setIsLoaded: NO];
	[[entireLayout_ freightCarWithName: FREIGHT_CAR_1_NAME] setIsLoaded: NO];
	
	NSLog(@"%@", [train allFreightCarsInVisitOrder]);
	
	NSArray *changeInLength = [train changeInTrainLengthArray];
	STAssertEqualsInt(3, [changeInLength count], @"");
	STAssertEqualsInt(1, [[changeInLength objectAtIndex: 0] intValue], @"");
	STAssertEqualsInt(-1, [[changeInLength objectAtIndex: 1] intValue], @"");
	STAssertEqualsInt(0, [[changeInLength objectAtIndex: 2] intValue], @"");
}

@end
