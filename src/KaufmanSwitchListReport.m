//
//  KaufmanSwitchListReport.m
//  SwitchList
//
//  Created by Robert Bowdidge on 10/2/08.
//
// Copyright (c)2008 Robert Bowdidge,
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

#import "KaufmanSwitchListReport.h"

#import "CarType.h"
#import "FreightCar.h"
#import "Industry.h"
#import "Place.h"
#import "ScheduledTrain.h"
#import "SwitchListDocumentInterface.h"

// Bill Kaufman style switch list used on the San Francisco Belt rr.  
// 
// This style of switch list groups cars into two (or three categories)
//
// Drop off - cars being taken from the originating station to other places
// Pick up - cars being taken to the terminating station
// Other - cars going between other stations, picked up and dropped off as part of same train.

@implementation KaufmanSwitchListReport

// what kind of report?
- (NSString *) typeString {
	return [NSString stringWithFormat: @"Switch List for %@",[train_ name]];
}

- (void) displayCars: (NSArray *) cars intoString: (NSMutableString *) switchListReport  {
  FreightCar *freightCar;
  NSEnumerator *e= [cars objectEnumerator];
	while ((freightCar = [e nextObject]) != nil) {
		InduYard *source = [freightCar currentLocation];
		NSString* contents = [freightCar cargoDescription];
		if (contents == nil) contents = @"empty";
		// fixme door goes here
		[switchListReport appendFormat: @"%-12s %4s %15s/%15s  %31s %15s \n",
					                    [[freightCar reportingMarks] UTF8String],
										[[[freightCar carTypeRel] carTypeName] UTF8String],
										[[[source location] name] UTF8String],
										[[source name] UTF8String],
										[[self nextDestinationForFreightCar: freightCar] UTF8String],
										[contents UTF8String]];
    }						

}

- (NSString*) contents {
	// Now, iterate through each stop.
	NSMutableString *switchListReport = [NSMutableString string];

	[switchListReport appendFormat: @"\nTrain %@:\n",[train_ name]];
	
	[switchListReport appendFormat: @"\nEngineer:\n\nLocomotive:\n\n"];
	[switchListReport appendFormat: @"%-12s %4s %15s/%15s  %15s/%15s %15s\n","Rept marks","Kind","From Sta","Ind","To Sta","Ind # door","Contents"];
	[switchListReport appendFormat: @"%-12s %4s %15s/%15s  %15s/%15s %15s\n","-----------","----","--------------","--------------","--------------","--------------","--------------"];

	[switchListReport appendFormat: @"Cars to drop off\n"];
	
	NSArray *stationStops = [[owningDocument_ entireLayout] stationStopsForTrain: train_];
	Place *firstStation = [stationStops objectAtIndex: 0];
	Place *lastStation = [stationStops lastObject];
	
	NSArray *dropOffCars = [train_ carsAtStation: firstStation];

	[self displayCars: dropOffCars intoString: switchListReport];

	[switchListReport appendFormat: @"\nCars to pick up\n"];

	NSArray *pickUpCars = [train_ carsForStation: lastStation];
	[self displayCars: pickUpCars intoString: switchListReport];
	
	NSMutableArray *remainingCars = [NSMutableArray arrayWithArray: carsInTrain_];
	[remainingCars removeObjectsInArray: pickUpCars];
	[remainingCars removeObjectsInArray: dropOffCars];
	
	[switchListReport appendFormat: @"\nOther cars to handle\n"];
	[self displayCars: remainingCars intoString: switchListReport];

	return switchListReport;				
}

@end
