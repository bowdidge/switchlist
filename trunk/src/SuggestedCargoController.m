// 
//  SuggestedCargoController.m
//  SwitchList
//
//  Created by Robert Bowdidge on 8/12/12.
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

// Still to do:
// Fill in more samples.
// Add a "send suggestions" button.
// Allow changing time without losing keep settings.


#import <Cocoa/Cocoa.h>
#import <CoreData/CoreData.h>

#import "Cargo.h"
#import "EntireLayout.h"
#import "InduYard.h"
#import "Industry.h"
#import "SuggestedCargoController.h"
#import "SwitchListDocument.h"
#import "TypicalIndustryStore.h"

@implementation ProposedCargo 
@synthesize isKeep;
@synthesize isReceive;
@synthesize name;
@synthesize carsPerWeek;

- (Industry*) industry {
	return industry;
}

- (void) setIndustry: (Industry*) newIndustry {
	[industry release];
	industry = [newIndustry retain];
}

@end

@implementation SuggestedCargoController

- (id) init {
	[super init];
	NSString *industryFile = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"/typicalIndustry.plist"];
	store_ = [[TypicalIndustryStore alloc] initWithIndustryPlistFile: industryFile];
	return self;
}

- (void) dealloc {
	[store_ release];
	[super dealloc];
}

- (NSWindow*) window {
	return window_;
}

// Callbacks to trigger the reordering of all the popup buttons listing places and other things
// that deserve sorting alphabetically.
- (void)rearrangeCurrentIndustryArrayController:(NSNotification *)note
{
    [currentIndustryArrayController_ rearrangeObjects];
	// Clear check box on all menu items.  Not sure why they're there.
	for (NSMenuItem *item in [currentIndustryButton_ itemArray]) {
		[item setState: 0];
	}
} 

- (void)rearrangeIndustryColumnArrayController:(NSNotification *)note
{
    [industryColumnArrayController_ rearrangeObjects];
} 

- (void) awakeFromNib {
	[suggestedIndustriesButton_ removeAllItems];
	
	[cancelButton_ setTarget: self];
	[cancelButton_ setAction: @selector(doCancel:)];

	[createButton_ setTarget: self];
	[createButton_ setAction: @selector(doCreate:)];

	[suggestedIndustriesButton_ setTarget: self];
	[suggestedIndustriesButton_ setAction: @selector(doChangeIndustryClass:)];

	[currentIndustryButton_ setTarget: self];
	[currentIndustryButton_ setAction: @selector(doChangeIndustry:)];
	
	// Default value.
	[desiredCarsPerWeek_ setStringValue: @"12"];

	// Sort current industry popup alphabetically.
	NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc]
										 initWithKey: @"name" ascending:YES] autorelease];
	
	[currentIndustryArrayController_ setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector: @selector(rearrangeCurrentIndustryArrayController:)

												 name:NSPopUpButtonWillPopUpNotification
											   object: currentIndustryButton_];
	
	[currentIndustryArrayController_ addObserver:self forKeyPath:@"content" options:0 context:nil];

	// Sort current industry popup alphabetically.	
	[industryColumnArrayController_ setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector: @selector(rearrangeIndustryColumnArrayController:)
	 
												 name:NSPopUpButtonWillPopUpNotification
											   object: currentIndustryButton_];
	
	[industryColumnArrayController_ addObserver:self forKeyPath:@"content" options:0 context:nil];
}
	
// Only used to watch for the content being set in the currentIndustryArrayController_, and having it trigger
// loading of the rest of the UI.
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (object == currentIndustryArrayController_) {
		[currentIndustryArrayController_ rearrangeObjects];
		[currentIndustryArrayController_ removeObserver:self forKeyPath:@"content"];
		[self doChangeIndustry: self];
	}
}

// Returns a default industry likely to be a source / destination of any industry.
- (Industry*) likelyDestination {
	NSArray *allIndustries = [[document_ entireLayout] allIndustries];
	Industry *mostPopularStagingIndustry = nil;
	int mostPopularCargoCount = 0;
	for (Industry *i in allIndustries) {
		if ([i isStaging] || [i isOffline]) {
			int cargoCount = [[i originatingCargos] count] + [[i terminatingCargos] count];
			if (!mostPopularStagingIndustry || cargoCount > mostPopularCargoCount) {
				mostPopularStagingIndustry = i;
				mostPopularCargoCount = cargoCount;
			}
		}
	}
	
	if (mostPopularStagingIndustry) {
		return mostPopularStagingIndustry;
	}
	
	// Next, try most popular industry in general?
	Industry *mostPopularIndustry = nil;
	for (Industry *i in allIndustries) {
		int cargoCount = [[i originatingCargos] count] + [[i terminatingCargos] count];
		if (!mostPopularStagingIndustry || cargoCount > mostPopularCargoCount) {
			mostPopularStagingIndustry = i;
			mostPopularCargoCount = cargoCount;
		}
	}

	// return most popular industry or nil if none.
	if (mostPopularIndustry) {
		return mostPopularIndustry;
	}
	
	return [[document_ entireLayout] workbenchIndustry];
}

