//
//  PICLReport.m
//  SwitchList
//
//  Created by James McNab on 4/4/11
//
// Copyright (c)2011 James McNab,
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

#import "PICLReport.h"


#import "EntireLayout.h"
#import "GlobalPreferences.h"
#import "CarType.h"
#import "FreightCar.h"
#import "Industry.h"
#import "Place.h"
#import "ScheduledTrain.h"
#import "SwitchListDocumentInterface.h"

// Creates a switchlist report based on "modern" (post-1980) computer based switchlists and
// reports using PICL (Perpetual Inventory of Car Locations) software.
// Report shows standing of all cars to be handled at stations visited by selected train

@implementation PICLReport

// what kind of report?
- (NSString *) typeString {
	return [NSString stringWithFormat: @"Work Order for %@",[train_ name]];
}

- (NSString*) contents {
	NSMutableString *piclString = [NSMutableString string];
	
	NSArray *stops = [train_ stationsInOrder];
	// Create unique list of stops because the train may visit the same town twice.
	// We'll make the list ourselves to keep the list in visited order.
	NSMutableArray *stopsVisited = [NSMutableArray array];
	for (Place *stop in stops) {
		if ([stopsVisited containsObject: stop] == NO) {
			[stopsVisited addObject: stop];
		}
	}
	
	for (Place *currentTown in stopsVisited) {
		// What industries have cars here?
		NSArray *carsAtStation = [train_ carsAtStation: currentTown];
		NSMutableSet *industriesWithCars = [NSMutableSet set];
		for (FreightCar *car in carsAtStation) {
			[industriesWithCars addObject: [car currentLocation]];
		}
		// Make the list of industries in town with cars, sorted in alphabetical industry name order.
		NSArray *industriesInNameOrder = [[industriesWithCars allObjects] sortedArrayUsingSelector: @selector(compareNames:)];
		for (InduYard *currentIndustry in industriesInNameOrder) {
			const char *currentIndustryName = (currentIndustry  ? [[currentIndustry name] UTF8String]: "unknown");
			const char *currentTownName = (currentTown ? [[currentTown name] UTF8String] : "unknown");
											 
			// Print section header.
			[piclString appendFormat: @"\n\n===============================================================================\n"];
			[piclString appendFormat: @"TRACK: %-18s           STATION: %-21s\n", currentIndustryName, currentTownName];
			[piclString appendFormat: @"===============================================================================\n"];
			[piclString appendFormat: @"Seq Car         LE Block To                                    LG KD Commodity\n"];
			[piclString appendFormat: @"-------------------------------------------------------------------------------\n"];
			
			// Make the list of cars here, sorted in order of car type.
			NSMutableArray *carsAtIndustry = [NSMutableArray array];
			for (FreightCar *car in carsAtStation) {
				if ([car currentLocation] == currentIndustry) {
					[carsAtIndustry addObject: car];
				}
			}
			
			// TODO(mcnab) Currently sorting by Destination in Alphabetical Order.  Should sort in Station Order.
			NSArray *carsAtIndustrySortedByDestination = [carsAtIndustry sortedArrayUsingFunction: sortCarsByDestinationIndustry context: nil];
			
			int seq = 1;
			
			Place *currentPlace = nil;
			for (FreightCar *freightCar in carsAtIndustrySortedByDestination) {
				NSString* contents;
				if ([freightCar isLoaded]) {
					contents = [[freightCar cargoDescription] uppercaseString];
				} else { 
					contents = @"**EMPTY**";
				}
				if ([contents length] > 14) {
					contents = [contents substringWithRange: NSMakeRange(0, 14)];
				}
		
				BOOL loaded = [freightCar isLoaded];
				NSString *LE = (loaded ? @"L" : @"E");
				
				InduYard *toIndustry = [freightCar nextStop];
				NSString *toIndustryName = [toIndustry name];
				Place *toTown = [toIndustry location];
				int doorToSpot = [freightCar nextDoor];
				if (doorToSpot != 0) {
					toIndustryName = [[NSString stringWithFormat: @"%@ #%d", toIndustryName, doorToSpot] uppercaseString];
				}
				
				if (currentPlace != nil &&
					[[freightCar nextStop] location] != currentPlace) {
					// Draw separator only between cars going to different towns, not between
					// car and heading.
					[piclString appendFormat: @"-------------------------------------------------------------------------------\n"];
				}
				currentPlace = [[freightCar nextStop] location];
				
				// Print line for this freight car.
				[piclString appendFormat: @"%3d %-4s %6d %-2s %-21s %-21s %2d %-2s %-15s\n",
				 seq,
				 [[freightCar initials] UTF8String],
				 [[freightCar number] intValue],
				 [LE UTF8String],
				 [toIndustryName UTF8String],
				 [[toTown name] UTF8String],
				 [[freightCar length] intValue],
				 [[freightCar carType] UTF8String],
				 [contents UTF8String]];
				seq++;
			}
			[piclString appendFormat: @"_______________________________________________________________________________\n"];
			int carsAtLocation = [carsAtIndustry count];
			int carsAtLocationLength = 0;
			int carsAtLocationLoaded = 0;
			for (FreightCar *car in carsAtIndustry) {
				carsAtLocationLength += [[car length] intValue];
				if ([car isLoaded]) {
					carsAtLocationLoaded += 1;
				}
			}
			
			int carsAtLocationEmpty = carsAtLocation  - carsAtLocationLoaded;
			[piclString appendFormat: @"-------------------------------------------------------------------------------\n"];
			[piclString appendFormat: @"LOADS:%4d     EMPTY:%4d     CARS:%4d                           LENGTH: %4d\n",
			 carsAtLocationLoaded,
			 carsAtLocationEmpty,
			 carsAtLocation,
			 carsAtLocationLength];
		}
	}
	

	// Print footer.
	NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
	[outputFormatter setDateFormat:@"MM/dd/yy"];
	NSString *newDateString = [outputFormatter stringFromDate: [[owningDocument_ entireLayout] currentDate]];
	[outputFormatter release];
	
	
	NSDate * now1 = [NSDate date];
	NSDateFormatter *outputFormatter1 = [[NSDateFormatter alloc] init];
	[outputFormatter1 setDateFormat:@"HH:mm:ss"];
	NSString *newDateString1 = [outputFormatter1 stringFromDate:now1];
    [outputFormatter1 release];									
	
	
	[piclString appendFormat: @"\n\nPRINTED %@ - %@\n",newDateString,newDateString1];
	[piclString appendFormat: @"** END OF REPORT **\n"];
	
	return piclString;
}

- (int) expectedColumns {
	return 85;
}

@end
