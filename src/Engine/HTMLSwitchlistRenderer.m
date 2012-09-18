//
//
//  HTMLSwitchlistRenderer.m
//  SwitchList
//
//  Created by bowdidge on 8/30/2011
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

#import <Foundation/Foundation.h>

#import "FreightCar.h"
#import "GlobalPreferences.h"
#import "HTMLSwitchlistRenderer.h"
#import "ICUTemplateMatcher.h"
#import "Industry.h"
#import "MGTemplateEngine.h"
#import "NSFileManager+DirectoryLocations.h"
#import "ScheduledTrain.h"
#import "SwitchListFilters.h"


@implementation HTMLSwitchlistRenderer

// Create a new HTMLSwitchlistRenderer.
//   bundle: pointer to app's main bundle, used for finding default switchlist files.
- (id) initWithBundle: (NSBundle*) bundle {
	self = [super init];
    mainBundle_ = [bundle retain];
	templateDirectory_ = nil;
	engine_ = [[MGTemplateEngine alloc] init];
	[engine_ setMatcher: [ICUTemplateMatcher matcherWithTemplateEngine: engine_]];
	[engine_ loadFilter: [[[SwitchListFilters alloc] init] autorelease]];
	return self;
}

- (void) dealloc {
	[engine_ release];
	[templateDirectory_ release];
	[mainBundle_ release];
	[super dealloc];
}

// Directory containing current switchlist template.
- (NSString*) templateDirectory {
	return templateDirectory_;
}

// Sets the current template used for switchlists to the named template.
// The user's application support folder (~/Library/Application Support/SwitchList) will be
// searched first, followed by the Resources directory of the application bundle.
// If no directory with the template's name is found in either directory, then the
// default switchlist will be used.
- (void) setTemplate: (NSString*) templateName {
	if (!templateName || [templateName isEqualToString: DEFAULT_SWITCHLIST_TEMPLATE]) {
		// Either 'Handwritten' or unset. Use defaults.
		[templateDirectory_ release];
		templateDirectory_ = nil;
		return;
	}
	
	NSString *userTemplateDirectory = [[[NSFileManager defaultManager] applicationSupportDirectory] stringByAppendingPathComponent: templateName];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath: userTemplateDirectory]) {
		[templateDirectory_ release];
		templateDirectory_ = [userTemplateDirectory retain];
		return;
	}
	
	// Next, check in the app itself.
	NSString *resourceTemplateDirectory = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: templateName];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath: resourceTemplateDirectory]) {
		[templateDirectory_ release];
		templateDirectory_ = [resourceTemplateDirectory retain];
		return;
	}
	
	[templateDirectory_ release];
	templateDirectory_ = nil;
	return;
}

// Returns the path to the named file, either in the current template directory
// or in the main bundle.  Error if in neither.
- (NSString*) filePathForTemplateFile: (NSString*) filename {
	if (templateDirectory_) {
		NSString *htmlFilePath = [templateDirectory_ stringByAppendingPathComponent: filename];
		if ([[NSFileManager defaultManager] fileExistsAtPath: htmlFilePath]) {
			return htmlFilePath;
		}
	}
	// Default to stock version.
	return [mainBundle_ pathForResource: [filename stringByDeletingPathExtension]
								 ofType: [filename pathExtension]];
}

// Returns the path to the template with the given name, as found in one of the switchlist template
// directories.  If none can be found, it uses the copy in the main bundle.
- (NSString*) filePathForTemplateHtml: (NSString*) template {
	NSString *htmlFilePath;
	if (templateDirectory_) {
		htmlFilePath = [templateDirectory_ stringByAppendingPathComponent: [NSString stringWithFormat: @"%@.html",  template]];
		if ([[NSFileManager defaultManager] fileExistsAtPath: htmlFilePath]) {
			return htmlFilePath;
		}
	}
	// Default to stock version.
	return [mainBundle_ pathForResource: template ofType: @"html"];
}

- (NSString*) filePathForSwitchlistHTML {
	return [self filePathForTemplateHtml: @"switchlist"];
}

// Returns the path to the iPhone-specific HTML file for the current template.
// If the template didn't define an iPhone-specific version, default to the non-iPhone

- (NSString*) filePathForSwitchlistIPhoneHTML {
	NSString *htmlFilePath;
	if (templateDirectory_) {
		htmlFilePath = [templateDirectory_ stringByAppendingPathComponent: @"switchlist-iphone.html"];
		if ([[NSFileManager defaultManager] fileExistsAtPath: htmlFilePath]) {
			return htmlFilePath;
		}
	
		// If there isn't an iPhone specific HTML file in the template directory, use the regular HTML file.
		htmlFilePath = [templateDirectory_ stringByAppendingPathComponent: @"switchlist.html"];
		if ([[NSFileManager defaultManager] fileExistsAtPath: htmlFilePath]) {
			return htmlFilePath;
		}
	}

	// Final fallback: use stock SwitchList iPhone HTML file.
	return [mainBundle_ pathForResource: @"switchlist-iphone" ofType: @"html"];
}

