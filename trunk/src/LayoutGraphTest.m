//
//  LayoutGraphTest.m
//  SwitchList
//
//  Created by bowdidge on 10/7/12.
//  Copyright 2012 Robert Bowdidge. All rights reserved.
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

#import "LayoutGraphTest.h"

#import "EntireLayout.h"
#import "LayoutGraph.h"
#import "ScheduledTrain.h"


@implementation LayoutGraphTest
- (void) testSimple {
	[self makeThreeStationLayout];
	[self makeThreeStationTrain];
	LayoutGraph *graph = [[LayoutGraph alloc] initWithLayout: entireLayout_];
	
	STAssertTrue([graph edgeExistsFromStationName: @"A" toStationName: @"B"], @"");
	STAssertTrue([graph edgeExistsFromStationName: @"B" toStationName: @"C"], @"");
	STAssertTrue([graph edgeExistsFromStationName: @"C" toStationName: @"B"], @"");

	STAssertFalse([graph edgeExistsFromStationName: @"C" toStationName: @"A"], @"");
	STAssertFalse([graph edgeExistsFromStationName: @"A" toStationName: @"C"], @"");
}

- (NSArray*) makeTrainsWithRoutes: (NSArray*) array {
	NSMutableArray *trains = [NSMutableArray array];
	int i=0;
	for (NSString *route in array) {
		ScheduledTrain *myTrain = [self makeTrainWithName: [NSString stringWithFormat: @"train %d", i++]];
		[myTrain setStops: route];
		[trains addObject: myTrain];
	}
	return trains;
}

- (void) testTwoRoutes {
	[self makeThreeStationLayout];
	[self makePlaceWithName: @"D"];
	NSArray *trains = [self makeTrainsWithRoutes: [NSArray arrayWithObjects: @"A,B", @"D,C", nil]];
	LayoutGraph *graph = [[LayoutGraph alloc] initWithLayout: entireLayout_ ];
	
	STAssertTrue([graph edgeExistsFromStationName: @"A" toStationName: @"B"], @"");
	STAssertTrue([graph edgeExistsFromStationName: @"C" toStationName: @"D"], @"");
	STAssertFalse([graph edgeExistsFromStationName: @"A" toStationName: @"C"], @"");
	STAssertFalse([graph edgeExistsFromStationName: @"A" toStationName: @"D"], @"");
	
	NSArray *stationList = [graph stationsInReasonableOrder];
	STAssertEqualObjects(@"A", [((LayoutNode*)[stationList objectAtIndex: 0]).station name], @"");
	STAssertEqualObjects(@"B", [((LayoutNode*)[stationList objectAtIndex: 1]).station name], @"");
	// Second train.
	STAssertEqualObjects(@"D", [((LayoutNode*)[stationList objectAtIndex: 2]).station name], @"");
	STAssertEqualObjects(@"C", [((LayoutNode*)[stationList objectAtIndex: 3]).station name], @"");
}

- (void) testAddSkippedStation {
	[self makeThreeStationLayout];
	[self makePlaceWithName: @"D"];
	[self makePlaceWithName: @"E"];
	// Layout has C between B and E, and D as a branch from C.
	[self makeTrainsWithRoutes: [NSArray arrayWithObjects: @"A,B,E", @"A,B,C,E", @"A,B,C,D", nil]];
	LayoutGraph *graph = [[LayoutGraph alloc] initWithLayout: entireLayout_];

	STAssertTrue([graph edgeExistsFromStationName: @"A" toStationName: @"B"], @"");
	STAssertTrue([graph edgeExistsFromStationName: @"B" toStationName: @"C"], @"");
	STAssertFalse([graph edgeExistsFromStationName: @"B" toStationName: @"E"], @"");
	STAssertTrue([graph edgeExistsFromStationName: @"B" toStationName: @"C"], @"");
	STAssertTrue([graph edgeExistsFromStationName: @"C" toStationName: @"D"], @"");

	STAssertFalse([graph edgeExistsFromStationName: @"B" toStationName: @"D"], @"");
	STAssertFalse([graph edgeExistsFromStationName: @"A" toStationName: @"D"], @"");
}

