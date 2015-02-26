//
//  ProposedCargo.h
//  SwitchList
//
//  Created by Robert Bowdidge on 1/30/2015
//
// Copyright (c)2015 Robert Bowdidge,
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

@class Cargo;
@class Industry;
@class InduYard;

// Represents a potential cargo for the current industry.
@interface ProposedCargo : NSObject {
    NSNumber *isKeep;
    BOOL isReceive;
    NSString *name;
    NSString *carsPerWeek;
    InduYard *industry;
    BOOL isExistingCargo;
}

// Create ProposedCargo based on a cargo type we already have.
- (id) initWithExistingCargo: (Cargo*) cargo isReceive: (BOOL) shouldReceive;

// Creates an actual cargo based on the proposed cargo, and stores it in the
// permanent database.
- (Cargo*) createRealCargoWithIndustry: (Industry*) i;

// Value of checkbox whether to create this cargo.  NSNumber required
// for checkbox.
@property (nonatomic, retain) NSNumber *isKeep;
// Is incoming cargo.
@property (nonatomic) BOOL isReceive;
// String value for receive column: either "Receive" or "Ship".
@property (nonatomic, readonly) NSString *receiveString;
// Cargo description.
@property (nonatomic, retain) NSString *name;
// Rate of cars arriving or departing.
@property (nonatomic, retain) NSString *carsPerWeek;
// Preferred industry as source/dest of cargo.
@property (nonatomic, retain) InduYard *industry;
// Existing cargo just being shown for context?
@property (nonatomic) BOOL isExistingCargo;
@end