//
//  KaufmanSwitchListView.m
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

#import "KaufmanSwitchListView.h"
#import "DoorAssignmentRecorder.h"
#import "EntireLayout.h"
#import "ScheduledTrain.h"

//  Pretty switchlist based on the San Francisco Belt Line's
//  Form B-7.  See Bill Kaufman's article on his use of these
//  forms in the July 2009 Railroad Model Craftsman magazine.

@interface KaufmanTakeOutSwitchListSource : SwitchListSource {
}

@end
@implementation KaufmanTakeOutSwitchListSource

- (int) columnCount {
	return 5;
}

- (float) widthForColumn: (int) column {
	float columnWidth[6] = {0.10, 0.24, 0.14, 0.35, 0.17};
	return columnWidth[column];
}

- (NSString*) headingForColumn: (int) column {
	switch (column) {
		case 0:
			return @"INITIAL";
		case 1: 
			return @"NUMBER";
		case 2:
			return @"LOADED";
		case 3:
			return @"DELIVER TO";
		case 4:
			return @"REMARKS";
	}
	return @"???";
}

// Returns true if this column allows squiggly lines to indicate "same as above"?
- (BOOL) columnAllowsContinuations: (int) column {
	return NO;
}

// Returns string value of particular cell of table.
- (NSString*) textForColumn: (int) column row: (int) row {
	FreightCar *fc = [carsInTrain_ objectAtIndex: row];
	DoorAssignmentRecorder *door = [owningDocument_ doorAssignmentRecorder];
	switch (column) {
		case 0:
			return [fc initials];
		case 1:
			return [fc number];
		case 2:
			return ([fc isLoaded] ? @"X" : @" ");
		case 3:
			return [[fc nextStop] name];
		case 4:
			if (!door) return @"";
			if ([door doorForCar:fc] == 0) return @"";
			return [NSString stringWithFormat: @"Door %d", [door doorForCar: fc]];

	}
	return @"???";
}
@end

@interface KaufmanPickUpSwitchListSource : SwitchListSource {
}

@end
@implementation KaufmanPickUpSwitchListSource

- (int) columnCount {
	return 5;
}

- (float) widthForColumn: (int) column {
	float columnWidth[5] = {0.10, 0.24, 0.14, 0.35, 0.17};
	return columnWidth[column];
}

- (NSString*) headingForColumn: (int) column {
	switch (column) {
		case 0:
			return @"INITIAL";
		case 1: 
			return @"NUMBER";
		case 2:
			return @"LOADED";
		case 3:
			return @"RECEIVED FROM";
		case 4:
			return @"REMARKS";
	}
	return @"???";
}

// Returns true if this column allows squiggly lines to indicate "same as above"?
- (BOOL) columnAllowsContinuations: (int) column {
	return NO;
}

// Returns string value of particular cell of table.
- (NSString*) textForColumn: (int) column row: (int) row {
	FreightCar *fc = [carsInTrain_ objectAtIndex: row];
	switch (column) {
		case 0:
			return [fc initials];
		case 1:
			return [fc number];
		case 2:
			return ([fc isLoaded] ? @"X" : @" ");
		case 3:
			return [[fc currentLocation] name];
		case 4:
		{
			NSArray *stationStops = [[owningDocument_ entireLayout] stationStopsForTrain: train_];
			Place *lastStation = [stationStops lastObject];
			if (([[fc nextStop] location] != lastStation) &&
				([[[fc nextStop] location] isOffline] == NO)) {
				return [NSString stringWithFormat: @"To %@", [[fc nextStop] name]];
			}
			return @"";
		}
	}
	return @"???";
	}
@end

@implementation KaufmanSwitchListView
- (id) initWithFrame: (NSRect) frameRect withDocument: (NSObject<SwitchListDocumentInterface>*) document {
	[super initWithFrame: frameRect withDocument: document];
	documentHeight_ = 720;
	pageWidth_ = 480;
	startY_ = 0;
	return self;
}


