//
//
//  Report.m
//  SwitchList
//
//  Created by Robert Bowdidge on 12/14/05.
//
// Copyright (c)2005 Robert Bowdidge,
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

#import "Report.h"

#import "DoorAssignmentRecorder.h"
#import "EntireLayout.h"
#import "GlobalPreferences.h"
#import "FreightCar.h"
#import "Industry.h"
#import "SwitchListDocumentInterface.h"

@implementation Report
- (id) initWithDocument: (NSDocument<SwitchListDocumentInterface>*) document {
	[super init];
    if ([NSBundle loadNibNamed:@"Report.nib" owner: self] != YES) {
		NSLog(@"Problems loading report nib!\n");
	}
	typedFont_ = [self defaultTypedFont];
	objectsToDisplay_ = nil;
	owningDocument_ = [document retain];
	return self;
}

- (void) dealloc {
	[typedFont_ release];
	[objectsToDisplay_ release];
	[owningDocument_ release];
	[super dealloc];
}

// Returns the font to use for fixed-width reports.
- (NSFont*) defaultTypedFont {
	return [NSFont userFixedPitchFontOfSize: 10.0];
}

// For testing only.
- (void) setReportTextView: (id) reportTextView {
	reportTextView_ = [reportTextView retain];
}
	
// For testing only.	 
- (void) setTypedFont: (id) typedFont {
	typedFont_ = [typedFont retain];
}

// Set up print settings that hold for reports (and pretty much everything else we'll print in the app).
- (void) awakeFromNib {
	[[NSPrintInfo sharedPrintInfo] setHorizontalPagination: NSFitPagination];
	[[NSPrintInfo sharedPrintInfo] setVerticallyCentered: NO];
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
	NSSize textViewSize = [reportTextView_ maxSize];
	NSDictionary *fontAttrs = [NSDictionary dictionaryWithObject: [self typedFont] forKey: NSFontAttributeName];
	NSSize characterSize = [@"A" sizeWithAttributes: fontAttrs];
	return textViewSize.width / characterSize.width;
}

- (int) lineCount {
	NSPrintInfo *myPrintInfo = [owningDocument_ printInfo];
	NSRect pageSize = [myPrintInfo imageablePageBounds];

	NSDictionary *fontAttrs = [NSDictionary dictionaryWithObject: [self typedFont] forKey: NSFontAttributeName];
	NSSize gCharacterSize = [@"g" sizeWithAttributes: fontAttrs];
	return (int) (pageSize.size.height / gCharacterSize.height);
}

// Given report contents, convert to two column.
// TODO(bowdidge): Correctly handle header.
// TODO(bowdidge): Figure out how to not break elements in column.
- (NSString*) convertToTwoColumn: (NSString*) contents {
	int i;
	NSMutableString *result = [NSMutableString string];
	NSMutableArray *rawLines = [NSMutableArray arrayWithArray: [contents componentsSeparatedByString: @"\n"]];
	int linesPerPage = [self lineCount];
	int columnWidth = ([self lineLength] / 2) - 1;
	
	// Fill out array to an even set of lines.
	int linesToPrint;
	int extraLines = [rawLines count] % (linesPerPage * 2);
	int linesToAdd = linesPerPage * 2 - extraLines;

	if (linesToAdd != 0) {
		for (i = 0 ; i < linesToAdd; i++) {
			[rawLines addObject: @""];
		}
	}

	linesToPrint = [rawLines count];
	int startLine = 0;

	while (linesToPrint >= startLine + (2 * linesPerPage)) {
		NSArray *column1 = [rawLines subarrayWithRange: NSMakeRange(startLine, linesPerPage)];
		NSArray *column2 = [rawLines subarrayWithRange: NSMakeRange(startLine + linesPerPage, linesPerPage)];
		int i;
		for (i=0; i<linesPerPage; i++) {
			NSString *leftLine = [column1 objectAtIndex: i];
			NSString *rightLine = [column2 objectAtIndex: i];

			NSString *leftLinePadded = [(NSString*) leftLine stringByPaddingToLength: columnWidth - 1
																		   withString: @" "
																	 startingAtIndex: 0];
			[result appendString: [NSString stringWithFormat: @"%@ %@\n", leftLinePadded, rightLine]];
		}
		startLine += 2 * linesPerPage;
	}
	return result;
}


// Returns a string with the provided string, padded with leading spaces to be centered in the current window.
- (NSString*) centeredString: (NSString*) str {
	int strLen = [str length];
	int leadingSpaces = ([self lineLength] - strLen) / 2;
	if (leadingSpaces < 0) return str;
	// Awkward, but it works.
	return [[@"" stringByPaddingToLength: leadingSpaces withString:@" " startingAtIndex: 0] stringByAppendingString: str];
}

// Generates the header / first few lines of the report.  Override for customization.
- (NSString*) headerString {
	NSMutableString *header = [NSMutableString string];
	[header appendString: [self centeredString: [[self layoutName] uppercaseString]]];
	[header appendString: @"\n"];
	[header appendString: [self centeredString: [[self typeString] uppercaseString]]];
	return header;
}
	
// Displays the requested contents in the report window.
- (void) generateReport {
	NSString *contents = [self contents];
	[reportTextView_ setString: @""];
	
	NSString *entireReport = [NSString stringWithFormat: @"%@\n%@", [self headerString] ,contents];

	[reportTextView_ setString: entireReport];
    [reportTextView_ setEditable: NO];
	[reportTextView_ setAlignment:NSLeftTextAlignment range: NSMakeRange(0,[entireReport length])];
    [reportTextView_ setFont: [self typedFont] range: NSMakeRange(0,[entireReport length])];
	
	[reportTextView_ setTextContainerInset: NSMakeSize(0.25,0.25)];
	[reportWindow_ makeKeyAndOrderFront: self];

	[scrollView_ setVerticalPageScroll: 0.0];
}	
	
- (NSString*) contents {
	// do whatever's necessary to make text here.
	return @"contents here";
}

- (void) setObjects: (NSArray*) objects {
	[objectsToDisplay_ release];
	objectsToDisplay_ = [objects retain];
}

- (IBAction)printDocument:(id)sender {
  [reportTextView_ print: sender];
}

- (NSFont*) typedFont {
	return typedFont_;
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
