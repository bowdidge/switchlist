//
//
//  typical_main.m
//  SwitchList
//
//  Created by bowdidge on 8/12/12.
//
// Copyright (c)2012 Robert Bowdidge,
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

#import <Foundation/Foundation.h>
#import <LatentSemanticMapping/LatentSemanticMapping.h>

#import "Cargo.h"
#import "EntireLayout.h"
#import "Industry.h"
#import "LayoutController.h"
#import "NSMigrationManagerCategory.h"
#import "TypicalIndustryStore.h"

#import "unistd.h"

// Command-line tool for testing Latent Semantic Meaning routines used to infer
// actual kind of industry name.
//
// This tool supports two possible uses:
// 1) (default): give suggestions on a set of canned industry names.  For testing.
// 2) -b: build new cargo rules depending on a named layout file.
// 
// Creates NSManagedObjectModel for the named database schema.
NSManagedObjectModel *managedObjectModel(NSString* momPath) {
    NSURL *modelURL = [NSURL fileURLWithPath:momPath];
    return [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
}

// Generates the NSManagedObjectContext for the named persistent layout and schema.
NSManagedObjectContext *managedObjectContext(NSString* momPath, NSString* storePath) {
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: managedObjectModel(momPath)];
    [context setPersistentStoreCoordinator: coordinator];
	
    NSString *STORE_TYPE = NSXMLStoreType;
    NSURL *url = [NSURL fileURLWithPath:storePath];
    NSError *error;
    NSPersistentStore *newStore = [coordinator addPersistentStoreWithType:STORE_TYPE configuration:nil URL:url options:nil error:&error];
	
    if (newStore == nil) {
        NSLog(@"ERROR: %@: Store Configuration Failure\n%@", storePath,
              ([error localizedDescription] != nil) ?
              [error localizedDescription] : @"Unknown Error");
		return nil;
    }
	
    return context;
}

// Sends some typical industry names to the TypicalIndustryStore, and prints out its
// recommendations about category of industry and possible cargos.
void TestIndustries(NSString *industryPlistFile) {
	TypicalIndustryStore *typicalIndustryFinder = [[TypicalIndustryStore alloc] initWithIndustryPlistFile: industryPlistFile];
	
	[typicalIndustryFinder helpUser: @"Ainsley Cannery"];
	[typicalIndustryFinder helpUser: @"Bennett Lumber"];
	[typicalIndustryFinder helpUser: @"North Hollywood Depot"];
	[typicalIndustryFinder helpUser: @"Sunkist Packing House"];
	[typicalIndustryFinder helpUser: @"Sheller Feed Company"];
	[typicalIndustryFinder helpUser: @"B C Ice & Cold Storage"];
	[typicalIndustryFinder helpUser: @"cannery"];
	[typicalIndustryFinder helpUser: @"Bapco Paint"];
	[typicalIndustryFinder helpUser: @"Bay Lumber"];
	[typicalIndustryFinder helpUser: @"cannery"];
	[typicalIndustryFinder helpUser: @"packing house"];
	[typicalIndustryFinder helpUser: @"lumber yard"];
}

