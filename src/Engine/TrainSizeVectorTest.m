//
//
//  TrainSizeVectorTest.m
//  SwitchList
//
//  Created by bowdidge on 2/25/12.
//
// Copyright (c)2012 Robert Bowdidge,
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

#import "TrainSizeVectorTest.h"

#import "EntireLayout.h"
#import "FreightCar.h"
#import "ScheduledTrain.h"
#import "TrainSizeVector.h"

@implementation TrainSizeVectorTest
- (void) setUp {
	[super setUp];
	[self makeThreeStationLayout];
	
	stops_ = [[NSArray alloc] initWithObjects:
			  [entireLayout_ stationWithName: @"A"],
			  [entireLayout_ stationWithName: @"B"],
			  [entireLayout_ stationWithName: @"C"],
			  nil];	
}

- (void) tearDown {
	[stops_ release];
	stops_ = nil;
}

- (void) testSimpleLoaded {
	NSMutableArray *cars = [NSMutableArray array];
	[cars addObject: [self makeFreightCarNamed: @"AA 1"
											at: @"A"
									movingFrom: @"C" to:@"C" loaded: YES]];
	 
	
	TrainSizeVector *trainSizeVector = [[[TrainSizeVector alloc] initWithCars: cars
																		stops: stops_] autorelease];
	NSArray *changeInLength = [trainSizeVector vector];
	XCTAssertEqualInt(3, [changeInLength count], @"");
	// Car1 goes a to b, car2 goes b to c.
	XCTAssertEqualInt(40, [[changeInLength objectAtIndex: 0] changeInLengthAtStop],
                      @"");
	XCTAssertEqualInt(0, [[changeInLength objectAtIndex: 1] changeInLengthAtStop],
                      @"");
	XCTAssertEqualInt(-40, [[changeInLength objectAtIndex: 2] changeInLengthAtStop],
                      @"");
	
	XCTAssertFalse([trainSizeVector vectorExceedsLength: 80], @"");
	XCTAssertFalse([trainSizeVector vectorExceedsLength: 40], @"");
	XCTAssertTrue([trainSizeVector vectorExceedsLength: 0], @"");				
}
	 
- (void) testSimpleUnloaded {
	NSMutableArray *cars = [NSMutableArray array];
	[cars addObject: [self makeFreightCarNamed: @"AA 1"
											at: @"A"
									movingFrom: @"C" to:@"A" loaded: NO]];
		  
	TrainSizeVector *trainSizeVector = [[[TrainSizeVector alloc] initWithCars: cars stops: stops_] autorelease];
    NSArray *changeInLength = [trainSizeVector vector];
		  
    XCTAssertEqualInt(3, [changeInLength count], @"");
	// Car1 goes a to b, car2 goes b to c.
	XCTAssertEqualInt(40, [[changeInLength objectAtIndex: 0] changeInLengthAtStop],
                      @"");
	XCTAssertEqualInt(0, [[changeInLength objectAtIndex: 1] changeInLengthAtStop],
                      @"");
	XCTAssertEqualInt(-40, [[changeInLength objectAtIndex: 2] changeInLengthAtStop],
                      @"");
		  
	XCTAssertFalse([trainSizeVector vectorExceedsLength: 80], @"");
	XCTAssertFalse([trainSizeVector vectorExceedsLength: 40], @"");
	XCTAssertTrue([trainSizeVector vectorExceedsLength: 0], @"");				
}

- (void) testTrainLengthArrayCorrectlyHandlesCarsNotMovedBetweenTowns {
	NSMutableArray *cars = [NSMutableArray array];
	// Shouldn't count.
	[cars addObject: [self makeFreightCarNamed: @"AA 1"
											at: @"A"
									movingFrom: @"A" to:@"C" loaded: NO]];
	[cars addObject: [self makeFreightCarNamed: @"AA 2"
											at: @"A"
									movingFrom: @"B" to:@"C" loaded: NO]];
	
	TrainSizeVector *trainSizeVector = [[[TrainSizeVector alloc] initWithCars: cars
																		stops: stops_] autorelease];
	NSArray *changeInLength = [trainSizeVector vector];
	
	XCTAssertEqualInt(3, [changeInLength count], @"change in length array wrong size");
	XCTAssertEqualInt(40, [[changeInLength objectAtIndex: 0] changeInLengthAtStop], @"Wrong change in car count for town A");
	XCTAssertEqualInt(-40, [[changeInLength objectAtIndex: 1] changeInLengthAtStop], @"Wrong change in car count for town B");
	XCTAssertEqualInt(0, [[changeInLength objectAtIndex: 2] changeInLengthAtStop], @"Wrong change in car count for town C");

	XCTAssertFalse([trainSizeVector vectorExceedsLength: 80], @"");
	XCTAssertFalse([trainSizeVector vectorExceedsLength: 40], @"");
	XCTAssertTrue([trainSizeVector vectorExceedsLength: 0], @"");				
}

