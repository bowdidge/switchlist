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
	carAssigner_ = [[CarAssigner alloc] initWithUnassignedCars:nil];
	[self makeThreeStationLayout];

	myCargo_ = [[self makeCargo: @"a to b"] retain];	
	[myCargo_ setSource: [self industryAtStation: @"A"]];
	[myCargo_ setDestination: [self industryAtStation: @"B"]];
	
	myFreightCar_ = [[self makeFreightCarWithReportingMarks: FREIGHT_CAR_3] retain];
}
- (void) tearDown {
	[carAssigner_ release];
	[myCargo_ release];
	[myFreightCar_ release];
	[super tearDown];
}

- (void) testCarWithNoCargoButLoadedGetsCargo {
	[myFreightCar_ setCargo: nil];
	[myFreightCar_ setIsLoaded: YES];
	[myFreightCar_ setCurrentLocation: [self industryAtStation: @"A"]];
	
	
	// Car fc1 should be a find.
	STAssertTrue([carAssigner_ cargo: myCargo_ appropriateForCar: myFreightCar_], @"cargo and car with undefined division");
	
	CarAssigner *myCarAssigner = [[CarAssigner alloc] initWithUnassignedCars: [NSArray arrayWithObject: myFreightCar_]];
	[myCarAssigner autorelease];
	STAssertEqualObjects([myCarAssigner assignedCarForCargo: myCargo_], myFreightCar_, @"Find assigned car with incomplete cargo.");
	
	
}
- (void) testCarAssignerCarDivisionsUnset {
	[myFreightCar_ setHomeDivision: nil];
	
	STAssertNil([myFreightCar_ homeDivision], @"Check home division unset for freight car");
	STAssertNil([[myCargo_ source] division], @"Check cargo source division unset");
	STAssertNil([[myCargo_ destination] division], @"Check cargo destination division unset");
	
	// Everything has no division - should be a good match.
	STAssertTrue([carAssigner_ cargo: myCargo_ appropriateForCar: myFreightCar_], @"cargo and car with undefined division");
		
	[[myCargo_ source] setDivision: @"ATSF"];
	// Car is undefined, destination is undefined, so we should use it.
	STAssertTrue([carAssigner_ cargo:myCargo_ appropriateForCar:myFreightCar_], @"undefined division car, source not of this division");

	[[myCargo_ source] setDivision: nil];
	[[myCargo_ destination] setDivision: @"ATSF"];
	// Car is undefined, source is undefined so we should use it.
	STAssertTrue([carAssigner_ cargo:myCargo_ appropriateForCar:myFreightCar_], @"undefined division car, destination not of this division");

	[[myCargo_ source] setDivision: @"ATSF"];
	[[myCargo_ destination] setDivision: @"ATSF"];
	// Car is undefined, source and destination not here.
	STAssertTrue([carAssigner_ cargo:myCargo_ appropriateForCar:myFreightCar_], @"undefined division car, cargo src, dest not of this division");
}

- (void) testCarAssignerCarForeignDivision {
	[myFreightCar_ setHomeDivision: @"ATSF"];
	
	STAssertEqualObjects([myFreightCar_ homeDivision], @"ATSF", @"Check foreign car has foreign division");
	STAssertNil([[myCargo_ source] division], @"Check cargo source division unset");
	STAssertEqualObjects([[myCargo_ destination] division], nil, @"Check cargo destination division unset");


	// Car isn't of this division, but everything else is undefined.  Should be a good match.
	STAssertTrue([carAssigner_ cargo: myCargo_ appropriateForCar: myFreightCar_], @"car foreign, cargo doesn't care");
	
	[[myCargo_ source] setDivision: @"ATSF"];
	// Car is foreign road, source is foreign.  We should use it.
	STAssertTrue([carAssigner_ cargo: myCargo_ appropriateForCar: myFreightCar_], @"car and source are both same foreign division");

	// Car isn't of this division, destination is same foreign division, use.
	[[myCargo_ source] setDivision: nil];
	[[myCargo_ destination] setDivision: @"ATSF"];
	// Car is home-road, source is here so we should use it
	STAssertTrue([carAssigner_ cargo: myCargo_ appropriateForCar: myFreightCar_], @"car and destination are same division");
	
	[[myCargo_ source] setDivision: @"ATSF"];
	[[myCargo_ destination] setDivision: @"ATSF"];
	// Car is foreign, source and destination same.  Use.
	STAssertTrue([carAssigner_ cargo:myCargo_ appropriateForCar:myFreightCar_], @"car, source, dest all the same.");
}

