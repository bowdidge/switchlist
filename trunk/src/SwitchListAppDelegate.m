//
//  SwitchListAppDelegate.m
//  SwitchList
//
//  Created by Robert Bowdidge on 9/17/05.
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

#import "SwitchListAppDelegate.h"

#import "SwitchListDocument.h"

#import "CarReport.h"
#import "CargoReport.h"
#import "GlobalPreferences.h"
#import "IndustryReport.h"
#import "KaufmanSwitchListReport.h"
#import "KaufmanSwitchListView.h"
#import "PICLReport.h"
#import "ReservedCarReport.h"
#import "SouthernPacificSwitchListView.h"
#import "SwitchListReport.h"
#import "SwitchListView.h"
#import "YardReport.h"

#import "SimpleHttpServer/WebServerDelegate.h"

// MyOutlineViewController handles the major document-like actions for the Problems window -
// copy and paste, printing, etc.
@interface MyOutlineViewController : NSViewController {
	SwitchListAppDelegate *appDelegate_;
}

- (id) initWithAppDelegate: (SwitchListAppDelegate*) appDelegate;
@end

@implementation MyOutlineViewController
// Creates a new MyOutlineViewController, using the pointer to the
// appDelegate to retrieve information about current selections.
- (id) initWithAppDelegate: (SwitchListAppDelegate*) appDelegate {
	[super init];
	appDelegate_ = [appDelegate retain];
	return self;
}

- (void) dealloc {
	[appDelegate_ release];
	[super dealloc];
}

// Copies the selected problems to the clipboard as strings, or all problems if
// none are selected.
- (IBAction) copy: (id) sender {
	NSPasteboard *pboard = [NSPasteboard generalPasteboard];
	[pboard clearContents];
	NSPasteboardItem *pasteboardItem = [[[NSPasteboardItem alloc] init] autorelease];
	NSString *selectedString = [appDelegate_ selectedProblemText];
	if (selectedString == nil) {
		selectedString = [appDelegate_ allProblemText];
	}
	[pasteboardItem setString: selectedString forType: NSPasteboardTypeString];
	[pboard writeObjects: [NSArray arrayWithObject: pasteboardItem]];
}

// Print the Problems view's list of problems.  All problems are always printed.
- (IBAction) printDocument: (id) sender {
	// set printing properties
	NSPrintInfo *myPrintInfo = [NSPrintInfo sharedPrintInfo];
	[myPrintInfo setHorizontalPagination:NSFitPagination];
	[myPrintInfo setHorizontallyCentered:NO];
	[myPrintInfo setVerticallyCentered:NO];
	[myPrintInfo setLeftMargin:72.0];
	[myPrintInfo setRightMargin:72.0];
	[myPrintInfo setTopMargin:72.0];
	[myPrintInfo setBottomMargin:90.0];
		
	// create new view just for printing
	NSTextView *printView = [[NSTextView alloc]initWithFrame: 
							 NSMakeRect(0.0, 0.0, 8.5 * 72, 11.0 * 72)];
	NSPrintOperation *op;
		
	// copy the textview into the printview
	[printView insertText: [appDelegate_ allProblemText]];
	op = [NSPrintOperation printOperationWithView: printView printInfo: 
		  myPrintInfo];
	[op setShowsPrintPanel: YES];
	[[[NSDocument alloc] init] runModalPrintOperation: op delegate: nil didRunSelector: NULL 
					 contextInfo: NULL];
		
	[printView release];
}
@end

@implementation SwitchListAppDelegate
- (id) init {
	[super init];
	indexToSwitchListClassMap_ = [[NSMutableDictionary alloc] init];
	[indexToSwitchListClassMap_ setObject: [SwitchListView class] forKey: [NSNumber numberWithInt: PrettySwitchListStyle]];
	[indexToSwitchListClassMap_ setObject: [SwitchListReport class] forKey: [NSNumber numberWithInt: OldSwitchListStyle]];
	[indexToSwitchListClassMap_ setObject: [KaufmanSwitchListReport class] forKey: [NSNumber numberWithInt: PickUpDropOffSwitchListStyle]];
	[indexToSwitchListClassMap_ setObject: [SouthernPacificSwitchListView class] forKey: [NSNumber numberWithInt: SouthernPacificSwitchListStyle]];
	[indexToSwitchListClassMap_ setObject: [PICLReport class] forKey: [NSNumber numberWithInt: PICLReportStyle]];
	[indexToSwitchListClassMap_ setObject: [KaufmanSwitchListView class] forKey: [NSNumber numberWithInt: SanFranciscoBeltLineB7Style]];
	
	indexToSwitchListNameMap_ = [[NSMutableDictionary alloc] init];
	[indexToSwitchListNameMap_ setObject: @"Large Type" forKey: [NSNumber numberWithInt: PrettySwitchListStyle]];
	[indexToSwitchListNameMap_ setObject: @"Traditional From/To" forKey: [NSNumber numberWithInt: OldSwitchListStyle]];
	[indexToSwitchListNameMap_ setObject: @"Drop-off/Pick-up" forKey: [NSNumber numberWithInt: PickUpDropOffSwitchListStyle]];
	[indexToSwitchListNameMap_ setObject: @"Narrow Southern Pacific-style" forKey: [NSNumber numberWithInt: SouthernPacificSwitchListStyle]];
	[indexToSwitchListNameMap_ setObject: @"PICL Report" forKey: [NSNumber numberWithInt: PICLReportStyle]];
	[indexToSwitchListNameMap_ setObject: @"San Francisco Belt B-7" forKey: [NSNumber numberWithInt: SanFranciscoBeltLineB7Style]];
	
	return self;
}

