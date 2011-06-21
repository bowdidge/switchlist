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

// How many table rows in the form?
int ROWS_PER_TABLE = 9;

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

// KaufmanSwitchListView generates one page per form.
- (BOOL)knowsPageRange:(NSRangePointer)range {
	int formCount = [[self stopsForForm] count];
    range->location = 1;
    range->length = formCount;
    return YES;
}

- (void) setTrain: (ScheduledTrain*) train {
	[super setTrain: train];
	NSSet *stopsForForm = [self stopsForForm];
	// Update our size now that we know how large the train is.
	[self setFrame: NSMakeRect(0, 0, [self pageWidth], [self pageHeight] * [stopsForForm count])];
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
					 centerY: startHeight-20
					 centerX: [self pageWidth] / 2
				  attributes: displayAttrs];

	[self drawCenteredString: @"Help Prevent Accidents"
					 centerY: startHeight-38
					 centerX: [self pageWidth] * 0.75
				  attributes: displayAttrs];
	
	[self drawCenteredString: @"Maintain Clearance"
					 centerY: startHeight-56
					 centerX: [self pageWidth] * 0.75
				  attributes: displayAttrs];
	
	NSFontManager *sharedFontManager = [NSFontManager sharedFontManager];
	NSFont *condensedSansSerif = [sharedFontManager convertFont: [NSFont fontWithName:@"Futura" size: 12.0] 
													toHaveTrait: NSCondensedFontMask | NSBoldFontMask];

	NSDictionary *strangeCapsAttr = [NSDictionary dictionaryWithObject: condensedSansSerif  forKey: NSFontAttributeName];
	[self drawCenteredString: @"SAN FRANCISCO PORT AUTHORITY"
					 centerY: startHeight-38
					 centerX: [self pageWidth] / 4
				  attributes: strangeCapsAttr];

	NSFont *tinyTimes = [NSFont fontWithName:@"Times Roman" size: 9.0];
	NSDictionary *tinyTimesAttr = [NSDictionary dictionaryWithObject: tinyTimes forKey: NSFontAttributeName];
	[self drawCenteredString: @"To the Superintendent:"
					 centerY: startHeight-56
					 centerX: [self pageWidth] / 4
				  attributes: tinyTimesAttr];

	tinyTimesAttr = [NSDictionary dictionaryWithObject: tinyTimes forKey: NSFontAttributeName];
	[self drawCenteredString: @"Please switch the following cars as indicated:"
					 centerY: startHeight-68
					 centerX: [self pageWidth] / 4
				  attributes: tinyTimesAttr];
	
	
	NSString *datedLine = @"Dated  ________________________  Signed _________________________ By ____________________";
	[self drawFormLine: datedLine centerX: [self pageWidth] / 2 centerY: startHeight-94
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
	
	[[train_ name] drawAtPoint: NSMakePoint(10.0, startHeight + [self pageHeight] - 20.0)
				withAttributes: [self smallTypeAttr]];

	[[NSColor blueColor] setStroke];
	NSMutableArray *dropOffCars = [NSMutableArray arrayWithArray: [train_ carsForStation: stationOfInterest]];
	NSMutableArray *pickUpCars = [NSMutableArray arrayWithArray: [train_ carsAtStation: stationOfInterest]];
	[pickUpCars sortUsingFunction: &sortFreightCarByIndustry context: 0];
	[dropOffCars sortUsingFunction: &sortFreightCarByDestinationIndustry
						   context: [owningDocument_ doorAssignmentRecorder]];
								
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
	NSFrameRect(NSMakeRect(0, startHeight+10, [self pageWidth], 3));

	int outCount = [dropOffCars count];
	int inCount = [pickUpCars count];
	
	// TODO(bowdidge): Should gracefully handle more cars than rows.
	if (outCount < ROWS_PER_TABLE) outCount = ROWS_PER_TABLE;
	if (inCount < ROWS_PER_TABLE) inCount = ROWS_PER_TABLE;
	
	NSDictionary *actionTitleAttrs = [NSDictionary dictionaryWithObject: [self titleFontForSize: 16]
																 forKey: NSFontAttributeName];
	
	NSString *takeOutLine = @"TAKE OUT from: ______________________________";
	[self drawFormLine: takeOutLine centerX: [self pageWidth] / 2 centerY: startHeight
			   strings: [NSArray arrayWithObjects: @"", [stationOfInterest name], nil]
		  printedAttrs: actionTitleAttrs];
	
	startHeight -= rowHeight_ * inCount + 40;
	
	[self drawTableForCars: pickUpCars
					  rect: NSMakeRect(0, startHeight, [self pageWidth], rowHeight_ * (inCount + 1))
					source: pickUpSource];

	// Draw line immediately under previous to give a simulated double line
	[[NSColor blackColor] setStroke];
	NSFrameRect(NSMakeRect(0, startHeight, [self pageWidth], 3));
	
	// Entertainment.
	int pickUpCarsCount = [pickUpCars count];
	if (pickUpCarsCount < 5 && pickUpCarsCount != 0) {
		[self drawHandwrittenString: @"(Ready at 11 a.m.)"
							centerX: [self pageWidth]/2
							centerY: startHeight + 0.2 * (rowHeight_ * outCount)
						 columnSize: [self pageHeight] / 2
				   handwrittenAttrs: [self handwritingFontAttr]];
	}
	
	startHeight -= 16;

	NSString *spotAtLine = @"SPOT at: ______________________________";
	[self drawFormLine: spotAtLine centerX: [self pageWidth] / 2 centerY: startHeight
			   strings: [NSArray arrayWithObjects: @"", [stationOfInterest name], nil]
		  printedAttrs: actionTitleAttrs];

	startHeight -= rowHeight_ * outCount + 40;
	[self drawTableForCars: dropOffCars
					  rect: NSMakeRect(0, startHeight, [self pageWidth], rowHeight_ * (outCount + 1))
					source: dropOffSource];
	
	// Draw line immediately under previous to give a simulated 
	[[NSColor blackColor] setStroke];
	NSFrameRect(NSMakeRect(0, startHeight, [self pageWidth], 3));

	// Entertainment.
	int dropOffCarsCount = [dropOffCars count];
	if (dropOffCarsCount < 5 && dropOffCarsCount != 0) {
		[self drawHandwrittenString: @"(Spot by 1 p.m.)"
							centerX: [self pageWidth] / 2
							centerY: startHeight + 0.2 * (rowHeight_ * outCount)
						 columnSize: [self pageWidth]/2
				   handwrittenAttrs: [self handwritingFontAttr]];
		
	}
	
	NSDictionary *tinyTitleAttrs = [NSDictionary dictionaryWithObject: [self titleFontForSize: 6]
																 forKey: NSFontAttributeName];
	NSString *formNumber = [NSString stringWithString: @"FORM B-7"];
	[formNumber drawInRect: NSMakeRect(18,18,100,40) withAttributes: tinyTitleAttrs];
}

- (void) drawRect:(NSRect)dirtyRect {
	[[NSColor whiteColor] setFill];
	// TODO(bowdidge): Only redraw the pages affected by the dirtyRect.
	NSRectFill([self bounds]);
	NSSet* stopsForForm = [self stopsForForm];
	
	// Drop the top by the margin boundary.
	float top = [self pageHeight] * [stopsForForm count];
	
	for (Place *stationOfInterest in stopsForForm) {
		[self drawOneForm: stationOfInterest startHeight: top];
		top -= [self pageHeight];
	}		
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
