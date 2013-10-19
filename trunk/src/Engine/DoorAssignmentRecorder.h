//
//  DoorAssignmentRecorder.h
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

#import <Foundation/Foundation.h>

#import "FreightCar.h"
#import "Industry.h"

// Helper class for hiding details of where cars are being assigned, and specifically
// what doors moving cars are being routed to. This information is only used to
// identify which doors at an industry are reserved.  The freight cars themselves hold
// the next door assignment.
//
// TODO(bowdidge): Consider removing this class, and instead having the TrainAssigner
// extract the list of cars arriving at doors at the industry from the freight cars.

@interface DoorAssignmentRecorder : NSObject {
	NSMutableDictionary *industryToCarMapping_;
	NSMutableDictionary *carToDoorMapping_;
}
- (id) init;
+ (id) doorAssignmentRecorder;
- (void) setCar: (FreightCar*) fc destinedForIndustry: (Industry*) industry door: (int) doorNumber;
- (int) doorForCar: (const FreightCar*) car;
- (NSArray*) carsAtIndustry: (Industry*) industry;
@property (retain) NSMutableDictionary *industryToCarMapping;
@property (retain) NSMutableDictionary *carToDoorMapping;
@end

