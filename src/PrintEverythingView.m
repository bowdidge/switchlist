//
//  PrintEverythingView.m
//  SwitchList
//
//  Created by Robert Bowdidge on 7/31/08.
//
// Copyright (c)2008 Robert Bowdidge,
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

#import "PrintEverythingView.h"

#import "EntireLayout.h"
#import "ScheduledTrain.h"
#import "SwitchListBaseView.h"
#import "SwitchListDocumentInterface.h"

// Create a view holding all switchlists of all trains, as well as the industry list and yard list.
// This can be used to print everything in one fell swoop.

@implementation PrintEverythingView

- (BOOL) knowsPageRange: (NSRangePointer) range {
	range->location = 1;
	range->length = 0;
	
	for (SwitchListBaseView *view in [self subviews]) {
		NSRange r;
		[view knowsPageRange: &r];
		range->length += r.length;
	}
	return YES;
}

- (NSRect)rectForPage:(NSInteger)page {
    // All the switchlists are printing in the same containing view, so document bounds should match.
	// Note we don't call through to views.
	return NSMakeRect(0, imageableHeight_ * (page-1), imageableWidth_, imageableHeight_);
}

- (id) initWithFrame: (NSRect) r withDocument: (NSDocument<SwitchListDocumentInterface>*) document 
	   withViewClass: (Class) preferredClass {
	self = [super initWithFrame: r];
	document_ = [document retain];	
	subviews = [[NSMutableArray alloc] init];
	int pages = 0;

	NSPrintInfo *myPrintInfo = [document printInfo];
	imageableWidth_ = [myPrintInfo paperSize].width - [myPrintInfo leftMargin] - [myPrintInfo rightMargin];
	imageableHeight_ = [myPrintInfo paperSize].height - [myPrintInfo topMargin] - [myPrintInfo bottomMargin];

	NSArray *trains = [[document entireLayout] allTrains];

	float offsetY = 0.0;
	for (ScheduledTrain *t in trains) {		
		NSRect subDocumentRect = NSMakeRect(0.0, offsetY, imageableWidth_, imageableHeight_);
		SwitchListBaseView *v = [[preferredClass alloc] initWithFrame: subDocumentRect withDocument: document];
		[v setTrain: t];
		// All the switchlists are printing in the same view, so document bounds should match.
		NSRange r;
		[v knowsPageRange: &r];
		NSUInteger pageCount = r.length;
		if (r.length == 0) {
			continue;
		}
		NSRect viewFrame = [v frame];
		[subviews addObject: v];
		pages += pageCount;
		[v release];
		
		offsetY += viewFrame.size.height;
	}
	NSRect lastViewFrame = [[subviews lastObject] frame];
	[self setFrame: NSMakeRect(0.0, 0.0, lastViewFrame.size.width, offsetY)];
	[self setSubviews: subviews];
    optionalSettings_ = nil;
	return self;
}

// No implementation of drawRect because the view does no drawing
// of its own.

- (void) dealloc {
	[subviews release];
	[document_ release];
    [optionalSettings_ release];
	[super dealloc];
}

// Set the optional settings as a list of pairs of (setting, custom value.
- (void) setOptionalSettings: (NSArray*) optionalSettings {
    [optionalSettings_ release];
    optionalSettings_ = optionalSettings;
}

- (NSString*) optionWithName: (NSString*) optionName alternate: (NSString*) alternate {
    return alternate;
}

@end
