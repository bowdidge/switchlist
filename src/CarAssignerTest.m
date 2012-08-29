//
//  CarAssignerTest.m
//  SwitchList
//
//  Created by bowdidge on 10/29/10.
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

#import "CarAssignerTest.h"

#import "CarAssigner.h"
#import "Cargo.h"
#import "FreightCar.h"
#import "Industry.h"
#import "Place.h"
#import "Yard.h"

@implementation CarAssignerTest

NSString *FREIGHT_CAR_3 = @"ATSF 1";
NSString *FREIGHT_CAR_4 = @"NYC 1";

- (void) setUp {
	[super setUp];
	carAssigner_ = [[CarAssigner alloc] initWithUnassignedCars:nil layout:nil];
	[self makeThreeStationLayout];
}
- (void) tearDown {
	[carAssigner_ release];
	[super tearDown];
}

- (void) testCarWithNoCargoButLoadedGetsCargo {
	FreightCar *fc1 = [self makeFreightCarWithReportingMarks: FREIGHT_CAR_3];
	[fc1 setCargo: nil];
	[fc1 setIsLoaded: YES];
	[fc1 setCurrentLocation: [self industryAtStation: @"A"]];
	
	Cargo *c1 = [self makeCargo: @"a to b"];	
	[c1 setSource: [self industryAtStation: @"A"]];
	[c1 setDestination: [self industryAtStation: @"B"]];
	
	// Car fc1 should be a find.
	STAssertTrue([carAssigner_ cargo:c1 appropriateForCar:fc1], @"cargo and car with undefined division");
	
	CarAssigner *myCarAssigner = [[CarAssigner alloc] initWithUnassignedCars: [NSArray arrayWithObject: fc1]
																	  layout: entireLayout_];
	[myCarAssigner autorelease];
	STAssertEqualObjects([myCarAssigner assignedCarForCargo: c1], fc1, @"Find assigned car with incomplete cargo.");
	
	
}
- (void) testCarAssignerCarDivisionsUnset {
	FreightCar *fc1 = [self makeFreightCarWithReportingMarks: FREIGHT_CAR_3];

	Cargo *c1 = [self makeCargo: @"a to b"];	
	[c1 setSource: [self industryAtStation: @"A"]];
	[c1 setDestination: [self industryAtStation: @"B"]];

	[fc1 setHomeDivision: nil];
	
	STAssertNil([fc1 homeDivision], @"Check home division unset for freight car");
	STAssertNil([[c1 source] division], @"Check cargo source division unset");
	STAssertNil([[c1 destination] division], @"Check cargo destination division unset");
	
	// Everything has no division - should be a good match.
	STAssertTrue([carAssigner_ cargo:c1 appropriateForCar:fc1], @"cargo and car with undefined division");
		
	[[c1 source] setDivision: @"ATSF"];
	// Car is undefined, destination is undefined, so we should use it.
	STAssertTrue([carAssigner_ cargo:c1 appropriateForCar:fc1], @"undefined division car, source not of this division");

	[[c1 source] setDivision: nil];
	[[c1 destination] setDivision: @"ATSF"];
	// Car is undefined, source is undefined so we should use it.
	STAssertTrue([carAssigner_ cargo:c1 appropriateForCar:fc1], @"undefined division car, destination not of this division");

	[[c1 source] setDivision: @"ATSF"];
	[[c1 destination] setDivision: @"ATSF"];
	// Car is undefined, source and destination not here.
	STAssertTrue([carAssigner_ cargo:c1 appropriateForCar:fc1], @"undefined division car, cargo src, dest not of this division");
}

