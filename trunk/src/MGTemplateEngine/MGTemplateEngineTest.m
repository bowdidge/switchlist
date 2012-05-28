//
//  MGTemplateEngineTest.m
//  MGTemplateEngine
//
//  Created by Robert Bowdidge on 5/22/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MGTemplateEngineTest.h"

#import "ICUTemplateMatcher.h"
#import "MGTemplateEngine.h"

@implementation TemplateEngineTestDelegate
- (id) init {
	lastError_ = nil;
	return self;
}

- (void) dealloc {
	[lastError_ autorelease];
	[super dealloc];
}

- (void)templateEngine:(MGTemplateEngine *)engine encounteredError:(NSError *)error isContinuing:(BOOL)continuing {
	[lastError_ autorelease];
	lastError_ = [[error localizedDescription] retain];
}
- (void) clearLastError {
	[lastError_ autorelease];
	lastError_ = nil;
}

- (NSString*) lastError {
	return lastError_;
}

@end

@implementation MGTemplateEngineTest
- (void)setUp {
	engine_ = [[MGTemplateEngine alloc] init];
	// Why is this required?
	[engine_ setMatcher: [ICUTemplateMatcher matcherWithTemplateEngine: engine_]];
	delegate_ = [[TemplateEngineTestDelegate alloc] init];
	[engine_ setDelegate: delegate_];
}

- (void) tearDown {
	[delegate_ release];
	[engine_ release];
}

- (void) testSimpleTemplate {
	NSString *result = [engine_ processTemplate: @"foo" withVariables: [NSDictionary dictionaryWithObject: @"1" forKey: @"foo"]];
	STAssertEqualObjects(@"foo", result, @"");
	STAssertNil([delegate_ lastError], @"");
}

- (void) testSimpleIfTemplate {
	NSString *result = [engine_ processTemplate: @"{% if foo == 1 %}bah{%/if%}" withVariables: [NSDictionary dictionaryWithObject: @"1" forKey: @"foo"]];
	STAssertEqualObjects(@"bah", result, @"");
	STAssertNil([delegate_ lastError], @"");
}

- (void) testErrorIfTemlate {
	NSString *result = [engine_ processTemplate: @"{% if foo == 1 %}bah" withVariables: [NSDictionary dictionaryWithObject: @"1" forKey: @"foo"]];
	STAssertEqualObjects(@"Finished processing template, but 1 block was left open (if).", [delegate_ lastError], @"");
	STAssertEqualObjects(@"bah", result, @"");
}

- (void) testInvalidVariable {
	NSString *result = [engine_ processTemplate: @"{{ hello }}" withVariables: [NSDictionary dictionary]];
	STAssertEqualObjects(@"", result, @"");
	STAssertEqualObjects(@"\"hello\" is not a valid variable", [delegate_ lastError], @"");
}

- (void) testInvalidMarker {
	NSString *result = [engine_ processTemplate: @"{%hello%}" withVariables: [NSDictionary dictionary]];
	STAssertEqualObjects(@"", result, @"");
	STAssertEqualObjects(@"\"hello\" is not a valid marker", [delegate_ lastError], @"");
}

- (void) testSimpleVariable {
	NSString *result = [engine_ processTemplate: @"{{ var }}" withVariables: [NSDictionary dictionaryWithObject: @"hello" forKey: @"var"]];
	STAssertEqualObjects(@"hello", result, @"");
	STAssertNil([delegate_ lastError], @"");
}

- (void) testSimpleVariableNoSpaces {
	NSString *result = [engine_ processTemplate: @"{{var}}" withVariables: [NSDictionary dictionaryWithObject: @"hello" forKey: @"var"]];
	STAssertEqualObjects(@"hello", result, @"");
	STAssertNil([delegate_ lastError], @"");
}

- (void) testUppercaseFilter {
	NSString *result = [engine_ processTemplate: @"{{var|uppercase}}" withVariables: [NSDictionary dictionaryWithObject: @"hello" forKey: @"var"]];
	STAssertEqualObjects(@"HELLO", result, @"");
	STAssertNil([delegate_ lastError], @"");
}

- (void) testConstants {
	NSString *result = [engine_ processTemplate: @"We also know about {{ YES }} and {{ NO }} or {{ true }} and {{ false }}"
								   withVariables: [NSDictionary dictionary]];
	STAssertEqualObjects(@"We also know about 1 and 0 or 1 and 0", result, @"");
	STAssertNil([delegate_ lastError], @"");
}

- (void) testMath {
	NSString *result = [engine_ processTemplate: @"Is 1 less than 2? {% if 1 < 2 %} Yes! {% else %} No? {% /if %}"
								  withVariables: [NSDictionary dictionary]];
	STAssertEqualObjects(@"Is 1 less than 2?  Yes! ", result, @"");
	STAssertNil([delegate_ lastError], @"");
}

- (void) testLiteral {
	NSString *result = [engine_ processTemplate: @"{% literal %}This text won't be {% now %} interpreted.{% /literal %}"
								  withVariables: [NSDictionary dictionary]];
	STAssertEqualObjects(@"This text won't be {% now %} interpreted.", result, @"");
	STAssertNil([delegate_ lastError], @"");
}

- (void) testSimpleCountTemplate {
	NSString *result = [engine_ processTemplate: @"{{foo.@count}}" withVariables: [NSDictionary dictionaryWithObject: [NSArray arrayWithObject: @"1"] forKey: @"foo"]];
	STAssertEqualObjects(@"1", result, @"");
	STAssertNil([delegate_ lastError], @"");
}

