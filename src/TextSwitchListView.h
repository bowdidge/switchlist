//
//  TextSwitchListView.h
//  SwitchList
//
//  Created by bowdidge on 4/21/11.
//  Copyright 2011 Robert Bowdidge. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "SwitchListBaseView.h"

// Abstract class for generating computer- or teletype-printed
// switchlists.  The superclass implements contents to provide the text,
// and this class automatically draws the text in an appropriate typewriter font.
@interface TextSwitchListView : SwitchListBaseView {
	NSTextView *textView_;
	NSFont *typedFont_;
	NSString *cachedContents_;
}

- (NSFont*) typedFont;
- (NSString*) contents;
// Subclasses override with number of characters per line.
- (int) expectedColumns;


// Helper for generating string representation of station/industry/door.
- (NSString *) nextDestinationForFreightCar: (FreightCar *) freightCar;
- (void) generateReport;

// Methods for subclasses to override:
// Generates text for report.
- (NSString*) contents;

// Returns name of report.
- (NSString *) typeString;

// Generates the header / first few lines of the report.
// Subclass should override for customization.
- (NSString*) headerString;

// Internal only.  Avoid calling contents over and over.
- (NSString*) cachedContents;
	
@end
