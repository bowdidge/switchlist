//
//  InduYard.m
//  SwitchList
//
//  Created by bowdidge on 10/29/10.
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

#import "InduYard.h"

#import "Cargo.h"
#import "EntireLayout.h"
#import "FreightCar.h"
#import "Place.h"
#import "StringHelpers.h"


@implementation InduYard

@dynamic name;
@dynamic division;
@dynamic location;
@dynamic originatingCargos;
@dynamic terminatingCargos;

- (BOOL) isOffline {
	return [[self location] isOffline];
}

- (BOOL) isStaging {
	return [[self location] isStaging];
}

- (BOOL) isOnline {
	return [[self location] isOnLayout];
}

// Returns whether this is a valid industry for receiving cargo.  Yards and Workbench don't count.
- (BOOL) canReceiveCargo {
	if ([self isYard]) {
		return false;
	}
	
	if ([[self name] isEqualToString: @"Workbench"]) {
		return false;
	}
	return true;
}

- (NSSet*) freightCars {
	NSEntityDescription *ent = [NSEntityDescription entityForName: @"FreightCar" inManagedObjectContext: [self managedObjectContext]];
	NSFetchRequest * req2  = [[[NSFetchRequest alloc] init] autorelease];
	[req2 setEntity: ent];
	[req2 setPredicate: [NSPredicate predicateWithFormat:[NSString stringWithFormat: @"currentLocation.name LIKE '%@'",[[self name] sqlSanitizedString]]]];
	NSError *error;
	return [NSSet setWithArray: [[self managedObjectContext] executeFetchRequest: req2 error:&error]];
}

- (BOOL) isYard {
	return false;
}

// Is industry, not yard, not in staging or offline.
- (BOOL) isRegularIndustry {
	return ([self isYard] == NO &&
			[self isOffline] == NO &&
			[self isStaging] == NO);
}

// If sidingLength isn't defined, say it's zero.
- (NSNumber*) sidingLength {
	return nil;
}

// Returns true if industry or yard can have cars spotted at specific places.
- (BOOL) hasDoors { 
	// By default, yards and industries do not have door assignments.
	return NO;
}

- (NSNumber *)numberOfDoors {
	return [NSNumber numberWithInt: 0];
}

// Returns array of valid door numbers for this industry.  For population of NSPopUpButton.
- (NSArray*) doorList {
	int ct = [[self numberOfDoors] intValue];
	NSMutableArray *result = [NSMutableArray array];
	int i;
	for (i=1; i <= ct; i++) {
		[result addObject: [NSNumber numberWithInt: i]];
	}
	return result;
}
		 
// Sorts freight car reporting marks by railroad, then number.  SP 3941 should appear before SP 10240.
- (NSArray*) allFreightCarsSortedOrder {
	return [[[self freightCars] allObjects] sortedArrayUsingFunction: compareReportingMarksAlphabetically context: nil];
}

- (NSComparisonResult) compareNames: (InduYard*) i {
	return [[self name] compare: [i name]];
}

// Returns the fullness of the siding.
- (enum SidingOccupancyRating) cargoLoad {
    // How full would the industry be with the current cargos?
    int sidingLength = [[self sidingLength] intValue];
    float freightCarFeetPerDay =0.0;
    
    for (Cargo *c in [self originatingCargos]) {
        freightCarFeetPerDay += 40 * [[c carsPerMonth] intValue] / 30.0;
    }
    
    for (Cargo *c in [self terminatingCargos]) {
        freightCarFeetPerDay += 40 * [[c carsPerMonth] intValue] * [[c unloadingDays] intValue] / 30.0;
    }
    
    // Turn into 0-1 percentage of being full.
    float occupancyPercent = freightCarFeetPerDay / sidingLength;
    if (occupancyPercent == 0.0) {
        return SidingEmpty;
    } else if (occupancyPercent < 0.2) {
        return SidingQuiet;
    } else if (occupancyPercent < 0.5) {
        return SidingModerate;
    } else if (occupancyPercent < 0.8) {
        return SidingBusy;
    }
    return SidingOverloaded;
}


// Copy fields that are officially part of the HTML template to the dictionary
// representing an industry.
- (NSMutableDictionary*) templateDictionary {
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[dict setObject: [self name] forKey: @"name"];
	[dict setObject: [self location] forKey: @"location"];
	return dict;
}

- (id) nameAndLoad {
    // TODO(bowdidge): Cache.
    if ([self isYard] || [[self sidingLength] intValue] == 0) {
        return [self name];
    }
    NSString *occupancy = SidingOccupancyString([self cargoLoad]);
    NSString *rawString = [NSString stringWithFormat: @"%@ (%@)", [self name], occupancy];
    return rawString;
}

NSString* SidingOccupancyString(enum SidingOccupancyRating r) {
    switch (r) {
        case SidingEmpty:
            return @"Unused";
            break;
        case SidingQuiet:
            return @"Quiet";
            break;
        case SidingModerate:
            return @"Moderate";
            break;
        case SidingBusy:
            return @"Busy";
            break;
        case SidingOverloaded:
            return @"Overloaded";
            break;
    }
}

@end