// Runs through industries in the named layout file, compares them to categories
// from TypicalIndustryFinder to name best fit, then prints out their current cargos
// in a way that can be put in the master list of typical industries.
BOOL BuildCargos(NSString *industryPlistFile, NSString *layoutFile) {
	TypicalIndustryStore *typicalIndustryFinder = [[TypicalIndustryStore alloc] initWithIndustryPlistFile: industryPlistFile];
  if ([[NSFileManager defaultManager] fileExistsAtPath: layoutFile] == NO) {
	NSLog(@"ERROR: No such file %@\n", layoutFile);
	return NO;
  }
		
	// TODO(bowdidge): Infer or allow as parameter.
	NSString *pathToMom =  @"/SharedProducts/Debug/SwitchList.app/Contents/Resources/SwitchListDocument.momd/SwitchListDocument 4.mom";
	if ([[NSFileManager defaultManager] fileExistsAtPath: pathToMom] == NO) {
		NSLog(@"FAIL: %@: Configuration error: expected schema file at %@, but not found", layoutFile, pathToMom);
		return NO;
	}
		
	NSManagedObjectContext *context = managedObjectContext(pathToMom, layoutFile);
	if (!context) {
		NSLog(@"FAIL: %@: Setup error: problems loading file.  (Incompatible version?)", layoutFile);
		return NO;
	}
	EntireLayout *entireLayout = [[EntireLayout alloc] initWithMOC: context];
	
	for (Industry* industry in [entireLayout allIndustries]) {
		NSArray *categories = [typicalIndustryFinder categoriesForIndustryName: [industry name]];
		NSNumber *firstCategory = [categories objectAtIndex: 0];
		NSDictionary *categoryDict = [typicalIndustryFinder industryDictForCategory: firstCategory];
			  
		NSMutableArray *outgoingLoads = [NSMutableArray array];
		NSMutableArray *incomingLoads = [NSMutableArray array];

		int totalCarsPerWeek = 0;
		for (Cargo *c in [entireLayout allCargos]) {
			if ([c source] == industry) {
				[outgoingLoads addObject: c];
				totalCarsPerWeek += [[c carsPerWeek] intValue];
			}
			if ([c destination] == industry) {
				[incomingLoads addObject: c];
				totalCarsPerWeek += [[c carsPerWeek] intValue];
			}
		}
			
		printf("------------------\n");
		printf("%s: think it's the %s category.\n", [[industry name] UTF8String], [[categoryDict objectForKey: @"IndustryClass"] UTF8String]);
		printf("<key>Cargo</key>\n  <array>\n", [[industry name] UTF8String]);
		for (Cargo *c in outgoingLoads) {
			printf("    <dict>\n");
			printf("      <key>Name</key><string>%s</string>\n", [[c name] UTF8String]);
			printf("      <key>Incoming</key><false/>\n");
			printf("      <key>Rate</key><integer>%d</integer>\n", [[c carsPerWeek] intValue] * 100 / totalCarsPerWeek);
			printf("    </dict>\n");
		}
		for (Cargo *c in incomingLoads) {
			printf("    <dict>\n");
			printf("      <key>Name</key>\n<string>%s</string>\n", [[c name] UTF8String]);
			printf("      <key>Incoming</key><false/>\n");
			printf("      <key>Rate</key><integer>%d</integer>\n", [[c carsPerWeek] intValue] * 100 / totalCarsPerWeek);
			printf("    </dict>\n");
		}
		printf("  </array>\n  </dict>\n");
	}
	return YES;
}

void usage() {
	fprintf(stderr, "Usage: typical_main typicalIndustry.plist\n");
	fprintf(stderr, "   or: typical_main -b layoutFile typicalIndustry.plist\n");
	fprintf(stderr, "Regular option tests some canned industry names.  -b builds new cargo lists from layoutFile.\n");
	exit(1);
}

int main (int argc, char * const argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	BOOL build = NO;
	char ch;
	const char *layoutFileStr = nil;
	while ((ch = getopt(argc, argv, "b:")) != -1) {
		switch (ch) {
			case 'b':
				build = YES;
				layoutFileStr = optarg;
				break;
			default:
				usage();
		}
	}
	argc -= optind;
	argv += optind;
	if (argc != 1) {
		usage();
	}

	// insert code here...
	NSString *industryPlistFile =  [NSString stringWithUTF8String: argv[0]];

	if (!build) {
		TestIndustries(industryPlistFile);
	} else {
		NSString *layoutFile = [NSString stringWithUTF8String: layoutFileStr];
		BuildCargos(industryPlistFile, layoutFile);
	}
										
	[pool drain];
    return 0;
}
