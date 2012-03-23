//
//
//  WebServerDelegate.m
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

#import <Foundation/Foundation.h>

#import "WebServerDelegate.h"

#import "CarType.h"
#import "EntireLayout.h"
#import "FreightCar.h"
#import "GlobalPreferences.h"
#import "HTMLSwitchlistRenderer.h"
#import "InduYard.h"
#import "Industry.h"
#import "MGTemplateEngine/MGTemplateEngine.h"
#import "MGTemplateEngine/ICUTemplateMatcher.h"
#import "NSFileManager+DirectoryLocations.h"
#import "Place.h"
#import "SwitchListAppDelegate.h"
#import "SwitchListDocument.h"
#import "SwitchListFilters.h"
#import "SimpleHTTPServer/SimpleHTTPServer.h"
#import "SimpleHTTPServer/SimpleHTTPConnection.h"
#import "Yard.h"

#include <regex.h> // For pattern matching on IP address.

static const int HTTP_OK = 200;
static const int HTTP_FORBIDDEN = 403;
static const int HTTP_NOT_FOUND = 404;

const int DEFAULT_SWITCHLIST_PORT = 20000;

BOOL IsValidIPAddress(NSString *potentialAddress) {
	regex_t patternCompiled;
	BOOL isValidPattern = NO;
	int ret;
	ret = regcomp(&patternCompiled, "^[0-9]+.[0-9]+.[0-9]+.[0-9]+$", REG_EXTENDED);
	if (ret != 0) {
		NSLog(@"Regex pattern for detecting appropriate IP address for server returned %d\n", ret);
		exit(1);
	}
	
	ret = regexec(&patternCompiled, [potentialAddress UTF8String], 0, NULL, 0);
	if (!ret) {
		isValidPattern = YES;
	} else if (ret == REG_NOMATCH) {
		isValidPattern = NO;
	} else {
		char message[100];
		regerror(ret, &patternCompiled, message, sizeof(message));
		printf("Regex match failed: %s\n", message);
		isValidPattern = NO;
	}
	regfree(&patternCompiled);
	return isValidPattern;
}


NSString *CurrentHostname() {
	NSArray *ipAddresses = [[NSHost currentHost] addresses];
	for (NSString *address in ipAddresses) {
		if (IsValidIPAddress(address)) {
			return address;
		}
	}
	// TODO(bowdidge): Find better way to warn when no addresses are valid.
	return @"127.0.0.1";	
}

@implementation WebServerDelegate

// For mocking.
- (id) initWithServer: (SimpleHTTPServer*) server withBundle: (NSBundle*) bundle withRenderer: (HTMLSwitchlistRenderer*) renderer {
	[super init];
	server_ = [server retain];
    htmlRenderer_ = [renderer retain];
	[htmlRenderer_ setTemplate: DEFAULT_SWITCHLIST_TEMPLATE];
	if (server_) {
		NSLog(@"Started!");
	} else {
		NSLog(@"Problems starting server!");
	}
	return self;
}

// Preferred constructor.
- (id) init {
	HTMLSwitchlistRenderer *htmlRenderer = [[HTMLSwitchlistRenderer alloc] initWithBundle: [NSBundle mainBundle]];
	[htmlRenderer autorelease];
	
	return [self initWithServer: [[[SimpleHTTPServer alloc] initWithTCPPort: DEFAULT_SWITCHLIST_PORT delegate:self] autorelease]
					 withBundle: [NSBundle mainBundle]
				   withRenderer: htmlRenderer];
}

- (void) dealloc {
	[server_ stopResponding];
	[server_ release];
	[htmlRenderer_ release];
	[super dealloc];
}

// Query stops.
- (void) stopProcessing {
	NSLog(@"Stop!");
}

// Shut down server.
- (void) stopResponding {
	[server_ stopResponding];
}

// Change the default switchlist template to the named one.
// If templateName is Handwritten or is nil, then use the default template.
- (void) setTemplate: (NSString*) templateName {
	[htmlRenderer_ setTemplate: templateName];
}

