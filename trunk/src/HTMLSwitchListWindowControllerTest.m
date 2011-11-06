//
//  HTMLSwitchListWindowControllerTest.m
//  SwitchList
//
//  Created by Robert Bowdidge on 9/9/11.
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

#import "HTMLSwitchListWindowControllerTest.h"

#import "HTMLSwitchListWindowController.h"

@interface MockBundle : NSObject {
}
- (NSString*) bundlePath;
- (NSString*) resourcePath;
@end

@implementation MockBundle 
- (NSString*) bundlePath {
	return @"/foo.app";
}

- (NSString*) resourcePath {
	return @"/foo.app/Contents/MacOS";
}
@end

@implementation HTMLSwitchListWindowControllerTest
- (void) setUp {
	MockBundle *myBundle = [[[MockBundle alloc] init] autorelease];
	windowController_ = [[HTMLSwitchListWindowController alloc] initWithBundle: (NSBundle*) myBundle
																   fileManager: [NSFileManager defaultManager]
																		 title:	@"Don't Care"];
}

- (void) tearDown {
	[windowController_ release];
}

// Returns the filename that should be retrieved when requesting fileToRequest
// from within the page templateFile.
- (NSURLRequest *) getRequestedFileNameForFile: (NSString *) fileToRequest withinTemplate: (NSString *) templateFile  {
  [windowController_ drawHTML: @"<html><body>Hello World!</body></html>"
			  template: templateFile];
	NSURLRequest *initialRequest = [[NSURLRequest alloc] initWithURL: [NSURL fileURLWithPath: templateFile]];
	WebDataSource *dataSource = [[WebDataSource alloc] initWithRequest: initialRequest];

	NSURLRequest *req = [[NSURLRequest alloc] initWithURL: [NSURL fileURLWithPath: fileToRequest]];
	
	NSURLRequest *actualRequest = [windowController_ webView: nil 
													resource: nil
											 willSendRequest: req
											redirectResponse: nil
											  fromDataSource: dataSource];
  return actualRequest;
}


// Requests for a file in the same directory as the template should always be allowed.
- (void) testSimpleRequestInSameDirectory {
	NSString *templateFile = @"/foo.app/Contents/MacOS/SwitchListStyle/foo.html";
	NSString *fileToRequest = @"/foo.app/Contents/MacOS/SwitchListStyle/foo.css";

	NSURLRequest *actualRequest = [self getRequestedFileNameForFile: fileToRequest withinTemplate: templateFile];
	STAssertEqualObjects(fileToRequest, [[actualRequest URL] path],
						@"Request should have been passed through unmolested.");
}

// Requests for a file in a different directory shouldn't be allowed.
- (void) testRequestFileOutsideDirectory {
	NSString *templateFile = @"/foo.app/Contents/MacOS/SwitchListStyle/foo.html";
	NSString *fileToRequest = @"/etc/passwd";
	
	// Double-check fileToRequest exists so test fails because of access, not existence.
	STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath: fileToRequest], @"Test requires /etc/password to exist.");
	
	NSURLRequest *actualRequest = [self getRequestedFileNameForFile: templateFile withinTemplate: fileToRequest];
	STAssertNil(actualRequest, @"Request should have been refused.");
}

- (void) testRequestFileWithNoTemplateDirectory {
	NSString *cssFile = @"/foo.app/Contents/MacOS/SwitchListStyle/foo.css";
	NSURLRequest *actualRequest = [self getRequestedFileNameForFile: cssFile withinTemplate: @""];
	STAssertNil(actualRequest, @"Request should have been refused.");
}

- (void) testRequestFileInSubdirectory {
	NSString *templateName = @"/MyTemplates/Foo/switchlist.html";
	NSString *cssFile = @"/MyTemplates/Bar/foo.css";
	NSURLRequest *actualRequest = [self getRequestedFileNameForFile: cssFile withinTemplate: templateName];
	STAssertNil(actualRequest, @"Request should have been refused.");
}

@end

