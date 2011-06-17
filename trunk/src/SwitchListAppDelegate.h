//
//  SwitchListAppDelegate.h
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
//

#import <Cocoa/Cocoa.h>
@class SwitchListDocument;
@class WebServerDelegate;

// Hides details on app-level actions -- mostly menus.

@interface SwitchListAppDelegate : NSObject<NSOutlineViewDataSource, NSOutlineViewDelegate>  {
	IBOutlet NSWindow *reportWindow_;
	IBOutlet NSTextView *reportTextView_;

	// Preferences stuff
	IBOutlet NSWindow *preferencesWindow_;
	IBOutlet NSPopUpButton *switchListStyleButton_;
	IBOutlet NSButton *webServerEnabledCheckBox_;

	// Errors window
	IBOutlet NSWindow *problemsWindow_;
	IBOutlet NSOutlineView *problemsOutlineView_;
	NSMutableArray *problems_;
	IBOutlet NSWindow *splashWindow_;
	IBOutlet NSImageView *splashImage_;
	
	
	IBOutlet NSWindow *helpWindow_;
	IBOutlet NSTextView *helpView_;
	IBOutlet NSScrollView *scrollView_;
	
	IBOutlet NSButton *splashScreenOpenButton_;
	IBOutlet NSTextField *splashScreenDocumentName_;
	
	// Currently active document / last raised /etc.
	SwitchListDocument *currentDocument_;
	WebServerDelegate *webController_;
	bool webServerEnabled_;
	// For starting recent app
	BOOL applicationHasStarted_;
	BOOL shouldShowSplashScreen_;
	
	// Map from SwitchListStyle enum to appropriate SwitchListView class.
	NSMutableDictionary *indexToSwitchListClassMap_;
	// Map from SwitchListStyle enum to appropriate string.
	NSMutableDictionary *indexToSwitchListNameMap_;
}

- (NSWindow*) reportWindow;
- (NSTextView*) reportTextView;
- (IBAction) makeCarReport: (id) sender;
- (IBAction) makeIndustryReport: (id) sender;
- (IBAction) displayCargoReport: (id) sender;
- (IBAction) displayReservedCarReport: (id) sender;
- (IBAction) displayYardReport: (id) sender;
- (IBAction) switchListFormatPreferenceChanged: (id) sender;
- (IBAction) webServerPreferenceChanged: (id) sender;

// Set the current set of problem strings.
- (void) setProblems: (NSArray*) problemStrings;

// Current selection in problems, used for copy.
- (NSString*) selectedProblemText;
// All text in problems.
- (NSString*) allProblemText;

// Brings up the Help page for switch list styles.  Triggered by Help icon in preferences dialog.
- (IBAction) switchListStyleHelpPressed: (id) sender;

- (SwitchListDocument*) currentDocument;

// Manual approaches for testing.
- (void) startWebServer;
- (void) stopWebServer;

- (NSDictionary*) indexToSwitchListClassMap;
- (NSDictionary*) indexToSwitchListNameMap;
@end

// Used in preference panels, in defaults.  Stored in default  SwitchListDefaultStyle
enum SwitchListStyle {
	Undefined=0,
	PrettySwitchListStyle=1,
	OldSwitchListStyle=2,
	PickUpDropOffSwitchListStyle=3,
	SouthernPacificSwitchListStyle=4,
	PICLReportStyle=5,
	SanFranciscoBeltLineB7Style=6
};


