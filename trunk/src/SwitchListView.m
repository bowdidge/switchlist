//
//  SwitchListView.m
//  SwitchListView
//
//  Created by Robert Bowdidge on 2/23/08.
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

#import "SwitchListView.h"

#import "CarType.h"
#import "DoorAssignmentRecorder.h"
#import "EntireLayout.h"
#import "FreightCar.h"
#import "SwitchListDocumentInterface.h"


@interface LargePrintSwitchListSource : SwitchListSource {
}

@end
@implementation LargePrintSwitchListSource

- (int) columnCount {
	return 4;
}

- (float) widthForColumn: (int) column {
	float columnWidth[4] = {0.20, 0.10, 0.35, 0.35};
	return columnWidth[column];
}

- (NSString*) headingForColumn: (int) column {
	switch (column) {
		case 0:
			return @"Car no.";
		case 1: 
			return @"Type";
		case 2:
			return @"From";
		case 3:
			return @"To";
	}
	return @"???";
}

// Returns true if this column allows squiggly lines to indicate "same as above"?
- (BOOL) columnAllowsContinuations: (int) column {
	return (column == 2) || (column == 3);
}

// Returns string value of particular cell of table.
- (NSString*) textForColumn: (int) column row: (int) row {
	FreightCar *fc = [carsInTrain_ objectAtIndex: row];
	switch (column) {
		case 0:
			return [fc reportingMarks];
		case 1:
			return [[fc carTypeRel] carTypeName];
		case 2:
			return [fc sourceString];
		case 3:
			return [self destStringForFreightCar: fc];
	}
	return @"???";
}
@end

// Class for drawing "pretty" switch lists that imitate the real thing.
// Switch list report format borrowed from Jack Burgess's YV switch lists.
// 
// Do what's needed to make this look like a real form.  Use handwriting fonts, adjust positions
// of each entry so they look random, etc.


@implementation SwitchListView
- (id) initWithFrame: (NSRect) frameRect withDocument: (NSObject<SwitchListDocumentInterface>*) document {
	[super initWithFrame: frameRect withDocument: document];
	headerHeight_ = 60;
	return self;
} 

// Draws the title portion of the switch list.
- (void) drawHeader {
	NSArray *date = [self getDateInStringFormat];
	NSString *dateString = [date objectAtIndex: 0];
	NSString *yearString = [date objectAtIndex: 1];
	NSString *centuryString = [date objectAtIndex: 2];
	
	float documentHeight = documentBounds_.size.height;
	// Draw stuff in title.
	NSDictionary *title1Attrs = [NSDictionary dictionaryWithObject: [self titleFontForSize: 12]  forKey: NSFontAttributeName];
	[self drawCenteredString: [[owningDocument_ entireLayout] layoutName] centerY: documentHeight - 8 centerX: documentBounds_.size.width/2 attributes: title1Attrs];
	
	NSDictionary *title2Attrs = [NSDictionary dictionaryWithObject: [self titleFontForSize: 24]  forKey: NSFontAttributeName];
	[self drawCenteredString: @"SWITCH LIST" centerY: documentHeight - 24 centerX: documentBounds_.size.width/2  attributes: title2Attrs];
	
	NSDictionary *title3Attrs = [NSDictionary dictionaryWithObject: [self titleFontForSize: 14]  forKey: NSFontAttributeName];
	
	// Next, draw the location/date string, and handwrite in the year and date.
	float locationStringCenterY = documentHeight - 50;
	float locationStringCenterX = documentBounds_.size.width / 2;
	NSString *locationDateString = [NSString stringWithFormat: @"______________ at ____________________ station, ___________________ %@____",
									centuryString];
	
	// TODO(bowdidge): Change this to size to the field. 
	NSString *firstTownString = @"";
	// NSString *firstTownString = [[train_ stationStopStrings] objectAtIndex: 0];
	[self drawFormLine: locationDateString centerX: locationStringCenterX centerY: locationStringCenterY
			   strings: [NSArray arrayWithObjects: @"", @"", firstTownString, @"", dateString, @"", yearString, nil]
		  printedAttrs: title3Attrs];

	[self drawTrainNameAtStart: 0];
}

// Main drawing routine, called for printing or screen redraw.
- (void) drawRect: (NSRect) rect {
	float documentHeight = documentBounds_.size.height;
	[[NSColor whiteColor] setFill];
	// Draw whole thing in white to make sure the preview window is empty.
	NSRectFill([self bounds]);
	
	float tableWidth = documentBounds_.size.width;
	float tableHeight =  floor((documentHeight - headerHeight_) / rowHeight_) * rowHeight_;
	float tableBottom = 0;
	float tableLeft = 0;

	[self drawHeader];
	[self drawTableForCars: carsInTrain_
					  rect: NSMakeRect(tableLeft, tableBottom, tableWidth, tableHeight)
					source: [[[LargePrintSwitchListSource alloc] initWithTrain: train_
																	  withCars: carsInTrain_ 
																owningDocument: owningDocument_] autorelease]];
}

- (NSDictionary*) columnTitleAttr {
	// Column titles.
	NSFont *columnTitleFont = [NSFont fontWithName: @"Copperplate" size: 12];
	NSMutableDictionary *columnTitleAttr = [NSMutableDictionary dictionary];
	[columnTitleAttr setValue: columnTitleFont forKey: NSFontAttributeName];
	return columnTitleAttr;
}

// Gray in header?
- (BOOL) useGrayBlock {
	return YES;
}
@end
