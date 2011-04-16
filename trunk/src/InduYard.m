//
//  InduYard.m
//  SwitchList
//
//  Created by bowdidge on 10/29/10.
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

#import "InduYard.h"

#import "EntireLayout.h"
#import "StringHelpers.h"


@implementation InduYard

@dynamic name;
@dynamic division;
@dynamic location;

- (BOOL) isOffline {
	return [[self location] isOffline];
}

- (BOOL) isStaging {
	return [[self location] isStaging];
}

// Returns whether this is a valid industry for receiving cargo.  Yards and Workbench don't count.
- (BOOL) canReceiveCargo {
	if ([self isYard]) {
		return false;
	}
	
	if ([[self name] isEqualToString: @"Workbench"]) {
		return false;
	}
	return true;
}

- (NSSet*) freightCars {
	NSEntityDescription *ent = [NSEntityDescription entityForName: @"FreightCar" inManagedObjectContext: [self managedObjectContext]];
	NSFetchRequest * req2  = [[[NSFetchRequest alloc] init] autorelease];
	[req2 setEntity: ent];
	[req2 setPredicate: [NSPredicate predicateWithFormat:[NSString stringWithFormat: @"currentLocation.name LIKE '%@'",[[self name] sqlSanitizedString]]]];
	NSError *error;
	return [NSSet setWithArray: [[self managedObjectContext] executeFetchRequest: req2 error:&error]];
}

- (BOOL) isYard {
	return false;
}

@end
