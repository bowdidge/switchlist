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

#import "TypicalIndustryStore.h"

#import "BKClassifier.h"

@implementation TypicalIndustryStore

- (id) init {
    [super init];
    self.classifier = [[[BKClassifier alloc] init] autorelease];
    self.typicalIndustries = [NSMutableArray array];
    self.categoryMap = [NSMutableDictionary dictionary];
    return self;
}


// Reads the typical industry database file, and produces the array of objects
// described in its plist format.
- (NSArray*) readTypicalIndustryFile: (NSString*) trainingFile {
	NSString *errorDesc = nil;
	NSPropertyListFormat format;
	NSArray *result;
	NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath: trainingFile];
	result = (NSArray *)[NSPropertyListSerialization
                         propertyListFromData:plistXML
                         mutabilityOption:NSPropertyListMutableContainersAndLeaves
                         format:&format
                         errorDescription:&errorDesc];
    
	if (!result) {
		NSLog(@"Error reading plist: %@", errorDesc);
		return nil;
	}
    for (NSDictionary *item in result) {
        NSString *industryClass = [item objectForKey: @"IndustryClass"];
		[self.categoryMap setObject: item forKey: industryClass];
    }
	return result;
}

NSArray* NameStringToTokens(NSString* name) {
    NSString *cleanedString = [[[[[[[name lowercaseString]
                               stringByReplacingOccurrencesOfString: @"(" withString:@""]
                               stringByReplacingOccurrencesOfString: @")" withString:@""]
                               stringByReplacingOccurrencesOfString: @"'" withString:@""]
                               stringByReplacingOccurrencesOfString: @"&" withString:@""]
                               stringByReplacingOccurrencesOfString: @"." withString: @""]
                               stringByReplacingOccurrencesOfString: @"-" withString: @" "];
    
    NSMutableArray *results = [NSMutableArray arrayWithArray: [cleanedString componentsSeparatedByString: @" "]];
    // TODO(bowdidge): Replace city names and stations with PLACENAME?
    // Remove words unlikely to provide hints.
    [results removeObject: @"company"];
    [results removeObject: @"co"];
    [results removeObject: @"corporation"];
    [results removeObject: @"inc"];
    // Double weight of last word.
    if ([results count] == 2) {
        // Add last word on assumption it's usually kind of business, unless it's plant when we'll look at first.
        if ([[results objectAtIndex: 1] isEqualToString: @"plant"]) {
            [results addObject: [results objectAtIndex: 0]];
        } else {
            [results addObject: [results objectAtIndex: 1]];
        }
    }
    return results;
}

- (void) trainString: (NSString*) string asCategory: (NSString*) category {
    [self.classifier trainWithTokens: NameStringToTokens(string)
                              inPool: [self.classifier poolNamed: category]];
}

// Creates an LSM map in memory from the typical industry database,
// and prepares the map for lookups.
// Only needed if no compiled training results are available.
- (void) makeMapFromIndustryList: (NSArray*) industryList {
	// TODO(bowdidge): Include stop words.
    for (NSDictionary *item in industryList) {
        NSString *industryClass = [item objectForKey: @"IndustryClass"];
        //[self.classifier trainWithTokens: NameStringToTokens(industryClass) inPool: [self.classifier poolNamed: industryClass]];
        NSArray *synonyms = [item objectForKey: @"Synonyms"];
        for (id syn in synonyms) {
            // TODO(bowdidge): Consider mixing in other tokens - other loads, etc?
            // TODO(bowdidge): Consider cutting out known non-words - Co, &, etc.
            // Treat some prefixes as stand-alone words - Chem*, *Star,
            // Strip punctuation, parens, plurals, etc?
            [self trainString: syn asCategory: industryClass];
        }
    }
}

// Creates a TypicalIndustryStore based on an in-memory version of
// the plist contents.  For testing.
- (id) initWithIndustryPlistArray: (NSArray*) industryFileContents {
	self = [self init];
	[self makeMapFromIndustryList: industryFileContents];
	return self;
}	
	
// Creates a TypicalIndustryStore based on the on-disk version of the
// typical industry database.
- (id) initWithIndustryPlistFile: (NSString*) industryPlistFile {
    self = [self init];
    self.typicalIndustries = [self readTypicalIndustryFile: industryPlistFile];
	if (!self.typicalIndustries) {
		return nil;
	}
	[self makeMapFromIndustryList: self.typicalIndustries];
	return self;
}


// Initialize with the .bks training file from BKClassifier.
- (id) initWithIndustryTrainingFile: (NSString*) trainingFilename withIndustryPlistFile: (NSString*) industryPlistFile {
    self = [self init];
    self.typicalIndustries = [self readTypicalIndustryFile: industryPlistFile];
    self.classifier = [[BKClassifier alloc] initWithContentsOfFile: trainingFilename];
    
    return self;
}

- (NSArray*) allCategoryNames {
    return [self.classifier.pools allKeys];
}

// Returns a list of categories (as NSStrings) describing the best fits for the
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
    
    NSArray *tokens = NameStringToTokens(industryName);
    NSDictionary *categoriesAndScores = [self.classifier guessWithTokens: tokens];
    
    // Consider scaling score by number of terms?
    NSArray *categoryNames = [categoriesAndScores keysSortedByValueUsingSelector: @selector(compare:)];

    NSMutableArray *result = [NSMutableArray array];
    for (NSString *category in categoryNames) {
        if ([[categoriesAndScores objectForKey: category] floatValue] < threshold) {
            break;
        }
        [result addObject: category];
    }
    
    return [[result reverseObjectEnumerator] allObjects];
}

// Human-readable.  Print the matching categories.
- (void) printCategoriesForIndustryName: (NSString*) industryName {
    NSArray *tokens = NameStringToTokens(industryName);
    NSDictionary *categoriesAndScores = [self.classifier guessWithTokens: tokens];

	NSLog(@"Classification for %@", industryName);
	for (NSNumber *categoryName in [categoriesAndScores allKeys]) {
		NSNumber *categoryScore = [categoriesAndScores objectForKey: categoryName];
		NSLog(@"  Potential: %@: %f", categoryName, [categoryScore floatValue]);
	}
}

// Returns the list of categories (as NSString) that best match the
// named industries.  Use industryDictForCategory: to find details of the
// match.
- (NSArray*) categoriesForIndustryName: (NSString*) industryName {
	return [self categoriesForIndustryName: industryName threshold: 0.0];
}

// Given an incoming industry name, finds a set of categories and scores
// of typical industries that may be the same.
- (NSDictionary*) categoriesAndScoresForIndustryName: (NSString*) industryName {
    NSArray *tokens = NameStringToTokens(industryName);
    return [self.classifier guessWithTokens: tokens];
}

// Give full record on the canonical category, including generic name,
// synonyms, and sample cargos.
- (NSDictionary*) industryDictForCategory: (NSString*) category {
    return [self.categoryMap objectForKey: category];
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
		NSLog(@"    %@", category);
	}
	NSDictionary *dict = [self industryDictForCategory: [categories objectAtIndex: 0]];
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
