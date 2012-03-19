//
//
//  LayoutTest.m
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

#import "LayoutTest.h"

#import "Cargo.h"
#import "CarType.h"
#import "EntireLayout.h"
#import "FreightCar.h"
#import "InduYard.h"
#import "Industry.h"
#import "Place.h"
#import "ScheduledTrain.h"
#import "Yard.h"


@implementation LayoutTest
- (void)setUp
{
	context_ = [[NSManagedObjectContext inMemoryMOCFromBundle: [NSBundle bundleForClass: [self class]]] retain];
	entireLayout_ = [[EntireLayout alloc] initWithMOC: context_];
	[self makeCarType: @"XA"];
	[self makeCarType: @"XM"];
	[self makeCarType: @"T"];
}

- (void)tearDown
{
    [context_ release];
	[entireLayout_ release];
}

- (EntireLayout*) entireLayout {
	return entireLayout_;
}

- (FreightCar*) freightCarWithReportingMarks: (NSString*) reportingMarks {
	NSArray *allCars = [entireLayout_ allFreightCars];
	for (FreightCar *fc in allCars) {
		if ([[fc reportingMarks] isEqualToString: reportingMarks]) {
			return fc;
		}
	}
	return nil;
}

- (void) setTrain: (ScheduledTrain*) st acceptsCarTypes: (NSString*) carTypesToSetString {
	NSArray *allCarTypes = [entireLayout_ allCarTypes];
	NSMutableDictionary *carTypeMap = [NSMutableDictionary dictionary];
	for (CarType *ct in allCarTypes) {
		[carTypeMap setObject: ct forKey: [ct carTypeName]];
	}
	
	NSArray *carTypesToSet = [carTypesToSetString componentsSeparatedByString: @","];
	NSMutableSet *carTypesSet = [NSMutableSet set];
	for (NSString *carTypeStr in carTypesToSet) {
		CarType *foundCarType = [carTypeMap objectForKey: carTypeStr];
		if (foundCarType) {
			[carTypesSet addObject: foundCarType];
		}
	}
	[st setCarTypesAcceptedRel: carTypesSet];
}

// Creates a persistent freight car in the current managed object context.
- (CarType*) makeCarType: (NSString*) carTypeStr {
	[NSEntityDescription entityForName: @"CarType" inManagedObjectContext: context_];
	CarType *carType = [NSEntityDescription insertNewObjectForEntityForName:@"CarType"
														   inManagedObjectContext: context_];
	[carType setCarTypeName: carTypeStr];
	return carType;
}

// Creates a persistent freight car in the current managed object context.
- (FreightCar*) makeFreightCarWithReportingMarks: (NSString*) reportingMarks {
	[NSEntityDescription entityForName: @"FreightCar" inManagedObjectContext: context_];
	FreightCar *freightCar = [NSEntityDescription insertNewObjectForEntityForName:@"FreightCar"
														   inManagedObjectContext: context_];
	[freightCar setReportingMarks: reportingMarks];
	return freightCar;
}

- (ScheduledTrain*) makeTrainWithName: (NSString*) name {
	[NSEntityDescription entityForName: @"ScheduledTrain" inManagedObjectContext: context_];
	ScheduledTrain *train = [NSEntityDescription insertNewObjectForEntityForName:@"ScheduledTrain"
														  inManagedObjectContext: context_];
	[train setName: name];
	return train;
}

// Creates persistent industry in current managed object context.
- (Industry *) makeIndustryWithName: (NSString *) name  {
	Industry *industry = [NSEntityDescription insertNewObjectForEntityForName:@"Industry"
													   inManagedObjectContext: context_];
	[industry setName: [NSString stringWithFormat: @"%@-industry", name]];
  return industry;
}

// Creates persistent yard in current managed object context.
- (Yard *) makeYardWithName: (NSString *) name  {
	Yard *yard = [NSEntityDescription insertNewObjectForEntityForName:@"Yard"
													   inManagedObjectContext: context_];
	[yard setName: [NSString stringWithFormat: @"%@-yard", name]];
	return yard;
}

// Creates a persistent place in the current managed object context, and adds a single industry.
- (Place*) makePlaceWithName: (NSString*) name {
	[NSEntityDescription entityForName: @"Place" inManagedObjectContext: context_];
	Place *place = [NSEntityDescription insertNewObjectForEntityForName:@"Place"
												 inManagedObjectContext: context_];
	[place setName: name];
	
	Industry *industry = [self makeIndustryWithName: name];
	[place addIndustriesObject: industry];
	return place;
}

- (Yard*) makeYardAtStation: (NSString*) stationName {
	NSEntityDescription *industryEntity = [NSEntityDescription entityForName: @"Yard" inManagedObjectContext: context_];
	Yard *yard = [NSEntityDescription insertNewObjectForEntityForName:@"Yard"
													   inManagedObjectContext: context_];
	[yard setName: [NSString stringWithFormat: @"%@-yard", stationName]];
	Place *station = [entireLayout_ stationWithName: stationName];
	STAssertNotNil(station, @"Yard for station %@ not found", stationName);
	[station addIndustriesObject: yard];
	return yard;
}
	

// Creates a persistent cargo in the current managed object context.
- (Cargo*) makeCargo: (NSString*) name {
	[NSEntityDescription entityForName: @"Cargo" inManagedObjectContext: context_];
	Cargo *cargo = [NSEntityDescription insertNewObjectForEntityForName:@"Cargo"
														   inManagedObjectContext: context_];
	[cargo setCargoDescription: name];
	return cargo;
}

