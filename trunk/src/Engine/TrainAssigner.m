//
//  TrainAssigner.m
//  SwitchList
//
//  Created by Robert Bowdidge on 11/16/07.
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
//

#import "TrainAssigner.h"

#import "CarType.h"
#import "Cargo.h"
#import "DoorAssignmentRecorder.h"
#import "FreightCar.h"
#import "Industry.h"
#import "Place.h" 
#import "ScheduledTrain.h"
#import "TrainSizeVector.h"
#import "Yard.h"


//  TrainAssigner groups all the code associated with assigning cars to a train.  It sniffs the
//  set of movable freight cars out of the layout object, then assigns those cars to each train 
//  appropriately.
//
// Currently, the assigning is done by creating "reachability" graphs to show for a given car type what
// stations are accessible by a trip on a single train.  For each freight car, we find a possible route
// to take it from its source to its destination.  At any snapshot in time, the SwitchList program will
// let the car take one hop.
//
// Assumptions:
// * Cars destined for an offline industry only need to reach a staging yard accepting that car to count as "arrived."

// Permits changing logging settings at runtime.
BOOL DEBUG_CAR_ASSN = NO;

@implementation TrainAssigner

- (id) initWithLayout: (EntireLayout*) mapper trains: (NSArray*) trains useDoors: (BOOL) useDoors respectSidingLengths: (BOOL) respectSidingLengths {
	self = [super init];
	entireLayout_ = [mapper retain];
	stationReachabilityGraph_ = [[NSMutableDictionary alloc] init];
	errors_ = [[NSMutableArray alloc] init];
	assignDoors_ = useDoors;
	respectSidingLengths_ = respectSidingLengths;
	doorAssignmentRecorder_ = nil;
	arrivingCars_ = [[NSMutableDictionary alloc] init];
	randomNumberGenerator_ = [[RandomNumberGenerator alloc] init];
	allTrains_ = [trains retain];
	return self;
}

- (id) initWithLayout: (EntireLayout*) mapper trains: (NSArray*) trains useDoors: (BOOL) useDoors {
	return [self initWithLayout: mapper trains: trains useDoors: useDoors respectSidingLengths: NO];
}

- (void) dealloc {
	[entireLayout_ release];
	[stationReachabilityGraph_ release];
	[errors_ release];
	[doorAssignmentRecorder_ release];
	[arrivingCars_ release];
	[randomNumberGenerator_ release];
	[allTrains_ release];
	[super dealloc];
}

// For testing only.
- (void) setRandomNumberGenerator: (NSObject<RandomNumberGeneratorInterface>*) generator {
	[randomNumberGenerator_ release];
	randomNumberGenerator_ = [generator retain];
}

// Access the DoorAssignmentRecorder containing details about which
// door freight cars might get assigned to.
- (DoorAssignmentRecorder*) doorAssignmentRecorder {
	return doorAssignmentRecorder_;
}

// Returns list of errors found during assignment for presentation to user.
// Arranged as NSErrors, even though all represent algorithm errors.
- (NSArray*) errors {
	return errors_;
}

// Adds a newly found error to the list of problems when trying to assign cars.
- (void) addError: (NSString*) str {
	if (DEBUG_CAR_ASSN) NSLog(@"Train assigner error: %@", str);
	[errors_ addObject: str];
}

// This method generates the graph of stations reachable from another by a trip on a single
// train.  The graph is made up of dictionaries associating station names with the names of
// stations reachable.
- (NSMutableDictionary *) createStationReachabilityGraphForCarType: (CarType *) carType  {
  NSMutableDictionary *stationReachabilityGraph = [NSMutableDictionary dictionary];
	for (ScheduledTrain *tr in allTrains_) {
		if ([tr acceptsCarType: carType] == NO) continue;
		
		NSArray *stations = [tr stationsInOrder];
		int ct = [stations count];
		int i;
		for (i=0;i<ct-1;i++) {
			Place *startStation = [stations objectAtIndex: i];
			NSMutableArray *stationsReachable = [stationReachabilityGraph objectForKey: [startStation objectID]];
			if (stationsReachable == nil) {
				stationsReachable = [NSMutableArray array];
				[stationReachabilityGraph setObject: stationsReachable forKey: [startStation objectID]];
			}
			// Get all stations from one after current to end.
			NSArray *potentialStations = [stations subarrayWithRange:NSMakeRange(i+1,(ct-i-1))];
			for (Place *potentialStation in potentialStations) {
				if (potentialStation == startStation) {
					// ignore
				} else if ([stationsReachable containsObject: potentialStation] == YES) {
					// ignore.
				} else if ([potentialStation hasYard]) {
					// add stations early so we find 'em sooner.
					[stationsReachable insertObject: potentialStation atIndex: 0];
				} else {
					[stationsReachable addObject: potentialStation];
				}
			}
		}
	}
  return stationReachabilityGraph;
}

