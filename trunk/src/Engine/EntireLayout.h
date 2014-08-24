//
//  EntireLayout.h
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
#import <CoreData/CoreData.h>

@class CarType;
@class DoorAssignmentRecorder;
@class FreightCar;
@class InduYard;
@class Industry;
@class Place;
@class ScheduledTrain;
@class Yard;

// Helper for dealing with division strings.  Return a whitespace-removed version of the name,
// or return nil if the name was all whitespace.
NSString *NormalizeDivisionString(NSString *inString);

// Object encapsulating all of the layout, and providing several query functions over the entire database.
// Note that EntireLayout isn't a managed object; it's never stored on disk.
@interface EntireLayout : NSObject {
	// Hook to database so EntireLayout can do its queries.
	NSManagedObjectContext *moc_;
	// Cached from LayoutInfo object.
	NSDate *currentDate_;
	NSString *layoutName_;
	Place *workbench_;
	Industry *workbenchIndustry_;
	NSMutableDictionary *preferences_;
	NSMutableDictionary *carTypes_;
    NSArray *popularFreightCarLengths_;
};

- (id) initWithMOC: (NSManagedObjectContext*) moc;

/* Queries used for reports. */
- (NSArray*) allFreightCarsReportingMarkOrder;
- (NSArray*) allFreightCarsSortedByIndustry;
- (NSArray*) allFreightCars;
- (NSArray*) allFreightCarsNotInTrain;
- (NSArray*) allAvailableFreightCars;
- (NSArray*) allReservedFreightCars;
- (NSArray*) allFreightCarsOnWorkbench;
- (NSArray*) allFreightCarsOnLayout;
- (NSArray*) allLoadedFreightCarsReportingMarkOrder;
// Returns a list of lengths of freight cars in order of popularity.  Empty lengths 
// are not counted.
- (NSArray*) freightCarLengths;

// Returns one freight car with matching reporting marks, or nil if none exist.
- (FreightCar*) freightCarWithName: (NSString*) name;

// Array of all Industry objects, excluding the workbench and any yards.
// Generally any industries that can get cargos.
- (NSArray*) allIndustries;
- (NSArray*) allYards;

// Returns one industry or yard with the given name, or nil if none exists.
- (InduYard*) industryOrYardWithName: (NSString*) name;


// List of all cargos with start and end.  For algorithm use.
- (NSArray*) allValidCargos;
// All cargos guaranteed each day.
- (NSArray*) allFixedRateCargos;
// All non-guaranteed (random) cargos.
- (NSArray*) allNonFixedRateCargos;

//All cargos - for UI use.
- (NSArray*) allCargos;
- (NSArray*) allCargosForCarType: (CarType*) carType;

// Calculates the average number of loads per day based on the cargos defined.
- (int) loadsPerDay;

// Returns the list of all stations (Places) on the layout in no particular order.
- (NSArray*) allStations;

// Returns the list of all stations either on the layout or in staging, in alphabetical order.
- (NSArray*) allOnlineStationsSortedOrder;

// Returns an array of all stations ordered by station name.
// PUBLIC TEMPLATE API.
- (NSArray*) allStationsSortedOrder;

- (NSArray*) allStationsInStaging;
- (NSArray*) allStationNamesInStaging;
// Returns a list of potential Places with staging yards that can accept a car going to an offline
// location.
- (NSArray*) allStationsInStagingAcceptingCar: (FreightCar*) car;
// Returns list of freight cars that have reached their destination and can have their load state switched.
// Cars without cargos are not included.
- (NSArray*) allFreightCarsAtDestination;


// workbench place - for testing only.
- (Place*) workbench;
- (Industry*) workbenchIndustry;
// List all cars sitting in a yard.  Used for yard report.
- (NSArray*) allFreightCarsInYard;

- (NSArray*) allTrains;

// Remember the date of the current operating session.
// PUBLIC TEMPLATE API.
- (NSDate*) currentDate;
- (void) setCurrentDate: (NSDate*) date;

// PUBLIC TEMPLATE API.
- (NSString*) layoutName;
- (void) setLayoutName: (NSString*) name;
	
// Returns list of all CarType objects defined in this class.
// No order is guaranteed.
- (NSArray*) allCarTypes;

// Dictionary holding layout-specific preferences.  We use this so that we don't need
// to change the document model (and break on-disk compatibility) for every preference
// we need to add.
- (NSMutableDictionary*) getPreferencesDictionary;
- (void) writePreferencesDictionary;

// For testing only.  Set the raw preferences data.
- (void) setPreferencesDictionary: (NSData*) prefData;

// Creates freight cars based on a string containing car names, and returns the number
// of cars created.
- (int) importFreightCarsUsingString: (NSString*) input errors: (NSString**) outErrors;

// Internal
- (void) initializeWorkbench;

//Testing
// Returns the industry object with the given name in the given station.
- (Industry*) industryWithName: (NSString*) industryName withStationName: (NSString*) stationName;
- (ScheduledTrain*) trainWithName: (NSString*) name;
// Also used in route UI.
- (Place*) stationWithName: (NSString*) name;
// Returns the car type object for a given identifier, or nil if none exists.
- (CarType*) carTypeForName: (NSString*) carType;

- (void) dealloc;
@end


// Sorts cars by the town name for each car, then the industry name for each car, then reporting marks.
NSInteger sortCarsByCurrentIndustry(FreightCar *a, FreightCar *b, void *context);
// Sorts cars by the destination town name for each car, then the industry name for each car, then reporting marks.
NSInteger sortCarsByDestinationIndustry(FreightCar *a, FreightCar *b, void *context);

// Keys declared in model for LayoutInfo.
NSString *LAYOUT_INFO_LAYOUT_NAME;
NSString *LAYOUT_INFO_CURRENT_DATE;
// Dictionary, NSKeyedArchiver-encoded.
NSString *LAYOUT_INFO_LAYOUT_PREFERENCES;