- (void) processError: (NSURL *) badURL {
	[server_ replyWithStatusCode: HTTP_NOT_FOUND
						message: [NSString stringWithFormat: @"Unknown URL %@", [badURL path]]];
}

- (void) processRequestForSwitchlistCSS {
	NSString *cssFile = [htmlRenderer_ filePathForSwitchlistCSS];
	if (!cssFile) {
		[server_ replyWithStatusCode: HTTP_NOT_FOUND
							 message: [NSString stringWithFormat: @"Unknown URL switchlist.css"]];
		return;
	}

	NSData *data = [NSData dataWithContentsOfURL: [NSURL fileURLWithPath: cssFile]];
	[server_ replyWithData:data MIMEType: @"text/css"];
}

- (void) processRequestForSwitchlistIPhoneCSS {
	NSString *cssFile = [htmlRenderer_ filePathForSwitchlistIPhoneCSS];
	if (!cssFile) {
		[server_ replyWithStatusCode: HTTP_NOT_FOUND
							 message: [NSString stringWithFormat: @"Unknown URL switchlist.css"]];
		return;
	}
	NSData *data = [NSData dataWithContentsOfURL: [NSURL fileURLWithPath: cssFile]];
	[server_ replyWithData:data MIMEType: @"text/css"];
}

- (void) processRequestForSwitchlistIPadCSS {
	NSString *cssFile = [htmlRenderer_ filePathForSwitchlistIPadCSS];
	if (!cssFile) {
		[server_ replyWithStatusCode: HTTP_NOT_FOUND
							 message: [NSString stringWithFormat: @"Unknown URL switchlist.css"]];
		return;
	}
	NSData *data = [NSData dataWithContentsOfURL: [NSURL fileURLWithPath: cssFile]];
	[server_ replyWithData:data MIMEType: @"text/css"];
}

- (void) processRequestForDefaultCSS: (NSString*) filePrefix {
	NSString *cssFile = [htmlRenderer_ filePathForDefaultCSS: filePrefix];
	if (!cssFile) {
		[server_ replyWithStatusCode: HTTP_NOT_FOUND
							 message: [NSString stringWithFormat: @"Unknown URL %@.css", filePrefix]];
		return;
	}
	NSData *data = [NSData dataWithContentsOfURL: [NSURL fileURLWithPath: cssFile]];
	[server_ replyWithData:data MIMEType: @"text/css"];
}

- (void) processRequestForLayout: (SwitchListDocument*) document train: (NSString*) trainName forIPhone: (BOOL) isIPhone {
	// TODO(bowdidge): Current document is nil whenever not active.
	EntireLayout *layout = [document entireLayout];
	ScheduledTrain *train = [layout trainWithName: trainName];
	[server_ replyWithStatusCode: HTTP_OK
						 message: [htmlRenderer_ renderSwitchlistForTrain: train layout: layout iPhone: isIPhone]];
}


// Generates HTML response for the car list for the names layout.
- (void) processRequestForCarListForLayout: (SwitchListDocument*) document {
	// TODO(bowdidge): Current document is nil whenever not active.
	EntireLayout *layout = [document entireLayout];

	NSString *message = [htmlRenderer_ renderCarlistForLayout: layout];
	[server_ replyWithStatusCode: HTTP_OK message: message];
}

// Returns HTML for industry list, showing the cars at each industry 
- (void) processRequestForIndustryListForLayout: (SwitchListDocument*) document {
	EntireLayout *layout = [document entireLayout];
	NSString *message = [htmlRenderer_ renderIndustryListForLayout: layout];
	[server_ replyWithStatusCode: HTTP_OK message: message];
}

