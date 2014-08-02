//
//  EntireLayoutTest.m
//  SwitchList
//
//  Created by bowdidge on 10/26/10.
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

#import "EntireLayoutTest.h"

#import "Cargo.h"
#import "CarType.h"
#import "DoorAssignmentRecorder.h"
#import "EntireLayout.h"
#import "FreightCar.h"
#import "InduYard.h"
#import "Industry.h"
#include "LayoutController.h"
#import "Place.h"
#import "ScheduledTrain.h"
#import "Yard.h"


// Tests functionality in EntireLayout class - mostly whether global queries work.

@implementation EntireLayoutTest

- (void) testSetName {
	[self makeSimpleLayout];
	
	id entireLayout = [[EntireLayout alloc] initWithMOC: context_];
	[entireLayout setLayoutName: @"Test"];
	XCTAssertEqualObjects([entireLayout layoutName], @"Test", @".  Name does not match.");
	// TODO(bowdidge): For now, just check not-nil as opposed to actually within seconds of now.
	XCTAssertNotNil([entireLayout currentDate], @".  Date not equal to today.");
}

// Checks that the workbench object exists in the layout object once we request it.
- (void) testWorkbench {
	// Make sure we allocate one and only one workbench.
	id entireLayout = [[EntireLayout alloc] initWithMOC: context_];
	// Populate industry stuff.
	Industry *workbenchIndustry = [entireLayout workbenchIndustry];
    XCTAssertNotNil(workbenchIndustry, @"workbenchIndustry assumed not to be nil.");
	XCTAssertNotNil([entireLayout workbench], @"Workbench not defined.");
	Place *workbench = [entireLayout workbench];
	XCTAssertFalse([workbench isStaging], @"Workbench should not be staging.");
	XCTAssertTrue([workbench isOffline], @"Workbench should be offline.");
	XCTAssertEqualInt(1, [[entireLayout allStations] count], @"Wrong number of Places");
	XCTAssertEqualObjects([workbench name], @"Workbench", @"Name not correct.");
}

- (void) testPreferences {
	// TODO(bowdidge): Test we can read it back.

}
	
- (void) testAllFreightCars {
	// Make sure the workbench industry is in the workbench place.
	id entireLayout = [[EntireLayout alloc] initWithMOC: context_];
	id workbenchIndustry = [entireLayout workbenchIndustry];
    [self makeFreightCarWithReportingMarks: @"SP 1"];

	FreightCar *car2 = [self makeFreightCarWithReportingMarks: @"SP 2"];
	[car2 setCurrentLocation: workbenchIndustry];
	
	XCTAssertEqualInt(2, [[entireLayout allFreightCars] count], @"Wrong number of total freight cars");
	XCTAssertEqualInt(1, [[entireLayout allAvailableFreightCars] count],  @"Wrong number of available freight cars");
	XCTAssertEqualInt(0, [[entireLayout allReservedFreightCars] count], @"Wrong number of reserved freight cars");
}

- (void) testFreightCarsOnWorkbench {
	id entireLayout = [[EntireLayout alloc] initWithMOC: context_];
	id workbenchIndustry = [entireLayout workbenchIndustry];
    [self makeFreightCarWithReportingMarks: @"SP 1"];

	 FreightCar *car2 = [self makeFreightCarWithReportingMarks: @"SP 2"];
	[car2 setCurrentLocation: workbenchIndustry];
	
	XCTAssertEqualInt(2, [[entireLayout allFreightCars] count], @"Wrong number of total freight cars");
	// Make sure we don't count the car on the workbench as available.
	XCTAssertEqualInt(1, [[entireLayout allAvailableFreightCars] count], @"Wrong number of available freight cars");
	// Make sure neither car has a cargo.
	XCTAssertEqualInt(0, [[entireLayout allReservedFreightCars] count], @"Wrong number of reserved freight cars");
}

- (void) testFreightCars {
	// Unit tests for freight cars.
	// TODO(bowdidge) Move to own section.
	[[EntireLayout alloc] initWithMOC: context_];
	FreightCar *car1 = [self makeFreightCarWithReportingMarks: @"SP 1"];
	FreightCar *car2 = [self makeFreightCarWithReportingMarks: @"DRG&W 99999"];
	FreightCar *car3 = [self makeFreightCarWithReportingMarks: @"UP  2222"];
	FreightCar *car4 = [self makeFreightCarWithReportingMarks: @"LA2X 9999"];
	
	XCTAssertEqualObjects(@"SP", [car1 initials], @"Car initials should be SP, were %@", [car1 initials]);
	XCTAssertEqualObjects(@"1", [car1 number], @"Car number should be 1, was %@", [car1 initials]);

	XCTAssertEqualObjects(@"DRG&W", [car2 initials], @"Car initials should be DRG&W, were %@", [car2 initials]);
	XCTAssertEqualObjects(@"99999", [car2 number], @"Car number should be 99999, was %@", [car2 initials]);

	XCTAssertEqualObjects(@"UP", [car3 initials], @"Car initials should be UP, were %@", [car3 initials]);
	XCTAssertEqualObjects(@"2222", [car3 number], @"Car number should be 22222, was %@", [car3 initials]);

	XCTAssertEqualObjects(@"LA2X", [car4 initials], @"Car initials should be LA2X, were %@", [car4 initials]);
	XCTAssertEqualObjects(@"9999", [car4 number], @"Car number should be 9999, was %@", [car4 initials]);
}

