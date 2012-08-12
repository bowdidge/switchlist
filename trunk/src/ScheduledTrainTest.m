//
//  ScheduledTrainTest.h
//  SwitchList
//
//  Created by Robert Bowdidge on 2/23/12.
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


#import "EntireLayout.h"
#import "FreightCar.h"
#import "ICUTemplateMatcher.h"
#import "MGTemplateEngine.h"
#import "ScheduledTrain.h"
#import "ScheduledTrainTest.h"
#import "SwitchListFilters.h"
#import "TrainSizeVector.h"


@implementation ScheduledTrainTest
- (void) setUp {
	[super setUp];
	[self makeThreeStationLayout];
}

- (void) testStationStrings {
	[self makeThreeStationTrain];
	
	ScheduledTrain *train = [entireLayout_ trainWithName: @"MyTrain"];
	// Test raw string is the old form with commas.
	STAssertEqualObjects(@"A,B,C", [train stops], @"Station stops not as expected.");
	
	// Test that the parsing code correctly handles the old-style separator.
	NSArray *stationStops = [train stationsInOrder];

	STAssertEqualsInt(3, [stationStops count], @"Wrong number of items in station stop array");
	STAssertEqualObjects(@"A", [[stationStops objectAtIndex: 0] name], @"station stops array wrong");
	STAssertEqualObjects(@"B", [[stationStops objectAtIndex: 1] name], @"station stops array wrong");
	STAssertEqualObjects(@"C", [[stationStops objectAtIndex: 2] name], @"station stops array wrong");
}

- (void) testNoStationStrings {
	[self makeThreeStationTrain];
	
	ScheduledTrain *train = [entireLayout_ trainWithName: @"MyTrain"];
	// Test raw string is the old form with commas.
    [train setStops: @""];
	NSArray *stationStops = [train stationsInOrder];
    
	STAssertEqualsInt(0, [stationStops count], @"Wrong number of items in station stop array");
}	

- (void) testStationStringsWithComma {
	[self makeThreeStationTrain];
	Place *p1 = [self makePlaceWithName: @"Erie, Pennsylvania"];
	Place *p2 = [self makePlaceWithName: @"Pasco, WA"];
	Place *p3 = [self makePlaceWithName: @"College Park Yard, San Jose"];
	ScheduledTrain *train = [entireLayout_ trainWithName: @"MyTrain"];
	[train setStationsInOrder: [NSArray arrayWithObjects: p1, p2, p3, nil]];

	NSArray *stationStops = [train stationsInOrder];
	STAssertEqualsInt(3, [stationStops count], @"Wrong number of items in station stop array");
	STAssertEqualObjects(p1, [stationStops objectAtIndex: 0], @"station stops array wrong");
	STAssertEqualObjects(p2, [stationStops objectAtIndex: 1], @"station stops array wrong");
	STAssertEqualObjects(p3, [stationStops objectAtIndex: 2], @"station stops array wrong");
}	

