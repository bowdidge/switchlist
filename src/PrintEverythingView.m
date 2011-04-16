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
#import "SwitchListDocumentInterface.h"
#import "SwitchListView.h"

// Create a view holding all switchlists of all trains, as well as the industry list and yard list.
// This can be used to print everything in one fell swoop.

@implementation PrintEverythingView

// Look at the current printing objects to find the size of the paper.
- (float) myPageHeight {
	NSPrintOperation *printOp = [NSPrintOperation currentOperation];
	NSPrintInfo *printInfo = [printOp printInfo];
	float pageHeight = [printInfo paperSize].height - [printInfo topMargin] - [printInfo bottomMargin];
	return pageHeight;
}


- (id) initWithFrame: (NSRect) r withDocument: (NSObject<SwitchListDocumentInterface>*) document {
	[super initWithFrame: r];
	NSArray *trains = [[document entireLayout] allTrains];
	subviews = [[NSMutableArray alloc] init];
	int page = 0;
	pages_ = [trains count]; //[trains count];
	float pageHeight = [self myPageHeight];
	if (pageHeight == 0.0) {
		pageHeight = 612;
	}
	
	// TODO(bowdidge): Check size of pages beforehand, and make sure that multi-page switchlists
	// will be printed.
	// TODO(bowdidge): Fix this so it works with different sized paper.
	for (ScheduledTrain *t in trains) {
		NSRect subDocumentRect = NSMakeRect(0.0,pageHeight*page,720.0,pageHeight);
		SwitchListView *v = [[SwitchListView alloc] initWithFrame: subDocumentRect withDocument: document];
		[v setTrain: t];
		[subviews addObject: v];
		page++;
		[v release];
	}
	[self setFrame: NSMakeRect(0.0,0.0,6.5 * 72.0,pageHeight*pages_)];
	return self;
}

- (void) drawRect: (NSRect) rect {
	int page = 0;
	float pageHeight = [self myPageHeight];
	if (pageHeight == 0.0) {
		pageHeight = 612;
	}

	for (SwitchListView *v in subviews) {
		[v drawRect: NSMakeRect(0.0,pageHeight*page,720.0,pageHeight)];
		// Do gray fill to identify page edges.
		// [[NSColor colorWithCalibratedWhite: page * 0.1 alpha: 0.2] setFill];
		// NSRect subDocumentRect = NSMakeRect(0.0,pageHeight*page,720.0,pageHeight);
		// NSRectFill(subDocumentRect);
		page++;
	}
}

- (void) dealloc {
	[subviews release];
	[super dealloc];
}
@end