- (void) testFreightCarCargos {
	[self makeThreeStationLayout];
	FreightCar *fc1 = [self makeFreightCarWithReportingMarks: @"SP1"];
	FreightCar *fc2 = [self makeFreightCarWithReportingMarks: @"SP2"];

	Cargo *c1 = [self makeCargo: @"Foo"];
	[c1 setSource: [self industryAtStation: @"A"]];
	[c1 setDestination: [self industryAtStation: @"B"]];
	[fc1 setCargo: c1];
	[fc1 setIsLoaded: NO];

	// Cars that are empty and unassigned or empty and assigned should appear the same way.
	XCTAssertEqualObjects(@"empty", [fc1 cargoDescription], @"");
	XCTAssertEqualObjects(@"empty", [fc2 cargoDescription], @"");

	[fc1 setIsLoaded: YES];
	XCTAssertEqualObjects(@"Foo", [fc1 cargoDescription], @"");
}

- (void) testMoveOneStep {
	[self makeThreeStationLayout];
	FreightCar *fc1 = [self makeFreightCarWithReportingMarks: @"SP1"];
	
	Cargo *c1 = [self makeCargo: @"Foo"];
	[c1 setSource: [self industryAtStation: @"A"]];
	[c1 setDestination: [self industryAtStation: @"B"]];
	[fc1 setCargo: c1];
	[fc1 setCurrentLocation: [self industryAtStation: @"A"]];
	[fc1 setIsLoaded: YES];
	
	// Cars that are empty and unassigned or empty and assigned should appear the same way.
	XCTAssertEqualObjects([self industryAtStation: @"A"], [fc1 currentLocation], @"");
	
	[fc1 moveOneStep];
	XCTAssertEqualObjects([self industryAtStation: @"B"], [fc1 currentLocation], @"");
}

- (void) testCurrentDoor {
	[self makeThreeStationLayout];
	FreightCar *fc1 = [self makeFreightCarWithReportingMarks: @"SP1"];
	[[self industryAtStation: @"A"] setHasDoors: YES];
	[[self industryAtStation: @"A"] setNumberOfDoors: [NSNumber numberWithInt: 3]];
	[[self industryAtStation: @"B"] setHasDoors: YES];
	[[self industryAtStation: @"B"] setNumberOfDoors: [NSNumber numberWithInt: 2]];

	Cargo *c1 = [self makeCargo: @"Foo"];
	[c1 setSource: [self industryAtStation: @"A"]];
	[c1 setDestination: [self industryAtStation: @"B"]];
	[fc1 setCargo: c1];
	[fc1 setDoorToSpot: [NSNumber numberWithInt: 1]];
	[fc1 setCurrentLocation: [self industryAtStation: @"A"]];
	[fc1 setCurrentDoor: [NSNumber numberWithInt: 2]];
	[fc1 setIsLoaded: YES];

	// Cars that are empty and unassigned or empty and assigned should appear the same way.
	XCTAssertEqualObjects([self industryAtStation: @"A"], [fc1 currentLocation], @"");
    XCTAssertEqualInt(2, [[fc1 currentDoor] intValue], @"");
	
	[fc1 moveOneStep];
	XCTAssertEqualObjects([self industryAtStation: @"B"], [fc1 currentLocation], @"");
	XCTAssertEqualInt(1, [[fc1 currentDoor] intValue], @"");
}

// Make sure the reportingMarks, initials, and number fields work with strange values.
- (void) testFreightCarNumbers {
	FreightCar *fc1 = [self makeFreightCarWithReportingMarks: @"F&C 123"];
	XCTAssertEqualObjects(@"F&C 123", [fc1 reportingMarks], @"Reporting marks don't match.");
	XCTAssertEqualObjects(@"F&C", [fc1 initials], @"Initials don't match.");
	XCTAssertEqualObjects(@"123", [fc1 number], @"Number doesn't match.");
	
	FreightCar *fc2 = [self makeFreightCarWithReportingMarks: @" F&C 123"];
	XCTAssertEqualObjects(@" F&C 123", [fc2 reportingMarks], @"Reporting marks don't match.");
	XCTAssertEqualObjects(@"F&C", [fc2 initials], @"Initials don't match.");
	XCTAssertEqualObjects(@"123", [fc2 number], @"Number doesn't match.");
	
	FreightCar *fc3 = [self makeFreightCarWithReportingMarks: @"F 1"];
	XCTAssertEqualObjects(@"F 1", [fc3 reportingMarks], @"Reporting marks don't match.");
	XCTAssertEqualObjects(@"F", [fc3 initials], @"Initials don't match.");
	XCTAssertEqualObjects(@"1", [fc3 number], @"Number doesn't match.");
	
	FreightCar *fc4 = [self makeFreightCarWithReportingMarks: @"F A 1"];
	XCTAssertEqualObjects(@"F A 1", [fc4 reportingMarks], @"Reporting marks don't match.");
	XCTAssertEqualObjects(@"F", [fc4 initials], @"Initials don't match.");
	XCTAssertEqualObjects(@"A 1", [fc4 number], @"Number doesn't match.");
	
	FreightCar *fc5 = [self makeFreightCarWithReportingMarks: @""];
	XCTAssertEqualObjects(@"", [fc5 reportingMarks], @"Reporting marks don't match.");
	XCTAssertEqualObjects(@"", [fc5 initials], @"Initials don't match.");
	XCTAssertEqualObjects(@"", [fc5 number], @"Number doesn't match.");
	
	FreightCar *fc6 = [self makeFreightCarWithReportingMarks: @"FOO"];
	XCTAssertEqualObjects(@"FOO", [fc6 reportingMarks], @"Reporting marks don't match.");
	XCTAssertEqualObjects(@"FOO", [fc6 initials], @"Initials don't match.");
	XCTAssertEqualObjects(@"", [fc6 number], @"Number doesn't match.");
	
	FreightCar *fc7 = [self makeFreightCarWithReportingMarks: @"F&C123"];
	XCTAssertEqualObjects(@"F&C123", [fc7 reportingMarks], @"Reporting marks don't match.");
	XCTAssertEqualObjects(@"F&C123", [fc7 initials], @"Initials don't match.");
	XCTAssertEqualObjects(@"", [fc7 number], @"Number doesn't match.");
}

