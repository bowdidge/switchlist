//
//  TemplateCache.m
//  SwitchList
//
//  Created by bowdidge on 8/16/14.
//
// Copyright (c)2014 Robert Bowdidge,
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

#import "TemplateCache.h"

#import <Foundation/Foundation.h>

#import "GlobalPreferences.h"
#import "NSFileManager+DirectoryLocations.h"

@implementation TemplateCache

- (id) init {
    self = [super init];
    self.theFileManager = [NSFileManager defaultManager];
    return self;
}

// For testing.
- (id) initWithFileManager: (NSFileManager*) fileManager {
    self = [super init];
    self.theFileManager = fileManager;
    return self;
}

// TODO(bowdidge): Make common code between iPad and Mac.
// Returns true if a directory named "name" exists in the specified directory,
// and if "name" contains a switchlist.html file suggesting it's a real template.
- (BOOL) isSwitchlistTemplate: (NSString*) name inDirectory: (NSString*) directory {
	BOOL isDirectory = NO;
	if (![self.theFileManager fileExistsAtPath: [directory stringByAppendingPathComponent: name]
                                              isDirectory: &isDirectory] || isDirectory == NO) {
		return NO;
	}
	// Does a switchlist.html directory exist there?
	if ([self.theFileManager fileExistsAtPath: [[directory stringByAppendingPathComponent: name]
                                                           stringByAppendingPathComponent: @"switchlist.html"]]) {
		return YES;
	}
	return NO;
}

// Return the list of valid template names that exist.
// TODO(bowdidge): Cache result for a short time.
- (NSArray*) validTemplateNames {
	// Handwritten is always valid - uses defaults.
	NSMutableArray *result = [NSMutableArray arrayWithObject: DEFAULT_SWITCHLIST_TEMPLATE];
    
	NSError *error;
	// First find templates in application support directory.
	NSString *applicationSupportDirectory = [self.theFileManager applicationSupportDirectory];
	NSArray *filesInApplicationSupportDirectory = [self.theFileManager contentsOfDirectoryAtPath: applicationSupportDirectory
                                                                                                      error: &error];
	for (NSString *file in filesInApplicationSupportDirectory) {
		if ([self isSwitchlistTemplate: file inDirectory: applicationSupportDirectory]) {
			[result addObject: file];
		}
	}
	
	// Next, find templates in the bundle directory.  User templates with the same name win.
	NSString *resourcesDirectory = [[NSBundle mainBundle] resourcePath];
	NSArray *filesInResourcesDirectory = [self.theFileManager contentsOfDirectoryAtPath: resourcesDirectory
                                                                                             error: &error];
	for (NSString *file in filesInResourcesDirectory) {
		if ([self isSwitchlistTemplate: file inDirectory: resourcesDirectory]) {
			if ([result containsObject: file] == NO) {
				[result addObject: file];
			}
		}
	}
	return [result sortedArrayUsingSelector: @selector(compare:)];
}


@synthesize theFileManager;
@end
