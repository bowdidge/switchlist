//
//
//  SwitchListFilters.m
//  SwitchList
//
//  Created by bowdidge on 8/26/2011
//
// Copyright (c)2011 Robert Bowdidge,
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

// Defines new MGTemplateEngine filters for converting values in templates.
//
// New filters are:
//
// jitter:
//
// adds random space at the ends or in the middle of an existing string
// in order to make strings appear random and hand-drawn in handwritten
// switchlists.  It only affects x position; there's probably a way with
// CSS styles to change the y location.
//
// Example:
//   {{ car.location.name | jitter }} 
// draws the freight car's name with slight changes on each line.
//
// sum_of_lengths:
//
// Takes an array of freight cars, and returns the sum of lengths of cars.
//
// Example:
//   {{ all_incoming_cars | sum_of_lengths }}
// draws the number for the sum of lengths.

#import <Foundation/Foundation.h>

#import "MGTemplateFilter.h"

@interface SwitchListFilters : NSObject <MGTemplateFilter> {
}
- (NSArray *)filters;
- (NSObject *)filterInvoked:(NSString *)filter withArguments:(NSArray *)args onValue:(NSObject *)value;

- (NSString*) jitterString: (NSString*) value;
// Only operates on arrays.
- (NSString*) sumOfLengths: (id) value;

// For predictably testing which way a jittered string will change.
- (int) getRandomValue: (int) max;

@end
