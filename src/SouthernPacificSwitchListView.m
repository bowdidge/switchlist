//
//  SouthernPacificSwitchList.m
//  SwitchList
//
//  Created by bowdidge on 2/8/11.
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

#import "SouthernPacificSwitchListView.h"

#import "CarType.h"
#import "DoorAssignmentRecorder.h"
#import "EntireLayout.h"

// "Pretty" switchlist imitating the SP-style switchlist shown by Bill Kaufman in his
// article on the San Francisco Belt Railway, Railroad Model Craftsman, July 2009.

@implementation SouthernPacificSwitchListSource

- (int) columnCount {
	return 6;
}

- (float) widthForColumn: (int) column {
	float columnWidth[6] = {0.12, 0.13, 0.03, 0.18, 0.30, 0.23};
	return columnWidth[column];
}

- (NSString*) headingForColumn: (int) column {
	switch (column) {
		case 0:
			return @"Initial";
		case 1:
			return @"No";
		case 2:
			return @"Ld";
		case 3:
			return @"Contents";
		case 4: 
			return @"To";
		case 5:
			return @"Origin";
	}
	return @"???";
}

// Allow squiggly lines for the TO and ORIGIN columns.
- (BOOL) columnAllowsContinuations: (int) column {
	switch(column) {
	case 4:
	case 5:
		return YES;
	}
	return NO;
}


- (NSString*) textForColumn: (int) column row: (int) row {
	FreightCar *fc = [carsInTrain_ objectAtIndex: row];
	switch (column) {
		case 0:
			return [fc initials];
		case 1:
			return [fc number];
		case 2:
			return [fc isLoaded] ? @"X" : @" ";
		case 3:
			return ([fc isLoaded] ? [[fc cargo] cargoDescription] : @"—");
		case 4:
			return [fc destinationIndustryString];
		case 5:
			return [fc sourceIndustryString];
	}
	return @"???";
}
@end

@implementation SouthernPacificSwitchListView
- (id) initWithFrame: (NSRect) frameRect withDocument: (NSObject<SwitchListDocumentInterface>*) document {
	[super initWithFrame: frameRect withDocument: document];
	headerHeight_ = 80;
	[self setBounds: NSMakeRect(0, 0, PAGE_WIDTH, PAGE_HEIGHT)];
	return self;
}

- (float) handwritingFontSize {
	if ([NSGraphicsContext currentContextDrawingToScreen]) {
		return 11;
	} 
	return 11;
}

- (float) columnTitleFontSize {
	if ([NSGraphicsContext currentContextDrawingToScreen]) {
		return 9;
	}
	return 9;
}

- (float) headerTextFontSize {
	if ([NSGraphicsContext currentContextDrawingToScreen]) {
		return 11;
	}
	return 11;
}

- (float) headerTitleFontSize {
	if ([NSGraphicsContext currentContextDrawingToScreen]) {
		return 14;
	}
	return 14;
}

- (void) setTrain: (ScheduledTrain*) train {
	[super setTrain: train];
	// TODO(bowdidge): Print multiple pages if too many cars.
	[self setBounds: NSMakeRect(0, 0, PAGE_WIDTH, PAGE_HEIGHT)];
}

// Return the number of pages available for printing
// Required for printing support.
- (BOOL)knowsPageRange:(NSRangePointer)range {
    range->location = 1;
    range->length = 1;
    return YES;
}

// Draws the title portion of the switch list.
// General format:
//    SOUTHERN PACIFIC LINES
//         SWITCH LIST
// Train:  ____  Left _______M _______, 19__
// Engine: ____  Arrd _______M _______, 19__

- (void) drawHeader {
	
	float topOfHeader = [self bounds].size.height - 8;
	NSArray *date = [self getDateInStringFormat];
	NSString *dateString = [date objectAtIndex: 0];
	NSString *yearString = [date objectAtIndex: 1];
	NSString *centuryString = [date objectAtIndex: 2];
	
	// Draw stuff in title.
	NSDictionary *title1Attrs = [NSDictionary dictionaryWithObject: [self titleFontForSize: [self headerTextFontSize]]  forKey: NSFontAttributeName];
	NSDictionary *title2Attrs = [NSDictionary dictionaryWithObject: [self titleFontForSize: [self headerTitleFontSize]]  forKey: NSFontAttributeName];
	
	[self drawCenteredString: [[owningDocument_ entireLayout] layoutName] centerY: topOfHeader centerX: PAGE_WIDTH/2 attributes: title1Attrs];
	[self drawCenteredString: @"SWITCH LIST" centerY: topOfHeader - 20 centerX: PAGE_WIDTH/2  attributes: title2Attrs];
	
	NSString *line1 = [NSString stringWithFormat: @"Train _________ Left _________________ station, __________M _______________ %@____", centuryString];
	float line1CenterY = topOfHeader - 36;
	float line1CenterX = PAGE_WIDTH / 2;
	NSString *line2 = [NSString stringWithFormat: @"Engine ________ Arrd _________________ station, __________M _______________ %@____", centuryString];
	float line2CenterY = topOfHeader - 50;
	float line2CenterX = PAGE_WIDTH / 2;
	
	[self drawFormLine: line1 centerX: line1CenterX centerY: line1CenterY
			   strings: [NSArray arrayWithObjects: @"",@"", @"", @"", @"", @"", @"", dateString, @"", yearString, nil]
		  printedAttrs: title1Attrs];

	[self drawFormLine: line2 centerX: line2CenterX centerY: line2CenterY
			   strings: [NSArray arrayWithObjects: @"",@"", @"", @"", @"", @"", @"", dateString, @"", yearString, nil]
		  printedAttrs: title1Attrs];

	[self drawTrainName];
}

// Main drawing routine, called for printing or screen redraw.
- (void) drawRect: (NSRect) rect {
	float documentWidth = 400;
	float documentHeight = [self bounds].size.height;
	[[NSColor whiteColor] setFill];
	NSRectFill(NSMakeRect(0, 0, documentWidth, documentHeight));
	
	[[self canaryYellowColor] setFill];
	// Draw whole thing in yellow - rect alone isn't enough for printing.
	NSRectFill(NSMakeRect((PAGE_WIDTH - documentWidth)/2, 0, documentWidth, documentHeight));

	float tableWidth = documentWidth;
	float tableHeight =  floor((documentHeight - headerHeight_) / rowHeight_) * rowHeight_;
	float tableBottom = 0;
	float tableLeft = (PAGE_WIDTH - documentWidth) / 2;
			   
	[self drawHeader];
	[self drawTableForCars: carsInTrain_
					  rect: NSMakeRect(tableLeft, tableBottom, tableWidth, tableHeight)
					source: [[[SouthernPacificSwitchListSource alloc] initWithTrain: train_
																		   withCars: carsInTrain_
																	 owningDocument: owningDocument_] autorelease]];
}

- (NSColor *) canaryYellowColor {
	return [NSColor colorWithCalibratedRed: 1.0 green:0.98 blue:0.75 alpha:1.0];
}

- (NSDictionary*) columnTitleAttr {
	// Column titles.
	NSFont *columnTitleFont = [NSFont fontWithName: @"Arial Narrow" size: [self columnTitleFontSize]];
	NSMutableDictionary *columnTitleAttr = [NSMutableDictionary dictionary];
	[columnTitleAttr setValue: columnTitleFont forKey: NSFontAttributeName];
	return columnTitleAttr;
}

@end
