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
#import "Place.h"
#import "ScheduledTrain.h"
#import "Yard.h"


// Tests functionality in EntireLayout class - mostly whether global queries work.

@implementation EntireLayoutTest

- (void) testSetName {
	[self makeSimpleLayout];
	
	id entireLayout = [[EntireLayout alloc] initWithMOC: context_];
	[entireLayout setLayoutName: @"Test"];
	STAssertEqualObjects([entireLayout layoutName], @"Test", @".  Name does not match.");
	// TODO(bowdidge): For now, just check not-nil as opposed to actually within seconds of now.
	STAssertNotNil([entireLayout currentDate], @".  Date not equal to today.");
}

// Checks that the workbench object exists in the layout object once we request it.
- (void) testWorkbench {
	// Make sure we allocate one and only one workbench.
	id entireLayout = [[EntireLayout alloc] initWithMOC: context_];
	// Populate industry stuff.
	Industry *workbenchIndustry = [entireLayout workbenchIndustry];
	STAssertNotNil([entireLayout workbench], @"Workbench not defined.");
	Place *workbench = [entireLayout workbench];
	STAssertFalse([workbench isStaging], @"Workbench should not be staging.");
	STAssertTrue([workbench isOffline], @"Workbench should be offline.");
	STAssertEqualsInt(1, [[entireLayout allStations] count], @"Wrong number of Places");
	STAssertEqualObjects([workbench name], @"Workbench", @"Name not correct.");
}

- (void) testPreferences {
	// TODO(bowdidge): Test we can read it back.

}
	
- (void) testAllFreightCars {
	// Make sure the workbench industry is in the workbench place.
	id entireLayout = [[EntireLayout alloc] initWithMOC: context_];
	id workbenchIndustry = [entireLayout workbenchIndustry];
    FreightCar *car1 = [self makeFreightCarWithReportingMarks: @"SP 1"];
	FreightCar *car2 = [self makeFreightCarWithReportingMarks: @"SP 2"];
	[car2 setCurrentLocation: workbenchIndustry];
	
	STAssertEqualsInt(2, [[entireLayout allFreightCars] count], @"Wrong number of total freight cars");
	STAssertEqualsInt(1, [[entireLayout allAvailableFreightCars] count],  @"Wrong number of available freight cars");
	STAssertEqualsInt(0, [[entireLayout allReservedFreightCars] count], @"Wrong number of reserved freight cars");
}

- (void) testFreightCarsOnWorkbench {
	id entireLayout = [[EntireLayout alloc] initWithMOC: context_];
	id workbenchIndustry = [entireLayout workbenchIndustry];
    FreightCar *car1 = [self makeFreightCarWithReportingMarks: @"SP 1"];
	FreightCar *car2 = [self makeFreightCarWithReportingMarks: @"SP 2"];
	[car2 setCurrentLocation: workbenchIndustry];
	
	STAssertEqualsInt(2, [[entireLayout allFreightCars] count], @"Wrong number of total freight cars");
	// Make sure we don't count the car on the workbench as available.
	STAssertEqualsInt(1, [[entireLayout allAvailableFreightCars] count], @"Wrong number of available freight cars");
	// Make sure neither car has a cargo.
	STAssertEqualsInt(0, [[entireLayout allReservedFreightCars] count], @"Wrong number of reserved freight cars");
}

- (void) testFreightCars {
	// Unit tests for freight cars.
	// TODO(bowdidge) Move to own section.
	id entireLayout = [[EntireLayout alloc] initWithMOC: context_];
	id workbenchIndustry = [entireLayout workbenchIndustry];
	FreightCar *car1 = [self makeFreightCarWithReportingMarks: @"SP 1"];
	FreightCar *car2 = [self makeFreightCarWithReportingMarks: @"DRG&W 99999"];
	FreightCar *car3 = [self makeFreightCarWithReportingMarks: @"UP  2222"];
	FreightCar *car4 = [self makeFreightCarWithReportingMarks: @"LA2X 9999"];
	
	STAssertEqualObjects(@"SP", [car1 initials], @"Car initials should be SP, were %@", [car1 initials]);
	STAssertEqualObjects(@"1", [car1 number], @"Car number should be 1, was %@", [car1 initials]);

	STAssertEqualObjects(@"DRG&W", [car2 initials], @"Car initials should be DRG&W, were %@", [car2 initials]);
	STAssertEqualObjects(@"99999", [car2 number], @"Car number should be 99999, was %@", [car2 initials]);

	STAssertEqualObjects(@"UP", [car3 initials], @"Car initials should be UP, were %@", [car3 initials]);
	STAssertEqualObjects(@"2222", [car3 number], @"Car number should be 22222, was %@", [car3 initials]);

	STAssertEqualObjects(@"LA2X", [car4 initials], @"Car initials should be LA2X, were %@", [car4 initials]);
	STAssertEqualObjects(@"9999", [car4 number], @"Car number should be 9999, was %@", [car4 initials]);
}