// Returns the list of stops that will require a form to be printed.
// Only stops that aren't the beginning and end and have traffic need forms.
- (NSSet*) stopsForForm {
	NSMutableSet *stops = [NSMutableSet set];
	NSArray *allStops = [[owningDocument_ entireLayout] stationStopsForTrain: train_];
	for (Place *stop in allStops) {
		if ([[train_ carsForStation: stop] count] != 0 ||
			[[train_ carsAtStation: stop] count] != 0) {
			[stops addObject: stop];
		}
	}
	[stops removeObject: [allStops objectAtIndex: 0]];
	[stops removeObject: [allStops lastObject]];
	
	return stops;
}

- (void) setTrain: (ScheduledTrain*) train {
	[super setTrain: train];
	NSSet *stopsForForm = [self stopsForForm];
	documentHeight_ = 720.0 * [stopsForForm count];
}

float HEADER_HEIGHT = 126.0;

// Draws the title portion of the switch list.
- (void) drawHeaderAtX: (float) startHeight {
	NSArray *date = [self getDateInStringFormat];
	NSString *dateString = [NSString stringWithFormat: @"%@ %@%@",
							[date objectAtIndex: 0], [date objectAtIndex: 2], [date objectAtIndex: 1]];
	
	// Start drawing the page.
	// Draw stuff in title.
	NSDictionary *displayAttrs = [NSDictionary dictionaryWithObject: [self titleFontForSize: 16]  forKey: NSFontAttributeName];
	[self drawCenteredString: @"SAFETY FIRST"
					 centerY: startY_ + startHeight-20
					 centerX: pageWidth_/2
				  attributes: displayAttrs];

	[self drawCenteredString: @"Help Prevent Accidents"
					 centerY: startY_ + startHeight-38
					 centerX: pageWidth_ * 0.75
				  attributes: displayAttrs];
	
	[self drawCenteredString: @"Maintain Clearance"
					 centerY: startY_ + startHeight-56
					 centerX: pageWidth_ * 0.75
				  attributes: displayAttrs];
	
	NSFontManager *sharedFontManager = [NSFontManager sharedFontManager];
	NSFont *condensedSansSerif = [sharedFontManager convertFont: [NSFont fontWithName:@"Futura" size: 12.0] 
													toHaveTrait: NSCondensedFontMask | NSBoldFontMask];

	NSDictionary *strangeCapsAttr = [NSDictionary dictionaryWithObject: condensedSansSerif  forKey: NSFontAttributeName];
	[self drawCenteredString: @"SAN FRANCISCO PORT AUTHORITY"
					 centerY: startY_ + startHeight-38
					 centerX: pageWidth_/4
				  attributes: strangeCapsAttr];

	NSFont *tinyTimes = [NSFont fontWithName:@"Times Roman" size: 9.0];
	NSDictionary *tinyTimesAttr = [NSDictionary dictionaryWithObject: tinyTimes forKey: NSFontAttributeName];
	[self drawCenteredString: @"To the Superintendent:"
					 centerY: startY_ + startHeight-56
					 centerX: pageWidth_/4
				  attributes: tinyTimesAttr];

	tinyTimesAttr = [NSDictionary dictionaryWithObject: tinyTimes forKey: NSFontAttributeName];
	[self drawCenteredString: @"Please switch the following cars as indicated:"
					 centerY: startY_ + startHeight-68
					 centerX: pageWidth_/4
				  attributes: tinyTimesAttr];
	
	
	NSString *datedLine = @"Dated  ________________________  Signed _________________________ By ____________________";
	[self drawFormLine: datedLine centerX: pageWidth_ / 2 centerY: startY_ + startHeight-94
			   strings: [NSArray arrayWithObjects: @"", dateString, @"", @"Del Monte Corp.", @"", [self randomFunctionary], nil]
		  printedAttrs: tinyTimesAttr];
}


int sortFreightCarByIndustry(const FreightCar *fc1, const FreightCar* fc2, void *context) {
	return [[[fc1 currentLocation] name] compare: [[fc2 currentLocation] name]];
}

