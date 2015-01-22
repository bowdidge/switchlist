//  SwitchList_OCUnit.h
//  SwitchList
//
//  Created by bowdidge on 11/5/11.
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

// New macros for OCUnit that cover helpful cases in SwitchList.

/*" Generates a failure when contains does not appear in container. This test is for
 Objective C strings.
 _{contains    The string to find.}
 _{container    The string to search.}
 _{description A format string as in the printf() function. Can be nil or
 an empty string but must be present.}
 _{... A variable number of arguments to the format string. Can be absent.}
 "*/

#import <XCTest/XCTest.h>

/*" Generates a failure when contains does not appear in container. This test is for
 Objective C strings.
 _{contains    The string to find.}
 _{container    The string to search.}
 _{description A format string as in the printf() function. Can be nil or
 an empty string but must be present.}
 _{... A variable number of arguments to the format string. Can be absent.}
 "*/
#define XCTAssertContains(contains, container, format...) \
do { \
@try {\
NSString *containsvalue = (contains); \
NSString *containervalue = (container); \
if ([containervalue rangeOfString: containsvalue].location == NSNotFound ) { \
/* TODO(bowdidge): What symbol here? */ \
_XCTRegisterFailure(self, _XCTFailureDescription(_XCTAssertion_EqualObjects, 0, @#contains, @#container, containsvalue, containervalue), format); \
} \
} \
@catch (id anException) {\
_XCTRegisterFailure(self, _XCTFailureDescription(_XCTAssertion_EqualObjects, 1, @#contains, @#container, [anException reason]), format); \
}\
} while(0)

#define XCTAssertNotContains(contains, container, format...) \
do { \
@try {\
NSString *containsvalue = (contains); \
NSString *containervalue = (container); \
if ([containervalue rangeOfString: containsvalue].location != NSNotFound ) { \
_XCTRegisterFailure(self, _XCTFailureDescription(_XCTAssertion_NotEqualObjects, 0, @#contains, @#container, containsvalue, containervalue), format); \
} \
} \
@catch (id anException) {\
_XCTRegisterFailure(self, _XCTFailureDescription(_XCTAssertion_NotEqualObjects, 1, @#contains, @#container, [anException reason]), format); \
}\
} while(0)

// Wrapper to avoid type mismatches.
#define XCTAssertEqualInt(val, expr, ...) XCTAssertEqual(((NSInteger)val), ((NSInteger)expr), ##__VA_ARGS__)