- (void) testFreightCarCargos {
	[self makeThreeStationLayout];
	FreightCar *fc1 = [self makeFreightCarWithReportingMarks: @"SP1"];
	FreightCar *fc2 = [self makeFreightCarWithReportingMarks: @"SP2"];

	Cargo *c1 = [self makeCargo: @"Foo"];
	[c1 setSource: [self industryAtStation: @"A"]];
	[c1 setDestination: [self industryAtStation: @"B"]];
	[fc1 setCargo: c1];
	[fc1 setLoaded: NO];

	// Cars that are empty and unassigned or empty and assigned should appear the same way.
	STAssertEqualObjects(@"empty", [fc1 cargoDescription], @"");
	STAssertEqualObjects(@"empty", [fc2 cargoDescription], @"");

	[fc1 setIsLoaded: YES];
	STAssertEqualObjects(@"Foo", [fc1 cargoDescription], @"");
}


// Make sure the reportingMarks, initials, and number fields work with strange values.
- (void) testFreightCarNumbers {
	FreightCar *fc1 = [self makeFreightCarWithReportingMarks: @"F&C 123"];
	STAssertEqualObjects(@"F&C 123", [fc1 reportingMarks], @"Reporting marks don't match.");
	STAssertEqualObjects(@"F&C", [fc1 initials], @"Initials don't match.");
	STAssertEqualObjects(@"123", [fc1 number], @"Number doesn't match.");
	
	FreightCar *fc2 = [self makeFreightCarWithReportingMarks: @" F&C 123"];
	STAssertEqualObjects(@" F&C 123", [fc2 reportingMarks], @"Reporting marks don't match.");
	STAssertEqualObjects(@"F&C", [fc2 initials], @"Initials don't match.");
	STAssertEqualObjects(@"123", [fc2 number], @"Number doesn't match.");
	
	FreightCar *fc3 = [self makeFreightCarWithReportingMarks: @"F 1"];
	STAssertEqualObjects(@"F 1", [fc3 reportingMarks], @"Reporting marks don't match.");
	STAssertEqualObjects(@"F", [fc3 initials], @"Initials don't match.");
	STAssertEqualObjects(@"1", [fc3 number], @"Number doesn't match.");
	
	FreightCar *fc4 = [self makeFreightCarWithReportingMarks: @"F A 1"];
	STAssertEqualObjects(@"F A 1", [fc4 reportingMarks], @"Reporting marks don't match.");
	STAssertEqualObjects(@"F", [fc4 initials], @"Initials don't match.");
	STAssertEqualObjects(@"A 1", [fc4 number], @"Number doesn't match.");
	
	FreightCar *fc5 = [self makeFreightCarWithReportingMarks: @""];
	STAssertEqualObjects(@"", [fc5 reportingMarks], @"Reporting marks don't match.");
	STAssertEqualObjects(@"", [fc5 initials], @"Initials don't match.");
	STAssertEqualObjects(@"", [fc5 number], @"Number doesn't match.");
	
	FreightCar *fc6 = [self makeFreightCarWithReportingMarks: @"FOO"];
	STAssertEqualObjects(@"FOO", [fc6 reportingMarks], @"Reporting marks don't match.");
	STAssertEqualObjects(@"FOO", [fc6 initials], @"Initials don't match.");
	STAssertEqualObjects(@"", [fc6 number], @"Number doesn't match.");
	
	FreightCar *fc7 = [self makeFreightCarWithReportingMarks: @"F&C123"];
	STAssertEqualObjects(@"F&C123", [fc7 reportingMarks], @"Reporting marks don't match.");
	STAssertEqualObjects(@"F&C123", [fc7 initials], @"Initials don't match.");
	STAssertEqualObjects(@"", [fc7 number], @"Number doesn't match.");
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
	STAssertFalse([[entireLayout_ allFreightCarsAtDestination] containsObject: fc1], @"Car without cargo shouldn't be at destination.");
	

	// fc2 has a cargo, but the car isn't at source or dest.
	[fc2 setCurrentLocation: [self industryAtStation: @"C"]];
	[fc2 setCargo: c1];
	STAssertFalse([[entireLayout_ allFreightCarsAtDestination] containsObject: fc2], @"Car not at src or dest not at destination.");
	
	// fc2 has a cargo, is unloaded, and is at source.
	[fc2 setCurrentLocation: [self industryAtStation: @"A"]];
	[fc2 setIsLoaded: NO];
	STAssertTrue([[entireLayout_ allFreightCarsAtDestination] containsObject: fc2], @"Car not at src or dest not at destination.");

	// If fc2 is loaded, it's not at the next destination.
	[fc2 setIsLoaded: YES];
	STAssertFalse([[entireLayout_ allFreightCarsAtDestination] containsObject: fc2], @"Car not at src or dest not at destination.");

	// If fc2 is loaded, it's not at the next destination.
	[fc2 setIsLoaded: YES];
	[fc2 setCurrentLocation: [self industryAtStation: @"C"]];
	STAssertFalse([[entireLayout_ allFreightCarsAtDestination] containsObject: fc2], @"Car not at src or dest not at destination.");
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
	
	STAssertEqualsInt(2, [[entireLayout allFreightCars] count], @"Wrong total number of cars");
	STAssertEqualsInt(1, [[entireLayout allFreightCarsNotInTrain] count], @"Wrong number of cars not in train");
	STAssertTrue([[myTrain freightCars] containsObject: fc1], @"freight car 1 should be in train.");
	STAssertFalse([[myTrain freightCars] containsObject: fc2], @"freight car 2 should not be in train.");
}


