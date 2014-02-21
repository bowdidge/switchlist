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

#import "CarType.h"
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
	XCTAssertTrue([CarTypes isValidCarType: @"MyType"], @"MyType not considered valid type");
	XCTAssertNotNil([carTypes objectForKey: @"MyType"], @"New car type not found");
	XCTAssertEqual([[stockCars allKeys] count] + 1, [carTypes count], @"Car type count not correct");
}

// TODO(bowdidge): Special case ANY?
- (void) testCarTypeAny {
	FreightCar *fc1 = [self makeFreightCarWithReportingMarks: @"AAAA 1111"];
	[fc1 setCarTypeRel: nil];
	
	NSDictionary *stockCars = [CarTypes stockCarTypes];
	NSDictionary *carTypes = [CarTypes populateCarTypesFromLayout: entireLayout_];
	NSArray *allCars = [entireLayout_ allFreightCars];

	XCTAssertTrue([CarTypes isValidCarType: @"Any"], @"MyType not considered valid ");
	XCTAssertNil([carTypes objectForKey: @"Any"], @"New car type not found");
	XCTAssertEqual([[stockCars allKeys] count], [carTypes count], @"Car type count not correct");
}

- (void) testCarType_DoNotAddExistingType {
	FreightCar *fc1 = [self makeFreightCarWithReportingMarks: @"AAAA 1111"];
	[fc1 setCarTypeRel: [entireLayout_ carTypeForName: @"XM"]];
	
	NSDictionary *stockCars = [CarTypes stockCarTypes];
	NSDictionary *carTypes = [CarTypes populateCarTypesFromLayout: entireLayout_];
	NSArray *allCars = [entireLayout_ allFreightCars];
	
	XCTAssertTrue([CarTypes isValidCarType: @"XM"], @"XM not considered valid type");
	XCTAssertNotNil([carTypes objectForKey: @"XM"], @"New car type not found");
	XCTAssertEqual([[stockCars allKeys] count], [carTypes count], @"Car type count not correct");
}

- (void) testCarType_TestInvalid {
	NSString *carTypeToTest = @"Bad Spaces";
	FreightCar *fc1 = [self makeFreightCarWithReportingMarks: @"AAAA 1111"];
	[fc1 setCarTypeRel: nil];
	
	NSDictionary *stockCars = [CarTypes stockCarTypes];
	NSDictionary *carTypes = [CarTypes populateCarTypesFromLayout: entireLayout_];
	NSArray *allCars = [entireLayout_ allFreightCars];
	
	XCTAssertFalse([CarTypes isValidCarType: carTypeToTest], @"Not supposed to be valid");
	XCTAssertNil([carTypes objectForKey: carTypeToTest], @"New car type not found");
	XCTAssertEqual([[stockCars allKeys] count], [carTypes count], @"Car type count not correct");
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

	XCTAssertTrue([CarTypes isValidCarType: @"ACargo"], @"MyType not considered valid type");
	XCTAssertNotNil([carTypes objectForKey: @"ACargo"], @"New car type not found");
	XCTAssertEqual([[stockCars allKeys] count] + 1, [carTypes count], @"Car type count not correct");
}

- (void) testCargoTextNoCarType {
	[self makeThreeStationLayout];
	Cargo *c1 = [self makeCargo: @"cans"];
	[c1 setSource: [self industryAtStation: @"B"]];
	[c1 setDestination: [self industryAtStation: @"C"]];
//	[c1 setPrimitiveValue: @"ACargo" forKey: @"carType"];
	
	XCTAssertEqualObjects(@"cans, sent from B-industry to C-industry, 7 cars per week", [c1 tooltip], @"");
}

- (void) testCargoTextNoCarLabelType {
	CarType *ct = [self makeCarType: @"X"];
	// No value.
	[ct setCarTypeDescription: nil];
	
	[self makeThreeStationLayout];
	Cargo *c1 = [self makeCargo: @"cans"];
	[c1 setSource: [self industryAtStation: @"B"]];
	[c1 setDestination: [self industryAtStation: @"C"]];
	[c1 setCarTypeRel: ct];
	
	XCTAssertEqualObjects(@"cans, sent from B-industry to C-industry, 7 'X' cars per week", [c1 tooltip], @"");
}

- (void) testCargoTextWithCarLabelType {
	CarType *ct = [self makeCarType: @"X"];
	[ct setCarTypeDescription: @"extra-big"];
	
	[self makeThreeStationLayout];
	Cargo *c1 = [self makeCargo: @"cans"];
	[c1 setSource: [self industryAtStation: @"B"]];
	[c1 setDestination: [self industryAtStation: @"C"]];
	[c1 setCarTypeRel: ct];
	
	XCTAssertEqualObjects(@"cans, sent from B-industry to C-industry, 7 'X' (extra-big) cars per week", [c1 tooltip], @"");
}

- (void) testCargoTextWithBlankCarLabelType {
	CarType *ct = [self makeCarType: @"X"];
	[ct setCarTypeDescription: @""];
	
	[self makeThreeStationLayout];
	Cargo *c1 = [self makeCargo: @"cans"];
	[c1 setSource: [self industryAtStation: @"B"]];
	[c1 setDestination: [self industryAtStation: @"C"]];
	[c1 setCarTypeRel: ct];
	
	XCTAssertEqualObjects(@"cans, sent from B-industry to C-industry, 7 'X' cars per week", [c1 tooltip], @"");
}

- (void) testCargoTextWithEmptyDestination {
	CarType *ct = [self makeCarType: @"X"];
	[ct setCarTypeDescription: @""];
	
	[self makeThreeStationLayout];
	Cargo *c1 = [self makeCargo: @"cans"];
	[c1 setSource: [self industryAtStation: @"B"]];
	[c1 setDestination: nil];
	[c1 setCarTypeRel: ct];
	
	XCTAssertEqualObjects(@"cans, sent from B-industry to No Value, 7 'X' cars per week", [c1 tooltip], @"");
}

- (void) testCargoTextWithEmptySource {
	CarType *ct = [self makeCarType: @"X"];
	[ct setCarTypeDescription: @""];
	
	[self makeThreeStationLayout];
	Cargo *c1 = [self makeCargo: @"cans"];
	[c1 setSource: nil];
	[c1 setDestination: [self industryAtStation: @"B"]];
	[c1 setCarTypeRel: ct];
	
	XCTAssertEqualObjects(@"cans, sent from No Value to B-industry, 7 'X' cars per week", [c1 tooltip], @"");
}

@end
