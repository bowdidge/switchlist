//
//  SwitchListReport.m
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

#import "SwitchListReport.h"

#import "CarType.h"
#import "DoorAssignmentRecorder.h"
#import "EntireLayout.h"
#import "FreightCar.h"
#import "Industry.h"
#import "Place.h"
#import "ScheduledTrain.h"
#import "SwitchListDocumentInterface.h"

//  Generates the text report for a standard to/from switchlist.

@implementation SwitchListReport

// what kind of report?
- (NSString *) typeString {
	return @"Conductor's Wheel Report";
}


- (NSString*) contents {
	FreightCar *freightCar;
	
	NSMutableString *switchListReport = [NSMutableString string];
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"yyyy/MM/dd" options:0 locale:[NSLocale currentLocale]]];
	NSString *currentDateString = [dateFormatter stringFromDate: [[owningDocument_ entireLayout] currentDate]]; 
	[switchListReport appendFormat: @"\nTrain: %@               Date: %@        Conductor:\n",[[train_ name] uppercaseString], currentDateString];
	[switchListReport appendFormat: @"%-12s %4s %12s/%-12s  %12s/%12s %12s\n","Init Number","Kind","From Sta","Ind","To Sta","Ind # Door","Contents"];
	[switchListReport appendFormat: @"%-12s %4s %12s/%-12s  %12s/%12s %12s\n","-----------","----","--------------","--------------","--------------","--------------","--------------"];

	NSEnumerator *e= [carsInTrain_ objectEnumerator];
	while ((freightCar = [e nextObject]) != nil) {
		InduYard *source = [freightCar currentLocation];
		NSString* contents = [freightCar cargoDescription];
		if (contents == nil) contents = @"empty";
		
		[switchListReport appendFormat: @"%-12s %4s %12s/%-12s  %25s %12s\n",
					                    [[freightCar reportingMarks] UTF8String],
										[[freightCar carType] UTF8String],
										[[[source location] name] UTF8String],
										[[source name] UTF8String],
										[[self nextDestinationForFreightCar: freightCar] UTF8String],
										[contents UTF8String]];

    }						

	return switchListReport;				
}

- (int) expectedColumns {
	return 80;
}

@end
