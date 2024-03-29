//
//  SwitchListBaseView.m
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

#import "SwitchListBaseView.h"

#import "CarType.h"
#import "EntireLayout.h"
#import "FreightCar.h"
#import "GlobalPreferences.h"
#import "Industry.h"
#import "Place.h"
#import "ScheduledTrain.h"

@implementation SwitchListSource
// Creates a new SwitchListSource that will display information on the named cars in the given
// train.  The list of cars can be a subset of the train if not all are to be displayed in a
// specific switchlist table.
- (id) initWithTrain: (ScheduledTrain*) train
			withCars: (NSArray*) cars
	  owningDocument: (NSDocument<SwitchListDocumentInterface>*) doc {
	self = [super init];
	
	train_ = [train retain];
	owningDocument_ = [doc retain];
	carsInTrain_ = [cars retain];
	return self;
}

- (void) dealloc {
	[train_ release];
	[carsInTrain_ release];
	[owningDocument_ release];
	[super dealloc];
}

// Returns the number of columns to be displayed in this switchlist.
- (int) columnCount {
	return 0;
}

// Returns the width of the nth column as fraction of entire column (0.0-1.0)
- (float) widthForColumn: (int) column {
	return 0.0;
}

// Returns the column heading to display for the column.
- (NSString*) headingForColumn: (int) column {
	return @"";
}

// Returns the string to show in a particular cell of the table.
- (NSString*) textForColumn: (int) column row: (int) row {
	return @"";
}

// Returns true if this column allows squiggly lines to indicate "same as above"?
- (BOOL) columnAllowsContinuations: (int) column {
	return NO;
}
	
// Returns a string containing "industry/town" pairs.
- (NSString *) destStringForFreightCar: (FreightCar *) freightCar {
	NSString *toIndustry, *toTown;
	BOOL loaded = [freightCar isLoaded];
	if ([freightCar intermediateDestination]) {
		// If freight car's being routed home empty, we use intermediateLocation for next place.
		toIndustry = [[freightCar intermediateDestination] name];
		toTown = [[[freightCar intermediateDestination] location] name];
	} else if ([freightCar cargo]) {
		if (loaded) {
			toIndustry = [freightCar valueForKeyPath: @"cargo.destination.name"];
			toTown = [freightCar valueForKeyPath: @"cargo.destination.location.name"];
		} else {
			toIndustry = [freightCar valueForKeyPath: @"cargo.source.name"];
			toTown = [freightCar valueForKeyPath: @"cargo.source.location.name"];
		}
		int doorToSpot = [freightCar nextDoor];
		if (doorToSpot != 0) {
			toIndustry = [NSString stringWithFormat: @"%@ #%d", toIndustry, doorToSpot];
		}
	} else {
		toIndustry=@"---";
		toTown=@"----";
	} 
	return [NSString stringWithFormat: @"%15s/%-15s",[toTown UTF8String],[toIndustry UTF8String]];
}
@end

@implementation SwitchListBaseView
// Create a SwitchListView.
// The frame provided will be the space initially used for the document; if the switch
// list needs to be multiple pages, then the view will set its frame (and bounds) to a larger size
// which the container should be able to handle.
- (id) initWithFrame: (NSRect) frameRect withDocument: (NSDocument<SwitchListDocumentInterface>*) document {
	self = [super initWithFrame: frameRect];

	train_ = nil;
	carsInTrain_ = [[NSArray alloc] init];
	owningDocument_ = [document retain];
	rowHeight_ = 22.0;

	// TODO(bowdidge): Get rid of size being passed in here; use document instead.  Requires lots of other changes.
	imageableWidth_ = frameRect.size.width;
	imageableHeight_ = frameRect.size.height;
	
	randomValue_ = random();
    optionalSettings_ = nil;

    [self findFonts];

	return self;
}

- (void) dealloc {
	[train_ release];
	[carsInTrain_ release];
	[owningDocument_ release];
    [optionalSettings_ release];
	[super dealloc];
}

- (NSDocument<SwitchListDocumentInterface>*) owningDocument {
	return owningDocument_;
}

// Page height in bounds coordinates.
- (float) imageableHeight {
	return imageableHeight_;
}

// Page width in bounds coordinates.
- (float) imageableWidth {
	return imageableWidth_;
}

- (void) recalculateFrame {
	// Frame should be multiple of imageableWidth.
	// For SwitchListBaseView, it's always one page.  Do nothing.
}

- (void) setTrain: (ScheduledTrain*) train {
	[train_ release];
	[carsInTrain_ release];
	train_ = [train retain];
	carsInTrain_ = [[train allFreightCarsInVisitOrder] retain];
	[self recalculateFrame];
}

