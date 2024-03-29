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
#import "SimpleHttpServer/SimpleHTTPServer.h"
#import "SimpleHttpServer/SimpleHTTPConnection.h"
#import "Yard.h"

#include <regex.h> // For pattern matching on IP address.

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
	self = [super init];
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

- (void) processError: (NSURL *) badURL {
	[server_ replyWithStatusCode: HTTP_NOT_FOUND
						message: [NSString stringWithFormat: @"Unknown URL %@", [badURL path]]];
}

- (void) updatePreferredTemplateForDocument: (NSDocument<SwitchListDocumentInterface>*) document {
    // Hack.  We should be setting this per-request, but other files in the template (css,
    // images, etc) would be searched in the built-in default files.
    // Instead, assume only one document at a time would
    // ever be using the web interface - not a big stretch - and remember the last
    // document and template.
    if (document) {
        [htmlRenderer_ setTemplate: [document preferredSwitchListStyle]];
    }
}

- (void) processRequestForLayout: (NSDocument<SwitchListDocumentInterface>*) document train: (NSString*) trainName forIPhone: (BOOL) isIPhone {
	// TODO(bowdidge): Current document is nil whenever not active.
	EntireLayout *layout = [document entireLayout];
    [self updatePreferredTemplateForDocument: document];
	ScheduledTrain *train = [layout trainWithName: trainName];
    [htmlRenderer_ setOptionalSettings: [document optionalFieldKeyValues]];
    if (!train) {
        [server_ replyWithStatusCode: HTTP_NOT_FOUND
                             message: [NSString stringWithFormat: @"Unknown train: %@", trainName]];
        return;
    }
	[server_ replyWithStatusCode: HTTP_OK
						 message: [htmlRenderer_ renderSwitchlistForTrain: train layout: layout
                                                                   iPhone: isIPhone interactive: YES]];
}


// Generates HTML response for the car list for the names layout.
- (void) processRequestForCarListForLayout: (NSDocument<SwitchListDocumentInterface>*) document {
	// TODO(bowdidge): Current document is nil whenever not active.
	EntireLayout *layout = [document entireLayout];
    [self updatePreferredTemplateForDocument: document];

	NSString *message = [htmlRenderer_ renderCarlistForLayout: layout];
	[server_ replyWithStatusCode: HTTP_OK message: message];
}

// Returns HTML for industry list, showing the cars at each industry 
- (void) processRequestForIndustryListForLayout: (NSDocument<SwitchListDocumentInterface>*) document {
	EntireLayout *layout = [document entireLayout];
    [self updatePreferredTemplateForDocument: document];

	NSString *message = [htmlRenderer_ renderIndustryListForLayout: layout];
	[server_ replyWithStatusCode: HTTP_OK message: message];
}

// Returns HTML for yard report.
- (void) processRequestForYardReportForLayout: (NSDocument<SwitchListDocumentInterface>*) document {
	EntireLayout *layout = [document entireLayout];
    [self updatePreferredTemplateForDocument: document];

    NSString *message = [htmlRenderer_ renderYardReportForLayout: layout];
	[server_ replyWithStatusCode: HTTP_OK message: message];
}

// Returns HTML for reserved car report.
- (void) processRequestForReservedCarReportForLayout: (NSDocument<SwitchListDocumentInterface>*) document {
	EntireLayout *layout = [document entireLayout];
    [self updatePreferredTemplateForDocument: document];

	NSString *message = [htmlRenderer_ renderReservedCarReportForLayout: layout];
	[server_ replyWithStatusCode: HTTP_OK message: message];
}

// Returns HTML for cargo report.
- (void) processRequestForCargoReportForLayout: (NSDocument<SwitchListDocumentInterface>*) document {
	EntireLayout *layout = [document entireLayout];
    [self updatePreferredTemplateForDocument: document];

	NSString *message = [htmlRenderer_ renderCargoReportForLayout: layout];
	[server_ replyWithStatusCode: HTTP_OK message: message];
}

