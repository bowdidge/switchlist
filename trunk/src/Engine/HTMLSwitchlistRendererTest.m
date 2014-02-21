//
//  HTMLSwitchlistRendererTest.h
//  SwitchList
//
//  Created by bowdidge on 11/5/11.
//  Copyright 2011 Robert Bowdidge. All rights reserved.
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

#import "HTMLSwitchlistRendererTest.h"

#import "EntireLayout.h"
#import "HTMLSwitchlistRenderer.h"
#import "MGTemplateEngine.h"
#import "ICUTemplateMatcher.h"
#import "SwitchListFilters.h"


@implementation HTMLSwitchlistRendererTest
// Test line printer template returns line printer template files.
- (void) testStockTemplateTest {
	[self makeThreeStationLayout];
	[self makeThreeStationTrain];
	
	NSBundle *bundleForUnitTests = [NSBundle bundleForClass: [self class]];
	HTMLSwitchlistRenderer *renderer = [[HTMLSwitchlistRenderer alloc] initWithBundle: bundleForUnitTests];
	NSString *text = [renderer renderSwitchlistForTrain: [[self entireLayout] trainWithName: @"MyTrain"]
												 layout: [self entireLayout]
												 iPhone: NO];
	XCTAssertNotNil(text, @"Expected renderSwitchListForTrain to return something, but returned nil.");
	XCTAssertContains(@"switchlist.css", text, @"%@ does not contain builtin ref", text);
}
@end

// Minimal tests to ensure MGTemplate is working.
@implementation TemplateExampleTest
- (void)setUp {
	engine_ = [[MGTemplateEngine alloc] init];
	// Why is this required?
	[engine_ setMatcher: [ICUTemplateMatcher matcherWithTemplateEngine: engine_]];
	[engine_ loadFilter: [[[SwitchListFilters alloc] init] autorelease]];
}

- (void) tearDown {
	[engine_ release];
}
	
- (void) testSimpleTemplate {
	NSString *result = [engine_ processTemplate: @"foo" withVariables: [NSDictionary dictionaryWithObject: @"1" forKey: @"foo"]];
	XCTAssertEqualObjects(@"foo", result, @"");
}

- (void) testSimpleIfTemplate {
	NSString *result = [engine_ processTemplate: @"{% if foo == 1 %}bah{%/if%}" withVariables: [NSDictionary dictionaryWithObject: @"1" forKey: @"foo"]];
	XCTAssertEqualObjects(@"bah", result, @"If clause not rendered correctly.");
}

- (void) testSimpleCountTemplate {
	NSString *result = [engine_ processTemplate: @"{{foo.@count}}" withVariables: [NSDictionary dictionaryWithObject: [NSArray arrayWithObject: @"1"] forKey: @"foo"]];
	XCTAssertEqualObjects(@"1", result, @"");
}

- (void) failingTestSimpleCountZeroTemplate {
	NSString *result = [engine_ processTemplate: @"{{foo.@count}}" withVariables: [NSDictionary dictionaryWithObject: [NSArray array] forKey: @"foo"]];
	XCTAssertEqualObjects(@"0", result, @"");
}

- (void) testSimpleAssignment {
	NSString *result = [engine_ processTemplate: @"{% set seq 0 %}{{seq}}" withVariables: [NSDictionary dictionaryWithObject: [NSArray array] forKey: @"foo"]];
	XCTAssertEqualObjects(@"0", result, @"");
}

// Tests that the assignment of boo with a mathematical expression
// returns the mathematical expression.
- (void) testComplexAssignment {
	NSString *result = [engine_ processTemplate: @"{% set seq 0 %}{{seq}} {% set boo 1+3 %}{{boo}}"
								  withVariables: [NSDictionary dictionaryWithObject: [NSNumber numberWithInt: 0] forKey: @"seq"]];
	XCTAssertEqualObjects(@"0 4", result, @"");
}

// Tests that references to an invalid variable in an expression is handled without crashing
// or throwing an exception.
- (void) testReferenceToInvalidVariable {
	NSString *result = [engine_ processTemplate: @"{% set seq bar+1 %}{{seq}}"
								  withVariables: [NSDictionary dictionaryWithObject: [NSNumber numberWithInt: 0] forKey: @"seq"]];
	XCTAssertEqualObjects(@"bar+1", result, @"");
}

// Tests that a reassignment of an existing variable works.
- (void) testReassignment {
	NSString *result = [engine_ processTemplate: @"{% set seq 0 %}{{seq}} {% set seq seq+1 %}{{seq}}"
								  withVariables: [NSDictionary dictionaryWithObject: [NSNumber numberWithInt: 0] forKey: @"bar"]];
	XCTAssertEqualObjects(@"0 1", result, @"");
}

- (void) failedTestForTo {
	NSString *result = [engine_ processTemplate: @"{% for 1 to 5 %}1{% for %}"
								  withVariables: [NSDictionary dictionaryWithObject: [NSNumber numberWithInt: 0] forKey: @"loop"]];
	XCTAssertEqualObjects(@"11111", result, @"");
}

- (void) testOverrideGlobal {
	NSString *result = [engine_ processTemplate: @"{% set bar 17 %}{{bar}}"
								  withVariables: [NSDictionary dictionaryWithObject: [NSNumber numberWithInt: 0] forKey: @"bar"]];
	XCTAssertEqualObjects(@"17", result, @"");
}

- (void) testArrayCount {
	NSNumber *count = [[NSArray array] valueForKeyPath: @"@count"];
	XCTAssertEqual(0, [count intValue], @"");
}