- (NSString*) renderSwitchlistForTrain: (ScheduledTrain*) train layout: (EntireLayout*)layout iPhone: (BOOL) isIPhone {
	NSDictionary *templateDict = [NSDictionary dictionaryWithObjectsAndKeys:
								  train, @"train", 
								  [[[train stationsInOrder] objectAtIndex: 0] name], @"firstStation", 
								  layout, @"layout",
								  [NSNumber numberWithInt: 1], @"interactive",
								  nil];
	NSString *switchlistTemplatePath = (isIPhone ? [self filePathForSwitchlistIPhoneHTML] : [self filePathForSwitchlistHTML]);
	return [engine_ processTemplateInFileAtPath: switchlistTemplatePath
								  withVariables: templateDict];
}

- (NSString*) renderCarlistForLayout: (EntireLayout*) layout {
	NSMutableString *carLocations = [NSMutableString string];
	NSArray *allFreightCars = [[layout allFreightCarsReportingMarkOrder] sortedArrayUsingSelector: @selector(compareNames:)];
	for (FreightCar *freightCar in allFreightCars) {
		[carLocations appendFormat: @"'%@':'%@',", [freightCar reportingMarks], [[freightCar currentLocation] name]];
	}
	NSDictionary *templateDict = [NSDictionary dictionaryWithObjectsAndKeys:
								  allFreightCars, @"freightCars",
								  layout, @"layout",
								  carLocations, @"carLocations",
								  [layout allIndustries], @"allIndustries",
								  [layout allYards], @"allYards",
								  [NSNumber numberWithInt: 1], @"interactive",
								  nil];
	// Note that switchlist-carlist is the interactive version.
	return [self renderReport: @"switchlist-carlist" withDict: templateDict];
}

// Renders a generic report, but allows the caller to specify a template dictionary with
// more than just the layout name.
- (NSString*) renderReport: (NSString*) reportName withDict: (NSDictionary*) dict {
	NSString *industryHtml = [self filePathForTemplateHtml: reportName];
	return [engine_ processTemplateInFileAtPath: industryHtml
								  withVariables: dict];
}

- (NSString*) renderIndustryListForLayout: (EntireLayout*) layout {
	return [self renderReport: @"industry-report" withDict: [NSDictionary dictionaryWithObject: layout
																								forKey: @"layout"]];
}

- (NSString*) renderCargoReportForLayout: (EntireLayout*) layout {
	return [self renderReport: @"cargo-report" withDict: [NSDictionary dictionaryWithObject: layout
																						forKey: @"layout"]];
}

- (NSString*) renderYardReportForLayout: (EntireLayout*) layout {
	return [self renderReport: @"yard-report" withDict: [NSDictionary dictionaryWithObject: layout
																						forKey: @"layout"]];
}

- (NSString*) renderReservedCarReportForLayout: (EntireLayout*) layout {
	return [self renderReport: @"reserved-car-report" withDict: [NSDictionary dictionaryWithObject: layout
																							forKey: @"layout"]];
}

- (NSString*) renderLayoutPageForLayout: (EntireLayout*) layout {
	NSDictionary *templateDict = [NSDictionary dictionaryWithObject: layout forKey: @"layout"];
	return [engine_ processTemplateInFileAtPath: [self filePathForTemplateHtml: @"switchlist-layout"]
								  withVariables: templateDict];
}

- (NSString*) renderLayoutsPageWithLayouts: (NSArray*) allLayouts {
	if ([allLayouts count] == 0) {
		return @"No layouts open in SwitchList!";
	}
	
	NSMutableArray *layoutNames = [NSMutableArray array];
	for (EntireLayout *layout in allLayouts) {
		NSString *layoutName = [layout layoutName];
		if (!layoutName || [layoutName isEqualToString: @""]) {
			// If there's no cars in the layout, ignore.
			if ([[layout allFreightCars] count] > 0) {
				[layoutNames addObject: @"untitled"];
			}
		} else {
			[layoutNames addObject: layoutName];
		}
	}
	
	NSDictionary *templateDict = [NSDictionary dictionaryWithObject: layoutNames forKey:  @"layoutNames"];
	NSString *message = [engine_ processTemplateInFileAtPath: [self filePathForTemplateHtml: @"switchlist-home"]
											   withVariables: templateDict];
	return message;
}
@end
