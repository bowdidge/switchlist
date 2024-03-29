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
#import "EntireLayout.h"
#include "InduYard.h"
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
    int door = [fc nextDoor];
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
			if ([fc nextDoor] == 0) return @"";
			return [NSString stringWithFormat: @"Door %d", [fc nextDoor]];

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
			NSArray *stationStops = [train_ stationsInOrder];
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
int ROWS_PER_TABLE = 8;

// Returns the list of stops that will require a form to be printed.
// Only stops that aren't the beginning and end and have traffic need forms.
- (NSSet*) stopsForForm {
	NSMutableSet *stops = [NSMutableSet set];
	NSArray *allStops = [train_ stationsInOrder];
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

- (void) recalculateFrame {
	// Frame should be multiple of imageableHeight.
	NSUInteger formCount = [[self stopsForForm] count];
	NSRect currentFrame = [self frame];
	[self setFrame: NSMakeRect(currentFrame.origin.x, currentFrame.origin.y,
							   currentFrame.size.width, formCount * [self imageableHeight])];
}

float HEADER_HEIGHT = 126.0;

// Draws the title portion of the switch list.
- (void) drawHeaderAtOffset: (float) startHeight {
	NSArray *date = [self getDateInStringFormat];
	NSString *dateString = [NSString stringWithFormat: @"%@ %@%@",
							[date objectAtIndex: 0], [date objectAtIndex: 2], [date objectAtIndex: 1]];
	
	// Start drawing the page.
	// Draw stuff in title.
	NSDictionary *displayAttrs = [NSDictionary dictionaryWithObject: [self titleFontForSize: 16]  forKey: NSFontAttributeName];
	[self drawCenteredString: @"SAFETY FIRST"
					 centerY: startHeight-20
					 centerX: [self imageableWidth] / 2
				  attributes: displayAttrs];

	[self drawCenteredString: @"Help Prevent Accidents"
					 centerY: startHeight-38
					 centerX: [self imageableWidth] * 0.75
				  attributes: displayAttrs];
	
	[self drawCenteredString: @"Maintain Clearance"
					 centerY: startHeight-56
					 centerX: [self imageableWidth] * 0.75
				  attributes: displayAttrs];
	
	NSFontManager *sharedFontManager = [NSFontManager sharedFontManager];
	NSFont *condensedSansSerif = [sharedFontManager convertFont: [NSFont fontWithName:@"Futura" size: 12.0] 
													toHaveTrait: NSCondensedFontMask | NSBoldFontMask];

    NSString* railroadName1 = [self optionWithName: @"Railroad_Name_1" alternate: @"SAN FRANCISCO PORT AUTHORITY"];
	NSDictionary *strangeCapsAttr = [NSDictionary dictionaryWithObject: condensedSansSerif  forKey: NSFontAttributeName];
	[self drawCenteredString: railroadName1
					 centerY: startHeight-38
					 centerX: [self imageableWidth] / 4
				  attributes: strangeCapsAttr];

	NSFont *tinyTimes = [NSFont fontWithName:@"Times Roman" size: 9.0];
	NSDictionary *tinyTimesAttr = [NSDictionary dictionaryWithObject: tinyTimes forKey: NSFontAttributeName];
	[self drawCenteredString: @"To the Superintendent:"
					 centerY: startHeight-56
					 centerX: [self imageableWidth] / 4
				  attributes: tinyTimesAttr];

	tinyTimesAttr = [NSDictionary dictionaryWithObject: tinyTimes forKey: NSFontAttributeName];
	[self drawCenteredString: @"Please switch the following cars as indicated:"
					 centerY: startHeight-68
					 centerX: [self imageableWidth] / 4
				  attributes: tinyTimesAttr];
	
	
	NSString *datedLine = @"Dated  ________________________  Signed _________________________ By ____________________";
	[self drawFormLine: datedLine centerX: [self imageableWidth] / 2 centerY: startHeight-94
			   strings: [NSArray arrayWithObjects: @"", dateString, @"", @"", @"", [self randomFunctionary: startHeight], nil]
		  printedAttrs: tinyTimesAttr];
}

NSInteger sortFreightCarByIndustry(const FreightCar *fc1, const FreightCar* fc2, void *context) {
	return [[[fc1 currentLocation] name] compare: [[fc2 currentLocation] name]];
}

NSInteger sortFreightCarByDestinationIndustry(const FreightCar *fc1, const FreightCar* fc2, void *context) {
	NSComparisonResult result = [[[fc1 nextStop] name] compare: [[fc2 nextStop] name]];
	if (result != NSOrderedSame) {
		return result;
	}
	int door1 = [fc1 nextDoor];
	int door2 = [fc2 nextDoor];
	return (door1 - door2);
}

- (void) drawOneForm: (Place*) stationOfInterest startHeight: (float) startHeight {	
	
	[[train_ name] drawAtPoint: NSMakePoint(10.0, startHeight + [self imageableHeight] - 20.0)
				withAttributes: [self smallTypeAttr]];

	[[NSColor blueColor] setStroke];
	NSMutableArray *dropOffCars = [NSMutableArray arrayWithArray: [train_ carsForStation: stationOfInterest]];
	NSMutableArray *pickUpCars = [NSMutableArray arrayWithArray: [train_ carsAtStation: stationOfInterest]];
	[pickUpCars sortUsingFunction: &sortFreightCarByIndustry context: 0];
	[dropOffCars sortUsingFunction: &sortFreightCarByDestinationIndustry  context: 0];
								
	[self drawHeaderAtOffset: startHeight];
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
	NSFrameRect(NSMakeRect(0, startHeight+10, [self imageableWidth], 3));

	NSUInteger outCount = [dropOffCars count];
    NSUInteger inCount = [pickUpCars count];
	
	// TODO(bowdidge): Should gracefully handle more cars than rows.
	// TODO(bowdidge): Should gracefully handle more cars than space on page.
	if (outCount < ROWS_PER_TABLE) outCount = ROWS_PER_TABLE;
	if (inCount < ROWS_PER_TABLE) inCount = ROWS_PER_TABLE;
	
	NSDictionary *actionTitleAttrs = [NSDictionary dictionaryWithObject: [self titleFontForSize: 16]
																 forKey: NSFontAttributeName];
	
	NSString *takeOutLine = @"TAKE OUT from: ______________________________";
	[self drawFormLine: takeOutLine centerX: [self imageableWidth] / 2 centerY: startHeight
			   strings: [NSArray arrayWithObjects: @"", [stationOfInterest name], nil]
		  printedAttrs: actionTitleAttrs];
	
	startHeight -= rowHeight_ * inCount + 40;
	
	// TODO(bowdidge): Need to size rectangles based on size of sheet.
	[self drawTableForCars: pickUpCars
					  rect: NSMakeRect(0, startHeight, [self imageableWidth], rowHeight_ * (inCount + 1))
					source: pickUpSource];

	// Draw line immediately under previous to give a simulated double line
	[[NSColor blackColor] setStroke];
	NSFrameRect(NSMakeRect(0, startHeight, [self imageableWidth], 3));
	
	// Entertainment.
    NSUInteger pickUpCarsCount = [pickUpCars count];
	if (pickUpCarsCount < 5 && pickUpCarsCount != 0) {
		[self drawHandwrittenString: @"(Ready at 11 a.m.)"
							centerX: [self imageableWidth]/2
							centerY: startHeight + 0.2 * (rowHeight_ * outCount)
						 columnSize: [self imageableHeight] / 2
				   handwrittenAttrs: [self handwritingFontAttr]];
	}
	
	startHeight -= 16;

	NSString *spotAtLine = @"SPOT at: ______________________________";
	[self drawFormLine: spotAtLine centerX: [self imageableWidth] / 2 centerY: startHeight
			   strings: [NSArray arrayWithObjects: @"", [stationOfInterest name], nil]
		  printedAttrs: actionTitleAttrs];

	startHeight -= rowHeight_ * outCount + 40;
	[self drawTableForCars: dropOffCars
					  rect: NSMakeRect(0, startHeight, [self imageableWidth], rowHeight_ * (outCount + 1))
					source: dropOffSource];
	
	// Draw line immediately under previous to give a simulated 
	[[NSColor blackColor] setStroke];
	NSFrameRect(NSMakeRect(0, startHeight, [self imageableWidth], 3));

	// Entertainment.
    NSUInteger dropOffCarsCount = [dropOffCars count];
	if (dropOffCarsCount < 5 && dropOffCarsCount != 0) {
		[self drawHandwrittenString: @"(Spot by 1 p.m.)"
							centerX: [self imageableWidth] / 2
							centerY: startHeight + 0.2 * (rowHeight_ * outCount)
						 columnSize: [self imageableWidth]/2
				   handwrittenAttrs: [self handwritingFontAttr]];
		
	}
	
	NSDictionary *tinyTitleAttrs = [NSDictionary dictionaryWithObject: [self titleFontForSize: 6]
																 forKey: NSFontAttributeName];
	NSString *formNumber = @"FORM B-7";
	[formNumber drawInRect: NSMakeRect(18,18,100,40) withAttributes: tinyTitleAttrs];
}

- (void) drawRect:(NSRect)dirtyRect {
	[[NSColor whiteColor] setFill];
	// TODO(bowdidge): Only redraw the pages affected by the dirtyRect.
	NSRectFill([self bounds]);
	NSSet* stopsForForm = [self stopsForForm];
	
	// Drop the top by the margin boundary.
	float top = [self imageableHeight] * [stopsForForm count];
	
	for (Place *stationOfInterest in stopsForForm) {
		[self drawOneForm: stationOfInterest startHeight: top];
		top -= [self imageableHeight];
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

@end
