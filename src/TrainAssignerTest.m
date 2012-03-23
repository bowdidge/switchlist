//
//
//  TrainAssignerTest.m
//  SwitchList
//
//  Created by bowdidge on 10/27/10.
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

#import "TrainAssignerTest.h"

#import "Cargo.h"
#import "EntireLayout.h"
#import "FreightCar.h"
#import "Industry.h"
#import "Place.h"
#import "ScheduledTrain.h"
#import "TrainAssigner.h"
#import "Yard.h"

#import "stdlib.h"

// Tests for TrainAssigner class, the core algorithm for SwitchList.
@implementation TrainAssignerTest

NSString *FREIGHT_CAR_1 = @"WP 1";
NSString *FREIGHT_CAR_2 = @"UP 2";

- (void) setUp {
	[super setUp];
	[self makeThreeStationLayout];
	xmMovingBToC_ = [self makeFreightCarWithReportingMarks: FREIGHT_CAR_1];
	[xmMovingBToC_ setCarTypeRel: [entireLayout_ carTypeForName: @"XM"]];
	[xmMovingBToC_ setLength: [NSNumber numberWithInt: 40]];
	
	xaMovingAToB_ = [self makeFreightCarWithReportingMarks: FREIGHT_CAR_2];
	[xaMovingAToB_ setCarTypeRel: [entireLayout_ carTypeForName: @"XA"]];
	[xaMovingAToB_ setLength: [NSNumber numberWithInt: 50]];

	xmMovingAToB_ = [self makeFreightCarWithReportingMarks: FREIGHT_CAR_2];
	[xmMovingAToB_ setCarTypeRel: [entireLayout_ carTypeForName: @"XM"]];
	[xmMovingAToB_ setLength: [NSNumber numberWithInt: 40]];
}

	
// Creates a sample short train moving only from A to B, and
// defines two cargos, one going from B to C, and the other from A to B.
- (ScheduledTrain*) makeShortTrain {
	ScheduledTrain *myTrain = [self makeTrainWithName: @"MyTrain"];
	[myTrain setStops: @"A,B"];
	[self setTrain: myTrain acceptsCarTypes: @"XM"];

	STAssertEqualsInt(2, [[myTrain stationStopObjects] count], @"Wrong number of station stops");
	STAssertEqualObjects(@"A", [[[myTrain stationStopObjects] objectAtIndex: 0] name], @"A missing");
	STAssertEqualObjects(@"B", [[[myTrain stationStopObjects] objectAtIndex: 1] name], @"B missing");

	Cargo *c1 = [self makeCargo: @"b to c"];
	[c1 setSource: [self industryAtStation: @"B"]];
	[c1 setDestination: [self industryAtStation: @"C"]];
	[c1 setCarTypeRel: [entireLayout_ carTypeForName: @"XM"]];
	[xmMovingBToC_ setCargo: c1];
	[xmMovingBToC_ setCurrentLocation: [self industryAtStation: @"B"]];

	Cargo *c2 = [self makeCargo: @"a to b"];
	[c2 setSource: [self industryAtStation: @"A"]];
	[c2 setDestination: [self industryAtStation: @"B"]];
	[c2 setCarTypeRel: [entireLayout_ carTypeForName: @"XA"]];
	[xaMovingAToB_ setCargo: c2];
	[xaMovingAToB_ setCurrentLocation: [self industryAtStation: @"A"]];

	Cargo *c3 = [self makeCargo: @"a to b"];
	[c3 setSource: [self industryAtStation: @"A"]];
	[c3 setDestination: [self industryAtStation: @"B"]];
	[c3 setCarTypeRel: [entireLayout_ carTypeForName: @"XM"]];
	[xmMovingAToB_ setCargo: c3];
	[xmMovingAToB_ setCurrentLocation: [self industryAtStation: @"A"]];
	return myTrain;
}

- (void) testTrainServingStationName {
	[self makeShortTrain];
	
	TrainAssigner *assigner = [[TrainAssigner alloc] initWithLayout: entireLayout_  useDoors: NO];
	STAssertEqualObjects([[assigner trainServingStation: [entireLayout_ stationWithName: @"A"] acceptingCar: xmMovingBToC_] name],
						 @"MyTrain",
						 @"Should pick up fc1 at A");
	STAssertNil([assigner trainServingStation: [entireLayout_ stationWithName: @"A"] acceptingCar: xaMovingAToB_], @"FC2 wrong car type");

	STAssertNil([assigner trainServingStation: [entireLayout_ stationWithName: @"C"] acceptingCar: xmMovingBToC_], @"No train serves C");
	STAssertNil([assigner trainServingStation: [entireLayout_ stationWithName: @"C"] acceptingCar: xaMovingAToB_], @"No train serves C");
	STAssertEqualsInt(0, [[assigner errors] count], @"Unexpected errors from TrainAssigner!");
	[assigner release];
}

- (void) testTrainBetweenStationName {
	[self makeShortTrain];

	TrainAssigner *assigner = [[TrainAssigner alloc] initWithLayout: entireLayout_ useDoors: NO];
	STAssertEqualObjects([[assigner trainBetweenStation: [entireLayout_ stationWithName: @"A"] andStation: [entireLayout_ stationWithName: @"B"] acceptingCar: xmMovingBToC_] name],
						 @"MyTrain", @"fc1 is right car type");
	STAssertNil([assigner trainBetweenStation: [entireLayout_ stationWithName: @"A"] andStation: [entireLayout_ stationWithName: @"B"] acceptingCar: xaMovingAToB_],
				@"fc2 not accepted on train");

	STAssertNil([assigner trainBetweenStation: [entireLayout_ stationWithName: @"A"] andStation: [entireLayout_ stationWithName: @"A"] acceptingCar: xmMovingBToC_],
				@"train doesn't go there.");
	STAssertNil([assigner trainBetweenStation: [entireLayout_ stationWithName: @"A"] andStation: [entireLayout_ stationWithName: @"A"] acceptingCar: xaMovingAToB_],
				@"train doesn't go there.");
		
	STAssertNil([assigner trainBetweenStation: [entireLayout_ stationWithName: @"A"] andStation: [entireLayout_ stationWithName: @"A"] acceptingCar: xmMovingBToC_],
				@"train doesn't go there.");
	STAssertNil([assigner trainBetweenStation: [entireLayout_ stationWithName: @"A"] andStation: [entireLayout_ stationWithName: @"C"] acceptingCar: xaMovingAToB_],
				@"train doesn't go there.");
	STAssertEqualsInt(0, [[assigner errors] count], @"Unexpected errors from TrainAssigner!");
	[assigner release];
}

- (void) testTrainServingStationName2 {
	ScheduledTrain *myTrain1 = [self makeTrainWithName: @"Train 1"];
	[myTrain1 setStops: @"A,B"];
	[self setTrain: myTrain1 acceptsCarTypes: @"XM"];

	ScheduledTrain *myTrain2 = [self makeTrainWithName: @"Train 2"];
	[myTrain2 setStops: @"A,B,C"];
	[self setTrain: myTrain2 acceptsCarTypes: @"XA"];
	
	[xmMovingBToC_ setCurrentLocation: [self industryAtStation: @"A"]];
	[xaMovingAToB_ setCurrentLocation: [self industryAtStation: @"A"]];

	
	Cargo *c1 = [self makeCargo: @"a to b"];
	[c1 setSource: [self industryAtStation: @"A"]];
	[c1 setDestination: [self industryAtStation: @"B"]];
	[c1 setCarTypeRel: [entireLayout_ carTypeForName: @"XM"]];
	[xmMovingBToC_ setCargo: c1];
	
	Cargo *c2 = [self makeCargo: @"a to c"];
	[c2 setSource: [self industryAtStation: @"A"]];
	[c2 setDestination: [self industryAtStation: @"C"]];
	[c2 setCarTypeRel: [entireLayout_ carTypeForName: @"XA"]];
	[xaMovingAToB_ setCargo: c2];
	
	TrainAssigner *assigner = [[TrainAssigner alloc] initWithLayout: entireLayout_ useDoors: NO];
	STAssertEqualObjects([assigner trainServingStation: [entireLayout_ stationWithName: @"A"] acceptingCar: xmMovingBToC_], myTrain1, @"fc1 should go to A");
	STAssertEqualObjects([assigner trainServingStation: [entireLayout_ stationWithName: @"B"] acceptingCar: xmMovingBToC_], myTrain1, @"fc1 should go to B");
	STAssertNil([assigner trainServingStation: [entireLayout_ stationWithName: @"C"] acceptingCar: xmMovingBToC_], @"fc1 can't get to C");
	
	STAssertEqualObjects([assigner trainServingStation: [entireLayout_ stationWithName: @"A"] acceptingCar: xaMovingAToB_], myTrain2, @"fc2 can go to A");
	STAssertEqualObjects([assigner trainServingStation: [entireLayout_ stationWithName: @"B"] acceptingCar: xaMovingAToB_], myTrain2, @"fc2 can go to B");
	STAssertEqualObjects([assigner trainServingStation: [entireLayout_ stationWithName: @"C"] acceptingCar: xaMovingAToB_], myTrain2, @"fc2 can go to C");	
	STAssertEqualsInt(0, [[assigner errors] count], @"Unexpected errors from TrainAssigner!");
	[assigner release];
}

