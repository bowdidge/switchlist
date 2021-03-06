//
//  IndustryReport.m
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

#import "IndustryReport.h"

#import "CarType.h"
#import "FreightCar.h"
#import "Industry.h"
#import "Place.h"

@implementation IndustryReport

- (NSString *) typeString {
	return @"Industry report";
}


- (NSString*) contents {
	FreightCar *car;
	NSMutableString *reportString = [NSMutableString string];
	[reportString appendString:@"  Reporting marks  type   contents\n"];
	NSString *currentIndustry=nil;
	BOOL firstLine = YES;
	for (car in objectsToDisplay_) {
		NSString* currentLocation = [[car currentLocation] name];
		NSString* currentTown = [[car currentTown] name];

		// print section header.
		if (((currentIndustry == nil) && (firstLine == YES)) || 
			((currentLocation != nil) && (currentIndustry == nil)) ||
			(currentIndustry != nil && [currentLocation compare: currentIndustry] != NSOrderedSame)) {
			firstLine = NO;
			currentIndustry = currentLocation;
			[reportString appendFormat: @"\n %s: %s\n",(currentTown ? [currentTown UTF8String] : "unknown"), (currentLocation ? [currentLocation UTF8String] : "unknown")];
		}
		
		NSString* contents = [car cargoDescription];
		
		[reportString appendFormat: @"  %-16s %-4s %s\n",
			[[car reportingMarks]  UTF8String],
			[[car carType] UTF8String],
			[contents UTF8String]];
	}
	return reportString;
}

@end