// Return a dictionary of array, each entry mapping a station to
// reachable stations according to trains touching both stations.
- (NSDictionary*) stationReachabilityGraphForCarType: (CarType*) carType {
	NSMutableDictionary *wantedGraph;
	NSString *carTypeName = [carType carTypeName];
	if (carTypeName == nil) {
		carTypeName = @"";
	}
	
	if ((wantedGraph = [stationReachabilityGraph_ objectForKey: carTypeName]) == nil) {
		wantedGraph = [self createStationReachabilityGraphForCarType: carType];
		[stationReachabilityGraph_ setObject: wantedGraph forKey: carTypeName];
	}

	return wantedGraph;
}


// Returns a train that works the given station and carries the given car.
// TODO(bowdidge): Make predictable so same train always would get picked?
- (ScheduledTrain*) trainServingStation: (Place*) start acceptingCar: (FreightCar*) car{
	for (ScheduledTrain *tr in allTrains_) {
		if ([tr acceptsCar: car] == NO) continue;
		
		NSArray *stops = [tr stationsInOrder];
		NSInteger startIndex = [stops indexOfObject: start];
		if (startIndex != NSNotFound) return tr;
	}
	return nil;
}

// Given a pair of stations that we learned are sequential in a route, name the train that will
// take visit both.  Return nil if no such train exists.
// In case of multiple trains following the same route, the order is unspecified (though currently the
// trains should always be returned in the same order for consistent replay.)
- (NSArray*) trainsBetweenStation: (Place*) start andStation: (Place*) end acceptingCar: (FreightCar*) car {
	NSMutableArray *allTrains = [NSMutableArray array];
	for (ScheduledTrain *tr in allTrains_) {
		if ([tr acceptsCar: car] == NO) continue;
		
		NSArray *stops = [tr stationsInOrder];
		NSInteger startIndex = [stops indexOfObject: start];
		if (startIndex == NSNotFound) continue;
		
		int searchRangeStart = startIndex+1;
		int searchLength=  [stops count] - searchRangeStart ;
		NSInteger endIndex = [stops indexOfObject: end inRange: NSMakeRange(searchRangeStart, searchLength)];
		
		if ((endIndex != NSNotFound) && (startIndex < endIndex)) {
			[allTrains addObject: tr];
		}
	}
	
	if ([allTrains count] == 0) {
		return nil;
	}

	return allTrains;
}

// Returns a train going between the named station that would accept the specified car.
// In case of multiple trains following the same route, only returns the first matching
// station.
// Used only for testing.
- (ScheduledTrain*) trainBetweenStation: (Place*) start andStation: (Place*) end acceptingCar: (FreightCar*) car {
	NSArray *result = [self trainsBetweenStation: start andStation: end acceptingCar: car];
	if (!result) return nil;
	return [result objectAtIndex: 0];
}