// Create a pair of trains, one accepting XM cars, the other XA cars, and make sure two freight cars go to the
// correct cars.
- (void) testAssignCarsToTrains {
	ScheduledTrain *myTrain1 = [self makeTrainWithName: @"Train 1"];
	[myTrain1 setStops: @"A,B"];
	[self setTrain: myTrain1 acceptsCarTypes: @"XM"];
	
	ScheduledTrain *myTrain2 = [self makeTrainWithName: @"Train 2"];
	[myTrain2 setStops: @"A,B,C"];
	[self setTrain: myTrain2 acceptsCarTypes: @"XA"];
	
	[xmMovingBToC_ setCurrentLocation: [self industryAtStation: @"A"]];
	[xaMovingAToB_ setCurrentLocation: [self industryAtStation: @"A"]];
	
	Cargo *c1 = [self makeCargo: @"a to b"];
	[c1 setSource: [self industryAtStation: @"A"]];
	[c1 setDestination: [self industryAtStation: @"B"]];
	STAssertNotNil([c1 source], @"cargo source is nil");
	[c1 setCarTypeRel: [entireLayout_ carTypeForName: @"XM"]];
	[xmMovingBToC_ setCargo: c1];
	[xmMovingBToC_ setIsLoaded: YES];
	
	Cargo *c2 = [self makeCargo: @"a to c"];
	[c2 setSource: [self industryAtStation: @"A"]];
	[c2 setDestination: [self industryAtStation: @"C"]];
	[c2 setCarTypeRel: [entireLayout_ carTypeForName: @"XA"]];
	[xaMovingAToB_ setCargo: c2];
	[xaMovingAToB_ setIsLoaded: YES];
	
	TrainAssigner *assigner = [[TrainAssigner alloc] initWithLayout: entireLayout_ useDoors: NO];
	[assigner assignCarsToTrains: [NSArray arrayWithObjects: myTrain1, myTrain2, nil]];
	
	STAssertEquals(myTrain1, [xmMovingBToC_ currentTrain], @"fc1 not assigned");
	STAssertEquals(myTrain2, [xaMovingAToB_ currentTrain], @"fc2 not assigned");
	STAssertEqualsInt(0, [[assigner errors] count], @"Unexpected errors from TrainAssigner!");
	[assigner release];
}

// Make sure a single car can move farther than any one train can go.
- (void) testMultiStepMove {
	ScheduledTrain *myTrain1 = [self makeTrainWithName: @"Train 1"];
	[myTrain1 setStops: @"A,B"];
	[self setTrain: myTrain1 acceptsCarTypes: @"XM"];
	
	ScheduledTrain *myTrain2 = [self makeTrainWithName: @"Train 2"];
	[myTrain2 setStops: @"B,C"];
	[self setTrain: myTrain1 acceptsCarTypes: @"XM"];
	
	[xmMovingBToC_ setCurrentLocation: [self industryAtStation: @"A"]];
	
	Cargo *c1 = [self makeCargo: @"a to c"];
	[c1 setSource: [self industryAtStation: @"A"]];
	[c1 setDestination: [self industryAtStation: @"C"]];
	[c1 setCarTypeRel: [entireLayout_ carTypeForName: @"XM"]];
	[xmMovingBToC_ setCargo: c1];
	[xmMovingBToC_ setIsLoaded: YES];
	
	TrainAssigner *assigner = [[TrainAssigner alloc] initWithLayout: entireLayout_ useDoors: NO];
	[assigner assignCarsToTrains: [NSArray arrayWithObjects: myTrain1, myTrain2, nil]];
	STAssertEqualObjects([xmMovingBToC_ currentTrain], myTrain1, @"fc1 not assigned");
	
	// Ok, run that train.
	[xmMovingBToC_ moveOneStep];
	STAssertEqualObjects([[xmMovingBToC_ currentLocation] name], @"B-yard", @"Car didn't make first step.");
	
	assigner = [[TrainAssigner alloc] initWithLayout: entireLayout_ useDoors: NO];
	[assigner assignCarsToTrains: [NSArray arrayWithObjects: myTrain1, myTrain2, nil]];
	
	STAssertEqualObjects([[xmMovingBToC_ nextStop] name], @"C-industry", @"Wrong nextStop");
	STAssertEqualObjects([[xmMovingBToC_ nextIndustry] name], @"C-industry", @"Wrong nextIndustry");
	
	[xmMovingBToC_ moveOneStep];
	STAssertEqualObjects([[xmMovingBToC_ currentLocation] name], @"C-industry", @"Car didn't make second step.");
	
	STAssertEqualsInt(0, [[assigner errors] count], @"Unexpected errors from TrainAssigner!");
	[assigner release];
}

// Make sure an empty car gets picked up.
- (void) testEmptyMove {
	ScheduledTrain *myTrain1 = [self makeTrainWithName: @"Train 1"];

	[myTrain1 setStops: @"A,B"];
	[self setTrain: myTrain1 acceptsCarTypes: @"XM"];

	ScheduledTrain *myTrain2 = [self makeTrainWithName: @"Train 2"];
	[myTrain2 setStops: @"B,C"];
	[self setTrain: myTrain2 acceptsCarTypes: @"XM"];

	
	[xmMovingBToC_ setHomeDivision: @"B"];
	[xmMovingBToC_ setCurrentLocation: [self industryAtStation: @"A"]];

	TrainAssigner *assigner = [[TrainAssigner alloc] initWithLayout: entireLayout_ useDoors: NO];

	[assigner assignCarsToTrains: [NSArray arrayWithObjects: myTrain1, myTrain2, nil]];

	STAssertEqualObjects([xmMovingBToC_ currentTrain], myTrain1, @"fc1 not assigned");
	STAssertEqualObjects([[xmMovingBToC_ nextStop] name], @"B-yard", @"fc1 not assigned");
	STAssertEqualsInt(0, [[assigner errors] count], @"Unexpected errors from TrainAssigner!");
	[assigner release];
}

// Do we correctly treat an empty car type in a train as "Any"?
- (void) testEmptyCarTypeCarAndTrain {
	ScheduledTrain *myTrain1 = [self makeTrainWithName: @"Train 1"];
	[myTrain1 setStops: @"A,B,C"];
	[self setTrain: myTrain1 acceptsCarTypes: @""];
	
	[xmMovingBToC_ setCurrentLocation: [self industryAtStation: @"A"]];

	Cargo *c1 = [self makeCargo: @"a to b"];
	[c1 setSource: [self industryAtStation: @"A"]];
	[c1 setDestination: [self industryAtStation: @"B"]];
	[c1 setCarTypeRel: nil];
	[xmMovingBToC_ setCargo: c1];
	[xmMovingBToC_ setIsLoaded: YES];

	
	TrainAssigner *assigner = [[TrainAssigner alloc] initWithLayout: entireLayout_ useDoors: NO];
	[assigner assignCarsToTrains: [NSArray arrayWithObjects: myTrain1, nil]];
	STAssertEquals(myTrain1, [xmMovingBToC_ currentTrain] , @"Freight car 1 not on train1.");
	STAssertEqualsInt(0, [[assigner errors] count], @"Unexpected errors from TrainAssigner!");
	[assigner release];

}

// Do we correctly treat an empty car type in a train as "Any"?
- (void) testNoMoveCarAtCorrectLocation {
	ScheduledTrain *myTrain1 = [self makeTrainWithName: @"Train 1"];
	[myTrain1 setStops: @"A,B,C"];
	[self setTrain: myTrain1 acceptsCarTypes: @"XM"];
	
	[xmMovingBToC_ setCurrentLocation: [self industryAtStation: @"A"]];
	
	Cargo *c1 = [self makeCargo: @"a to b"];
	[c1 setSource: [self industryAtStation: @"A"]];
	[c1 setDestination: [self industryAtStation: @"B"]];
	[c1 setCarTypeRel: nil];
	[xmMovingBToC_ setCargo: c1];
	[xmMovingBToC_ setIsLoaded: NO];
	
	[xaMovingAToB_ setCargo: c1];
	[xaMovingAToB_ setIsLoaded: YES];
	[xaMovingAToB_ setCurrentLocation: [self industryAtStation: @"B"]];
	
	
	TrainAssigner *assigner = [[TrainAssigner alloc] initWithLayout: entireLayout_ useDoors: NO];
	[assigner assignCarsToTrains: [NSArray arrayWithObjects: myTrain1, nil]];
	STAssertNil([xmMovingBToC_ currentTrain], @"Freight car 1 should not be on train1.");
	STAssertNil([xaMovingAToB_ currentTrain], @"Freight car 2 should not be on train1.");
	STAssertEqualsInt(0, [[assigner errors] count], @"Unexpected errors from TrainAssigner: %@", [assigner errors]);
	[assigner release];
	
}

// Do we correctly treat an empty car type in a train as "Any"?
- (void) testEmptyCarTypeInCar {
	ScheduledTrain *myTrain1 = [self makeTrainWithName: @"Train 1"];
	[myTrain1 setStops: @"A,B,C"];
	[self setTrain: myTrain1 acceptsCarTypes: @"XM"];
	
	[xmMovingBToC_ setCurrentLocation: [self industryAtStation: @"A"]];
	
	Cargo *c1 = [self makeCargo: @"a to b"];
	[c1 setSource: [self industryAtStation: @"A"]];
	[c1 setDestination: [self industryAtStation: @"B"]];
	[c1 setCarTypeRel: nil];
	[xmMovingBToC_ setCargo: c1];
	[xmMovingBToC_ setIsLoaded: YES];
	
	
	TrainAssigner *assigner = [[TrainAssigner alloc] initWithLayout: entireLayout_ useDoors: NO];
	[assigner assignCarsToTrains: [NSArray arrayWithObjects: myTrain1, nil]];
	STAssertEquals(myTrain1, [xmMovingBToC_ currentTrain], @"Freight car 1 not on train1.");
	STAssertEqualsInt(0, [[assigner errors] count], @"Unexpected errors from TrainAssigner: %@", [assigner errors]);
	[assigner release];
}