- (void) testSkipMultipleStations {
	[self makeThreeStationLayout];
	[self makePlaceWithName: @"D"];
	[self makePlaceWithName: @"E"];
	// Layout has C between B and E, and D as a branch from C.
	[self makeTrainsWithRoutes: [NSArray arrayWithObjects: @"A,B,E", @"A,B,C,D,E", nil]];
	LayoutGraph *graph = [[LayoutGraph alloc] initWithLayout: entireLayout_];
	
	STAssertTrue([graph edgeExistsFromStationName: @"A" toStationName: @"B"], @"");
	STAssertTrue([graph edgeExistsFromStationName: @"B" toStationName: @"C"], @"");
	STAssertTrue([graph edgeExistsFromStationName: @"C" toStationName: @"D"], @"");
	STAssertTrue([graph edgeExistsFromStationName: @"D" toStationName: @"E"], @"");

	STAssertFalse([graph edgeExistsFromStationName: @"B" toStationName: @"E"], @"");
}

- (void) testBranch {
	[self makeThreeStationLayout];
	[self makePlaceWithName: @"D"];
	[self makePlaceWithName: @"E"];
	// Layout has C between B and E, and D as a branch from C.
	NSArray *trains = [self makeTrainsWithRoutes: [NSArray arrayWithObjects: @"A,B,C,E", @"A,B,C,D", @"D,C,E", nil]];
	LayoutGraph *graph = [[LayoutGraph alloc] initWithLayout: entireLayout_];
	
	STAssertTrue([graph edgeExistsFromStationName: @"A" toStationName: @"B"], @"");
	STAssertTrue([graph edgeExistsFromStationName: @"B" toStationName: @"C"], @"");
	STAssertTrue([graph edgeExistsFromStationName: @"C" toStationName: @"D"], @"");
	STAssertTrue([graph edgeExistsFromStationName: @"C" toStationName: @"E"], @"");

	STAssertTrue([graph edgeExistsFromStationName: @"D" toStationName: @"C"], @"");
	STAssertFalse([graph edgeExistsFromStationName: @"D" toStationName: @"E"], @"");
}

- (void) testWaterside{
	// Vasona Branch, with A as San Jose Yard and J as Santa Cruz.
	[self makeThreeStationLayout];
	[self makePlaceWithName: @"West"];
	[self makePlaceWithName: @"Waterside"];
	[self makePlaceWithName: @"East Waterside"];
	[self makePlaceWithName: @"West Waterside"];
	[self makePlaceWithName: @"East"];
	[self makePlaceWithName: @"Branch"];
	
	NSArray *trains = [self makeTrainsWithRoutes: [NSArray arrayWithObjects:
												   @"West,West Waterside,Waterside,East Waterside,East",
												   @"East,East Waterside, Waterside,West Waterside,West",
												   @"Waterside,Branch,Waterside", nil]];
	LayoutGraph *graph = [[LayoutGraph alloc] initWithLayout: entireLayout_];
	STAssertTrue([graph edgeExistsFromStationName: @"Waterside" toStationName: @"Branch"], @"");
	STAssertFalse([graph edgeExistsFromStationName: @"West" toStationName: @"Branch"], @"");
	STAssertFalse([graph edgeExistsFromStationName: @"East" toStationName: @"Branch"], @"");

	
	// TODO(bowdidge): All wrong below.
	NSArray *stationList = [graph stationsInReasonableOrder];
	STAssertEqualObjects(@"East", [((LayoutNode*)[stationList objectAtIndex: 0]).station name], @"");
	STAssertEqualObjects(@"East Waterside", [((LayoutNode*)[stationList objectAtIndex: 1]).station name], @"");
	STAssertEqualObjects(@"Waterside", [((LayoutNode*)[stationList objectAtIndex: 2]).station name], @"");
	STAssertEqualObjects(@"Branch", [((LayoutNode*)[stationList objectAtIndex: 3]).station name], @"");
	STAssertEqualObjects(@"West Waterside", [((LayoutNode*)[stationList objectAtIndex: 4]).station name], @"");
	STAssertEqualObjects(@"West", [((LayoutNode*)[stationList objectAtIndex: 5]).station name], @"");
}