- (void) testCarAssignerCarForeignDivision {
	FreightCar *fc1 = [self makeFreightCarWithReportingMarks: FREIGHT_CAR_3];
	
	Cargo *c1 = [self makeCargo: @"a to b"];
	[c1 setSource: [self industryAtStation: @"A"]];
	[c1 setDestination: [self industryAtStation: @"B"]];
	[fc1 setHomeDivision: @"ATSF"];
	
	STAssertEqualObjects([fc1 homeDivision], @"ATSF", @"Check foreign car has foreign division");
	STAssertNil([[c1 source] division], @"Check cargo source division unset");
	STAssertEqualObjects([[c1 destination] division], nil, @"Check cargo destination division unset");


	// Car isn't of this division, but everything else is undefined.  Should be a good match.
	STAssertTrue([carAssigner_ cargo:c1 appropriateForCar:fc1], @"car foreign, cargo doesn't care");
	
	[[c1 source] setDivision: @"ATSF"];
	// Car is foreign road, source is foreign.  We should use it.
	STAssertTrue([carAssigner_ cargo:c1 appropriateForCar:fc1], @"car and source are both same foreign division");

	// Car isn't of this division, destination is same foreign division, use.
	[[c1 source] setDivision: nil];
	[[c1 destination] setDivision: @"ATSF"];
	// Car is home-road, source is here so we should use it
	STAssertTrue([carAssigner_ cargo:c1 appropriateForCar:fc1], @"car and destination are same division");
	
	[[c1 source] setDivision: @"ATSF"];
	[[c1 destination] setDivision: @"ATSF"];
	// Car is foreign, source and destination same.  Use.
	STAssertTrue([carAssigner_ cargo:c1 appropriateForCar:fc1], @"car, source, dest all the same.");
}

- (void) testCarAssignerCarMismatchDivision {
	FreightCar *fc1 = [self makeFreightCarWithReportingMarks: FREIGHT_CAR_3];
	
	Cargo *c1 = [self makeCargo: @"a to b"];
	[c1 setSource: [self industryAtStation: @"A"]];
	[c1 setDestination: [self industryAtStation: @"B"]];
	[fc1 setHomeDivision: @"BN"];
	
	STAssertEqualObjects([fc1 homeDivision], @"BN", @"Check foreign car has foreign division");
	STAssertNil([[c1 source] division], @"Check cargo source division unset");
	STAssertNil([[c1 destination] division], @"Check cargo destination division unset");
	
	
	// Car isn't of this division, but everything else doesn't care.  Should be a good match.
	STAssertTrue([carAssigner_ cargo:c1 appropriateForCar:fc1], @"car foreign, cargo doesn't care");
	
	[[c1 source] setDivision: @"ATSF"];
	// Car is foreign road, source is foreign.  We should use it.
	STAssertTrue([carAssigner_ cargo:c1 appropriateForCar:fc1], @"car foreign, destination doesn't care.");
	
	// Car isn't of this division, destination is same foreign division, use.
	[[c1 source] setDivision: nil];
	[[c1 destination] setDivision: @"ATSF"];
	// Car is home-road, source is here so we should use it
	STAssertTrue([carAssigner_ cargo:c1 appropriateForCar:fc1], @"car foreign, source doesn't care.");
	
	[[c1 source] setDivision: @"ATSF"];
	[[c1 destination] setDivision: @"ATSF"];
	// Car is foreign, source and destination same.  Use.
	STAssertFalse([carAssigner_ cargo:c1 appropriateForCar:fc1], @"car is foreign, and source/dest are different division.");
}

// Do we correctly just mark the cargo as loaded if the car's already there?
- (void) testFreightCarAutoLoadedIfAtSource {
	FreightCar *fc1 = [self makeFreightCarWithReportingMarks: FREIGHT_CAR_3];
	[fc1 setCurrentLocation: [self industryAtStation: @"A"]];
	
	CarAssigner *myCarAssigner = [[CarAssigner alloc] initWithUnassignedCars: [NSArray arrayWithObject: fc1]
																	  layout: entireLayout_];
	[myCarAssigner autorelease];
	Cargo *c1 = [self makeCargo: @"a to b"];
	[c1 setSource: [self industryAtStation: @"A"]];
	[c1 setDestination: [self industryAtStation: @"B"]];
	
	STAssertEqualObjects([myCarAssigner assignedCarForCargo: c1], fc1, @"Test car is correctly assigned to cargo");
	STAssertTrue([fc1 isLoaded], @"Test cargo is marked as loaded because we're already there.");
}

// Do we mark the cargo as loaded if the car's already there and we're in staging?
- (void) testFreightCarNotAutoLoadedIfAtSourceInStaging {
	FreightCar *fc1 = [self makeFreightCarWithReportingMarks: FREIGHT_CAR_3];
	[[entireLayout_ stationWithName: @"A"] setIsStaging: YES];
	[self makeYardAtStation: @"A"];
	[fc1 setCurrentLocation: [self yardAtStation: @"A"]];
	
	CarAssigner *myCarAssigner = [[CarAssigner alloc] initWithUnassignedCars: [NSArray arrayWithObject: fc1]
																	  layout: entireLayout_];
	[myCarAssigner autorelease];
	Cargo *c1 = [self makeCargo: @"a to b"];
	[c1 setSource: [self industryAtStation: @"A"]];
	[c1 setDestination: [self industryAtStation: @"B"]];
	
	STAssertEqualObjects([myCarAssigner assignedCarForCargo: c1], fc1, @"Test car is correctly assigned to cargo");
	STAssertFalse([fc1 isLoaded], @"Test cargo should be not marked as loaded because it can be moved.");
}

