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

@implementation MyFileManager
- (id) init {
	preferredResponse_ = NO;
}

- (void) setPreferredResponse: (BOOL) preferredResponse {
	preferredResponse_ = preferredResponse;
}

- (BOOL) fileExistsAtPath: (NSString*) path {
	return preferredResponse_;
}
@end

@implementation HTMLSwitchListWindowControllerTest
- (void) setUp {
	MockBundle *myBundle = [[[MockBundle alloc] init] autorelease];
	myFileManager_ = [[MyFileManager alloc] init];
	windowController_ = [[HTMLSwitchListWindowController alloc] initWithBundle: (NSBundle*) myBundle
																   fileManager: (NSFileManager*) myFileManager_
																		 title:	@"Don't Care"];
}

- (void) tearDown {
	[myFileManager_ release];
	[windowController_ release];
}

// Requests for a file in the same directory as the template should always be allowed.
// TODO(bowdidge): Should be more like web interface and only allow specific files to be
// retrieved.
- (void) testSimpleRequestInSameDirectory {
	[myFileManager_ setPreferredResponse: YES];
	[windowController_ drawHTML: @"<html><body>Hello World!</body></html>"
			 templateDirectory: @"/foo.app/Contents/MacOS/SwitchListStyle"];
	NSURLRequest *req = [[NSURLRequest alloc] initWithURL: [NSURL URLWithString: @"file://foo.app/Contents/MacOS/SwitchListStyle/foo.css"]];
	
	NSURLRequest *actualRequest = [windowController_ webView: nil 
													resource: nil
											 willSendRequest: req
											redirectResponse: nil
											  fromDataSource: nil];
	
	STAssertEquals(req, actualRequest, @"Request should have been passed through unmolested.");
}

// Requests for a file in a different directory shouldn't be allowed.
- (void) testRequestFileOutsideDirectory {
	[myFileManager_ setPreferredResponse: YES];
	[windowController_ drawHTML: @"<html><body>Hello World!</body></html>"
			  templateDirectory: @"/foo.app/Contents/MacOS/SwitchListStyle"];
	NSURLRequest *req = [[NSURLRequest alloc] initWithURL: [NSURL URLWithString: @"file://My/BankDetails.txt"]];
	
	NSURLRequest *actualRequest = [windowController_ webView: nil 
													resource: nil
											 willSendRequest: req
											redirectResponse: nil
											  fromDataSource: nil];
	
	STAssertNil(actualRequest, @"Request should have been refused.");
}

// If the directory does not exist, the request shouldn't be allowed.
- (void) testRequestFileFromNonexistentDirectory {
	[myFileManager_ setPreferredResponse: NO];
	[windowController_ drawHTML: @"<html><body>Hello World!</body></html>"
			  templateDirectory: @"/foo.app/Contents/MacOS/SwitchListStyle"];
	NSURLRequest *req = [[NSURLRequest alloc] initWithURL: [NSURL URLWithString: @"file://foo.app/Contents/MacOS/SwitchListStyle/foo.css"]];
	
	NSURLRequest *actualRequest = [windowController_ webView: nil 
													resource: nil
											 willSendRequest: req
											redirectResponse: nil
											  fromDataSource: nil];
	
	STAssertNil(actualRequest, @"Request should have been refused.");
}

- (void) testRequestFileWithNoTemplateDirectory {
	[myFileManager_ setPreferredResponse: NO];
	[windowController_ drawHTML: @"<html><body>Hello World!</body></html>"
			  templateDirectory: nil];
	NSURLRequest *req = [[NSURLRequest alloc] initWithURL: [NSURL URLWithString: @"file://foo.app/Contents/MacOS/SwitchListStyle/foo.css"]];
	
	NSURLRequest *actualRequest = [windowController_ webView: nil 
													resource: nil
											 willSendRequest: req
											redirectResponse: nil
											  fromDataSource: nil];
	
	STAssertNil(actualRequest, @"Request should have been refused.");
}

- (void) testRequestDefaultFileWithNoTemplateDirectory {
	[myFileManager_ setPreferredResponse: NO];
	[windowController_ drawHTML: @"<html><body>Hello World!</body></html>"
			  templateDirectory: nil];
	NSURLRequest *req = [[NSURLRequest alloc] initWithURL: [NSURL URLWithString: @"file://foo.app/Contents/MacOS/foo.css"]];
	
	NSURLRequest *actualRequest = [windowController_ webView: nil 
													resource: nil
											 willSendRequest: req
											redirectResponse: nil
											  fromDataSource: nil];
	
	STAssertEquals(req, actualRequest, @"Should have allowed access to default directory.");
}
@end

