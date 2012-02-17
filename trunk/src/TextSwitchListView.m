//
//  TextSwitchListView.m
//  SwitchList
//
//  Created by bowdidge on 4/21/11.
//  Copyright 2011 Robert Bowdidge. All rights reserved.
//

#import "TextSwitchListView.h"

#import "DoorAssignmentRecorder.h"
#import "EntireLayout.h"
#import "FreightCar.h"
#import "GlobalPreferences.h"
#import "InduYard.h"
#import "Place.h"

// Abstract class for teletype-style switchlists.
@implementation TextSwitchListView
- (id) initWithFrame: (NSRect) frameRect withDocument: (NSDocument<SwitchListDocumentInterface>*) document {
	[super initWithFrame: frameRect withDocument: document];
	textView_ = [[NSTextView alloc] initWithFrame: frameRect];
	[self addSubview: textView_];
	typedFont_ = nil;
	cachedContents_ = nil;
	return self;
}

- (void) dealloc {
	[textView_ release];
	[typedFont_ release];
	[cachedContents_ release];
	[super dealloc];
}

// Calculate the correct font size for the named font so that each
// line fits on the page.
// TODO(bowdidge): Unused.
- (float) fontSizeToFitFont: (NSString*) fontName {
	char *testCString = malloc([self expectedColumns] + 1);
	int i;
	for (i=0;i<[self expectedColumns];i++) {
		testCString[i] = 'M';
	}
	testCString[[self expectedColumns]] = '\0';
	NSString *testString = [NSString stringWithUTF8String: testCString];
	float testSize = 10.0;
	
	NSDictionary *fontForSizing = [NSDictionary dictionaryWithObject: [NSFont fontWithName: fontName size: testSize] forKey: NSFontAttributeName];
	NSSize lineSize = [testString sizeWithAttributes: fontForSizing];
	
	// pageWidth / lineWidth = finalFontSize / testFontSize
	float finalFontSize = ceil([self imageableWidth] * testSize / lineSize.width);

	// Now, assume the finalFontSize is a bit too large, and drop it a point at a time until the
	// line is smaller than the page width.  Smaller fonts always draw in point sizes probably because
	// anti-aliased versions are canned.
	NSSize finalSize;
	do {
		finalFontSize--;
		NSDictionary *finalFont = [NSDictionary dictionaryWithObject: [NSFont fontWithName: fontName size: finalFontSize] forKey: NSFontAttributeName];
		finalSize = [testString sizeWithAttributes: finalFont];
	} while (finalSize.width > [self imageableWidth]);

	return finalFontSize;
}


// Returns the font to use for fixed-width reports.
- (NSFont*) defaultTypedFont {
	// TODO(bowdidge): This makes line a bit too long.
	return [NSFont userFixedPitchFontOfSize: 9];
}

// For testing only.
- (void) setReportTextView: (id) reportTextView {
	textView_ = [reportTextView retain];
}

// For testing only.	 
- (void) setTypedFont: (id) typedFont {
	typedFont_ = [typedFont retain];
}

- (NSFont*) typedFont {
	if (!typedFont_) {
		typedFont_ = [[self defaultTypedFont] retain];
	}
	return typedFont_;
}


// Default; each subclass should override based on the width of the report.
- (int) expectedColumns {
	return 80;
}

- (void) setTrain: (ScheduledTrain*) train {
	[super setTrain: train];
	// and regenerate text for the report.
	[self generateReport];
}

- (void) setUpTextView {
	[textView_ setHorizontallyResizable: NO];
	[textView_ setVerticallyResizable: NO];
    [textView_ setEditable: NO];
}

- (NSDocument<SwitchListDocumentInterface>*) owningDocument {
	return owningDocument_;
}

- (NSString*) layoutName {
	return [[owningDocument_ entireLayout] layoutName];
}

- (NSString*) currentDate {
	NSDateFormatter *f = [[NSDateFormatter alloc] init];
	[f setDateStyle: NSDateFormatterShortStyle];
	NSDate *currentDate = [[owningDocument_ entireLayout] currentDate];
	NSString *res = [f stringFromDate: currentDate];
	[f release];
	return res;
}

- (NSString *) typeString {
	return @"Generic report";
}

// Returns EntireLayout object for current document.
- (EntireLayout *) entireLayout {
	return [owningDocument_ entireLayout];
}

// Returns the number of characters that can be displayed on a single line with the current font.
- (int) lineLength {
	NSSize textViewSize = [self bounds].size;
	NSDictionary *fontAttrs = [NSDictionary dictionaryWithObject: [self typedFont] forKey: NSFontAttributeName];
	NSSize characterSize = [@"M" sizeWithAttributes: fontAttrs];
	return textViewSize.width / characterSize.width;
}