- (void) testCarAssignerCarMismatchDivision {
	[myFreightCar_ setHomeDivision: @"BN"];
	
	STAssertEqualObjects([myFreightCar_ homeDivision], @"BN", @"Check foreign car has foreign division");
	STAssertNil([[myCargo_ source] division], @"Check cargo source division unset");
	STAssertNil([[myCargo_ destination] division], @"Check cargo destination division unset");
	
	
	// Car isn't of this division, but everything else doesn't care.  Should be a good match.
	STAssertTrue([carAssigner_ cargo: myCargo_ appropriateForCar: myFreightCar_], @"car foreign, cargo doesn't care");
	
	[[myCargo_ source] setDivision: @"ATSF"];
	// Car is foreign road, source is foreign.  We should use it.
	STAssertTrue([carAssigner_ cargo: myCargo_ appropriateForCar: myFreightCar_], @"car foreign, destination doesn't care.");
	
	// Car isn't of this division, destination is same foreign division, use.
	[[myCargo_ source] setDivision: nil];
	[[myCargo_ destination] setDivision: @"ATSF"];
	// Car is home-road, source is here so we should use it
	STAssertTrue([carAssigner_ cargo: myCargo_ appropriateForCar: myFreightCar_], @"car foreign, source doesn't care.");
	
	[[myCargo_ source] setDivision: @"ATSF"];
	[[myCargo_ destination] setDivision: @"ATSF"];
	// Car is foreign, source and destination same.  Use.
	STAssertFalse([carAssigner_ cargo:myCargo_ appropriateForCar:myFreightCar_], @"car is foreign, and source/dest are different division.");
}

// Do we correctly just mark the cargo as loaded if the car's already there?
- (void) testFreightCarAutoLoadedIfAtSource {
	[myFreightCar_ setCurrentLocation: [self industryAtStation: @"A"]];
	
	CarAssigner *myCarAssigner = [[CarAssigner alloc] initWithUnassignedCars: [NSArray arrayWithObject: myFreightCar_]];
	[myCarAssigner autorelease];
		
	STAssertEqualObjects([myCarAssigner assignedCarForCargo:myCargo_], myFreightCar_, @"Test car is correctly assigned to cargo");
	STAssertTrue([myFreightCar_ isLoaded], @"Test cargo is marked as loaded because we're already there.");
}

// Do we mark the cargo as loaded if the car's already there and we're in staging?
- (void) testFreightCarNotAutoLoadedIfAtSourceInStaging {
	[[entireLayout_ stationWithName: @"A"] setIsStaging: YES];
	[self makeYardAtStation: @"A"];
	[myFreightCar_ setCurrentLocation: [self yardAtStation: @"A"]];
	
	CarAssigner *myCarAssigner = [[CarAssigner alloc] initWithUnassignedCars: [NSArray arrayWithObject: myFreightCar_]];
	[myCarAssigner autorelease];
	
	STAssertEqualObjects([myCarAssigner assignedCarForCargo: myCargo_], myFreightCar_, @"Test car is correctly assigned to cargo");
	STAssertFalse([myFreightCar_ isLoaded], @"Test cargo should be not marked as loaded because it can be moved.");
}

// Do we correctly just mark the cargo as loaded if the car's already there and we're in staging?
- (void) testFreightCarAutoLoadedIfAtSourceInStagingAndCarInYard {
	[[entireLayout_ stationWithName: @"A"] setIsStaging: YES];
	[self makeYardAtStation: @"A"];
	[myFreightCar_ setCurrentLocation: [self yardAtStation: @"A"]];
	
	CarAssigner *myCarAssigner = [[CarAssigner alloc] initWithUnassignedCars: [NSArray arrayWithObject: myFreightCar_]];
	[myCarAssigner autorelease];
	
	STAssertEqualObjects([myCarAssigner assignedCarForCargo:myCargo_], myFreightCar_, @"Test car is correctly assigned to cargo");
	STAssertFalse([myFreightCar_ isLoaded], @"Test cargo is not marked as loaded because it can be moved in staging.");
}

// Do we correctly just mark the cargo as loaded if the car's already there and we're in staging?
- (void) testFreightCarNotAutoLoadedIfAtSourceInStagingAndCarAtOtherStaging {
	[[entireLayout_ stationWithName: @"A"] setIsStaging: YES];
	[[entireLayout_ stationWithName: @"C"] setIsStaging: YES];
	[myFreightCar_ setCurrentLocation: [self industryAtStation: @"C"]];
	
	CarAssigner *myCarAssigner = [[CarAssigner alloc] initWithUnassignedCars: [NSArray arrayWithObject: myFreightCar_]];
	[myCarAssigner autorelease];
	
	STAssertEqualObjects([myCarAssigner assignedCarForCargo:myCargo_], myFreightCar_, @"Test car is correctly assigned to cargo");
	STAssertFalse([myFreightCar_ isLoaded], @"Test cargo is marked as loaded because we're already there.");
}

