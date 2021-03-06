//
//  PrintEverythingView.h
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

#import <Cocoa/Cocoa.h>

#import "SwitchListDocumentInterface.h"

// Class for printing all needed switchlists at one time.

@class SwitchListDocument;

@interface PrintEverythingView : NSView {
	// SwitchListBaseViews for each train switch list.
	NSMutableArray *subviews;
	NSObject<SwitchListDocumentInterface> *document_;
	float imageableWidth_;
	float imageableHeight_;
    NSArray *optionalSettings_;
}

// Creates a SwitchListBaseView with a default frame (only provided by convention), a pointer to the
// document holding the layout, and the class of the SwitchListBaseView subclass that should be
// used to generate the switchlist for each train.
- (id) initWithFrame: (NSRect) r withDocument: (NSDocument<SwitchListDocumentInterface>*) document
	   withViewClass: (Class) preferredViewClass;
// Set the optional settings as a list of pairs of (setting, custom value.
- (void) setOptionalSettings: (NSArray*) optionalSettings;
// Returns the setting with the specified name, or alternate if no such value exists.
- (NSString*) optionWithName: (NSString*) optionName alternate: (NSString*) alternate;
@end
