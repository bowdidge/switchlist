//
//  SwitchListStyleTabController.m
//  SwitchList
//
//  Created by bowdidge on 8/2/14.
//
// Copyright (c)2014 Robert Bowdidge,
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

#import "SwitchListStyleTabController.h"

#import "ClickcAtchingView.h"
#import "GlobalPreferences.h"
#import "HTMLSwitchlistRenderer.h"
#import "NSFileManager+DirectoryLocations.h"
#import "SwitchListDocument.h"

@implementation SwitchListStyleTabController

- (id) init {
    self = [super init];
    optionalFieldKeyValues_ = [[NSMutableArray alloc] init];
    styleNameToDescriptionMap_ = [[NSMutableDictionary alloc] init];
    return self;
}

- (void) dealloc {
    [optionalFieldKeyValues_ release];
    [styleNameToDescriptionMap_ release];
    [super dealloc];
}

- (void) awakeFromNib {
    
    // TODO(bowdidge): Move to separate delegate class?
    [switchListStyleOptions_ setDataSource: self];
    [optionColumn_ setEditable: NO];
    [valueColumn_ setEditable: YES];
    
    NSView *clipView = [[[[demoSwitchListView_ mainFrame] frameView] documentView] superview];
    float scale = 0.25; // pow( 4, [sender floatValue] )/(clipView.frame.size.width/clipView.bounds.size.width);
    [clipView scaleUnitSquareToSize:NSMakeSize(scale, scale)];
    [clipView setNeedsDisplay:YES];
    
    // TODO(bowdidge): Merge with template names in ChooseTemplateViewController.
    [styleNameToDescriptionMap_ setObject: @"" forKey: DEFAULT_SWITCHLIST_TEMPLATE];
 	[styleNameToDescriptionMap_ setObject: @"The original style, designed for easy reading in dark garages."
                                  forKey: DEFAULT_SWITCHLIST_TEMPLATE];
    [styleNameToDescriptionMap_ setObject: @"Switchlists that look like they came from a 1980's dot matrix printer." forKey: @"Line Printer"];
    [styleNameToDescriptionMap_ setObject: @"The ``Work Order'' format is based off the PICL-style reports used by most modern era (post-1980) railroad. PICL, or Perpetual Inventory of Car Locations, refers to a computer software program that lists the standing of cars in order on each track."
                                    forKey: @"PICL Report"];
	[styleNameToDescriptionMap_ setObject: @"Typed up each morning by the company manager (a two-finger typist) on a sheet of the company letterhead, this style captures the switching focus of many modern short lines." forKey: @"Railroad Letterhead"];
	[styleNameToDescriptionMap_ setObject: @"On the SF Belt Line, each industry provided its own switchlist, which were given to the crews." forKey: @"San Francisco Belt Line B-7"];
	[styleNameToDescriptionMap_ setObject: @"Borrowed from actual railroad switchlists, this form explicitly lists the contents of each car, and places the origin to the right of the To field, just like on the prototype." forKey: @"Southern Pacific Narrow"];
	[styleNameToDescriptionMap_ setObject: @"Specially designed for the Brio set." forKey: @"Thomas"];
	[styleNameToDescriptionMap_ setObject: @"Generate realistic waybills, just like real conductors would have carried.  Print and cut out for best effect." forKey: @"Waybill"];
   
    demoSwitchListController_ = [[HTMLSwitchListController alloc] init];
    [demoSwitchListController_ setWebView: demoSwitchListView_];
    [[demoSwitchListView_ mainFrame] loadHTMLString: @"Unset" baseURL: [NSURL URLWithString: @"http://www.vasonabranch.com"]];
}

- (NSArray*) optionalFieldKeyValues {
    return optionalFieldKeyValues_;
}

// Returns true if a directory named "name" exists in the specified directory,
// and if "name" contains a switchlist.html file suggesting it's a real template.
- (BOOL) isSwitchlistTemplate: (NSString*) name inDirectory: (NSString*) directory {
	BOOL isDirectory = NO;
	if (![[NSFileManager defaultManager] fileExistsAtPath: [directory stringByAppendingPathComponent: name]
                                              isDirectory: &isDirectory] || isDirectory == NO) {
		return NO;
	}
	// Does a switchlist.html directory exist there?
	if ([[NSFileManager defaultManager] fileExistsAtPath: [[directory stringByAppendingPathComponent: name]
                                                           stringByAppendingPathComponent: @"switchlist.html"]]) {
		return YES;
	}
	return NO;
}

// Puts the switchlist template names in the pop-up in sorted order,
// rescanning the template directories.
- (void) reloadSwitchlistTemplateNames {
	int pos=0;
	[switchListStyleButton_ removeAllItems];
	for (NSString *templateName in [document_ validTemplateNames]) {
		[switchListStyleButton_ insertItemWithTitle: templateName atIndex: pos++];
	}
    
	[switchListStyleButton_ selectItemWithTitle: [document_ preferredSwitchListStyle]];
    [self updateSwitchListOptions];
}
- (IBAction) switchListFormatPreferenceChanged: (id) sender {
	int selection = [sender indexOfSelectedItem];
	NSString *preferredReportName = [sender itemTitleAtIndex: selection];
	[document_ setPreferredSwitchListStyle: preferredReportName];
    [self updateSwitchListOptions];
}

