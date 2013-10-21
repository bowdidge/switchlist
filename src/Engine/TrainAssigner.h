//
//  TrainAssigner.h
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

#import <Foundation/Foundation.h>

#import "DoorAssignmentRecorder.h"
#import "RandomNumberGenerator.h"
#import "ScheduledTrain.h"
#import "EntireLayout.h"

// Class hiding details of how we assign cars to trains.
// Also responsible for assigning the specific door that cars will be spotted at; we only do that
// work here because we want to know which cars we're removing that might be opening up door slots.
@interface TrainAssigner : NSObject {
	EntireLayout *entireLayout_;
	// Dictionary mapping string version of car type to a dictionary mapping station names to places.
	NSMutableDictionary *stationReachabilityGraph_;
	// List of assignment problems to display to the user.
	NSMutableArray *errors_;
	BOOL assignDoors_;
	BOOL respectSidingLengths_;
	// Dictionary mapping industry object IDs to an array of cars being directed at that industry during
	// the next session.
	NSMutableDictionary *arrivingCars_;
	NSMutableDictionary *leavingCars_;
	
	DoorAssignmentRecorder *doorAssignmentRecorder_;
	NSObject<RandomNumberGeneratorInterface> *randomNumberGenerator_;
}

- (id) initWithLayout: (EntireLayout*) mapper trains: (NSArray*) trains useDoors: (BOOL) useDoors respectSidingLengths: (BOOL) respectSidingLengths;
- (id) initWithLayout: (EntireLayout*) mapper trains: (NSArray*) trains useDoors: (BOOL) useDoors;

- (void) assignCarsToTrains;

// Retrieve the DoorAssignmentRecorder used to note which doors specific cars should
// be spotted at.
- (DoorAssignmentRecorder*) doorAssignmentRecorder;

// For debugging/information.
- (NSArray* ) routeFrom: (InduYard*) startIndustry to: (InduYard *) endIndustry  forCar: (FreightCar*) c;
- (NSArray*) errors;

// Returns a train that goes between the named stations.
// For testing only.
- (ScheduledTrain*) trainBetweenStation: (Place*) start andStation: (Place*) end acceptingCar: (FreightCar*) car;

// Given a station, what train works that station?
- (ScheduledTrain*) trainServingStation: (Place*) start acceptingCar: (FreightCar*) car;
- (NSMutableDictionary *) createStationReachabilityGraphForCarType: (CarType *) carType;

enum CarAssignmentResult {
	CarAssignmentSuccess=0,
	CarAssignmentRoutingProblem=1,
	CarAssignmentNoMoveNeeded=2,
	CarAssignmentNoRoomAtDestination=3,
	CarAssignmentNoTrainsWithSpace=4
};

typedef enum CarAssignmentResult CarAssignmentResult;

// For Testing Only.
// Given a car, find the proper train to carry it on its way.  Add the car to the train,
// and if multiple steps are required, set intermediate destination to go there.
- (CarAssignmentResult) assignCarToTrain: (FreightCar *) car;
	
	
// Exposed in interface for unit testing only.
// Per-car work to determine a door for the incoming freight car.  Caller is responsible for
//updating the DoorAssignmentRecorder.
- (NSNumber*) chooseRandomDoorForCar: (FreightCar*) car
							 inTrain: (ScheduledTrain*) train
					 goingToIndustry:(Industry*) industry 
			  industryArrivingCarMap: (DoorAssignmentRecorder*) doorAssignments;

// For testing only.
- (void) setRandomNumberGenerator: (NSObject<RandomNumberGeneratorInterface>*) generator;

// All trains allowed for scheduling.
NSArray *allTrains_;
@end