int sortFreightCarByDestinationIndustry(const FreightCar *fc1, const FreightCar* fc2, void *context) {
	DoorAssignmentRecorder *recorder = (DoorAssignmentRecorder*) context;
	NSComparisonResult result = [[[fc1 nextStop] name] compare: [[fc2 nextStop] name]];
	if (result != NSOrderedSame) {
		return result;
	}
	int door1 = [recorder doorForCar: fc1];
	int door2 = [recorder doorForCar: fc2];
	return (door1 - door2);
}


- (void) drawOneForm: (Place*) stationOfInterest startHeight: (float) startHeight {		
	float tableWidth = pageWidth_ - documentMargin_*2;
	[[NSColor blueColor] setStroke];
	NSMutableArray *dropOffCars = [NSMutableArray arrayWithArray: [train_ carsForStation: stationOfInterest]];
	NSMutableArray *pickUpCars = [NSMutableArray arrayWithArray: [train_ carsAtStation: stationOfInterest]];
	[pickUpCars sortUsingFunction: &sortFreightCarByIndustry context: 0];
	[dropOffCars sortUsingFunction: &sortFreightCarByDestinationIndustry context: [owningDocument_ doorAssignmentRecorder]];
								
	[self drawHeaderAtX: startHeight];
	startHeight -= HEADER_HEIGHT;
	
	// TODO: Remove pickUp cars also in dropOff for this page.
	SwitchListSource *dropOffSource = [[[KaufmanTakeOutSwitchListSource alloc] initWithTrain: train_ 
																					withCars: dropOffCars
																			  owningDocument: owningDocument_] autorelease];
	SwitchListSource *pickUpSource = [[[KaufmanPickUpSwitchListSource alloc] initWithTrain: train_ 
																					withCars: pickUpCars
																			  owningDocument: owningDocument_] autorelease];
	// Draw line immediately under previous to give a simulated 
	[[NSColor blackColor] setStroke];
	NSFrameRect(NSMakeRect(0, startHeight+10, tableWidth, 3));

	int outCount = [dropOffCars count];
	int inCount = [pickUpCars count];
	
	if (outCount < 10) outCount = 10;
	if (inCount < 10) inCount = 10;
	
	NSDictionary *actionTitleAttrs = [NSDictionary dictionaryWithObject: [self titleFontForSize: 16]
																 forKey: NSFontAttributeName];
	
	NSString *takeOutLine = @"TAKE OUT from: ______________________________";
	[self drawFormLine: takeOutLine centerX: pageWidth_ / 2 centerY: startHeight
			   strings: [NSArray arrayWithObjects: @"", [stationOfInterest name], nil]
		  printedAttrs: actionTitleAttrs];
	
	startHeight -= rowHeight_ * inCount + 40;
	
	[self drawTableForCars: pickUpCars
					  rect: NSMakeRect(0, startHeight, tableWidth, rowHeight_ * (inCount + 1))
					source: pickUpSource];

	// Draw line immediately under previous to give a simulated double line
	[[NSColor blackColor] setStroke];
	NSFrameRect(NSMakeRect(0, startHeight, tableWidth, 3));
	
	// Entertainment.
	int pickUpCarsCount = [pickUpCars count];
	if (pickUpCarsCount < 5 && pickUpCarsCount != 0) {
		[self drawHandwrittenString: @"(Ready at 11 a.m.)"
							centerX: tableWidth/2
							centerY: startHeight + 0.2 * (rowHeight_ * outCount)
						 columnSize: tableWidth/2
				   handwrittenAttrs: [self handwritingFontAttr]];
	}
	

	startHeight -= 16;

	NSString *spotAtLine = @"SPOT at: ______________________________";
	[self drawFormLine: spotAtLine centerX: pageWidth_ / 2 centerY: startHeight
			   strings: [NSArray arrayWithObjects: @"", [stationOfInterest name], nil]
		  printedAttrs: actionTitleAttrs];

	startHeight -= rowHeight_ * outCount + 40;
	[self drawTableForCars: dropOffCars
					  rect: NSMakeRect(0, startHeight, tableWidth, rowHeight_ * (outCount + 1))
					source: dropOffSource];
	
	// Draw line immediately under previous to give a simulated 
	[[NSColor blackColor] setStroke];
	NSFrameRect(NSMakeRect(0, startHeight, tableWidth, 3));

	// Entertainment.
	int dropOffCarsCount = [dropOffCars count];
	if (dropOffCarsCount < 5 && dropOffCarsCount != 0) {
		[self drawHandwrittenString: @"(Spot by 1 p.m.)"
							centerX: tableWidth/2
							centerY: startHeight + 0.2 * (rowHeight_ * outCount)
						 columnSize: tableWidth/2
				   handwrittenAttrs: [self handwritingFontAttr]];
		
	}
	
	
	NSDictionary *tinyTitleAttrs = [NSDictionary dictionaryWithObject: [self titleFontForSize: 6]
																 forKey: NSFontAttributeName];
	NSString *formNumber = [NSString stringWithString: @"FORM B-7"];
	[formNumber drawInRect: NSMakeRect(18,18,100,40) withAttributes: tinyTitleAttrs];
}

