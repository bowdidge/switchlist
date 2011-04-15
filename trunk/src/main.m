//
//  main.m
//  SwitchList
//
//  Created by Robert Bowdidge on 9/17/05.
//
// Copyright (c)2005 Robert Bowdidge,
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

#import <Cocoa/Cocoa.h>
#include <sys/time.h>

#import "NSMigrationManagerCategory.h"

// transformer for Train presentation
// TODO(bowdidge): What is this for?
@interface TrainPathTransformer: NSValueTransformer {
}
@end

@implementation TrainPathTransformer
+ (Class)transformedValueClass { return [NSString self]; }
+ (BOOL)allowsReverseTransformation { return NO; }
- (id)transformedValue:(id)value {
	NSArray *foo = (NSArray*) value;
	NSMutableString *result = [NSMutableString string];
	NSEnumerator *e = [foo objectEnumerator];
	id place;
	while ((place=[e nextObject]) != nil) {
		[result appendString: [place valueForKey: @"name"]];
	}
	return result;
}
@end


int main(int argc, char *argv[])
{
	struct timeval tp;
	struct timezone tz;
	gettimeofday(&tp, &tz);
	srand(tp.tv_usec);
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	id transformer = [[[TrainPathTransformer alloc] init] autorelease];
	[NSValueTransformer setValueTransformer:transformer forName:@"TrainPathTransformer"]; 

	// Workaround for bug in 10.5.
	[NSMigrationManager addRelationshipMigrationMethodIfMissing];
	
	int ret = NSApplicationMain(argc, (const char **) argv);
	[pool release];
	return ret;
}


