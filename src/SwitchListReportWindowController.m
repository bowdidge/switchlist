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
#import "SwitchListDocument.h"

@implementation SwitchListReportWindowController
- (id) initWithWindowNibName: (NSString*) nibName withView: (SwitchListBaseView*) view withDocument: (SwitchListDocument*) owningDocument {	
	[super initWithWindowNibName: nibName];
	view_ = [view retain];
	float margin = 10.0;
	// TODO(bowdidge): Fix.  The view gets sized larger than the view in the window, and so always is partially obscured.
	marginView_ = [[NSView alloc] initWithFrame: NSMakeRect(0,0, [view frame].size.width + 2 * margin, [view frame].size.height + 2 * margin)];
	[marginView_ addSubview: view_];
	
	owningDocument_ = [owningDocument retain];
	return self;
}

- (void) dealloc {
	[view_ release];
	[owningDocument_ release];
	[super dealloc];
}

- (void) awakeFromNib {
	// Use a white background so resizing the window doesn't show unseemly gray bands.
	[scrollView_ setBackgroundColor: [NSColor whiteColor]];
	[scrollView_ setDrawsBackground: YES];
	[scrollView_ setDocumentView: marginView_];
	[[scrollView_ contentView] setCopiesOnScroll:NO];
}

- (IBAction)runPageLayout:(id)sender {
	[owningDocument_ runPageLayout: sender];
}						

- (IBAction) printDocument: (id) sender {
	// set default printing properties for switchlists.
	NSPrintInfo *printInfo = [[owningDocument_ printInfo] copy];
	[printInfo setLeftMargin: 0.75 * 72];
	[printInfo setRightMargin: 0.75 * 72];
	[printInfo setTopMargin: 0.75 * 72];
	[printInfo setBottomMargin: 0.75 * 72];
	
	NSSize paperSize = [printInfo paperSize];
	
	// Assumes margins shrink things beyond imageable bounds.
	NSRect drawingBounds = NSMakeRect([printInfo leftMargin], [printInfo bottomMargin], 
									  paperSize.width - [printInfo leftMargin] - [printInfo rightMargin],
									  paperSize.height - [printInfo topMargin] - [printInfo bottomMargin]);
	SwitchListBaseView *printView = [[[view_ class] alloc] initWithFrame: drawingBounds
															withDocument: [view_ owningDocument]];
	[printView setTrain: [view_ train]];					
	
	NSPrintOperation *op = [NSPrintOperation printOperationWithView: printView
														  printInfo: printInfo];
	[op setShowsPrintPanel: YES];
	[[[NSDocument alloc] init] runModalPrintOperation: op delegate: nil didRunSelector: NULL 
										  contextInfo: NULL];
	[printView release];
}
@end
