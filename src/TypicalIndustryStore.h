//
//
//  TypicalIndustryStore.h
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

#import "BKClassifier.h"

// Allows matching a new industry name to a class of industry, and provides information
// on that typical industry - synonyms, likely cargos, etc.
@interface TypicalIndustryStore: NSObject {
}

// Initialize the TypicalIndustryStore with data from the named file.
// Regenerates the LSM Map.
- (id) initWithIndustryPlistFile: (NSString*) industryPlistFilename;

// Initialize with the .bks training file from BKClassifier.
- (id) initWithIndustryTrainingFile: (NSString*) trainingFilename withIndustryPlistFile: (NSString*) industryPlistFile ;

// For testing only.
- (id) initWithIndustryPlistArray: (NSArray*) industryPListArray;

- (void) trainString: (NSString*) string asCategory: (NSString*) category;

// All category canonical names.
- (NSArray*) allCategoryNames;

// Given an incoming industry name, finds a set of categories
// of typical industries that may be the same.
- (NSArray*) categoriesForIndustryName: (NSString*) name;

// Given an incoming industry name, finds a set of categories and scores
// of typical industries that may be the same.
- (NSDictionary*) categoriesAndScoresForIndustryName: (NSString*) name;

// Returns the raw data on the typical industry.
- (NSDictionary*) industryDictForCategory: (NSString*) category;

// Human readable description of what advice we might give for the industry.
- (void) helpUser: (NSString*) industryName;
- (void) printCategoriesForIndustryName: (NSString*) industryName;

// Break a name into tokens for each word, and skip some uninteresting words.
NSArray* NameStringToTokens(NSString* industryName);

@property (retain, nonatomic) BKClassifier *classifier;
// Raw list of industry classes from XML file.
@property (retain, nonatomic) NSArray *typicalIndustries;
// Map from category number to category's canonical name.
@property (retain, nonatomic) NSMutableDictionary *categoryMap;

@end
