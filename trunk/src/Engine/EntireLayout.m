//
//  EntireLayout.m
//  SwitchList
//
//  Created by Robert Bowdidge on 1/31/07.
//
// Copyright (c)2007 Robert Bowdidge,
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

#import <Foundation/Foundation.h>

#import "CarType.h"
#import "CarTypes.h"
#import "DoorAssignmentRecorder.h"
#import "EntireLayout.h"
#import "Industry.h"
#import "FreightCar.h"
#import "Place.h"
#import "Cargo.h"
#import "Yard.h"
#import "ScheduledTrain.h"
#import "StringHelpers.h"

// Normalize the strings used for division names by removing whitespace, and replacing
// empty items with nil.
NSString *NormalizeDivisionString(NSString *inString) {
	NSString *trimmedString = [inString stringByTrimmingCharactersInSet:
							   [NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if ([trimmedString length] == 0) return nil;
	return trimmedString;
}
	
// The EntireLayout object provides a place for overall queries about the whole state
// of the layout, and also hides the different database accesses from the rest of the
// program.
//

@implementation EntireLayout
- (id) initWithMOC: (NSManagedObjectContext*) moc {
	self = [super init];
	moc_ = [moc retain];
	currentDate_ = nil;
	layoutName_ = nil;
	workbench_ = nil;
	workbenchIndustry_ = nil;
	preferences_ = nil;
	carTypes_ = nil;
	[self initializeWorkbench];
	return self;
}

- (void) dealloc {
	[moc_ release];
	[currentDate_ release];
	[layoutName_ release];
	[preferences_ release];
	[workbenchIndustry_ release];
	[carTypes_ release];
	[super dealloc];
}


- (NSManagedObjectContext*) managedObjectContext {
	return moc_;
}


// Returns the industry object with the given name in the given station.
- (Industry*) industryWithName: (NSString*) industryName withStationName: (NSString*) stationName {
	Place *station = [self stationWithName: stationName];
	if (!station) return nil;

	for (Industry *i in [station industries]) {
		if ([[i name] isEqualToString: industryName]) {
			return i;
		}
	}
	return nil;
}
	
- (Place*) stationWithName: (NSString *)stationName {
	NSError *error;
    NSEntityDescription *ent = [NSEntityDescription entityForName: @"Place" inManagedObjectContext: [self managedObjectContext]];
    NSFetchRequest * req2  = [[[NSFetchRequest alloc] init] autorelease];
    [req2 setEntity: ent];
	[req2 setPredicate: [NSPredicate predicateWithFormat: @"name LIKE %@",[stationName sqlSanitizedString]]];
	NSArray *result = [[self managedObjectContext] executeFetchRequest: req2 error:&error];

	if ([result count] == 0) {
		NSLog(@"No such station named %@", stationName);
		return nil;
	}
	
	if ([result count] > 1) {
		NSLog(@"Too many stations named %@", stationName);
		// TODO(bowdidge): Correct response?
	}
	return [result objectAtIndex: 0];
}

// Find or create the workbench place and the workbench industry.  This gives us a known object
// as a default location.
// Private.
- (Place*) workbench {
	return workbench_;
}

// Return the workbench industry in the workbench place.
- (Industry*) workbenchIndustry {
	return workbenchIndustry_;
}

- (void) initializeWorkbench {
	NSError *error;
	NSEntityDescription *ent = [NSEntityDescription entityForName: @"Place" inManagedObjectContext: [self managedObjectContext]];
	NSFetchRequest * req2  = [[[NSFetchRequest alloc] init] autorelease];
	
	[req2 setEntity: ent];
	[req2 setPredicate: [NSPredicate predicateWithFormat: @"name LIKE %@",@"Workbench"]];
	NSArray *result = [[self managedObjectContext] executeFetchRequest: req2 error:&error];
	if ([result count] == 0) {
		// create
		workbench_ = [NSEntityDescription insertNewObjectForEntityForName: @"Place"
			inManagedObjectContext: [self managedObjectContext]];
		[workbench_ setValue: @"Workbench" forKey: @"name"];
		[workbench_ setIsStaging: NO];
		[workbench_ setIsOffline: YES];
	} else {
		if ([result count] != 1) {
			NSLog(@"Too many workbenches!");
		}
		workbench_ = [result objectAtIndex: 0];
	}
	[workbench_ retain];

	// Do the same for the workbench industry.

    ent = [NSEntityDescription entityForName: @"Industry" inManagedObjectContext: [self managedObjectContext]];
    req2  = [[[NSFetchRequest alloc] init] autorelease];
    [req2 setEntity: ent];
	[req2 setPredicate: [NSPredicate predicateWithFormat: @"name LIKE %@",@"Workbench"]];
	result = [[self managedObjectContext] executeFetchRequest: req2 error:&error];

	if ([result count] == 0) {
		// create
		workbenchIndustry_ = [NSEntityDescription insertNewObjectForEntityForName: @"Industry"
			inManagedObjectContext: [self managedObjectContext]];
		[workbenchIndustry_ setValue: @"Workbench" forKey: @"name"];
		[workbenchIndustry_ setLocation: workbench_];
	} else {
		if ([result count] != 1) {
			NSLog(@"Too many workbenches!");
		}
		workbenchIndustry_ = [result objectAtIndex: 0];
	}
	[workbenchIndustry_ retain];
}

// Returns all cargos, including those we won't show to the car routing algorithm because
// they're invalid in interesting ways.
// This method should generally be called either by code manipulating the database or
// presenting stuff in the UI.
- (NSArray*) allCargos {
	NSEntityDescription *ent = [NSEntityDescription entityForName: @"Cargo" inManagedObjectContext: [self managedObjectContext]];
	NSFetchRequest * req2  = [[[NSFetchRequest alloc] init] autorelease];
	[req2 setEntity: ent];
	NSError *error;
	return [[self managedObjectContext] executeFetchRequest: req2 error:&error];
}

// returns array of managed objects representing cargo stuff.
- (NSArray*) allValidCargos {
	NSEntityDescription *ent = [NSEntityDescription entityForName: @"Cargo" inManagedObjectContext: [self managedObjectContext]];
	NSFetchRequest * req2  = [[[NSFetchRequest alloc] init] autorelease];
	[req2 setEntity: ent];
	[req2 setPredicate: [NSPredicate predicateWithFormat: @"(source != nil) AND (destination != nil)"]];
	NSError *error;
	return [[self managedObjectContext] executeFetchRequest: req2 error:&error];
}

// returns all cargos that are guaranteed to appear each day.
- (NSArray*) allFixedRateCargos {
	NSEntityDescription *ent = [NSEntityDescription entityForName: @"Cargo" inManagedObjectContext: [self managedObjectContext]];
	NSFetchRequest * req2  = [[[NSFetchRequest alloc] init] autorelease];
	[req2 setEntity: ent];
	[req2 setPredicate: [NSPredicate predicateWithFormat: @"(source != nil) AND (destination != nil) AND (priority == 1)"]];
	NSError *error;
	return [[self managedObjectContext] executeFetchRequest: req2 error:&error];
}

// Returns all cargos that are chosen randomly.
- (NSArray*) allNonFixedRateCargos {
	NSEntityDescription *ent = [NSEntityDescription entityForName: @"Cargo" inManagedObjectContext: [self managedObjectContext]];
	NSFetchRequest * req2  = [[[NSFetchRequest alloc] init] autorelease];
	[req2 setEntity: ent];
	[req2 setPredicate: [NSPredicate predicateWithFormat: @"(source != nil) AND (destination != nil) AND (priority == 0)"]];
	NSError *error;
	return [[self managedObjectContext] executeFetchRequest: req2 error:&error];
}

// Calculates the average number of loads per day based on the cargos defined.
- (int) loadsPerDay {
	int curSum=0;
	id thisCargo;
	NSArray *allCargos = [self allNonFixedRateCargos];
	NSEnumerator *e = [allCargos objectEnumerator];
	while ((thisCargo = [e nextObject]) != nil) {
		int thisCargoCarsPerMonth = [[thisCargo carsPerMonth] intValue];
		curSum += thisCargoCarsPerMonth;
	}
	return curSum / 30;
}

// returns array of freight car managed objects that have loaded flag set or where cargo isn't NULL.
- (NSArray*) allReservedFreightCars {
	NSEntityDescription *ent = [NSEntityDescription entityForName: @"FreightCar" inManagedObjectContext: [self managedObjectContext]];
	NSFetchRequest * req2  = [[[NSFetchRequest alloc] init] autorelease];
	[req2 setEntity: ent];
	[req2 setPredicate: [NSPredicate predicateWithFormat: @"((cargo != nil) OR (loaded == YES)) AND currentLocation.name != 'Workbench'"]];
	NSError *error;
	return [[self managedObjectContext] executeFetchRequest: req2 error:&error];
}

// returns array of freight car managed objects that have loaded flag set or where cargo isn't NULL.
- (NSArray*) allFreightCarsOnWorkbench {
	NSEntityDescription *ent = [NSEntityDescription entityForName: @"FreightCar" inManagedObjectContext: [self managedObjectContext]];
	NSFetchRequest * req2  = [[[NSFetchRequest alloc] init] autorelease];
	[req2 setEntity: ent];
	[req2 setPredicate: [NSPredicate predicateWithFormat: @"currentLocation.name == 'Workbench'"]];
	NSError *error;
	return [[self managedObjectContext] executeFetchRequest: req2 error:&error];
}

// returns array of freight car managed objects that have loaded flag set or where cargo isn't NULL.
- (NSArray*) allFreightCarsOnLayout {
	NSEntityDescription *ent = [NSEntityDescription entityForName: @"FreightCar" inManagedObjectContext: [self managedObjectContext]];
	NSFetchRequest * req2  = [[[NSFetchRequest alloc] init] autorelease];
	[req2 setEntity: ent];
	[req2 setPredicate: [NSPredicate predicateWithFormat: @"currentLocation.name != 'Workbench'"]];

    NSSortDescriptor *ind1 = [[[NSSortDescriptor alloc] initWithKey: @"reportingMarks" ascending: YES] autorelease];
	NSMutableArray *sortDescs = [NSMutableArray arrayWithObject: ind1];
	[req2 setSortDescriptors: sortDescs];

    NSError *error;
	return [[self managedObjectContext] executeFetchRequest: req2 error:&error];
}

- (NSArray*) allCarTypes {
	NSError *error;
	NSEntityDescription *ent = [NSEntityDescription entityForName: @"CarType" inManagedObjectContext: [self managedObjectContext]];
	NSFetchRequest * req2  = [[[NSFetchRequest alloc] init] autorelease];
	[req2 setEntity: ent];

    NSSortDescriptor *ind1 = [[[NSSortDescriptor alloc] initWithKey: @"carTypeName" ascending: YES] autorelease];
	NSMutableArray *sortDescs = [NSMutableArray arrayWithObject: ind1];
	[req2 setSortDescriptors: sortDescs];

    NSArray *carTypes = [[self managedObjectContext] executeFetchRequest: req2 error:&error];
	return carTypes;
}

- (CarType*) carTypeForName: (NSString*) carType {
	NSArray *allCarTypes = [self allCarTypes];
	for (CarType *ct in allCarTypes) {
		if ([[ct carTypeName] isEqualToString: carType]) {
			return ct;
		}
	}
	// Car type not found.
	return nil;
}

- (NSArray*) allYards {
	NSError *error;
	NSEntityDescription *ent = [NSEntityDescription entityForName: @"Yard" inManagedObjectContext: [self managedObjectContext]];
	NSFetchRequest * req2  = [[[NSFetchRequest alloc] init] autorelease];
	[req2 setEntity: ent];
	NSArray *cars = [[self managedObjectContext] executeFetchRequest: req2 error:&error];
	return cars;
}

- (NSArray*) allFreightCars {
	NSError *error;
	NSEntityDescription *ent = [NSEntityDescription entityForName: @"FreightCar" inManagedObjectContext: [self managedObjectContext]];
	NSFetchRequest * req2  = [[[NSFetchRequest alloc] init] autorelease];
	[req2 setEntity: ent];

	// Sort by reporting marks to ensure consistent sort order..
	// TODO(bowdidge): Sort by objectID for a bit more randomness so cars with reporting marks that 
	// sort later aren't always the ones left behind.
	NSSortDescriptor *ind1 = [[[NSSortDescriptor alloc] initWithKey: @"reportingMarks" ascending: YES] autorelease];
	NSMutableArray *sortDescs = [NSMutableArray arrayWithObject: ind1];
	[req2 setSortDescriptors: sortDescs];

	return [[self managedObjectContext] executeFetchRequest: req2 error:&error];
}

- (NSArray*) allFreightCarsNotInTrain {
	NSError *error;
	
	NSEntityDescription *ent = [NSEntityDescription entityForName: @"FreightCar" inManagedObjectContext: [self managedObjectContext]];
	NSFetchRequest * req2  = [[[NSFetchRequest alloc] init] autorelease];
	[req2 setEntity: ent];
	[req2 setPredicate: [NSPredicate predicateWithFormat: @"currentTrain == nil"]];

	// Sort by reporting marks to ensure consistent sort order.
	// TODO(bowdidge): Sort by objectID for a bit more randomness so cars with reporting marks that 
	// sort later aren't always the ones left behind.
	NSSortDescriptor *ind1 = [[[NSSortDescriptor alloc] initWithKey: @"reportingMarks" ascending: YES] autorelease];
	NSMutableArray *sortDescs = [NSMutableArray arrayWithObject: ind1];
	[req2 setSortDescriptors: sortDescs];
	
	return [[self managedObjectContext] executeFetchRequest: req2 error:&error];
}

- (NSArray*) allAvailableFreightCars {
	NSEntityDescription *ent = [NSEntityDescription entityForName: @"FreightCar" inManagedObjectContext: [self managedObjectContext]];
	NSFetchRequest * req2  = [[[NSFetchRequest alloc] init] autorelease];
	[req2 setEntity: ent];
	[req2 setPredicate: [NSPredicate predicateWithFormat: @"cargo == nil AND NOT currentLocation.name LIKE 'Workbench'"]];
	NSError *error;
	return [[self managedObjectContext] executeFetchRequest: req2 error:&error];
}

// TODO(bowdidge): Move to yard report, rewrite not to use database?
- (NSArray*) allFreightCarsInYard {
	NSEntityDescription *ent = [NSEntityDescription entityForName: @"FreightCar" inManagedObjectContext: [self managedObjectContext]];
	NSFetchRequest * req2  = [[[NSFetchRequest alloc] init] autorelease];
	[req2 setEntity: ent];
	NSSortDescriptor *ind1 = [[[NSSortDescriptor alloc] initWithKey: @"reportingMarks" ascending: YES] autorelease];
	NSSortDescriptor *ind2 = [[[NSSortDescriptor alloc] initWithKey: @"currentLocation.name" ascending: YES] autorelease];
	NSMutableArray *sortDescs = [NSMutableArray array];
	[sortDescs addObject: ind2];
	[sortDescs addObject: ind1];
	[req2 setSortDescriptors: sortDescs];

	NSError *error;
	NSMutableArray *result = [NSMutableArray array];
	NSArray *cars = [[self managedObjectContext] executeFetchRequest: req2 error:&error];
	for (FreightCar *car in cars) {
		if ([[car currentLocation] isYard]) {
			[result addObject: car];
		}
	}
	return result;
}

- (NSArray*) allFreightCarsSortedByIndustry {
	// how many freight cars?
	NSEntityDescription *ent = [NSEntityDescription entityForName: @"FreightCar" inManagedObjectContext: [self managedObjectContext]];
	NSFetchRequest * req2  = [[[NSFetchRequest alloc] init] autorelease];
	[req2 setEntity: ent];
	NSSortDescriptor *ind1 = [[[NSSortDescriptor alloc] initWithKey: @"currentLocation.location.name" ascending: YES] autorelease];
	NSSortDescriptor *ind2 = [[[NSSortDescriptor alloc] initWithKey: @"currentLocation.name" ascending: YES] autorelease];
	NSSortDescriptor *ind3 = [[[NSSortDescriptor alloc] initWithKey: @"reportingMarks" ascending: YES] autorelease];
	NSMutableArray *sortDescs = [NSMutableArray array];
	[sortDescs addObject: ind1];
	[sortDescs addObject: ind2];
	[sortDescs addObject: ind3];
	[req2 setSortDescriptors: sortDescs];
	NSError *error;
	return [[self managedObjectContext] executeFetchRequest: req2 error:&error];
}

// Returns one freight car with matching reporting marks, or nil if none exist.
- (FreightCar*) freightCarWithName: (NSString*) name {
	NSError *error;
	NSEntityDescription *ent = [NSEntityDescription entityForName: @"FreightCar" inManagedObjectContext: [self managedObjectContext]];
	NSFetchRequest * req2  = [[[NSFetchRequest alloc] init] autorelease];
	[req2 setEntity: ent];
	[req2 setPredicate: [NSPredicate predicateWithFormat: @"reportingMarks LIKE %@",[name sqlSanitizedString]]];
	NSArray *result = [[self managedObjectContext] executeFetchRequest: req2 error:&error];
	
	if ([result count] == 0) {
		return nil;
	}
	return [result objectAtIndex: 0];
}
	

// Returns an array of all industries that can receive cargo.
- (NSArray*) allIndustries {
	// Sort non-staging first, then sort by location, then sort alphabetically by name.
	NSEntityDescription *ent = [NSEntityDescription entityForName: @"Place" inManagedObjectContext: [self managedObjectContext]];
	NSEntityDescription *indEnt = [NSEntityDescription entityForName: @"Industry" inManagedObjectContext: [self managedObjectContext]];
	NSFetchRequest * req2  = [[[NSFetchRequest alloc] init] autorelease];
	[req2 setEntity: ent];
	NSSortDescriptor *ind1 = [[[NSSortDescriptor alloc] initWithKey: @"isOffline" ascending: YES] autorelease];
	NSSortDescriptor *ind2 = [[[NSSortDescriptor alloc] initWithKey: @"name" ascending: YES] autorelease];

	NSMutableArray *sortDescs = [NSMutableArray array];
	[sortDescs addObject: ind1];
	[sortDescs addObject: ind2];
	[req2 setSortDescriptors: sortDescs];
	NSError *error;
	NSArray *listOfPlaces =  [[self managedObjectContext] executeFetchRequest: req2 error:&error];
	// Now convert to list of industries
	NSMutableArray *allIndustries = [NSMutableArray array];
	
	NSEnumerator *placeEnum = [listOfPlaces objectEnumerator];
	Place* place;
	while ((place = [placeEnum nextObject]) != nil) {
		if ([[place industries] count] == 0) continue;
		[req2 setEntity: indEnt];
		NSPredicate *industriesHerePred = [NSPredicate predicateWithFormat:
										   [NSString stringWithFormat: @"location.name LIKE '%@'",[[place name] sqlSanitizedString]]];
		[req2 setPredicate: industriesHerePred];
		[req2 setSortDescriptors: [NSArray arrayWithObject: ind2]];
		NSArray *industries = [[self managedObjectContext] executeFetchRequest: req2 error: &error];
		NSEnumerator *indEnum = [industries objectEnumerator];
		Industry *ind;
		while ((ind = [indEnum nextObject]) != nil) {
			if ([ind canReceiveCargo]) {
				[allIndustries addObject: ind];
			}
		}
	}
	
	return allIndustries;
}

// Returns one industry or yard with the given name, or nil if none exists.
- (InduYard*) industryOrYardWithName: (NSString*) name {
	NSError *error;
	NSEntityDescription *ent = [NSEntityDescription entityForName: @"InduYard" inManagedObjectContext: [self managedObjectContext]];
	NSFetchRequest * req2  = [[[NSFetchRequest alloc] init] autorelease];
	[req2 setEntity: ent];
	[req2 setPredicate: [NSPredicate predicateWithFormat: @"name LIKE %@",[name sqlSanitizedString]]];
	NSArray *result = [[self managedObjectContext] executeFetchRequest: req2 error:&error];
	
	if ([result count] == 0) {
		return nil;
	}
	return [result objectAtIndex: 0];
}


// Returns the list of all stations (Places) on the layout in no particular order.
- (NSArray*) allStations {
	NSEntityDescription *ent = [NSEntityDescription entityForName: @"Place" inManagedObjectContext: [self managedObjectContext]];
	NSFetchRequest * req2  = [[[NSFetchRequest alloc] init] autorelease];
	[req2 setEntity: ent];
	NSError *error;
	return [[self managedObjectContext] executeFetchRequest: req2 error:&error];
}

// Returns the list of all stations either on the layout or in staging, in alphabetical order.
// Offline stations are not included.
- (NSArray*) allOnlineStationsSortedOrder {
	NSEntityDescription *ent = [NSEntityDescription entityForName: @"Place" inManagedObjectContext: [self managedObjectContext]];
	NSFetchRequest *req2  = [[[NSFetchRequest alloc] init] autorelease];
	[req2 setPredicate: [NSPredicate predicateWithFormat: @"isOffline != YES"]];
	[req2 setEntity: ent];
	NSSortDescriptor *nameSortDesc = [[[NSSortDescriptor alloc] initWithKey: @"name" ascending: YES] autorelease];
	[req2 setSortDescriptors: [NSArray arrayWithObject: nameSortDesc]];
	NSError *error;
	return [[self managedObjectContext] executeFetchRequest: req2 error:&error];
}

// Helper routine for displaying lists of stations in templates.
- (NSArray*) allStationsSortedOrder {
	NSArray *stations = [self allStations];
	NSArray* all = [stations sortedArrayUsingSelector: @selector(compareNames:)];
	return all;
}

- (NSArray*) allStationsInStaging {
	NSArray *allStations = [self allStations];
	NSMutableArray *allStaging = [NSMutableArray array];
	for (Place *p in allStations) {
		if ([p isStaging] == YES) {
			[allStaging addObject: p];
		}
	}
	return allStaging;
}

- (NSArray*) allStationNamesInStaging {
	NSArray *allStations = [self allStations];
	NSMutableArray *allStaging = [NSMutableArray array];
	for (Place *p in allStations) {
		if ([p isStaging] == YES) {
			[allStaging addObject: [p name]];
		}
	}
	return allStaging;
}

// Returns the Places that can serve as destinations for a car
// going to an offline location.
- (NSArray*) allStationsInStagingAcceptingCar: (FreightCar*) car {
	NSString *targetDivision;
	if ([car cargo] == nil) {
		targetDivision = [car homeDivision];
	} else {
		// Where are we going next according to the cargo?  That says which
		// division we're aiming for.
		InduYard *nextIndustry = [car nextIndustry];
		targetDivision = [nextIndustry division];
	}
	
	NSArray *allStations = [self allStations];
	NSMutableArray *allStaging = [NSMutableArray array];
	for (Place *p in allStations) {
		if ([p isStaging] == YES) {
			for (Yard* y in [p yards]) {
				if ([y acceptsDivision: targetDivision]) {
					[allStaging addObject: p];
					break;
				}
			}
		}
	}
	return allStaging;
}

- (NSArray*) allFreightCarsReportingMarkOrder {
	// how many freight cars?
	NSEntityDescription *ent = [NSEntityDescription entityForName: @"FreightCar" inManagedObjectContext: [self managedObjectContext]];
	NSFetchRequest * req2  = [[[NSFetchRequest alloc] init] autorelease];
	[req2 setEntity: ent];
	NSSortDescriptor *ind2 = [[[NSSortDescriptor alloc] initWithKey: @"reportingMarks" ascending: YES] autorelease];
	NSMutableArray *sortDescs = [NSMutableArray array];
	[sortDescs addObject: ind2];
	[req2 setSortDescriptors: sortDescs];
	NSError *error;
	return [[self managedObjectContext] executeFetchRequest: req2 error:&error];
}

- (NSArray*) allLoadedFreightCarsReportingMarkOrder {
	// Find all freight cars with cargo specified.
	// List these, naming their current location, whether it's been loaded, origin, and destination.
	NSEntityDescription *ent = [NSEntityDescription entityForName: @"FreightCar" inManagedObjectContext: [self managedObjectContext]];
	NSFetchRequest * req2  = [[[NSFetchRequest alloc] init] autorelease];
	[req2 setEntity: ent];
	NSSortDescriptor *ind2 = [[[NSSortDescriptor alloc] initWithKey: @"reportingMarks" ascending: YES] autorelease];
	NSMutableArray *sortDescs = [NSMutableArray array];
	[sortDescs addObject: ind2];
	[req2 setSortDescriptors: sortDescs];
	[req2 setPredicate: [NSPredicate predicateWithFormat: @"cargo != nil"]];
	NSError *error;
	return [[self managedObjectContext] executeFetchRequest: req2 error:&error];
}

- (ScheduledTrain*) trainWithName: (NSString*) trainName {
	NSError *error;
	NSEntityDescription *ent = [NSEntityDescription entityForName: @"ScheduledTrain" inManagedObjectContext: [self managedObjectContext]];
	NSFetchRequest * req2  = [[[NSFetchRequest alloc] init] autorelease];
	[req2 setEntity: ent];
	[req2 setPredicate: [NSPredicate predicateWithFormat: @"name LIKE %@",[trainName sqlSanitizedString]]];
	NSArray *result = [[self managedObjectContext] executeFetchRequest: req2 error:&error];
	
	if ([result count] == 0) {
		NSLog(@"No such train named %@", trainName);
		return nil;
	}
	
	if ([result count] > 1) {
		NSLog(@"Too many trains named %@", trainName);
		// TODO(bowdidge): Correct response?
	}
	return [result objectAtIndex: 0];
}	


- (NSArray*) allTrains {
	NSError *error;
	NSEntityDescription *ent = [NSEntityDescription entityForName: @"ScheduledTrain" inManagedObjectContext: [self managedObjectContext]];
	NSFetchRequest * req2  = [[[NSFetchRequest alloc] init] autorelease];
	[req2 setEntity: ent];
	NSSortDescriptor *ind1 = [[[NSSortDescriptor alloc] initWithKey: @"name" ascending: YES] autorelease];
	NSMutableArray *sortDescs = [NSMutableArray arrayWithObject: ind1];
	[req2 setSortDescriptors: sortDescs];
	NSArray *result = [[self managedObjectContext] executeFetchRequest: req2 error:&error];
	return result;
}

// Returns list of freight cars that have reached their destination and can have their loaded state changed.
- (NSArray*) allFreightCarsAtDestination  {
	// There's two definitions for "arrived". 
	// 1: car is loaded and car has cargo and the current location is the cargo's destination
	// 2: car is empty and car has cargo and current location is car's source
	
	NSArray *cars = [self allFreightCars];
	NSMutableArray *result = [NSMutableArray array];
	NSEnumerator *e = [cars objectEnumerator];
	FreightCar *car;
	while ((car = [e nextObject]) != nil) {
		BOOL isLoaded = [car isLoaded];
		InduYard *carIndustryLocation = [car currentLocation];
		Cargo *cargo = [car cargo];
		//NSString *carName = [car reportingMarks];
		
		// Any car in staging without a cargo is fair game.
		if (cargo == nil) {
			// Not at destination because it has no destination.
			continue;
		}
		// Is the car where it's supposed to be?
		id cargoDest = [cargo destination];
		id cargoSrc = [cargo source];
		
		if (((isLoaded == YES) && (carIndustryLocation == cargoDest)) ||
			((isLoaded == NO) && (carIndustryLocation == cargoSrc))) {
			[result addObject: car];
		} else if ((isLoaded == NO) && ([cargo isSourceOffline]) && ([car inStaging] == YES)) {
			[result addObject: car];
		} else if ((isLoaded == YES) && ([cargo isDestinationOffline]) && ([car inStaging] == YES)) {
			// if the car is in an offstage location and the target industry is in an offstage location
			// and the current offstage location 
			// TODO(bowdidge): are we in an appropriate staging yard?
			[result addObject: car];
		}
	}
	return result;
}

/* Sorting for doing switch lists in as-visited order. */
NSInteger sortCarsByCurrentIndustry(FreightCar *a, FreightCar *b, void *context) {
	InduYard *currentA = [a currentLocation];
	InduYard *currentB = [b currentLocation];
	
	if (currentA == nil || currentB == nil) {
		return [[a reportingMarks] compare: [b reportingMarks]];
	}

	int currentResult = [[[currentA location] name] compare: [[currentB location] name]];
	if (currentResult != NSOrderedSame) return currentResult;

	currentResult = ([[[a currentLocation] name] compare: [[b currentLocation] name]]);
	if (currentResult != NSOrderedSame) return currentResult;
	
	// Compare by reporting marks when all else fails.
	return [[a reportingMarks] compare: [b reportingMarks]];
}

// Sorts cars by destination industry.  Assumes all cars are in the same town.
NSInteger sortCarsByDestinationIndustry(FreightCar *a, FreightCar *b, void *context) {
	InduYard *destA = [a nextStop];
	InduYard *destB = [b nextStop];
	
	if ((destA == nil) || (destB == nil)) {
		return [[a reportingMarks] compare: [b reportingMarks]];
	}
	
	int compareResult = [[[destA location] name] compare: [[destB location] name]];
	if (compareResult != NSOrderedSame) {
		return compareResult;
	}
	
	compareResult = [[destA name] compare: [destB name]];
	if (compareResult != NSOrderedSame) {
		return compareResult;
	}
	
	// Do cars in reporting mark order when all else matches.
	return [[a reportingMarks] compare: [b reportingMarks]];
}

- (id) getLayoutInfo {
	NSError *error;

	NSEntityDescription *ent = [NSEntityDescription entityForName: @"LayoutInfo" inManagedObjectContext: [self managedObjectContext]];
	NSFetchRequest * req2  = [[[NSFetchRequest alloc] init] autorelease];
	[req2 setEntity: ent];
	NSArray *result = [[self managedObjectContext] executeFetchRequest: req2 error:&error];
	
	if ([result count] == 0) {
		// Create one.
		NSEntityDescription *layoutInfoEntity = [NSEntityDescription entityForName: @"LayoutInfo" inManagedObjectContext: [self managedObjectContext]];
		NSManagedObject *obj = [[[NSManagedObject alloc] initWithEntity: layoutInfoEntity insertIntoManagedObjectContext: [self managedObjectContext]] autorelease];
		[obj setValue: [NSDate dateWithTimeIntervalSinceNow: 0] forKey: @"currentDate"];
		[obj setValue: @"" forKey: @"layoutName"];
		return obj;
	} 
	return [result objectAtIndex: 0];
}

- (NSDate*) currentDate {
	if (currentDate_ != nil) return currentDate_;

	id layoutInfo = [self getLayoutInfo];
	[currentDate_ autorelease];
	currentDate_ = [[layoutInfo valueForKey: @"currentDate"] retain];
	if (currentDate_ == nil) 
		currentDate_ = [[NSDate date] retain];
	return currentDate_;
}

- (void) setCurrentDate: (NSDate*) date {
	id layoutInfo = [self getLayoutInfo];
	[layoutInfo setValue: date forKey: @"currentDate"];
	[currentDate_ autorelease];
	currentDate_ = [date retain];
}

- (NSString*) layoutName {
	if (layoutName_ != nil) return layoutName_;
	id layoutInfo = [self getLayoutInfo];
	layoutName_ = [[layoutInfo valueForKey: @"layoutName"] retain];
	if (layoutName_ == nil) layoutName_ = @"";
	return [[layoutName_ retain] autorelease];
}

- (void) setLayoutName: (NSString*) layoutName {
	id layoutInfo = [self getLayoutInfo];
	[layoutInfo setValue: layoutName forKey: @"layoutName"];
	[layoutName_ autorelease];
	layoutName_ = [layoutName retain];
}

// For testing only.  Set the raw preferences data.
- (void) setPreferencesDictionary: (NSData*) prefData {
	id layoutInfo = [self getLayoutInfo];
    [layoutInfo setValue: prefData forKey: @"layoutPreferences"];
	[preferences_ release];
	preferences_ = nil;
}

- (NSMutableDictionary*) getPreferencesDictionary { 
	if (preferences_ != nil) return preferences_;
	id layoutInfo = [self getLayoutInfo];
	NSData *prefData = [layoutInfo valueForKey: @"layoutPreferences"];
	if (prefData == nil) {
		[preferences_ release];
		preferences_ = [[NSMutableDictionary alloc] init];
	} else {
        // Try first as a keyed archive, then as the older (SwitchList-1.1)
        // plain archive.
		// TODO(bowdidge): Inappropriate for iOS.
		@try {
          preferences_ = [[NSKeyedUnarchiver unarchiveObjectWithData: prefData] retain];
		} @catch (NSException *exception) {
			preferences_ = nil;
		}
		
        if (preferences_ == nil) {
#if !defined(TARGET_OS_IPHONE) || !TARGET_OS_IPHONE
            @try {
                // Try to unarchive with NSUnarchiver.
                preferences_ = [[NSUnarchiver unarchiveObjectWithData: prefData] retain];
            }
            @catch (NSException *exception) {
                // Couldn't be parsed.
                preferences_ = [[NSMutableDictionary alloc] init];
            }
#else
            // On iOS, assume the data is invalid and create a new dictionary.
            preferences_ = [[NSMutableDictionary alloc] init];
#endif
        }
	}
	return preferences_;
}

- (void) writePreferencesDictionary {
	id layoutInfo = [self getLayoutInfo];
	// In SwitchList-1.1 and before, an NSArchiver was used here.
	[layoutInfo setValue: [NSKeyedArchiver archivedDataWithRootObject: preferences_] forKey: @"layoutPreferences"];

	[layoutInfo didChangeValueForKey: @"layoutPreferences"];
}

// Removes leading and trailing spaces in string.
- (NSString*) stringRemovingWhitespace: (NSString*) s {
	return [s stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
}

// Normalize reporting marks by removing leading and trailing spaces, and replacing 
- (NSString*) cleanReportingMarks: (NSString*) originalMarks {
	NSString *cleanEnds = [self stringRemovingWhitespace: originalMarks];
	NSString *cleanMiddle = [cleanEnds stringByNormalizingCharacterInSet: [NSCharacterSet whitespaceCharacterSet]
															  withString: @" "];
	return cleanMiddle;
}

// Creates a freight car (and car type, if needed) in the database from cleaned reporting
// marks and car type.
- (void) createFreightCar: (NSString *) reportingMarks withCarType: (NSString *) carTypeName  {
	FreightCar *freightCar = [NSEntityDescription insertNewObjectForEntityForName:@"FreightCar"
														   inManagedObjectContext: moc_];
	[freightCar setReportingMarks: reportingMarks];
	CarType *freightCarType = [self carTypeForName: carTypeName];
	if (freightCarType == nil) {
		// Car type does not exist, create it.
		freightCarType = [NSEntityDescription insertNewObjectForEntityForName:@"CarType" 
													   inManagedObjectContext:moc_];
		[freightCarType setCarTypeName: carTypeName];
		[freightCarType setCarTypeDescription: @""];
	}
	[freightCar setCarTypeRel: freightCarType];
}

/**
 * Converts a text file containing freight cars (reporting marks or reporting marks and car type) into
 * new freight cars in the database.  Return the number of cars imported, and any errors in outErrors.
 */
- (int) importFreightCarsUsingString: (NSString*) input errors: (NSString**) outErrors {
	int carsCreated = 0;
	NSArray *freightCarLines = [input componentsSeparatedByString: @"\n"];
	NSMutableString *warnings = [NSMutableString string];
	int line = 0;
	int warningCount = 0;
	for (NSString *freightCarLine in freightCarLines) {
		line++;
		NSArray *carComponents = [freightCarLine componentsSeparatedByString: @","];
		if ([carComponents count] == 1) {
			// Try separating with tabs
			carComponents = [freightCarLine componentsSeparatedByString: @"\t"];
		}
		NSString *freightCarNameCleaned = [self cleanReportingMarks: [carComponents objectAtIndex: 0]];
		NSString *freightCarTypeName = nil;
		if ([carComponents count] >= 2) {
			// Allow extra commas.  Assume second must be car type.
			freightCarTypeName = [self stringRemovingWhitespace: [carComponents objectAtIndex: 1]];
		}
		if ([freightCarNameCleaned length] == 0) {
			// Ignore blank lines.
		} else if (false) {
			// Error detection goes here.
			warningCount++;
			if (warningCount == 4) {
				[warnings appendFormat: @"Other problems seen but ignored."];
			} else if (warningCount < 4) {
				[warnings appendFormat: @"Blank freight car name at line %d\n", line];
			} else {
				// Ignore.
			}
		} else {
			[self createFreightCar: freightCarNameCleaned withCarType: freightCarTypeName];
			carsCreated++;
		}
	}
	if ([warnings length] != 0) {
		*outErrors = warnings;
	} else {
		*outErrors = nil;
	}
	return carsCreated;
}
@end