// Find shortest set of steps to go from one station to the other.
// This is a breadth first search of the station reachability graph.
// route should never contain offline towns.
// Returns an empty array if car already in location, or nil if no route exists.
- (NSArray* ) routeFrom: (InduYard*) startIndustry to: (InduYard*) endIndustry forCar: (FreightCar*) c {
	NSArray *endStations;
	Place *startPlace = [startIndustry location];
	Place *endPlace = [endIndustry location];
	if (c == nil) {
		if (DEBUG_CAR_ASSN) NSLog(@"Car is nil in -[TrainAssigner routeFrom:to:forCar:]");
		return nil;
	}
	
	if (startPlace == nil) {
		[self addError: 
		 [NSString stringWithFormat: @"%@ '%@' does not have its town set.",
		  ([startIndustry isYard] ? @"Yard" : @"Industry"),
		  [startIndustry name]]];
		return nil;
		
	}
	
	if (endPlace == nil) {
		[self addError:
		 [NSString stringWithFormat: @"%@ '%@' does not have its town set.",
		  ([endIndustry isYard] ? @"Yard" : @"Industry"),
		  [endIndustry name]]];
		return nil;
	}
	
	if (DEBUG_CAR_ASSN) NSLog(@"Looking for route from '%@' to '%@' for '%@'", [startPlace name], [endPlace name], c);
	// Staying at same place?  Give one item route.
	if (startPlace == endPlace) {
		return [NSArray arrayWithObject: startPlace];
	}
	// End station an offline place?  Replace with staging yards.
	// TODO(bowdidge) We don't want to end at any staging yard, but at staging yards that are
	// in the division of the cargo (if the car is loaded), and in the division of the car
	// if the car is empty.
	if ([endPlace isOffline] == YES) {
		// All staging yards are possible outs.
		endStations = [entireLayout_ allStationsInStagingAcceptingCar: c];
		if (DEBUG_CAR_ASSN) NSLog(@"Appropriate end stations for car going offline are %@", endStations);
	} else {
		endStations = [NSArray arrayWithObject: endPlace];
	}
	
	// If we're already in an appropriate place, stop.
	if ([endStations containsObject: startPlace]) {
		if (DEBUG_CAR_ASSN) NSLog(@"Current station is a fine place to go offline!");
		return [NSArray array];
	}
	
	NSDictionary *stationReachabilityGraph = [self stationReachabilityGraphForCarType: [c carTypeRel]];
	NSMutableArray *potentialRoutes = [NSMutableArray array];
	[potentialRoutes addObject: [NSMutableArray arrayWithObject: startPlace]];
	// Keep a list of stations that we've already reached in one route; once we've found the shortest
	// path to one intermediate station, there's no point to examine others.
	NSMutableArray *stationsAlreadyVisited = [NSMutableArray arrayWithObject: startPlace];
	while ([potentialRoutes count] != 0) {
		NSMutableArray *firstRoute= [potentialRoutes objectAtIndex: 0];
		[potentialRoutes removeObjectAtIndex: 0];
		
		// Find places reachable from last station that aren't already in route.
		Place *lastStationOnRoute = [firstRoute lastObject];
		NSMutableArray *reachableStations = [stationReachabilityGraph objectForKey: [lastStationOnRoute objectID]];
		// Remove any that are in route.
		for (Place *reachableSta in reachableStations) {
			if ([firstRoute containsObject: reachableSta] == NO) {
				NSMutableArray *newRoute = [NSMutableArray arrayWithArray: firstRoute];

				if ([endStations containsObject: reachableSta] == YES) {
					[newRoute addObject: reachableSta];
					return newRoute;
				}

				// If reachableSta is a yard, then it's potentially an intermediate point.  Otherwise,
				// we can ignore following any routes from the non-yard place.

				if ([stationsAlreadyVisited containsObject: reachableSta] == NO &&
					[reachableSta hasYard]) {
					[newRoute addObject: reachableSta];
					[potentialRoutes addObject: newRoute];
					[stationsAlreadyVisited addObject: reachableSta];
				}
			}
		}
	}
	
	// Nothing found
	return nil;
}

