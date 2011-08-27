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
#import "EntireLayout.h";
#import "FreightCar.h"
#import "InduYard.h"
#import "Industry.h"
#import "MGTemplateEngine/MGTemplateEngine.h"
#import "MGTemplateEngine/ICUTemplateMatcher.h"
#import "Place.h"
#import "SwitchListAppDelegate.h";
#import "SwitchListDocument.h"
#import "SwitchListFilters.h"
#import "SimpleHTTPServer/SimpleHTTPServer.h"
#import "SimpleHTTPServer/SimpleHTTPConnection.h"
#import "Yard.h"

#include <regex.h> // For pattern matching on IP address.

static const int HTTP_OK = 200;

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
- (id) initWithServer: (SimpleHTTPServer*) server withBundle: (NSBundle*) bundle {
	[super init];
	server_ = server;
	mainBundle_ = bundle;
	engine_ = [[MGTemplateEngine alloc] init];
	[engine_ setMatcher: [ICUTemplateMatcher matcherWithTemplateEngine: engine_]];
	[engine_ loadFilter: [[[SwitchListFilters alloc] init] autorelease]];

	if (server_) {
		NSLog(@"Started!");
	} else {
		NSLog(@"Problems starting server!");
	}
	return self;
}

// Preferred constructor.
- (id) init {
	return [self initWithServer: [[SimpleHTTPServer alloc] initWithTCPPort: DEFAULT_SWITCHLIST_PORT delegate:self]
					 withBundle: [NSBundle mainBundle]];
}

- (void) dealloc {
	[server_ stopResponding];
	[server_ release];
	[engine_ release];
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
	[server_ replyWithStatusCode: 403
						message: [NSString stringWithFormat: @"Unknown URL %@", [badURL path]]];
}

- (void) processRequestForSwitchlistCSS {
	// TODO(bowdidge): Allow users to specify a different directory of CSS and HTML for switchlists.
	// The default-switchlist is just the name of the preferred switchlist.css file.  A better
	// scheme would be to stash the default versions in a directory, but XCode doesn't copy directories
	// into the resources directory well.
	NSString *cssFile = [mainBundle_ pathForResource: @"default-switchlist" ofType: @"css"];
	NSData *data = [NSData dataWithContentsOfURL: [NSURL fileURLWithPath: cssFile]];
	[server_ replyWithData:data MIMEType: @"text/css"];
}

- (void) processRequestForSwitchlistIphoneCSS {
	NSString *cssFile = [mainBundle_ pathForResource: @"default-switchlist-iphone" ofType: @"css"];
	NSData *data = [NSData dataWithContentsOfURL: [NSURL fileURLWithPath: cssFile]];
	[server_ replyWithData:data MIMEType: @"text/css"];
}

- (void) processRequestForSwitchlistIpadCSS {
	NSString *cssFile = [mainBundle_ pathForResource: @"default-switchlist-ipad" ofType: @"css"];
	NSData *data = [NSData dataWithContentsOfURL: [NSURL fileURLWithPath: cssFile]];
	[server_ replyWithData:data MIMEType: @"text/css"];
}

- (NSString*) townLocationStringForLocation: (InduYard*) induYard {
	return [NSString stringWithFormat: @"%@/%@", [[induYard location] name], [induYard name]];
}
	
- (void) processRequestForLayout: (SwitchListDocument*) document train: (NSString*) trainName forIPhone: (BOOL) isIPhone {
	// TODO(bowdidge): Current document is nil whenever not active.
	EntireLayout *layout = [document entireLayout];
	ScheduledTrain *train = [layout trainWithName: trainName];
	
	NSDictionary *templateDict = [NSDictionary dictionaryWithObjectsAndKeys:
								  trainName, @"trainName", 
								  [[train stationStopStrings] objectAtIndex: 0],@"firstStation", 
								  [train freightCars], @"freightCars",
								  layout, @"layout",
								  nil];
	
	NSString *switchlistTemplate = (isIPhone ? @"default-switchlist-iphone" : @"default-switchlist");
	NSString *message = [engine_ processTemplateInFileAtPath: [mainBundle_ pathForResource: switchlistTemplate ofType: @"html"]
											   withVariables: templateDict];
	[server_ replyWithStatusCode: HTTP_OK
						 message: message];
}

// Returns the contents of the named resource file.
- (NSString*) contentsOfHtmlHeaderResource: (NSString*) resourceName {
	NSString *carListHeaderPath = [mainBundle_ pathForResource: resourceName ofType: @"html"];
	NSData *data = [NSData dataWithContentsOfURL: [NSURL fileURLWithPath: carListHeaderPath]];
	NSString *contents = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
	return [contents autorelease];
}

// Generates HTML response for the car list for the names layout.
- (void) processRequestForCarListForLayout: (SwitchListDocument*) document {
	// TODO(bowdidge): Current document is nil whenever not active.
	EntireLayout *layout = [document entireLayout];

	NSMutableString *carLocations = [NSMutableString string];
	NSArray *allFreightCars = [[layout allFreightCarsReportingMarkOrder] sortedArrayUsingSelector: @selector(compareNames:)];
	for (FreightCar *freightCar in allFreightCars) {
		[carLocations appendFormat: @"'%@':'%@',", [freightCar reportingMarks], [[freightCar currentLocation] name]];
	}
	NSDictionary *templateDict = [NSDictionary dictionaryWithObjectsAndKeys:
								  allFreightCars, @"freightCars",
								  layout, @"layout",
								  carLocations, @"carLocations",
								  nil];
	NSString *message = [engine_ processTemplateInFileAtPath: [mainBundle_ pathForResource: @"switchlist-carlist" ofType: @"html"]
											   withVariables: templateDict];
	[server_ replyWithStatusCode: HTTP_OK message: message];
}