- (void) testAllFreightCarsAtDestination {
	[self makeThreeStationLayout];
	FreightCar *fc1 = [self makeFreightCarWithReportingMarks: @"SP1"];
	FreightCar *fc2 = [self makeFreightCarWithReportingMarks: @"SP2"];
	
	Cargo *c1 = [self makeCargo: @"Foo"];
	[c1 setSource: [self industryAtStation: @"A"]];
	[c1 setDestination: [self industryAtStation: @"B"]];
	
	// fc1 has no cargo.
	[fc1 setCurrentLocation: [self industryAtStation:@"A"]];
	XCTAssertFalse([[entireLayout_ allFreightCarsAtDestination] containsObject: fc1], @"Car without cargo shouldn't be at destination.");
	

	// fc2 has a cargo, but the car isn't at source or dest.
	[fc2 setCurrentLocation: [self industryAtStation: @"C"]];
	[fc2 setCargo: c1];
	XCTAssertFalse([[entireLayout_ allFreightCarsAtDestination] containsObject: fc2], @"Car not at src or dest not at destination.");
	
	// fc2 has a cargo, is unloaded, and is at source.
	[fc2 setCurrentLocation: [self industryAtStation: @"A"]];
	[fc2 setIsLoaded: NO];
	XCTAssertTrue([[entireLayout_ allFreightCarsAtDestination] containsObject: fc2], @"Car not at src or dest not at destination.");

	// If fc2 is loaded, it's not at the next destination.
	[fc2 setIsLoaded: YES];
	XCTAssertFalse([[entireLayout_ allFreightCarsAtDestination] containsObject: fc2], @"Car not at src or dest not at destination.");

	// If fc2 is loaded, it's not at the next destination.
	[fc2 setIsLoaded: YES];
	[fc2 setCurrentLocation: [self industryAtStation: @"C"]];
	XCTAssertFalse([[entireLayout_ allFreightCarsAtDestination] containsObject: fc2], @"Car not at src or dest not at destination.");
}

- (void) testAllFreightCarsAtDestinationInStaging {
	// TODO(bowdidge): Fill in.
}

- (void) testAllFreightCarsInTrains {
	// Make sure the workbench industry is in the workbench place.
	id entireLayout = [[EntireLayout alloc] initWithMOC: context_];
	ScheduledTrain *myTrain = [self makeTrainWithName: @"MyTrain"];
	FreightCar *fc1 = [self makeFreightCarWithReportingMarks: @"SP 1"];
	FreightCar *fc2 = [self makeFreightCarWithReportingMarks: @"SP 2"];
	[myTrain addFreightCarsObject: fc1];
	
	XCTAssertEqualInt(2, [[entireLayout allFreightCars] count], @"Wrong total number of cars");
	XCTAssertEqualInt(1, [[entireLayout allFreightCarsNotInTrain] count], @"Wrong number of cars not in train");
	XCTAssertTrue([[myTrain freightCars] containsObject: fc1], @"freight car 1 should be in train.");
	XCTAssertFalse([[myTrain freightCars] containsObject: fc2], @"freight car 2 should not be in train.");
}


- (void) testAllStations {
	// Make sure the workbench industry is in the workbench place.
	id entireLayout = [[EntireLayout alloc] initWithMOC: context_];
    Place *placeA = [self makePlaceWithName: @"A"];
	Place *placeB = [self makePlaceWithName: @"B"];
	Place *placeC = [self makePlaceWithName: @"C"];
	[placeB setIsStaging: YES];

    XCTAssertNotNil(placeA);
	XCTAssertNotNil(placeB);
    XCTAssertNotNil(placeC);
    
    // Workbench counts as a station.
	XCTAssertEqualInt(4, [[entireLayout allStations] count], @"Wrong number of stations");
	XCTAssertEqualInt(1, [[entireLayout allStationsInStaging] count], @"Wrong number of stations in staging");
	XCTAssertEqualInt(1, [[entireLayout allStationNamesInStaging] count], @"Wrong number of station names in staging.");
	XCTAssertTrue([[entireLayout allStationNamesInStaging] containsObject: @"B"], @"Place A not in all station names in staging.");
}

- (void) testAllOnlineStations {
	// Make sure the workbench industry is in the workbench place.
	id entireLayout = [[EntireLayout alloc] initWithMOC: context_];
    Place *placeA = [self makePlaceWithName: @"A"];
	Place *placeB = [self makePlaceWithName: @"B"];
	[placeB setIsOffline: YES];
	Place *placeC = [self makePlaceWithName: @"C"];
	[placeC setIsStaging: YES];
	Place *placeAa = [self makePlaceWithName: @"Aa+"];
	[placeAa setIsStaging: YES];
	
	// Workbench counts as a station.
	NSArray *allOnlineStations = [entireLayout allOnlineStationsSortedOrder];
	XCTAssertEqualInt(5, [[entireLayout allStations] count], @"Wrong number of stations");
	XCTAssertEqualInt(3, [allOnlineStations count], @"Wrong number of stations online");
	XCTAssertEqual(placeA, [allOnlineStations objectAtIndex: 0], @"Expected station A to be first in %@.", allOnlineStations);
	XCTAssertEqual(placeAa, [allOnlineStations objectAtIndex: 1], @"Expected station Aa to be second in %@.", allOnlineStations);
	XCTAssertEqual(placeC, [allOnlineStations objectAtIndex: 2], @"Expected station C to be third in %@.", allOnlineStations);
}

