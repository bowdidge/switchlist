//
//  RandomNumberGenerator.h
//  SwitchList
//
//  Created by bowdidge on 9/1/12.
//
// Copyright (c)2012 Robert Bowdidge,
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

// Encapsulates the idea of a random number generator, and provides mock
// for testing.

#import <Foundation/Foundation.h>

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
// TODO: Move to a real mocking framework?
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

