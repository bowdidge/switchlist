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

#import "../CarType.h"
#import "../EntireLayout.h";
#import "../InduYard.h"
#import "../Industry.h"
#import "../Yard.h"
#import "../Place.h"
#import "../FreightCar.h"
#import "../SwitchListDocument.h"
#import "../SwitchListAppDelegate.h";
#import "SimpleHTTPServer.h"
#import "SimpleHTTPConnection.h"


static const int HTTP_OK = 200;

@implementation WebServerDelegate

// For mocking.
- (id) initWithServer: (SimpleHTTPServer*) server withBundle: (NSBundle*) bundle {
	[super init];
	server_ = server;
	mainBundle_ = bundle;
	if (server_) {
		NSLog(@"Started!");
	} else {
		NSLog(@"Problems starting server!");
	}
	return self;
}

// Preferred constructor.
- (id) init {
	return [self initWithServer: [[SimpleHTTPServer alloc] initWithTCPPort: 20000 delegate:self]
					 withBundle: [NSBundle mainBundle]];
}

- (void) dealloc {
	[server_ stopResponding];
	[server_ release];
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
	NSString *cssFile = [mainBundle_ pathForResource: @"switchlist" ofType: @"css"];
	NSData *data = [NSData dataWithContentsOfURL: [NSURL fileURLWithPath: cssFile]];
	[server_ replyWithData:data MIMEType: @"text/css"];
}

- (void) processRequestForSwitchlistIphoneCSS {
	NSString *cssFile = [mainBundle_ pathForResource: @"switchlist-iphone" ofType: @"css"];
	NSData *data = [NSData dataWithContentsOfURL: [NSURL fileURLWithPath: cssFile]];
	[server_ replyWithData:data MIMEType: @"text/css"];
}

- (void) processRequestForSwitchlistIpadCSS {
	NSString *cssFile = [mainBundle_ pathForResource: @"switchlist-ipad" ofType: @"css"];
	NSData *data = [NSData dataWithContentsOfURL: [NSURL fileURLWithPath: cssFile]];
	[server_ replyWithData:data MIMEType: @"text/css"];
}


- (NSString*) switchListHeaderForTrain: (NSString*) trainName {
	return [NSString stringWithFormat: @"<HTML>\n<HEAD>\n"
			@"<link type=\"text/css\" href=\"switchlist.css\" rel=\"stylesheet\" />\n"
			@"<link media=\"only screen and (max-device-width: 480px)\" href=\"switchlist-iphone.css\" type=\"text/css\" rel=\"stylesheet\" />\n"
			@"<link media=\"only screen and (max-device-width: 1024px)\" href=\"switchlist-ipad.css\" type=\"text/css\" rel=\"stylesheet\" />\n"
			@"<TITLE>Switch List for %@</TITLE>\n</HEAD>\n<BODY>\n", trainName];
}

- (NSString*) townLocationStringForLocation: (InduYard*) induYard {
	return [NSString stringWithFormat: @"%@/%@", [[induYard location] name], [induYard name]];
}
	
