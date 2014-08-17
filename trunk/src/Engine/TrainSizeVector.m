//
//  TrainSizeVector.m
//  SwitchList
//
//  Created by bowdidge on 2/25/12.
//
// Copyright (c)2012 Robert Bowdidge,
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

#import "TrainSizeVector.h"

#import "FreightCar.h"
#import "InduYard.h"
#import "Place.h"
#import "ScheduledTrain.h"

@implementation Stop 
// Creates a stop for the train at the named station.
// There may be more than one stop per place for a train if it visits
// the same town multiple times.
- (id) initWithPlace: (Place*) p {
	self = [super init];
	place_ = [p retain];
	carsPickedUp_ = [[NSMutableArray alloc] init];
	carsDroppedOff_ = [[NSMutableArray alloc] init];
	return self;
}

- (void) dealloc {
	[place_ release];
	[super dealloc];
}

// Alternate allocator.
+ (id) stopWithPlace: (Place*) p {
	Stop *s = [[Stop alloc] initWithPlace: p];
	return [s autorelease];
}

- (Place*) place {
	return place_;
}

// Returns the change in the train's length feet at the current stop.
- (int) changeInLengthAtStop {
	int value = 0;
	for (FreightCar *fc in carsPickedUp_) {
		value += [[fc length] intValue];
	}
	for (FreightCar *fc in carsDroppedOff_) {
		value -= [[fc length] intValue];
	}
	return value;
}

// Adds a new car to be picked up at the current place.
- (void) addCarToPickUpList: (FreightCar*) car {
	[carsPickedUp_ addObject: car];
}

// Remembers a car to be removed at the current place.
- (void) addCarToDropOffList: (FreightCar*) car {
	[carsDroppedOff_ addObject: car];
}

- (NSArray*) pickUpList {
	return carsPickedUp_;
}

- (NSArray*) dropOffList {
	return carsDroppedOff_;
}

@end

@implementation TrainSizeVector

- (void) addCars: (NSArray*) cars stops: (NSArray*) stationStops {
	NSInteger stationCount = [stationStops count];
	NSInteger i,j;
	
	for (FreightCar *car in cars) {
		Place *currentStationForCar = [car currentTown];
		Place *nextStationForCar = [[car nextStop] location];
		
		if (nextStationForCar == nil) continue;
		// Cars staying in same town don't count.
		if (currentStationForCar == nextStationForCar) continue;
		
		// Best approach would be to find first occurrence of station where dropping
		// off, then work backwards to figure out the closest time to pick up.
		for (i=1; i<stationCount; i++) {
			Place *station = [stationStops objectAtIndex: i];
			if (station == nextStationForCar) {
				break;
			}
		}
		
		if (i == stationCount) {
			NSLog(@"Couldn't find next station for car %@", car);
		}

		// Go backwards to find prev visit.
		BOOL found = NO;
		for (j=i-1;j>=0;j--) {
			Place *station = [stationStops objectAtIndex: j];
			if (station == currentStationForCar) {
				found = YES;
				break;
			}
		}

		if (found == YES) {
			Stop *currentStop = [stopsVector_ objectAtIndex: i];
			[currentStop addCarToDropOffList: car];

			Stop *prevStop = [stopsVector_ objectAtIndex: j];
			[prevStop addCarToPickUpList: car];
			continue;
		}
		
		// Try searching forward.
		// Best approach would be to find first occurrence of station where dropping
		// off, then work backwards to figure out the closest time to pick up.
		for (i=0; i < stationCount; i++) {
			Place *station = [stationStops objectAtIndex: i];
			if (station == currentStationForCar) {
				break;
			}
		}
			
		// Go forwards to find prev visit.
		for (j=i;j < stationCount;j++) {
			Place *station = [stationStops objectAtIndex: j];
			if (station == nextStationForCar) {
				found = YES;
				break;
			}
		}
		
		if (found == YES) {
			Stop *currentStop = [stopsVector_ objectAtIndex: i];
			[currentStop addCarToPickUpList: car];
			
			Stop *nextStop = [stopsVector_ objectAtIndex: j];
			[nextStop addCarToDropOffList: car];
			continue;
		}
		
		// We should have been able to figure out which start and end could carry this car;
		// if we couldn't, how was the car ever determined to be safe to put on this train?
		// TODO(bowdidge): any way to get rid of assert?
		if (found == NO) {
			NSLog(@"TrainSizeVector addCars:stops: could not find how to carry car %@", car);
		}
	}
}

- (id) initWithTrain: (ScheduledTrain*) train {
	return [self initWithCars: [train.freightCars allObjects] stops: [train stationsInOrder]];
}

// Creates a new TrainSizeVector with only a single car but with
// a full list of stops for some train.
// For specifying a single car to add to a train, or for testing.
- (id) initWithCars: (NSArray*) cars stops: (NSArray*) stops {
	int i;

	self = [super init];
	
	NSInteger vectorLength = [stops count];
	stopsVector_ = [[NSMutableArray alloc] init];
	for (i=0; i<vectorLength; i++) {
		Place *currentPlace = [stops objectAtIndex: i];
		[stopsVector_ addObject: [Stop stopWithPlace: currentPlace ]];
	}
	
	[self addCars: cars stops: stops];
	return self;
}

- (void) addVector: (TrainSizeVector*) otherVector {
	if ([stopsVector_ count] != [otherVector->stopsVector_ count]) {
		NSLog(@"Trying to compare TrainSizeVectors from different trains! %@ vs %@", stopsVector_, otherVector);
		return;
	}
	
	NSInteger count = [stopsVector_ count];
	NSInteger i;
	for (i=0; i<count; i++) {
		Stop *stop = [stopsVector_ objectAtIndex: i];
		Stop *otherStop = [otherVector->stopsVector_ objectAtIndex: i];
		NSAssert([stop place] == [otherStop place], @"Tried to merge two train vectors for different trains.");

		for (FreightCar *fc in [otherStop pickUpList]) {
			[stop addCarToPickUpList: fc];
		}
		for (FreightCar *fc in [otherStop dropOffList]) {
			[stop addCarToDropOffList: fc];
		}
	}
}

- (int) maximumLength {
	int currentLength = 0;
	int maximumLength = 0;
	int i = 0;
	NSInteger count = [stopsVector_ count];
	for (i=0;i<count; i++) {
		Stop *change = [stopsVector_ objectAtIndex: i];
		currentLength += [change changeInLengthAtStop];
		if (currentLength > maximumLength) {
			maximumLength = currentLength;
		}
	}
	return maximumLength;
}

- (BOOL) vectorExceedsLength: (int) maxLength {
	return [self maximumLength] > maxLength;
}

- (NSArray*) vector {
	return stopsVector_;
}

- (NSString*) description {
	return [NSString stringWithFormat: @"<TrainSizeVector: %d elements, %@>", (int) [stopsVector_ count], stopsVector_];
}
@end
