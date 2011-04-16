//
//  CarTypes.h
//  SwitchList
//
//  Created by bowdidge on 11/6/10.
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

@class EntireLayout;

// Hides some of the helper codes for dealing with car types, and
// converting string-based names to the object-based system.

@interface CarTypes : NSObject {

}

// Searches the named layout for all the car types, and produces a default
// dictionary of car types.
+ (NSDictionary*) populateCarTypesFromLayout: (EntireLayout*) layout;

// Returns the dictionary of car types that we provide in all cases.
+ (NSDictionary*) stockCarTypes;

// Returns the car type names only.
+ (NSArray*) stockCarTypeArray;

// Returns true if the provided string is a valid car type string.
// For now, this only means that it's only made up of alphanumeric characters.
// "Any" and "" return false - this is only for determining whether to create
// car types.
+ (BOOL) isValidCarType: (NSString*) carTypeString;

@end