// Do we correctly just mark the cargo as loaded if the car's already there and we're in staging?
- (void) testFreightCarAutoLoadedIfAtSourceInStagingAndCarInYard {
	FreightCar *fc1 = [self makeFreightCarWithReportingMarks: FREIGHT_CAR_3];
	[[entireLayout_ stationWithName: @"A"] setIsStaging: YES];
	[self makeYardAtStation: @"A"];
	[fc1 setCurrentLocation: [self yardAtStation: @"A"]];
	
	CarAssigner *myCarAssigner = [[CarAssigner alloc] initWithUnassignedCars: [NSArray arrayWithObject: fc1]
																	  layout: entireLayout_];
	[myCarAssigner autorelease];
	Cargo *c1 = [self makeCargo: @"a to b"];
	[c1 setSource: [self industryAtStation: @"A"]];
	[c1 setDestination: [self industryAtStation: @"B"]];
	
	STAssertEqualObjects([myCarAssigner assignedCarForCargo: c1], fc1, @"Test car is correctly assigned to cargo");
	STAssertFalse([fc1 isLoaded], @"Test cargo is not marked as loaded because it can be moved in staging.");
}

// Do we correctly just mark the cargo as loaded if the car's already there and we're in staging?
- (void) testFreightCarNotAutoLoadedIfAtSourceInStagingAndCarAtOtherStaging {
	FreightCar *fc1 = [self makeFreightCarWithReportingMarks: FREIGHT_CAR_3];
	[[entireLayout_ stationWithName: @"A"] setIsStaging: YES];
	[[entireLayout_ stationWithName: @"C"] setIsStaging: YES];
	[fc1 setCurrentLocation: [self industryAtStation: @"C"]];
	
	CarAssigner *myCarAssigner = [[CarAssigner alloc] initWithUnassignedCars: [NSArray arrayWithObject: fc1]
																	  layout: entireLayout_];
	[myCarAssigner autorelease];
	Cargo *c1 = [self makeCargo: @"a to b"];
	[c1 setSource: [self industryAtStation: @"A"]];
	[c1 setDestination: [self industryAtStation: @"B"]];
	
	STAssertEqualObjects([myCarAssigner assignedCarForCargo: c1], fc1, @"Test car is correctly assigned to cargo");
	STAssertFalse([fc1 isLoaded], @"Test cargo is marked as loaded because we're already there.");
}

// Do we correctly just mark the cargo as loaded in C because it's staging and load comes from offline?
- (void) testFreightCarAutoLoadedIfAtSourceOffline {
	FreightCar *fc1 = [self makeFreightCarWithReportingMarks: FREIGHT_CAR_3];
	[[entireLayout_ stationWithName: @"A"] setIsOffline: YES];
	[[entireLayout_ stationWithName: @"C"] setIsStaging: YES];
	[fc1 setCurrentLocation: [self industryAtStation: @"C"]];
	
	CarAssigner *myCarAssigner = [[CarAssigner alloc] initWithUnassignedCars: [NSArray arrayWithObject: fc1]
																	  layout: entireLayout_];
	[myCarAssigner autorelease];
	Cargo *c1 = [self makeCargo: @"a to b"];
	[c1 setSource: [self industryAtStation: @"A"]];
	[c1 setDestination: [self industryAtStation: @"B"]];
	
	STAssertEqualObjects([myCarAssigner assignedCarForCargo: c1], fc1, @"Test car is correctly assigned to cargo");
	STAssertTrue([fc1 isLoaded], @"Test cargo is marked as loaded because we're already there.");
}