- (ScheduledTrain*) sampleTrain {
    ScheduledTrain *sampleTrain = nil;
    for (ScheduledTrain *train in [[document_ entireLayout] allTrains]) {
        if ([[train freightCars] count] > [[sampleTrain freightCars] count]) {
            sampleTrain = train;
        }
    }
    return sampleTrain;
}

- (void) updateSwitchListOptions {
    HTMLSwitchlistRenderer *renderer = [[[HTMLSwitchlistRenderer alloc] initWithBundle: [NSBundle mainBundle]] autorelease];
    [renderer setTemplate: [document_ preferredSwitchListStyle]];

    NSString *description = [styleNameToDescriptionMap_ objectForKey: [document_ preferredSwitchListStyle]];
    if (!description) description = @"";
    [styleDescription_ setStringValue: description];

    [optionalFieldKeyValues_ release];
    NSArray* defaultFieldKeyValues = [[renderer optionalSettingsForTemplateHtml: @"switchlist"] retain];
    if (![document_ optionalFieldKeyValues] || [[document_ optionalFieldKeyValues] count] != [defaultFieldKeyValues count]) {
        optionalFieldKeyValues_ = [defaultFieldKeyValues retain];
    } else {
        optionalFieldKeyValues_ = [[document_ optionalFieldKeyValues] retain];
    }
    [switchListStyleOptions_ reloadData];
    
    NSString *switchlistHtmlFile = [renderer filePathForTemplateHtml: @"switchlist"];
    // TODO(bowdidge): Fake train with cars.
    [renderer setOptionalSettings: optionalFieldKeyValues_];
    [document_ setOptionalFieldKeyValues: optionalFieldKeyValues_];

    
    // Choose longest train as sample.
    ScheduledTrain* sampleTrain = [self sampleTrain];
    // TODO(bowdidge): Consider making fake train if no trains exist.
    NSString *message = [renderer renderSwitchlistForTrain: sampleTrain layout:[document_ entireLayout] iPhone: NO interactive: NO];
    [demoSwitchListController_ drawHTML: message template: switchlistHtmlFile];
}

- (void)tableView:(NSTableView *)aTable setObjectValue:(id)aData
   forTableColumn:(NSTableColumn *)aCol
			  row:(NSInteger)aRow {
    if (aTable != switchListStyleOptions_) return;
    if (aCol != valueColumn_) return;
    if ((aRow < 0) || aRow >= [optionalFieldKeyValues_ count]) return;
    
    NSMutableArray *keyValuePair = [optionalFieldKeyValues_ objectAtIndex: aRow];
    [keyValuePair replaceObjectAtIndex: 1 withObject: aData];
    [document_ setOptionalFieldKeyValues: optionalFieldKeyValues_];
    [switchListStyleOptions_ reloadData];
}

- (id)switchListStyleObjectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row {
    if ([[[tableColumn headerCell] title] isEqualToString: @"Custom setting" ]) {
        return [[[optionalFieldKeyValues_ objectAtIndex: row] objectAtIndex: 0] stringByReplacingOccurrencesOfString: @"_" withString: @" "];
    } else if ([[[tableColumn headerCell] title] isEqualToString: @"Value"]) {
        return [[optionalFieldKeyValues_ objectAtIndex: row] objectAtIndex: 1];
    }
    return @"";
}

// Table view for main document.
// This handles multiple tables, so dispatch off to different methods depending
// on the table.
- (NSInteger) numberOfRowsInTableView:(NSTableView *)tableView {
    if (tableView != switchListStyleOptions_) {
		NSLog(@"Calling numberOfRowsInTableView on wrong table: %@!", tableView);
        return 0;
    }
    return [optionalFieldKeyValues_ count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	if (tableView != switchListStyleOptions_) {
		NSLog(@"Calling tableView:ObjectValueForTableColumn:row: on wrong table: %@!", tableView);
		return nil;
    }
    return [self switchListStyleObjectValueForTableColumn: tableColumn row: row];
}

// Brings up the Help page for something in the prefences dialog.
// Triggered by Help icon in preferences dialog.
// TODO(bowdidge): Rename to match generic use.
- (IBAction) switchListStyleHelpPressed: (id) sender {
	NSString *locBookName = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleHelpBookName"];
	[[NSHelpManager sharedHelpManager] openHelpAnchor: @"SwitchListPreferencesHelp" inBook: locBookName];
}

- (void) clickCaught: (id) sender {
    // Click on the Web view.
    [document_ doGenerateSwitchListForTrain: [self sampleTrain]];
}



@end
