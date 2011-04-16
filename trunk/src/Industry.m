// 
//  Industry.m
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

#import "Industry.h"

#import "EntireLayout.h"   // For NormalizeDivisioString().
#import "FreightCar.h"
#import "InduYard.h"

@implementation Industry 

- (void)awakeFromInsert {
	[super awakeFromInsert];
	[self setName: @"New industry"];
}

- (NSNumber *)numberOfDoors 
{
    NSNumber * tmpValue;
    
    [self willAccessValueForKey: @"numberOfDoors"];
    tmpValue = [self primitiveValueForKey: @"numberOfDoors"];
    [self didAccessValueForKey: @"numberOfDoors"];
    
    return tmpValue;
}

- (void)setNumberOfDoors:(NSNumber *)value 
{
    [self willChangeValueForKey: @"numberOfDoors"];
    [self setPrimitiveValue: value forKey: @"numberOfDoors"];
    [self didChangeValueForKey: @"numberOfDoors"];
}

- (BOOL)isYard 
{
	return false;
}

- (void)setIsYard:(NSNumber *)value {
	NSLog(@"Can't set isYard!");
}

- (BOOL)hasDoors 
{
    NSNumber * tmpValue;
    
    [self willAccessValueForKey: @"hasDoors"];
    tmpValue = [self primitiveValueForKey: @"hasDoors"];
    [self didAccessValueForKey: @"hasDoors"];
    
    return [tmpValue boolValue] == YES;
}

- (void)setHasDoors:(BOOL) value 
{
    [self willChangeValueForKey: @"hasDoors"];
    [self setPrimitiveValue: [NSNumber numberWithBool: value] forKey: @"hasDoors"];
    [self didChangeValueForKey: @"hasDoors"];
}

- (NSString*) description {
	return [NSString stringWithFormat: @"%@ at %@", [self name], [[self location] name]];
}


@end
