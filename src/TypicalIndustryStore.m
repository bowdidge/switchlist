//
//
//  TypicalIndustryStoreTest.m
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

#import "TypicalIndustryStore.h"

@implementation TypicalIndustryStore

// Read the LSM's map file from disk.
// Currently not used - regenerated each time.
- (void) readMapFromFile: (NSString*) industryMapFile {
	NSURL *url = [NSURL fileURLWithPath: industryMapFile];
	industryMap_ = LSMMapCreateFromURL(kCFAllocatorDefault, (CFURLRef) url, 0);
	LSMMapCompile(industryMap_);
}

// Creates an LSM map in memory from the typical industry database,
// and prepares the map for lookups.
- (void) makeMapFromIndustryDict {
	// TODO(bowdidge): Include stop words.
	industryMap_ = LSMMapCreate(kCFAllocatorDefault, 0);
	LSMMapStartTraining(industryMap_);
		
	for (NSDictionary *industry in typicalIndustries_) {
		NSString *industryName = [industry objectForKey: @"IndustryClass"];
		NSArray *synonyms = [industry objectForKey: @"Synonyms"];
		LSMCategory industryCategory = LSMMapAddCategory(industryMap_);
		// TODO(bowdidge): FIXME.
		[categoryMap_ setValue: industryName forKey: (NSString*) [NSNumber numberWithInt: industryCategory]];
		
		LSMTextRef textRef = LSMTextCreate(kCFAllocatorDefault,  industryMap_);
		LSMTextAddWords(textRef, (CFStringRef) industryName, CFLocaleGetSystem(), 0);
		LSMMapAddText(industryMap_, textRef, industryCategory);
		for (NSString *synonym in synonyms) {
			LSMTextRef synonymTextRef = LSMTextCreate(kCFAllocatorDefault,  industryMap_);
			LSMTextAddWords(synonymTextRef, (CFStringRef) synonym, CFLocaleGetSystem(), 0);
			LSMMapAddText(industryMap_, synonymTextRef, industryCategory);
		}
	}
	LSMMapCompile(industryMap_);
}

// Reads the typical industry database file, and produces the array of objects
// described in its plist format.
- (NSArray *) readIndustryFile: (NSString*) typicalIndustriesFile {
	NSString *errorDesc = nil;
	NSPropertyListFormat format;
	NSArray *result;
	NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath: typicalIndustriesFile];
	result = (NSArray *)[NSPropertyListSerialization
								propertyListFromData:plistXML
								mutabilityOption:NSPropertyListMutableContainersAndLeaves
								format:&format
								errorDescription:&errorDesc];
		
	if (!result) {
		NSLog(@"Error reading plist: %@, format: %ld", errorDesc, format);
		return nil;
	}
	return result;
}

// Creates a TypicalIndustryStore based on an in-memory version of
// the plist contents.  For testing.
- (id) initWithIndustryPlistArray: (NSArray*) industryFileContents {
	self = [super init];
	
	categoryMap_ = [[NSMutableDictionary alloc] init];
	typicalIndustries_ = [industryFileContents retain];
	[self makeMapFromIndustryDict];
	return self;
}	
	
// Creates a TypicalIndustryStore based on the on-disk version of the
// typical industry database.
- (id) initWithIndustryPlistFile: (NSString*) industryPlistFile {
    NSArray *industryFileContents = [self readIndustryFile: industryPlistFile];
	if (!industryFileContents) {
		return nil;
	}
	
	self = [self initWithIndustryPlistArray: industryFileContents];
	return self;
}

- (void) dealloc {
	CFRelease(industryMap_);
	[typicalIndustries_ release];
	[categoryMap_ release];
	[super dealloc];
}