- (void) testCarsNotMovingDoNotAffectTrainLength {
	NSMutableArray *cars = [NSMutableArray array];
	[cars addObject: [self makeFreightCarNamed: @"AA 1"
											at: @"B"
									movingFrom: @"B" to:@"B" loaded: NO]];
	[cars addObject: [self makeFreightCarNamed: @"AA 2"
											at: @"B"
									movingFrom: @"B" to:@"C" loaded: NO]];
	
	[cars addObject: [self makeFreightCarNamed: @"AA 3"
											at: @"C"
									movingFrom: @"B" to:@"C" loaded: YES]];
	

	TrainSizeVector *trainSizeVector = [[[TrainSizeVector alloc] initWithCars: cars
																		stops: stops_] autorelease];
	NSArray *changeInLength = [trainSizeVector vector];
	XCTAssertEqualInt(3, [changeInLength count], @"change in length array wrong size");
	XCTAssertEqualInt(0, [[changeInLength objectAtIndex: 0] changeInLengthAtStop], @"Wrong change in car cound for town A");
	XCTAssertEqualInt(0, [[changeInLength objectAtIndex: 1] changeInLengthAtStop], @"Wrong change in car cound for town B");
	XCTAssertEqualInt(0, [[changeInLength objectAtIndex: 2] changeInLengthAtStop], @"Wrong change in car cound for town C");
}

@end

// TODO: Add tests of sums.

@interface OutAndBackTrainSizeVectorTest : LayoutTest {
	NSMutableArray *stops_;
}
@end
@implementation OutAndBackTrainSizeVectorTest
- (void) setUp {
	[super setUp];
	[self makeThreeStationLayout];
	stops_ = [[NSMutableArray alloc] initWithObjects:
			  [entireLayout_ stationWithName: @"A"],
			  [entireLayout_ stationWithName: @"B"],
			  [entireLayout_ stationWithName: @"C"],
			  [entireLayout_ stationWithName: @"B"],
			  [entireLayout_ stationWithName: @"A"],
			  nil];
}

- (void) tearDown {
	[stops_ release];
	stops_ = nil;
}
			  
- (void) testOutAndBack {
	NSMutableArray *cars = [NSMutableArray array];
	[cars addObject: [self makeFreightCarNamed: @"AA 1"
														at: @"A"
												movingFrom: @"A" to:@"C" loaded: YES]];
	[cars addObject: [self makeFreightCarNamed: @"AA 2"
														at: @"A"
												movingFrom: @"B" to:@"C" loaded: NO]];
	
	[cars addObject: [self makeFreightCarNamed: @"AA 3"
														at: @"B"
												movingFrom: @"B" to:@"B" loaded: YES]];
	
	FreightCar *newCar = [self makeFreightCarNamed: @"AA 4"	at: @"B" movingFrom: @"B" to:@"C" loaded: YES];
	NSArray *addedCarArray = [NSArray arrayWithObject: newCar];
	
	TrainSizeVector *trainVector = [[[TrainSizeVector alloc] initWithCars: cars stops: stops_] autorelease];
	TrainSizeVector *addedCarVector = [[[TrainSizeVector alloc] initWithCars: addedCarArray stops: stops_] autorelease];
	XCTAssertTrue([trainVector vectorExceedsLength: 40], @"Expected train max length greater than 80 but found %@", trainVector);
	// This fails because b->b not treated as same location.
	XCTAssertFalse([trainVector vectorExceedsLength: 80], @"Expected train never longer than 80, but found %@", trainVector);
	XCTAssertFalse([addedCarVector vectorExceedsLength: 40], @"");
	
	[addedCarVector addVector: trainVector];
	XCTAssertFalse([trainVector vectorExceedsLength: 80], @"Expected maximum length = 80, was %d", [trainVector maximumLength]);
}

- (void) testOutAndBack2 {
	NSMutableArray *cars = [NSMutableArray array];
	[cars addObject: [self makeFreightCarNamed: @"AA 1"
											at: @"C"
									movingFrom: @"C" to:@"B" loaded: YES]];
	

	TrainSizeVector *trainVector = [[[TrainSizeVector alloc] initWithCars: cars stops: stops_] autorelease];
	XCTAssertEqualInt(40, [trainVector maximumLength], @"");
}

@end