// Make sure we correctly handle valid and invalid names.
- (void) testStationWithName {
	id entireLayout = [[EntireLayout alloc] initWithMOC: context_];
    Place *placeA = [self makePlaceWithName: @"A"];
	
	XCTAssertEqualObjects([entireLayout stationWithName: @"A"], placeA, @"Check existence of A");
	XCTAssertNil([entireLayout stationWithName: @"Bogus"], @"Check bogus name rejected");
	XCTAssertNil([entireLayout stationWithName: nil], @"Check NULL rejected.");	
}

- (void) disableTestStationValidation {
	Place *placeA = [self makePlaceWithName: @"A"];
	Place *placeB = [self makePlaceWithName: @""];
    
    XCTAssertNotNil(placeA);
    XCTAssertNotNil(placeB);
    
	NSString *proposedNameA = @"A";
	NSString *proposedNameB = @"B";
	NSError *error = nil;
	XCTAssertTrue([placeB validateName: &proposedNameB error:&error], @"B should be legal name for place.");
	XCTAssertNil(error, @"Error not nil.");
 	XCTAssertFalse([placeB validateName: &proposedNameA error:&error], @"A should not be legal name for place.");
	XCTAssertNotNil(error, @"Error should be non-nil");
}								 

- (void) testAllIndustries {
	// TODO(bowdidge): Test that yards are included.
	// Make sure the workbench industry is in the workbench place.
	id entireLayout = [[EntireLayout alloc] initWithMOC: context_];
	Place *placeA = [self makePlaceWithName: @"A"];
	XCTAssertNotNil(placeA);
	XCTAssertEqualInt(1, [[entireLayout allIndustries] count], @"Wrong number of industries");
}

- (void) testAllCargo {
	EntireLayout *entireLayout = [[EntireLayout alloc] initWithMOC: context_];
	[self makeThreeStationLayout];
	
	Cargo *c1 = [self makeCargo: @"b to c"];
	[c1 setSource: [self industryAtStation: @"B"]];
	[c1 setDestination: [self industryAtStation: @"C"]];
	
	XCTAssertEqualInt(1, [[entireLayout allValidCargos] count], @"Wrong number of cargos");
	XCTAssertTrue([[entireLayout allValidCargos] containsObject: c1], @"cargo isn't in list.");
}

- (void) testAllFixedRateCargo {
	EntireLayout *entireLayout = [[EntireLayout alloc] initWithMOC: context_];
	[self makeThreeStationLayout];
	
	Cargo *c1 = [self makeCargo: @"b to c"];
	[c1 setSource: [self industryAtStation: @"B"]];
	[c1 setDestination: [self industryAtStation: @"C"]];

	Cargo *c2 = [self makeCargo: @"a to b"];
	[c2 setPriority: [NSNumber numberWithBool: YES]];
	[c2 setSource: [self industryAtStation: @"A"]];
	[c2 setDestination: [self industryAtStation: @"B"]];
	
	XCTAssertEqualInt(1, [[entireLayout allFixedRateCargos] count], @"Wrong number of cargos");
	XCTAssertTrue([[entireLayout allFixedRateCargos] containsObject: c2], @"cargo isn't in list.");
}	 

- (void) testAllNonFixedRateCargo {
	EntireLayout *entireLayout = [[EntireLayout alloc] initWithMOC: context_];
	[self makeThreeStationLayout];
	
	Cargo *c1 = [self makeCargo: @"b to c"];
	[c1 setSource: [self industryAtStation: @"B"]];
	[c1 setDestination: [self industryAtStation: @"C"]];
	
	Cargo *c2 = [self makeCargo: @"a to b"];
	[c2 setPriority: [NSNumber numberWithBool: YES]];
	[c2 setSource: [self industryAtStation: @"A"]];
	[c2 setDestination: [self industryAtStation: @"B"]];
	
	XCTAssertEqualInt(1, [[entireLayout allNonFixedRateCargos] count], @"Wrong number of cargos");
	XCTAssertTrue([[entireLayout allNonFixedRateCargos] containsObject: c1], @"cargo isn't in list.");
}

// TODO(bowdidge): Move to ScheduledTrainTests?
- (void) testAllCarsInTrainSortedInVisitOrder {
	[self makeThreeStationLayout];
	[self makeThreeStationTrain];
	
	ScheduledTrain *myTrain1 = [[entireLayout_ allTrains] lastObject];
	NSArray *allCars = [myTrain1 allFreightCarsInVisitOrder];
	XCTAssertEqualInt(2, [allCars count], @"Not enough cars in train.");
	// First A->B car
	XCTAssertEqualObjects([[[allCars objectAtIndex: 0] cargo] cargoDescription], @"A to B", @"Cars out of order");
    // Then B->C Car									
	XCTAssertEqualObjects([[[allCars objectAtIndex: 1] cargo] cargoDescription], @"B to C", @"Cars out of order.");
}

