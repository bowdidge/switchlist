//
//  HTMLSwitchListView.h
//  SwitchList
//
//  Created by Robert Bowdidge on 8/30/11.
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
#import <WebKit/WebKit.h>

// Handles setup and actions on the window used to display HTML switchlists.
@interface HTMLSwitchListWindowController : NSWindowController<NSWindowDelegate> {
	// Web view displaying the switchlist.
	IBOutlet WebView *htmlView_;
	// Owning window.
	IBOutlet NSWindow *window_;
	// Path to preferred directory for templates.  Used to communicate between
	// drawHTML:file: and the callback.
	NSString* currentTemplateDirectory_;
	// Shared bundle - for mocking.
	NSBundle *mainBundle_;
	// Shared file manager - for mocking.
	NSFileManager *fileManager_;
	NSString *title_;
}

// Default constructor.
- (id) initWithTitle: (NSString*) windowTitle;

// For testing - allow injection of an NSBundle and NSFileManager.
- (id) initWithBundle: (NSBundle*) mainBundle fileManager: (NSFileManager*) fileManager title: (NSString*) title;
// Main routine for naming the HTML to display.
//   html: raw HTML to display
//   templateDirectory: path to html file, used to find related files (css, etc).
- (void) drawHTML: (NSString*) html templateDirectory: (NSString*) directory;

// Allows manipulation of the window containing the HTML.
- (NSWindow*) window;
// For testing only.
- (WebView*) htmlView;

// Callback required by WebView to load additional resources. 
- (NSURLRequest *)webView:(WebView *)sender
				 resource:(id)identifier
		  willSendRequest:(NSURLRequest *)request
		 redirectResponse:(NSURLResponse *)redirectResponse
		   fromDataSource:(WebDataSource *)dataSource;

@end