// Tests object used for rendering some HTML switchlists.
// trainWorkByStation provides a station-by-station view of what should be picked up and dropped off.
- (void) testTrainWorkByStation {
	ScheduledTrain *train = [self makeThreeStationTrain];
	[train setStops: @"A,B,C,B,A"];
	NSArray *result = [train trainWorkByStation];
	STAssertEqualsInt(5, [result count], @"");
	// TODO(bowdidge): Wrong.
	NSDictionary *stationA =  [result objectAtIndex: 0];

	STAssertEqualObjects(@"A", [[stationA objectForKey: @"station"] name], @"");
	STAssertEqualsInt(0, [[stationA objectForKey: @"emptyCount"] intValue], @"");
	STAssertEqualsInt(1, [[stationA objectForKey: @"loadedCount"] intValue], @"");
	STAssertEqualsInt(1, [[stationA objectForKey: @"carsToPickUp"] count], @"");
	STAssertEqualsInt(0, [[stationA objectForKey: @"carsToDropOff"] count], @"");

	STAssertEqualsInt(1, [[stationA objectForKey: @"industries"] count], @"");
	NSDictionary *industryA =  [[stationA objectForKey: @"industries"] objectAtIndex: 0];
	STAssertEqualObjects(@"A-industry", [[industryA objectForKey: @"industry"] name], @"");
	STAssertEqualsInt(1, [[industryA objectForKey: @"carsToPickUp"] count], @"");
	STAssertEqualsInt(0, [[industryA objectForKey: @"carsToDropOff"] count], @"");\
	
	NSDictionary *stationB =  [result objectAtIndex: 1];
	STAssertEqualObjects(@"B", [[stationB objectForKey: @"station"] name], @"");
	STAssertEqualsInt(0, [[stationB objectForKey: @"emptyCount"] intValue], @"");
	STAssertEqualsInt(1, [[stationB objectForKey: @"loadedCount"] intValue], @"");
	STAssertEqualsInt(1, [[stationB objectForKey: @"carsToPickUp"] count], @"");
	STAssertEqualsInt(1, [[stationB objectForKey: @"carsToDropOff"] count], @"");

	STAssertEqualsInt(1, [[stationB objectForKey: @"industries"] count], @"");
	NSDictionary *industryB =  [[stationB objectForKey: @"industries"] objectAtIndex: 0];
	STAssertEqualObjects(@"B-industry", [[industryB objectForKey: @"industry"] name], @"");
	STAssertEqualsInt(1, [[industryB objectForKey: @"carsToPickUp"] count], @"");
	STAssertEqualsInt(1, [[industryB objectForKey: @"carsToDropOff"] count], @"");\
	
	NSDictionary *stationC = [result objectAtIndex: 2];
	STAssertEqualObjects(@"C", [[stationC objectForKey: @"station"] name], @"");
	STAssertEqualsInt(0, [[stationC objectForKey: @"emptyCount"] intValue], @"");
	STAssertEqualsInt(0, [[stationC objectForKey: @"loadedCount"] intValue], @"");
	STAssertEqualsInt(0, [[stationC objectForKey: @"carsToPickUp"] count], @"");
	STAssertEqualsInt(1, [[stationC objectForKey: @"carsToDropOff"] count], @"");

	STAssertEqualObjects(@"B", [[[result objectAtIndex: 3] objectForKey: @"station"] name], @"");
	STAssertEqualsInt(0, [[[result objectAtIndex: 3] objectForKey: @"emptyCount"] intValue], @"");
	STAssertEqualsInt(0, [[[result objectAtIndex: 3] objectForKey: @"loadedCount"] intValue], @"");
	STAssertEqualsInt(0, [[[result objectAtIndex: 3] objectForKey: @"carsToPickUp"] count], @"");
	STAssertEqualsInt(0, [[[result objectAtIndex: 3] objectForKey: @"carsToDropOff"] count], @"");

	STAssertEqualObjects(@"A", [[[result objectAtIndex: 4] objectForKey: @"station"] name], @"");
	STAssertEqualsInt(0, [[[result objectAtIndex: 4] objectForKey: @"emptyCount"] intValue], @"");
	STAssertEqualsInt(0, [[[result objectAtIndex: 4] objectForKey: @"loadedCount"] intValue], @"");
	STAssertEqualsInt(0, [[[result objectAtIndex: 4] objectForKey: @"carsToPickUp"] count], @"");
	STAssertEqualsInt(0, [[[result objectAtIndex: 4] objectForKey: @"carsToDropOff"] count], @"");
}
@end

@implementation ScheduledTrainTemplateTest
- (void)setUp {
	[super setUp];
	engine_ = [[MGTemplateEngine alloc] init];
	// Why is this required?
	[engine_ setMatcher: [ICUTemplateMatcher matcherWithTemplateEngine: engine_]];
	[engine_ loadFilter: [[[SwitchListFilters alloc] init] autorelease]];
}

- (void) tearDown {
	[engine_ release];
	[super tearDown];
}

// Make sure a simple template gets expanded correctly.
- (void) testSampleTemplate {
	// Stations always print, industries only printed if there's something there.
	NSString *switchlistTemplate = [NSString stringWithFormat: @"%@ %@ %@ %@ %@ %@ %@ %@ %@ %@\n",
										@"{%for station in work%}station {{station.name}}:<br>",
										@"  {%for industry in station.industries%}",
										@"    {% if industry.carsToPickUp.@count %}",
									    @"      {{station.name}}: industry {{industry.name}}<br>",
										@"      {% for car in industry.carsToPickUp %}",
									    @"        {{car.reportingMarks}} going to {{car.nextStop}}",
									    @"      {%/for%}",
										@"     {%/if%}",
										@"  {%/for%}<p>",
									    @"{%/for%}"];
	ScheduledTrain *train = [self makeThreeStationTrain];
	[train setStops: @"A,B,C,B,A"];
	NSArray *work = [train trainWorkByStation];
	NSDictionary *params = [NSDictionary dictionaryWithObject: work forKey: @"work"];
	NSString *result = [engine_ processTemplate: switchlistTemplate withVariables:params];
	STAssertContains(@"station A:", result, @"Missing station name");
	STAssertContains(@"B: industry B-industry", result, @"Missing industry name");
}

// Make sure the stationsInOrder method correctly uses the cache.
- (void) testCacheInvalidation {
	ScheduledTrain *train = [self makeThreeStationTrain];
	[train setStops: @"A,B,C,B,A"];
	STAssertEqualsInt(5, [[train stationsInOrder] count], @"");
	STAssertEqualsInt(5, [[train stationsInOrder] count], @"");

	[train setStops: @"A,B,C"];
	STAssertEqualsInt(3, [[train stationsInOrder] count], @"");
	
	// TODO(bowdidge): Should use mock to prove we're actually retrieving the cached value.
}
	
@end