// Do we correctly treat an empty car type in a train as "Any"?
- (void) testEmptyCarTypeInTrain {
	ScheduledTrain *myTrain1 = [self makeTrainWithName: @"Train 1"];
	[myTrain1 setStops: @"A,B,C"];
	[self setTrain: myTrain1 acceptsCarTypes: @""];
	
	[xmMovingBToC_ setCurrentLocation: [self industryAtStation: @"A"]];
	
	Cargo *c1 = [self makeCargo: @"a to b"];
	[c1 setSource: [self industryAtStation: @"A"]];
	[c1 setDestination: [self industryAtStation: @"B"]];
	[c1 setCarTypeRel: [entireLayout_ carTypeForName: @"XM"]];
	[xmMovingBToC_ setCargo: c1];
	[xmMovingBToC_ setIsLoaded: YES];
	
	
	TrainAssigner *assigner = [[TrainAssigner alloc] initWithLayout: entireLayout_ useDoors: NO];
	[assigner assignCarsToTrains: [NSArray arrayWithObjects: myTrain1, nil]];
	STAssertEquals(myTrain1, [xmMovingBToC_ currentTrain], @"Freight car 1 not on train1.");
	STAssertEqualsInt(0, [[assigner errors] count], @"Unexpected errors from TrainAssigner: %@", [assigner errors]);
	[assigner release];
}

// Make sure that we don't try to switch things backwards.
- (void) testTrainDirectionRespected2 {
	ScheduledTrain *myTrain1 = [self makeTrainWithName: @"Train 1"];
	[myTrain1 setStops: @"A,B,C,A"];
	[self setTrain: myTrain1 acceptsCarTypes: @"XM"];
	
	[xmMovingBToC_ setCurrentLocation: [self industryAtStation: @"C"]];
	
	Cargo *c1 = [self makeCargo: @"C to B"];
	[c1 setSource: [self industryAtStation: @"C"]];
	[c1 setDestination: [self industryAtStation: @"B"]];
	[c1 setCarTypeRel: [entireLayout_ carTypeForName: @"XM"]];
	[xmMovingBToC_ setCargo: c1];
	[xmMovingBToC_ setIsLoaded: YES];
	
	
	TrainAssigner *assigner = [[TrainAssigner alloc] initWithLayout: entireLayout_ useDoors: NO];
	[assigner assignCarsToTrains: [NSArray arrayWithObjects: myTrain1, nil]];
	// Make sure we don't assign it to this train - from C, we can only go to A in one step.
	// We need to go to B to deliver.
	STAssertNil([xmMovingBToC_ currentTrain], @"Make sure car not assigned to train going other direction.");
	STAssertEqualObjects([[xmMovingBToC_ nextStop] name], @"B-industry", @"fc1 not assigned");
	
	// Expect one error - WP 1 has no route from C to B.
	STAssertTrue(1 == [[assigner errors] count], @"Unexpected errors from TrainAssigner: %@", [assigner errors]);
	[assigner release];
}

// Make sure that we don't try to switch things backwards.
- (void) testTrainDirectionRespected3 {
	ScheduledTrain *myTrain1 = [self makeTrainWithName: @"Train 1"];
	[myTrain1 setStops: @"A,B,C,A"];
	[self setTrain: myTrain1 acceptsCarTypes: @"XM"];
	
	[xmMovingBToC_ setCurrentLocation: [self industryAtStation: @"C"]];
	
	Cargo *c1 = [self makeCargo: @"B to A"];
	[c1 setSource: [self industryAtStation: @"B"]];
	[c1 setDestination: [self industryAtStation: @"A"]];
	[c1 setCarTypeRel: [entireLayout_ carTypeForName: @"XM"]];
	[xmMovingBToC_ setCargo: c1];
	[xmMovingBToC_ setIsLoaded: NO];
	
	
	TrainAssigner *assigner = [[TrainAssigner alloc] initWithLayout: entireLayout_ useDoors: NO];
	[assigner assignCarsToTrains: [NSArray arrayWithObjects: myTrain1, nil]];
	// Make sure we don't assign it to this train - from C, we can only go to A in one step.
	// We need to go back to B to load.
	STAssertNil([xmMovingBToC_ currentTrain], @"Make sure car not assigned to train going other direction.");
	STAssertEqualObjects([[xmMovingBToC_ nextStop] name], @"B-industry", @"fc1 not assigned");

	// Expect one error - WP 1 has no route from C to B.
	STAssertEqualsInt(1, [[assigner errors] count], @"Unexpected errors from TrainAssigner: %@", [assigner errors]);
	[assigner release];
}

@end
@interface TrainAssignerTestNoYards : LayoutTest {
	FreightCar *freightCar1_;
	FreightCar *freightCar2_;
};
@end
@implementation TrainAssignerTestNoYards
- (void) setUp {
	[super setUp];
	[self makeThreeStationLayoutNoYards];
	freightCar1_ = [self makeFreightCarWithReportingMarks: FREIGHT_CAR_1];
	[freightCar1_ setCarTypeRel: [entireLayout_ carTypeForName: @"XM"]];
	
	freightCar2_ = [self makeFreightCarWithReportingMarks: FREIGHT_CAR_2];
	[freightCar2_ setCarTypeRel: [entireLayout_ carTypeForName: @"XA"]];
}

- (BOOL) checkGraph: (NSDictionary*) reachabilityGraph linksStationName: (NSString*) fromName
					  toStationName: (NSString*) toName {
	Place *from = [entireLayout_ stationWithName: fromName];
	Place *to = [entireLayout_ stationWithName: toName];
	return ([[reachabilityGraph objectForKey: [from objectID]] containsObject: to]);
}
	
// If we have no yards, does the reachability graph realize we can only go where trains go?
- (void) testStationReachabilityGraph {
	ScheduledTrain *myTrain1 = [self makeTrainWithName: @"Train 1"];
	[myTrain1 setStops: @"A,B"];
	[self setTrain: myTrain1 acceptsCarTypes: @"XM"];
	
	ScheduledTrain *myTrain2 = [self makeTrainWithName: @"Train 2"];
	[myTrain2 setStops: @"B,C"];
	[self setTrain: myTrain2 acceptsCarTypes: @"XM,XA"];
	
	ScheduledTrain *myTrain3 = [self makeTrainWithName: @"Train 3"];
	[myTrain3 setStops: @"C,A"];
	[self setTrain: myTrain3 acceptsCarTypes: @"T"];

	TrainAssigner *assigner = [[[TrainAssigner alloc] initWithLayout: entireLayout_ useDoors: NO] autorelease];
	
	NSDictionary *graph =[assigner createStationReachabilityGraphForCarType: [entireLayout_ carTypeForName: @"XM"]];

	STAssertTrue([self checkGraph: graph linksStationName: @"A" toStationName: @"B"], @"A and B should be reachable.");
	STAssertTrue([self checkGraph: graph linksStationName: @"B" toStationName: @"C"], @"B and C should be reachable.");
	STAssertFalse([self checkGraph: graph linksStationName: @"A" toStationName: @"C"], @"A and C should not be reachable.");
	STAssertFalse([self checkGraph: graph linksStationName: @"B" toStationName: @"A"], @"B and A should not be reachable.");
	STAssertFalse([self checkGraph: graph linksStationName: @"C" toStationName: @"A"], @"C and A should not be reachable.");
	STAssertFalse([self checkGraph: graph linksStationName: @"A" toStationName: @"A"], @"Shouldn't be reachable from self");
	STAssertFalse([self checkGraph: graph linksStationName: @"B" toStationName: @"B"], @"Shouldn't be reachable from self");
	STAssertFalse([self checkGraph: graph linksStationName: @"C" toStationName: @"C"], @"Shouldn't be reachable from self");

	graph =[assigner createStationReachabilityGraphForCarType: [entireLayout_ carTypeForName: @"XA"]];
	STAssertFalse([self checkGraph: graph linksStationName: @"A" toStationName: @"B"], @"A and B should not be reachable.");
	STAssertTrue([self checkGraph: graph linksStationName: @"B" toStationName: @"C"], @"B and C should not be reachable.");

	// Make sure reachability graph for "don't care" car could go on all three trains.
	graph =[assigner createStationReachabilityGraphForCarType: nil];
	STAssertTrue([self checkGraph: graph linksStationName: @"A" toStationName: @"B"], @"A and B should be reachable.");
	STAssertTrue([self checkGraph: graph linksStationName: @"B" toStationName: @"C"], @"B and C should be reachable.");
	STAssertTrue([self checkGraph: graph linksStationName: @"C" toStationName: @"A"], @"C and A should be reachable.");
}

- (void) testMultiHopPaths {
	ScheduledTrain *myTrain1 = [self makeTrainWithName: @"Train 1"];
	[myTrain1 setStops: @"A,B"];
	[self setTrain: myTrain1 acceptsCarTypes: @"XM"];
	
	ScheduledTrain *myTrain2 = [self makeTrainWithName: @"Train 2"];
	[myTrain2 setStops: @"B,C"];
	[self setTrain: myTrain2 acceptsCarTypes: @"XM"];

	[freightCar1_ setHomeDivision: @"C"];
	[freightCar1_ setCurrentLocation: [self industryAtStation: @"A"]];
	
	TrainAssigner *assigner = [[[TrainAssigner alloc] initWithLayout: entireLayout_ useDoors: NO] autorelease];
	NSArray *route = [assigner routeFrom: [entireLayout_ industryOrYardWithName: @"A-industry"]
									  to: [entireLayout_ industryOrYardWithName: @"B-industry"]
										 forCar:freightCar1_];
	[self checkRoute: route equals: @"A,B"];
	
	// Make sure we can't get from A to C because there is no yard at B.
	NSArray *unreachableRoute = [assigner routeFrom: [entireLayout_ industryOrYardWithName: @"A-industry"]
												 to: [entireLayout_ industryOrYardWithName: @"C-industry"]
													forCar: freightCar1_];
	STAssertEqualsInt(0, [unreachableRoute count],
					  @"Route should have been unreachable instead of %@", unreachableRoute);
}

@end

