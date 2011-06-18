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

// Size of window on SwitchListReportWindow.
float FRAME_WIDTH = 640.0;
float FRAME_HEIGHT = 748.0;

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
	// Use a white background so resizing the window doesn't show unseemly gray bands.
	[scrollView_ setBackgroundColor: [NSColor whiteColor]];
	[scrollView_ setDrawsBackground: YES];
	[scrollView_ setDocumentView: view_];
	// TODO(bowdidge): Should scroll view to top here.
}

- (IBAction) printDocument: (id) sender {
	// set printing properties
	NSPrintInfo *myPrintInfo = [[NSPrintInfo sharedPrintInfo] copy];
	[myPrintInfo setHorizontalPagination:NSFitPagination];
	[myPrintInfo setHorizontallyCentered:NO];
	[myPrintInfo setVerticallyCentered:NO];
	[myPrintInfo setLeftMargin:36.0];
	[myPrintInfo setRightMargin:36.0];
	[myPrintInfo setTopMargin:36.0];
	[myPrintInfo setBottomMargin:36.0];
	
	// create new view just for printing
	float pageWidth = [myPrintInfo paperSize].width - [myPrintInfo leftMargin] - [myPrintInfo rightMargin];
	float pageHeight = [myPrintInfo paperSize].height - [myPrintInfo topMargin] - [myPrintInfo bottomMargin];
	SwitchListBaseView *printView = [[[view_ class] alloc] initWithFrame: NSMakeRect(0.0, 0.0, pageWidth, pageHeight)
															withDocument: [view_ owningDocument]];
	[printView setTrain: [view_ train]];					
								
	NSPrintOperation *op = [NSPrintOperation printOperationWithView: printView
														  printInfo: myPrintInfo];
	[op setShowsPrintPanel: YES];
	[[[NSDocument alloc] init] runModalPrintOperation: op delegate: nil didRunSelector: NULL 
										  contextInfo: NULL];

	[printView release];
}
@end
