//
//  SwitchListWindowController.m
//  SwitchList
//
//  Created by Robert Bowdidge on 2/24/08.
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

#import "SwitchListReportWindowController.h"

#import "SwitchListBaseView.h"

@implementation SwitchListReportWindowController
- (id) initWithWindowNibName: (NSString*) nibName withView: (SwitchListBaseView*) view {	
	[super initWithWindowNibName: nibName];
	view_ = [view retain];
	return self;
}

- (void) dealloc {
	[view_ release];
	[super dealloc];
}

- (void) awakeFromNib {
	// TODO(bowdidge): Scale the size of the view's bounds a bit for easier reading.
	NSRect bounds = [view_ bounds];
	[view_ setFrame: [view_ bounds]];
	// Set the bounds slightly larger than the document drawing area so there's some margin.
	[view_ setBounds: NSInsetRect(bounds, -10, -10)];
	
	// Use a white background so resizing the window doesn't show unseemly gray bands.
	[scrollView_ setBackgroundColor: [NSColor whiteColor]];
	[scrollView_ setDrawsBackground: YES];
	[scrollView_ setDocumentView: view_];
}

- (IBAction) printDocument: (id) sender {
	[view_ print: sender];
}
@end