- (void) FailingTestSimpleCountZeroTemplate {
	NSString *result = [engine_ processTemplate: @"{{foo.@count}}" withVariables: [NSDictionary dictionaryWithObject: [NSArray array] forKey: @"foo"]];
	STAssertEqualObjects(@"0", result, @"");
	STAssertNil([delegate_ lastError], @"");
}

- (void) testArrayCount {
	NSNumber *count = [[NSArray array] valueForKeyPath: @"@count"];
	STAssertEquals(0, [count intValue], @"");
	STAssertNil([delegate_ lastError], @"");
}

- (void) testSimpleIfCountZeroTemplate {
	NSString *result = [engine_ processTemplate: @"{% if foo.@count != 0 %}not-zero{% else %}zero{%/if%}" withVariables: [NSDictionary dictionaryWithObject: [NSArray array] forKey: @"foo"]];
	STAssertEqualObjects(@"zero", result, @"");
	STAssertNil([delegate_ lastError], @"");
}

- (void) testSimpleIfCountZeroDictTemplate {
	NSDictionary *dict = [NSDictionary dictionaryWithObject: [NSDictionary dictionaryWithObject: [NSArray array] forKey: @"myArray"] forKey: @"myKey"];
	NSString *result = [engine_ processTemplate: @"{% if myKey.myArray.@count != 0 %}not-zero{% else %}zero{%/if%}" withVariables: dict];
	STAssertEqualObjects(@"zero", result, @"");
	STAssertNil([delegate_ lastError], @"");
}

- (void) testNestedIf {
	NSString *result = [engine_ processTemplate: @"{% if false %}level1{% if false}level2{% /if %}level1{% /if %}level0"
								  withVariables: [NSDictionary dictionaryWithObject: [NSArray array] forKey: @"foo"]];
	STAssertEqualObjects(@"level0", result, @"");
	STAssertNil([delegate_ lastError], @"");
}

- (void) testSimpleIfCountNonZeroDictTemplate {
	NSDictionary *dict = [NSDictionary dictionaryWithObject: [NSDictionary dictionaryWithObject: [NSArray arrayWithObject: @"a"] forKey: @"myArray"] forKey: @"myKey"];
	NSString *result = [engine_ processTemplate: @"{% if myKey.myArray.@count != 0 %}not-zero{% else %}zero{%/if%}" withVariables: dict];
	STAssertEqualObjects(@"not-zero", result, @"");
	STAssertNil([delegate_ lastError], @"");
}

- (void) testNestedForLoop {
	// Two stations: A, B
	// A has two industries, B has none.
	NSArray *industryA1 = [NSDictionary dictionaryWithObject: @"A1" forKey: @"name"];
	NSArray *industryA2 = [NSDictionary dictionaryWithObject: @"A2" forKey: @"name"];
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
	
	STAssertEqualObjects(@"A: ind:A1 EndInd ind:A2 EndInd EndSta B: EndSta ", result, @"");
	STAssertNil([delegate_ lastError], @"");
}

- (void) testNestedTripleForLoop {
	// Two stations: A, B
	// A has two industries, B has none.
	NSArray *industryA1 = [NSDictionary dictionaryWithObjectsAndKeys:
						   @"A1", @"industryName", [NSArray arrayWithObject: @"SP 1"], @"cars", nil];
	
	NSArray *industryA2 = [NSDictionary dictionaryWithObjectsAndKeys:
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
	STAssertEqualObjects(@"StartStation A: StartInd:A1 SP 1EndInd StartInd:A2 EndIndEndStationStartStation B:EndStation", result, @"");
	STAssertNil([delegate_ lastError], @"");
}

// TODO(bowdidge): Requires more elaborate stack frames to remember when to disable output.
- (void) disableTestAlernateForAndIf {
	NSDictionary *vars = [NSDictionary dictionaryWithObjectsAndKeys: [NSArray array], @"emptyArray",
						  [NSArray arrayWithObject: @"asasda"], @"itemArray", nil];
	NSString *result = [engine_ processTemplate: @"{% for i in itemArray %}{% if true %}A{% for j in emptyArray %}{% if false %}B{% /if %}C {% /for %} D {%/if%} E {% /for %}"
								  withVariables: vars];
	STAssertEqualObjects(@"A", result, @"");
	STAssertNil([delegate_ lastError], @"");
}

// TODO: Add support for section.
- (void) testSection {
	// Not documented, but let's add tests anyway.
	NSString *result = [engine_ processTemplate: @"{%section%}Hello, World{%/section%}"
								  withVariables: [NSDictionary dictionary]];
	STAssertEqualObjects(@"Hello, World", result, @"");
	STAssertEqualObjects(@"Marker \"/section\" reported that a non-existent block ended", [delegate_ lastError], @"");
}

// TODO: Add support for section.
- (void) testSectionAndIf {
	// Not documented, but let's add tests anyway.
	NSString *result = [engine_ processTemplate: @"{%if false%}{%section%}Hello, World{%/section%}{%/if%}"
								  withVariables: [NSDictionary dictionary]];
	STAssertEqualObjects(@"", result, @"");
	STAssertEqualObjects(@"Marker \"/section\" reported that a block ended, but current block was started by \"if\" marker", [delegate_ lastError], @"");
}

@end

