//
//  CarAssigner.h
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

#import <Foundation/Foundation.h>
#import "Cargo.h"
#import "EntireLayout.h"
#import "FreightCar.h"
#import "RandomNumberGenerator.h"

// This object hides the process of choosing an appropriate car for a cargo.
// It's initialized with the unattached cars, and then as cargos are given, it chooses 
// an appropriate freight car, and removes the car from the list of eligible cars.

@interface CarAssigner : NSObject {
	NSMutableArray *availableCars_;
	NSObject<RandomNumberGeneratorInterface> *generator_;
}

- (id) initWithUnassignedCars: (NSArray*) cars;
- (FreightCar*) assignedCarForCargo: (Cargo*) cargo;

// For testing only:
- (BOOL) cargo: (Cargo*) cargo appropriateForCar: (id) frtCar;

// For testing only.
- (void) setRandomNumberGenerator: (NSObject<RandomNumberGeneratorInterface>*) generator;

@end
