//
//  CarTypesTest.m
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

#import "CarTypesTest.h"

#import "CarTypes.h"
#import "Cargo.h"
#import "EntireLayout.h"
#import "FreightCar.h"
#import "Industry.h"

@implementation CarTypesTest

- (void) testFreightCarValueSet {
	//CarType *ct = [self makeCarType: @"MyType"];
	FreightCar *fc1 = [self makeFreightCarWithReportingMarks: @"AAAA 1111"];
	[fc1 setPrimitiveValue: @"MyType" forKey: @"carType"];
	
	NSDictionary *stockCars = [CarTypes stockCarTypes];
	NSDictionary *carTypes = [CarTypes populateCarTypesFromLayout: entireLayout_];
	NSArray *allCars = [entireLayout_ allFreightCars];
	STAssertTrue([CarTypes isValidCarType: @"MyType"], @"MyType not considered valid type");
	STAssertNotNil([carTypes objectForKey: @"MyType"], @"New car type not found");
	STAssertEquals([[stockCars allKeys] count] + 1, [carTypes count], @"Car type count not correct");
}

// TODO(bowdidge): Special case ANY?
- (void) testCarTypeAny {
	FreightCar *fc1 = [self makeFreightCarWithReportingMarks: @"AAAA 1111"];
	[fc1 setCarTypeRel: nil];
	
	NSDictionary *stockCars = [CarTypes stockCarTypes];
	NSDictionary *carTypes = [CarTypes populateCarTypesFromLayout: entireLayout_];
	NSArray *allCars = [entireLayout_ allFreightCars];

	STAssertTrue([CarTypes isValidCarType: @"Any"], @"MyType not considered valid ");
	STAssertNil([carTypes objectForKey: @"Any"], @"New car type not found");
	STAssertEquals([[stockCars allKeys] count], [carTypes count], @"Car type count not correct");
}

- (void) testCarType_DoNotAddExistingType {
	FreightCar *fc1 = [self makeFreightCarWithReportingMarks: @"AAAA 1111"];
	[fc1 setCarTypeRel: [entireLayout_ carTypeForName: @"XM"]];
	
	NSDictionary *stockCars = [CarTypes stockCarTypes];
	NSDictionary *carTypes = [CarTypes populateCarTypesFromLayout: entireLayout_];
	NSArray *allCars = [entireLayout_ allFreightCars];
	
	STAssertTrue([CarTypes isValidCarType: @"XM"], @"XM not considered valid type");
	STAssertNotNil([carTypes objectForKey: @"XM"], @"New car type not found");
	STAssertEquals([[stockCars allKeys] count], [carTypes count], @"Car type count not correct");
}

- (void) testCarType_TestInvalid {
	NSString *carTypeToTest = @"Bad Spaces";
	FreightCar *fc1 = [self makeFreightCarWithReportingMarks: @"AAAA 1111"];
	[fc1 setCarTypeRel: nil];
	
	NSDictionary *stockCars = [CarTypes stockCarTypes];
	NSDictionary *carTypes = [CarTypes populateCarTypesFromLayout: entireLayout_];
	NSArray *allCars = [entireLayout_ allFreightCars];
	
	STAssertFalse([CarTypes isValidCarType: carTypeToTest], @"Not supposed to be valid");
	STAssertNil([carTypes objectForKey: carTypeToTest], @"New car type not found");
	STAssertEquals([[stockCars allKeys] count], [carTypes count], @"Car type count not correct");
}



- (void) testCargoCarType {
	[self makeThreeStationLayout];
	Cargo *c1 = [self makeCargo: @"b to c"];
	[c1 setSource: [self industryAtStation: @"B"]];
	[c1 setDestination: [self industryAtStation: @"C"]];
	[c1 setPrimitiveValue: @"ACargo" forKey: @"carType"];

	NSDictionary *stockCars = [CarTypes stockCarTypes];
	NSDictionary *carTypes = [CarTypes populateCarTypesFromLayout: entireLayout_];
	NSArray *allCars = [entireLayout_ allFreightCars];

	STAssertTrue([CarTypes isValidCarType: @"ACargo"], @"MyType not considered valid type");
	STAssertNotNil([carTypes objectForKey: @"ACargo"], @"New car type not found");
	STAssertEquals([[stockCars allKeys] count] + 1, [carTypes count], @"Car type count not correct");
}

@end
