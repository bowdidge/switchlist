//
//  RandomNumberGenerator.m
//  SwitchList
//
//  Created by bowdidge on 9/1/12.
//  Copyright 2012 Robert Bowdidge. All rights reserved.
//
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

#import "RandomNumberGenerator.h"

#include <sys/time.h>

// Preps the random number generator for particularly
// random values.
int GenerateSeed() {
	struct timeval tp;
	struct timezone tz;
	gettimeofday(&tp, &tz);
	srand(tp.tv_usec);
	return 1;
}	

@implementation RandomNumberGenerator

// Generates a random number between 0 and max-1.
- (int) generateRandomNumber: (int) max {
	if (max == 0) {
		return 0;
	}
	return rand() % max;
}
@end

@implementation MockRandomNumberGenerator

- (void) setNumbers: (NSArray*) numbers {
	[numbers_ release];
	numbers_  = [numbers retain];
	nextIndex_ = 0;
}

- (int) generateRandomNumber: (int) max {
	if (nextIndex_ >= [numbers_ count]) {
		NSLog(@"MockRandomNumberGenerator: Ran out of numbers!");
		return -1;
	}
	
	int nextNumber = [[numbers_ objectAtIndex: nextIndex_] intValue];
	if (nextNumber >= max) {
		NSLog(@"MockRandomNumberGenerator: Proposed random number %d greater or equal to than max %d\n", nextNumber, max);
		return -1;
	}
	NSLog(@"Generating %d", nextNumber);
	return [[numbers_ objectAtIndex: nextIndex_++] intValue];
}
	
@end
