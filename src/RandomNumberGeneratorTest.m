//
//  RandomNumberGeneratorTest.m
//  SwitchList
//
//  Created by bowdidge on 9/1/12.
//  Copyright 2012 Robert Bowdidge. All rights reserved.
//
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

#import <XCTest/XCTest.h>

#import "RandomNumberGenerator.h"

@interface RandomNumberGeneratorTest : XCTestCase {
};
@end

@implementation RandomNumberGeneratorTest
- (void) testRegularGenerator {
	RandomNumberGenerator *generator = [[[RandomNumberGenerator alloc] init] autorelease];
	int n1 = [generator generateRandomNumber: 100];
	int n2 = [generator generateRandomNumber: 100];
	int n3 = [generator generateRandomNumber: 100];
	
	XCTAssertFalse(n1 == n2 == n3, @"Three numbers should not have been equal.");
	XCTAssertTrue(n1 >= 0 && n1 < 100, @"");
	XCTAssertTrue(n2 >= 0 && n2 < 100, @"");
	XCTAssertTrue(n3 >= 0 && n3 < 100, @"");
}

- (void) testOddValues {
	RandomNumberGenerator *generator = [[[RandomNumberGenerator alloc] init] autorelease];
	XCTAssertEqual(0, [generator generateRandomNumber: 0], @"");
	XCTAssertEqual(0, [generator generateRandomNumber: 1], @"");
}
@end

@interface MockRandomNumberGeneratorTest : XCTestCase {
};
@end

@implementation MockRandomNumberGeneratorTest
- (void) testRegularGenerator {
	MockRandomNumberGenerator *generator = [[[MockRandomNumberGenerator alloc] init] autorelease];
	
	// Returns 0 before setNumbers:
	XCTAssertEqual(-1, [generator generateRandomNumber: 100], @"");
	XCTAssertEqual(-1, [generator generateRandomNumber: 100], @"");

	[generator setNumbers: [NSArray arrayWithObjects: [NSNumber numberWithInt: 1], [NSNumber numberWithInt: 2], [NSNumber numberWithInt: 3], nil]];
	
	XCTAssertEqual(1, [generator generateRandomNumber: 100], @"");
	XCTAssertEqual(2, [generator generateRandomNumber: 100], @"");
	XCTAssertEqual(3, [generator generateRandomNumber: 100], @"");
	XCTAssertEqual(-1, [generator generateRandomNumber: 100], @"");

	[generator setNumbers: [NSArray arrayWithObjects: [NSNumber numberWithInt: 1], [NSNumber numberWithInt: 2], [NSNumber numberWithInt: 3], nil]];
	XCTAssertEqual(1, [generator generateRandomNumber: 100], @"");
	XCTAssertEqual(2, [generator generateRandomNumber: 100], @"");
	XCTAssertEqual(3, [generator generateRandomNumber: 100], @"");
	XCTAssertEqual(-1, [generator generateRandomNumber: 100], @"");
	
}

- (void) testExceedsMax {
	MockRandomNumberGenerator *generator = [[[MockRandomNumberGenerator alloc] init] autorelease];
	[generator setNumbers: [NSArray arrayWithObjects: [NSNumber numberWithInt: 5], [NSNumber numberWithInt: 3], nil]];
	
	XCTAssertEqual(-1, [generator generateRandomNumber: 5], @"Expected error when next number == max");
	XCTAssertEqual(-1, [generator generateRandomNumber: 2], @"Expected error when next number > max");
}
@end