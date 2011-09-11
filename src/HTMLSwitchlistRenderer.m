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

#import "FreightCar.h"
#import "GlobalPreferences.h"
#import "HTMLSwitchlistRenderer.h"
#import "ICUTemplateMatcher.h"
#import "Industry.h"
#import "MGTemplateEngine.h"
#import "NSFileManager+DirectoryLocations.h"
#import "ScheduledTrain.h"
#import "SwitchListDocument.h"
#import "SwitchListFilters.h"


@implementation HTMLSwitchlistRenderer

// Create a new HTMLSwitchlistRenderer.
//   bundle: pointer to app's main bundle, used for finding default switchlist files.
- (id) initWithBundle: (NSBundle*) bundle {
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

- (NSString*) filePathForSwitchlistIPhoneCSS {
	NSString *cssFilePath;
	if (templateDirectory_) {
		cssFilePath = [templateDirectory_ stringByAppendingPathComponent: @"switchlist-iphone.css"];
		if ([[NSFileManager defaultManager] fileExistsAtPath: cssFilePath]) {
			return cssFilePath;
		}
	}
	return [mainBundle_ pathForResource: @"switchlist-iphone" ofType: @"css"];
}


- (NSString *) filePathForSwitchlistIPadCSS {
	NSString *cssFilePath;
	if (templateDirectory_) {
		cssFilePath = [templateDirectory_ stringByAppendingPathComponent: @"switchlist-ipad.css"];
		if ([[NSFileManager defaultManager] fileExistsAtPath: cssFilePath]) {
			return cssFilePath;
		}
	}
	
	return [mainBundle_ pathForResource: @"switchlist-ipad" ofType: @"css"];
}

- (NSString *) filePathForSwitchlistCSS {
	NSString *cssFilePath;
	if (templateDirectory_) {
		cssFilePath = [templateDirectory_ stringByAppendingPathComponent: @"switchlist.css"];
		if ([[NSFileManager defaultManager] fileExistsAtPath: cssFilePath]) {
			return cssFilePath;
		}
	}
	
	return [mainBundle_ pathForResource: @"switchlist" ofType: @"css"];
}

- (NSString*) filePathForSwitchlistHTML {
	NSString *htmlFilePath;
	if (templateDirectory_) {
		htmlFilePath = [templateDirectory_ stringByAppendingPathComponent: @"switchlist.html"];
		if ([[NSFileManager defaultManager] fileExistsAtPath: htmlFilePath]) {
			return htmlFilePath;
		}
	}
	
	return [mainBundle_ pathForResource: @"switchlist" ofType: @"html"];
}

- (NSString*) filePathForSwitchlistIPhoneHTML {
	NSString *htmlFilePath;
	if (templateDirectory_) {
		htmlFilePath = [templateDirectory_ stringByAppendingPathComponent: @"switchlist-iphone.html"];
		if ([[NSFileManager defaultManager] fileExistsAtPath: htmlFilePath]) {
			return htmlFilePath;
		}
	}
	
	return [mainBundle_ pathForResource: @"switchlist-iphone" ofType: @"html"];
}

- (NSString*) renderSwitchlistForTrain: (ScheduledTrain*) train layout: (EntireLayout*)layout iPhone: (BOOL) isIPhone {
	NSDictionary *templateDict = [NSDictionary dictionaryWithObjectsAndKeys:
								  train, @"train", 
								  [[train stationStopStrings] objectAtIndex: 0],@"firstStation", 
								  layout, @"layout",
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
								  nil];
	return [engine_ processTemplateInFileAtPath: [mainBundle_ pathForResource: @"switchlist-carlist" ofType: @"html"]
								  withVariables: templateDict];
}

- (NSString*) renderIndustryListForLayout: (EntireLayout*) layout {
	NSDictionary *templateDict = [NSDictionary dictionaryWithObject: layout forKey:  @"layout"];
	NSString *industryHtml = [mainBundle_ pathForResource: @"switchlist-industrylist" ofType: @"html"];
	return [engine_ processTemplateInFileAtPath: industryHtml
								  withVariables: templateDict];
}

- (NSString*) renderLayoutPageForLayout: (EntireLayout*) layout {
	NSDictionary *templateDict = [NSDictionary dictionaryWithObject: layout forKey: @"layout"];
	return [engine_ processTemplateInFileAtPath: [mainBundle_ pathForResource: @"switchlist-layout" ofType: @"html"]
								  withVariables: templateDict];
}

- (NSString*) renderLayoutsPage{
	NSDocumentController *controller = [NSDocumentController sharedDocumentController];
	NSArray *allDocuments = [controller documents];
	if ([allDocuments count] == 0) {
		return @"No layouts open in SwitchList!";
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
	return message;
}
@end
