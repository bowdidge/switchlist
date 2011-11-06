//
//  LayoutTest.h
//  SwitchList
//
//  Created by bowdidge on 10/27/10.
//
// Copyright (c)2010 Robert Bowdidge,
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


#import <SenTestingKit/SenTestingKit.h>
#import <CoreData/CoreData.h>
#import "NSManagedObjectContext.h"

@class Cargo;
@class CarType;
@class EntireLayout;
@class FreightCar;
@class Industry;
@class ScheduledTrain;
@class Place;
@class Yard;


// Base class holds test harness code for building up sample layouts in the persistent store.
@interface LayoutTest : SenTestCase {
	NSPersistentStoreCoordinator *coord_;
    NSManagedObjectContext *context_;
    NSManagedObjectModel *model_;
    NSPersistentStore *store_;
	
	// Handy reference to EntireLayout.
	EntireLayout *entireLayout_;
}

// Handy functions for creating persistent objects.
- (FreightCar*) makeFreightCarWithReportingMarks: (NSString*) reportingMarks;
- (ScheduledTrain*) makeTrainWithName: (NSString*) name;
- (Place*) makePlaceWithName: (NSString*) name;
- (Cargo*) makeCargo: (NSString*) name;
// Helper for creating new CarType objects in the layout database.
- (CarType*) makeCarType: (NSString*) name;

// Creates persistent industry in current managed object context.
- (Industry *) makeIndustryWithName: (NSString *) name;

// Creates a persistent yard in the current managed object context.
- (Yard *) makeYardWithName: (NSString *) name;

// Set the kinds of car types picked up by this train.  Allows using short names
// for easier setup.
- (void) setTrain: (ScheduledTrain*) st acceptsCarTypes: (NSString*) carTypesToSetString;
// Handy objects for creating entire starter layouts.

// Creates a layout with no stations, cars, or trains.
- (void) makeSimpleLayout;
// Creates a layout with three stations A, B, and C.
- (void) makeThreeStationLayout;
- (void) makeThreeStationLayoutWithDivisions: (BOOL) divisions;
// Same, but no intermediate yards.
- (void) makeThreeStationLayoutNoYards;
// Make train that goes A->B->C.
- (void) makeThreeStationTrain;
- (Yard*) makeYardAtStation: (NSString*) stationName;

- (FreightCar*) freightCarWithReportingMarks: (NSString*) reportingMarks;

// Queries for simplifying unit tests. 
// Find the yard named stationName-yard in the given station.
- (Yard*) yardAtStation: (NSString*) stationName;
// Assumes only one industry at each station with name town-industry
- (Industry*) industryAtStation: (NSString*) stationName;
- (EntireLayout*) entireLayout;

- (void) checkRoute: (NSArray*) routeOfPlaces equals: (NSString*) stringOfStops;


extern NSString *FREIGHT_CAR_1_NAME;
extern NSString *FREIGHT_CAR_2_NAME;

@end

/*" Generates a failure when contains does not appear in container. This test is for
 Objective C strings.
 _{contains    The string to find.}
 _{container    The string to search.}
 _{description A format string as in the printf() function. Can be nil or
 an empty string but must be present.}
 _{... A variable number of arguments to the format string. Can be absent.}
 "*/
#define STAssertContains(contains, container, description, ...) \
do { \
  @try {\
    NSString *containsvalue = [NSString stringWithString: (contains)]; \
    NSString *containervalue = [NSString stringWithString: (container)]; \
    if ([containervalue rangeOfString: containsvalue].location == NSNotFound ) { \
      [self failWithException:([NSException failureInCondition: [NSString stringWithFormat: @"%@ in %@", containsvalue, containervalue] \
					   isTrue: false \
					   inFile:[NSString stringWithUTF8String:__FILE__] \
                       atLine:__LINE__ \
              withDescription:@"%@", STComposeString(description, ##__VA_ARGS__)])]; \
    } \
  } \
  @catch (id anException) {\
    [self failWithException:([NSException \
             failureInRaise:[NSString stringWithFormat:@"(%s) in (%s)", #contains, #container] \
                  exception:anException \
					 inFile:[NSString stringWithUTF8String:__FILE__] \
                     atLine:__LINE__ \
            withDescription:@"%@", STComposeString(description, ##__VA_ARGS__)])]; \
  }\
} while(0)

/*" Generates a failure when contains does not appear in container. This test is for
 Objective C strings.
 _{contains    The string to find.}
 _{container    The string to search.}
 _{description A format string as in the printf() function. Can be nil or
 an empty string but must be present.}
 _{... A variable number of arguments to the format string. Can be absent.}
 "*/
#define STAssertNotContains(contains, container, description, ...) \
do { \
@try {\
NSString *containsvalue = [NSString stringWithString: (contains)]; \
NSString *containervalue = [NSString stringWithString: (container)]; \
if ([containervalue rangeOfString: containsvalue].location != NSNotFound ) { \
[self failWithException:([NSException failureInCondition: [NSString stringWithFormat: @"%@ not in %@", containsvalue, containervalue] \
isTrue: false \
inFile:[NSString stringWithUTF8String:__FILE__] \
atLine:__LINE__ \
withDescription:@"%@", STComposeString(description, ##__VA_ARGS__)])]; \
} \
} \
@catch (id anException) {\
[self failWithException:([NSException \
failureInRaise:[NSString stringWithFormat:@"(%s) in (%s)", #contains, #container] \
exception:anException \
inFile:[NSString stringWithUTF8String:__FILE__] \
atLine:__LINE__ \
withDescription:@"%@", STComposeString(description, ##__VA_ARGS__)])]; \
}\
} while(0)
