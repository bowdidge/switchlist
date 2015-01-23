//
//  Cargo.h
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

@class CarType;
@class InduYard;

enum RateUnits {
	RATE_PER_DAY = 0,
	RATE_PER_WEEK = 1,
	RATE_PER_MONTH = 2
};

// for cargoRate method.
struct CargoRate {
    int rate;
    enum RateUnits units;
};

@interface Cargo :  NSManagedObject  
{
}

// Does the car occur with some random chance, or shopuld exactly the
// requested number of cars appear every operating session?
// TODO(bowdidge): Rename to "fixedRate" when we next redo the schema.
@property (nonatomic, retain) NSNumber *priority;
@property(nonatomic, retain) CarType* carTypeRel;
@property (nonatomic, retain) NSString* cargoDescription;
@property (nonatomic, retain) InduYard* source, *destination;
// rate replaces carsPerMonth.  rate is an NSNumber (integer) representing the number
// of cars per unit time; rateUnits is 0 for per day, 1 for perWeek, 2 for perMonth.
@property (nonatomic, retain) NSNumber* rate, *rateUnits;
@property (nonatomic, retain) NSNumber* unloadingDays;


- (NSNumber *)carsPerWeek;
- (void)setCarsPerWeek:(NSNumber *)value;

- (NSNumber*) carsPerMonth;
- (void)setCarsPerMonth:(NSNumber *)value;

- (NSNumber*) unloadingDays;
- (void) setUnloadingDays: (NSNumber *) value;

// Returns rate in terms of the unit that the user explicitly chose.
- (struct CargoRate) cargoRate;

// Only for consistency in template language.
- (NSString*) name;
// Returns the string name of the car type for this cargo.
- (NSString*) carType;

- (BOOL) isSourceOffline;
- (BOOL) isDestinationOffline;

- (BOOL) isPriority;

// Returns the text that should appear when hovering over the cargo in a menu.
- (NSString*) tooltip;

- (NSString*) descriptionForCopy;

@end
