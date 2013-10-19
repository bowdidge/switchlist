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
	self = [super init];
	self.industryToCarMapping = [NSMutableDictionary dictionary];
	self.carToDoorMapping = [NSMutableDictionary dictionary];
	return self;
}

+ (id) doorAssignmentRecorder {
	return [[[self alloc] init] autorelease];
}

- (void) dealloc {
	[super dealloc];
}

- (void) setCar: (FreightCar*) car destinedForIndustry: (Industry*) industry door: (int) doorNumber {
	[car setDoorToSpot: [NSNumber numberWithInt: doorNumber]];
	NSMutableArray *industryMap = [self.industryToCarMapping objectForKey: [industry objectID]];
	if (industryMap == nil) {
		industryMap = [NSMutableArray array];
		[self.industryToCarMapping setObject: industryMap forKey: [industry objectID]];
	}
	[industryMap addObject: car];
	
	[self.carToDoorMapping setObject: [NSNumber numberWithInt: doorNumber] forKey: [car objectID]];
}

- (int) doorForCar: (const FreightCar*) car {
	return [[car doorToSpot] intValue];
}

- (NSArray*) carsAtIndustry: (Industry*) industry {
	return [self.industryToCarMapping objectForKey: [industry objectID]];
}

- (NSString*) description {
	if ([self.carToDoorMapping count] == 0) {
		return @"<DoorAssignmentRecorder: empty>";
	}
	
	NSMutableString *result = [NSMutableString string];
	[result appendString: @"<DoorAssignmentRecorder: \n"];
	for (NSNumber *key in [self.industryToCarMapping keyEnumerator]) {
		[result appendFormat: @"  Industry %@:\n", key];
		for (FreightCar *fc in [self.industryToCarMapping objectForKey: key]) {
			[result appendFormat: @"    %@: door %@\n", fc, [self.carToDoorMapping objectForKey: [fc objectID]]];
		}
	}
	[result appendString: @">\n"];
	return result;
}

@synthesize industryToCarMapping=industryToCarMapping_;
@synthesize carToDoorMapping=carToDoorMapping_;
@end