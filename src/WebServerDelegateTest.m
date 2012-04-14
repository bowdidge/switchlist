//
//  WebServerDelegateTest.m
//  SwitchList
//
//  Created by bowdidge on 4/16/11.
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
//

#import "WebServerDelegateTest.h"

#import <Cocoa/Cocoa.h>

#import "EntireLayout.h"
#import "FakeSwitchListDocument.h"
#import "HTMLSwitchlistRenderer.h"
#import "FreightCar.h"
#import "Industry.h"
#import "SwitchListDocument.h"
#import "WebServerDelegate.h"

@interface MockSimpleHTTPServer : NSObject {
 @public
	int lastCode;
	NSDictionary *lastHeaders;
	NSData *lastBody;
	NSString *lastType;
	NSString *lastMessage;
}

- (void)replyWithStatusCode:(int)code
                    headers:(NSDictionary *)headers
                       body:(NSData *)body;
- (void)replyWithData:(NSData *)data MIMEType:(NSString *)type;
- (void)replyWithStatusCode:(int)code message:(NSString *)message;
@end

@implementation MockSimpleHTTPServer
- (id) init {
	[super init];
	lastCode = 0;
	lastHeaders = nil;
	lastBody = nil;
	lastType = nil;
	lastMessage = nil;
}

- (void) clearState {
	lastCode = 0;
	[lastHeaders release];
	lastHeaders = nil;
	[lastBody release];
	lastBody = nil;
	[lastType release];
	lastType = nil;
	[lastMessage release];
	lastMessage = nil;
}

- (void) dealloc {
	[self clearState];
	[super dealloc];
}

- (void)replyWithStatusCode:(int)code
                    headers:(NSDictionary *)headers
                       body:(NSData *)body {
	[self clearState];
	lastCode = code;
	lastHeaders = [headers retain];
	lastBody = [body retain];
}

- (void)replyWithData:(NSData *)data MIMEType:(NSString *)type {
	[self clearState];
	lastBody = [data retain];
	lastType = [type retain];
}

- (void)replyWithStatusCode:(int)code message:(NSString *)message {
	[self clearState];
	lastCode = code;
	lastMessage = [message retain];
}

- (void) stopResponding {
}

@end

@implementation WebServerDelegateTest
- (void) setUp {
	[super setUp];
	// Needed files need to be in the unit test's main bundle.
	unitTestBundle_ = [[NSBundle bundleWithIdentifier: @"com.blogspot.vasonabranch.UnitTests"] retain];
	server_ = [[MockSimpleHTTPServer alloc] init];
	webServerDelegate_ = [[WebServerDelegate alloc] initWithServer: (SimpleHTTPServer*) server_
														withBundle: unitTestBundle_
													  withRenderer: [[[HTMLSwitchlistRenderer alloc] initWithBundle: unitTestBundle_] autorelease]];
}

- (void) tearDown {
	// Remove any documents we created in the test.
	NSArray *documents = [[NSDocumentController sharedDocumentController] documents];
	for (NSDocument *document in documents) {
		[[NSDocumentController sharedDocumentController] removeDocument: document];
	}
	[webServerDelegate_ release];
	webServerDelegate_ = nil;
	[unitTestBundle_ release];
}
	
- (void) testSwitchlistIPhoneCss {
	// TODO(bowdidge): Fails.
	NSURL *url = [NSURL URLWithString: @"http://localhost/builtin-switchlist-iphone.css"];
	[webServerDelegate_ processURL: url connection: nil userAgent: nil];
	
	STAssertTrue(200 < [server_->lastBody length], @"Not enough bytes in switchlist-iphone.css (should be > 200");
}
				  
- (void) testSwitchlistCss {
	NSURL *url = [NSURL URLWithString: @"http://localhost/builtin-switchlist.css"];
	[webServerDelegate_ processURL: url connection: nil userAgent: nil];
	
	STAssertTrue(200 < [server_->lastBody length], @"Not enough bytes in switchlist.css (should be > 200_>, was %d)",
					[server_->lastBody length]);
}

