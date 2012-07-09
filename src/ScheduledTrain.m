// 
//  ScheduledTrain.m
//  SwitchList
//
//  Created by Robert Bowdidge on 6/9/06.
//
// Copyright (c)2006 Robert Bowdidge,
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

#import "ScheduledTrain.h"

#import "CarType.h"
#import "FreightCar.h"
#import "Industry.h"
#import "Place.h"
#import "StringHelpers.h"
#import "Yard.h"

@implementation ScheduledTrain 

@dynamic freightCars;

// Code run the first time an object is created. 
// Make sure any initial values are sane.
- (void)awakeFromInsert {
	[super awakeFromInsert];
	if ([self name]== nil) {
		[self setName: @"New train"];
		// [self setAcceptedCarTypes: @"Any"];
	}
}

- (NSNumber *)maxLength 
{
    NSNumber * tmpValue;
    
    [self willAccessValueForKey: @"maxLength"];
    tmpValue = [self primitiveValueForKey: @"maxLength"];
    [self didAccessValueForKey: @"maxLength"];
    
    return tmpValue;
}

- (void)setMaxLength:(NSNumber *)value 
{
    [self willChangeValueForKey: @"maxLength"];
    [self setPrimitiveValue: value forKey: @"maxLength"];
    [self didChangeValueForKey: @"maxLength"];
}

- (NSString *)acceptedCarTypes 
{
    NSString * tmpValue;
    
    [self willAccessValueForKey: @"acceptedCarTypes"];
    tmpValue = [self primitiveValueForKey: @"acceptedCarTypes"];
    [self didAccessValueForKey: @"acceptedCarTypes"];
    
    return tmpValue;
}

// Returns a string containing the comma-separated types of
// car types picked up by this train.  This is treated
// like a valid property and marked as invalid so parts of the 
// UI will re-query it.
- (NSString*) acceptedCarTypesString {
	NSArray *carTypes = [self primitiveValueForKey: @"acceptedCarTypesRel"];
    NSMutableArray *carTypeNames = [NSMutableArray array];
	for (CarType *ct in carTypes) {
		[carTypeNames addObject: [ct carTypeName]];
	}
	[carTypeNames sortUsingSelector: @selector(compare:)];
	
	if ([carTypeNames count] == 0) {
		return @"All car types";
	}
	
	return [carTypeNames componentsJoinedByString: @", "];
}

- (void) setCarTypesAcceptedRel: (NSSet*) currentCarTypes {
	[self willChangeValueForKey: @"carTypesAcceptedRel"];
	[self willChangeValueForKey: @"acceptedCarTypesString"];
	[self setPrimitiveValue: currentCarTypes forKey: @"carTypesAcceptedRel"];
	[self didChangeValueForKey: @"carTypesAcceptedRel"];
	[self didChangeValueForKey: @"acceptedCarTypesString"];
}

//- (void)setAcceptedCarTypes:(NSString *)value 
//{
//    [self willChangeValueForKey: @"acceptedCarTypes"];
//    [self setPrimitiveValue: value forKey: @"acceptedCarTypes"];
//    [self didChangeValueForKey: @"acceptedCarTypes"];
//}

- (BOOL) acceptsCarType: (CarType*) carType {
	NSSet *acceptedCarTypes = [self valueForKey: @"acceptedCarTypesRel"];
	// No car types = all car types.
	if ([acceptedCarTypes count] == 0) return YES;
	
	// Car type nil?  That means we've got a car we don't care about the car type on.
	// It'll come along.
	if (carType == nil) return YES;
	return ([acceptedCarTypes containsObject: carType]);
}
	
/* Would this train accept this kind of car? */
- (BOOL) acceptsCar: (FreightCar*) car {
	if ([car carTypeRel] == nil) return YES;
	if ([[self valueForKey: @"acceptedCarTypesRel"] count] == 0) return YES;
	// Removed explicit check for "any".
	
	return ([[self valueForKey: @"acceptedCarTypesRel"] containsObject: [car carTypeRel]]);
}

- (BOOL) containsCar: (FreightCar*) car {
	return [[self primitiveValueForKey: @"freightCars"] containsObject: car];
}

- (NSString *)name {
    NSString *tmpValue;
    
    [self willAccessValueForKey: @"name"];
    tmpValue = [self primitiveValueForKey: @"name"];
    [self didAccessValueForKey: @"name"];
    
    return tmpValue;
}

- (void)setName:(NSString *)value 
{
    [self willChangeValueForKey: @"name"];
    [self setPrimitiveValue: value forKey: @"name"];
    [self didChangeValueForKey: @"name"];
}

// Set the list of station stops as a string of station names separated by either
// a comma (OLD_SEPARATOR_FOR_STOPS) or more complicated separator (NEW_SEPARATOR_FOR_STOPS).
// This is For internal use only; all real callers should use stationsInOrder which will give
// a list of Place objects for each station.
- (NSString *)stops 
{
    NSString * tmpValue;
    
    [self willAccessValueForKey: @"stops"];
    tmpValue = [self primitiveValueForKey: @"stops"];
    [self didAccessValueForKey: @"stops"];
    
    return tmpValue;
}

