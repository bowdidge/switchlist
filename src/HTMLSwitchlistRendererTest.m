//
//  HTMLSwitchlistRendererTest.h
//  SwitchList
//
//  Created by bowdidge on 11/5/11.
//  Copyright 2011 Robert Bowdidge. All rights reserved.
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

#import "HTMLSwitchlistRendererTest.h"

#import "EntireLayout.h"
#import "HTMLSwitchlistRenderer.h"


@implementation HTMLSwitchlistRendererTest
// Test line printer template returns line printer template files.
- (void) testStockTemplateTest {
	[self makeThreeStationLayout];
	[self makeThreeStationTrain];
	
	NSBundle *bundleForUnitTests = [NSBundle bundleForClass:[HTMLSwitchlistRenderer class]];
	HTMLSwitchlistRenderer *renderer = [[HTMLSwitchlistRenderer alloc] initWithBundle: bundleForUnitTests];
	NSString *text = [renderer renderSwitchlistForTrain: [[self entireLayout] trainWithName: @"MyTrain"]
												 layout: [self entireLayout]
												 iPhone: NO];
	STAssertContains(@"builtin-switchlist.css", text, @"%@ does not contain builtin ref", text);
}
@end
