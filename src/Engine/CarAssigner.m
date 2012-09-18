//
//  CarAssigner.m
//  SwitchList
//
//  Created by Robert Bowdidge on 11/3/07.
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

#import "CarAssigner.h"
#import "Cargo.h"
#import "Industry.h"
#import "RandomNumberGenerator.h"

@interface NSArray (RandomizedList) 
- (NSArray*) randomizeWithGenerator: (NSObject<RandomNumberGeneratorInterface> *) generator;
@end

@implementation NSArray (RandomizedList)

// Creates a new version of an array in a different order chosen randomly.
- (NSArray*) randomizeWithGenerator: (NSObject<RandomNumberGeneratorInterface>*) generator {
	NSMutableArray *remainingItems = [NSMutableArray arrayWithArray: self];
	NSMutableArray *result = [NSMutableArray array];
	int i;
	for (i=[remainingItems count]; i>0; i--) {
		int itemToRemove = [generator generateRandomNumber: i];
		id object = [remainingItems objectAtIndex: itemToRemove];
		[remainingItems removeObjectAtIndex: itemToRemove];
		[result addObject: object];
	}
	return result;
}
@end

@implementation CarAssigner
- (id) initWithUnassignedCars: (NSArray*) cars {
	self = [super init];
	availableCars_ = [[NSMutableArray alloc] initWithArray: cars];
	generator_ = [[RandomNumberGenerator alloc] init];
	return self;
}

- (BOOL) cargo: (Cargo*) cargo appropriateForCar: (id) frtCar  {

	CarType *cargoCarReqt = [cargo carTypeRel];
	
	// If a car type was specified and it doesn't match, ignore this car.
	if (cargoCarReqt && [frtCar carTypeRel] && cargoCarReqt != [frtCar carTypeRel]) {
		return NO;
	}
	
	// Is car's division undefined?  It can be used in any case.
	if ([frtCar homeDivision] == nil) return YES;
		
	// If source or destination division is undefined, it can be used in any case.
	if ([[cargo source] division] == nil) return YES;
	if ([[cargo destination] division] == nil) return YES;
	
	// we found a car to use
	// Does the car either match the division of the source or dest?  If not, don't use
	NSString *homeDiv = [frtCar homeDivision];
	NSString *sourceDivision = [[cargo source] division];
	NSString *destinationDivision = [[cargo destination] division];
	if (([homeDiv compare: sourceDivision] != NSOrderedSame) &&
		([homeDiv compare: destinationDivision] != NSOrderedSame)) {
		// this car would rather go home empty than take this cargo somewhere else.
		return NO;
	}
		
	return YES;

}

	
- (FreightCar*) assignedCarForCargo: (Cargo*) cargo {
	// pick first cargo.  Find first freight car with this car type. 
	// set cargo on freight car to that cargo, remove freight car from available list, and loop.
	NSEnumerator *e = [[availableCars_ randomizeWithGenerator: generator_] objectEnumerator];
	FreightCar *frtCar;
	while ((frtCar = [e nextObject]) != nil) {
		if ([self cargo: cargo appropriateForCar: frtCar] == YES) {
			[frtCar setCargo: cargo];
			if (([[frtCar currentLocation] isStaging]) && ([[[frtCar cargo] source] isOffline])) {
				// Just mark it as loaded ASAP.  This keeps the car from sitting in staging for a round.
				[frtCar setIsLoaded: YES];
			} else if ([frtCar currentLocation] == [[frtCar cargo] source]) {
				// We're here, assume it's loaded.
				[frtCar setIsLoaded: YES];
			} else {
				[frtCar setIsLoaded: NO];
			}
			[availableCars_ removeObject: frtCar];
			return frtCar;
		}
	} 
	
	return nil;
}

- (void) dealloc {
	[availableCars_ release];
	[generator_ release];
	[super dealloc];
}

// For testing only.
- (void) setRandomNumberGenerator: (NSObject<RandomNumberGeneratorInterface>*) generator {
	[generator_ release];
	generator_ = [generator retain];
}

@end
