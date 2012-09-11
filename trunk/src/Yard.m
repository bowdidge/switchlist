// 
//  Yard.m
//  SwitchList
//
//  Created by Robert Bowdidge on 6/9/06.
//
// Copyright (c)2006 Robert Bowdidge,
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

#import "Yard.h"

#import "EntireLayout.h"
#import "FreightCar.h"

@implementation Yard 

- (void)awakeFromInsert {
	[super awakeFromInsert];
	[self setName: @"New yard"];
}

- (BOOL)isYard 
{
	return true;
}

- (NSString *)acceptsDivisions 
{
    NSString * tmpValue;
    
    [self willAccessValueForKey: @"acceptsDivisions"];
    tmpValue = [self primitiveValueForKey: @"acceptsDivisions"];
    [self didAccessValueForKey: @"acceptsDivisions"];
    
    return tmpValue;
}

// Returns true if the freight car named would be accepted by this yard.
- (BOOL) acceptsCar: (FreightCar*) fc {
	return [self acceptsDivision: [fc nextDivision]];
}

// Which divisions are accepted?  No divisions implies all are accepted.
- (BOOL) acceptsDivision: (NSString*) requestedDivisionName {
	NSString *cleanedRequestedDivisionName = NormalizeDivisionString(requestedDivisionName);
	
	if (cleanedRequestedDivisionName == nil) {
		// Car from unknown division should be accepted anywhere.
		return YES;
	}
	
	NSArray *thisYardDivisions = [[self acceptsDivisions] componentsSeparatedByString: @","];
	if ([thisYardDivisions count] == 0) {
		// No divisions.
		return YES;
	}
	
	for (NSString *div in thisYardDivisions) {
		NSString *cleanedDivisionName = NormalizeDivisionString(div);
		if ([cleanedRequestedDivisionName isEqualToString: cleanedDivisionName]) {
			return YES;
		}
	}
	return NO;
}
	

- (void)setAcceptsDivisions:(NSString *)value 
{
    [self willChangeValueForKey: @"acceptsDivisions"];
    [self setPrimitiveValue: value forKey: @"acceptsDivisions"];
    [self didChangeValueForKey: @"acceptsDivisions"];
}

- (NSString*) description {
	return [NSString stringWithFormat: @"%@ at %@", [self name], [[self location] name]];
}


@end
