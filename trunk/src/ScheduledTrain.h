//
//  ScheduledTrain.h
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
#import "EntireLayout.h"
@class CarType;
@class FreightCar;
@class Place;
@class Yard, Industry;

@interface ScheduledTrain :  NSManagedObject  
{
}

// freightCars is a PUBLIC TEMPLATE API.
// Set of all freight cars to be inclued in the train in no order.
@property (nonatomic, retain) NSSet *freightCars;

- (NSNumber *)maxLength;
- (void)setMaxLength:(NSNumber *)value;

//- (NSString *)acceptedCarTypes;
//- (void)setAcceptedCarTypes:(NSString *)value;
- (BOOL) acceptsCarType: (CarType*) carType;

// Returns a comma-separated string listing the car types that this
// train will accept.  Parts of the UI explicitly watch this as
// if it were a variable.
- (NSString*) acceptedCarTypesString;
- (void) setCarTypesAcceptedRel: (NSSet*) currentCarTypes;


/* Would this train accept this kind of car? */
- (BOOL) acceptsCar: (FreightCar*) car;
- (BOOL) containsCar: (FreightCar*) car;

// Returns the name of the train.
// PUBLIC TEMPLATE API.
- (NSString *)name;
- (void)setName:(NSString *)value;

// Set the list of station stops as a string with a "," separator.
// FOR TESTING ONLY.  Array versions should be preferred.
- (NSString*) stops;
- (void)setStops:(NSString *)value;

// Setters for station stop list, using arrays of Place objects instead of names.
// PUBLIC TEMPLATE API.
- (NSArray*) stationsInOrder;
- (void) setStationsInOrder: (NSArray*) stationsInOrder;

// List of station names, suitable for human display.
- (NSString*) listOfStationsString;

- (NSNumber *)minCarsToRun;
- (void)setMinCarsToRun:(NSNumber *)value;

- (NSArray*) carsAtStation:(Place *)station;
- (NSArray*) carsForStation:(Place *)station;

// Return the list of freight cars in the train in the order they would be visited during the
// operation of the train.
// This method is guaranteed to have the same sort order between runs; use it for getting the
// list of freight cars for any code that might affect display order or which cars get booted
// from the train.
- (NSArray* ) allFreightCarsInVisitOrder;

// Returns an array of stations with work for this train, where each
// dictionary entry includes a name for the station and a list of industries at the station
// with cars for the current train, and each industry is a dictionary with name and list
// of cars.
// Needed for implementing PICL switchlist and other by-station switchlists in the web interface.
// PUBLIC TEMPLATE API.
- (NSArray*) stationsWithWork;

// Access to-many relationship via -[NSObject mutableSetValueForKey:]
- (void)addFreightCarsObject:(FreightCar *)value;
- (void)removeFreightCarsObject:(FreightCar *)value;

// TODO(bowdidge): Trains, stops, and freight cars can change at any point
// via the UI.  Add a sanity check function that boots freight cars out of the
// train if they're no longer appropriate, and check this when regenerating trains.
@end

// Separators used for list of train stops.  Should only be used by testing code
// and code determining whether to force conversion.
NSString *NEW_SEPARATOR_FOR_STOPS;
NSString *OLD_SEPARATOR_FOR_STOPS;