- (void) testSwitchlistIpadCss {
	NSURL *url = [NSURL URLWithString: @"http://localhost/builtin-switchlist-ipad.css"];
	[webServerDelegate_ processURL: url connection: nil userAgent: nil];
	
	STAssertTrue(200 < [server_->lastBody length], @"Not enough bytes in switchlist-ipad.css (should be > 200");
}

- (void) testInvalidFile {
	NSURL *url = [NSURL URLWithString: @"http://localhost/foo.h"];
	[webServerDelegate_ processURL: url connection: nil userAgent: nil];
	
	STAssertEquals(404, server_->lastCode,
				   [NSString stringWithFormat: @"Expected 404, got %d (%@)", server_->lastCode, server_->lastMessage]);
	STAssertContains(@"Unknown path: '/foo.h'", server_->lastMessage,
					 [NSString stringWithFormat: @"Expected string 'Unknown path: /foo.h', found %@",
					  server_->lastMessage]);
}

- (void) testInvalidFileLayoutsOpen {
	NSDocumentController *sharedDocumentController = [NSDocumentController sharedDocumentController];
	[sharedDocumentController addDocument: (NSDocument*) [[FakeSwitchListDocument alloc] init]];
	NSURL *url = [NSURL URLWithString: @"http://localhost/foo.h"];
	[webServerDelegate_ processURL: url connection: nil userAgent: nil];
	
	STAssertEquals(404, server_->lastCode,
				   [NSString stringWithFormat: @"Expected 404, got %d (%@)", server_->lastCode, server_->lastMessage]);
	STAssertContains(@"Unknown path: '/foo.h'", server_->lastMessage,
					 [NSString stringWithFormat: @"Expected string 'Unknown path: /foo.h', found %@",
					  server_->lastMessage]);
}

- (void) testRoot {
	NSURL *url = [NSURL URLWithString: @"http://localhost/"];
	[webServerDelegate_ processURL: url connection: nil userAgent: nil];
	
	STAssertContains(@"No layouts", server_->lastMessage,
					 [NSString stringWithFormat: @"Expected %@ in %@", @"No layouts", server_->lastMessage]);
}

- (void) testNoSuchLayout {
	NSURL *url = [NSURL URLWithString: @"http://localhost/get?layout=Nonexistent"];
	[webServerDelegate_ processURL: url connection: nil userAgent: nil];
	
	STAssertEquals(404, server_->lastCode,
				   [NSString stringWithFormat: @"Expected 404, got %d", server_->lastCode]);
}

- (void) testTwoLayouts {
	NSDocumentController *sharedDocumentController = [NSDocumentController sharedDocumentController];
	[sharedDocumentController addDocument: (NSDocument*) [[FakeSwitchListDocument alloc] init]];
	[sharedDocumentController addDocument: (NSDocument*) [[FakeSwitchListDocument alloc] init]];
	NSURL *url = [NSURL URLWithString: @"http://localhost/"];
	[webServerDelegate_ processURL: url connection: nil userAgent: nil];
	
	STAssertEquals(200, server_->lastCode, @"Page not loaded.");
	STAssertNotNil(server_->lastMessage, @"No message received - switchlist-home.html not loaded.");
	// Make sure we have the links to at least one layout.
	STAssertContains(@"get?layout=untitled", server_->lastMessage,
					 [NSString stringWithFormat: @"Expected %@ in %@", @"get?layout=untitled", server_->lastMessage]);
	
}

- (void) testCarlist {
	NSDocumentController *sharedDocumentController = [NSDocumentController sharedDocumentController];
	[self makeThreeStationLayout];
	[self makeThreeStationTrain];
	FakeSwitchListDocument *doc = [[[FakeSwitchListDocument alloc] initWithLayout: entireLayout_] autorelease];
	[webServerDelegate_ processRequestForCarListForLayout: (SwitchListDocument*) doc];
	STAssertEquals(200, server_->lastCode, @"Page not loaded.");
	STAssertNotNil(server_->lastMessage, @"");
	// Check for industry and freight car names in script portion.
	STAssertContains(@"'WP 1'", server_->lastMessage, @"");
	STAssertContains(@"'UP 2'", server_->lastMessage, @"");
	STAssertContains(@"'A-industry'", server_->lastMessage, @"");
	// Check car listed in HTML.
	STAssertContains(@"<td>WP 1</td>", server_->lastMessage, @"");
}
@end