- (ScheduledTrain*) train {
	return train_;
}

// Returns a font for title displays in the header.
- (NSFont*) titleFontForSize: (float) sz {
	// TODO(bowdidge) Get rid of Egyptian - it's not available on others' machines.
	NSFont *font = [NSFont fontWithName: @"Egyptian" size: sz];
	if (font == nil) {
		font = [NSFont fontWithName: @"Copperplate" size: sz];
	}
	return font;
}

// Draw the train name in the upper left in small type.
- (void) drawTrainNameWithOffset: (float) offsetY {
	float documentHeight = [self imageableHeight];
	[[train_ name] drawAtPoint: NSMakePoint(10.0, offsetY + documentHeight - 10.0) withAttributes: [self smallTypeAttr]];
}

- (void) drawCenteredString: (NSString *) str centerY: (float) centerY centerX: (float) centerPos attributes: attrs {
	NSSize stringSize = [str sizeWithAttributes: attrs];
	
	[str drawInRect: NSMakeRect(centerPos-stringSize.width/2 , centerY-stringSize.height/2, stringSize.width, stringSize.height)
	 withAttributes: attrs];
}

// We want this this to look handwritten, so we jitter the x and y positions.  These need
// to be predictable so resizing the window doesn't cause stuff to shake as each redraw
// chooses a different value.
// choose random offsets -3.2 - 3.2
float randomXOffset[32] = {-3.2, -3.0, -2.8, 2.6, -2.4, 2.2, -2.0, -1.8,
	1.6, -1.4, -1.2, 1.0, 0.8, -0.6, -0.4, -0.2, 
	0, 0.2, 0.4, 0.6, -0.8, -2.0, 3.0, -1.0,
	1.2, 1.4, -1.6, 1.8, 2.0, -2.2, 2.4, -2.6};
float randomYOffset[32] = {0, 0.2, 0.4, 0.6, -0.8, -2.0, 3.0, -1.0,
	1.6, -1.4, -1.2, 1.0, 0.8, -0.6, -0.4, -0.2, 
	-3.2, -3.0, -2.8, 2.6, -2.4, 2.2, -2.0, -1.8,
	1.2, 1.4, -1.6, 1.8, 2.0, -2.2, 2.4, -2.6};

// Draws a string with a bit of random placement, sized to fit the named x dimension.
// The sequence number should be some predictable integer to avoid jitter when redrawing on the screen.
- (void) drawJitteryString: (NSString *) str centerX: (float) centerX centerY: (float) centerY columnSize: (float) columnSize attrs: (id) attrs sequence: (int) sequenceNumber  {
	float offsetX = randomXOffset[sequenceNumber%32];
	// +1 is fudge factor - easier to move text up than down so descenders don't bump.
	float offsetY = randomYOffset[sequenceNumber%32] + 1.0;
	
	centerX += offsetX;
	centerY += offsetY;
	
	[self drawHandwrittenString: str centerX: centerX centerY: centerY columnSize: columnSize handwrittenAttrs: attrs];
}

// Draws a handwritten string in the named location, fitting the string to the specified column size.
- (void) drawHandwrittenString: (NSString *) str
					   centerX: (float) centerX
					   centerY: (float) centerY
					columnSize: (float) columnSize 
			  handwrittenAttrs: (NSDictionary*) attrs {
	
	NSMutableDictionary *newAttrs = [NSMutableDictionary dictionaryWithDictionary: attrs];
	NSSize stringSize = [str sizeWithAttributes: newAttrs];
	NSFont *curFont = [newAttrs objectForKey: NSFontAttributeName];
	// 1.2 magic number is to try to account for descenders.  Without it, text in some fonts gets awfully small.
	while (stringSize.width > columnSize || stringSize.height > rowHeight_ * 1.2) {
		NSFont *newFont = [NSFont fontWithName: [curFont fontName]  size: [curFont pointSize] - 1];
		[newAttrs setObject: newFont forKey: NSFontAttributeName];
		stringSize = [str sizeWithAttributes: newAttrs];
		curFont = newFont;
	}
	
	[self drawCenteredString: str centerY: centerY centerX: centerX attributes: newAttrs];
}

// Returns a string, split up into dash and non-dash components.
- (NSArray*) splitStringByDashes: (NSString*) input {
	NSMutableArray *result = [NSMutableArray array];
	NSUInteger len = [input length];
	BOOL inDashes = [input characterAtIndex: 0] == '_';
	int startOfCurrentEntry = 0;
	for (int i=0; i<len; i++) {
		if (([input characterAtIndex: i] == '_') ^ inDashes) {
			// Switching.
			NSString *nextEntry = [input substringWithRange: NSMakeRange(startOfCurrentEntry, i - startOfCurrentEntry)];
			[result addObject: nextEntry];
			startOfCurrentEntry = i;
			inDashes = !inDashes;
		}
	}
	[result addObject: [input substringFromIndex: startOfCurrentEntry]];
	return result;
}

