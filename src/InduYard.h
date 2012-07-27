//
//  InduYard.h
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

#import <CoreData/CoreData.h>

@class Place;

@interface InduYard : NSManagedObject {

}
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *division;
@property (nonatomic, retain) Place *location;


- (NSSet*) freightCars;
- (BOOL) isOffline;
- (BOOL) isStaging;
// Returns whether this is a valid industry for receiving cargo.  Yards and Workbench don't count.
- (BOOL) canReceiveCargo;
- (BOOL) isYard;
// Is industry, not yard, not in staging or offline.
- (BOOL) isRegularIndustry;


// Returns sidingLength of current object, or 0 if not set or if current object is
// not an industry with a defined siding length.
- (NSNumber*) sidingLength;

- (NSArray*) allFreightCarsSortedOrder;

- (NSComparisonResult) compareNames: (InduYard*) i;

// Copy fields that are officially part of the HTML template to the dictionary
// representing an industry.
- (NSMutableDictionary*) templateDictionary;

@end
