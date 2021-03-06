//
//  SwitchListWindowController.h
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

#import <Cocoa/Cocoa.h>
#import "SwitchListDocumentInterface.h"

@class SwitchListBaseView;
@class SwitchListDocument;

//  Controller for managing pretty switchlist windows.
//  This controller is responsible for the creation of the
//  window, the loading of the nib file, and receiving actions
//  such as the print request.

@interface SwitchListReportWindowController : NSWindowController<NSWindowDelegate> {
	// View wrapping SwitchList so we can add margins to it for screen display.
	// Unneeded when printing.
	NSView *marginView_;
	// Actual view.
	IBOutlet SwitchListBaseView *view_;
    IBOutlet NSScrollView *scrollView_;
	SwitchListDocument *owningDocument_;
}

- (id) initWithWindowNibName: (NSString*) nibName withView: (NSView*) v withDocument: (SwitchListDocument*) owningDocument;
- (IBAction) printDocument: (id) sender;
@end