// Do things still work if no divisions have been set?
// This tests whether a novice user ignoring divisions still might have decent behavior.

@interface TrainAssignerTestNoDivisions : LayoutTest {
	FreightCar *freightCar1_;
	FreightCar *freightCar2_;
};
@end
@implementation TrainAssignerTestNoDivisions
- (void) setUp {
	[super setUp];
	[self makeThreeStationLayoutWithDivisions: NO];
	freightCar1_ = [self makeFreightCarWithReportingMarks: FREIGHT_CAR_1];
	[freightCar1_ setCarTypeRel: [entireLayout_ carTypeForName: @"XM"]];
	
	freightCar2_ = [self makeFreightCarWithReportingMarks: FREIGHT_CAR_2];
	[freightCar2_ setCarTypeRel: [entireLayout_ carTypeForName: @"XA"]];
}
	
- (void) testCarReturnedToAnyYard {
	ScheduledTrain *myTrain1 = [self makeTrainWithName: @"Train 1"];
	[myTrain1 setStops: @"A,B"];
	[self setTrain: myTrain1 acceptsCarTypes: @"XM"];
	[freightCar1_ setCurrentLocation: [self industryAtStation: @"A"]];
	
	// Do we correctly direct freightCar1_ to the yard at B?
	TrainAssigner *assigner = [[TrainAssigner alloc] initWithLayout: entireLayout_ useDoors: NO];
	[assigner autorelease];
	[assigner assignCarsToTrains: [NSArray arrayWithObject: myTrain1]];
	
	// Would the car get routed to the yard?
	NSArray *route = [assigner routeFrom: [entireLayout_ industryOrYardWithName: @"A-industry"]
									  to: [entireLayout_ industryOrYardWithName: @"B-industry"]
										 forCar:freightCar1_]; 
	[self checkRoute: route equals: @"A,B"];
	// Did the car get onto the right train?
	STAssertEquals(myTrain1, [freightCar1_ currentTrain], @"Car not put on train");

	
	// TODO(bowdidge): Shouldn't try to move car when there's no yard for dumping car.
	//STAssertEqualObjects([assigner routeFromStation:@"A" toStation:@"C" forCar:fc1],
	//						 ([NSArray array]),
	//						 @"Should not find route from A to B");
}

// Add test to figure out why Stockton example with no divisions always sends cars to SP.

@end

@interface TrainAssignerTestStocktonExample : LayoutTest {
	FreightCar *freightCar1_;
	Place *C_;
	Place *D_;
	Place *A_;
	Place *E_;
	Place *West_;
	Yard *A_yard_;
	Yard *C_yard_;
	Yard *E_yard_;
	ScheduledTrain *train_;
}
@end
@implementation TrainAssignerTestStocktonExample
- (void) setUp {
	[super setUp];
	[self makeSimpleLayout];
	// Stations are center(a), east ind (b), WP int (c), 
	// west ind (d), SP int (e).
	// Train moves a,b,c,d,e,a.
    A_ = [self makePlaceWithName: @"A"];
	[self makePlaceWithName: @"B"];
	C_ = [self makePlaceWithName: @"C"];
	D_ = [self makePlaceWithName: @"D"];
	E_ = [self makePlaceWithName: @"E"];
	West_ = [self makePlaceWithName: @"West"];
	[West_ setIsOffline: YES];
	
	// Both interchange yards count as staging.
	[C_ setIsStaging: YES];
	[E_ setIsStaging: YES];

	A_yard_ = [self makeYardAtStation: @"A"];
	[A_yard_ setDivision: @"Here"];
	[A_yard_ setAcceptsDivisions: @"Here,SP"];

	C_yard_ = [self makeYardAtStation: @"C"];
	[C_yard_ setDivision: @"WP"];
	[C_yard_ setAcceptsDivisions: @"WP"];
	
	E_yard_ = [self makeYardAtStation: @"E"];
	[E_yard_ setDivision: @"SP"];
	[E_yard_ setAcceptsDivisions: @"SP"];
	
	[[self industryAtStation: @"D"] setDivision: @"Here"];
	
	train_ = [self makeTrainWithName: @"daily"];
	[train_ setStops: @"A,B,C,D,E,A"];
}

- (void) testReachability {
	freightCar1_ = [self makeFreightCarWithReportingMarks: @"WP 1"];
	[freightCar1_ setHomeDivision: @"WP"];
	
	Cargo *c = [self makeCargo: @"canned fruit"];
	[c setSource: [self industryAtStation: @"D"]];
	[c setDestination: [self industryAtStation: @"West"]];
	[freightCar1_ setCargo: c];
	[freightCar1_ setIsLoaded: YES];
	[freightCar1_ setCurrentLocation: [self industryAtStation: @"D"]];
	
	// See what train assigner says.
	TrainAssigner *assigner = [[TrainAssigner alloc] initWithLayout: entireLayout_ useDoors: NO];
	[assigner assignCarsToTrains: [NSArray arrayWithObject: train_]];
	
	// Reachability graphs don't matter much here because we haven't set car types.
	NSLog(@"Reachability is %@", [assigner createStationReachabilityGraphForCarType: nil]);
	NSLog(@"Reachability is %@", [assigner createStationReachabilityGraphForCarType: [entireLayout_ carTypeForName: @"XM"]]);

	STAssertEqualObjects([assigner createStationReachabilityGraphForCarType: nil],
						 [assigner createStationReachabilityGraphForCarType: [entireLayout_ carTypeForName: @"XM"]],
						 @"");
	[assigner release];
}

// If we pick up a WP boxcar from the west industries (D), then the train will
// need to leave the boxcar in A yard for the next train to take to the
// WP interchange (c).  Check the boxcar isn't moved in one step in a way the train
// doesn't move.
// Note that the destination here is an offline destination.
- (void) testFreightCarDestinedOfflineStopsAtYard {
	freightCar1_ = [self makeFreightCarWithReportingMarks: @"WP 1"];
	[freightCar1_ setHomeDivision: @"WP"];
	
	Cargo *c = [self makeCargo: @"canned fruit"];
	[c setSource: [self industryAtStation: @"D"]];
	[c setDestination: [self industryAtStation: @"West"]];
	[freightCar1_ setCargo: c];
	[freightCar1_ setIsLoaded: YES];
	[freightCar1_ setCurrentLocation: [self industryAtStation: @"D"]];
	
	// See what train assigner says.
	TrainAssigner *assigner = [[TrainAssigner alloc] initWithLayout: entireLayout_ useDoors: NO];
	[assigner assignCarsToTrains: [NSArray arrayWithObject: train_]];
	
	// Did the car get onto the right train?
	STAssertEquals(train_, [freightCar1_ currentTrain], @"Car not put on train");

	// E yard is valid here because the cargo is going west to an SP customer.
	STAssertTrue([freightCar1_ nextStop] == [self yardAtStation: @"E"],
				 @"next stop %@ should be E-yard",
				 [[freightCar1_ nextStop] name]);

	// E yard is valid here because the cargo is going west to an SP customer.
	STAssertTrue([freightCar1_ intermediateDestination] == [self yardAtStation: @"E"],
				 @"Intermediate destination %@ should be E-yard",
				 [[freightCar1_ intermediateDestination] name]);
	STAssertTrue([freightCar1_ nextIndustry] == [self industryAtStation: @"West"],
				 @"nextIndustry %@ should be West",
				 [[freightCar1_ nextIndustry] name]);
	[assigner release];
}

// If we pick up an empty WP boxcar from D, then we'll need to take it to A so the
// next train can take it to the WP interchange at C.
// This test differs from the above because there is no cargo so it should go back to WP.
- (void) testEmptyFreightCarDestinedOfflineStopsAtYard {
	freightCar1_ = [self makeFreightCarWithReportingMarks: @"WP 1"];
	[freightCar1_ setHomeDivision: @"WP"];
	[freightCar1_ setCurrentLocation: [self industryAtStation: @"D"]];
	
	// See what train assigner says.
	TrainAssigner *assigner = [[TrainAssigner alloc] initWithLayout: entireLayout_ useDoors: NO];
	[assigner assignCarsToTrains: [NSArray arrayWithObject: train_]];
	
	// Would the car get routed to the yard?
	NSArray *route = [assigner routeFrom: [entireLayout_ industryOrYardWithName: @"D-industry"]
									  to: [entireLayout_ industryOrYardWithName: @"C-industry"]
										 forCar:freightCar1_];
	[self checkRoute: route equals: @"D,A,C"];

	// Did the car get onto the right train?
	STAssertTrue([freightCar1_ currentTrain] == train_, @"Car not put on train");

	// Car should go to A, then C because it's empty and needs to return to WP.
	STAssertTrue([freightCar1_ intermediateDestination] == [self yardAtStation: @"A"],
				 @"Intermediate destination expected to be A-yard, but was %@",
				 [[freightCar1_ intermediateDestination] name]);
	STAssertNil([freightCar1_ nextIndustry],
				@"Next industry should be nil because car is empty.");
}

// If we pick up a WP boxcar from the west industries (D), but don't set any
// divisions, then any staging yard is valid.  Make sure we take the car to the 
// SP interchange at E, or to A
- (void) testEmptyFreightCarNoDivision {
	freightCar1_ = [self makeFreightCarWithReportingMarks: @"WP 1"];
	[freightCar1_ setCurrentLocation: [self industryAtStation: @"D"]];
	
	// See what train assigner says.
	TrainAssigner *assigner = [[TrainAssigner alloc] initWithLayout: entireLayout_ useDoors: NO];
	[assigner assignCarsToTrains: [NSArray arrayWithObject: train_]];
	
	// Did the car get onto the right train?
	STAssertTrue([freightCar1_ currentTrain] == train_, @"Car not put on train");
	
	// Car should go to E or C eventually.  The division isn't set, so either is fine.
	// TODO(bowdidge): Should make this deterministic.
	STAssertTrue(([freightCar1_ intermediateDestination] == [self yardAtStation: @"E"]) ||
				 ([freightCar1_ intermediateDestination] == [self yardAtStation: @"A"]),
				 @"intermediateDestination set to %@, but expected either A-yard or E-yard.",
				 [[freightCar1_ intermediateDestination] name]);
	STAssertNil([freightCar1_ nextIndustry],
				@"nextIndustry should be nil because car is empty.");
}

