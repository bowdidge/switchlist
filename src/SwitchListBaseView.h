//
//  SwitchListBaseView.h
//  SwitchList
//
//  Created by bowdidge on 2/3/11.
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

#import <Cocoa/Cocoa.h>

#import "FreightCar.h"
#import "SwitchListDocumentInterface.h"

// Model for switch list, hiding details of what's in the specific
// columns, number of rows, and how the text is generated.
// This should have presentation-independent stuff; presentation dependent stuff
// such as font choice goes in the *SwitchListView class.
@interface SwitchListSource : NSObject {
	NSArray *carsInTrain_;
	ScheduledTrain *train_;
	NSDocument<SwitchListDocumentInterface> *owningDocument_;
}
// Initializes a new source.  The cars list must be a subset of the cars on the train.
- (id) initWithTrain: (ScheduledTrain*) train 
			withCars: (NSArray*) cars
	  owningDocument: (NSDocument<SwitchListDocumentInterface>*) doc;
// How many columns are in this kind of switch list?
- (int) columnCount;
// How many pixels wide should the nth column be?
- (float) widthForColumn: (int) column;
// Returns the column heading for the named column.
- (NSString*) headingForColumn: (int) column;
// Returns the text value of the specified cell of the table.
- (NSString*) textForColumn: (int) column row: (int) row;
// Return the name of the next industry/town pair.
- (NSString *) destStringForFreightCar: (FreightCar *) freightCar;

@end

// Class representing a pretty switchlist view.  This handles all the presentation issues
// including printing.
@interface SwitchListBaseView : NSView {
	NSDocument<SwitchListDocumentInterface> *owningDocument_;
	ScheduledTrain *train_;
	NSArray *carsInTrain_;

	// Height of individual rows in switchlist table drawn by -[SwitchListBaseView drawTableForCars:rect:source]
	float rowHeight_;
	
	// Size of a single page with the current print settings.  This is the source of truth for
	// all drawing decisions, and represents the size of the paper inside the default margins.
	float imageableWidth_;
	float imageableHeight_;

	// Each document gets a random number exactly once so values don't change per redraw.
	long randomValue_;
    NSArray *optionalSettings_;

    // Font to use for handwritten parts of forms.
    NSString *handwritingFontName_;
}

// Initial frame size indicates the initial page size.
- (id) initWithFrame: (NSRect) frameRect withDocument: (NSDocument<SwitchListDocumentInterface>*) document;
- (void) setTrain: (ScheduledTrain*) train;
- (ScheduledTrain*) train;

- (NSDocument<SwitchListDocumentInterface>*) owningDocument;

// Page height in bounds coordinates.
- (float) imageableHeight;
// Page width in bounds coordinates.
- (float) imageableWidth;

// Recalculates the appropriate switch list report size whenever either the contents (the train) or the
// size of the paper changes.  To be overridden by subclass.
- (void) recalculateFrame;

// 
// Preferred font drawing attributes for this view.
//

- (NSFont*) titleFontForSize: (float) sz;
- (NSDictionary*) handwritingFontAttr;
- (NSDictionary*) handwritingFontAttrForSize: (float) size;
- (NSDictionary*) columnTitleAttr;

// Font attributes available to all.
// Small, faint type used for train name.
- (NSDictionary*) smallTypeAttr;
- (NSColor*) bluePenColor;
// Can be overridden by defaults setting.
- (NSString*) handwritingFontName;

// Gray in header?
- (BOOL) useGrayBlock;


//
// Helpful drawing routines for subclasses.
//

// Draws the named string in a box centered at the specified location with the specified width.
- (void) drawCenteredString: (NSString *) str centerY: (float) centerY centerX: (float) centerPos attributes: attrs;

// Draws the named string at the given location, but jitters the location so columns look handwritten.
// Sequence number is some derivative of object which always returns the same value, and avoids movement when window
// is resized.
- (void) drawJitteryString: (NSString *) str
				   centerX: (float) centerX
				   centerY: (float) centerY
				columnSize: (float) columnSize
					 attrs: (id) attrs
				  sequence: (int) sequenceNumber;


// Given a string to handwrite and a form line that was drawn at the provided location,
// place the handwritten string over the nth component.
// Components are blocks of characters that are either all dashes or all not, numbered from zero.
- (void) handwriteString: (NSString*) handString
		  inNthComponent: (int) componentIndex
				ofString: (NSString*) templateString
				 centerY: (float) centerY
				 centerX: (float) centerX
				   attrs: (NSDictionary*) attrs;

// Draws a handwritten string in the named location, fitting the string to the specified column size.
- (void) drawHandwrittenString: (NSString *) str
					   centerX: (float) centerX
					   centerY: (float) centerY
					columnSize: (float) columnSize
			  handwrittenAttrs: (NSDictionary*) attrs;

// Draws a form line with specified handwritten strings to appear over fields.
// strings array corresponds to each non-dash/dash component of formLine; use @"" to indicate
// no handwritten string belongs at the field.
- (void) drawFormLine: (NSString*) formLine centerX: (long) centerX centerY: (long) centerY strings: (NSArray*) strings
		 printedAttrs: (NSDictionary*) printedAttrs;

// Draws the train's name faintly in the upper right.
- (void) drawTrainNameWithOffset: (float) offsetY;

// Returns current layout date in an array with three elements: month/day, 2 digit year, and 2 digit century.
- (NSArray*) getDateInStringFormat;

// Draws the car table with the given cars at the given location.
- (void) drawTableForCars: (NSArray*) carsToDisplay rect: (NSRect) rect source: (SwitchListSource*) source;

// Returns a random name for signatures.
// Seed used to generate different names per document.
- (NSString*) randomFunctionary: (int) seed;

// Testing only.
- (NSArray*) splitStringByDashes: (NSString*) input;

// Set the optional settings as a list of pairs of (setting, custom value.
- (void) setOptionalSettings: (NSArray*) optionalSettings;
// Returns the setting with the specified name, or alternate if no such value exists.
- (NSString*) optionWithName: (NSString*) optionName alternate: (NSString*) alternate;

@end
