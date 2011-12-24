//
//  Report.h
//  SwitchList
//
//  Created by Robert Bowdidge on 12/14/05.
//
// Copyright (c)2005, Robert Bowdidge
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

#import <Cocoa/Cocoa.h>
@class EntireLayout;
@class FreightCar;
@protocol SwitchListDocumentInterface;

// Class for managing a report window.
// Each report has a similar form:
// A set of managed objects to display
// a method for displaying the objects.
// 
// This class has the generic stuff for managing the window; each
// report should have its own subclass inheriting from this.

@interface Report : NSObject {
	IBOutlet NSWindow *reportWindow_;
	IBOutlet NSTextView *reportTextView_;
	IBOutlet NSScrollView *scrollView_;
	NSArray *objectsToDisplay_;
	NSDocument<SwitchListDocumentInterface> *owningDocument_;
	NSFont *typedFont_;
}
- (id) initWithDocument: (NSDocument<SwitchListDocumentInterface>*) document;
// do work display window
- (void) generateReport;
/* Note that some reports may define the objects to be something else like an NSDictionary. */
- (void) setObjects: (NSArray*) objects;

// string representing contents of report -- override to produce output.
- (NSString*) contents;
// Generates the header / first few lines of the report.  Override for customization.
- (NSString*) headerString;
// Returns the kind of report being generated.  Override.
- (NSString *) typeString;

// Helpers:
// Returns the number of characters that can be displayed on a single line with the current font.
- (int) lineLength;
// Returns a string with the provided string, padded with leading spaces to be centered in the current window.
- (NSString*) centeredString: (NSString*) str;
		
- (NSString *) nextDestinationForFreightCar: (FreightCar *) freightCar;
// Returns EntireLayout object for current document.
- (EntireLayout *) entireLayout;
// Returns preferred typed font, either from preferences or default choice.
- (NSFont*) typedFont;

- (IBAction)printDocument:(id)sender;

- (NSDocument<SwitchListDocumentInterface>*) owningDocument;

// Internal
// Returns the current fixed width font to use for all reports.
- (NSFont*) defaultTypedFont;

// Returns the current layout's name.
- (NSString*) layoutName;

// Return the date of the operating session.
- (NSString*) currentDate;
	
// For testing only.
- (void) setReportTextView: (id) reportTextView;
- (void) setTypedFont: (id) typedFont;

// Given report text, convert to two column.
- (NSString*) convertToTwoColumn: (NSString*) contents;


		 
@end
