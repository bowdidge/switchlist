//
//  ProposedCargo.m
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


#import "ProposedCargo.h"

#import "Cargo.h"

@implementation ProposedCargo
@synthesize isKeep;
@synthesize isReceive;
@synthesize name;
@synthesize carsPerWeek;
@synthesize industry;
@synthesize isExistingCargo;

// Creates a proposed cargo based on an existing Cargo object.
- (id) initWithExistingCargo: (Cargo*) cargo isReceive: (BOOL) shouldReceive {
    self = [self init];
    self.name = [cargo cargoDescription];
    self.isKeep = [NSNumber numberWithBool: NO];
    self.isExistingCargo = YES;
    self.isReceive = shouldReceive;
    self.industry = (shouldReceive ? [cargo source] : [cargo destination]);
    self.carsPerWeek = [[cargo carsPerWeek] stringValue];
    return self;
}

- (NSString*) receiveString {
    return (self.isReceive ? @"Receive" : @"Ship");
}

- (Cargo*) createRealCargoWithIndustry: (InduYard*) currentIndustry {
    NSManagedObjectContext *context = [currentIndustry managedObjectContext];
    [NSEntityDescription entityForName: @"Cargo" inManagedObjectContext: context];
    Cargo *newCargo = [NSEntityDescription insertNewObjectForEntityForName:@"Cargo"
                                              inManagedObjectContext: context];
    newCargo.cargoDescription = [self name];
    newCargo.priority = [NSNumber numberWithBool: NO];
    newCargo.carsPerWeek = [NSNumber numberWithInt: [[self carsPerWeek] intValue]];
    if ([self isReceive]) {
        newCargo.source = [self industry];
        newCargo.destination = currentIndustry;
    } else {
        newCargo.source = currentIndustry;
        newCargo.destination = [self industry];
    }
    return newCargo;
}
@end