- (void)setStops:(NSString *)value 
{
    [self willChangeValueForKey: @"stops"];
	[self willChangeValueForKey: @"listOfStationsString"];
    [self setPrimitiveValue: value forKey: @"stops"];
    [self didChangeValueForKey: @"listOfStationsString"];
    [self didChangeValueForKey: @"stops"];
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

// The list of stations is just a string of names.  SwitchList formerly used
// the convention that the station names were separated by commas, but that
// introduced the risk of problems if someone chose a station name with a
// comma.  The new separator string uses pattern unlikely in station names.
// Change was in version 0.9.5, and did not involve revising the file format.
NSString *NEW_SEPARATOR_FOR_STOPS = @"++&&";
NSString *OLD_SEPARATOR_FOR_STOPS = @",";


// Changes the train's list of stops.  Array is list of station objects
// in order.
- (NSArray*) stationsInOrder {
	// First, parse the string containing the list of stations.
	// Assume we're using the old one.
	NSString *separator = NEW_SEPARATOR_FOR_STOPS;
	NSString *stops = [self stops];
	if ([stops rangeOfString: NEW_SEPARATOR_FOR_STOPS].length == 0) {
		// Old-style separator.
		separator = OLD_SEPARATOR_FOR_STOPS;
	}
	NSArray *stationNames = [stops componentsSeparatedByString: separator];
	
	// Validate the station names are valid, and produce the final list.
	NSMutableArray *stationArray = [NSMutableArray array];
	for (NSString *stationName in stationNames) {
		Place *nextStation = [self stationWithName: stationName];
		if (!nextStation) {
			NSLog(@"Station %@ from train %@'s list of stops unknown - ignoring.", stationName, [self name]);
			continue;
		}
		[stationArray addObject: nextStation];
	}
	return stationArray;
}

// List of station names, suitable for human display.
- (NSString*) listOfStationsString {
	NSArray *stations = [self stationsInOrder];
	NSMutableArray *stationNames = [NSMutableArray array];
	for (Place *station in stations) {
		[stationNames addObject: [station name]];
	}
	
	return [stationNames componentsJoinedByString: @", "];
}	

- (void) setStationsInOrder: (NSArray*) stationsInOrder {
	NSMutableArray *stationStopNames = [NSMutableArray array];
	for (id stationStopObject in stationsInOrder) {
		[stationStopNames addObject: [stationStopObject name]];
	}
	[self setStops: [stationStopNames componentsJoinedByString: NEW_SEPARATOR_FOR_STOPS]];
}


- (BOOL) beginsAndEndsAtSameStation {
	NSArray *allStops = [self stationsInOrder];
	if ([allStops objectAtIndex: 0] == [allStops lastObject]) {
		return YES;
	}
	return NO;
}

- (NSNumber *)minCarsToRun 
{
    NSNumber * tmpValue;
    
    [self willAccessValueForKey: @"minCarsToRun"];
    tmpValue = [self primitiveValueForKey: @"minCarsToRun"];
    [self didAccessValueForKey: @"minCarsToRun"];
    
    return tmpValue;
}

- (void)setMinCarsToRun:(NSNumber *)value 
{
    [self willChangeValueForKey: @"minCarsToRun"];
    [self setPrimitiveValue: value forKey: @"minCarsToRun"];
    [self didChangeValueForKey: @"minCarsToRun"];
}

// Cars in this train currently at the named station.
- (NSArray*) carsAtStation: (Place *) station   {
	NSMutableArray *carsAtStation  = [NSMutableArray array];
	for (FreightCar *f in [self freightCars]) {
		if ([f currentTown] == station) {
			[carsAtStation addObject: f];
		}
	}
	// Now, sort carsAtStation according to industry
	return [carsAtStation sortedArrayUsingFunction: sortCarsByDestinationIndustry context: NULL];
	
}

// Cars in this train that will go to the named station.
- (NSArray*) carsForStation: (Place *) station   {
	NSMutableArray *carsForStation  = [NSMutableArray array];
	for (FreightCar *f in [self freightCars]) {
		if ([[f nextStop] location] == station)  {
			[carsForStation addObject: f];
		}
	}
	// Now, sort carsForStation according to industry
	return [carsForStation sortedArrayUsingFunction: sortCarsByCurrentIndustry context: NULL];
	
}

- (NSArray*) sortedCarsInSet: (NSSet*) cars atStation: (Place *) station {
	NSMutableArray *carsAtStation  = [NSMutableArray array];
	for (FreightCar *f in cars ) {
		if ([f currentTown] == station) {
			[carsAtStation addObject: f];
		}
	}
	// Now, sort carsAtStation according to industry
	return [carsAtStation sortedArrayUsingFunction: sortCarsByDestinationIndustry context: nil];
	
}

// Returns a list of all freight cars in the train, sorted by the order
// the train will pick up the cars. 
- (NSArray* ) allFreightCarsInVisitOrder {
	// To sort cars for display:
	// take cars in the order that the train visits each station.
	NSMutableArray *stationsVisited = [NSMutableArray array];
	NSMutableArray *sortedList = [NSMutableArray array];
	
	NSSet *cars = [self freightCars];
	
	NSArray *stationStops = [self stationsInOrder];
	for (Place *station in stationStops) {
		if ([stationsVisited containsObject: station]) continue;
		[stationsVisited addObject: station];
		
		[sortedList addObjectsFromArray: [self sortedCarsInSet: cars atStation: station]];
		
	}
	return sortedList;
}

// Returns an array of stations with work for this train, where each
// dictionary entry includes a name for the station and a list of industries at the station
// with cars for the current train, and each industry is a dictionary with name and list
// of cars.
// Needed for implementing PICL switchlist and other by-station switchlists in the web interface.
- (NSArray*) stationsWithWork {
	NSArray *freightCars = [self allFreightCarsInVisitOrder];
	NSMutableArray *result = [NSMutableArray array];
	
	// Create temp objects for all stations, remove at end.
	NSArray *stationStops = [self stationsInOrder];
	// Contains station name if already created.
	NSMutableDictionary *stationMap = [NSMutableDictionary dictionary];
	for (Place *station in stationStops) {
		if ([stationMap objectForKey: [station name]] == nil) {
			NSMutableDictionary *stationDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
												[station name], @"name",
												[NSMutableDictionary dictionary], @"industries",
												nil];
			[result addObject: stationDict];
			[stationMap setObject: stationDict forKey: [station name]];
		}
	}

	// Run through all freight cars being handled, and insert them in the dictionary.
	for (FreightCar *fc in freightCars) {
		InduYard *start = [fc currentLocation];
		Place *startPlace = [start location];
		InduYard *end = [fc nextStop];
		Place *endPlace = [end location];
		
		NSMutableDictionary *startStationDict = [[stationMap objectForKey: [startPlace name]] objectForKey: @"industries"];	
		NSMutableDictionary *endStationDict = [[stationMap objectForKey: [endPlace name]] objectForKey: @"industries"];;

		// Make place for start.
		NSMutableDictionary *startIndustryDict = [startStationDict objectForKey: [start name]];
		if (startIndustryDict == nil) {
			startIndustryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								 [start name], @"name",
								 [NSMutableArray array], @"carsToPickUp",
								 [NSMutableArray array], @"carsToDropOff",
								 [NSNumber numberWithInt: 0], @"emptyCount",
								 [NSNumber numberWithInt: 0], @"loadsCount",
								 nil];
			[startStationDict setObject: startIndustryDict forKey: [start name]];
		}
		[[startIndustryDict objectForKey: @"carsToPickUp"] addObject: fc];		
		if ([fc isLoaded]) {
			[startIndustryDict setObject: [NSNumber numberWithInt: [[startIndustryDict objectForKey: @"loadsCount"] intValue] + 1]
								  forKey: @"loadsCount"];
		} else {
			[startIndustryDict setObject: [NSNumber numberWithInt: [[startIndustryDict objectForKey: @"emptyCount"] intValue] + 1]
								  forKey: @"emptyCount"];
			
		}
		
		// Same for end.
		NSMutableDictionary *endIndustryDict = [endStationDict objectForKey: [end name]];
		if (endIndustryDict == nil) {
			endIndustryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								 [end name], @"name",
								 [NSMutableArray array], @"carsToPickUp",
							     [NSMutableArray array], @"carsToDropOff",
								 [NSNumber numberWithInt: 0], @"emptyCount",
								 [NSNumber numberWithInt: 0], @"loadsCount",
							   nil];
			[endStationDict setObject: endIndustryDict forKey: [end name]];
		}
		[[endIndustryDict objectForKey: @"carsToDropOff"] addObject: fc];
	}

	// Run through the list of stations and remove any stations that had no work.
	NSMutableArray *stationsToRemove = [NSMutableArray array];
	for (NSMutableDictionary *station in result) {
		if ([[station objectForKey: @"industries"] count] == 0) {
			[stationsToRemove addObject: station];
		}
	}

	for (NSMutableDictionary *station in stationsToRemove) {
		[result removeObject: station];
	}
	
	return result;
}
		
- (void)addFreightCarsObject:(FreightCar *)value 
{    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    
    [self willChangeValueForKey:@"freightCars" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    
    [[self primitiveValueForKey: @"freightCars"] addObject: value];
    
    [self didChangeValueForKey:@"freightCars" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    
    [changedObjects release];
}

- (void)removeFreightCarsObject:(FreightCar *)value 
{
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    
    [self willChangeValueForKey:@"freightCars" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    
    [[self primitiveValueForKey: @"freightCars"] removeObject: value];
    
    [self didChangeValueForKey:@"freightCars" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    
    [changedObjects release];
}

@end