// Do we correctly just mark the cargo as loaded in C because it's staging and load comes from offline?
- (void) testFreightCarAutoLoadedIfAtSourceOffline {
	[[entireLayout_ stationWithName: @"A"] setIsOffline: YES];
	[[entireLayout_ stationWithName: @"C"] setIsStaging: YES];
	[myFreightCar_ setCurrentLocation: [self industryAtStation: @"C"]];
	
	CarAssigner *myCarAssigner = [[CarAssigner alloc] initWithUnassignedCars: [NSArray arrayWithObject: myFreightCar_]];
	[myCarAssigner autorelease];
	
	STAssertEqualObjects([myCarAssigner assignedCarForCargo:myCargo_], myFreightCar_, @"Test car is correctly assigned to cargo");
	STAssertTrue([myFreightCar_ isLoaded], @"Test cargo is marked as loaded because we're already there.");
}


// Do we correctly mark cargo as unloaded if car isn't at correct site?
- (void) testFreightCarNotLoadedAtStart {
	[myFreightCar_ setCurrentLocation: [self industryAtStation: @"B"]];
	
	CarAssigner *myCarAssigner = [[CarAssigner alloc] initWithUnassignedCars: [NSArray arrayWithObject: myFreightCar_]];
	[myCarAssigner autorelease];
	
	STAssertEqualObjects([myCarAssigner assignedCarForCargo:myCargo_], myFreightCar_, @"Test car is correctly assigned to cargo");
	STAssertFalse([myFreightCar_ isLoaded], @"Test cargo is marked as loaded because we're already there.");
}

- (void) testHandlesIncompleteCargoSafely {
	// TODO(bowdidge): Bad test.  Incomplete cargos shouldn't get passed to assignedCarForCargo.
	[myFreightCar_ setCurrentLocation: [self industryAtStation: @"A"]];
	CarAssigner *myCarAssigner = [[CarAssigner alloc] initWithUnassignedCars: [NSArray arrayWithObject: myFreightCar_]];
	[myCarAssigner autorelease];
	Cargo *incompleteCargo = [self makeCargo: @"a to b"];
	// This shouldn't crash.
	STAssertTrue([myCarAssigner cargo:incompleteCargo appropriateForCar:myFreightCar_], @"car foreign, cargo doesn't care");
	STAssertEqualObjects([myCarAssigner assignedCarForCargo: incompleteCargo], myFreightCar_, @"Find assigned car with incomplete cargo.");
	STAssertNotNil([myFreightCar_ cargo], @"Cargo assigned");
	STAssertFalse([myFreightCar_ isLoaded], @"Cargo should not be loaded.");
}

// TODO(bowdidge): Move to freight car test eventually.
- (void) testFreightCarHomeDivision {
	STAssertNil([myFreightCar_ homeDivision], @"Check division starts empty.");
	
	[myFreightCar_ setHomeDivision: @"BN"];
	STAssertEqualObjects([myFreightCar_ homeDivision], @"BN", @"Check home division is settable.");
	
	[myFreightCar_ setHomeDivision: @"Here"];
	STAssertEqualObjects([myFreightCar_ homeDivision], @"Here", @"Check setting home division to Here works.");

	
	[myFreightCar_ setHomeDivision: @""];
	STAssertNil([myFreightCar_ homeDivision], @"Check setting home division to empty string works.");

	[myFreightCar_ setHomeDivision: @" "];
	STAssertNil([myFreightCar_ homeDivision], @"Check setting home division to spaces works.");
}

- (void) testSameCarNotAssignedEveryTime {
	[myFreightCar_ setCargo: nil];
	[myFreightCar_ setIsLoaded: YES];
	[myFreightCar_ setCurrentLocation: [self industryAtStation: @"A"]];

	FreightCar *fc2 = [self makeFreightCarWithReportingMarks: FREIGHT_CAR_4];
	[fc2 setCargo: nil];
	[fc2 setIsLoaded: YES];
	[fc2 setCurrentLocation: [self industryAtStation: @"A"]];

	MockRandomNumberGenerator *generator = [[[MockRandomNumberGenerator alloc] init] autorelease];
	[generator setNumbers: [NSArray arrayWithObjects: [NSNumber numberWithInt: 0], [NSNumber numberWithInt: 1], nil]];
	 
	CarAssigner *myCarAssigner = [[CarAssigner alloc] initWithUnassignedCars: [NSArray arrayWithObjects: myFreightCar_, fc2, nil]];
	// Make sure the two cars both get picked.
	STAssertEquals(fc2, [myCarAssigner assignedCarForCargo:myCargo_], @"");
	STAssertEquals(myFreightCar_, [myCarAssigner assignedCarForCargo:myCargo_], @"");
	STAssertNil([myCarAssigner assignedCarForCargo:myCargo_], @"");
}

@end
