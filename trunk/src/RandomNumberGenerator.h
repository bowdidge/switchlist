//
//  RandomNumberGenerator.h
//  SwitchList
//
//  Created by bowdidge on 9/1/12.
//  Copyright 2012 Robert Bowdidge. All rights reserved.
//
// Encapsulates the idea of a random number generator, and provides mock
// for testing.

#import <Cocoa/Cocoa.h>

@protocol RandomNumberGeneratorInterface
- (int) generateRandomNumber: (int) max;
@end

// Regular random number generator.  Call generateRandomNumber: repeatedly.
@interface RandomNumberGenerator : NSObject<RandomNumberGeneratorInterface> {
}
// Generates a random number between 0 and max-1.
- (int) generateRandomNumber: (int) max;
@end

// Mock - load with preferred numbers.
@interface MockRandomNumberGenerator : NSObject<RandomNumberGeneratorInterface> {
	NSArray *numbers_;
	int nextIndex_;
}

// Declares the preferred numbers that generateRandomNumber: should generate in sequence.
- (void) setNumbers: (NSArray*) numbers;

// Returns each number from setNumbers: in sequence, then returns 0 once those are exhausted.
- (int) generateRandomNumber: (int) max;
@end

// Call before use to ensure more random numbers.
extern int GenerateSeed();