- (void) checkAssigner: (TrainAssigner*) assigner
	 routesFrom: (NSString*) fromString to: (NSString*) toString forCar: (FreightCar*) fc
			   matches: (NSString*) expected {
	InduYard *from = [entireLayout_ industryOrYardWithName: fromString];
	InduYard *to = [entireLayout_ industryOrYardWithName: toString];
	STAssertFalse([from isOffline],
				  @"Input to routeFromStation should not be offline - car can never be offline.");
	NSArray *route = [assigner routeFrom:from to:to forCar:fc];
	// Expected no route?  Return.
	if (expected == nil && route == nil) return;
	NSMutableArray *resultNames = [NSMutableArray array];
	for (Place *p in route) {
		[resultNames addObject: [p name]];
	}
	NSString *result = [resultNames componentsJoinedByString: @","];
	STAssertTrue([result isEqualToString: expected],
				 @"Expected route '%@', got '%@'", expected, result);
}

// Tests that if the freight car is explicitly going to staging, then we correctly
// route it from D to the yard at A so the next train can take it to the staging
// yard at C.
// Note that the destination here is a staging yard, not an offline destination.
- (void) testFreightCarDestinedForStagingStopsAtYard {
	freightCar1_ = [self makeFreightCarWithReportingMarks: @"WP 1"];
	[freightCar1_ setHomeDivision: @"WP"];
	
	Cargo *c = [self makeCargo: @"canned fruit"];
	[c setSource: [self industryAtStation: @"D"]];
	[c setDestination: [self yardAtStation: @"C"]];
	[freightCar1_ setCargo: c];
	[freightCar1_ setIsLoaded: YES];
	[freightCar1_ setCurrentLocation: [self industryAtStation: @"D"]];
	
	// See what train assigner says.
	TrainAssigner *assigner = [[[TrainAssigner alloc] initWithLayout: entireLayout_ useDoors: NO] autorelease];
	[assigner assignCarsToTrains: [NSArray arrayWithObject: train_]];
	
	// Would the car get routed to the yard?
	[self checkAssigner:assigner 
	  routesFrom:@"D-industry" to:@"C-industry" forCar:freightCar1_ 
				matches: @"D,A,C"];
	
	// Did the car get onto the right train?
	STAssertTrue([freightCar1_ currentTrain] == train_, @"Car not put on train");
	// Car needs to go to A first so it can go to WP staging at C.
	STAssertTrue([freightCar1_ intermediateDestination] == [self yardAtStation: @"A"],
				 @"Intermediate destination %@ should be A-yard",
				 [freightCar1_ intermediateDestination]);
	// NextIndustry should be to C-yard because that's the explicit destination.
	STAssertTrue([freightCar1_ nextIndustry] == [self yardAtStation: @"C"],
				 @"nextIndustry '%@' should be C-yard",
				 [[freightCar1_ nextIndustry] name]);
}

- (void) testRouteNeverReturnsOfflineLocations {
	// TODO(bowdidge) Test [routeFromStation:toStation:forCar:] never returns an offline location.
	freightCar1_ = [self makeFreightCarWithReportingMarks: @"WP 1"];
	[freightCar1_ setHomeDivision: @"WP"];
	[freightCar1_ setCurrentLocation: [self yardAtStation: @"A"]];
	
	TrainAssigner *assigner = [[[TrainAssigner alloc] initWithLayout: entireLayout_ useDoors: NO] autorelease];
	// Route for empty car from A to C?
	[self checkAssigner:assigner routesFrom:@"A-industry" to:@"C-industry" forCar:freightCar1_ matches:@"A,C"];
	[self checkAssigner:assigner routesFrom:@"C-industry" to:@"C-industry" forCar:freightCar1_ matches:@"C"];
	[self checkAssigner:assigner routesFrom:@"E-industry" to:@"West-industry" forCar:freightCar1_ matches:@"E,A,C"];
	[self checkAssigner:assigner routesFrom:@"C-industry" to:@"B-industry" forCar:freightCar1_ matches:@"C,A,B"];
	[self checkAssigner:assigner routesFrom:@"D-industry" to:@"B-industry" forCar:freightCar1_ matches:@"D,A,B"];
	[self checkAssigner:assigner routesFrom:@"E-industry" to:@"B-industry" forCar:freightCar1_ matches:@"E,A,B"];
	[self checkAssigner:assigner routesFrom:@"E-industry" to:@"C-industry" forCar:freightCar1_ matches:@"E,A,C"];
	[self checkAssigner:assigner routesFrom:@"E-industry" to:@"West-industry" forCar:freightCar1_ matches: @"E,A,C"];
	[self checkAssigner:assigner routesFrom:@"A-industry" to:@"West-industry" forCar:freightCar1_ matches:@"A,C"];
	// If we're already in staging, expect to stay.
	[self checkAssigner:assigner routesFrom:@"C-industry" to:@"West-industry" forCar:freightCar1_ matches: @""];
	// TODO(bowdidge): Should be empty.
	[self checkAssigner:assigner routesFrom:@"C-industry" to:@"C-industry" forCar:freightCar1_ matches: @"C"];
}
@end
   
@interface TrainAssignerErrorTest : LayoutTest
@end

@implementation TrainAssignerErrorTest
- (void) makeABALayout {
	[self makeSimpleLayout];
	
    [self makePlaceWithName: @"A"];
    [self makePlaceWithName: @"B"];
	[self industryAtStation: @"A"];
	[self industryAtStation: @"B"];
	
	ScheduledTrain *train = [self makeTrainWithName: @"Train"];
	[train setStops: @"A,B,A"];
}

- (void) setUp {
	[super setUp];
    [self makeABALayout];
}

- (void) tearDown {
   [super tearDown];
}
   
- (void) testNoCrashWithMissingCargoSource {
	Cargo *c1 = [self makeCargo: @"cargo"];
	[c1 setSource: nil];
	[c1 setDestination: [self industryAtStation: @"A"]];

	FreightCar *fc = [self makeFreightCarWithReportingMarks: @"SP 1"];
	[fc setCargo: c1];
	[fc setCurrentTrain: [[entireLayout_ allTrains] lastObject]];
	[fc setCurrentLocation: [self industryAtStation: @"B"]];
	[fc setIsLoaded: NO];

	TrainAssigner *assigner = [[TrainAssigner alloc] initWithLayout: entireLayout_ useDoors: NO];
	[assigner autorelease];
	// Should fail because of missing source.
	STAssertEquals(CarAssignmentRoutingProblem, [assigner assignCarToTrain: fc], @"Incorrectly assigns car with missing source for cargo.");
	STAssertEqualsInt(1, [[assigner errors] count], @"Expected one error from train assigner, found %d", [[assigner errors] count]);
	STAssertContains(@"source location for cargo", [[assigner errors] objectAtIndex: 0],
					 @"Wrong error for missing source", [[assigner errors] count]);
}
   
- (void) testNoCrashWithMissingCargoDestination {
	Cargo *c2 = [self makeCargo: @"cargo"];
	[c2 setSource: [self industryAtStation: @"A"]];
	[c2 setDestination: nil];
	
	FreightCar *fc2 = [self makeFreightCarWithReportingMarks: @"SP 1"];
	[fc2 setCargo: c2];
	[fc2 setCurrentTrain: [[entireLayout_ allTrains] lastObject]];
	[fc2 setCurrentLocation: [self industryAtStation: @"A"]];
	[fc2 setIsLoaded: YES];
	
	TrainAssigner *assigner = [[[TrainAssigner alloc] initWithLayout: entireLayout_ useDoors: NO] autorelease];
	// Should fail because of missing destination.
	STAssertEquals(CarAssignmentRoutingProblem, [assigner assignCarToTrain: fc2], @"Incorrectly assigns car with missing destination for cargo.");
	STAssertEqualsInt(1, [[assigner errors] count], @"Expected one error from train assigner, found %d", [[assigner errors] count]);
	STAssertContains(@"destination location for cargo", [[assigner errors] objectAtIndex: 0],
					 @"Wrong error for missing source: found %@", [[assigner errors] objectAtIndex: 0]);
	
}
	
- (void) testNoCrashWithMissingYardStation {
	// Make an industry, but make sure the town is nil.
	Yard *yardWithoutTown = [self makeYardWithName: @"Yard without Town"];
	[yardWithoutTown setLocation: nil];
	
	FreightCar *fc1 = [self makeFreightCarWithReportingMarks: @"SP 1"];
	[fc1 setCargo: nil];
	[fc1 setCurrentTrain: [[entireLayout_ allTrains] lastObject]];
	[fc1 setCurrentLocation: [self industryAtStation: @"A"]];
	[fc1 setIsLoaded: NO];
	
	TrainAssigner *assigner = [[[TrainAssigner alloc] initWithLayout: entireLayout_ useDoors: NO] autorelease];
	// Should fail because of missing destination.
	STAssertEquals(CarAssignmentRoutingProblem, [assigner assignCarToTrain: fc1], @"assignCarToTrain for non-existent industry did not fail.");
	
	STAssertEqualsInt(2, [[assigner errors] count], @"Expected two errors from train assigner, found %d", [[assigner errors] count]);
	STAssertContains(@"does not have its town set", [[assigner errors] objectAtIndex: 0],
					 @"Wrong error for missing source", [[assigner errors] count]);
	STAssertContains(@"Cannot find route for car SP 1 from A to a yard", [[assigner errors] objectAtIndex: 1],
					 @"Wrong error for missing source", [[assigner errors] count]);
	
}

