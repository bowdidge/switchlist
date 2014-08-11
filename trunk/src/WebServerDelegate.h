//
//  WebServerDelegate.h
//  SwitchList
//
//  Created by bowdidge on 11/20/10.
//
// Copyright (c)2010 Robert Bowdidge,
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

#import "MGTemplateEngine/MGTemplateEngine.h"
#import "SwitchListDocumentInterface.h"
@class EntireLayout;
@class HTMLSwitchlistRenderer;
@class SimpleHTTPConnection;
@class SimpleHTTPServer;
@class SwitchListAppDelegate;
@class SwitchListDocument;

/* TCP port where SwitchList web server will listen. */
extern const int DEFAULT_SWITCHLIST_PORT;
// Returns an IP address for current host.
extern NSString *CurrentHostname();

@interface WebServerDelegate : NSObject {
	SimpleHTTPServer *server_;
	HTMLSwitchlistRenderer *htmlRenderer_;
}

- (id) init;
- (void) stopResponding;
- (void) processURL: (NSURL*) url connection: (SimpleHTTPConnection*) conn userAgent: (NSString*) userAgent;
// For mocking.
- (id) initWithServer: (SimpleHTTPServer*) server withBundle: (NSBundle*) mainBundle withRenderer: (HTMLSwitchlistRenderer*) renderer;

// For testing.
- (void) processRequestForCarListForLayout: (NSDocument<SwitchListDocumentInterface>*) document;
- (void) processRequestForIndustryListForLayout: (NSDocument<SwitchListDocumentInterface>*) document;
- (void) processRequestForLayout: (NSDocument<SwitchListDocumentInterface>*) document train: (NSString*) trainName forIPhone: (BOOL) isIPhone;
// Marks the given train as completed, and moves cars to final locations.
- (void) processCompleteTrain: (NSString*) trainName forLayout: (SwitchListDocument*) document;


@end
