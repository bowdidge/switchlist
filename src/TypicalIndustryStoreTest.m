//
//
//  TypicalIndustryStoreTest.m
//  SwitchList
//
//  Created by bowdidge on 8/12/12.
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


#import "TypicalIndustryStoreTest.h"

#import "TypicalIndustryStore.h"

@implementation TypicalIndustryStoreTest
- (void) setUp {
	NSMutableArray *array = [NSMutableArray array];
	NSMutableDictionary *cannery = [NSMutableDictionary dictionary];
	[cannery setObject: @"cannery" forKey: @"IndustryClass"];
	[cannery setObject: [NSArray arrayWithObjects: @"canneries", @"canning", @"packing", nil] forKey: @"Synonyms"];
	[array addObject: cannery];
	NSMutableDictionary *lumber = [NSMutableDictionary dictionary];
	[lumber setObject: @"lumber yard" forKey: @"IndustryClass"];
	[lumber setObject: [NSArray arrayWithObjects: @"lumber", @"building", nil] forKey: @"Synonyms"];
	[array addObject: lumber];
	store_ = [[TypicalIndustryStore alloc] initWithIndustryPlistArray: array];
}

- (void) testSimpleCannery {
	NSArray *categories = [store_ categoriesForIndustryName: @"cannery"];
	XCTAssertTrue([categories count] > 0, @"Expected at least one match.");
	NSNumber *firstCategory = [categories objectAtIndex: 0];
	XCTAssertEqualObjects(@"cannery", [store_ industryNameForCategory: firstCategory], @"%d", [firstCategory intValue]);
}

- (void) testSimpleLumber {
	NSArray *categories = [store_ categoriesForIndustryName: @"lumber yard"];
	XCTAssertTrue([categories count] > 0, @"Expected at least one match.");
	NSNumber *firstCategory = [categories objectAtIndex: 0];
	XCTAssertEqualObjects(@"lumber yard", [store_ industryNameForCategory: firstCategory], @"%d", [firstCategory intValue]);
}

- (void) testInferLumber {
	NSArray *categories = [store_ categoriesForIndustryName: @"San Bruno Lumber"];
	XCTAssertTrue([categories count] > 0, @"Expected at least one match.");
	NSNumber *firstCategory = [categories objectAtIndex: 0];
	XCTAssertEqualObjects(@"lumber yard", [store_ industryNameForCategory: firstCategory], @"%d", [firstCategory intValue]);
}

- (void) testInferMixed {
	NSArray *categories = [store_ categoriesForIndustryName: @"Packing Lumber"];
	XCTAssertTrue([categories count] == 2, @"Expected two matches.");
	NSNumber *firstCategory = [categories objectAtIndex: 0];
	XCTAssertEqualObjects(@"lumber yard", [store_ industryNameForCategory: firstCategory], @"Expected lumber to be first.");
}



@end
