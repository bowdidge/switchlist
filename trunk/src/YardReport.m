//
//  YardReport.m
//  SwitchList
//
//  Created by Robert Bowdidge on 12/15/05.
//
// Copyright (c)2005 Robert Bowdidge,
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
//

#import "YardReport.h"

#import "CarType.h"
#import "FreightCar.h"
#import "ScheduledTrain.h"

@implementation YardReport
- (NSString*) contents {
	NSMutableString *reportString = [NSMutableString string];
	NSEnumerator *e = [objectsToDisplay_ objectEnumerator];
	FreightCar *car;
	NSString *lastLocation = nil;
	
	while ((car=[e nextObject]) != nil) {
		// The car list is sorted by yard and then reporting marks.
		// When the car location changes, we're then starting to print the
		// next yard.  Add space and column headers to separate each yard's cars.
		NSString* currentLocation = [[car currentLocation] name];
		if ((lastLocation == nil) || ([lastLocation isEqualToString: currentLocation] == NO)) {
			[reportString appendFormat: @"\n   Yard: %@\n",currentLocation];
			[reportString appendString:@"  Reporting marks  type  train                         destination                  contents\n"];
			lastLocation = currentLocation;
		}
		
		NSString *contents = [car cargoDescription];
		NSString *currentTrain = [[car currentTrain] name];
		
		[reportString appendFormat: @"  %-16s %-4s  %-24s %31s   %s\n",
			[[car reportingMarks] UTF8String],
			[[[car carTypeRel] carTypeName] UTF8String],
			(currentTrain ? [currentTrain UTF8String] : "------------"),
			[[self nextDestinationForFreightCar: car] UTF8String],
			[contents UTF8String]];
	}
	
	return reportString;
}

- (NSString*) typeString {
	return @"Yard report";
}

@end