// Given a string to handwrite and a form line that was drawn at the provided location,
// place the handwritten string over the nth component.
// Components are blocks of characters that are either all dashes or all not, numbered from zero.
- (void) handwriteString: (NSString*) handString
		  inNthComponent: (int) componentIndex
				ofString: (NSString*) templateString
				 centerY: (float) centerY
				 centerX: (float) centerX
				   attrs: (NSDictionary*) attrs {
	NSArray *splitString = [self splitStringByDashes: templateString];
	NSSize overallSize = [templateString sizeWithAttributes: attrs];
	NSDictionary *handAttrs = [self handwritingFontAttr];
	// Calculate the length of each of the non-string parts, advance.
	float leftPos = centerX - overallSize.width / 2.0;
	int i;
	for (i=0;i<componentIndex;i++) {
		NSSize sizeOfComponent = [[splitString objectAtIndex: i] sizeWithAttributes: attrs];
		leftPos +=  sizeOfComponent.width;
	}
	// This element is the one we want.
	NSRect result;
	NSSize sizeOfNthComponent = [[splitString objectAtIndex: componentIndex] sizeWithAttributes: attrs];
	result.origin.x = leftPos;
	// +3 to raise above line.
	result.origin.y = centerY - overallSize.height / 2;
	result.size.width = sizeOfNthComponent.width;
	result.size.height = overallSize.height;
	float RAISE_ABOVE_LINE = 3.0;
	[self drawCenteredString: handString
					 centerY: centerY - overallSize.height / 2 + result.size.height / 2 + RAISE_ABOVE_LINE
					 centerX: result.origin.x + result.size.width / 2.0
				  attributes: handAttrs];
}

// Draws a form line with specified handwritten strings to appear over fields.
// strings array corresponds to each non-dash/dash component of formLine; use @"" to indicate
// no handwritten string belongs at the field.
- (void) drawFormLine: (NSString*) formLine centerX: (long) centerX centerY: (long) centerY strings: (NSArray*) strings
		 printedAttrs: (NSDictionary*) printedAttrs  {
	[self drawCenteredString: formLine centerY: centerY centerX: centerX attributes: printedAttrs];
	NSUInteger fieldCount = [strings count];
	int i;
	// Ignore blanks.
	for (i=0; i< fieldCount; i++) {
		if ([[strings objectAtIndex: i] length] == 0) continue;
		[self handwriteString: [strings objectAtIndex: i]
			   inNthComponent: i ofString: formLine centerY: centerY centerX: centerX attrs: printedAttrs];
	}
}

// Returns current layout date in an array with three elements: month/day, 2 digit year, and 2 digit century.
// TODO(bowdidge): Use dictionary.
- (NSArray*) getDateInStringFormat {
	char *MONTH_NAMES[13] = {"","January","February","March","April","May","June","July","August","September","October",
		"November","December"};
	NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay
										  fromDate: [[owningDocument_ entireLayout] currentDate]];
	NSInteger month = [components month];
    NSInteger day = [components day];
    NSInteger year = [components year];
	NSString *dateString = [NSString stringWithFormat: @"%s %d", MONTH_NAMES[month], (int) day];
	NSString *yearString = [NSString stringWithFormat: @"%d", (int) year % 100];
	NSString *centuryString = [NSString stringWithFormat: @"%d", (int) year/100];
	return [NSArray arrayWithObjects: dateString, yearString, centuryString, nil];
}

// Return the number of pages available for printing
// Required for printing support.
- (BOOL)knowsPageRange:(NSRangePointer)range {
    range->location = 1;
	int pageCount = ceil([self frame].size.height / [self imageableHeight]);
    range->length = pageCount;
    return YES;
}

// Return the drawing rectangle for a particular page number
// Required for printing support.
// The printed document is assumed to be a single view, with bottom left
// of last page at (0,0), and top right at (page width, pages * page_height).
// For the nth page, we'll start at the top and measure down n pages.
// The top should always be at a page boundary.
- (NSRect)rectForPage:(NSInteger)page {
	// TODO(bowdidge): Reverse.
	NSRect rectForPage = NSMakeRect(0, [self imageableHeight] * (page - 1), [self imageableWidth], [self imageableHeight]);
	return rectForPage;
}
	
