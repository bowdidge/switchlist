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
- (id) initWithAppDelegate: (SwitchListAppDelegate*) delegate {
	[super init];
	appDelegate_ = [delegate retain];
	server_ = [[SimpleHTTPServer alloc] initWithTCPPort: 20000 delegate:self];
	if (server_) {
		NSLog(@"Started!");
	} else {
		NSLog(@"Problems starting server!");
	}
	return self;
}

- (void) dealloc {
	[server_ stopResponding];
	[appDelegate_ release];
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
	NSString *cssFile = [[NSBundle mainBundle] pathForResource: @"switchlist" ofType: @"css"];
	NSData *data = [NSData dataWithContentsOfURL: [NSURL fileURLWithPath: cssFile]];
	[server_ replyWithData:data MIMEType: @"text/css"];
}

- (void) processRequestForSwitchlistIphoneCSS {
	NSString *cssFile = [[NSBundle mainBundle] pathForResource: @"switchlist-iphone" ofType: @"css"];
	NSData *data = [NSData dataWithContentsOfURL: [NSURL fileURLWithPath: cssFile]];
	[server_ replyWithData:data MIMEType: @"text/css"];
}

- (void) processRequestForSwitchlistIpadCSS {
	NSString *cssFile = [[NSBundle mainBundle] pathForResource: @"switchlist-ipad" ofType: @"css"];
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


- (void) processRequestForCarListForLayout: (SwitchListDocument*) document {
	// TODO(bowdidge): Current document is nil whenever not active.
	EntireLayout *layout = [document entireLayout];
	NSMutableString *message = [NSMutableString string];

	NSString *carListHeaderPath = [[NSBundle mainBundle] pathForResource: @"switchlist-carlist-header" ofType: @"html"];
	NSData *data = [NSData dataWithContentsOfURL: [NSURL fileURLWithPath: carListHeaderPath]];
	NSString *contents = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
	[message appendString: contents];
	[contents release];

	// Fill in needed variables for JavaScript.
	[message appendFormat: @"<script type='text/javascript'>var layoutName='%@';</script>", [layout layoutName]];
	
	[message appendFormat: @"<BODY>Cars currently active in layout %@:", [layout layoutName]];;
	
	NSArray *cars = [layout allFreightCarsReportingMarkOrder];
	NSArray *industries = [layout allIndustries];
	[message appendFormat: @"<TABLE>"];
	for (FreightCar *fc in cars) {
		// Put each car on its own line of a table, with the name in the left cell and a SELECT pulldown
		// in the right.  Each SELECT should have the current location selected.
		[message appendFormat: @"<TR>\n<TD>%@</TD>\n", [fc reportingMarks]];
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

// Given parameters to changeCarLocation, updates database.
- (void) processChangeLocationForLayout: (SwitchListDocument*) document car: (NSString*) carName location: (NSString*) locationName {
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
	// TODO(bowdidge): Current document is nil whenever not active.
	EntireLayout *layout = [document entireLayout];
	NSMutableString *message = [NSMutableString string];
	[message appendFormat: @"<HTML><HEAD><TITLE>Train List</TITLE></HEAD><BODY>Trains currently active in layout %@:", [layout layoutName]];
	
	NSArray *trains = [layout allTrains];
	for (ScheduledTrain *train in trains) {
		[message appendFormat: @"<P><A HREF=\"?layout=%@&train=%@\">%@</A>", [layout layoutName], [train name], [train name]];
	}
	[message appendFormat: @"<p>Reposition <A HREF=\"?layout=%@&carList=1\">all freight cars</a>", [layout layoutName]];
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
	
- (void) showAllLayouts {
	NSDocumentController *controller = [NSDocumentController sharedDocumentController];
	NSArray *allDocuments = [controller documents];
	
	NSMutableString *message = [NSMutableString string];
	[message appendFormat: @"<HTML><HEAD><TITLE>SwitchList</TITLE></HEAD><BODY>The following layouts are currently open in SwitchList:"];
	
	for (SwitchListDocument *document in allDocuments) {
		EntireLayout *layout = [document entireLayout];
		[message appendFormat: @"<P><A HREF=\"get?layout=%@\">%@</A>", [layout layoutName], [layout layoutName]];
	}
	[message appendFormat: @"</BODY></HTML>"];
	
	[server_ replyWithStatusCode: HTTP_OK
						 message: message];
}	

// URLs should be of form:
// http://localhost:20000/ -- show list of layouts
// http://localhost:20000/get?layout="xxx" -- show list of trains on layout xxx.
// http://localhost:20000/get?layout="xxx"&train="yyyy" - show details on train yyy on layout xxx.
// http://localhost:20000/get?layout="xxx"&carList -- show list of freight cars, and allow changing locations.
//
// http://localhost:20000/setCarLocation?layout="xxx"&car="xxx"&location="xxx" -- change car's location.

// TODO(bowdidge): Perhaps switch layout/train query to being part of the path, then use queries to set'
// values?  That would also make it easier to do a car detail view.
- (void) processURL: (NSURL*) url connection: (SimpleHTTPConnection*) conn {
	NSLog(@"Process %@", url);
	NSLog(@"Query is %@", [url query]);

	NSString *urlClean = [[url query] stringByReplacingOccurrencesOfString: @"%20" withString: @" "];

	if ([[url path] isEqualToString: @"/switchlist.css"]) {
		[self processRequestForSwitchlistCSS];
	} else if ([[url path] isEqualToString: @"/switchlist-iphone.css"]) {
		[self processRequestForSwitchlistIphoneCSS];
	} else if ([[url path] isEqualToString: @"/switchlist-ipad.css"]) {
		[self processRequestForSwitchlistIpadCSS];
	} else {
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
			} else {
				// Default to showing layout.
				[self processRequestForLayout: document];
			}
		} else {
			// Default to showing all layouts.
			[self showAllLayouts];
		}
	}
}

@end
