//
//  Place.h
//  SwitchList
//
//  Created by Robert Bowdidge on 6/9/06.
//
// Copyright (c)2006 Robert Bowdidge,
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

@class Industry;
@class InduYard;

// A Place is a physical location with multiple industries.  It's generally
// referred to as "town" or "station" within the program.
// A place can also hold a yard.

@interface Place :  NSManagedObject {
}
@property (nonatomic, retain) NSString* name;


- (BOOL)isOffline;
- (void) setIsOffline: (BOOL) value;

- (BOOL)isStaging;
- (void)setIsStaging:(BOOL) value;

- (NSSet*) industries;
- (NSSet*) yards;

- (NSSet*) freightCarsAtStation;

// Access to-many relationship via -[NSObject mutableSetValueForKey:]
// TODO(bowdidge): Remove.  Unused.
- (void)addAdjacentPlacesObject:(NSManagedObject *)value;
- (void)removeAdjacentPlacesObject:(NSManagedObject *)value;

// Access to-many relationship via -[NSObject mutableSetValueForKey:]
- (void)addIndustriesObject:(InduYard *)value;
- (void)removeIndustriesObject:(InduYard *)value;

// Does this place have a yard?
- (BOOL) hasYard;

- (BOOL)validateName: (id*) namePtr error:(NSError **)error;

@end