- (NSArray*) allCategoryNames {
	NSMutableArray *result = [NSMutableArray array];
	for (NSString *categoryName in [categoryMap_ allValues]) {
		[result addObject: categoryName];
	}
	return result;
}
// Returns a list of categories (as NSNumbers) describing the best fits for the
// industry named.  The threshold value sets a cutoff for (compared to the best
// match.  By taking the best match's score and dividing by threshold, it sets a lower
// bound on the quality of lesser matches that will be shown.  The first match will
// always be shown.
- (NSArray*) categoriesForIndustryName: (NSString*) industryName threshold: (float) threshold {
    // TODO(bowdidge): Catch this error higher up, and provide a more
    // helpful message when trying to get suggested cargos for a null
    // industry name.
    if (!industryName) {
        return [NSArray array];
    }
    
	LSMTextRef textRef = LSMTextCreate(kCFAllocatorDefault,  industryMap_);
	LSMTextAddWords(textRef, (CFStringRef) industryName, CFLocaleGetSystem(), 0);
	LSMResultRef result = LSMResultCreate(kCFAllocatorDefault, industryMap_,
										  textRef, 4, 0);
	NSMutableArray *results = [NSMutableArray array];
	int i;
	float bestScore = LSMResultGetScore(result, 0);
	// Always add first.
	[results addObject: [NSNumber numberWithInt: LSMResultGetCategory(result, 0)]];
	for (i=1;i<4;i++) {
		float currentScore = LSMResultGetScore(result, i);
		if (bestScore > currentScore * threshold) {
			break;
		}
		[results addObject: [NSNumber numberWithInt: LSMResultGetCategory(result, i)]];
	}
	CFRelease(textRef);
	CFRelease(result);
	return results;
}

// Human-readable.  Print the matching categories.
- (void) printCategoriesForIndustryName: (NSString*) industryName {
	NSArray *categories = [self categoriesForIndustryName: industryName threshold: 1.6];
	NSLog(@"Classification for %@", industryName);
	for (NSNumber *category in categories) {
		NSString *categoryName = [categoryMap_ objectForKey: category];
		NSLog(@"  Potential: %@", categoryName);
	}
	NSLog(@"");
}

// Returns the list of categories (as NSNumber) that best match the
// named industries.  Use industryDictForCategory: to find details of the
// match.
- (NSArray*) categoriesForIndustryName: (NSString*) industryName {
	return [self categoriesForIndustryName: industryName threshold: 1.5];
}

// Give the canonical name for the category.
- (NSString*) industryNameForCategory: (NSNumber*) category {
	return [categoryMap_ objectForKey: category];
}

// Give full record on the canonical category, including generic name,
// synonyms, and sample cargos.
- (NSDictionary*) industryDictForCategory: (NSNumber*) category {
	NSString *industryName = [categoryMap_ objectForKey: category];
	for (NSDictionary *industry in typicalIndustries_) {
		if ([[industry objectForKey: @"IndustryClass"] isEqualToString: industryName]) {
			return industry;
		}
	}
	return nil;
}

// Given a canonical name for an industry (which should be unique), return the NSNumber
// identifying that particular category which is an index to the industry dictionary.
- (NSNumber*) categoryWithCanonicalName: (NSString*) canonicalName {
	for (NSNumber* category in [categoryMap_ allKeys]) {
		if ([[categoryMap_ objectForKey: category] isEqualToString: canonicalName]) {
			return category;
		}
	}
	return nil;
}

// Provides human-readable response of related typical industries.
// For development only.
- (void) helpUser: (NSString*) industryName {
	NSArray *categories = [self categoriesForIndustryName: industryName];
	if ([categories count] == 0) {
		NSLog(@"No hints for industry %@", industryName);
	}
	
	NSLog(@"%@ might be one of the following industries:", industryName);
	for (NSNumber *category in categories) {
		NSLog(@"    %@", [self industryNameForCategory: category]);
	}
	NSNumber* firstCategory = [categories objectAtIndex: 0];
	NSDictionary *dict = [self industryDictForCategory: firstCategory];
	NSArray *cargoSuggestions = [dict objectForKey: @"Cargo"];
	if (cargoSuggestions && [cargoSuggestions count] > 0) {
		NSLog(@"  Potential cargos for most likely choice are:");
		for (NSDictionary *cargo in cargoSuggestions) {
			NSLog(@"    %@", [cargo objectForKey: @"Name"]);
		}
	} else {
		NSLog(@"  No suggestions for cargo.");
	}
}
	
	
@end