- (void) testNoCrashWithMissingEndStation {
	// Make an industry, but make sure the town is nil.
	Industry *industryWithoutTown = [self makeIndustryWithName: @"Lost"];
	[industryWithoutTown setLocation: nil];
	
	Cargo *c2 = [self makeCargo: @"cargo"];
	[c2 setSource: [self industryAtStation: @"A"]];
	[c2 setDestination: industryWithoutTown];

	
	FreightCar *fc1 = [self makeFreightCarWithReportingMarks: @"SP 1"];
	[fc1 setCargo: c2];
	[fc1 setCurrentTrain: [[entireLayout_ allTrains] lastObject]];
	[fc1 setCurrentLocation: [self industryAtStation: @"A"]];
	[fc1 setIsLoaded: YES];
	
	TrainAssigner *assigner = [[[TrainAssigner alloc] initWithLayout: entireLayout_ useDoors: NO] autorelease];
	// Should fail because of missing destination.
	STAssertEquals(CarAssignmentRoutingProblem, [assigner assignCarToTrain: fc1], @"assignCarToTrain for non-existent industry did not fail.");
	STAssertEqualsInt(2, [[assigner errors] count], @"Expected two errors from train assigner, found %d", [[assigner errors] count]);
	STAssertContains(@"does not have its town set", [[assigner errors] objectAtIndex: 0],
					 @"Wrong error for missing source, found %@", [[assigner errors] objectAtIndex: 0]);
	STAssertContains(@"Cannot find route to get car SP 1 from A to 'No Value'", [[assigner errors] objectAtIndex: 1],
					 @"Wrong error for missing source, found %@", [[assigner errors] objectAtIndex: 0]);
	
}

- (void) testNoCrashWithMissingStartStation {
	// Make an industry, but make sure the town is nil.
	Industry *industryWithoutTown = [self makeIndustryWithName: @"Lost"];
	[industryWithoutTown setLocation: nil];
	
	Cargo *c2 = [self makeCargo: @"cargo"];
	[c2 setSource: [self industryAtStation: @"A"]];
	[c2 setDestination: [self industryAtStation: @"B"]];
	
	
	FreightCar *fc1 = [self makeFreightCarWithReportingMarks: @"SP 1"];
	[fc1 setCargo: c2];
	[fc1 setCurrentTrain: [[entireLayout_ allTrains] lastObject]];
	[fc1 setCurrentLocation: industryWithoutTown];
	[fc1 setIsLoaded: NO];
	
	TrainAssigner *assigner = [[[TrainAssigner alloc] initWithLayout: entireLayout_ useDoors: NO] autorelease];
	// Should fail because of missing destination.
	STAssertEquals(CarAssignmentRoutingProblem, [assigner assignCarToTrain: fc1], @"assignCarToTrain for non-existent industry did not fail.");
	
	STAssertEqualsInt(2, [[assigner errors] count], @"Expected two errors from train assigner, found %d", [[assigner errors] count]);

	STAssertContains(@"does not have its town set", [[assigner errors] objectAtIndex: 0],
					 @"Wrong error for missing source: %@", [[assigner errors] objectAtIndex: 0]);
	STAssertContains(@"Cannot find route to get car SP 1 from 'No Value' to A", [[assigner errors] objectAtIndex: 1],
					 @"Wrong error for missing source: %@", [[assigner errors] objectAtIndex: 1]);
	
}

@end

@interface TestDoorAssignment : LayoutTest {
	TrainAssigner* assigner;
	Industry* newIndustry;
}
@end

extern void srandom(unsigned);
extern unsigned gettimeofday (void*, void*);

@implementation TestDoorAssignment
- (void) setUp {
	[super setUp];
	newIndustry = [[self makeIndustryWithName: @"MyIndustry"] retain];
	assigner = [[TrainAssigner alloc] initWithLayout: entireLayout_ useDoors: YES];
	srandom(gettimeofday(NULL, NULL));
}
- (void) tearDown {
	[assigner release];
	[newIndustry release];
	[super tearDown];
}

// Test with one freight car, four doors, and no competition.  Make sure door choice always between 1-4.
- (void) testSimpleDoorAssignment {
	[newIndustry setHasDoors: YES];
	[newIndustry setNumberOfDoors: [NSNumber numberWithInt: 4]];
	
	ScheduledTrain *newTrain = [self makeTrainWithName: @"MyTrain"];
	
	FreightCar *fc1 = [self makeFreightCarWithReportingMarks: @"SP 1"];
	[fc1 setCurrentTrain: newTrain];
	
	DoorAssignmentRecorder *doorAssignments = [DoorAssignmentRecorder doorAssignmentRecorder];

	int i;
	// Test 10 times to make sure random values aren't out of range.
	for (i = 0; i< 10; i++) {
		NSNumber *door = [assigner chooseRandomDoorForCar: fc1
												  inTrain: newTrain
										  goingToIndustry: newIndustry
								   industryArrivingCarMap: doorAssignments];
		STAssertNotNil(door, @"Door expected to be non-nil");
		STAssertTrue([door intValue] > 0, [NSString stringWithFormat: @"Door expected > 0, but was %d", [door intValue]]);
		STAssertTrue([door intValue] <= 4, [NSString stringWithFormat: @"Door expected 1-4, but was %d", [door intValue]]);
	}
}

// Place a freight car at door 2.  Do we avoid assigning the new car to door 2?
- (void) testConflictingDoorAssignment {
	[newIndustry setHasDoors: YES];
	[newIndustry setNumberOfDoors: [NSNumber numberWithInt: 4]];
	
	ScheduledTrain *newTrain = [self makeTrainWithName: @"MyTrain"];
	
	FreightCar *fc1 = [self makeFreightCarWithReportingMarks: @"SP 1"];
	[fc1 setCurrentTrain: newTrain];
	FreightCar *fc2 = [self makeFreightCarWithReportingMarks: @"SP 2"];
	[fc2 setCurrentLocation: newIndustry];
	[fc2 setDoorToSpot: [NSNumber numberWithInt: 2]];
	
	DoorAssignmentRecorder *doorAssignments = [DoorAssignmentRecorder doorAssignmentRecorder];
	
	int i;
	// Test 10 times to make sure random values aren't out of range.
	for (i = 0; i< 10; i++) {
		NSNumber *door = [assigner chooseRandomDoorForCar: fc1
												  inTrain: newTrain
										  goingToIndustry: newIndustry
								   industryArrivingCarMap: doorAssignments];
		STAssertNotNil(door, @"Door expected to be non-nil");
		STAssertTrue([door intValue] > 0, [NSString stringWithFormat: @"Door expected > 0, but was %d", [door intValue]]);
		STAssertTrue([door intValue] <= 4, [NSString stringWithFormat: @"Door expected 1-4, but was %d", [door intValue]]);
		STAssertTrue([door intValue] != 2, @"Door 2 already occupied.");
	}
}

// Place a freight car at door 2, but it's moving.  Do we get both door 1 and 2?
- (void) testConflictingDoorAssignment2 {
	[newIndustry setHasDoors: YES];
	[newIndustry setNumberOfDoors: [NSNumber numberWithInt: 4]];
	
	ScheduledTrain *newTrain = [self makeTrainWithName: @"MyTrain"];
	
	FreightCar *fc1 = [self makeFreightCarWithReportingMarks: @"SP 1"];
	[fc1 setCurrentTrain: newTrain];
	FreightCar *fc2 = [self makeFreightCarWithReportingMarks: @"SP 2"];
	[fc2 setCurrentLocation: newIndustry];
	[fc2 setDoorToSpot: [NSNumber numberWithInt: 2]];
	[fc2 setCurrentTrain: newTrain];
	
	DoorAssignmentRecorder *doorAssignments = [DoorAssignmentRecorder doorAssignmentRecorder];
	
	int i;
	int sawTwo = 0;
	// Test 10 times to make sure random values aren't out of range.
	for (i = 0; i< 100; i++) {
		NSNumber *door = [assigner chooseRandomDoorForCar: fc1
												  inTrain: newTrain
										  goingToIndustry: newIndustry
								   industryArrivingCarMap: doorAssignments];
		STAssertNotNil(door, @"Door expected to be non-nil");
		STAssertTrue([door intValue] > 0, [NSString stringWithFormat: @"Door expected > 0, but was %d", [door intValue]]);
		STAssertTrue([door intValue] <= 4, [NSString stringWithFormat: @"Door expected 1-4, but was %d", [door intValue]]);
		if ([door intValue] == 2) {
			sawTwo = 1;
		}
	}
	STAssertFalse(sawTwo == 0, @"Should have seen door 2 at least once.");
		
}

// TODO(bowdidge): Need test where we've already put one car in the train into a door in the same industry.

// Only one space - door 2.  Do we end up choosing it?
- (void) testOnlyOneChoiceDoorAssignment {
	[newIndustry setHasDoors: YES];
	[newIndustry setNumberOfDoors: [NSNumber numberWithInt: 2]];
	
	ScheduledTrain *newTrain = [self makeTrainWithName: @"MyTrain"];
	
	FreightCar *fc1 = [self makeFreightCarWithReportingMarks: @"SP 1"];
	[fc1 setCurrentTrain: newTrain];
	FreightCar *fc2 = [self makeFreightCarWithReportingMarks: @"SP 2"];
	[fc2 setCurrentLocation: newIndustry];
	[fc2 setDoorToSpot: [NSNumber numberWithInt: 1]];

	DoorAssignmentRecorder *doorAssignments = [DoorAssignmentRecorder doorAssignmentRecorder];
	
	// We go straight for door 2, right?
	NSNumber *door = [assigner chooseRandomDoorForCar: fc1
											  inTrain: newTrain
									  goingToIndustry: newIndustry
							   industryArrivingCarMap: doorAssignments];
	STAssertNotNil(door, @"Door expected to be non-nil");
	STAssertEqualsInt(2, [door intValue], [NSString stringWithFormat: @"Door expected 2, but was %d", [door intValue]]);
}

