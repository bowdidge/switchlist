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
@class SwitchListAppDelegate;

// MyOutlineViewController handles the major document-like actions for the Problems window -
// copy and paste, printing, etc.
@interface MyOutlineDelegate : NSViewController<NSOutlineViewDelegate, NSOutlineViewDataSource> {
	SwitchListAppDelegate *appDelegate_;
	NSOutlineView *problemsOutlineView_;
}

- (id) initWithAppDelegate: (SwitchListAppDelegate*) appDelegate withOutlineView: (NSOutlineView*) view;
// Returns the currently selected problems, or nil if none are selected.
- (NSString*) selectedProblemText;

@end

// Hides details on app-level actions -- mostly menus.
@interface SwitchListAppDelegate : NSObject<NSOutlineViewDataSource, NSOutlineViewDelegate, NSAlertDelegate>  {
	IBOutlet NSWindow *reportWindow_;
	IBOutlet NSTextView *reportTextView_;

	// Preferences stuff
	IBOutlet NSWindow *preferencesWindow_;
	IBOutlet NSPopUpButton *switchListStyleButton_;
	IBOutlet NSButton *webServerVisibleCheckBox_;

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
	
	// Submenu containing list of example layouts to explore.
	IBOutlet NSMenu *exampleMenu_;
	
	// Web server status window.
	IBOutlet NSPanel *webServerStatusPanel_;
	IBOutlet NSImageView *networkIconView_;
	IBOutlet NSButton *webAccessCheckBox_;
	IBOutlet NSTextField *connectAtMessage_;
	IBOutlet NSTextField *webAccessAddressMessage_;
	IBOutlet NSTextField *webAccessStatusMessage_;
	// Image to be displayed in networkIconView_ when server is enabled.
	NSImage* networkIconImage_;
	
	// Currently active document / last raised /etc.
	SwitchListDocument *currentDocument_;
	WebServerDelegate *webController_;
	// Should web server be running?
	bool webServerEnabled_;
	// Should web server panel be visible?
	bool webServerVisible_;
	// For starting recent app
	BOOL applicationHasStarted_;
	BOOL shouldShowSplashScreen_;
	
	// Keep central file manager for easier stubbing.
	NSFileManager *defaultFileManager_;
	
	MyOutlineDelegate *outlineDelegate_;
}

+ (SwitchListAppDelegate *)sharedAppDelegate;

- (NSWindow*) reportWindow;
- (NSTextView*) reportTextView;
- (IBAction) webServerPreferenceChanged: (id) sender;

- (IBAction) webServerRunStatusChanged: (id) sender;

// Selector for the example menu items.  Opens the example named by the sending menu.
- (IBAction) doOpenExample: (id) sender;

// Copies a template directory into the correct application support directory for the app.
- (IBAction) doImportTemplate: (id) sender;

// Set the current set of problem strings.
- (void) setProblems: (NSArray*) problemStrings;
// List of strings in problems.
- (NSArray*) problems;

// Brings up the Help page for switch list styles.  Triggered by Help icon in preferences dialog.
- (IBAction) switchListStyleHelpPressed: (id) sender;

- (SwitchListDocument*) currentDocument;

// Manual approaches for testing.
- (void) startWebServer;
- (void) stopWebServer;

@end