// Given a freight car, figure out the next sequence of stops (based on all available trains)
// to get the car to its next destination.  The destination for cars without a cargo will
// be either a yard in their division or a car that accepts them.  The destination for a car
// with a cargo will be the next stop as requested by their cargo.
// Returns the array of station names, or an empty list if no routing is needed (the car is
// already at its next stop.)
// If no routing is possible, errors are added to the list of problems.
- (NSArray *) routeToNextStopForCar: (FreightCar *) car  {
	NSArray *route = nil;
	if ([car cargo] == nil) { 
		// The car doesn't have its next assignment.
		// The general rule here is to get the car back to its own railroad, which is
		// a yard whose division is the same as the car.  If there's no yard like that,
		// then getting the car to a yard that accepts such cars (and should be on the
		// way) is good enough.
		//
		
		if  (([[car currentLocation] isYard] == YES) &&
			 ([(Yard*)[car currentLocation] acceptsDivision: [car homeDivision]])) {
			// It's in a yard that accepts it, so it can stay where it is.  We
			// do this so the car won't go bouncing around looking for a place to 
			// end up.
			// TODO(bowdidge): A better check might be if we're in a yard that accepts it,
			// and NO other places exist.
			return [NSArray array];
		}
		
		if ([car inStaging] == YES) {
			// It's in staging.  Leave it here for the same reason.
			// TODO(bowdidge): Needed?
			return [NSArray array];
		}
			
		// The car doesn't have its next assignment, but it can't stay on this industry track.
		// Assign to some yard that accepts that car - preferably closest, but for now choose any.
		NSArray *yards = [entireLayout_ allYards];
		for (Yard *y in yards) {
			// Make two passes, first to see if there's a yard which is in the
			// car's preferred division, then if there's a yard that accepts
			// that division.
			if ([[y division] isEqualToString: [car homeDivision]] == YES) {
				route = [self routeFrom: [car currentLocation]
									 to: y
										forCar: car];
				if (route != nil) {
					return route;
				}
			}
		}
		// Now see if there's a yard that will at least accept the car.
		for (Yard *y in yards) {
			if ([y acceptsDivision: [car homeDivision]] == YES) {
				route = [self routeFrom: [car currentLocation]
									 to: y
										forCar: car];
				if (route != nil) {
					// This will work.  Set the car to go there for now.
					return route;
				} 
			}
		}
	} else {
		// Already at its final destination.
		if ([car currentLocation] == [car nextIndustry]) {
			return [NSArray array];
		}
		
		// The car is loaded, so we have a place we're trying to direct it to.
		// If it doesn't fit in this division, move hoping we can find a better place.
		route = [self routeFrom: [car currentLocation] 
							 to: [car nextIndustry]
								forCar: car];
	}
	return route;
}

NSString *NameOrNoValue(NSString* string) {
	if (string) return string;
	return @"'No Value'";
}