- (void) processRequestForLayout: (SwitchListDocument*) document train: (NSString*) trainName {
	// TODO(bowdidge): Current document is nil whenever not active.
	EntireLayout *layout = [document entireLayout];
	ScheduledTrain *train = [layout trainWithName: trainName];
	NSMutableString *message = [NSMutableString stringWithString: [self switchListHeaderForTrain: [train name]]];
	[message appendFormat: @"<div class=\"switch-list-title\">\n"
		                   @"%@\n"
		                   @"<br>\n"
		                   @"SWITCH LIST\n</div>\n",
						   [[document entireLayout] layoutName]];
	[message appendFormat: @"<div class=\"switch-list-instructions\">\n"
	                       @"%@ AT %@ STATION, %@\n"
		                   @"</div>",
		                   [train name],
						   [[train stationStopStrings] objectAtIndex: 0],
						   [layout currentDate]];
	[message appendString: @"<p>\n" 
	                       @"<center>\n"
	                       @"<TABLE BORDER=\"1\" class=\"switch-list\">\n"];
	[message appendString: @"<TR class=\"switch-list-header\">\n"
                           @"  <TH>Done</TH>\n" 
	                       @"<TH>Car No.</TH>\n"
	                       @"<TH>Car Type</TH>\n"
                           @"<TH>From</TH>\n"
                           @"<TH>To</TH>\n</TR>"];
	NSSet *cars = [train freightCars];
	for (FreightCar *car in cars) {
		[message appendFormat: @"<TR><TD><INPUT TYPE=CHECKBOX NAME=""></TD><TD>%@</TD><TD id=\"cartype\">%@</TD><TD>%@</TD><TD>%@</TD></TR>",
		 [car reportingMarks], [[car carTypeRel] carTypeName], [self townLocationStringForLocation: [car currentLocation]],
		 [self townLocationStringForLocation: [car nextStop]]];
	}

	[message appendString: @"</TABLE>\n"
	                       @"</center>\n"
	                       @"<p align=\"right\">"];
	[message appendFormat: @"<INPUT TYPE=BUTTON value=\"Go Back\" onclick=\"location.href='?layout=%@'\">", [layout layoutName]];
	[message appendString: @"<INPUT TYPE=BUTTON value=\"Train Finished\"></p> </HTML>"];
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

// Comparator for place and industry names.
int compareNamesAlphabetically(id s1, id s2, void *context) {
	return [[s1 name] compare: [s2 name]];
}

// Sorts freight car reporting marks by railroad, then number.  SP 3941 should appear before SP 10240.
// TODO(bowdidge): Should make sure that 
int compareReportingMarksAlphabetically(FreightCar* s1, FreightCar* s2, void *context) {
	NSArray *marksComponents1 = [[s1 reportingMarks] componentsSeparatedByString: @" "];
	NSArray *marksComponents2 = [[s2 reportingMarks] componentsSeparatedByString: @" "];
	if (([marksComponents1 count] != 2) || ([marksComponents2 count] != 2)) {
		return [[s1 reportingMarks] compare: [s2 reportingMarks]];
	}
	int nameComp = [[marksComponents1 objectAtIndex: 0] compare: [marksComponents2 objectAtIndex: 0]];
	if (nameComp != NSOrderedSame) {
		return nameComp;
	}
	
	NSString *carNumberString1 = [marksComponents1 objectAtIndex: 1];
	NSString *carNumberString2 = [marksComponents2 objectAtIndex: 1];
	int carNumber1 = [carNumberString1 intValue];
	int carNumber2 = [carNumberString2 intValue];
	
	if ((carNumber1 != 0) && (carNumber2 != 0) &&
		(carNumber1 != carNumber2)) {
		return carNumber1 - carNumber2;
	}

	return [carNumberString1 compare: carNumberString2];
}

// Generates HTML response for the car list for the names layout.
- (void) processRequestForCarListForLayout: (SwitchListDocument*) document {
	// TODO(bowdidge): Current document is nil whenever not active.
	EntireLayout *layout = [document entireLayout];
	NSMutableString *message = [NSMutableString string];

	[message appendString: [self contentsOfHtmlHeaderResource: @"switchlist-carlist-header"]];

	// Fill in needed variables for JavaScript.
	[message appendFormat: @"<script type='text/javascript'>var layoutName='%@';</script>", [layout layoutName]];
	
	[message appendFormat: @"<BODY>Cars currently active in layout %@:", [layout layoutName]];;
	
	NSArray *cars = [[layout allFreightCarsReportingMarkOrder] sortedArrayUsingFunction: &compareReportingMarksAlphabetically context: 0];
	NSArray *industries = [layout allIndustries];
	[message appendFormat: @"<TABLE><th>Reporting Marks</th><th>Car Type</th><th>Location</th>"];
	for (FreightCar *fc in cars) {
		// Put each car on its own line of a table, with the name in the left cell and a SELECT pulldown
		// in the right.  Each SELECT should have the current location selected.
		[message appendFormat: @"<TR>\n<TD>%@</td><td>%@</td>\n", [fc reportingMarks], [[fc carTypeRel] carTypeName]];
		[message appendFormat: @"<TD><select onchange=\"javascript:carLocationChanged(this, '%@');\">", [fc reportingMarks]];
		// TODO(bowdidge): Stop duplicating the industry list in each SELECT.
		for (Industry *industry in industries) {
			[message appendFormat: @"<option %@value=\"%@\">%@</option>", 
				(([fc currentLocation] == industry) ? @"selected=\"selected\" " : @""),
				[industry name], [industry name]];
		}
		for (Yard *yard in [layout allYards]) {
			[message appendFormat: @"<option %@value=\"%@\">%@</option>", (([fc currentLocation] == yard) ? @"selected=\"selected\" " : @""),
			 
			 [yard name], [yard name]];
		}
		[message appendString: @"</select></TD>\n</TR>\n"];
	}
	[message appendString: @"</table>"];
	[message appendFormat: @"</BODY></HTML>"];
	
	[server_ replyWithStatusCode: HTTP_OK
						 message: message];
}

- (void) writeIndustryListForLayout: (EntireLayout *) layout toString: (NSMutableString *) message  {
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
	NSMutableString *message = [NSMutableString string];

	[message appendString: [self contentsOfHtmlHeaderResource: @"switchlist-industrylist-header"]];
	[message appendFormat: @"<BODY>Cars at each industry on layout %@:<p>\n", [layout layoutName]];
	[message appendFormat: @"<table>\n"];
	[self writeIndustryListForLayout: layout toString: message];

	[message appendFormat: @"</body>\n"];
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
	EntireLayout *layout = [document entireLayout];
	NSMutableString *message = [NSMutableString string];
	[message appendFormat: @"<HTML><HEAD><TITLE>%@ Layout/TITLE></HEAD><BODY>\n", [layout layoutName]];

	[message appendFormat: @"<h3>Lists of Cars</h3>\n"];
	[message appendFormat: @"<p>Reposition <A HREF=\"?layout=%@&carList=1\">List of Freight Cars, in reporting mark order</a>", [layout layoutName]];
	[message appendFormat: @"<p><A HREF=\"?layout=%@&industryList=1\">List of Freight Cars, in industry order</a>", [layout layoutName]];
	
	[message appendFormat: @"<H3>Trains</h3>\n<ul>"];
	NSArray *trains = [layout allTrains];
	for (ScheduledTrain *train in trains) {
		[message appendFormat: @"<li><A HREF=\"?layout=%@&train=%@\">%@</A>", [layout layoutName], [train name], [train name]];
	}
	[message appendFormat: @"</ul>\n"];
	[message appendFormat: @"</BODY></HTML>"];
	
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
	
	NSMutableString *message = [NSMutableString string];
	[message appendFormat: @"<HTML><HEAD><TITLE>SwitchList</TITLE></HEAD><BODY>The following layouts are currently open in SwitchList:"];
	
	for (SwitchListDocument *document in allDocuments) {
		EntireLayout *layout = [document entireLayout];
		NSString *layoutName = [layout layoutName];
		if ([layoutName length] == 0) {
			layoutName = @"untitled";
		}
		[message appendFormat: @"<P><A HREF=\"get?layout=%@\">%@</A>", layoutName, layoutName];
	}
	[message appendFormat: @"</BODY></HTML>"];
	
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
- (void) processURL: (NSURL*) url connection: (SimpleHTTPConnection*) conn {
	NSLog(@"Process %@", url);
	NSLog(@"Query is %@", [url query]);
    NSLog(@"Path is %@", [url path]);
	NSString *urlClean = [[url query] stringByReplacingOccurrencesOfString: @"%20" withString: @" "];
    NSLog(@"Clean is %@", urlClean);
	
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
			[self processRequestForLayout: document train: [query objectForKey: @"train"]];
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