// Reloads the table with data for the provided category.
- (void) setCargosToCategory: (NSNumber*) category {
	NSDictionary *industryDict = [store_ industryDictForCategory: category];

	NSMutableArray *newContents= [NSMutableArray array];
	Industry *likelyDestination = [self likelyDestination];
	
	for (NSDictionary *cargo in [industryDict objectForKey: @"Cargo"]) {
		ProposedCargo *c = [[[ProposedCargo alloc] init] autorelease];
		[c setName: [cargo objectForKey: @"Name"]];
		// TODO(bowdidge): Consider era.
		// NSString *era = [cargo objectForKey: @"Era"];
		[c setIsKeep: [NSNumber numberWithBool: YES]];
		int isReceive = ([[cargo objectForKey: @"Incoming"] intValue] == 0);
		NSString *receiveString =  isReceive ? @"Ship" : @"Receive";
		[c setIsReceive: receiveString];
		[c setIndustry: likelyDestination];
		int rate = [[cargo objectForKey: @"Rate"] intValue];
		int totalCarsPerWeek = [desiredCarsPerWeek_ intValue];
		int carsPerWeek = (totalCarsPerWeek * rate) / 100;
		if (carsPerWeek < 1) {
			carsPerWeek = 1;
		}
		[c setCarsPerWeek: [NSNumber numberWithInt: carsPerWeek]];
		[newContents addObject: c];
	}

	[proposedCargoArrayController_ setContent: newContents];
}
	
- (IBAction) doChangeCarsPerWeek: (id) sender {
	NSString *suggestedIndustry = [suggestedIndustriesButton_ titleOfSelectedItem];
	NSNumber *category = [store_ categoryWithCanonicalName: suggestedIndustry];
	[self setCargosToCategory: category];
}
	
- (IBAction) doChangeIndustryClass: (id) sender {
	NSString *industryName = [suggestedIndustriesButton_ titleOfSelectedItem];
	NSNumber *category = [store_ categoryWithCanonicalName: industryName];
	[self setCargosToCategory: category];
}

- (IBAction) doChangeIndustry: (id) sender {
	// Clear check on previous selection.
	for (NSMenuItem *item in [currentIndustryButton_ itemArray]) {
		[item setState: 0];
	}

	int i = [currentIndustryButton_ indexOfSelectedItem];
	// TODO(bowdidge): Why doesn't this set checkbox, and set center point of menu when opened?
	currentIndustry_ = [[currentIndustryArrayController_ content] objectAtIndex: i];
	[[currentIndustryButton_ itemAtIndex: i] setState: NSOnState];
	
	NSArray *categories = [store_ categoriesForIndustryName: [currentIndustry_ name]];
	
	[suggestedIndustriesButton_ removeAllItems];
	NSMutableDictionary *existingCategories = [NSMutableDictionary dictionary];
	for (NSNumber *category in categories) {
		NSDictionary *industryDict = [store_ industryDictForCategory: category];
		[existingCategories setObject: [NSNumber numberWithBool: YES] forKey: [industryDict objectForKey: @"IndustryClass"]];
		[suggestedIndustriesButton_ addItemWithTitle: [industryDict objectForKey: @"IndustryClass"]];
	}
	
	// Add some extra categories, potentially all.
	// Need to be able to respond to these.
	[[suggestedIndustriesButton_ menu] addItem:[NSMenuItem separatorItem]];

	for (NSString *name in [[store_ allCategoryNames] sortedArrayUsingSelector: @selector(compare:)]) {
		if ([existingCategories objectForKey: name] == nil) {
			// Not already in list.
			[suggestedIndustriesButton_ addItemWithTitle: name];
		}
	}
	
	if ([categories count] == 0) {
		[suggestedIndustriesButton_ setEnabled: NO];
	} else {
		[suggestedIndustriesButton_ setEnabled: YES];
		[suggestedIndustriesButton_ selectItemAtIndex: 0];
		NSNumber *category = [store_ categoryWithCanonicalName: [suggestedIndustriesButton_ titleOfSelectedItem]];
		[self setCargosToCategory: category];
	}
}	

- (IBAction) doCreate: (id) sender {
	NSArray *cargos = [proposedCargoArrayController_ content];
	for (ProposedCargo *cargo in cargos) {
		if ([[cargo isKeep] intValue]) {
			NSLog(@"Create cargo %@", [cargo name]);
			NSManagedObjectContext *context = [currentIndustry_ managedObjectContext];
			[NSEntityDescription entityForName: @"Cargo" inManagedObjectContext: context];
			Cargo *c1 = [NSEntityDescription insertNewObjectForEntityForName:@"Cargo"
														 inManagedObjectContext: context];
			[c1 setCargoDescription: [cargo name]];
			[c1 setPriority: [NSNumber numberWithBool: NO]];
			[c1 setCarsPerWeek: [cargo carsPerWeek]];
			if ([cargo isReceive]) {
				[c1 setSource: [cargo industry]];
				[c1 setDestination: currentIndustry_];
			} else {
				[c1 setSource: currentIndustry_];
				[c1 setDestination: [cargo industry]];
			}
		}
	}
	[window_ close];
}

- (IBAction) doCancel: (id) sender {
	[window_ close];
}	
	
@end