- (void) testStationsWithWork {
	[self makeThreeStationLayout];
	[self makeThreeStationTrain];
	FreightCar *fc1 = [self freightCarWithReportingMarks: FREIGHT_CAR_1_NAME];
	FreightCar *fc2 = [self freightCarWithReportingMarks: FREIGHT_CAR_2_NAME];
	[fc1 setCurrentLocation: [self industryAtStation: @"B"]];
	[fc1 setIsLoaded: YES];
	[fc2 setCurrentLocation: [self industryAtStation: @"A"]];
	[fc2 setIsLoaded: YES];

	ScheduledTrain *myTrain1 = [[entireLayout_ allTrains] lastObject];
	NSArray *allStations = [myTrain1 stationsWithWork];
	
	// Should see fc1 going B to C, and fc2 going A to B.

	XCTAssertEqualInt(3, [allStations count], @"Not enough stops.");
	
	NSDictionary *stationAData = [allStations objectAtIndex: 0];
	NSDictionary *stationBData = [allStations objectAtIndex: 1];
	NSDictionary *stationCData = [allStations objectAtIndex: 2];
	
	XCTAssertEqualObjects(@"A", [stationAData objectForKey: @"name"], @"Station A missing");
 	XCTAssertEqualObjects(@"B", [stationBData objectForKey: @"name"], @"Station B missing");
	XCTAssertEqualObjects(@"C", [stationCData objectForKey: @"name"], @"Station C missing");
	
	XCTAssertEqualInt(1, [[stationAData objectForKey: @"industries"] count], @"");
	NSDictionary *industryAData = [[stationAData objectForKey: @"industries"] objectForKey: @"A-industry"];

	XCTAssertEqualInt(1, [[stationBData objectForKey: @"industries"] count], @"");
	NSDictionary *industryBData = [[stationBData objectForKey: @"industries"] objectForKey: @"B-industry"];

	XCTAssertEqualInt(1, [[stationCData objectForKey: @"industries"] count], @"");
	NSDictionary *industryCData = [[stationCData objectForKey: @"industries"] objectForKey: @"C-industry"];
	
	XCTAssertEqualInt(0, [[industryAData objectForKey: @"carsToDropOff"] count],
				@"No cars expected to drop off at station A, found %ld", (unsigned long) [[stationAData objectForKey: @"carsToDropOff"] count]);
	XCTAssertEqualInt(1, [[industryAData objectForKey: @"carsToPickUp"] count],
				 @"Expected one car to pick up at station A, found %ld.", (unsigned long) [[stationAData objectForKey: @"carsToPickUp"] count]);

	XCTAssertEqualInt(1, [[industryBData objectForKey: @"carsToDropOff"] count], @"Expected one car to drop off at station B.");
	XCTAssertEqualInt(1, [[industryBData objectForKey: @"carsToPickUp"] count], @"Expected one car to pick up at station B.");

	XCTAssertEqualInt(1, [[industryCData objectForKey: @"carsToDropOff"] count], @"Expected one car to drop off at station C.");
	XCTAssertEqualInt(0, [[industryCData objectForKey: @"carsToPickUp"] count], @"Expected no cars to pick up at station C.");
}

- (void) testStationsWithWorkMultipleCars {
	[self makeThreeStationLayout];
	[self makeThreeStationTrain];
	FreightCar *fc1 = [self freightCarWithReportingMarks: FREIGHT_CAR_1_NAME];
	FreightCar *fc2 = [self freightCarWithReportingMarks: FREIGHT_CAR_2_NAME];
	[fc1 setCurrentLocation: [self industryAtStation: @"A"]];
	[fc1 setIsLoaded: NO];
	[fc2 setCurrentLocation: [self industryAtStation: @"A"]];
	[fc2 setIsLoaded: YES];
	
	ScheduledTrain *myTrain1 = [[entireLayout_ allTrains] lastObject];
	NSArray *allStations = [myTrain1 stationsWithWork];
	
	// Should see fc1 going B to C, and fc2 going A to B.

	XCTAssertEqualInt(2, [allStations count], @"Wrong number of stops, expected 2, found %ld", (unsigned long) [allStations count]);
	
	NSDictionary *stationAData = [allStations objectAtIndex: 0];
	NSDictionary *stationBData = [allStations objectAtIndex: 1];

	XCTAssertEqualObjects(@"A", [stationAData objectForKey: @"name"], @"Station A missing");
 	XCTAssertEqualObjects(@"B", [stationBData objectForKey: @"name"], @"Station B missing");
	
	XCTAssertEqualInt(1, [[stationAData objectForKey: @"industries"] count], @"");
	NSDictionary *industryAData = [[stationAData objectForKey: @"industries"] objectForKey: @"A-industry"];
	
	XCTAssertEqualInt(1, [[stationBData objectForKey: @"industries"] count], @"");
	NSDictionary *industryBData = [[stationBData objectForKey: @"industries"] objectForKey: @"B-industry"];
	
	XCTAssertEqualInt(0, [[industryAData objectForKey: @"carsToDropOff"] count],
				 @"No cars expected to drop off at station A, found %d", (int) [[stationAData objectForKey: @"carsToDropOff"] count]);
	XCTAssertEqualInt(2, [[industryAData objectForKey: @"carsToPickUp"] count],
				 @"Expected one car to pick up at station A, found %d.", (int) [[stationAData objectForKey: @"carsToPickUp"] count]);

	XCTAssertEqualInt(2, [[industryBData objectForKey: @"carsToDropOff"] count], @"Expected one car to drop off at station B.");
	XCTAssertEqualInt(0, [[industryBData objectForKey: @"carsToPickUp"] count], @"Expected one car to pick up at station B.");
}

