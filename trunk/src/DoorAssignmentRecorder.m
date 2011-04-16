//
//  DoorAssignmentRecorder.m
//  SwitchList
//
//  Created by bowdidge on 12/11/10.
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

#import "DoorAssignmentRecorder.h"

@implementation DoorAssignmentRecorder
- (id) init {
	[super init];
	industryToCarMapping_ = [[NSMutableDictionary alloc] init];
	carToDoorMapping_ = [[NSMutableDictionary alloc] init];
	return self;
}

+ (id) doorAssignmentRecorder {
	return [[[self alloc] init] autorelease];
}

- (void) dealloc {
	[industryToCarMapping_ release];
	[carToDoorMapping_ release];
	[super dealloc];
}

- (void) setCar: (FreightCar*) car destinedForIndustry: (Industry*) industry door: (int) doorNumber {
	NSMutableArray *industryMap = [industryToCarMapping_ objectForKey: [industry objectID]];
	if (industryMap == nil) {
		industryMap = [NSMutableArray array];
		[industryToCarMapping_ setObject: industryMap forKey: [industry objectID]];
	}
	[industryMap addObject: car];
	
	[carToDoorMapping_ setObject: [NSNumber numberWithInt: doorNumber] forKey: [car objectID]];
}

- (int) doorForCar: (const FreightCar*) car {
	return [[carToDoorMapping_ objectForKey: [car objectID]] intValue];
}

- (NSArray*) carsAtIndustry: (Industry*) industry {
	return [industryToCarMapping_ objectForKey: [industry objectID]];
}

- (NSString*) description {
	if ([carToDoorMapping_ count] == 0) {
		return @"<DoorAssignmentRecorder: empty>";
	}
	
	NSMutableString *result = [NSMutableString string];
	[result appendString: @"<DoorAssignmentRecorder: \n"];
	for (NSNumber *key in [industryToCarMapping_ keyEnumerator]) {
		[result appendFormat: @"  Industry %@:\n", key];
		for (FreightCar *fc in [industryToCarMapping_ objectForKey: key]) {
			[result appendFormat: @"%    @: door %@\n", fc, [carToDoorMapping_ objectForKey: [fc objectID]]];
		}
	}
	[result appendString: @">\n"];
	return result;
}


@end