// Number of lines per page.
- (int) linesPerPage {
	NSDictionary *fontAttrs = [NSDictionary dictionaryWithObject: [self typedFont] forKey: NSFontAttributeName];
	NSSize gCharacterSize = [@"gM" sizeWithAttributes: fontAttrs];
	return (int) ([self imageableHeight] / gCharacterSize.height);
}

- (void) recalculateFrame {
	// Frame should be multiple of imageableHeight.
	NSString *contents = [self cachedContents];
	int lineCount = [[contents componentsSeparatedByString: @"\n"] count];
	int pages = ceil((float) lineCount / [self linesPerPage]);
	NSRect currentFrame = [self frame];
	float fullDocumentHeight = pages * [self imageableHeight];
	[self setFrame: NSMakeRect(currentFrame.origin.x, currentFrame.origin.y,
							   currentFrame.size.width, fullDocumentHeight)];
	[textView_ setFrame: NSMakeRect(0, 0, currentFrame.size.width, fullDocumentHeight)];
}

// Returns a string with the provided string, padded with leading spaces to be centered in the current window.
- (NSString*) centeredString: (NSString*) str {
	float lineLength = [self lineLength];
	int strLen = [str length];
	int leadingSpaces = (lineLength - strLen) / 2;
	if (leadingSpaces < 0) return str;
	// Awkward, but it works.
	return [[@"" stringByPaddingToLength: leadingSpaces withString:@" " startingAtIndex: 0] stringByAppendingString: str];
}

// Generates the header / first few lines of the report.
// Subclass should override for customization.
- (NSString*) headerString {
	NSMutableString *header = [NSMutableString string];
	[header appendString: [self centeredString: [[self layoutName] uppercaseString]]];
	[header appendString: @"\n"];
	[header appendString: [self centeredString: [[self typeString] uppercaseString]]];
	return header;
}

- (float) lineHeight {
	NSMutableDictionary *typedFontAttr = [NSMutableDictionary dictionary];
	[typedFontAttr setValue: [self typedFont] forKey: NSFontAttributeName];
	NSSize size = [[NSString stringWithString: @"gHpQ"] sizeWithAttributes: typedFontAttr];
	return size.height;
}
	
// Displays the requested contents in the report window.
- (void) generateReport {
	[self setUpTextView];
	NSString *contents = [self cachedContents];
	NSMutableString *entireReport = [NSMutableString stringWithFormat: @"%@\n%@", [self headerString] ,contents];
	float lineHeight = [self lineHeight];
	int lineCount = [[entireReport componentsSeparatedByString: @"\n"] count];
	
	int linesPerPage = [self linesPerPage];
	int linesOnLastPage =  (lineCount % linesPerPage);
	if (linesOnLastPage != 0) {
		int linesNeeded = linesPerPage - linesOnLastPage;
		int i;
		// TODO(bowdidge): This sometimes adds too many lines.
		for (i=0; i<linesNeeded; i++) {
			[entireReport appendString: @"\n"];
		}
		lineCount += linesNeeded;
	}
	int documentHeight = lineCount * lineHeight;

	// Keep our containing frame at pixel size.
	NSRect bounds = NSMakeRect(0, 0, [self imageableWidth], documentHeight);
	[self setFrame: bounds];
	// TextView is 1-1.
	[textView_ setFrame: bounds];
	[textView_ setBounds: bounds];
		
	NSView *parent = self;
	while ([parent superview] != nil) {
		parent = [parent superview];
	}

	[textView_ setString: entireReport];
	[textView_ setAlignment:NSLeftTextAlignment range: NSMakeRange(0,[entireReport length])];
    [textView_ setFont: [self typedFont] range: NSMakeRange(0,[entireReport length])];
	[textView_ setTextContainerInset: NSMakeSize(0.25,0.25)];
}	

// Avoid calling contents more than once.
- (NSString*) cachedContents {
	if (!cachedContents_) {
		cachedContents_ = [[self contents] retain];
	}
	return cachedContents_;
}
	
// Common routine for returning contents of report.
// Subclasses must override.
- (NSString*) contents {
	// do whatever's necessary to make text here.
	return @"contents here";
}

- (NSString *) nextDestinationForFreightCar: (FreightCar *) freightCar {
	NSString *toIndustry, *toTown;
	BOOL loaded = [freightCar isLoaded];
	DoorAssignmentRecorder *recorder = [owningDocument_ doorAssignmentRecorder];
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
		int doorToSpot = [recorder doorForCar: freightCar];
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