- (void) testLayoutController {
	[self makeThreeStationLayout];
	[self makeThreeStationTrain];
	FreightCar *fc1 = [self freightCarWithReportingMarks: FREIGHT_CAR_1_NAME];
	FreightCar *fc2 = [self freightCarWithReportingMarks: FREIGHT_CAR_2_NAME];
	[fc1 setCurrentLocation: [self industryAtStation: @"A"]];
	[fc1 setIsLoaded: NO];
    [fc1 setHomeDivision: @"C"];
	[fc2 setCurrentLocation: [self industryAtStation: @"A"]];
	[fc2 setIsLoaded: YES];
    [fc2 setHomeDivision: @"B"];
    [fc2 setDaysUntilUnloaded: [NSNumber numberWithInt: 2]];
	
	ScheduledTrain *myTrain1 = [[entireLayout_ allTrains] lastObject];
	NSArray *allStations = [myTrain1 stationsWithWork];
	
    LayoutController *controller = [[LayoutController alloc] initWithEntireLayout: [self entireLayout]];
   
    // Cars start at A.
    XCTAssertEqualObjects([self industryAtStation: @"A"], [fc1 currentLocation]);
    XCTAssertFalse([fc1 isLoaded]);
    XCTAssertEqualObjects([self industryAtStation: @"A"], [fc2 currentLocation]);
    XCTAssertTrue([fc2 isLoaded]);
    
    [self advanceEntireLayout:controller];

    // After first move, car fc1 is moved to B for loading.  Car fc2 is moved to B for unloading.
    XCTAssertEqualObjects([self industryAtStation: @"B"], [fc1 currentLocation], @"Expected fc1 at B, found %@", [[fc1 currentLocation] name]);
    XCTAssertTrue([fc1 isLoaded]);
    XCTAssertEqualObjects([self industryAtStation: @"B"], [fc2 currentLocation], @"Expected fc2 at B, found %@", [[fc2 currentLocation] name]);
    // Still loaded on first day after arrival.
    XCTAssertTrue([fc2 isLoaded]);
    XCTAssertEqualInt(1, [[fc2 daysUntilUnloaded] intValue]);

    [self advanceEntireLayout:controller];

    // Car fc1 is now at C, and unloaded.  Car fc2 has been unloaded, and ready to be moved.
    XCTAssertEqualObjects([self industryAtStation: @"C"], [fc1 currentLocation]);
    XCTAssertFalse([fc1 isLoaded]);
    XCTAssertEqualObjects([self industryAtStation: @"B"], [fc2 currentLocation]);
    // Unloaded on next day.
    XCTAssertFalse([fc2 isLoaded]);

    [self advanceEntireLayout:controller];

    // fc1 now goes straight to the yard after a day of unloading, and fc2 goes to the yard after two days
    // of unloading.
    XCTAssertEqualObjects([self yardAtStation: @"C"], [fc1 currentLocation]);
    XCTAssertFalse([fc1 isLoaded]);
    XCTAssertEqualObjects([self yardAtStation: @"B"], [fc2 currentLocation]);
    XCTAssertFalse([fc2 isLoaded]);
    XCTAssertEqualInt(0, [[fc2 daysUntilUnloaded] intValue]);
    
    [self advanceEntireLayout:controller];
    
    // Both cars still unloaded.
    XCTAssertEqualObjects([self yardAtStation: @"C"], [fc1 currentLocation]);
    XCTAssertFalse([fc1 isLoaded]);
    XCTAssertEqualObjects([self yardAtStation: @"B"], [fc2 currentLocation]);
    XCTAssertFalse([fc2 isLoaded]);
    XCTAssertEqualInt(0, [[fc2 daysUntilUnloaded] intValue]);
}


- (void) testStationStops {
	[self makeThreeStationLayout];
	[self makeThreeStationTrain];
	
	ScheduledTrain *myTrain1 = [[entireLayout_ allTrains] lastObject];
	NSArray *stops = [myTrain1 stationsInOrder];
	
	XCTAssertEqualInt(3, [stops count], @"Incorrect number of stops for train");
	XCTAssertEqualObjects([entireLayout_ stationWithName: @"A"],
						 [stops objectAtIndex: 0], @"A not first station.");
	XCTAssertEqualObjects([entireLayout_ stationWithName: @"B"],
						 [stops objectAtIndex: 1], @"B not second station.");
	XCTAssertEqualObjects([entireLayout_ stationWithName: @"C"],
						 [stops objectAtIndex: 2], @"C not third station.");
}

// TODO(bowdidge): Move to ScheduledTrainTest.
- (void) testAcceptsCar {
	ScheduledTrain *myTrain = [self makeTrainWithName: @"MyTrain"];
	FreightCar *fc1 = [self makeFreightCarWithReportingMarks: FREIGHT_CAR_1_NAME];
	[fc1 setCarTypeRel: [entireLayout_ carTypeForName: @"XM"]];
	FreightCar *fc2 = [self makeFreightCarWithReportingMarks: FREIGHT_CAR_2_NAME];
	[fc2 setCarTypeRel: [entireLayout_ carTypeForName: @"XA"]];

	[myTrain setStops: @"A,B,C"];
	[self setTrain: myTrain acceptsCarTypes: @"XM"];
	
	XCTAssertTrue([myTrain acceptsCar: fc1], @"Should be accepted");
	XCTAssertFalse([myTrain acceptsCar: fc2], @"Should not be accepted");
}

- (void) testAllFreightCarsInYard {
	[self makeThreeStationLayout];
	[self makeYardAtStation: @"A"];
	FreightCar *fc = [self makeFreightCarWithReportingMarks: @"A 1"];
	[fc setCurrentLocation: [self yardAtStation: @"A"]];
	NSArray *carsInYard = [entireLayout_ allFreightCarsInYard];
	XCTAssertEqualInt(1, [carsInYard count], @"Incorrect number of cars in yard, found %ld", (unsigned long) [carsInYard count]);
}