// Returns YES if the train has space for the named car.
// This routine doesn't actually assign the car, but just checks capacity.
- (BOOL) train: (ScheduledTrain *) tr hasSpaceForCar: (FreightCar *) car  {
	NSArray *stationStops = [tr stationsInOrder];
	
	
	TrainSizeVector *sizeVector = [[[TrainSizeVector alloc] initWithCars: [tr allFreightCarsInVisitOrder]
																   stops: stationStops] autorelease];
	TrainSizeVector *addedCarVector = [[[TrainSizeVector alloc] initWithCars: [NSArray arrayWithObject: car]
																	   stops: stationStops] autorelease];
	[addedCarVector addVector: sizeVector];
		
	if ([addedCarVector vectorExceedsLength: [[tr maxLength] intValue]]) {
		return NO;
	}
	return YES;
}
// Given a car, find the proper train to carry it on its way.  Add the car to the train,
// and if multiple steps are required, set intermediate destination to go there.
//
// Arguments:
//   car: freight car to assign to one of the available trains.
//
// Returns:
//    CarAssignmentSuccess if car was assigned to a train, or another value if
//    a problem occurred.
//    On exit, the a freight car with a cargo either has intermediateLocation set to nil
//    (if the next destination is reachable on the assigned train), or the intermediate
//    yard where it will be dropped on.
//    A freight car with no cargo must have an intermediate location set to indicate its final
//    destination.
- (CarAssignmentResult) assignCarToTrain: (FreightCar *) car  {
	NSArray *route;
	[car setIntermediateDestination: nil];
	
	// Is this a car we have no intention of moving?
	if ([car currentLocation] == [entireLayout_ workbenchIndustry]) return CarAssignmentNoMoveNeeded;
	if ([car currentLocation] == nil) return CarAssignmentNoMoveNeeded;
	// Is this a car that can't be routed because of missing or inconsistent information?
	if ([[car currentLocation] isOffline]) {
		[self addError: [NSString stringWithFormat: @"Cannot move car %@ because it is at %@, an offline location.",
						 [car reportingMarks], [[car currentLocation] name]]];
		return CarAssignmentRoutingProblem;
	}

	// TODO(bowdidge): Move to do check before routing?
	if ([car cargo] && ![[car cargo] source]) {
		[self addError: [NSString stringWithFormat: @"Cargo '%@' does not have source set.",
						 [[car cargo] name]]];
		return CarAssignmentRoutingProblem;
	}
	

	if ([car cargo] && ![[car cargo] destination]) {
		[self addError: [NSString stringWithFormat: @"Cargo '%@' does not have destination set.",
						 [[car cargo] name]]];
		return CarAssignmentRoutingProblem;
	}
	
	if ([car cargo] && [[car cargo] source] == nil) {
		[self addError: [NSString stringWithFormat: @"Cannot place car %@ because source location for cargo %@ is unset.",
						 [car reportingMarks], [[car cargo] cargoDescription]]];
		return CarAssignmentRoutingProblem;
	}
	
	if ([car cargo] && [[car cargo] destination] == nil) {
		[self addError: [NSString stringWithFormat: @"Cannot place car %@ because destination location for cargo %@ is unset.",
						 [car reportingMarks], [[car cargo] cargoDescription]]];
		return CarAssignmentRoutingProblem;
	}
	route = [self routeToNextStopForCar: car];

	if (route == nil) {
		// We couldn't find a route.  Try to diagnose what went wrong.
		if ([car cargo] == nil) {
			NSString *err = [NSString stringWithFormat: @"Cannot find route for car %@ from %@ to a yard accepting cars of division %@",
							 [car reportingMarks],
							 NameOrNoValue([[car currentTown] name]),
							 [car homeDivision]];
			[self addError: err];
		} else {
			NSString *err = [NSString stringWithFormat: @"Cannot find route to get car %@ from %@ to %@",
							 [car reportingMarks],
							 NameOrNoValue([[car currentTown] name]),
							 NameOrNoValue([[[ car nextIndustry] location] name])];
			[self addError: err];
		}
		// In all cases, leave this car where it is, and move on to the next car.
		return CarAssignmentRoutingProblem;
	}
	
	// Which train are we going to put this on?
	ScheduledTrain *tr=nil;
	Place *here = [car currentTown];
	Place *there;

	if ([route count] == 0) {
		// No movement needed at all.  Ignore this car.
		return CarAssignmentNoMoveNeeded;
	} else if ([route count] == 1) {
		// Staying in same town - just transfer.
		tr = [self trainServingStation: [car currentTown]  acceptingCar: car];
		there = [route objectAtIndex: 0];
		if ([car cargo] == nil) {
			[car setIntermediateDestination: [[there yards] anyObject]];
		}
	} else {
		// We have one or more steps to go.  Find a train for the next step.
		// The route code shouldn't have given us a possible step if it wasn't valid.
		there = [route objectAtIndex: 1];
		if (DEBUG_CAR_ASSN) {
			NSLog(@"%@ ought to go via %@\n",[car reportingMarks], [route componentsJoinedByString: @","]);
			NSLog(@"Need to find a train going from %@ to %@\n", [here name], [there name]);
		}
		
		// It's acceptable to choose any of the yards in town;
		// we know this stop is along the path to the final
		// station, and we know all trains have to stop at all
		// industries (and yards) in the town.
		if (there != [[car nextIndustry] location]) {
			[car setIntermediateDestination: [[there yards] anyObject]];
		}

		NSArray *trains = [self trainsBetweenStation: here andStation: there acceptingCar: car];
	
		if (!respectSidingLengths_) {
			// If there are no limits on train size, just keep piling cars on the first available train.
			if (trains == nil) {
				NSString *err = [NSString stringWithFormat: @"Cannot find train going from %@ to %@ that can take car type %@\n",
								 [here name], [there name], [car carType]];
				[self addError: err];
				return CarAssignmentRoutingProblem;
			}
			tr = [trains objectAtIndex: 0];
		} else {	
			for (ScheduledTrain *train in trains) {
				if ([self train: train hasSpaceForCar: car] == YES) {
					tr = train;
					break;
				}
			}
			
			if (!tr) {
				NSString *err = [NSString stringWithFormat: @"Cannot fit car %@ onto any train going from %@ to %@.  Leaving car at current location %@.",
								 [car reportingMarks], [here name], [there name], [[car currentLocation] name]];
				[self addError: err];
				return CarAssignmentNoTrainsWithSpace;
			}
		}
	}

	// We found a train.	
	[car setCurrentTrain: tr];
	return CarAssignmentSuccess;
}