- (void) testVasonaBranch {
	// Vasona Branch, with A as San Jose Yard and J as Santa Cruz.
	[self makeThreeStationLayout];
	[self makePlaceWithName: @"SJY"];
	[self makePlaceWithName: @"WSJ"];
	[self makePlaceWithName: @"AUZ"];
	[self makePlaceWithName: @"CAMP"];
	[self makePlaceWithName: @"VJ"];
	[self makePlaceWithName: @"LG"];
	[self makePlaceWithName: @"ALMA"];
	[self makePlaceWithName: @"WRI"];
	[self makePlaceWithName: @"GLEN"];
	[self makePlaceWithName: @"SCZ"];

	NSArray *trains = [self makeTrainsWithRoutes: [NSArray arrayWithObjects:
												   @"SJY,WSJ,AUZ,WSJ,SJY",
												   @"SJY,CAMP,VJ,LG,VJ,CAMP,SJY",
												   @"SJY,WSJ,AUZ,CAMP,LG,CAMP,AUZ,WSJ,SJY",
												   @"SCZ,GLEN,WRI,ALMA,LG,AUZ,SJY,AUZ,LG,ALMA,WRI,GLEN,SCZ",
												   @"SCZ,GLEN,WSJ,SJY,WSJ,GLEN,SCZ", nil]];
	LayoutGraph *graph = [[LayoutGraph alloc] initWithLayout: entireLayout_];
	
	STAssertTrue([graph edgeExistsFromStationName: @"SJY" toStationName: @"WSJ"], @"");
	STAssertTrue([graph edgeExistsFromStationName: @"WSJ" toStationName: @"AUZ"], @"");

	//Not Campbell to San Jose Yard.
	STAssertFalse([graph edgeExistsFromStationName: @"SJY" toStationName: @"CAMP"], @"");

	// Campbell to Vasona Junction to Los Gatos
	STAssertTrue([graph edgeExistsFromStationName: @"CAMP" toStationName: @"VJ"], @"");
	STAssertTrue([graph edgeExistsFromStationName: @"VJ" toStationName: @"LG"], @"");
	
	// But not Campbell to Los Gatos.
	STAssertFalse([graph edgeExistsFromStationName: @"CAMP" toStationName: @"LG"], @"");

	// Not Glenwood to West San Jose
	STAssertFalse([graph edgeExistsFromStationName: @"B" toStationName: @"I"], @"");

	// TODO(bowdidge): All wrong below.
	NSArray *stationList = [graph stationsInReasonableOrder];
	STAssertEqualObjects(@"SJY", [((LayoutNode*)[stationList objectAtIndex: 0]).station name], @"");
	STAssertEqualObjects(@"WSJ", [((LayoutNode*)[stationList objectAtIndex: 1]).station name], @"");
	STAssertEqualObjects(@"AUZ", [((LayoutNode*)[stationList objectAtIndex: 2]).station name], @"");
	STAssertEqualObjects(@"CAMP", [((LayoutNode*)[stationList objectAtIndex: 3]).station name], @"");
	STAssertEqualObjects(@"VJ", [((LayoutNode*)[stationList objectAtIndex: 4]).station name], @"");
	STAssertEqualObjects(@"LG", [((LayoutNode*)[stationList objectAtIndex: 5]).station name], @"");
	STAssertEqualObjects(@"ALMA", [((LayoutNode*)[stationList objectAtIndex: 6]).station name], @"");
	STAssertEqualObjects(@"WRI", [((LayoutNode*)[stationList objectAtIndex: 7]).station name], @"");
	STAssertEqualObjects(@"GLEN", [((LayoutNode*)[stationList objectAtIndex: 8]).station name], @"");
	STAssertEqualObjects(@"SCZ", [((LayoutNode*)[stationList objectAtIndex: 9]).station name], @"");
}
@end
