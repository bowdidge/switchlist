//
//  SwitchListBaseViewTest.m
//  SwitchList
//
//  Created by bowdidge on 6/21/11.
//
// Copyright (c)2011 Robert Bowdidge,
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

#import "SwitchListBaseViewTest.h"

#import "SwitchListBaseView.h"
#import "SwitchList_OCUnit.h"

@implementation SwitchListBaseViewTest

- (void) testSplitStringByDashes {
	SwitchListBaseView *view = [[SwitchListBaseView alloc] initWithFrame: NSMakeRect(0,0,400,400) withDocument: nil];
	NSArray *a = [view splitStringByDashes: @"AAA ___ AAA"];
	STAssertEqualsInt(3, [a count], @"Count should have been 3 but was %d", [a count]);
	STAssertEqualObjects(@"AAA ", [a objectAtIndex: 0], @"");
	STAssertEqualObjects(@"___", [a objectAtIndex: 1], @"");
	STAssertEqualObjects(@" AAA", [a objectAtIndex: 2], @"");
}

// TODO(bowdidge): Should be 3, but gets extra space at the end.
- (void) brokenTestAdjoiningDashes {
	SwitchListBaseView *view = [[SwitchListBaseView alloc] initWithFrame: NSMakeRect(0,0,400,400) withDocument: nil];
	NSArray *a = [view splitStringByDashes: @"___ ___ "];
	STAssertEqualsInt(3, [a count], @"Count should have been 3 but was %d for %@", [a count], a);
	STAssertEqualObjects(@"___", [a objectAtIndex: 0], @"");
	STAssertEqualObjects(@" ", [a objectAtIndex: 1], @"");
	STAssertEqualObjects(@"___", [a objectAtIndex: 2], @"");
}

- (void) testNoDashes {
	SwitchListBaseView *view = [[SwitchListBaseView alloc] initWithFrame: NSMakeRect(0,0,400,400) withDocument: nil];
	NSArray *a = [view splitStringByDashes: @"Foo Bar Baz"];
	STAssertEqualsInt(1, [a count], @"Count should have been 1 but was %d for %@", [a count], a);
	STAssertEqualObjects(@"Foo Bar Baz", [a objectAtIndex: 0], @"");
}

- (void) testDashesAtStart {
	SwitchListBaseView *view = [[SwitchListBaseView alloc] initWithFrame: NSMakeRect(0,0,400,400) withDocument: nil];
	NSArray *a = [view splitStringByDashes: @"____Name"];
	STAssertEqualsInt(2, [a count], @"Count should have been 2 but was %d for %@", [a count], a);
	STAssertEqualObjects(@"____", [a objectAtIndex: 0], @"");
	STAssertEqualObjects(@"Name", [a objectAtIndex: 1], @"");
}

- (void) testDashesAtEnd {
	SwitchListBaseView *view = [[SwitchListBaseView alloc] initWithFrame: NSMakeRect(0,0,400,400) withDocument: nil];
	NSArray *a = [view splitStringByDashes: @"Name:_______"];
	STAssertEqualsInt(2, [a count], @"Count should have been 2 but was %d for %@", [a count], a);
	STAssertEqualObjects(@"Name:", [a objectAtIndex: 0], @"");
	STAssertEqualObjects(@"_______", [a objectAtIndex: 1], @"");
}
@end


