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
#import "CarType.h"
#import "EntireLayout.h"
#import "FreightCar.h"
#import "ScheduledTrain.h"

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

    return carTypes;
}

// Returns a string containing the comma-separated types of
// car types picked up by this train.
+ (NSString*) acceptedCarTypesString: (NSSet*) acceptedCarTypes {
    CarType* singleCarType = [acceptedCarTypes anyObject];

    // None is functionally the same as all.
    if ([acceptedCarTypes count] == 0) {
        return @"Accepts all car types";
    }

    NSError *error;
    NSEntityDescription *ent = [NSEntityDescription entityForName: @"CarType" inManagedObjectContext: [singleCarType managedObjectContext]];
    NSFetchRequest * req  = [[[NSFetchRequest alloc] init] autorelease];
    [req setEntity: ent];
    NSSortDescriptor *ind1 = [[[NSSortDescriptor alloc] initWithKey: @"carTypeName" ascending: YES] autorelease];
    NSMutableArray *sortDescs = [NSMutableArray arrayWithObject: ind1];
    [req setSortDescriptors: sortDescs];
    
    NSArray *allCarTypes = [[singleCarType managedObjectContext] executeFetchRequest: req error:&error];
    
    if ([acceptedCarTypes count] == 0 || [acceptedCarTypes count] == [allCarTypes count]) {
        return @"Accepts all car types";
    }
    
    // Decide whether what we have, or what we don't have, is smaller.
    int carTypeCount = [allCarTypes count];
    if ([acceptedCarTypes count] < carTypeCount * 0.6) {
        // Show list of accepted car types.
        NSMutableArray* allCarTypeStrings = [NSMutableArray array];
        for (CarType* carType in allCarTypes) {
            if ([acceptedCarTypes containsObject: carType]) {
                [allCarTypeStrings addObject: [carType carTypeName]];
            }
        }
        return [allCarTypeStrings componentsJoinedByString: @", "];
    }
    
    // All but.
    NSMutableArray *nonCarTypeStrings = [NSMutableArray array];
    for (CarType* carType in allCarTypes) {
        if (![acceptedCarTypes containsObject: carType]) {
            [nonCarTypeStrings addObject: [carType carTypeName]];
        }
    }
    
    return [NSMutableString stringWithFormat: @"All car types but %@", [nonCarTypeStrings componentsJoinedByString: @", "]];
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

+ (void) populateCarTypeLengthsFromLayout: (EntireLayout*) layout {
    for (CarType* carType in [layout allCarTypes]) {
        if ([carType carTypeLength] != nil) {
            // Some car types exist.
            return;
        }
    }
    
    for (CarType *carType in [layout allCarTypes]) {
        // Find the length of cars with the car type.  Find the most common length.
        // This is a workaround for car lengths previously been associating with
        // individual cars rather than car types.
        NSMutableDictionary *lengthDict = [NSMutableDictionary dictionary];
        NSArray *allFreightCars = [layout allFreightCars];
        for (FreightCar *fc in allFreightCars) {
            if ([fc carTypeRel] == carType) {
                NSNumber *count = [lengthDict objectForKey: [fc length]];
                if (!count) {
                    count = [NSNumber numberWithInt: 1];
                } else {
                    count = [NSNumber numberWithInt: [count intValue]];
                }
                [lengthDict setObject: count forKey: [fc length]];
            }
        }
        NSNumber *maxLength = nil;
        int maxCount = 0;
        for (NSNumber *length in [lengthDict allKeys]) {
            int count = [[lengthDict objectForKey: length] intValue];
            if (count > maxCount) {
                maxCount = count;
                maxLength = length;
            }
        }
        [carType setCarTypeLength: maxLength];
    }
}
		
@end
