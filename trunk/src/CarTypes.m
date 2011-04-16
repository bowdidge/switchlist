//
//  CarTypes.m
//  SwitchList
//
//  Created by bowdidge on 11/6/10.
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

#import "CarTypes.h"

#import <Foundation/Foundation.h>

#import "Cargo.h"
#import "EntireLayout.h"
#import "SCheduledTrain.h"

@implementation CarTypes
// Populates a dictionary of car types by analyzing the current layout to see what's
// defined, and including some common and popular car types from the AAR classification.
+ (NSDictionary*) populateCarTypesFromLayout: (EntireLayout*) layout {
	NSMutableDictionary *carTypes = [NSMutableDictionary dictionary];
	
	// Insert defaults.
	[carTypes setObject: @"boxcar (40')" forKey: @"XM"];
	[carTypes setObject: @"boxcar (50')" forKey: @"XA"];
	[carTypes setObject: @"refrigerator car (40')" forKey: @"RS"];
	[carTypes setObject: @"tankcar" forKey: @"T"];
	[carTypes setObject: @"flatcar" forKey: @"FM"];
	[carTypes setObject: @"gondola" forKey: @"G"];
	[carTypes setObject: @"stockcar" forKey: @"S"];
	[carTypes setObject: @"covered hopper" forKey: @"RO"];
	
	// Find all others mentioned.
	NSArray *allFreightCars = [layout allFreightCars];
	FreightCar *fc;
	for (fc in allFreightCars) {
		NSString *fcType = [fc primitiveValueForKey: @"carType"];
		// Ignore empty strings.
		if ([CarTypes isValidCarType: fcType] &&
			[carTypes objectForKey: fcType] == nil) {
			[carTypes setObject: @"" forKey: fcType];
		}
	}
	
	for (Cargo *c in [layout allValidCargos]) {
		NSString *carType = [c primitiveValueForKey: @"carType"];
		if ([CarTypes isValidCarType: carType] &&
			[carTypes objectForKey: carType] == nil) {
			[carTypes setObject: @"" forKey: carType];
		}
	}

	for (ScheduledTrain *train in [layout allTrains]) {
		NSString *carTypesAccepted = [train primitiveValueForKey: @"acceptedCarTypes"];
		NSArray *types = [carTypesAccepted componentsSeparatedByString: @","];
		for (NSString *type in types) {
			if ([CarTypes isValidCarType: type] &&
				[carTypes objectForKey: type] == nil) {
				[carTypes setObject: @"" forKey: type];
			}
		}
	}
		return carTypes;
}

// Returns the list of car types that we provide in all cases.
+ (NSDictionary*) stockCarTypes {
	return [CarTypes populateCarTypesFromLayout: nil];
}

// Returns the list of car types that we provide in all cases.
+ (NSArray*) stockCarTypeArray {
	return [[CarTypes populateCarTypesFromLayout: nil] allKeys];
}

// Determines if the car type is valid - basically alphanumeric with no whitespace.
+ (BOOL) isValidCarType: (NSString*) carTypeString {
	if (carTypeString == nil) return NO;
	if ([carTypeString isEqualToString: @""]) return NO;
	
	NSCharacterSet *validCharacters = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
	// TODO(bowdidge): Allow non-alphanumeric eventually?
	// Doesn't matter b/c this is only for converting old file.
	if ([carTypeString rangeOfCharacterFromSet: validCharacters].location != NSNotFound) {
		return NO;
	}
	return YES;
}
		
@end