// Inner loop for choosing the door a car should be placed at when arriving at an
// industry that expects cars to be spotted at particular doors.  Caller is responsible
// for updating the doorAssignments map with the results of this call.
// Returns nil if no space is available or if industry doesn't specify spotting instructions.
// TODO(bowdidge): Should find a neater way to keep track of door assignments, perhaps in the FreightCar
// object itself or in an explicit FreightCarMovement object.
- (NSNumber*) chooseRandomDoorForCar: (FreightCar*) car
							 inTrain: (ScheduledTrain*) train
					 goingToIndustry:(Industry*) industry 
			  industryArrivingCarMap: (DoorAssignmentRecorder*) doorAssignments {
	int i;
	int doorCount;
	if ([industry numberOfDoors] == nil) {
		NSLog(@"Industry %@ passed to chooseRandomDoorForCar:... does not have doors!", [industry name]);
		return nil;
	} 
	doorCount = [[industry numberOfDoors] intValue];
	
	// Make a char vector for noting the doors available in this industry.
	BOOL *doorAvailableMap = malloc(doorCount+1);
	for (i = 1; i <= doorCount; i++) {
		// available.
		doorAvailableMap[i] = YES;
	}
	
	// Run through the existing cars at this industry.  If they're not in our train (and thus
	// going to be picked up when we run the train), then they're occupying a door, and we cannot
	// spot the new car there.  Mark the door as unavailable.
	for (FreightCar* industryCar in [industry freightCars]) {
		if ([industryCar currentTrain] != train) {
			NSNumber* currentDoor = [industryCar doorToSpot];
			int doorValue;
			if (currentDoor) {
				doorValue = [currentDoor intValue];
				if (doorValue > 0 && doorValue <= doorCount) {
					doorAvailableMap[doorValue] = NO;
				}
			}
		}
	}

	// Find any car assignments we've already made to this industry, and note the doors
	// that we'll be putting cars into in this train (or in other trains).  The spotting
	// instructions for this session reserve the door for someone else; mark the door as
	// unavailable.
	for (FreightCar *car in [doorAssignments carsAtIndustry: industry]) {
		int doorValue = [doorAssignments doorForCar: car];
		if (doorValue > 0 && doorValue <= doorCount) {
			// Someone already got there.
			doorAvailableMap[doorValue] = NO;
		}
	}

	int availableDoorCount = 0;
	for (i = 1; i <= doorCount; i++) {
		if (doorAvailableMap[i] == YES) {
			availableDoorCount++;
		}
	}
	
	if (availableDoorCount == 0) {
		// No space left at industry.
        free(doorAvailableMap);
		return nil;
	}
	// Add one b/c doors numbered from one.
	int randomDoor = 1 + [randomNumberGenerator_ generateRandomNumber: availableDoorCount];
	// Find nth available door.
	for (i = 1; i <= doorCount; i++) {
		if (doorAvailableMap[i] == YES) {
			randomDoor--;
			if (randomDoor == 0) {
				// This is it.
				// Should add to arriving map here.
                free(doorAvailableMap);
				return [NSNumber numberWithInt: i];
			}
		}
	}

	// NSLog(@"Shouldn't get here - should have found one of available doors!");
    free(doorAvailableMap);
	return nil;
}

- (BOOL) canChangeSidingDict: (NSMutableDictionary*) dict forSiding: (InduYard*) siding byLength: (int) length {
	if ([siding sidingLength] == nil || [[siding sidingLength] intValue] == 0) {
		// Length not being checked.
		return YES;
	}
	NSNumber *sidingLengthObj = [dict objectForKey: [siding objectID]];
	int currentSidingContentsLength = 0;
	if (sidingLengthObj != nil) {
		currentSidingContentsLength = [sidingLengthObj intValue] + length;
	} else {
		currentSidingContentsLength = length;
	}
	
	if ([siding sidingLength] != nil &&
		currentSidingContentsLength > [[siding sidingLength] intValue]) {
		return NO;
	}
	[dict setObject: [NSNumber numberWithInt: currentSidingContentsLength] forKey: [siding objectID]];
	return YES;
}

