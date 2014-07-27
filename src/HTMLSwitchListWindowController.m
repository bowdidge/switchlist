//
//  HTMLSwitchListView.m
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

#import "HTMLSwitchListWindowController.h"
#import "HTMLSwitchListController.h"

@implementation HTMLSwitchListWindowController
// For testing - allow injection of an NSBundle and NSFileManager.
- (id) initWithBundle: (NSBundle*) mainBundle fileManager: (NSFileManager*) fileManager title: (NSString*) title {
	// TODO(bowdidge): Why doesn't initWithWindowNibName work?
	self = [super init];
	title_ = [title retain];
	// TODO(bowdidge): Moved because of problems with the unit tests.  Move this back to the 
	// top and figure out why it fails in unit tests.
    htmlController_ = [[HTMLSwitchListController alloc] initWithBundle: mainBundle fileManager: fileManager];
    if ([NSBundle loadNibNamed:@"HTMLSwitchListView.nib" owner: self] != YES) {
		NSLog(@"Problems loading HTMLSwitchListView !\n");
	}
    [htmlController_ setWebView:htmlView_];
	[htmlView_ setResourceLoadDelegate: self];
	return self;
}

- (id) initWithTitle: (NSString*) title {
	return [self initWithBundle: [NSBundle mainBundle] fileManager: [NSFileManager defaultManager] title: title];
}

- (void) dealloc {
	[mainBundle_ release];
	[fileManager_ release];
	[title_ release];
	[super dealloc];
}

// Main routine for naming the HTML to display.
//   html: raw HTML to display
//   template: path to html file, used to find related files (css, etc).
- (void) drawHTML: (NSString*) html template: (NSString*) templateFilePath {
	[htmlController_ drawHTML: html template: templateFilePath];
}

- (void) awakeFromNib {
	// Put the controller in the nextResponder chain so printing is supported.
	[self setNextResponder: [[htmlController_ htmlView] nextResponder]];
	[window_ setTitle: title_];
	[htmlView_ setNextResponder: self];
	[self drawHTML: @"" template: @""];
}

- (IBAction)printDocument:(id)sender {
	[[[[[htmlController_ htmlView] mainFrame] frameView] documentView] print: sender];
}


- (NSWindow*) window {
	return window_;
}

// For testing only.
- (WebView*) htmlView {
	return [htmlController_ htmlView];
}


// Callback required by WebView to load additional resources.
- (NSURLRequest *)webView:(WebView *)sender
				 resource:(id)identifier
          willSendRequest:(NSURLRequest *)request
         redirectResponse:(NSURLResponse *)redirectResponse
           fromDataSource:(WebDataSource *)dataSource {
    return [htmlController_ webView: sender resource: identifier willSendRequest: request redirectResponse: redirectResponse fromDataSource: dataSource];
}

@end