// Draw the main portion of the switchlist using the current
// SwitchListSource to describe the contents and headings for the rows.
- (void) drawTableForCars: (NSArray*) carsToDisplay rect: (NSRect) rect source: (SwitchListSource*) source {
	// Rectangle height must be a multiple of rowHeight_.
	float leftSide = rect.origin.x;
	float rightSide = rect.origin.x + rect.size.width;
	float bottom = rect.origin.y;
	float top = rect.origin.y + rect.size.height;
	float width = rect.size.width;
	
	[[NSColor blackColor] setStroke];
	NSFrameRect(NSMakeRect(leftSide, bottom, width, top-bottom));
	
	// Draw the table.  This is the outline and column lines.
	// Gray out title block.
	if ([self useGrayBlock]) {
		[[NSColor lightGrayColor] setFill];
		NSRectFill(NSMakeRect(leftSide ,top - rowHeight_, width, rowHeight_));
	}
	
	[[NSColor grayColor] setStroke];
	[NSBezierPath strokeRect: rect];

	int i;
	int numberOfColumns = [source columnCount];
	float offset = leftSide;
	for (i = 0; i < numberOfColumns; i++) {
		float halfOffset = offset + 0.5 * width * [source widthForColumn: i];
		offset += width * [source widthForColumn: i];
		if (i != numberOfColumns - 1) {
			// Not for last.
			[[NSColor grayColor] setStroke];
			[NSBezierPath strokeLineFromPoint: NSMakePoint(offset, top)
									  toPoint: NSMakePoint(offset, bottom)];
		}
		NSString *captionForColumn = [source headingForColumn: i];
		[self drawCenteredString: captionForColumn
						 centerY: top - rowHeight_ /2
						 centerX: halfOffset
					  attributes:[self columnTitleAttr]];
	}
	
	// Draw the row lines.
	float rowLinePos = top - rowHeight_;
	int row = 0;
	while (rowLinePos > bottom) {
		[[NSColor grayColor] setStroke];
		[NSBezierPath strokeLineFromPoint: NSMakePoint(leftSide, rowLinePos)
								  toPoint: NSMakePoint(rightSide, rowLinePos)];
		rowLinePos -= rowHeight_;
		row++;
	}
	
	// Now, fill out the contents of the table.	
	NSUInteger rows = [carsToDisplay count];
	for (row = 0; row < rows; row++) {
		int column;
		int columnCount = [source columnCount];
		int offset = leftSide;
		for (column = 0; column < columnCount; column++) {
			float columnWidth = [source widthForColumn: column] * width;
			float halfOffset = offset + 0.5 * columnWidth;
			offset += columnWidth;
			int sequenceNumber = (row + column);
			float centerY = top - (row+1)*rowHeight_-rowHeight_/2 ;
			float centerX = halfOffset;
			NSString *cellString = [source textForColumn: column row: row];
			
			if ([source columnAllowsContinuations: column] && (row > 0) &&
				[cellString isEqualToString: [source textForColumn: column row: row-1]]) {
				// Draw squiggly line.
				[[NSColor blueColor] set];
				NSBezierPath *path = [NSBezierPath bezierPath];
				[path moveToPoint: NSMakePoint(centerX, centerY + rowHeight_ - 4.0)];
				[path curveToPoint:NSMakePoint(centerX, centerY - 4.0)
					  controlPoint1: NSMakePoint(centerX - 5.0, centerY + rowHeight_/3 - 4.0)
					 controlPoint2: NSMakePoint(centerX + 5.0, centerY + 2*rowHeight_/3 - 4.0)];
				[path stroke];
				//[NSBezierPath strokeLineFromPoint: NSMakePoint(centerX, centerY + rowHeight_ - 4.0)  toPoint: NSMakePoint(centerX, centerY - 4.0)];
												
			} else {
				[self drawJitteryString: cellString 
								centerX: centerX 
								centerY: centerY
							 columnSize: columnWidth
								  attrs: [self handwritingFontAttr] sequence: sequenceNumber];
			}
		}
	}
}

- (NSString*) handwritingFontName {
	// Dakota's really nice, but only available if you installed a special version of iLife.
	// Rock Salt takes too much space, but is nice.
	// Fonts loaded in Info.plist.
    return handwritingFontName_;
}

/* Searches for good handwriting fonts, and picks one to use for
 * all handwritten text in forms.  Call once.
 *
 * Override with GLOBAL_PREFS_HANDWRITTEN_FONT.
 */