// Marks the given train as completed, and moves cars to final locations.
- (void) processCompleteTrain: (NSString*) trainName forLayout: (NSDocument<SwitchListDocumentInterface>*) document {
	ScheduledTrain *train  = [[document entireLayout] trainWithName: trainName];
	if (!train) {
		[server_ replyWithStatusCode: HTTP_OK message: [NSString stringWithFormat: @"Unknown train %@", trainName]];
		return;
	}
	[[document layoutController] completeTrain: train];
	[server_ replyWithStatusCode: HTTP_OK message: [NSString stringWithFormat: @"Train %@ marked completed!", trainName]];
    [document updateSummaryInfo: self];
}

// Given parameters to changeCarLocation, updates database.
- (void) processChangeLocationForLayout: (NSDocument<SwitchListDocumentInterface>*) document car: (NSString*) carName location: (NSString*) locationName {
	carName = [carName stringByRemovingPercentEncoding];
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
    [document updateSummaryInfo: self];
	[server_ replyWithStatusCode: HTTP_OK
						 message: @"OK"];
}	
	
- (void) processRequestForLayout: (NSDocument<SwitchListDocumentInterface>*) document {
	NSString *message = [htmlRenderer_ renderLayoutPageForLayout: [document entireLayout]];
	[server_ replyWithStatusCode: HTTP_OK message: message];
}

// Handle request for arbitrary file.  The filename will always be truncated to the last path component,
// and will be searched for in the current template directory and in app's Resources folder.
- (void) processRequestForFile: (NSString*) filename {
	NSString *cleanFilename = [filename lastPathComponent];
	NSString *filePath = [htmlRenderer_ filePathForTemplateFile: cleanFilename];

	if (!filePath || 
		![[NSFileManager defaultManager] isReadableFileAtPath: filePath]) {
		[server_ replyWithStatusCode: HTTP_NOT_FOUND
							 message: [NSString stringWithFormat: @"Unknown URL: '%@'.", filename]];
		return;
	}
	
	NSData *data = [NSData dataWithContentsOfURL: [NSURL fileURLWithPath: filePath]];
	[server_ replyWithData:data MIMEType: [NSString stringWithFormat: @"text/%@", [filePath pathExtension]]];
}