- (void) testImport {
	NSString *input = @"SP 1\nSP 2  \n    SP 3\n";
	NSMutableString *errors = nil;
	[entireLayout_ importFreightCarsUsingString: input errors: &errors];
	XCTAssertEqualInt(3, [[entireLayout_ allFreightCars] count], @"Expected 3 freight cars, got %ld", (unsigned long)[[entireLayout_ allFreightCars] count]);
	XCTAssertEqualInt(0, [errors length], @"No errors expected");
}

- (void) testImportBlankLines {
	NSString *input = @"SP 1\n\n\n\nSP 2  \n    SP 3\n";
	NSMutableString *errors = nil;
	[entireLayout_ importFreightCarsUsingString: input errors: &errors];
	XCTAssertEqualInt(0, [errors length], @"No errors expected");
	XCTAssertEqualInt(3, [[entireLayout_ allFreightCars] count], @"Expected 3 freight cars, got %ld (%@)", (unsigned long) [[entireLayout_ allFreightCars] count],[entireLayout_ allFreightCars]);
	XCTAssertNotNil([self freightCarWithReportingMarks: @"SP 1"], @"Freight car names corrupted.");
}

// TODO(bowdidge): How far do I want to go with invalid characters?
// TODO(bowdidge): \r treated as non-space.
// TODO(bowdidge): What happens if the car name already exists?
- (void) disableTestImportControlCharacters {
	NSString *input = @"SP 1\007\b\\nSP 2  \n    SP 3\n";
	NSMutableString *errors = nil;
	[entireLayout_ importFreightCarsUsingString: input errors: &errors];
	XCTAssertEqualInt(0, [errors length], @"No errors expected");
	XCTAssertEqualInt(3, [[entireLayout_ allFreightCars] count], @"Expected 3 freight cars, got %ld", (unsigned long) [[entireLayout_ allFreightCars] count]);
}

- (void) checkExistenceOfCar: (NSString*) reportingMarks type: (NSString*) carType length: (NSNumber*) expectedLength {
	FreightCar *fc = [self freightCarWithReportingMarks: reportingMarks];
	XCTAssertNotNil(fc, @"Freight car %@ not found", reportingMarks);	
	NSString *actualCarTypeName = [[fc carTypeRel] carTypeName];
	XCTAssertEqualObjects(carType, actualCarTypeName,
				   @"Expected freight car %@ to have type %@, but had type %@",
				   reportingMarks, carType, actualCarTypeName);
    if (expectedLength != nil) {
        XCTAssertEqualObjects(expectedLength, [fc length], @"Expected freight car %@ to have length %@, but had     length %@",
                    reportingMarks, expectedLength, [fc length]);
    }
    
}

- (void)testImportCarTypes {
	NSString *input = @"SP 1, XM,\nSP 2, T\nSP    3\nSP 4\tXM\n  SP  5\t MYCARTYPE\t\n";
	NSMutableString *errors = nil;
	[entireLayout_ importFreightCarsUsingString: input errors: &errors];
	XCTAssertEqualInt(0, [errors length], @"No errors expected");
	
	XCTAssertEqualInt(5, [[entireLayout_ allFreightCars] count], @"Expected 4 freight cars, got %ld", (unsigned long) [[entireLayout_ allFreightCars] count]);
	
	[self checkExistenceOfCar: @"SP 1" type: @"XM" length: nil];
	[self checkExistenceOfCar: @"SP 2" type: @"T" length: nil];
	[self checkExistenceOfCar: @"SP 3" type: nil length: nil];
	[self checkExistenceOfCar: @"SP 4" type: @"XM" length: nil];
	[self checkExistenceOfCar: @"SP 5" type: @"MYCARTYPE" length: nil];
	NSString *actualCarTypeDescription = [[[self freightCarWithReportingMarks: @"SP 5"] carTypeRel] carTypeDescription];
	XCTAssertEqualObjects(@"", actualCarTypeDescription,
						 @"Car type description for new car type assumed to be empty but was %@", actualCarTypeDescription);
}

- (void)testImportLengths {
	NSString *input = @"SP 1, XM, 50\nSP 2, T, 56\nSP    3\nSP 4\tXM\t 40\n  SP  5\t MYCARTYPE\t36\n";
	NSMutableString *errors = nil;
	[entireLayout_ importFreightCarsUsingString: input errors: &errors];
	XCTAssertEqualInt(0, [errors length], @"No errors expected");
	
	XCTAssertEqualInt(5, [[entireLayout_ allFreightCars] count], @"Expected 4 freight cars, got %ld", (unsigned long) [[entireLayout_ allFreightCars] count]);
	
	[self checkExistenceOfCar: @"SP 1" type: @"XM" length: [NSNumber numberWithInt: 50]];
	[self checkExistenceOfCar: @"SP 2" type: @"T" length: [NSNumber numberWithInt: 56]];
	[self checkExistenceOfCar: @"SP 3" type: nil length: nil];
	[self checkExistenceOfCar: @"SP 4" type: @"XM" length: [NSNumber numberWithInt: 40]];
	[self checkExistenceOfCar: @"SP 5" type: @"MYCARTYPE" length: [NSNumber numberWithInt: 36]];
	NSString *actualCarTypeDescription = [[[self freightCarWithReportingMarks: @"SP 5"] carTypeRel] carTypeDescription];
	XCTAssertEqualObjects(@"", actualCarTypeDescription,
                          @"Car type description for new car type assumed to be empty but was %@", actualCarTypeDescription);
}