// Do we correctly mark cargo as unloaded if car isn't at correct site?
- (void) testFreightCarNotLoadedAtStart {
	FreightCar *fc1 = [self makeFreightCarWithReportingMarks: FREIGHT_CAR_3];
	[fc1 setCurrentLocation: [self industryAtStation: @"B"]];
	
	CarAssigner *myCarAssigner = [[CarAssigner alloc] initWithUnassignedCars: [NSArray arrayWithObject: fc1]
																	  layout: entireLayout_];
	[myCarAssigner autorelease];
	Cargo *c1 = [self makeCargo: @"a to b"];
	[c1 setSource: [self industryAtStation: @"A"]];
	[c1 setDestination: [self industryAtStation: @"B"]];
	
	STAssertEqualObjects([myCarAssigner assignedCarForCargo: c1], fc1, @"Test car is correctly assigned to cargo");
	STAssertFalse([fc1 isLoaded], @"Test cargo is marked as loaded because we're already there.");
}

- (void) testHandlesIncompleteCargoSafely {
	// TODO(bowdidge): Bad test.  Incomplete cargos shouldn't get passed to assignedCarForCargo.
	FreightCar *fc1 = [self makeFreightCarWithReportingMarks: FREIGHT_CAR_3];
	[fc1 setCurrentLocation: [self industryAtStation: @"A"]];
	CarAssigner *myCarAssigner = [[CarAssigner alloc] initWithUnassignedCars: [NSArray arrayWithObject: fc1]
																	  layout: entireLayout_];
	[myCarAssigner autorelease];
	Cargo *c1 = [self makeCargo: @"a to b"];
	// This shouldn't crash.
	STAssertTrue([myCarAssigner cargo:c1 appropriateForCar:fc1], @"car foreign, cargo doesn't care");
	STAssertEqualObjects([myCarAssigner assignedCarForCargo: c1], fc1, @"Find assigned car with incomplete cargo.");
	STAssertNotNil([fc1 cargo], @"Cargo assigned");
	STAssertFalse([fc1 isLoaded], @"Cargo should not be loaded.");
}

// TODO(bowdidge): Move to freight car test eventually.
- (void) testFreightCarHomeDivision {
	FreightCar *fc1 = [self makeFreightCarWithReportingMarks: FREIGHT_CAR_3];
	STAssertNil([fc1 homeDivision], @"Check foreign car has foreign division");
	
	[fc1 setHomeDivision: @"BN"];
	STAssertEqualObjects([fc1 homeDivision], @"BN", @"Check setting home division is permanent.");
	
	[fc1 setHomeDivision: @"Here"];
	STAssertEqualObjects([fc1 homeDivision], @"Here", @"Check setting home division to Here works.");

	
	[fc1 setHomeDivision: @""];
	STAssertNil([fc1 homeDivision], @"Check setting home division to empty string works.");

	[fc1 setHomeDivision: @" "];
	STAssertNil([fc1 homeDivision], @"Check setting home division to spaces works.");
}

- (void) testSameCarNotAssignedEveryTime {
	FreightCar *fc1 = [self makeFreightCarWithReportingMarks: FREIGHT_CAR_3];
	[fc1 setCargo: nil];
	[fc1 setIsLoaded: YES];
	[fc1 setCurrentLocation: [self industryAtStation: @"A"]];

	FreightCar *fc2 = [self makeFreightCarWithReportingMarks: FREIGHT_CAR_4];
	[fc2 setCargo: nil];
	[fc2 setIsLoaded: YES];
	[fc2 setCurrentLocation: [self industryAtStation: @"A"]];

	
	Cargo *c1 = [self makeCargo: @"a to b"];	
	[c1 setSource: [self industryAtStation: @"A"]];
	[c1 setDestination: [self industryAtStation: @"B"]];
	

    int numberOfTimesFc1Assigned = 0;
	int i;
	for (i=0;i<10;i++) {
		CarAssigner *myCarAssigner = [[CarAssigner alloc] initWithUnassignedCars: [NSArray arrayWithObjects: fc1, fc2, nil]
																		  layout: entireLayout_];
		[myCarAssigner autorelease];
		if (fc1 == [myCarAssigner assignedCarForCargo: c1]) {
			numberOfTimesFc1Assigned++;
			[fc1 setCargo: nil];
		}
	}
	// fc1 and fc2 should have been assigned equally.  If only fc1 or fc2 got
	// assigned, something's probably wrong.
	// TODO(bowdidge): Probably a flaky test. There's probably a better way to test this.
	STAssertTrue(2 < numberOfTimesFc1Assigned < 8, @"Car assigner skewed to particular car, expected 5 uses, found %d", numberOfTimesFc1Assigned);
}



@end
