//
//
//  SwitchListFilters.m
//  SwitchList
//
//  Created by bowdidge on 8/26/2011.
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

#import "SwitchListFilters.h"

#import "FreightCar.h"

#define JITTER		@"jitter"
#define SUM_OF_LENGTHS @"sum_of_lengths"
// Escape the string for embedding in a JavaScript string.  Convert ' and " to \' and \".
#define ESCAPE_STRING @"js_escape_string"

@implementation SwitchListFilters
// Adds whitespace - nbsp, emsp, ensp - randomly at the beginning and end of strings,
// and at existing white space - to simulate handwriting.
- (int) getRandomValue: (int) max {
	return random() % max;
}

- (NSString*) jitterString: (NSString*) value {
	NSString *spaces[3] = {@"&nbsp;", @"&emsp;", @"&ensp;"};
	int spaceChoice = [self getRandomValue: 3];
	
	int choices = 2;
	NSRange spaceRange = [value rangeOfString:@" "];
	if (spaceRange.location != NSNotFound) choices = 3;

	switch ([self getRandomValue: choices]) {
		case 0:
			// Add whitespace at start.
			return [NSString stringWithFormat: @"%@%@", spaces[spaceChoice], value];
			break;
		case 1:
			// Add whitespace at beginning.
			return [NSString stringWithFormat: @"%@%@", value, spaces[spaceChoice]];
			break;
		case 2:
			// Add whitespace at one of the spaces.
			return [value stringByReplacingCharactersInRange: spaceRange
												  withString: [NSString stringWithFormat: @"%@ ",spaces[spaceChoice]]];
			break;
	}
	// Should fail.
	return value;
}

- (NSString*) sumOfLengths: (NSArray*) value {
	int sum = 0;

	if (![value isKindOfClass: [NSArray class]]) {
		return @"[sum_of_lengths only works on arrays.]";
	}

	for (FreightCar *car in value) {
		if ([car isKindOfClass: [FreightCar class]]) {
			sum += [[car length] intValue];
		}
	}
	return [NSString stringWithFormat: @"%d", sum];
}

// Escapes quotes and double quotes with \ for JavaScript.
- (NSString*) escapeJavaScriptString: (NSString*) str {
	NSString *str1 = [[str stringByReplacingOccurrencesOfString: @"'" withString: @"\\\'"]
			stringByReplacingOccurrencesOfString: @"\"" withString: @"\\\""];
	return str1;
}

- (NSArray *)filters
{
	return [NSArray arrayWithObjects: JITTER, SUM_OF_LENGTHS, ESCAPE_STRING, nil];
}

- (NSObject *)filterInvoked:(NSString *)filter withArguments:(NSArray *)args onValue:(NSObject *)value {
	if ([filter isEqualToString:JITTER]) {
		return [self jitterString: (NSString*) value];
	} else if ([filter isEqualToString: SUM_OF_LENGTHS]) {
		return [self sumOfLengths: (NSArray*) value];
	} else if ([filter isEqualToString: ESCAPE_STRING]) {
		return [self escapeJavaScriptString: (NSString*) value];
	}
	return value;
}		
@end