// Check all the cars in all trains, and make sure the overall number of cars entering and leaving
// stays below the siding capacity (at least for the operating session).  
- (void) leaveBehindOverflowingCars {
	// Maps industry to contents of siding at end.
	NSMutableDictionary *carChangeDictionary = [NSMutableDictionary dictionary];
	
	for (FreightCar *car in [entireLayout_ allFreightCars]) {
		if ([car currentLocation] == nil) continue;
	    if ([car nextStop] == nil || [car nextStop] == [car currentLocation]) {
			// All cars already there stay there, even if overflowing.
			[self canChangeSidingDict: carChangeDictionary
							forSiding: [car currentLocation]
							 byLength: [[car length] intValue]];
		}
	}
	
	for (ScheduledTrain *train in allTrains_) {
		NSArray *allCarsInTrain = [train allFreightCarsInVisitOrder];
		for (FreightCar *car in allCarsInTrain) {
			InduYard *currentLocation = [car currentLocation];
			InduYard *nextLocation = [car nextStop];

			if (currentLocation == nil) continue;
			if (currentLocation == [entireLayout_ workbenchIndustry]) continue;
			 
			if (nextLocation && ([car currentLocation] != nextLocation)) {
				if ([self canChangeSidingDict: carChangeDictionary
									forSiding: nextLocation
									 byLength: [[car length] intValue]] == NO) {
					// TODO(bowdidge): Add tests to check this message appears.
					[errors_ addObject: 
					 [NSString stringWithFormat: @"No room for car %@ at %@.  Leaving car at current location %@.",
					  [car reportingMarks], [nextLocation name], [currentLocation name]]];
					[[car currentTrain] removeFreightCarsObject: car];
				}
			}
		}
	}
	
	for (InduYard *industry in [entireLayout_ allIndustries]) {
		int lengthAtSiding = [[carChangeDictionary objectForKey: [industry objectID]] intValue];
		if ([industry sidingLength] != nil &&
			[[industry sidingLength] intValue] < lengthAtSiding) {
			[errors_ addObject: [NSString stringWithFormat: @"Siding for %@ was already overflowing.", [industry name]]];
		}
	}
}

// Basics of the car assigning problem.  we used to do clever things here trying to figure out
// for a given train and car whether this was the best train for a car.  That doesn't work because
// there may be another train that's a better choice.  Now, we find a route, then choose a car.
// TODO(bowdidge): Move trains parameter to constructor.
- (void) assignCarsToTrains {
	NSArray *allCars = [entireLayout_ allFreightCarsNotInTrain];
	NSMutableArray *carsMoved = [NSMutableArray array];
	
	// TODO(bowdidge): Should assign cars randomly so the same cars aren't always
	// assigned first, and the same cars are always left behind.  Doing so would
	// require not recalculating assigned trains each time the overview pane is showed. 
	for (FreightCar *car in allCars) {
		if ([self assignCarToTrain: car] == CarAssignmentSuccess) {
			[carsMoved addObject: car];
		}
	}
	
	// TODO(bowdidge): Car assignment assumes all the cars will be delivered; overflowing cars 
	// eat up space in the train.
	if (respectSidingLengths_) {
		[self leaveBehindOverflowingCars];
	}
	
	if (assignDoors_) {
		// First, create tables listing the cars currently at the industry (for quickly figuring out spare doors)
		// and cars arriving at industry (that take up slots later.)
		[doorAssignmentRecorder_ release];
		doorAssignmentRecorder_ = [[DoorAssignmentRecorder doorAssignmentRecorder] retain];
		
		for (FreightCar *car in carsMoved) {
			// TODO(bowdidge): Safe to assume next stop only final stop if no doors?
			if ([[car nextStop] isKindOfClass: [Industry class]] && [(Industry*) [car nextStop] hasDoors]) {
				Industry *nextIndustry = (Industry*) [car nextStop];
				ScheduledTrain *currentTrain = [car currentTrain];
				NSNumber *doorNum = [self chooseRandomDoorForCar: car
														 inTrain: currentTrain
												 goingToIndustry: nextIndustry
										  industryArrivingCarMap: doorAssignmentRecorder_];
				if (doorNum != nil) {
					// Valid door!
					// NSLog(@"Car %@ goes to door %@ of industry %@", [car reportingMarks], doorNum, [nextIndustry name]);
					[doorAssignmentRecorder_ setCar:car destinedForIndustry:nextIndustry door:[doorNum intValue]];
				} else {
					// TODO (bowdidge): Fill in what happens if the car can't be put at a door.
				}
			}
		}
	}
}

@end