// Only one space - door 1.  Does second car get rejected because there's no space?
// TODO(bowdidge): Need arrivingIndustryMap to have both industry->car and car->door mappings.
- (void) testSpaceTakenByOtherCar {
	[newIndustry setHasDoors: YES];
	[newIndustry setNumberOfDoors: [NSNumber numberWithInt: 1]];
	
	ScheduledTrain *newTrain = [self makeTrainWithName: @"MyTrain"];
	
	FreightCar *fc1 = [self makeFreightCarWithReportingMarks: @"SP 1"];
	[fc1 setCurrentTrain: newTrain];
	FreightCar *fc2 = [self makeFreightCarWithReportingMarks: @"SP 2"];
	[fc2 setCurrentLocation: newIndustry];
	[fc2 setCurrentTrain: newTrain];
	
	DoorAssignmentRecorder *doorAssignments = [DoorAssignmentRecorder doorAssignmentRecorder];
	
	// If fc1 goes to door 1, then fc2 should fail because it's already occupied. 
	NSNumber *door = [assigner chooseRandomDoorForCar: fc1 
											  inTrain: newTrain
									  goingToIndustry: newIndustry
							   industryArrivingCarMap: doorAssignments];
	STAssertNotNil(door, @"Door expected to be non-nil");
	STAssertEqualsInt(1, [door intValue], [NSString stringWithFormat: @"Door expected 2, but was %d", [door intValue]]);

	[doorAssignments setCar:fc1 destinedForIndustry:newIndustry door:[door intValue]];
	
	NSNumber *doorForCar2 = [assigner chooseRandomDoorForCar: fc2
													 inTrain: newTrain
											 goingToIndustry: newIndustry
									  industryArrivingCarMap: doorAssignments];
	STAssertNil(doorForCar2, @"Car 2 should not have had space, but put at door %@", doorForCar2);
				
}


// No space - do we fail nicely?
- (void) testNoSpaceDoorAssignment {
	[newIndustry setHasDoors: YES];
	[newIndustry setNumberOfDoors: [NSNumber numberWithInt: 1]];
	
	ScheduledTrain *newTrain = [self makeTrainWithName: @"MyTrain"];
	
	FreightCar *fc1 = [self makeFreightCarWithReportingMarks: @"SP 1"];
	[fc1 setCurrentTrain: newTrain];
	FreightCar *fc2 = [self makeFreightCarWithReportingMarks: @"SP 2"];
	[fc2 setCurrentLocation: newIndustry];
	[fc2 setDoorToSpot: [NSNumber numberWithInt: 1]];
	
	// TODO(bowdidge): Should accept my own random number generator so I can make sure 2 comes up.
	DoorAssignmentRecorder *doorAssignments = [DoorAssignmentRecorder doorAssignmentRecorder];
	
	// We go straight for door 2, right?
	NSNumber *door = [assigner chooseRandomDoorForCar: fc1
											  inTrain: newTrain
									  goingToIndustry: newIndustry
							   industryArrivingCarMap: doorAssignments];
	STAssertNil(door, [NSString stringWithFormat: @"Door expected to be nil, but was %@", door]);
}

// No doors at all - do we fail nicely?
- (void) testNoSpaceDoorAssignment2 {
	[newIndustry setHasDoors: YES];
	[newIndustry setNumberOfDoors: [NSNumber numberWithInt: 0]];
	
	ScheduledTrain *newTrain = [self makeTrainWithName: @"MyTrain"];
	
	FreightCar *fc1 = [self makeFreightCarWithReportingMarks: @"SP 1"];
	[fc1 setCurrentTrain: newTrain];
	
	DoorAssignmentRecorder *doorAssignments = [DoorAssignmentRecorder doorAssignmentRecorder];
	
	NSNumber *door = [assigner chooseRandomDoorForCar: fc1
											  inTrain: newTrain
									  goingToIndustry: newIndustry
							   industryArrivingCarMap: doorAssignments];
	STAssertNil(door, [NSString stringWithFormat: @"Door expected to be nil, but was %@", door]);
}
@end

@interface TestTrainAssignmentRespectingSidingLength : LayoutTest {
	FreightCar *xmMovingBToC_;
	FreightCar *xmMovingAToB_;
	FreightCar *xaMovingAToB_;
	
	ScheduledTrain *myTrain_;
}
@end

@implementation TestTrainAssignmentRespectingSidingLength
- (void) setUp {
	[super setUp];
	[self makeThreeStationLayout];

	[[self industryAtStation: @"A"] setSidingLength: [NSNumber numberWithInt: 40]];
	// Siding B can handle everything.
	[[self industryAtStation: @"B"] setSidingLength: [NSNumber numberWithInt: 40]];
	[[self industryAtStation: @"C"] setSidingLength: [NSNumber numberWithInt: 80]];
	
	xmMovingBToC_ = [self makeFreightCarWithReportingMarks: @"B2C 1"];
	[xmMovingBToC_ setCarTypeRel: [entireLayout_ carTypeForName: @"XM"]];
	[xmMovingBToC_ setLength: [NSNumber numberWithInt: 40]];
	
	xaMovingAToB_ = [self makeFreightCarWithReportingMarks: @"A2B 2"];
	[xaMovingAToB_ setCarTypeRel: [entireLayout_ carTypeForName: @"XA"]];
	[xaMovingAToB_ setLength: [NSNumber numberWithInt: 50]];
	
	xmMovingAToB_ = [self makeFreightCarWithReportingMarks: @"A2B 3"];
	[xmMovingAToB_ setCarTypeRel: [entireLayout_ carTypeForName: @"XM"]];
	[xmMovingAToB_ setLength: [NSNumber numberWithInt: 40]];
}


// Creates a sample short train moving only from A to B, and
// defines two cargos, one going from B to C, and the other from A to B.
- (ScheduledTrain*) makeShortTrain {
	myTrain_ = [self makeTrainWithName: @"MyTrain"];
	[myTrain_ setStops: @"A,B,C"];
	[self setTrain: myTrain_ acceptsCarTypes: @"XM"];
	
	STAssertEqualsInt(3, [[myTrain_ stationStopObjects] count], @"Wrong number of station stops");
	STAssertEqualObjects(@"A", [[[myTrain_ stationStopObjects] objectAtIndex: 0] name], @"A missing");
	STAssertEqualObjects(@"B", [[[myTrain_ stationStopObjects] objectAtIndex: 1] name], @"B missing");
	STAssertEqualObjects(@"C", [[[myTrain_ stationStopObjects] objectAtIndex: 2] name], @"C missing");
	
	Cargo *c1 = [self makeCargo: @"b to c"];
	[c1 setSource: [self industryAtStation: @"B"]];
	[c1 setDestination: [self industryAtStation: @"C"]];
	[c1 setCarTypeRel: [entireLayout_ carTypeForName: @"XM"]];
	[xmMovingBToC_ setCargo: c1];
	[xmMovingBToC_ setCurrentLocation: [self industryAtStation: @"B"]];
	
	Cargo *c2 = [self makeCargo: @"a to b"];
	[c2 setSource: [self industryAtStation: @"A"]];
	[c2 setDestination: [self industryAtStation: @"B"]];
	[c2 setCarTypeRel: [entireLayout_ carTypeForName: @"XA"]];
	[xaMovingAToB_ setCargo: c2];
	[xaMovingAToB_ setCurrentLocation: [self industryAtStation: @"A"]];

	[xmMovingAToB_ setCargo: c2];
	[xmMovingAToB_ setCurrentLocation: [self industryAtStation: @"A"]];
	return myTrain_;
}

/* Test that space occupied by cars on the same train can cause a later
 car not to be added.
 */
- (void) testMultipleCarsFit {
	[self makeShortTrain];
	TrainAssigner *assigner = [[TrainAssigner alloc] initWithLayout: entireLayout_ useDoors: NO respectSidingLengths: YES];
	// Freight car 1 goes to B, freight car 2 goes to A.
	[xmMovingBToC_ setIsLoaded: NO];
	[xmMovingBToC_ setCurrentLocation: [self industryAtStation: @"A"]];
	[xmMovingAToB_ setIsLoaded: YES];
	[xmMovingAToB_ setCurrentLocation: [self industryAtStation: @"A"]];
	[[self industryAtStation: @"B"] setSidingLength: [NSNumber numberWithInt: 80]];
	
	[assigner assignCarsToTrains: [NSArray arrayWithObjects: xmMovingBToC_, xmMovingAToB_, nil]];
	STAssertTrue(0 == [[assigner errors] count], @"Unexpected errors '%@' from TrainAssigner!", [assigner errors]);
	[assigner release];
}

// How does assignCarsToTrains work with cars with no destination?
- (void) testMovingOfflineCar {
	[self makeShortTrain];
	TrainAssigner *assigner = [[TrainAssigner alloc] initWithLayout: entireLayout_ useDoors: NO respectSidingLengths: YES];
	FreightCar *fc = [self makeFreightCarWithReportingMarks: @"LOST 1"];
	[fc setCurrentLocation: [self industryAtStation: @"B"]];
	Place *offline = [self makePlaceWithName: @"Offline"];
	[offline setIsOffline: YES];

	Cargo *c = [self makeCargo: @"foo"];
	[c setSource: [self industryAtStation: @"B"]];
	[c setDestination: [self industryAtStation: @"Offline"]];
	
	[self makeYardAtStation: @"C"];
	
	[assigner assignCarsToTrains: [NSArray arrayWithObject: fc]];
	STAssertEqualObjects(myTrain_, [fc currentTrain], @"");
	STAssertTrue(0 == [[assigner errors] count], @"Unexpected errors '%@' from TrainAssigner!", [assigner errors]);
	[assigner release];
}	 

