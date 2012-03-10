//
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


@implementation TrainSizeVector

- (void) addCars: (NSArray*) cars stops: (NSArray*) stationStops {
	int stationCount = [stationStops count];
	int i,j;
	
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
		
		assert(i != stationCount);

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
			int currentLength = [[vector objectAtIndex: i] intValue];
			[vector replaceObjectAtIndex: i
							  withObject: [NSNumber numberWithInt: currentLength - [[car length] intValue]]];

			currentLength = [[vector objectAtIndex: j] intValue];
			[vector replaceObjectAtIndex: j
							  withObject: [NSNumber numberWithInt: currentLength + [[car length] intValue]]];
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
			int currentLength = [[vector objectAtIndex: i] intValue];
			[vector replaceObjectAtIndex: i
							  withObject: [NSNumber numberWithInt: currentLength + [[car length] intValue]]];
			
			currentLength = [[vector objectAtIndex: j] intValue];
			[vector replaceObjectAtIndex: j
							  withObject: [NSNumber numberWithInt: currentLength - [[car length] intValue]]];
			continue;
		}
			
		// TODO(bowdidge): Fix.
		assert(found != NO);
	}
}

- (id) initWithCars: (NSArray*) cars stops: (NSArray*) stops {
	int i;

	[super init];
	
	int vectorLength = [stops count];
	vector = [[NSMutableArray alloc] init];
	for (i=0; i<vectorLength; i++) {
		[vector addObject: [NSNumber numberWithInt: 0]];
	}
	
	[self addCars: cars stops: stops];
	return self;
}

- (void) addVector: (TrainSizeVector*) otherVector {
	if ([vector count] != [otherVector->vector count]) {
		NSLog(@"Trying to compare TrainSizeVectors from different trains! %@ vs %@", vector, otherVector);
		return;
	}
	
	int count = [vector count];
	int i;
	for (i=0; i<count; i++) {
		int newValue = [[vector objectAtIndex: i] intValue] + [[otherVector->vector objectAtIndex: i] intValue];
		[vector replaceObjectAtIndex: i withObject: [NSNumber numberWithInt: newValue]];
	}
}


- (int) maximumLength {
	int currentLength = 0;
	int maximumLength = 0;
	int i = 0;
	int count = [vector count];
	for (i=0;i<count; i++) {
		NSNumber *change = [vector objectAtIndex: i];
		currentLength += [change intValue];
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
	return vector;
}

- (NSString*) description {
	return [NSString stringWithFormat: @"<TrainSizeVector: %d elements, %@>", [vector count], vector];
}
@end
