//
//  RandomNumberGeneratorTest.m
//  SwitchList
//
//  Created by bowdidge on 9/1/12.
//  Copyright 2012 Robert Bowdidge. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "RandomNumberGenerator.h"

@interface RandomNumberGeneratorTest : SenTestCase {
};
@end

@implementation RandomNumberGeneratorTest
- (void) testRegularGenerator {
	RandomNumberGenerator *generator = [[[RandomNumberGenerator alloc] init] autorelease];
	int n1 = [generator generateRandomNumber: 100];
	int n2 = [generator generateRandomNumber: 100];
	int n3 = [generator generateRandomNumber: 100];
	
	STAssertFalse(n1 == n2 == n3, @"Three numbers should not have been equal.");
	STAssertTrue(n1 >= 0 && n1 < 100, @"");
	STAssertTrue(n2 >= 0 && n2 < 100, @"");
	STAssertTrue(n3 >= 0 && n3 < 100, @"");
}

- (void) testOddValues {
	RandomNumberGenerator *generator = [[[RandomNumberGenerator alloc] init] autorelease];
	STAssertEquals(0, [generator generateRandomNumber: 0], @"");
	STAssertEquals(0, [generator generateRandomNumber: 1], @"");
}
@end

@interface MockRandomNumberGeneratorTest : SenTestCase {
};
@end

@implementation MockRandomNumberGeneratorTest
- (void) testRegularGenerator {
	MockRandomNumberGenerator *generator = [[[MockRandomNumberGenerator alloc] init] autorelease];
	
	// Returns 0 before setNumbers:
	STAssertEquals(0, [generator generateRandomNumber: 100], @"");
	STAssertEquals(0, [generator generateRandomNumber: 100], @"");

	[generator setNumbers: [NSArray arrayWithObjects: [NSNumber numberWithInt: 1], [NSNumber numberWithInt: 2], [NSNumber numberWithInt: 3], nil]];
	
	STAssertEquals(1, [generator generateRandomNumber: 100], @"");
	STAssertEquals(2, [generator generateRandomNumber: 100], @"");
	STAssertEquals(3, [generator generateRandomNumber: 100], @"");
	STAssertEquals(0, [generator generateRandomNumber: 100], @"");

	[generator setNumbers: [NSArray arrayWithObjects: [NSNumber numberWithInt: 1], [NSNumber numberWithInt: 2], [NSNumber numberWithInt: 3], nil]];
	STAssertEquals(1, [generator generateRandomNumber: 100], @"");
	STAssertEquals(2, [generator generateRandomNumber: 100], @"");
	STAssertEquals(3, [generator generateRandomNumber: 100], @"");
	STAssertEquals(0, [generator generateRandomNumber: 100], @"");
	
}
@end