- (NSDictionary*) indexToSwitchListClassMap {
	return indexToSwitchListClassMap_;
}

- (NSDictionary*) indexToSwitchListNameMap {
	return indexToSwitchListNameMap_;
}

// Either by user control or 
- (void) startWebServer {
  webController_ = [[WebServerDelegate alloc] init];
	if (webController_) {
		char hostnameBuf[500];
		// TODO(bowdidge): Check return value.
		gethostname(hostnameBuf, 500);
		NSString *hostname = [NSString stringWithUTF8String: hostnameBuf];
		
		NSAlert *alert = [NSAlert alertWithMessageText: @"Server will run on port 20000"
									 defaultButton: @"OK" alternateButton: nil otherButton: nil
							 informativeTextWithFormat: @"Connect at http://%@:20000 to see", hostname];
		// returns 1 for OK, 0 for cancel.
		[alert runModal];
	}
}

- (void) stopWebServer {
	[webController_ stopResponding];
	[webController_ release];
	webController_ = nil;
}

// Current behavior: Open an untitled document if launching app on its own.
- (BOOL) applicationShouldOpenUntitledFile: (NSApplication*) theApplication {
	return YES;
}


- (void) awakeFromNib {
	problems_ = [[NSMutableArray alloc] init];
	[problems_ addObject: @"No errors"];
	[problemsOutlineView_ setDataSource: self];
	[problemsOutlineView_ setDelegate: self];
	
	MyOutlineViewController *viewController = [[[MyOutlineViewController alloc] initWithAppDelegate: self] autorelease];
	// Chain viewController into the responder chain so it can handle print and copy.
	[viewController setNextResponder: [problemsOutlineView_ nextResponder]];
	[problemsOutlineView_ setNextResponder: viewController];
	[problemsOutlineView_ setAllowsMultipleSelection: YES];

	[switchListStyleButton_ removeAllItems];
	
	// Put the labels in the pop-up in sorted order.
	NSMutableArray *labels = [NSMutableArray array];
	for (NSNumber *switchListEnumValue in indexToSwitchListNameMap_) {
		[labels addObject: [indexToSwitchListNameMap_ objectForKey: switchListEnumValue]];
	}
	[labels sortUsingSelector: @selector(compare:)];
	int pos = 0;

	NSEnumerator *e = [labels reverseObjectEnumerator];
	NSString *label;
	while ((label = [e nextObject]) != nil) {
		[switchListStyleButton_ insertItemWithTitle: label atIndex: pos];
	}
	
	int cellChoice = [[NSUserDefaults standardUserDefaults] integerForKey: @"SwitchListDefaultStyle"];
	NSString *preferredName = [indexToSwitchListNameMap_ objectForKey: [NSNumber numberWithInt: cellChoice]];
	[switchListStyleButton_ selectItemWithTitle: preferredName];
	
	webServerEnabled_ = [[NSUserDefaults standardUserDefaults] boolForKey: @"SwitchListWebServerEnabled"];
	[webServerEnabledCheckBox_ setState: webServerEnabled_];
	webController_ = nil;
	if (webServerEnabled_) {
		[self startWebServer];
	}
}

- (NSWindow*) reportWindow {
	return reportWindow_;
}
- (NSTextView*) reportTextView {
	return reportTextView_;
}

// Provides detailed error message - generally CoreData errors when writing a file.
- (NSError *)application:(NSApplication *)application willPresentError:(NSError *)error {
	NSLog(@"Failed to save to data store: %@", [error localizedDescription]);
	NSArray* detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
	if(detailedErrors != nil && [detailedErrors count] > 0) {
		for(NSError* detailedError in detailedErrors) {
			NSLog(@"  DetailedError: %@", [detailedError userInfo]);
		}
	}
	else {
		NSLog(@"  %@", [error userInfo]);
	}
	return error;
}


- (NSObject<SwitchListDocumentInterface>*) currentDocument {
	NSWindow *win = [[NSApplication sharedApplication] mainWindow];
	NSWindowController *winc = [win windowController];
	if (winc == nil) {
		// Ok, it's probably a report.
		return [((Report*)[win delegate]) owningDocument];
	}
	SwitchListDocument *currentDocument = [winc document];
	return currentDocument;
}

