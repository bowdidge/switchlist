//
//  RandomNumberGenerator.m
//  SwitchList
//
//  Created by bowdidge on 9/1/12.
//  Copyright 2012 Robert Bowdidge. All rights reserved.
//

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