- (void) findFonts {
    NSFontManager *fontManager = [NSFontManager sharedFontManager];

    // Font families to try to use for handwritten text.
	NSMutableArray *fontChoices = [NSMutableArray arrayWithObjects:
								   //@"Handwriting - Dakota",
                                   // In app bundle.
								   @"Rock Salt",
                                   // Installed on Macs.
                                   @"Bradley Hand",
                                   @"Chalkduster",
                                   @"Noteworthy",
                                   @"Chalkboard",
                                   nil];
	
	NSString *preferredFont = [[NSUserDefaults standardUserDefaults] stringForKey: GLOBAL_PREFS_HANDWRITTEN_FONT];
	if (preferredFont) {
		[fontChoices insertObject: preferredFont atIndex: 0];
	}
	
	for (NSString *fontName in fontChoices) {
		if ([NSFont fontWithName: fontName size: 12.0]) {
			handwritingFontName_ = fontName;
            return;
		}
	}

    NSLog(@"Did not find any reasonable font family, considered %@", fontChoices);

    // Default, likely installed on Macs.
    NSLog(@"Font families installed were:");
    for (NSString* fontFamily in fontManager.availableFontFamilies) {
        NSLog(@"Family %@:", fontFamily);
    }

    // Default to the most annoying for obviousness.
    handwritingFontName_ = @"Comic Sans MS";
}

- (NSDictionary*) handwritingFontAttr {
	// Maximum size.
	NSFont *handwritingFont =  [NSFont fontWithName: [self handwritingFontName] size: 12];
	
	// This uses a blue color and handwriting font.
	NSDictionary *handwritingFontAttr = [NSMutableDictionary dictionary];
	[handwritingFontAttr setValue: [self bluePenColor] forKey: NSForegroundColorAttributeName];
	[handwritingFontAttr setValue: handwritingFont forKey: NSFontAttributeName];
	return handwritingFontAttr;
}

- (NSDictionary*) handwritingFontAttrForSize: (float) size {
	// TODO(bowdidge): Why the alternate font?  How much does the alternate font mess layout up?
	NSFont *handwritingFont =  [NSFont fontWithName: [self handwritingFontName] size: size];
	
	// This uses a blue color and handwriting font.
	NSDictionary *handwritingFontAttr = [NSMutableDictionary dictionary];
	[handwritingFontAttr setValue: [self bluePenColor] forKey: NSForegroundColorAttributeName];
	[handwritingFontAttr setValue: handwritingFont forKey: NSFontAttributeName];
	return handwritingFontAttr;
}


- (NSDictionary*) columnTitleAttr {
	return nil;
}

- (NSDictionary*) smallTypeAttr {
	NSDictionary *typeAttr = [NSMutableDictionary dictionary];
	[typeAttr setValue: [NSColor grayColor] forKey: NSForegroundColorAttributeName];
	NSFont *smallTypeFont = [NSFont fontWithName: @"Copperplate" size: 9];
	[typeAttr setValue: smallTypeFont forKey: NSFontAttributeName];
	return typeAttr;
}	

- (NSColor*) bluePenColor {
	return [NSColor colorWithDeviceRed:0.0 green: 0.0 blue: 0.4 alpha: 1.0];
}

// Gray in header?
- (BOOL) useGrayBlock {
	return NO;
}

// Returns a random name for signatures.
- (NSString*) randomFunctionary: (int) seed {
	// Taken from SP company officers from a 1946 timetable.
	// Keep the list odd and prime to avoid giving similar names with multiples-of-ten sees.
	NSArray *names = [NSArray arrayWithObjects: @"R. Riggs",
					  @"T. F. Goodwin",
					  @" F. J. Dignon",
					  @"M. A. Jenson",
					  @"Antonio Ferrara",
					  @"A. W. Kilborn",
					  @"RR Rob'nson",
					  @"Fuzzy Schetter", 
					  @"E. L. Cooper",
					  @"L.d'A",
					  @"R. Souza",
					  nil];
	long rnd = (randomValue_ + seed) % [names count];
	return [names objectAtIndex: rnd];
}

// Set the optional settings as a list of pairs of (setting, custom value.
- (void) setOptionalSettings: (NSArray*) optionalSettings {
    [optionalSettings_ release];
    optionalSettings_ = optionalSettings;
}

- (NSString*) optionWithName: (NSString*) optionName alternate: (NSString*) alternate {
    for (int i=0; i<[optionalSettings_ count]; i++) {
        NSArray* pair = [optionalSettings_ objectAtIndex: i];
        NSString* key = [pair objectAtIndex: 0];
        NSString* value = [pair objectAtIndex: 1];
        if ([key isEqualToString: optionName]) {
            return value;
        }
    }
    return alternate;
}

@end
