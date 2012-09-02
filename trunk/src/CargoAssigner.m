//
//  CargoAssigner.m
//  SwitchList
//
//  Created by Robert Bowdidge on 10/29/10.
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

#import "CargoAssigner.h"

#import "Cargo.h"
#import "EntireLayout.h"

@implementation CargoAssigner
- (id) initWithEntireLayout: (EntireLayout*) layout {
	self = [super init];
	entireLayout_ = [layout retain];
	generator_ = [[RandomNumberGenerator alloc] init];
	return self;
}

- (void) dealloc {
	[entireLayout_ release];
	[generator_ release];
	[super dealloc];
}

- (NSArray *) cargosForToday: (int) count {
	// Pick a random set of cargos for numberOfCar loads.  
	//result array may contain dup pointers to cargo objects.
	NSMutableArray *resultCargos = [NSMutableArray array];
	int i;
	
	// First, run through cargos with guarantee/fixed number of
	// arrivals.  Add those to the beginning of the list.
	Cargo *cargo;
	for (cargo in [entireLayout_ allFixedRateCargos]) {
		int cargosPerMonth = [[cargo carsPerMonth] intValue];
		int i;
		for (i=0; i < cargosPerMonth / 30; i++) {
			[resultCargos addObject: cargo];
		}
		// For the fractional part, choose random number to
		// decide if the fractional car appears today.
		if ([generator_ generateRandomNumber: 30] < (cargosPerMonth % 30)) {
			[resultCargos addObject: cargo];
		}
	}
	
	// Now, add the non-guaranteed cargos.
	NSArray *allCargos = [entireLayout_ allNonFixedRateCargos];
	// Sum up total number of cars/month
	int sum=0;
	for (cargo in allCargos) {
		NSLog(@"month %@", [cargo carsPerMonth]);
		sum += [[cargo carsPerMonth] intValue];
	}
	for (i=0;i<count;i++) {
		int cargoChoice = [generator_ generateRandomNumber: sum];
		int curSum=0;
		for (cargo in allCargos) {
			int thisCargoCarsPerMonth = [[cargo carsPerMonth] intValue];
			if (cargoChoice < thisCargoCarsPerMonth + curSum) {
				// this is our match
				[resultCargos addObject: cargo];
				break;
			}
			curSum += thisCargoCarsPerMonth;
		}
	}
	
	return resultCargos;
}


// For testing only.
- (void) setRandomNumberGenerator: (NSObject<RandomNumberGeneratorInterface>*) generator {
	[generator_ release];
	generator_ = [generator retain];
}

@end