- (void) writeIndustryListForLayout: (EntireLayout *) layout toString: (NSMutableString *) message  {
	// TODO(bowdidge): Replace with code that builds up an array of information suitable
	// for easily generating this report in the template.
	[message appendFormat:@"<table>"];
	Place *place;
	for (place in [[layout allStations] sortedArrayUsingFunction: &compareNamesAlphabetically context: 0])  {
		if ([place isOffline]) continue;
		BOOL firstIndustry = YES;
		InduYard *ind;
		for (ind in [[[place industries] allObjects] sortedArrayUsingFunction: &compareNamesAlphabetically context: 0]) {
			if ([[ind freightCars] count] == 0) continue;
			BOOL firstFreightCar = YES;
			FreightCar *fc;
			NSString *rowClass = @"";
			NSString *industryName = @"";
			for (fc in [[[ind freightCars] allObjects] sortedArrayUsingFunction: &compareReportingMarksAlphabetically context: 0]) {
				if (firstIndustry) {
					// Stations always get their own first line.
					[message appendFormat: @"<tr class='indStationStart'><td class='indStation'>%@</td></tr>",
					 [place name]];
					rowClass = @"class='indIndustryStart'";
					industryName = [ind name];
					firstIndustry = NO;
					firstFreightCar = NO;
				} else if (firstFreightCar) {
					rowClass= @"class='indIndustryStart'";
					industryName = [ind name]; 
					firstFreightCar = NO;
				} else {
					rowClass = @"";
					industryName = @"";
				}
				[message appendFormat: @"<tr %@><td class='indStation'></td><td class='indIndustry'>%@</td>\n", rowClass,
					industryName];
				[message appendFormat: @"<td class='indMarks'>%@</td><td class='indType'>%@</td></tr>\n",
					[fc reportingMarks], [[fc carTypeRel] carTypeName]];
			}
		}
	}
	[message appendFormat: @"</table>"];
}

// Returns HTML for industry list, showing the cars at each industry 
- (void) processRequestForIndustryListForLayout: (SwitchListDocument*) document {
	EntireLayout *layout = [document entireLayout];
	
	NSDictionary *templateDict = [NSDictionary dictionaryWithObject: layout forKey:  @"layout"];
	NSString *message = [engine_ processTemplateInFileAtPath: [mainBundle_ pathForResource: @"switchlist-industrylist" ofType: @"html"]
											   withVariables: templateDict];
	[server_ replyWithStatusCode: HTTP_OK
						 message: message];
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
	NSDictionary *templateDict = [NSDictionary dictionaryWithObject: [document entireLayout] forKey: @"layout"];
	NSString *message = [engine_ processTemplateInFileAtPath: [mainBundle_ pathForResource: @"switchlist-layout" ofType: @"html"]
											   withVariables: templateDict];
	[server_ replyWithStatusCode: HTTP_OK
						message: message];
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
	NSDocumentController *controller = [NSDocumentController sharedDocumentController];
	NSArray *allDocuments = [controller documents];
	if ([allDocuments count] == 0) {
		[server_ replyWithStatusCode: HTTP_OK message: @"No layouts open in SwitchList!"];;
		return;
	}
	
	// Only one layout?  Redirect straight to there.
	if ([allDocuments count] == 1) {
		EntireLayout *layout = [[allDocuments lastObject] entireLayout];
		[self replyWithRedirectTo: [NSString stringWithFormat: @"get?layout=%@", [layout layoutName]]];
		return;
	}
	
	NSMutableArray *layoutNames = [NSMutableArray array];
	for (SwitchListDocument *document in allDocuments) {
		NSString *layoutName = [[document entireLayout] layoutName];
		if (!layoutName || [layoutName isEqualToString: @""]) {
			[layoutNames addObject: @"untitled"];
		} else {
			[layoutNames addObject: layoutName];
		}
	}
	NSDictionary *templateDict = [NSDictionary dictionaryWithObject: layoutNames forKey:  @"layoutNames"];
	NSString *message = [engine_ processTemplateInFileAtPath: [mainBundle_ pathForResource: @"switchlist-home" ofType: @"html"]
											   withVariables: templateDict];
	NSLog(@"Message was %@", message);
	[server_ replyWithStatusCode: HTTP_OK
						 message: message];
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
	NSLog(@"Query is %@", [url query]);
   	NSLog(@"User agent is %@", userAgent);
    NSLog(@"Path is %@", [url path]);
	NSString *urlClean = [[url query] stringByReplacingOccurrencesOfString: @"%20" withString: @" "];
    NSLog(@"Clean is %@", urlClean);
	
	// If connecting from an iPhone, the UserAgent should contain '(iPhone;' somewhere.
	BOOL isIPhone = [userAgent rangeOfString: @"iPhone"].location != NSNotFound;
	
	if ([[url path] isEqualToString: @"/switchlist.css"]) {
		[self processRequestForSwitchlistCSS];
		return;
	} else if ([[url path] isEqualToString: @"/switchlist-iphone.css"]) {
		[self processRequestForSwitchlistIphoneCSS];
		return;
	} else if ([[url path] isEqualToString: @"/switchlist-ipad.css"]) {
		[self processRequestForSwitchlistIpadCSS];
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
	
	if ([[url path] hasPrefix: @"/setCarLocation"]) {
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
	} else {
		// Default to showing all layouts.
		[self showAllLayouts];
	}
}


@end