- (void) testAllStations {
	// Make sure the workbench industry is in the workbench place.
	id entireLayout = [[EntireLayout alloc] initWithMOC: context_];
    Place *placeA = [self makePlaceWithName: @"A"];
	Place *placeB = [self makePlaceWithName: @"B"];
	Place *placeC = [self makePlaceWithName: @"C"];
	[placeB setIsStaging: YES];

	// Workbench counts as a station.
	STAssertEqualsInt(4, [[entireLayout allStations] count], @"Wrong number of stations");
	STAssertEqualsInt(1, [[entireLayout allStationsInStaging] count], @"Wrong number of stations in staging");
	STAssertEqualsInt(1, [[entireLayout allStationNamesInStaging] count], @"Wrong number of station names in staging.");
	STAssertTrue([[entireLayout allStationNamesInStaging] containsObject: @"B"], @"Place A not in all station names in staging.");
}

// Make sure we correctly handle valid and invalid names.
- (void) testStationWithName {
	id entireLayout = [[EntireLayout alloc] initWithMOC: context_];
    Place *placeA = [self makePlaceWithName: @"A"];
	
	STAssertEqualObjects([entireLayout stationWithName: @"A"], placeA, @"Check existence of A");
	STAssertNil([entireLayout stationWithName: @"Bogus"], @"Check bogus name rejected");
	STAssertNil([entireLayout stationWithName: nil], @"Check NULL rejected.");	
}

- (void) disableTestStationValidation {
	Place *placeA = [self makePlaceWithName: @"A"];
	Place *placeB = [self makePlaceWithName: @""];
	NSString *proposedNameA = @"A";
	NSString *proposedNameB = @"B";
	NSError *error = nil;
	STAssertTrue([placeB validateName: &proposedNameB error:&error], @"B should be legal name for place.");
	STAssertNil(error, @"Error not nil.");
 	STAssertFalse([placeB validateName: &proposedNameA error:&error], @"A should not be legal name for place.");
	STAssertNotNil(error, @"Error should be non-nil");
}								 

- (void) testAllIndustries {
	// TODO(bowdidge): Test that yards are included.
	// Make sure the workbench industry is in the workbench place.
	id entireLayout = [[EntireLayout alloc] initWithMOC: context_];
	Place *placeA = [self makePlaceWithName: @"A"];
	
	STAssertEqualsInt(1, [[entireLayout allIndustries] count], @"Wrong number of industries");
}

