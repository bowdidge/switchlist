//
//  CargoReport.m
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

#import "CargoReport.h"
#import "Cargo.h"
#import "CarType.h"

// A cargo report summarizes the number of cars of each time sent and received at each industry,
// grouped by car type.
// It's useful for checking balance -- making sure, for instance, that the big cannery is twice
// as busy as the small one.

// _objectsToDisplay will contain the list of cargos.


@implementation CargoReport

- (id) initWithDocument: (NSDocument<SwitchListDocumentInterface>*) document 
		 withIndustries: (NSArray*) industryObjects {
	[super initWithDocument: document];
	industryObjects_  = [industryObjects retain];
	uniqueStrings_ = nil;
	unspecifiedString_ = [NSString stringWithString: @"Unspecified"];
	return self;
}
- (void) dealloc {
	[industryObjects_ release];
	NSFreeHashTable(uniqueStrings_);
	[unspecifiedString_ release];
  [super dealloc];
}

- (NSString*) uniqueCarType: (NSString*) carType {
	if (carType == nil) carType = unspecifiedString_;
	if (uniqueStrings_ == NULL) {
		uniqueStrings_ = NSCreateHashTable(NSObjectHashCallBacks,40);
	}
	
	NSString *match = (NSString*) NSHashGet(uniqueStrings_,carType);
	if (match) return match;
	
	NSHashInsert(uniqueStrings_, (NSString*)carType);
	return carType;
}

- (NSArray *) allCarTypes {
	return NSAllHashTableObjects(uniqueStrings_);
}

- (NSString*) contents {
	
	// First summarize data.
	// We need to know cars in/cars out of each type per industry.
	// we'll use a two level dictionary approach.  The first maps industry pointers
	// to dictionaries of car counts.
	// we'll have two dictionaries, one for in one for out.
	
	NSMutableDictionary *industryReceivingDict = [NSMutableDictionary dictionary];
	NSMutableDictionary *industrySendingDict = [NSMutableDictionary dictionary];
	NSEnumerator *e = [objectsToDisplay_ objectEnumerator];

	if (!objectsToDisplay_ || [objectsToDisplay_ count] == 0) {
		return @"No cargos defined";
	}

	Cargo *cargo;
	while ((cargo = [e nextObject]) != nil) {
		NSString *source = [cargo valueForKeyPath: @"destination.name"];
		NSString *carTypeName = [cargo carType];
		if (carTypeName == nil) carTypeName = unspecifiedString_;
		NSNumber *carsPerWeek = [cargo valueForKey: @"carsPerWeek"];
		NSString *uniqueCarType = [self uniqueCarType: carTypeName];
		NSMutableDictionary *carDict = [industryReceivingDict valueForKey: source];
		if (carDict == nil) {
			carDict = [NSMutableDictionary dictionary];
			[industryReceivingDict setValue: carDict forKey: source];
		}
		
		NSNumber *carCount = [carDict valueForKey: uniqueCarType];
		if (carCount == nil) {
			carCount = carsPerWeek;
		} else {
			carCount = [NSNumber numberWithInt: [carsPerWeek intValue] + [carCount intValue]];
		}
		[carDict setObject: carCount forKey: carTypeName];
	}

	/* Do the same for sources. */
	e = [objectsToDisplay_ objectEnumerator];
	while ((cargo = [e nextObject]) != nil) {
		NSString *dest = [cargo valueForKeyPath: @"source.name"];
		NSString *carTypeName = [cargo carType];
		if (carTypeName == nil) carTypeName = unspecifiedString_;
		NSNumber *carsPerWeek = [cargo valueForKey: @"carsPerWeek"];
		NSString *uniqueCarType = [self uniqueCarType: carTypeName];
		NSMutableDictionary *carDict = [industrySendingDict valueForKey: dest];
		if (carDict == nil) {
			carDict = [NSMutableDictionary dictionary];
			[industrySendingDict setValue: carDict forKey: dest];
		}
		
		NSNumber *carCount = [carDict valueForKey: uniqueCarType];
		if (carCount == nil) {
			carCount = carsPerWeek;
		} else {
			carCount = [NSNumber numberWithInt: [carsPerWeek intValue] + [carCount intValue]];
		}
		[carDict setObject: carCount forKey: carTypeName];
	}
	
	NSMutableString *result = [NSMutableString string];
	NSArray *carTypes = [self allCarTypes];
	NSEnumerator *carTypeEnum = [carTypes objectEnumerator];
	NSString *carType;
	[result appendFormat: @"%20s ","Industry"];
	while ((carType = [carTypeEnum nextObject]) != nil) {
		[result appendFormat: @" %04s    ",[carType UTF8String]];
	}
	[result appendString: @"\n"];


	NSEnumerator *indEnum = [industryObjects_ objectEnumerator];
	InduYard *ind;
	while ((ind = [indEnum nextObject]) != nil) {
		int sumRcv = 0;
		int sumSend = 0;
		[result appendFormat: @"%20s ",[[ind name] UTF8String]];
		NSDictionary *rcvCarCountDict = [industryReceivingDict valueForKey: [ind name]];
		NSDictionary *sendCarCountDict = [industrySendingDict valueForKey: [ind name]];
		NSEnumerator *carEnum = [carTypes objectEnumerator];

		NSString *carTypeName;
		while ((carTypeName = [carEnum nextObject]) != nil) {
			NSNumber *rcvCarCount = [rcvCarCountDict valueForKey: carTypeName];
			NSNumber *sendCarCount = [sendCarCountDict valueForKey: carTypeName];
			int rcvCount=0;
			int sendCount=0;
			if (rcvCarCount != nil) rcvCount = [rcvCarCount intValue];
			if (sendCarCount != nil) sendCount = [sendCarCount intValue];
			sumRcv += rcvCount;
			sumSend += sendCount;

			[result appendFormat: @"%3d/%3d  ",rcvCount, sendCount];
		}
		[result appendFormat: @"%3d/%3d  ",sumRcv, sumSend];
		[result appendString: @"\n"];
	}
	
	[result appendString: @"\nNumbers represent the number of incoming and outgoing cars per week for each car type\nand each industry.\n\n"];
	[result appendString: @"Ensure that industries of similar size have similar numbers of incoming and outgoing cars.\n"];
	return result;
}	
	
- (NSString *) typeString {
	return @"Cargo report";
}


@end
