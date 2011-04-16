// 
//  Cargo.m
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

#import "Cargo.h"

#import "CarType.h"
#import "Industry.h"

@implementation Cargo 


@dynamic priority;
@dynamic carTypeRel;
@dynamic cargoDescription;
@dynamic source,destination;


- (NSNumber *)carsPerWeek 
{
    NSNumber * tmpValue;
    
    [self willAccessValueForKey: @"carsPerWeek"];
    tmpValue = [self primitiveValueForKey: @"carsPerWeek"];
    [self didAccessValueForKey: @"carsPerWeek"];
    
    return tmpValue;
}

- (void)setCarsPerWeek:(NSNumber *)value 
{
    [self willChangeValueForKey: @"carsPerWeek"];
    [self setPrimitiveValue: value forKey: @"carsPerWeek"];
    [self didChangeValueForKey: @"carsPerWeek"];
}

- (BOOL) isSourceOffline {
	return ([[self valueForKeyPath: @"source"] isOffline]);
}

- (BOOL) isDestinationOffline {
	return ([[self valueForKeyPath: @"destination"] isOffline]);
}

- (NSString*) description {
	NSString *carTypeLabel = [NSString stringWithFormat: @"%@ (%@)",
							  [[self carTypeRel] carTypeName], [[self carTypeRel] carTypeDescription]];
	if (!carTypeLabel || [carTypeLabel length] == 0) {
		carTypeLabel = [[self carTypeRel] carTypeName];
	}
	return [NSString stringWithFormat: @"%@, sent from %@ to %@, %d %@ cars per week",
			[self cargoDescription],[[self source] name],[[self destination] name],
			[[self carsPerWeek] intValue], carTypeLabel];
}

@end