- (void) testSimpleIfCountZeroTemplate {
	NSString *result = [engine_ processTemplate: @"{% if foo.@count != 0 %}not-zero{% else %}zero{%/if%}" withVariables: [NSDictionary dictionaryWithObject: [NSArray array] forKey: @"foo"]];
	XCTAssertEqualObjects(@"zero", result, @"");
}

- (void) testSimpleIfCountZeroDictTemplate {
	NSDictionary *dict = [NSDictionary dictionaryWithObject: [NSDictionary dictionaryWithObject: [NSArray array] forKey: @"myArray"] forKey: @"myKey"];
	NSString *result = [engine_ processTemplate: @"{% if myKey.myArray.@count != 0 %}not-zero{% else %}zero{%/if%}" withVariables: dict];
	XCTAssertEqualObjects(@"zero", result, @"");
}
- (void) testSimpleIfCountNonZeroDictTemplate {
	NSDictionary *dict = [NSDictionary dictionaryWithObject: [NSDictionary dictionaryWithObject: [NSArray arrayWithObject: @"a"] forKey: @"myArray"] forKey: @"myKey"];
	NSString *result = [engine_ processTemplate: @"{% if myKey.myArray.@count != 0 %}not-zero{% else %}zero{%/if%}" withVariables: dict];
	XCTAssertEqualObjects(@"not-zero", result, @"");
}

- (void) testNestedForLoop {
	// Two stations: A, B
	// A has two industries, B has none.
	NSDictionary *industryA1 = [NSDictionary dictionaryWithObject: @"A1" forKey: @"name"];
	NSDictionary *industryA2 = [NSDictionary dictionaryWithObject: @"A2" forKey: @"name"];
	NSDictionary *stationA = [NSDictionary dictionaryWithObjectsAndKeys:
							 @"A", @"stationName",
							  [NSArray arrayWithObjects: industryA1, industryA2, nil], @"industries",
							  nil];
	NSDictionary *stationB = [NSDictionary dictionaryWithObjectsAndKeys:
							  @"B", @"stationName",
							  [NSArray array], @"industries",
							  nil];
	NSDictionary *vars = [NSDictionary dictionaryWithObject: [NSArray arrayWithObjects: stationA, stationB, nil] 
													 forKey: @"stations"];
	NSString *result = [engine_ processTemplate: @"{% for station in stations %}{{station.stationName}}:{% for industry in station.industries %} ind:{{industry.name}} EndInd{% /for %} EndSta {% /for %}"
								  withVariables: vars];
					
	XCTAssertEqualObjects(@"A: ind:A1 EndInd ind:A2 EndInd EndSta B: EndSta ", result, @"");
}

- (void) testNestedTripleForLoop {
	// Two stations: A, B
	// A has two industries, B has none.
	NSDictionary *industryA1 = [NSDictionary dictionaryWithObjectsAndKeys:
						   @"A1", @"industryName", [NSArray arrayWithObject: @"SP 1"], @"cars", nil];
						   
	NSDictionary *industryA2 = [NSDictionary dictionaryWithObjectsAndKeys:
							@"A2", @"industryName",
						   [NSArray array], @"cars", nil];
	NSDictionary *stationA = [NSDictionary dictionaryWithObjectsAndKeys:
							  @"A", @"name",
							  [NSArray arrayWithObjects: industryA1, industryA2, nil], @"industries",
							  nil];
	NSDictionary *stationB = [NSDictionary dictionaryWithObjectsAndKeys:
							  @"B", @"name",
							  [NSArray array], @"industries",
							  nil];
	NSDictionary *vars = [NSDictionary dictionaryWithObject: [NSArray arrayWithObjects: stationA, stationB, nil] 
													 forKey: @"stations"];
	NSString *result = [engine_ processTemplate: @"{% for station in stations %}StartStation {{station.name}}:{% for industry in station.industries %} StartInd:{{industry.industryName}} {% for car in industry.cars %}{{car}}{% /for %}EndInd{%/for %}EndStation{% /for %}"
								  withVariables: vars];
	// FIXME - StartStation B: shouldn't be followed by endInd because it shouldn't go through the industry loop.
	XCTAssertEqualObjects(@"StartStation A: StartInd:A1 SP 1EndInd StartInd:A2 EndIndEndStationStartStation B:EndStation", result, @"");
}

- (void) testNestedTripleForLoopWithIf {
	// Two stations: A, B
	// A has two industries, B has none.
	NSDictionary *industryA1 = [NSDictionary dictionaryWithObjectsAndKeys:
						   @"A1", @"name", [NSArray arrayWithObject: @"SP 1"], @"cars", nil];
	
	NSDictionary *industryA2 = [NSDictionary dictionaryWithObjectsAndKeys:
						   @"A2", @"name", [NSArray array], @"cars", nil];
	NSDictionary *stationA = [NSDictionary dictionaryWithObjectsAndKeys:
							  @"A", @"stationName",
							  [NSArray arrayWithObjects: industryA1, industryA2, nil], @"industries",
							  nil];
	NSDictionary *stationB = [NSDictionary dictionaryWithObjectsAndKeys:
							  @"B", @"stationName",
							  [NSArray array], @"industries",
							  nil];
	NSDictionary *vars = [NSDictionary dictionaryWithObject: [NSArray arrayWithObjects: stationA, stationB, nil] 
													 forKey: @"stations"];
	NSString *result = [engine_ processTemplate: @"{% for station in stations %}station:{{station.stationName}}:{% for industry in station.industries %}-ind:{{industry.name}}-{% if industry.cars.@count %}{% for car in industry.cars %}.{{car}}.{% /for %}{%/if%}EndInd{%/for %}EndSta{% /for %}"
								  withVariables: vars];
	
	XCTAssertEqualObjects(@"station:A:-ind:A1-.SP 1.EndInd-ind:A2-EndIndEndStastation:B:EndSta", result, @"");
}

@end