- (void) testAllCargo {
	EntireLayout *entireLayout = [[EntireLayout alloc] initWithMOC: context_];
	[self makeThreeStationLayout];
	
	Cargo *c1 = [self makeCargo: @"b to c"];
	[c1 setSource: [self industryAtStation: @"B"]];
	[c1 setDestination: [self industryAtStation: @"C"]];
	
	STAssertEqualsInt(1, [[entireLayout allValidCargos] count], @"Wrong number of cargos");
	STAssertTrue([[entireLayout allValidCargos] containsObject: c1], @"cargo isn't in list.");
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
	
	STAssertEqualsInt(1, [[entireLayout allFixedRateCargos] count], @"Wrong number of cargos");
	STAssertTrue([[entireLayout allFixedRateCargos] containsObject: c2], @"cargo isn't in list.");
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
	
	STAssertEqualsInt(1, [[entireLayout allNonFixedRateCargos] count], @"Wrong number of cargos");
	STAssertTrue([[entireLayout allNonFixedRateCargos] containsObject: c1], @"cargo isn't in list.");
}

// TODO(bowdidge): Move to ScheduledTrainTests?
- (void) testAllCarsInTrainSortedInVisitOrder {
	[self makeThreeStationLayout];
	[self makeThreeStationTrain];
	
	ScheduledTrain *myTrain1 = [[entireLayout_ allTrains] lastObject];
	NSArray *allCars = [myTrain1 allFreightCarsInVisitOrder];
	STAssertEqualsInt(2, [allCars count], @"Not enough cars in train.");
	// First A->B car
	STAssertEqualObjects([[[allCars objectAtIndex: 0] cargo] cargoDescription], @"A to B", @"Cars out of order");
    // Then B->C Car									
	STAssertEqualObjects([[[allCars objectAtIndex: 1] cargo] cargoDescription], @"B to C", @"Cars out of order.");
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

	STAssertEqualsInt(3, [allStations count], @"Not enough stops.");
	
	NSDictionary *stationAData = [allStations objectAtIndex: 0];
	NSDictionary *stationBData = [allStations objectAtIndex: 1];
	NSDictionary *stationCData = [allStations objectAtIndex: 2];
	
	STAssertEqualObjects(@"A", [stationAData objectForKey: @"name"], @"Station A missing");
 	STAssertEqualObjects(@"B", [stationBData objectForKey: @"name"], @"Station B missing");
	STAssertEqualObjects(@"C", [stationCData objectForKey: @"name"], @"Station C missing");
	
	STAssertEqualsInt(1, [[stationAData objectForKey: @"industries"] count], @"");
	NSDictionary *industryAData = [[stationAData objectForKey: @"industries"] objectForKey: @"A-industry"];

	STAssertEqualsInt(1, [[stationBData objectForKey: @"industries"] count], @"");
	NSDictionary *industryBData = [[stationBData objectForKey: @"industries"] objectForKey: @"B-industry"];

	STAssertEqualsInt(1, [[stationCData objectForKey: @"industries"] count], @"");
	NSDictionary *industryCData = [[stationCData objectForKey: @"industries"] objectForKey: @"C-industry"];
	
	STAssertEqualsInt(0, [[industryAData objectForKey: @"carsToDropOff"] count],
				@"No cars expected to drop off at station A, found %d", [[stationAData objectForKey: @"carsToDropOff"] count]);
	STAssertEqualsInt(1, [[industryAData objectForKey: @"carsToPickUp"] count],
				 @"Expected one car to pick up at station A, found %d.", [[stationAData objectForKey: @"carsToPickUp"] count]);

	STAssertEqualsInt(1, [[industryBData objectForKey: @"carsToDropOff"] count], @"Expected one car to drop off at station B.");
	STAssertEqualsInt(1, [[industryBData objectForKey: @"carsToPickUp"] count], @"Expected one car to pick up at station B.");

	STAssertEqualsInt(1, [[industryCData objectForKey: @"carsToDropOff"] count], @"Expected one car to drop off at station C.");
	STAssertEqualsInt(0, [[industryCData objectForKey: @"carsToPickUp"] count], @"Expected no cars to pick up at station C.");
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

	STAssertEqualsInt(2, [allStations count], @"Wrong number of stops, expected 2, found %d", [allStations count]);
	
	NSDictionary *stationAData = [allStations objectAtIndex: 0];
	NSDictionary *stationBData = [allStations objectAtIndex: 1];

	STAssertEqualObjects(@"A", [stationAData objectForKey: @"name"], @"Station A missing");
 	STAssertEqualObjects(@"B", [stationBData objectForKey: @"name"], @"Station B missing");
	
	STAssertEqualsInt(1, [[stationAData objectForKey: @"industries"] count], @"");
	NSDictionary *industryAData = [[stationAData objectForKey: @"industries"] objectForKey: @"A-industry"];
	
	STAssertEqualsInt(1, [[stationBData objectForKey: @"industries"] count], @"");
	NSDictionary *industryBData = [[stationBData objectForKey: @"industries"] objectForKey: @"B-industry"];
	
	STAssertEqualsInt(0, [[industryAData objectForKey: @"carsToDropOff"] count],
				 @"No cars expected to drop off at station A, found %d", [[stationAData objectForKey: @"carsToDropOff"] count]);
	STAssertEqualsInt(2, [[industryAData objectForKey: @"carsToPickUp"] count],
				 @"Expected one car to pick up at station A, found %d.", [[stationAData objectForKey: @"carsToPickUp"] count]);

	STAssertEqualsInt(2, [[industryBData objectForKey: @"carsToDropOff"] count], @"Expected one car to drop off at station B.");
	STAssertEqualsInt(0, [[industryBData objectForKey: @"carsToPickUp"] count], @"Expected one car to pick up at station B.");
}