// Test that other incoming cars are remembered when doing math for capacity.
- (void) testMultipleCarsTooLongDoNotFit {
	[self makeShortTrain];
	TrainAssigner *assigner = [[TrainAssigner alloc] initWithLayout: entireLayout_ useDoors: NO respectSidingLengths: YES];
	// Freight car 1 goes to B, freight car 2 goes to A.
	[xmMovingBToC_ setIsLoaded: NO];
	[xmMovingBToC_ setCurrentLocation: [self industryAtStation: @"A"]];
	[xmMovingAToB_ setIsLoaded: YES];
	[xmMovingAToB_ setCurrentLocation: [self industryAtStation: @"A"]];
	[[self industryAtStation: @"B"] setSidingLength: [NSNumber numberWithInt: 79]];
	
	[assigner assignCarsToTrains: [NSArray arrayWithObject: myTrain_]];
	
	STAssertTrue([xmMovingBToC_ currentTrain] == nil ^ [xmMovingAToB_ currentTrain] == nil,
				   @"Only one of the cars should have moved.");
	STAssertEqualsInt(1, [[assigner errors] count], @"Unexpected errors '%@' from TrainAssigner!", [assigner errors]);
	[assigner release];
}

/* Tests that if a car already occupies the siding, a new car isn't put on
   the same full siding.
 */
- (void) testSidingAlreadyOccupied {
	[self makeShortTrain];
	[xmMovingBToC_ setCurrentLocation: [self industryAtStation: @"B"]];
	[xmMovingBToC_ setIsLoaded: NO];

	[xmMovingAToB_ setCurrentLocation: [self industryAtStation: @"A"]];
	[xmMovingAToB_ setIsLoaded: YES];

	TrainAssigner *assigner = [[TrainAssigner alloc] initWithLayout: entireLayout_ useDoors: NO respectSidingLengths: YES];
	[assigner assignCarsToTrains: [NSArray arrayWithObject: myTrain_]];
	
	STAssertNil([xmMovingAToB_ currentTrain], @"AtoB shouldn't be moving!");
	STAssertEqualsInt(1, [[assigner errors] count], @"Unexpected errors from TrainAssigner: %@", [assigner errors]);
	[assigner release];
}

/* Test that space occupied by cars on the same train can cause a later
 car not to be added.
 */
- (void) testLeavingCarNotCounted {
	[self makeShortTrain];
	TrainAssigner *assigner = [[TrainAssigner alloc] initWithLayout: entireLayout_ useDoors: NO respectSidingLengths: YES];
	// Freight car 1 goes to B, freight car 2 goes to A.
	[xmMovingBToC_ setIsLoaded: YES];
	[xmMovingBToC_ setCurrentLocation: [self industryAtStation: @"B"]];
	[xmMovingAToB_ setIsLoaded: YES];
	[xmMovingAToB_ setCurrentLocation: [self industryAtStation: @"A"]];
	[[self industryAtStation: @"B"] setSidingLength: [NSNumber numberWithInt: 40]];
	
	STAssertEquals(CarAssignmentSuccess, [assigner assignCarToTrain: xmMovingBToC_],
				   @"xmMovingBToC should have been moved to C.");
	STAssertEquals(CarAssignmentSuccess, [assigner assignCarToTrain: xmMovingAToB_],
				   @"xmMovingAToB_ should have fit.");
	STAssertEqualsInt(0, [[assigner errors] count], @"Unexpected errors '%@' from TrainAssigner!", [assigner errors]);
	[assigner release];
}

/* Tests that if a car already occupies the siding, a new car isn't put on
 the same full siding.
 */
- (void) testZeroLengthSidingAlwaysAccepts {
	[self makeShortTrain];
	[xmMovingBToC_ setCurrentLocation: [self industryAtStation: @"A"]];
	[xmMovingBToC_ setIsLoaded: NO];
	
	FreightCar *fcNotMoving = [self makeFreightCarWithReportingMarks: @"STUCK 1"];
	[fcNotMoving setLength: [NSNumber numberWithInt: 0]];
	[fcNotMoving setCurrentLocation: [self industryAtStation: @"B"]];
	
	TrainAssigner *assigner = [[TrainAssigner alloc] initWithLayout: entireLayout_ useDoors: NO respectSidingLengths: YES];
	STAssertEquals(CarAssignmentSuccess, [assigner assignCarToTrain: xmMovingBToC_],
				   @"xmMovingBToC should have fit.");
	STAssertEqualsInt(0, [[assigner errors] count], @"Unexpected errors from TrainAssigner!");
	[assigner release];
}

// TODO(bowdidge): Test yards don't have capacity, and intermediate dest doesn't count.
@end

@interface TestTrainLengthLimitRespected : LayoutTest {
}
@end

@implementation TestTrainLengthLimitRespected
- (void) setUp {
	[super setUp];
	[self makeThreeStationLayout];
}

- (ScheduledTrain*) makeSimpleTrain: (int) maxLength {
	ScheduledTrain *train = [self makeTrainWithName: @"MyTrain"];
	[train setMaxLength: [NSNumber numberWithInt: maxLength]];
	
	[train setStops: @"A,B,C"];
	[train addFreightCarsObject: [self makeFreightCarNamed: @"AA 1"
														at: @"A"
												movingFrom: @"A" to:@"C" loaded: YES]];
	[train addFreightCarsObject: [self makeFreightCarNamed: @"AA 2"
														at: @"A"
												movingFrom: @"B" to:@"C" loaded: NO]];
	
	[train addFreightCarsObject: [self makeFreightCarNamed: @"AA 3"
														at: @"B"
												movingFrom: @"B" to:@"B" loaded: YES]];
	return train;
}

- (void) testCarWillNotFitInTrain {
	ScheduledTrain *train = [self makeSimpleTrain: 80];
	// Overloads the a-b leg.
	FreightCar *newCar =  [self makeFreightCarNamed: @"AA 4"
												 at: @"A"
										 movingFrom: @"B" to:@"C" loaded: NO];
	
	TrainAssigner *assigner = [[TrainAssigner alloc] initWithLayout: entireLayout_ useDoors: NO respectSidingLengths: YES];
	STAssertEquals(CarAssignmentNoTrainsWithSpace, [assigner assignCarToTrain: newCar], @"Car should not have fit.");
	STAssertEqualsInt(1, [[assigner errors] count], @"Wrong number of errors.");
	STAssertContains(@"Cannot fit car", [[assigner errors] objectAtIndex: 0], @"Wrong error");
}

- (void) testCarFitsInTrain {
	ScheduledTrain *train = [self makeSimpleTrain: 120];
	// Overloads the a-b leg.
	FreightCar *newCar =  [self makeFreightCarNamed: @"AA 4"
												 at: @"A"
										 movingFrom: @"B" to:@"C" loaded: NO];
	
	TrainAssigner *assigner = [[TrainAssigner alloc] initWithLayout: entireLayout_ useDoors: NO respectSidingLengths: YES];
	STAssertEquals(CarAssignmentSuccess, [assigner assignCarToTrain: newCar], @"Car should have fit.");
	STAssertEqualsInt(0, [[assigner errors] count], @"Wrong number of errors.");
}

@end

@interface InfiniteLoopInRouteTest : LayoutTest {
};
@end

@implementation InfiniteLoopInRouteTest 
- (void) testExcessiveTimeToCalculateRouteFrom {
	// RouteFrom should be fast, even in this case with several different yards available for the car to
	// switch trains at.  Check that the execution time is less than 0.1 sec.
	[self makeSimpleLayout];

	int i;
	for (i=1;i<8;i++) {
		NSString *townName = [NSString stringWithFormat: @"town-%d", i];
		Place *p = [self makePlaceWithName: townName];
		NSLog(@"%@", p);
		[self makeYardAtStation: townName];
	}
	Place *p = [self makePlaceWithName: @"town-branch"];
				
	ScheduledTrain *mainTrain  =[self makeTrainWithName: @"stops everywhere"];
	[mainTrain setStops: @"town-1,town-2,town-3,town-4,town-5,town-6,town-7"];
	
	ScheduledTrain *mainTrain3  =[self makeTrainWithName: @"stops everywhere"];
	[mainTrain3 setStops: @"town-7,town-6,town-5,town-4,town-3,town-2,town-1"];
	
	// Note no way *to* branch.
	ScheduledTrain *branchTrain  =[self makeTrainWithName: @"branchTrain"];
	[branchTrain setStops: @"town-branch,town-3"];

	Cargo *c = [self makeCargo: @"cargo"];
	[c setSource: [self industryAtStation: @"town-1"]];
	[c setDestination: [self industryAtStation: @"town-branch"]];
	[c setCarTypeRel: [entireLayout_ carTypeForName: @"XM"]];

	FreightCar *fc1 =[self makeFreightCarWithReportingMarks: @"AA 1"];
	[fc1 setCarTypeRel: [entireLayout_ carTypeForName: @"XM"]];
	
	NSDate *start = [NSDate date];
	TrainAssigner *assigner = [[TrainAssigner alloc] initWithLayout:[self entireLayout]  useDoors: NO];
	STAssertNil([assigner routeFrom: [self industryAtStation: @"town-1"] to: [self industryAtStation: @"town-branch"] forCar: fc1],
				@"No route expected because branch is unreachable.");
	NSDate *end = [NSDate date];
	STAssertTrue([end timeIntervalSinceDate: start] < 0.100, @"routeFrom:to:forCar: should have completed in 0.01 sec or so, not %f sec.", [end timeIntervalSinceDate: start]);
	
}	

@end
