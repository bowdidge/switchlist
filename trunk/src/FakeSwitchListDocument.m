//
//  FakeSwitchListDocument.m
//  SwitchList
//
//  Created by bowdidge on 4/16/11.
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

#import "FakeSwitchListDocument.h"

#import "DoorAssignmentRecorder.h"

@implementation FakeSwitchListDocument 
- (id) initWithLayout: (EntireLayout*) entireLayout {
	self = [super init];
	layout = [entireLayout retain];
	recorder = [[DoorAssignmentRecorder alloc] init];
	return self;
}

- (void) dealloc {
	[layout release];
	[recorder release];
	[super dealloc];
}

- (EntireLayout*) entireLayout {
	return layout;
}
- (DoorAssignmentRecorder*) doorAssignmentRecorder {
	return recorder;
}

- (NSURL*) fileURL {
	return [NSURL URLWithString:@"happy"];
}

- (NSURL*) autosavedContentsFileURL {
	return nil;
}

- (id) printInfo {
    return nil;
}
@end