// Marks the given train as completed, and moves cars to final locations.
- (void) processCompleteTrain: (NSString*) trainName forLayout: (SwitchListDocument*) document {
	ScheduledTrain *train  = [[document entireLayout] trainWithName: trainName];
	if (!train) {
		[server_ replyWithStatusCode: HTTP_OK message: [NSString stringWithFormat: @"Unknown train %@", trainName]];
		return;
	}
	[[document layoutController] completeTrain: train];
	[server_ replyWithStatusCode: HTTP_OK message: [NSString stringWithFormat: @"Train %@ marked completed!", trainName]];
	
}

// Given parameters to changeCarLocation, updates database.
- (void) processChangeLocationForLayout: (SwitchListDocument*) document car: (NSString*) carName location: (NSString*) locationName {
	carName = [carName stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
	EntireLayout *entireLayout = [document entireLayout];
	FreightCar *fc = [entireLayout freightCarWithName: carName];
	InduYard *location = [entireLayout industryOrYardWithName: locationName];
	if (!fc) {
		[server_ replyWithStatusCode: HTTP_OK
							 message: [NSString stringWithFormat: @"No such freight car %@", carName]];
		return;
	}
	if (!location) {
		[server_ replyWithStatusCode: HTTP_OK
							 message: [NSString stringWithFormat: @"No such location %@", locationName]];
		return;
	}
	
	[fc setCurrentLocation: location];
	[server_ replyWithStatusCode: HTTP_OK
						 message: @"OK"];
}	

	
- (void) processRequestForLayout: (SwitchListDocument*) document {
	NSString *message = [htmlRenderer_ renderLayoutPageForLayout: [document entireLayout]];
	[server_ replyWithStatusCode: HTTP_OK message: message];
}

- (SwitchListDocument*) layoutWithName: (NSString*) layout {
	NSDocumentController *controller = [NSDocumentController sharedDocumentController];
	NSArray *allDocuments = [controller documents];
	for (SwitchListDocument *d in allDocuments) {
		if ([[[d entireLayout] layoutName] isEqualToString: layout]) {
			return d;
		}
	}
	return nil;
}

// Generates a page that is a redirect to the provided URL.
- (void) replyWithRedirectTo: (NSString*) dest {
	NSMutableString *message = [NSMutableString string];
	[message appendString: @"<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\">\n"
	 @"<html><head><title>SwitchList</title>"];
	[message appendFormat: @"<meta http-equiv=\"REFRESH\" content=\"0;url=%@\"></HEAD>", dest];
	[message appendString: @"<BODY></body></html>\n"];
	[server_ replyWithStatusCode: HTTP_OK message: message];
}

- (void) showAllLayouts {
	[server_ replyWithStatusCode: HTTP_OK message: [htmlRenderer_ renderLayoutsPage]];
	}	

// URLs should be of form:
// http://localhost:20000/ -- show list of layouts
// http://localhost:20000/get?layout="xxx" -- show list of trains on layout xxx.
// http://localhost:20000/get?layout="xxx"&train="yyyy" - show details on train yyy on layout xxx.
// http://localhost:20000/get?layout="xxx"&carList=1 -- show list of freight cars, and allow changing locations.
// http://localhost:20000/get?layout="xxx"&industryList=1 -- show list of freight cars, and allow changing locations.
//
// http://localhost:20000/setCarLocation?layout="xxx"&car="xxx"&location="xxx" -- change car's location.

// TODO(bowdidge): Perhaps switch layout/train query to being part of the path, then use queries to set'
// values?  That would also make it easier to do a car detail view.
- (void) processURL: (NSURL*) url connection: (SimpleHTTPConnection*) conn userAgent: (NSString*) userAgent {
	NSLog(@"Process %@", url);
	NSString *urlClean = [[url query] stringByReplacingOccurrencesOfString: @"%20" withString: @" "];
	
	// If connecting from an iPhone, the UserAgent should contain '(iPhone;' somewhere.
	BOOL isIPhone = [userAgent rangeOfString: @"iPhone"].location != NSNotFound;
	
	if ([[url path] isEqualToString: @"/switchlist.css"]) {
		[self processRequestForSwitchlistCSS];
		return;
	} else if ([[url path] isEqualToString: @"/switchlist-iphone.css"]) {
		[self processRequestForSwitchlistIPhoneCSS];
		return;
	} else if ([[url path] isEqualToString: @"/switchlist-ipad.css"]) {
		[self processRequestForSwitchlistIPadCSS];
		return;
	}

	if ([[url path] isEqualToString: @"/builtin-switchlist.css"]) {
		NSLog(@"In builtin-switchlist.css");
		[self processRequestForDefaultCSS: @"builtin-switchlist"];
		return;
	} else if ([[url path] isEqualToString: @"/builtin-switchlist-iphone.css"]) {
		[self processRequestForDefaultCSS: @"builtin-switchlist-iphone"];
		return;
	} else if ([[url path] isEqualToString: @"/builtin-switchlist-ipad.css"]) {
		[self processRequestForDefaultCSS: @"builtin-switchlist-ipad"];
		return;
	}
	
	NSArray *queryTerms = [urlClean componentsSeparatedByString: @"&"];
	NSMutableDictionary *query = [NSMutableDictionary dictionary];
	for (NSString *item in queryTerms) {
		NSArray *queryPair = [item componentsSeparatedByString: @"="];
		if ([queryPair count] == 2) {
			[query setObject: [queryPair lastObject] forKey: [queryPair objectAtIndex: 0]];
		} else if ([queryPair count] == 1) {
			[query setObject: [NSNumber numberWithBool: true] forKey: [queryPair objectAtIndex: 0]];
		}
	}
	
	// For debugging: allow specifying "iphone=1" in URL to get iPhone UI.
	if ([query objectForKey: @"iphone"]) {
		isIPhone = YES;
	}
	
	if ([[url path] hasPrefix: @"/completeTrain"]) {
		NSString *train = [query objectForKey: @"train"];
		NSString *layout = [query objectForKey: @"layout"];
		SwitchListDocument *document = [self layoutWithName: layout];
		if (!document) {
			[server_ replyWithStatusCode: HTTP_OK
								 message: [NSString stringWithFormat: @"No layout named %@.", layout]];
			return;
		}
		[self processCompleteTrain: train forLayout: document];
		return;
	} else if ([[url path] hasPrefix: @"/setCarLocation"]) {
		NSString *car = [query objectForKey: @"car"];
		NSString *location = [query objectForKey: @"location"];
		NSString *layout = [query objectForKey: @"layout"];
		SwitchListDocument *document = [self layoutWithName: layout];
		if (!document) {
			[server_ replyWithStatusCode: HTTP_OK
								 message: [NSString stringWithFormat: @"No layout named %@.", layout]];
			return;
		}
		[self processChangeLocationForLayout: document car: car location: location];
		return;
	} else if ([[url path] isEqualToString: @"/get"]) {
		NSString *layoutName = [query objectForKey: @"layout"];
		SwitchListDocument *document = [self layoutWithName: layoutName];
		
		if (document == nil) {
			[server_ replyWithStatusCode: HTTP_NOT_FOUND
								 message: [NSString stringWithFormat: @"No such layout: '%@'.", layoutName]];
			return;
		}
		
		if ([query objectForKey: @"train"] != nil) {
			[self processRequestForLayout: document train: [query objectForKey: @"train"] forIPhone: isIPhone];
		} else if ([query objectForKey: @"carList"] != nil) {
			[self processRequestForCarListForLayout: document];
		} else if ([query objectForKey: @"industryList"] != nil) {
			[self processRequestForIndustryListForLayout: document];
		} else {
			// Default to showing layout.
			[self processRequestForLayout: document];
		}
	} else if ([[url path] isEqualToString: @"/"]) {
		[self showAllLayouts];
	} else {
		[server_ replyWithStatusCode: HTTP_NOT_FOUND
							 message: [NSString stringWithFormat: @"Unknown path: '%@'.", [url path]]];
	}
}


@end
