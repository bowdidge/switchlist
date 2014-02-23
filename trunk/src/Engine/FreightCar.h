//
//  FreightCar.h
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

#import <CoreData/CoreData.h>

@class Cargo;
@class CarType;
@class FreightCar;
@class Place;
@class Industry;
@class InduYard;;
@class ScheduledTrain;

// Compares the two freight car names, and returns order of the two.
NSInteger compareReportingMarksAlphabetically(FreightCar* s1,FreightCar* s2, void *context);

@interface FreightCar :  NSManagedObject  
{
}
@property(nonatomic, retain) CarType* carTypeRel;
@property(nonatomic, retain) NSNumber* daysUntilUnloaded;

- (BOOL) isLoaded;
- (void) setIsLoaded: (BOOL) loaded;
- (NSNumber *)loaded;
- (void)setLoaded:(NSNumber *)value;

// Division is either a string representing the owning
// division, or nil (indicating don't care.)
- (NSString *)homeDivision;
- (void)setHomeDivision:(NSString *)value;

- (NSString *)reportingMarks;
- (void)setReportingMarks:(NSString *)value;

- (NSString*) initials;
- (NSString*) number;
// Car type abbreviation for freight car.
- (NSString*) carType;

// Set the door at the next industry where the car should go.
- (NSNumber *)doorToSpot;
- (void)setDoorToSpot:(NSNumber *)value;

// Set the door that the car is currently located at.
- (NSNumber *)currentDoor;
- (void) setCurrentDoor: (NSNumber *) value;

// UNUSED.  Reports should sort the switchlists themselves.
- (unsigned)positionInTrain;
- (void)setPositionInTrain:(unsigned)value;

- (NSNumber *)length;
- (void)setLength:(NSNumber *)value;

- (InduYard *)currentLocation;
- (void)setCurrentLocation:(InduYard *)value;

- (NSNumber*) daysUntilUnloaded;
- (void) setDaysUntilUnloaded: (NSNumber*) value;

// Returns the town holding the current industry for the car.
- (Place *) currentTown;

/* Is this car at its next destination? */
- (BOOL) atDestinationIndustry;
- (BOOL) atDestinationTown;
- (Place*) nextTown;
// where's the next destination before we change state?
// May include offline places that aren't actually reachable.
// Returns nil if car has no cargo.
- (InduYard*) nextIndustry;

// Returns name of division of next destination.
- (NSString*) nextDivision;

// where's the next intermediate stop heading towards next dest.
// Should always return an industry.
- (InduYard*) nextStop;
- (BOOL) inStaging ;

// Strings describing current loc/ next stop for freight car
- (NSString*) sourceString;
// Same, but industry only.
- (NSString*) sourceIndustryString;

// Industry name only for next destination.
- (NSString*) destinationIndustryString;


- (BOOL) hasCargo;

// Clear the marking of which train this is assigned to.
- (void) removeFromTrain;

- (Cargo *)cargo;
- (void)setCargo:(NSManagedObject *)value;
- (NSString*) cargoDescription;


- (ScheduledTrain *)currentTrain;
- (void)setCurrentTrain:(ScheduledTrain *)value;

- (InduYard  *)intermediateDestination;
- (void)setIntermediateDestination:(InduYard *)value;

// Move the car to its next destination, and remove it from its current train.
// Returns false if any problems noted.
- (BOOL) moveOneStep;
	
// Comparison routine for grouping cars going to the same place.
- (NSComparisonResult) compareNextStop: (FreightCar *) other;

- (NSComparisonResult) compareNames: (FreightCar *) other;

@end