- (void) testCargoLoadsPerDay {
	[self makeThreeStationLayout];
	Cargo *c1 = [self makeCargo: @"b to c"];
	[c1 setSource: [self industryAtStation: @"B"]];
	[c1 setDestination: [self industryAtStation: @"C"]];
	[c1 setCarsPerWeek: [NSNumber numberWithInt: 7]];
	
	XCTAssertEqualInt(1, [entireLayout_ loadsPerDay], @"Expected 1 load/day, got %d", [entireLayout_ loadsPerDay]);
}

- (void) testNextDoorShowsOnlyAtIndustry {
	[self makeThreeStationLayout];
    [self makeTwoTrains];
	[self makeYardAtStation: @"A"];
    [self makeYardAtStation: @"B"];
    [[self industryAtStation: @"C"] setHasDoors: YES];
    [[self industryAtStation: @"C"] setNumberOfDoors: [NSNumber numberWithInt: 5]];
    
    Cargo *c1 = [self makeCargo: @"a to c"];
	[c1 setSource: [self yardAtStation: @"A"]];
	[c1 setDestination: [self industryAtStation: @"C"]];

	FreightCar *fc = [self makeFreightCarWithReportingMarks: @"A 1"];
    [fc setCargo: c1];
	[fc setIsLoaded: YES];
    [fc setCurrentLocation: [self yardAtStation: @"A"]];
    [fc setCurrentTrain: [[self entireLayout] trainWithName: @"Train 1"]];
    [fc setDoorToSpot: [NSNumber numberWithInt: 4]];
    [fc setIntermediateDestination: [self yardAtStation: @"B"]];

	XCTAssertEqualInt(0, [fc nextDoor], @"Expected no nextDoor, got %ld", (unsigned long) [fc nextDoor]);

    [fc setCurrentLocation: [self yardAtStation: @"B"]];
    [fc setIntermediateDestination: nil];
    [fc setCurrentTrain: [[self entireLayout] trainWithName: @"Train 2"]];

	XCTAssertTrue(0 < [fc nextDoor], @"Expected valid nextDoor");
}


- (void) testCargoLoadsPerDayFractions {
	[self makeThreeStationLayout];
	Cargo *c1 = [self makeCargo: @"b to c"];
	[c1 setSource: [self industryAtStation: @"B"]];
	[c1 setDestination: [self industryAtStation: @"C"]];
	[c1 setCarsPerMonth: [NSNumber numberWithInt: 41]];
	
	Cargo *c2 = [self makeCargo: @"a to b"];
	[c2 setSource: [self industryAtStation: @"A"]];
	[c2 setDestination: [self industryAtStation: @"B"]];
	[c2 setCarsPerMonth: [NSNumber numberWithInt: 49]];
	
	XCTAssertEqualInt(3, [entireLayout_ loadsPerDay], @"Expected 3 loads/day, got %d", [entireLayout_ loadsPerDay]);
}

- (void) testSqlSanity {
	[self makeThreeStationLayout];
	Industry *i = [entireLayout_ industryWithName: @"'" withStationName: @"A"];
	// Make sure it didn't crash, and didn't return anything.
	XCTAssertNil(i, @"industryWithName not correctly finding quote");
	
	Industry *myIndustry = [self makeIndustryWithName: @"robert's"];
	[myIndustry setLocation: [entireLayout_ stationWithName: @"A"]];
	Industry *j = [entireLayout_ industryWithName: @"robert's-industry" withStationName: @"A"];
	XCTAssertEqual(j, myIndustry, @"Wrong industry returned.");
	
	// Same test for freight cars at industry - just test it doesn't throw.
	NSSet *cars = [myIndustry freightCars];
	XCTAssertNotNil(cars, @"freightCars failed.");
}

// Tests that a preferences dictionary saved with an NSArchiver can still be read by the current
// code.
- (void) testOldPreferencesDictionary {
	NSDictionary *testDict = [NSDictionary dictionaryWithObject: @"Hello" forKey: @"World"];
	[entireLayout_ setPreferencesDictionary: [NSArchiver archivedDataWithRootObject: testDict]];
	NSDictionary *outDict = [entireLayout_ getPreferencesDictionary];
	XCTAssertNotNil([outDict objectForKey: @"World"], @"Expected dictionary to have a value for key 'World'");
}

// Tests that a preferences dictionary saved with an NSKeyedArchiver can be read.
- (void) testNewPreferencesDictionary {
	NSDictionary *testDict = [NSDictionary dictionaryWithObject: @"Hello" forKey: @"World"];
	[entireLayout_ setPreferencesDictionary: [NSKeyedArchiver archivedDataWithRootObject: testDict]];
	NSDictionary *outDict = [entireLayout_ getPreferencesDictionary];
	XCTAssertNotNil([outDict objectForKey: @"World"], @"Expected dictionary to have a value for key 'World'");
}

// Tests that if the data for an archived preferences dictionary is bogus, getPreferencesDictionary
// still returns a sane value.
- (void) testBogusPreferencesDictionary {
	[entireLayout_ setPreferencesDictionary: [NSData dataWithBytes: "123456" length: 6]];
	NSDictionary *outDict = [entireLayout_ getPreferencesDictionary];
	XCTAssertNil(outDict, @"Expected dictionary from getPreferencesDictionary.");
	XCTAssertNil([outDict objectForKey: @"World"], @"Expected dictionary to be empty.");
}

@end

