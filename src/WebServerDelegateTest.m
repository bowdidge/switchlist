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
#import "LayoutController.h"
#import "StringHelpers.h"
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
	self = [super init];
	lastCode = 0;
	lastHeaders = nil;
	lastBody = nil;
	lastType = nil;
	lastMessage = nil;
    return self;
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
	unitTestBundle_ = [[NSBundle bundleForClass: [self class]] retain];
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
    [server_ release];
	[unitTestBundle_ release];
}
	
- (void) testSwitchlistIPhoneCss {
	// TODO(bowdidge): Fails.
	XCTAssertNotNil(unitTestBundle_, @"Can't find unit test bundle, so all attempts to access files will fail.");
	NSURL *url = [NSURL URLWithString: @"http://localhost/switchlist-iphone.css"];
	[webServerDelegate_ processURL: url connection: nil userAgent: nil];
	
	XCTAssertTrue(200 < [server_->lastBody length], @"Not enough bytes in switchlist-iphone.css (should be > 200");
}
				  
- (void) testSwitchlistCss {
	NSURL *url = [NSURL URLWithString: @"http://localhost/switchlist.css"];
	[webServerDelegate_ processURL: url connection: nil userAgent: nil];
	
	XCTAssertTrue(200 < [server_->lastBody length], @"Not enough bytes in switchlist.css (should be > 200_>, was %ld)",
					[server_->lastBody length]);
}

- (void) testSwitchlistIpadCss {
	NSURL *url = [NSURL URLWithString: @"http://localhost/switchlist-ipad.css"];
	[webServerDelegate_ processURL: url connection: nil userAgent: nil];
	
	XCTAssertTrue(200 < [server_->lastBody length], @"Not enough bytes in switchlist-ipad.css (should be > 200");
}

- (void) testInvalidFile {
	NSURL *url = [NSURL URLWithString: @"http://localhost/foo.h"];
	[webServerDelegate_ processURL: url connection: nil userAgent: nil];
	
	XCTAssertEqual(404, server_->lastCode,
				   @"Expected 404, got %d (%@)", server_->lastCode, server_->lastMessage);
	XCTAssertContains(@"Unknown URL: '/foo.h'", server_->lastMessage,
					  @"Expected string 'Unknown URL: /foo.h', found %@",
					  server_->lastMessage);
}

- (void) testInvalidFileLayoutsOpen {
	NSDocumentController *sharedDocumentController = [NSDocumentController sharedDocumentController];
	[sharedDocumentController addDocument: (NSDocument*) [[FakeSwitchListDocument alloc] init]];
	NSURL *url = [NSURL URLWithString: @"http://localhost/foo.h"];
	[webServerDelegate_ processURL: url connection: nil userAgent: nil];
	
	XCTAssertEqual(404, server_->lastCode,
				   @"Expected 404, got %d (%@)", server_->lastCode, server_->lastMessage);
	XCTAssertContains(@"Unknown URL: '/foo.h'", server_->lastMessage,
					 @"Expected string 'Unknown URL: /foo.h', found %@",
					  server_->lastMessage);
}

- (void) testRoot {
	NSURL *url = [NSURL URLWithString: @"http://localhost/"];
	[webServerDelegate_ processURL: url connection: nil userAgent: nil];
	
	XCTAssertContains(@"No layouts", server_->lastMessage,
					 @"Expected %@ in %@", @"No layouts", server_->lastMessage);
}

- (void) testNoSuchLayout {
	NSURL *url = [NSURL URLWithString: @"http://localhost/layout?layout=Nonexistent"];
	[webServerDelegate_ processURL: url connection: nil userAgent: nil];
	
	XCTAssertEqual(404, server_->lastCode,
				   @"Expected 404, got %d (%@)", server_->lastCode, server_->lastMessage);
}

- (void) testTwoLayouts {
	NSDocumentController *sharedDocumentController = [NSDocumentController sharedDocumentController];
	FakeSwitchListDocument *doc1 = [[FakeSwitchListDocument alloc] initWithLayout: [self createEmptyLayout]];
	FakeSwitchListDocument *doc2 = [[FakeSwitchListDocument alloc] initWithLayout: [self createEmptyLayout]];
	[sharedDocumentController addDocument: (NSDocument*) doc1];
	[sharedDocumentController addDocument: (NSDocument*) doc2];
	// TODO(bowdidge): Changes both.
	[[doc1 entireLayout] setLayoutName: @"My Layout"];
	
	NSURL *url = [NSURL URLWithString: @"http://localhost/"];
	[webServerDelegate_ processURL: url connection: nil userAgent: nil];
	
	XCTAssertEqual(200, server_->lastCode, @"Page not loaded.");
	XCTAssertNotNil(server_->lastMessage, @"No message received - switchlist-home.html not loaded.");
	// Make sure we have the links to at least one layout.
	// Because only one layout has a name, only one name shows up.
	XCTAssertContains(@"layout?layout=My%20Layout", server_->lastMessage, @"Expected %@ in %@", @"layout?layout=My Layout", server_->lastMessage);
	XCTAssertEqual(1, [server_->lastMessage occurrencesOfString: @"layout?layout="],
					@"Wrong number of layouts in layout list, expected 1, found %d", 
				   [server_->lastMessage occurrencesOfString: @"layout?layout="]);
	
}

- (void) testCarlist {
	[self makeThreeStationLayout];
	[self makeThreeStationTrain];
	FakeSwitchListDocument *doc = [[[FakeSwitchListDocument alloc] initWithLayout: entireLayout_] autorelease];
	[webServerDelegate_ processRequestForCarListForLayout: (SwitchListDocument*) doc];
	XCTAssertEqual(200, server_->lastCode, @"Page not loaded.");
	XCTAssertNotNil(server_->lastMessage, @"");
	// Check for industry and freight car names in script portion.
	XCTAssertContains(@"'WP 1'", server_->lastMessage, @"");
	XCTAssertContains(@"'UP 2'", server_->lastMessage, @"");
	XCTAssertContains(@"'A-industry'", server_->lastMessage, @"");
	// Check car listed in HTML.
	XCTAssertContains(@"<td>WP 1</td>", server_->lastMessage, @"");
}

- (void) testTrainCompleted {
	[self makeThreeStationLayout];
	ScheduledTrain *train = [self makeThreeStationTrain];
	FakeSwitchListDocument *doc = [[[FakeSwitchListDocument alloc] initWithLayout: [self entireLayout]] autorelease];
    XCTAssertFalse([doc summaryInfoUpdated]);
    XCTAssertEqualObjects(@"A-industry", [[[self freightCarWithReportingMarks: @"UP 2"] currentLocation] name]);

	[webServerDelegate_ processCompleteTrain: [train name] forLayout: (SwitchListDocument*) doc];

    XCTAssertTrue([doc summaryInfoUpdated]);
    XCTAssertEqual(200, server_->lastCode, @"Page not loaded.");
	XCTAssertNotNil(server_->lastMessage, @"");
	// Check for industry and freight car names in script portion.
    NSLog(@"%@", server_->lastMessage);
	XCTAssertContains([train name], server_->lastMessage, @"");
    XCTAssertContains(@"completed", server_->lastMessage, @"");
    XCTAssertEqualObjects(@"B-industry", [[[self freightCarWithReportingMarks: @"UP 2"] currentLocation] name]);
}

@end