- (IBAction) makeCarReport: (id) sender {
	CarReport *report = [[CarReport alloc] initWithDocument: [self currentDocument]];
	[report setObjects: [[[self currentDocument] entireLayout] allFreightCarsReportingMarkOrder]];
	[report generateReport];
}
- (IBAction) makeIndustryReport: (id) sender {
	IndustryReport *report = [[IndustryReport alloc] initWithDocument: [self currentDocument]];
	[report setObjects: [[[self currentDocument] entireLayout] allFreightCarsSortedByIndustry]];
	[report generateReport];
}

- (IBAction) displayCargoReport: (id) sender {
	CargoReport *report = [[CargoReport alloc] initWithDocument: [self currentDocument]
												 withIndustries: [[[self currentDocument] entireLayout] allIndustries]];
	[report setObjects: [[[self currentDocument] entireLayout] allValidCargos]];
	[report generateReport];
}

- (IBAction) displayReservedCarReport: (id) sender {
	ReservedCarReport *report = [[ReservedCarReport alloc] initWithDocument: [self currentDocument]];
	[report setObjects: [[[self currentDocument] entireLayout] allFreightCarsReportingMarkOrder]];
	[report generateReport];
}

// For each yard or staging yard, print out the list of cars in each yard and the train
// that will be taking each car.
- (IBAction) displayYardReport: (id) sender {
	YardReport *report = [[YardReport alloc] initWithDocument: [self currentDocument]];
	[report setObjects: [[[self currentDocument] entireLayout] allFreightCarsInYard]];
	[report generateReport];
}

- (IBAction) switchListFormatPreferenceChanged: (id) sender {
	int selection = [sender indexOfSelectedItem];
	NSString *preferredReportName = [sender itemTitleAtIndex: selection];
	for (NSNumber *switchListReportEnumValue in [indexToSwitchListNameMap_ allKeys]) {
		if ([[indexToSwitchListNameMap_ objectForKey: switchListReportEnumValue] isEqualToString: preferredReportName]) {
			[[NSUserDefaults standardUserDefaults] setInteger: [switchListReportEnumValue intValue] forKey: GLOBAL_PREFS_SWITCH_LIST_DEFAULT_STYLE];
			[[NSUserDefaults standardUserDefaults] synchronize];
			NSLog(@"New switch list preference is %@ (%d)", preferredReportName, [switchListReportEnumValue intValue]);
			return;
		}
	}
	NSLog(@"Unknown switchlist format %@!", preferredReportName);
}

- (IBAction) webServerPreferenceChanged: (id) sender {
	bool newValue = [sender state];
	[[NSUserDefaults standardUserDefaults] setBool: newValue forKey: GLOBAL_PREFS_ENABLE_WEB_SERVER];
	webServerEnabled_ = newValue;
	[webServerEnabledCheckBox_ setState: newValue];
	if (newValue) {
		[self startWebServer];
	} else {
		[self stopWebServer];
	}
}


// Outline view methods for displaying the list of problems encountered
// when trying to assign cars.
// Just present each known problem as its own item.
- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
	if (item == nil) {
		// root
		id obj = [problems_ objectAtIndex: index];
		return obj;
	}
	return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
	return NO;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
	if (item == nil) {
		return [problems_ count];
	}
	return 0;
}
- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
	return item;
}

// Returns the currently selected problems, or nil if none are selected.
- (NSString*) selectedProblemText {
	NSIndexSet *selectedRowIndexes = [problemsOutlineView_ selectedRowIndexes];

	if ([selectedRowIndexes count] == 0) {
		return nil;
	}

	NSMutableString *fullString = [NSMutableString string];
    NSUInteger currentIndex = [selectedRowIndexes firstIndex];
    while (currentIndex != NSNotFound) {	
		// TODO(bowdidge): Handle case where column gets reordered?
		NSString *currentProblem = [problems_ objectAtIndex: currentIndex];
		[fullString appendFormat: @"%@\n", currentProblem];
        currentIndex = [selectedRowIndexes indexGreaterThanIndex:currentIndex];
    }
	return fullString;
}
	
// Returns all the problem text.
- (NSString*) allProblemText {
	NSMutableString *fullString = [NSMutableString string];
	for (NSString *problem in problems_) {
		[fullString appendFormat: @"%@\n", problem];
    }
	return fullString;
}

// Sets the list of problem strings to display in the Problems window.
- (void) setProblems: (NSArray*) problemStrings {
	[problems_ release];
	problems_ = [problemStrings retain];
	if ([problems_ count] == 0) {
		[problems_ addObject: @"No problems."];
		[problemsOutlineView_ reloadData];
	} else {
	    [problemsOutlineView_ reloadData];
		[problemsWindow_ makeKeyAndOrderFront: self];
	}
}

// Brings up the Help page for switch list styles.  Triggered by Help icon in preferences dialog.
- (IBAction) switchListStyleHelpPressed: (id) sender {
	NSString *locBookName = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleHelpBookName"];
	[[NSHelpManager sharedHelpManager] openHelpAnchor: @"SwitchListStyles" inBook: locBookName];
}

@end
