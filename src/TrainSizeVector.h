//
//  TrainSizeVector.h
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


#import <Foundation/Foundation.h>

@class ScheduledTrain;
@class Place;
@class FreightCar;

// Stores information about a given stop for the train in the TrainSizeVector.
// Remembers the cars added and removed, and total change in train length.
@interface Stop : NSObject {
	// Station this stop corresponds to.
	Place *place_;
	// List of cars picked up at this stop.
	NSMutableArray *carsPickedUp_;
	// List of cars dropped off at this stop.
	NSMutableArray *carsDroppedOff_;
}
- (id) initWithPlace: (Place*) p;
+ (id) stopWithPlace: (Place*) p;
- (Place*) place;

- (NSArray*) pickUpList;
- (NSArray*) dropOffList;

- (void) addCarToPickUpList: (FreightCar*) car;
- (void) addCarToDropOffList: (FreightCar*) car;

- (int) changeInLengthAtStop;
@end

// Records the cars added and removed from the train at each stop.
// Used for calculating whether cars can be added to train without the train
// becoming larger than desired.
@interface TrainSizeVector : NSObject {
	// Array storing number of cars added or removed at each stop on the train.
	NSMutableArray *stopsVector_;
}

// Constructor.  stops should be array of Place objects for the stops of the train.
- (id) initWithCars: (NSArray*) cars stops: (NSArray*) stops;
- (id) initWithTrain: (ScheduledTrain*) train;

// Modifies this vector by adding values from otherVector.
- (void) addVector: (TrainSizeVector*) vector;

- (int) maximumLength;
- (BOOL) vectorExceedsLength: (int) maxLength;

- (NSArray*) vector;
@end