- (void) testStationStops {
	[self makeThreeStationLayout];
	[self makeThreeStationTrain];
	
	ScheduledTrain *myTrain1 = [[entireLayout_ allTrains] lastObject];
	NSArray *stops = [myTrain1 stationStopObjects];
	
	STAssertEqualsInt(3, [stops count], @"Incorrect number of stops for train");
	STAssertEqualObjects([entireLayout_ stationWithName: @"A"],
						 [stops objectAtIndex: 0], @"A not first station.");
	STAssertEqualObjects([entireLayout_ stationWithName: @"B"],
						 [stops objectAtIndex: 1], @"B not second station.");
	STAssertEqualObjects([entireLayout_ stationWithName: @"C"],
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
	
	STAssertTrue([myTrain acceptsCar: fc1], @"Should be accepted");
	STAssertFalse([myTrain acceptsCar: fc2], @"Should not be accepted");
}

- (void) testAllFreightCarsInYard {
	[self makeThreeStationLayout];
	[self makeYardAtStation: @"A"];
	FreightCar *fc = [self makeFreightCarWithReportingMarks: @"A 1"];
	[fc setCurrentLocation: [self yardAtStation: @"A"]];
	NSArray *carsInYard = [entireLayout_ allFreightCarsInYard];
	STAssertEqualsInt(1, [carsInYard count], @"Incorrect number of cars in yard, found %d", [carsInYard count]);
}

- (void) testImport {
	NSString *input = @"SP 1\nSP 2  \n    SP 3\n";
	NSMutableString *errors = nil;
	[entireLayout_ importFreightCarsUsingString: input errors: &errors];
	STAssertEqualsInt(3, [[entireLayout_ allFreightCars] count], @"Expected 3 freight cars, got %d", [[entireLayout_ allFreightCars] count]);
	STAssertEqualsInt(0, [errors length], @"No errors expected");
}

- (void) testImportBlankLines {
	NSString *input = @"SP 1\n\n\n\nSP 2  \n    SP 3\n";
	NSMutableString *errors = nil;
	[entireLayout_ importFreightCarsUsingString: input errors: &errors];
	STAssertEqualsInt(0, [errors length], @"No errors expected");
	STAssertEqualsInt(3, [[entireLayout_ allFreightCars] count], @"Expected 3 freight cars, got %d (%@)", [[entireLayout_ allFreightCars] count],[entireLayout_ allFreightCars]);
	STAssertNotNil([self freightCarWithReportingMarks: @"SP 1"], @"Freight car names corrupted.");
}

// TODO(bowdidge): How far do I want to go with invalid characters?
// TODO(bowdidge): \r treated as non-space.
// TODO(bowdidge): What happens if the car name already exists?
- (void) disableTestImportControlCharacters {
	NSString *input = @"SP 1\007\b\\nSP 2  \n    SP 3\n";
	NSMutableString *errors = nil;
	[entireLayout_ importFreightCarsUsingString: input errors: &errors];
	STAssertEqualsInt(0, [errors length], @"No errors expected");
	STAssertEqualsInt(3, [[entireLayout_ allFreightCars] count], @"Expected 3 freight cars, got %d", [[entireLayout_ allFreightCars] count]);
}

- (void) checkExistenceOfCar: (NSString*) reportingMarks type: (NSString*) carType {
	FreightCar *fc = [self freightCarWithReportingMarks: reportingMarks];
	STAssertNotNil(fc, @"Freight car %@ not found", reportingMarks);	
	NSString *actualCarTypeName = [[fc carTypeRel] carTypeName];
	STAssertEqualObjects(carType, actualCarTypeName,
				   @"Expected freight car %@ to have type %@, but had type %@",
				   reportingMarks, carType, actualCarTypeName);
}

- (void)testImportCarTypes {
	NSString *input = @"SP 1, XM,\nSP 2, T\nSP    3\nSP 4\tXM\n  SP  5\t MYCARTYPE\t\n";
	NSMutableString *errors = nil;
	[entireLayout_ importFreightCarsUsingString: input errors: &errors];
	STAssertEqualsInt(0, [errors length], @"No errors expected");
	
	STAssertEqualsInt(5, [[entireLayout_ allFreightCars] count], @"Expected 4 freight cars, got %d", [[entireLayout_ allFreightCars] count]);
	
	[self checkExistenceOfCar: @"SP 1" type: @"XM"];
	[self checkExistenceOfCar: @"SP 2" type: @"T"];
	[self checkExistenceOfCar: @"SP 3" type: nil];
	[self checkExistenceOfCar: @"SP 4" type: @"XM"];
	[self checkExistenceOfCar: @"SP 5" type: @"MYCARTYPE"];
	NSString *actualCarTypeDescription = [[[self freightCarWithReportingMarks: @"SP 5"] carTypeRel] carTypeDescription];
	STAssertEqualObjects(@"", actualCarTypeDescription,
						 @"Car type description for new car type assumed to be empty but was %@", actualCarTypeDescription);
}

- (void) testCargoLoadsPerDay {
	[self makeThreeStationLayout];
	Cargo *c1 = [self makeCargo: @"b to c"];
	[c1 setSource: [self industryAtStation: @"B"]];
	[c1 setDestination: [self industryAtStation: @"C"]];
	[c1 setCarsPerWeek: [NSNumber numberWithInt: 7]];
	
	STAssertEqualsInt(1, [entireLayout_ loadsPerDay], @"Expected 1 load/day, got %d", [entireLayout_ loadsPerDay]);
}

- (void) testCargoLoadsPerDayFractions {
	[self makeThreeStationLayout];
	Cargo *c1 = [self makeCargo: @"b to c"];
	[c1 setSource: [self industryAtStation: @"B"]];
	[c1 setDestination: [self industryAtStation: @"C"]];
	[c1 setCarsPerWeek: [NSNumber numberWithInt: 10]];
	
	Cargo *c2 = [self makeCargo: @"a to b"];
	[c2 setSource: [self industryAtStation: @"A"]];
	[c2 setDestination: [self industryAtStation: @"B"]];
	[c2 setCarsPerWeek: [NSNumber numberWithInt: 11]];
	
	STAssertEqualsInt(3, [entireLayout_ loadsPerDay], @"Expected 1 load/day, got %d", [entireLayout_ loadsPerDay]);
}

- (void) testSqlSanity {
	[self makeThreeStationLayout];
	Industry *i = [entireLayout_ industryWithName: @"'" withStationName: @"A"];
	// Make sure it didn't crash, and didn't return anything.
	STAssertNil(i, @"industryWithName not correctly finding quote");
	
	Industry *myIndustry = [self makeIndustryWithName: @"robert's"];
	[myIndustry setLocation: [entireLayout_ stationWithName: @"A"]];
	Industry *j = [entireLayout_ industryWithName: @"robert's-industry" withStationName: @"A"];
	STAssertEquals(j, myIndustry, @"Wrong industry returned.");
	
	// Same test for freight cars at industry - just test it doesn't throw.
	NSSet *cars = [myIndustry freightCars];
	STAssertNotNil(cars, @"freightCars failed.");
}

@end

