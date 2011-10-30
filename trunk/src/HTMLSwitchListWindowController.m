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

@implementation HTMLSwitchListWindowController
// For testing - allow injection of an NSBundle and NSFileManager.
- (id) initWithBundle: (NSBundle*) mainBundle fileManager: (NSFileManager*) fileManager {
	// TODO(bowdidge): Why doesn't initWithWindowNibName work?
	[super init];
    if ([NSBundle loadNibNamed:@"HTMLSwitchListView.nib" owner: self] != YES) {
		NSLog(@"Problems loading HTMLSwitchListView !\n");
	}
	[htmlView_ setResourceLoadDelegate: self];
	currentTemplateDirectory_ = nil;
	mainBundle_ = [mainBundle retain];
	fileManager_ = [fileManager retain];
	
	return self;
}

- (id) init {
	return [self initWithBundle: [NSBundle mainBundle] fileManager: [NSFileManager defaultManager]];
}

- (void) dealloc {
	[currentTemplateDirectory_ release];
	[mainBundle_ release];
	[fileManager_ release];
	[super dealloc];
}

// Main routine for naming the HTML to display.
//   html: raw HTML to display
//   templateDirectory: path to html file, used to find related files (css, etc).
- (void) drawHTML: (NSString*) html templateDirectory: (NSString*) directory {
	if (directory == nil) {
		directory = [mainBundle_ resourcePath];
	}
	[currentTemplateDirectory_ release];
	currentTemplateDirectory_ = [directory retain];
	// Create a fake name for the file so the WebView knows how to find
	// referenced files.
	NSString *fileContainingHTML = [NSString stringWithFormat: @"/%@/switchlist.html", directory];
	[[htmlView_ mainFrame] loadHTMLString: html baseURL: [NSURL fileURLWithPath:fileContainingHTML]];
}

- (void) awakeFromNib {
	// Put the controller in the nextResponder chain so printing is supported.
	[self setNextResponder: [htmlView_ nextResponder]];
	[htmlView_ setNextResponder: self];
	[self drawHTML: @"" templateDirectory: @""];
}

- (IBAction)printDocument:(id)sender {
	[[[[htmlView_ mainFrame] frameView] documentView] print: sender];
}


- (NSWindow*) window {
	return window_;
}

// For testing only.
- (WebView*) htmlView {
	return htmlView_;
}

//  Handle requests from the WebView for additional documents.
// Imitate the web interface; don't allow access to files outside the specific template directory, and
// if the template directory doesn't exist, default to the resources directory for the app bundle so the
// default html and css files can be used.
- (NSURLRequest *)webView:(WebView *)sender
				 resource:(id)identifier
		  willSendRequest:(NSURLRequest *)request
		 redirectResponse:(NSURLResponse *)redirectResponse
		   fromDataSource:(WebDataSource *)dataSource {
	NSURL *requestURL = [request URL];
	if ([[requestURL scheme] isEqualToString: @"file"]) {
		NSString *requestedDirectory = [[[[requestURL resourceSpecifier] 
										 stringByStandardizingPath] stringByDeletingLastPathComponent] 
										stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
		NSString *templateDirectory = [currentTemplateDirectory_ stringByStandardizingPath];
		if ([fileManager_ fileExistsAtPath: templateDirectory] == NO) {
			// Use the default directory.
			templateDirectory = [mainBundle_ resourcePath];
		}
		if (![requestedDirectory isEqualToString: templateDirectory]) {
			// Don't allow the switchlist html to read files other than in its own directory.
			return nil;
		}
	}
	return request;
}
@end