- (SwitchListDocument*) layoutWithName: (NSString*) layoutName {
	if ([layoutName isEqualToString: @"untitled"]) {
		layoutName = @"";
	}
	NSDocumentController *controller = [NSDocumentController sharedDocumentController];
	NSArray *allDocuments = [controller documents];
	for (SwitchListDocument *d in allDocuments) {
		if ([[[d entireLayout] layoutName] isEqualToString: layoutName]) {
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

// Error for invalid layout parameter.  Shouldn't be reachable without a mangled URL.
- (void) replyWithNoKnownLayout: (NSString*) layoutName {
	[server_ replyWithStatusCode: HTTP_NOT_FOUND
						 message: [NSString stringWithFormat: @"No layout named %@.", layoutName]];
	return;
}
	

- (void) showAllLayouts {
	NSDocumentController *controller = [NSDocumentController sharedDocumentController];
	NSArray *allDocuments = [controller documents];
	NSMutableArray *allLayouts = [NSMutableArray array];
	for (SwitchListDocument *document in allDocuments) {
		NSString *layoutName = [[document entireLayout] layoutName];
		if (!layoutName || [layoutName isEqualToString: @""]) {
			// If there's no cars in the layout, ignore.
			if ([[[document entireLayout] allFreightCars] count] > 0) {
				[allLayouts addObject: [document entireLayout]];
			}
		} else {
			[allLayouts addObject: [document entireLayout]];
		}
	}
	
	[server_ replyWithStatusCode: HTTP_OK message: [htmlRenderer_ renderLayoutsPageWithLayouts: allLayouts]];
}	

// URLs should be of form:
// http://localhost:20000/ -- show list of layouts
// http://localhost:20000/layout?layout="xxx" -- show list of trains on layout xxx.
// http://localhost:20000/switchlist?layout="xxx"&train="yyyy" - show details on train yyy on layout xxx.
// http://localhost:20000/carList?layout="xxx" -- show list of freight cars, and allow changing locations.
// http://localhost:20000/industryList?layout="xxx" -- show list of freight cars, and allow changing locations.
//
// http://localhost:20000/setCarLocation?layout="xxx"&car="xxx"&location="xxx" -- change car's location.

// TODO(bowdidge): Perhaps switch layout/train query to being part of the path, then use queries to set'
// values?  That would also make it easier to do a car detail view.
- (void) processURL: (NSURL*) url connection: (SimpleHTTPConnection*) conn userAgent: (NSString*) userAgent {
	NSString *urlClean = [[url query] stringByReplacingOccurrencesOfString: @"%20" withString: @" "];
	
	// If connecting from an iPhone, the UserAgent should contain '(iPhone;' somewhere.
	BOOL isIPhone = [userAgent rangeOfString: @"iPhone"].location != NSNotFound;
	
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
	if ([[url path] isEqualToString: @"/"]) {
		[self showAllLayouts];
		return;
	} else {
		// All these expect a layout to be named.
		NSString *layout = [[query objectForKey: @"layout"] stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
		SwitchListDocument *document = [self layoutWithName: layout];
		
		if ([[url path] hasPrefix: @"/completeTrain"]) {
			NSString *train = [[query objectForKey: @"train"] stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
			if (!document) {
				[self replyWithNoKnownLayout: layout];
				return;
			}
			[self processCompleteTrain: train forLayout: document];
			return;
		} else if ([[url path] hasPrefix: @"/setCarLocation"]) {
			if (!document) {
				[self replyWithNoKnownLayout: layout];
				return;
			}
			NSString *car = [[query objectForKey: @"car"] stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
			NSString *location = [[query objectForKey: @"location"] stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
			[self processChangeLocationForLayout: document car: car location: location];
			return;
		} else if ([[url path] isEqualToString: @"/carList"]) {
			if (!document) {
				[self replyWithNoKnownLayout: layout];
				return;
			}
			[self processRequestForCarListForLayout: document];
			return;
		} else if ([[url path] isEqualToString: @"/industryList"]) {
			if (!document) {
				[self replyWithNoKnownLayout: layout];
				return;
			}
			[self processRequestForIndustryListForLayout: document];
			return;
		} else if ([[url path] isEqualToString: @"/yardReport"]) {
			if (!document) {
				[self replyWithNoKnownLayout: layout];
				return;
			}
			[self processRequestForYardReportForLayout: document];
			return;
		} else if ([[url path] isEqualToString: @"/reservedCarReport"]) {
			if (!document) {
				[self replyWithNoKnownLayout: layout];
				return;
			}
			[self processRequestForReservedCarReportForLayout: document];
			return;
		} else if ([[url path] isEqualToString: @"/cargoReport"]) {
			if (!document) {
				[self replyWithNoKnownLayout: layout];
				return;
			}
			[self processRequestForCargoReportForLayout: document];
			return;
		} else if ([[url path] isEqualToString: @"/switchlist"]) {
			if (!document) {
				[self replyWithNoKnownLayout: layout];
				return;
			}
			NSString *trainName = [[query objectForKey: @"train"] stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
			[self processRequestForLayout: document train: trainName forIPhone: isIPhone];
		} else if ([[url path] isEqualToString: @"/layout"]) {
			if (!document) {
				[self replyWithNoKnownLayout: layout];
				return;
			}
			[self processRequestForLayout: document];
		}
	}
	
    // TODO(bowdidge): Find way to identify which layout the file should be served from, and thus what template to use.
    // For now, defaults to previous template.
	[self processRequestForFile: [url path]];
}


@end
