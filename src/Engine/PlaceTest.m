//
//  PlaceTest.m
//  SwitchList
//
//  Created by Robert Bowdidge on 4/14/12
//
// Copyright (c)2012 Robert Bowdidge,
// All rights reserved.
// 

#import "PlaceTest.h"

#import "Place.h"

@implementation PlaceTest
- (void) testIsStaging {
	Place *stationA = [self makePlaceWithName: @"A"];
	XCTAssertEqualObjects(@"On Layout", [stationA kind], @"");
	XCTAssertFalse([stationA isStaging], @"");
	XCTAssertFalse([stationA isOffline], @"");
    XCTAssertTrue([stationA isOnLayout], @"");
	
	[stationA setIsStaging: YES];
	XCTAssertEqualObjects(@"Staging", [stationA kind], @"");
	XCTAssertTrue([stationA isStaging], @"");
	XCTAssertFalse([stationA isOffline], @"");
	XCTAssertFalse([stationA isOnLayout], @"");
    
	[stationA setIsOnLayout];
	XCTAssertEqualObjects(@"On Layout", [stationA kind], @"");
	XCTAssertFalse([stationA isStaging], @"");
	XCTAssertFalse([stationA isOffline], @"");
    XCTAssertTrue([stationA isOnLayout], @"");

    [stationA setIsStaging: NO];
	[stationA setIsOffline: YES];
	XCTAssertEqualObjects(@"Offline", [stationA kind], @"");
	XCTAssertFalse([stationA isStaging], @"");
	XCTAssertTrue([stationA isOffline], @"");
    XCTAssertFalse([stationA isOnLayout], @"");
	
	[stationA setIsStaging: NO];
	[stationA setIsOffline: NO];
	XCTAssertEqualObjects(@"On Layout", [stationA kind], @"");
	XCTAssertFalse([stationA isStaging], @"");
	XCTAssertFalse([stationA isOffline], @"");
    XCTAssertTrue([stationA isOnLayout], @"");
}

- (void) testTemplateDirectory {
	Place *stationA = [self makePlaceWithName: @"A"];
	
	NSDictionary *templateDictionary = [stationA templateDictionary];
	XCTAssertEqualObjects(@"A", [templateDictionary objectForKey: @"name"], @"");
	XCTAssertEqualInt(1, [[templateDictionary objectForKey: @"allIndustriesSortedOrder"] count], @"");
}
@end
