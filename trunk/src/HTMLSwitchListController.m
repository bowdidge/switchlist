//
//  HTMLSwitchListView.m
//  SwitchList
//
//  Created by Robert Bowdidge on 7/26/14.
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

#import "HTMLSwitchListController.h"

@implementation HTMLSwitchListController
// For testing - allow injection of an NSBundle and NSFileManager.
- (id) initWithBundle: (NSBundle*) mainBundle fileManager: (NSFileManager*) fileManager {
	// TODO(bowdidge): Why doesn't initWithWindowNibName work?
	self = [super init];
	mainBundle_ = [mainBundle retain];
	fileManager_ = [fileManager retain];
    htmlView_ = nil;
	return self;
}

- (id) init {
	return [self initWithBundle: [NSBundle mainBundle] fileManager: [NSFileManager defaultManager]];
}

- (void) dealloc {
	[mainBundle_ release];
	[fileManager_ release];
    [htmlView_ release];
	[super dealloc];
}

- (void) setWebView: (WebView*) view {
    [htmlView_ release];
    htmlView_ = [view retain];
}
// Main routine for naming the HTML to display.
//   html: raw HTML to display
//   template: path to html file, used to find related files (css, etc).
- (void) drawHTML: (NSString*) html template: (NSString*) templateFilePath {
	[[htmlView_ mainFrame] loadHTMLString: html baseURL: [NSURL fileURLWithPath: templateFilePath]];
}

// For testing only.
- (WebView*) htmlView {
	return htmlView_;
}

// Handle requests from the WebView for additional documents.
// Imitate the web interface; don't allow access to files outside the specific template directory, and
// if the template directory doesn't exist, default to the resources directory for the app bundle so the
// default html and css files can be used.
- (NSURLRequest *)webView:(WebView *)sender
				 resource:(id)identifier
		  willSendRequest:(NSURLRequest *)request
		 redirectResponse:(NSURLResponse *)redirectResponse
		   fromDataSource:(WebDataSource *)dataSource {
	NSURL *requestURL = [request URL];
	if ([requestURL isFileURL]) {
		// Note there's no fallback here - a template can only look for dependent files
		// in the same directory, not in the resources directory or elsewhere.
		NSString *requestedFile = [requestURL path];
		// Make sure this is a valid place for the template to look.
		NSString *templateDir = [[[[dataSource initialRequest] URL] path] stringByDeletingLastPathComponent];
		NSString *requestDir = [requestedFile stringByDeletingLastPathComponent];
		if (![templateDir isEqualToString: requestDir]) {
			// Don't allow the switchlist html to read files other than in its own directory.
			return nil;
		}
	}
	return request;
}
@end