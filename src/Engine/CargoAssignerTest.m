//
//
//  CargoAssignerTest.m
//  SwitchList
//
//  Created by bowdidge on 2/17/11.
//
// Copyright (c)2011 Robert Bowdidge,
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

#import "Cargo.h"
#import "CargoAssignerTest.h"
#import "Industry.h"

@implementation CargoAssignerTest

- (void) setUp {
	[super setUp];
	[self makeThreeStationLayout];
	cargoAssigner_ = [[CargoAssigner alloc] initWithEntireLayout: entireLayout_];
}

- (void) testDailyCargo {
	Cargo *c1 = [self makeCargo: @"a to b"];
	[c1 setRate: [NSNumber numberWithInt: 3]];
	[c1 setRateUnits: [NSNumber numberWithInt: RATE_PER_DAY]];
	XCTAssertEqualInt(21, [[c1 carsPerWeek] intValue], @"Expected 21 cars per week.");
}
	
- (void) testFixedRateCargosAlwaysShowUp {
	[self makeThreeStationLayout];

	Cargo *c1 = [self makeCargo: @"a to b"];
	[c1 setSource: [self industryAtStation: @"A"]];
	[c1 setDestination: [self industryAtStation: @"B"]];
	[c1 setPriority: [NSNumber numberWithBool: YES]];
	[c1 setCarsPerWeek: [NSNumber numberWithInt: 35]];

	Cargo *c2 = [self makeCargo: @"b to c"];
	[c2 setSource: [self industryAtStation: @"B"]];
	[c2 setDestination: [self industryAtStation: @"C"]];
	[c2 setCarsPerWeek: [NSNumber numberWithInt: 38]];

	Cargo *c3 = [self makeCargo: @"c to a"];
	[c3 setSource: [self industryAtStation: @"C"]];
	[c3 setDestination: [self industryAtStation: @"A"]];
	[c3 setCarsPerWeek: [NSNumber numberWithInt: 35]];
	
	// Should be 5 cars per day with cargo C1, and an average of 5 cargos with cargo type C2 and C3.
	NSArray *cargos = [cargoAssigner_ cargosForToday: 10];
	int i;
	for (i=0; i<5; i++) {
		XCTAssertEqual(c1, [cargos objectAtIndex: i], @"%d of 5 cargos not priority", i);
	}
	int cargoCount = [cargos count];
	XCTAssertEqualInt(15, [cargos count], @"Not enough cargos chosen.");
	
	int numberOfC2=0;
	for (i=0;i<15;i++) {
		if ([cargos objectAtIndex: i] == c2) numberOfC2++;
	}
	
	// Should be true most of the time.
	XCTAssertTrue(numberOfC2 > 2 && numberOfC2 < 8, @"c2 came up %d times - not random enough?", numberOfC2);
	
	for (i=5; i < 15; i++) {
		Cargo *c = [cargos objectAtIndex: i];
		XCTAssertTrue(c == c2 || c == c3, @"%dth cargo is not c2 or c3", i);
	}
}

int CountOfItemInArray(id item, NSArray* array) {
	int count = 0;
	for (id i in array) {
		if (i == item) {
			count++;
		}
	}
	return count;
}
	
- (void) testMixOfDailyAndWeekly {
	[self makeThreeStationLayout];
	
	MockRandomNumberGenerator *generator = [[[MockRandomNumberGenerator alloc] init] autorelease];
	NSMutableArray *numbers = [NSMutableArray array];
	int totalCargoChoiceCount = 30 + 4 + 1;
	int i;
	for (i=0; i < totalCargoChoiceCount; i++) {
		[numbers addObject: [NSNumber numberWithInt: totalCargoChoiceCount - i - 1]];
	}
		
	[generator setNumbers: numbers];
	[cargoAssigner_ setRandomNumberGenerator: generator];
	 
	Cargo *c1 = [self makeCargo: @"a to b"];
	[c1 setSource: [self industryAtStation: @"A"]];
	[c1 setDestination: [self industryAtStation: @"B"]];
	[c1 setRate: [NSNumber numberWithInt: 1]];
	[c1 setRateUnits: [NSNumber numberWithInt: RATE_PER_DAY]];
	
	Cargo *c2 = [self makeCargo: @"b to c"];
	[c2 setSource: [self industryAtStation: @"B"]];
	[c2 setDestination: [self industryAtStation: @"C"]];
	[c2 setRate: [NSNumber numberWithInt: 1]];
	[c2 setRateUnits: [NSNumber numberWithInt: RATE_PER_WEEK]];
	
	Cargo *c3 = [self makeCargo: @"c to a"];
	[c3 setSource: [self industryAtStation: @"C"]];
	[c3 setDestination: [self industryAtStation: @"A"]];
	[c3 setRate: [NSNumber numberWithInt: 1]];
	[c3 setRateUnits: [NSNumber numberWithInt: RATE_PER_MONTH]];
	
	NSArray *cargos = [cargoAssigner_ cargosForToday: totalCargoChoiceCount];
	int cargoCount = [cargos count];
	XCTAssertEqualInt(totalCargoChoiceCount, [cargos count], @"Not enough cargos chosen.");
	
	XCTAssertEqual(30, CountOfItemInArray(c1, cargos), @"");
	XCTAssertEqual(4, CountOfItemInArray(c2, cargos), @"");
	XCTAssertEqual(1, CountOfItemInArray(c3, cargos), @"");
}

- (void) tearDown {
	[cargoAssigner_ release];
	[super tearDown];
}
@end