// Creates a layout with no freight cars, places, or industries.
- (void) makeSimpleLayout {
	[NSEntityDescription entityForName: @"LayoutInfo" inManagedObjectContext: context_];
	[NSEntityDescription insertNewObjectForEntityForName:@"LayoutInfo"
															inManagedObjectContext: context_];
	[context_ save: nil];
}

// Creates a layout with no freight cars, places, or industries.
- (void) makeThreeStationLayoutNoYards {
	[self makeSimpleLayout];
	
    [self makePlaceWithName: @"A"];
	[self makePlaceWithName: @"B"];
	[self makePlaceWithName: @"C"];
}

// Creates a layout with no freight cars, places, or industries.
- (void) makeThreeStationLayoutWithDivisions: (BOOL) divisions {
	[self makeThreeStationLayoutNoYards];
	
	Yard *bYard = [self makeYardAtStation: @"B"];
	Yard *cYard = [self makeYardAtStation: @"C"];
	if (divisions) {
		// Mark divisions for each yard.
		[bYard setAcceptsDivisions: @"B"];
		[cYard setAcceptsDivisions: @"C"];
	}
}

- (void) makeThreeStationLayout {
	[self makeThreeStationLayoutWithDivisions: YES];
}

// Create a freight car with an expected movement.
// Name the car's current location, and where the town was loaded and unloaded,
// along with whether it's loaded.  Location is the name of a town; location would be the
// name of the industry in that town.
- (FreightCar *) makeFreightCarNamed: (NSString*) name
								  at: (NSString *) currentLocation
						  movingFrom: (NSString *) source
								  to: (NSString *) destination
							  loaded: (int) loaded  {
	FreightCar *fc1 = [self makeFreightCarWithReportingMarks: name];
	[fc1 setCarTypeRel: [entireLayout_ carTypeForName: @"XM"]];
	Cargo *c1 = [self makeCargo: [NSString stringWithFormat: @"%@ to %@", source ,destination]];
	[c1 setSource: [self industryAtStation: source]];
	[c1 setDestination: [self industryAtStation: destination]];
	[fc1 setCargo: c1];
	[fc1 setCurrentLocation: [self industryAtStation: currentLocation]];
	[fc1 setIsLoaded: loaded];
	return fc1;
}
// Make three stations, A, B, and C.
// Each has an industry; B has a yard.

- (void) makeThreeStationTrain {
	ScheduledTrain *myTrain = [self makeTrainWithName: @"MyTrain"];
	
	[myTrain setStops: @"A,B,C"];
	[self setTrain: myTrain acceptsCarTypes: @"XM"];
	
	STAssertEqualsInt(3, [[myTrain stationStopObjects] count], @"Wrong number of station stops");
	STAssertEqualObjects(@"A", [[[myTrain stationStopObjects] objectAtIndex: 0] name], @"A missing");
	STAssertEqualObjects(@"B", [[[myTrain stationStopObjects] objectAtIndex: 1] name], @"B missing");
	STAssertEqualObjects(@"C", [[[myTrain stationStopObjects] objectAtIndex: 2] name], @"C missing");
	
	FreightCar *fc1 = [self makeFreightCarNamed: FREIGHT_CAR_1_NAME at: @"B" movingFrom: @"B" to: @"C" loaded: YES];
	FreightCar *fc2 = [self makeFreightCarNamed: FREIGHT_CAR_2_NAME at: @"A" movingFrom: @"A" to: @"B" loaded: YES];

	[myTrain addFreightCarsObject: fc1];
	[myTrain addFreightCarsObject: fc2];
	STAssertEqualsInt(2, [[[entireLayout_ trainWithName: @"MyTrain"] freightCars] count], @"Not enough cars in train.");
}

- (Yard*) yardAtStation: (NSString*) stationName {
	InduYard *yard = [entireLayout_ industryWithName: [NSString stringWithFormat: @"%@-yard", stationName]
									 withStationName: stationName];
	STAssertTrue([yard isYard], @"Yard is not yard");
	STAssertNotNil(yard, @"yardAtStation: no yard in %@", stationName);
	return (Yard*) yard;
}

// Assumes only one industry at each station with name town-industry.
- (Industry*) industryAtStation: (NSString*) stationName {
	InduYard *industry = [entireLayout_ industryWithName: [NSString stringWithFormat: @"%@-industry", stationName]
									 withStationName: stationName];
	STAssertNotNil(industry, @"industryAtStation: no industry in %@", stationName);
	STAssertFalse([industry isYard], @"Industry is not industry");
	return (Industry*) industry;
}

- (void)testThatEnvironmentWorks
{
    STAssertNotNil(context_, @"no persistent store");
}

- (void) checkRoute: (NSArray*) routeOfPlaces equals: (NSString*) stringOfStops {
	NSArray *stopNames = [stringOfStops componentsSeparatedByString: @","];
	STAssertEqualsInt([routeOfPlaces count], [stopNames count], @"Wrong number of stops in route.");
	int i;
	for (i=0;i<[stopNames count];i++) {
		Place *nthPlace = [routeOfPlaces objectAtIndex: i];
		NSString *expectedNthStation = [stopNames objectAtIndex: i];
		STAssertTrue([[nthPlace name] isEqualToString: expectedNthStation],
					 @"Expected %@ in route but found %@", [nthPlace name], expectedNthStation);
	}
}

NSString *FREIGHT_CAR_1_NAME = @"WP 1";
NSString *FREIGHT_CAR_2_NAME = @"UP 2";

@end