- (void) drawRect:(NSRect)dirtyRect {
	[self setUpDocumentBounds];

	[[NSColor whiteColor] setFill];
	NSRectFill(dirtyRect);
	NSSet* stopsForForm = [self stopsForForm];
	
	// Drop the top by the margin boundary.
	float top = pageHeight_ * [stopsForForm count];
	
	for (Place *stationOfInterest in stopsForForm) {
		if (([[train_ carsForStation: stationOfInterest] count] == 0) &&
			([[train_ carsAtStation: stationOfInterest] count] == 0)) {
			continue;
		}
		[self drawOneForm: stationOfInterest startHeight: top];
		top -= pageHeight_;
	}		
}


// Height of entire document when printed.
- (float) preferredPrintHeight {
	return [[self stopsForForm] count] * [self printedPageHeight];
}

- (float) preferredPrintWidth {
	// Obtain the print info object for the current operation
	NSPrintInfo *printInfo = [[NSPrintOperation currentOperation] printInfo];
    // Convert height to the scaled view
    float scale = [[[printInfo dictionary] objectForKey:NSPrintScalingFactor] floatValue];
	return ([printInfo paperSize].width  - [printInfo leftMargin] - [printInfo rightMargin]) / scale;
}


- (float) preferredViewWidth {
//	return [self bounds].size.width;
	return 7.5 * 72.0;
}

- (float) preferredViewHeight {
	return 10 * 72.0 * [[self stopsForForm] count];
}


- (float) columnTitleFontSize {
	return 10;
}

- (NSDictionary*) columnTitleAttr {
	// Column titles.
	NSFont *columnTitleFont = [NSFont fontWithName: @"Times Bold" size: [self columnTitleFontSize]];
	NSMutableDictionary *columnTitleAttr = [NSMutableDictionary dictionary];
	[columnTitleAttr setValue: columnTitleFont forKey: NSFontAttributeName];
	return columnTitleAttr;
}

// Returns a font for title displays in the header.
- (NSFont*) titleFontForSize: (float) sz {
	// TODO(bowdidge) Get rid of Egyptian - it's not available on others' machines.
	NSFont *font = [NSFont fontWithName: @"Times Bold" size: sz];
	return font;
}

- (float) handwritingFontSize {
	return 14;
}

- (NSDictionary*) handwritingFontAttr {
	// TODO(bowdidge): Why the alternate font?  How much does the alternate font mess layout up?
	NSFont *handwritingFont =  [NSFont fontWithName: [self handwritingFontName] size: [self handwritingFontSize]];
	if (handwritingFont == nil) {
		handwritingFont = [NSFont fontWithName: @"Chalkboard" size: [self handwritingFontSize]];
	}
	
	// This uses a blue color and handwriting font.
	NSDictionary *handwritingFontAttr = [NSMutableDictionary dictionary];
	[handwritingFontAttr setValue: [self bluePenColor] forKey: NSForegroundColorAttributeName];
	[handwritingFontAttr setValue: handwritingFont forKey: NSFontAttributeName];
	return handwritingFontAttr;
}


@end
