//
//  SwitchRouteDialogControllerTest.m
//  SwitchList
//
//  Created by Robert Bowdidge on 3/25/11.
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

#import "SwitchRouteDialogControllerTest.h"

#import <Cocoa/Cocoa.h>

#import "Place.h"
#import "ScheduledTrain.h"

@implementation SwitchRouteDialogControllerTest
- (void) setUp {
	[super setUp];
	
	[self makeThreeStationLayout];
	Place *offlinePlace = [self makePlaceWithName: @"Offline"];
	[offlinePlace setIsOffline: YES];
	
	[self makeThreeStationTrain];
	controller_ = [[SwitchRouteDialogController alloc] init];
	
	mockStationTableView_ = [[[NSTableView alloc] initWithFrame: NSMakeRect(0,0,0,0)] autorelease];
	NSTableColumn *nameColumn = [[[NSTableColumn alloc] init] autorelease];
	[nameColumn setIdentifier: @"name"];
	[mockStationTableView_ addTableColumn: nameColumn];
	
	mockStopsTableView_ = [[[NSTableView alloc] initWithFrame: NSMakeRect(0,0,0,0)] autorelease];
	NSTableColumn *stopsNameColumn = [[[NSTableColumn alloc] init] autorelease];
	[stopsNameColumn setIdentifier: @"name"];
	[mockStationTableView_ addTableColumn: stopsNameColumn];
	
	controller_->townTableView_ = mockStationTableView_;
	controller_->routeTableView_ = mockStopsTableView_;
}

- (void) testOnlyDisplaysOnlineStations {
	ScheduledTrain *train = [entireLayout_ trainWithName: @"MyTrain"];
	[controller_ setTrain:train layout:entireLayout_];
	// Update needs a sender which has a managedObjectContext.
	[controller_ update: entireLayout_];
	
	int numberOfNonOfflineStations=0;
	for (Place *station in [entireLayout_ allStations]) {
		if ([station isOffline] == NO) {
			numberOfNonOfflineStations++;
		}
	}
	
	STAssertTrue(numberOfNonOfflineStations == 
				 [controller_ numberOfRowsInTableView: mockStationTableView_], @"Wrong number of towns displayed");
}

// Checks that a particular row's values in each column are correct.
- (void) checkStationTableRow: (int) row townName: (NSString*) townName {
	
	NSTableColumn *townTableColumn = [mockStationTableView_ tableColumnWithIdentifier: @"name"];

	id generatedTownName = [[controller_ tableView: mockStationTableView_
							   objectValueForTableColumn: townTableColumn
													 row: row] string];

	STAssertEqualObjects(townName, generatedTownName, @"Wrong town name for row %d, was %@", row, generatedTownName);
}

// Checks that a particular row's values in each column are correct.
- (void) checkStopsTableRow: (int) row townName: (NSString*) townName {
	
	NSTableColumn *townTableColumn = [mockStationTableView_ tableColumnWithIdentifier: @"name"];
	
	NSString *generatedTownName = [[controller_ tableView: mockStopsTableView_
							   objectValueForTableColumn: townTableColumn
													 row: row] string];
	STAssertEqualObjects(townName, generatedTownName, @"Wrong town name for row %d, was %@", row, generatedTownName);
}

- (void) testStationNamesCorrect {
	ScheduledTrain *train = [entireLayout_ trainWithName: @"MyTrain"];
	[controller_ setTrain:train layout:entireLayout_];
	// Update needs a sender which has a managedObjectContext.
	[controller_ update: entireLayout_];
	
	
	[self checkStationTableRow: 0 townName: @"A"];
	[self checkStationTableRow: 1 townName: @"B"];
	[self checkStationTableRow: 2 townName: @"C"];
}

- (void) testTrainStopsCorrect {
	ScheduledTrain *train = [entireLayout_ trainWithName: @"MyTrain"];
	[controller_ setTrain:train layout:entireLayout_];
	// Update needs a sender which has a managedObjectContext.
	[controller_ update: entireLayout_];
	
	int rowsInStopsTable = [controller_ numberOfRowsInTableView: mockStopsTableView_];
	STAssertEqualsInt(3, rowsInStopsTable,
				 @"Wrong number of towns displayed, found %d.", rowsInStopsTable);
	[self checkStopsTableRow: 0 townName: @"A"];
	[self checkStopsTableRow: 1 townName: @"B"];
	[self checkStopsTableRow: 2 townName: @"C"];
}


@end