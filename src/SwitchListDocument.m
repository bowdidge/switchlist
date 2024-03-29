//
//  SwitchListDocument.m
//  SwitchList
//
//  Created by Robert Bowdidge on 9/17/05.
//
// Copyright (c)2005 Robert Bowdidge,
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

#import "SwitchListDocument.h"

#import "CarAssigner.h"
#import "Cargo.h"
#import "CargoAssigner.h"
#import "CargoReport.h"
#import "CarReport.h"
#import "CarType.h"
#import "CarTypes.h"
#import "DoorAssignmentRecorder.h"
#import "EntireLayout.h"
#import "FreightCar.h"
#import "GlobalPreferences.h"
#import "HTMLSwitchListController.h"
#import "HTMLSwitchListWindowController.h"
#import "HTMLSwitchlistRenderer.h"
#import "Industry.h"
#import "IndustryReport.h"
#import "KaufmanSwitchListView.h"
#import "NSFileManager+DirectoryLocations.h"
#import "Place.h"
#import "PICLReport.h"
#import "PrintEverythingView.h"
#import "ReservedCarReport.h"
#import "ScheduledTrain.h"
#import "SouthernPacificSwitchListView.h"
#import "SuggestedCargoController.h"
#import "SwitchListAppDelegate.h"
#import "SwitchListReport.h"
#import "SwitchListView.h"
#import "SwitchListReportWindowController.h"
#import "SwitchListStyleTabController.h"
#import "TrainAssigner.h"
#import "Yard.h"
#import "YardReport.h"

#define DEBUG_CAR_ASSN 1

// Adds up all the cargo counts from all cargos in the project, and
// divides by 7 to find daily count.  Used for displaying loads/day in
// the cargo tab, and helps users understand if the number of cargos
// is balanced relative to the number of freight cars.
// On the InterfaceBuilder side, this is set up as looking at arrangedObjects
// for the table, and grabbing each of the carsPerMonth value from all visible
// cargos.  This ensures that the value is recalculated whenever carsPerMonth
// changes
@interface CargoCountTransformer: NSValueTransformer {}
@end

@implementation CargoCountTransformer
// Returns an NSNumber to the Cocoa Bindings.
+ (Class)transformedValueClass {
    return [NSNumber class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
}

// Adds up all the carsPerMonth and divides by thirty to calculate the 
// preferred loads per day.
// This code should match the loadsPerDay calculation in SwitchListDocument.
- (id)transformedValue:(id)value {
	NSArray *allCargoCounts = (NSArray*) value;
	int curSum=0;
	NSNumber *thisCargo;
	NSEnumerator *e = [allCargoCounts objectEnumerator];
	while ((thisCargo = [e nextObject]) != nil) {
		int thisCargoCarsPerMonth = [thisCargo intValue];
		curSum += thisCargoCarsPerMonth;
	}
	return [NSNumber numberWithInt: curSum / 7];
}
@end
@interface TrainCarTypesStringTransformer: NSValueTransformer {}
@end

@implementation TrainCarTypesStringTransformer
// Returns an NSNumber to the Cocoa Bindings.
+ (Class)transformedValueClass {
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
}

// Adds up all the carsPerMonth and divides by thirty to calculate the
// preferred loads per day.
// This code should match the loadsPerDay calculation in SwitchListDocument.
- (id)transformedValue:(id)value {
    // TODO(bowdidge) Won't detect changes.
    return [CarTypes acceptedCarTypesString: value];
}
@end


/**
 * Controller object for the main document. 
 */
@implementation SwitchListDocument

- (void) dealloc {
	[placeIsNotOfflineFilter_ release];
	[locationIsNotOfflineFilter_ release];
	[entireLayout_ release];
	[layoutController_ release];
	[annulledTrains_ release];
	[trains_ release];
    [printingHtmlViewController_ release];
    [preferredSwitchListStyle_ release];
    [theTemplateCache release];
	[super dealloc];
}

- (LayoutController*) layoutController { 
	return layoutController_;
}

- (NSDictionary*) nameToSwitchListClassMap {
	return nameToSwitchListClassMap_;
}

// Converts the train stop string in all trains from the old comma-based separator to the
// newer approach that will allow commas in place names.  If it looks like the stops has
// been converted on one already, assume all are converted and do nothing.
// This routine helps us avoid having station stop lists in both forms.
- (void) updateTrainsToUseNewSeparator {
	NSArray *allTrains = [entireLayout_ allTrains];

	if ([allTrains count] == 0) return;
	
	if ([[[allTrains lastObject] stops] rangeOfString: NEW_SEPARATOR_FOR_STOPS].length != 0) {
		// We've already converted stuff.
		return;
	}
	
	// Otherwise, force conversion.
	for (ScheduledTrain *train in allTrains) {
		[train setStationsInOrder: [train stationsInOrder]];
	}
}

// For each train, find any cases where acceptedCarTypesRel == nil, and replace with all.

- (void) awakeFromNib {
    entireLayout_ = nil;
    layoutController_ = nil;
    locationIsNotOfflineFilter_ = [[NSPredicate predicateWithFormat: @"self.location.isOffline == 0 OR self.location.name LIKE \"Workbench\""] retain];
    placeIsNotOfflineFilter_ = [[NSPredicate predicateWithFormat: @"self.isOffline == 0"] retain];
    trains_ = nil;
    annulledTrains_ = [[NSMutableArray alloc] init];
    printingHtmlViewController_  = nil;
    preferredSwitchListStyle_ = nil;
    theTemplateCache = [[TemplateCache alloc] init];
    
    // Gather the names of the switchlist templates with native support.
    nameToSwitchListClassMap_ = [[NSMutableDictionary alloc] init];
    [nameToSwitchListClassMap_ setObject: [SwitchListView class] forKey: DEFAULT_SWITCHLIST_TEMPLATE];
    [nameToSwitchListClassMap_ setObject: [KaufmanSwitchListView class] forKey: @"San Francisco Belt Line B-7"];
    [nameToSwitchListClassMap_ setObject: [SouthernPacificSwitchListView class] forKey: @"Southern Pacific Narrow"];
    [nameToSwitchListClassMap_ setObject: [PICLReport class] forKey: @"PICL Report"];
    
    entireLayout_ = [[EntireLayout alloc] initWithMOC: [self managedObjectContext]];
	layoutController_ = [[LayoutController alloc] initWithEntireLayout: entireLayout_];
	
	// Make sure every layout has a name.
	// TODO(bowdidge): Fix so unsaved layouts have unique names.
	if ([[entireLayout_ layoutName] length] == 0) {
		NSString *filename = [[[self fileURL] lastPathComponent] stringByDeletingPathExtension];
		if (filename) {
			[entireLayout_ setLayoutName: filename];
		}
	}
    
    // New layouts have no car types.  Add in a default set.
    if ([[entireLayout_ allCarTypes] count] == 0) {
        // No car types - set up default.
        NSDictionary* defaultCarTypes = [CarTypes defaultCarTypes];
        for (NSString *carTypeName in defaultCarTypes) {
            CarType *carType = [NSEntityDescription insertNewObjectForEntityForName:@"CarType"
                                                             inManagedObjectContext: [self managedObjectContext]];
            [carType setCarTypeName: carTypeName];
            [carType setCarTypeDescription: [defaultCarTypes objectForKey: carTypeName]];
        }
    }
	
	NSMutableDictionary *layoutPrefs = [entireLayout_ getPreferencesDictionary];
	NSNumber *defaultLoadsNumber = [layoutPrefs objectForKey: LAYOUT_PREFS_DEFAULT_NUM_LOADS];
	int defaultLoads = [defaultLoadsNumber intValue];
									
	if ((defaultLoads < 1) || (defaultLoads > 100)) {
		defaultLoads = 15;
		[layoutPrefs setObject: [NSNumber numberWithInt: defaultLoads] forKey: LAYOUT_PREFS_DEFAULT_NUM_LOADS];
		[entireLayout_ writePreferencesDictionary];
	}
	
	// Disable the door controls if the layout preference isn't set.
	NSNumber *useDoors = [layoutPrefs objectForKey: LAYOUT_PREFS_SHOW_DOORS_UI];
	if (!useDoors || [useDoors boolValue] == NO) {
		[self setDoorsButtonState: NO];
		[enableDoorsButton_ setState: NO];
	} else {
		[self setDoorsButtonState: YES];
		[enableDoorsButton_ setState: YES];
	}
	
	// Initialize to match the current selection.
	[self freightCarLocationChanged: self];
	
	// Disable the car length controls if the layout preference isn't set.
	NSNumber *useCarLengths = [layoutPrefs objectForKey: LAYOUT_PREFS_SHOW_SIDING_LENGTH_UI];
	if (!useCarLengths || [useCarLengths boolValue] == NO) {
		[enableSidingLengthButton_ setState: NO];
		[self setSidingLengthButtonState: NO];
	} else {
		[enableSidingLengthButton_ setState: YES];
		[self setSidingLengthButtonState: YES];
	}

	[overviewTrainTable_ setDoubleAction: @selector(doGenerateSwitchList:)];
	
	NSPredicate *pred = [NSPredicate predicateWithFormat: @"isYard == NO"];
	[industryArrayController_ setFilterPredicate: pred];
	
	// Set up the panel.
	[datePicker_ setDateValue: [entireLayout_ currentDate]];
	[layoutNameField_ setStringValue: [entireLayout_ layoutName]];

	// If we need to upgrade, do so.
	[self updateTrainsToUseNewSeparator];
	
    // Puts the switchlist template names in the pop-up in sorted order,
    // rescanning the template directories.
    [switchListStyleTabController_ reloadSwitchlistTemplateNames];

	[self doAssignCars: self];
}

/* This boilerplate code only exists to turn on the "migrate automatically" flag.  A file
   using an old data model gets loaded in and automatically moved to the new format using the
   mapping model. */
   
- (BOOL)configurePersistentStoreCoordinatorForURL:(NSURL*)url 
                      ofType:(NSString*)fileType
                modelConfiguration:(NSString*)configuration
                   storeOptions:(NSDictionary*)storeOptions
                      error:(NSError**)error
{
    NSMutableDictionary *options = nil;
    if (storeOptions != nil) {
        options = [storeOptions mutableCopy];
    } else {
        options = [[NSMutableDictionary alloc] init];
    }
    
    [options setObject:[NSNumber numberWithBool:YES] 
                forKey:NSMigratePersistentStoresAutomaticallyOption];
    [options setObject:[NSNumber numberWithBool:YES]
                forKey:NSInferMappingModelAutomaticallyOption];
    
    BOOL result = [super configurePersistentStoreCoordinatorForURL:url
                                                            ofType:fileType
                                                modelConfiguration:configuration
                                                      storeOptions:options
                                                             error:error];
    [options release];
    options = nil;
    return result;
}

- (NSString*) preferredSwitchListStyle {
    if (preferredSwitchListStyle_) return preferredSwitchListStyle_;
    
    // First, try to get from regular preferences.
	NSMutableDictionary *layoutPrefs = [[self entireLayout] getPreferencesDictionary];
    NSString *preferredSwitchListStyle = [layoutPrefs objectForKey: LAYOUT_PREFS_SWITCH_LIST_DEFAULT_TEMPLATE];
    // Fall back on global preference for now.
    if (!preferredSwitchListStyle) {
        preferredSwitchListStyle = [[NSUserDefaults standardUserDefaults] stringForKey: GLOBAL_PREFS_SWITCH_LIST_DEFAULT_TEMPLATE];
    }

    if (![[theTemplateCache validTemplateNames] containsObject: preferredSwitchListStyle]) {
        preferredSwitchListStyle = DEFAULT_SWITCHLIST_TEMPLATE;
    }
    
    preferredSwitchListStyle_ = [preferredSwitchListStyle retain];
    return preferredSwitchListStyle_;
}

- (void) setPreferredSwitchListStyle: (NSString*) styleName {
	NSMutableDictionary *layoutPrefs = [[self entireLayout] getPreferencesDictionary];
    [layoutPrefs setObject: styleName forKey: LAYOUT_PREFS_SWITCH_LIST_DEFAULT_TEMPLATE];
    [entireLayout_ writePreferencesDictionary];
    [preferredSwitchListStyle_ release];
    preferredSwitchListStyle_ = [styleName retain];
}

// Returns an array of (option name, value) pairs for custom options for the current switchlist style, or nil if
// no preferences are saved.
- (NSArray*) optionalFieldKeyValues {
    NSMutableDictionary *layoutPrefs = [[self entireLayout] getPreferencesDictionary];
    NSMutableDictionary *preferredSwitchListStyle = [layoutPrefs objectForKey: LAYOUT_PREFS_OPTIONAL_TEMPLATE_PARAMS];
    
    NSArray* options = [preferredSwitchListStyle objectForKey: [self preferredSwitchListStyle]];
    if (!options) {
        return nil;
    }
    if (![options isKindOfClass: [NSArray class]]) {
        // Corrupt.
        return nil;
    }
    NSAssert([options isKindOfClass: [NSArray class]], @"Should be array.");
    return options;
}

- (void) templatesChanged: (id) sender {
    [switchListStyleTabController_ reloadSwitchlistTemplateNames];
}


// Returns an array of (option name, value) pairs for custom options for the current switchlist style, or nil if
// no preferences are saved.
- (void) setOptionalFieldKeyValues: (NSArray*) options {
    NSAssert([options isKindOfClass: [NSArray class]], @"Should be array.");
    NSMutableDictionary *layoutPrefs = [[self entireLayout] getPreferencesDictionary];
    NSMutableDictionary *allOptions = [layoutPrefs objectForKey: LAYOUT_PREFS_OPTIONAL_TEMPLATE_PARAMS];
    if (!allOptions) {
        allOptions = [NSMutableDictionary dictionary];
        [layoutPrefs setObject: allOptions forKey: LAYOUT_PREFS_OPTIONAL_TEMPLATE_PARAMS];
    }

    // Sanity check before we save.
    for (NSArray *option in options) {
        if (![option isKindOfClass: [NSArray class]] ||
            [option count] != 2 ||
            ![[option objectAtIndex: 0] isKindOfClass: [NSString class]] ||
            ![[option objectAtIndex: 1] isKindOfClass: [NSString class]]) {
            NSLog(@"Malformed options: %@.  Not saving.", options);
            return;
        }
    }

    [allOptions setObject: options forKey: [self preferredSwitchListStyle]];
	[entireLayout_ writePreferencesDictionary];
}


// Prints switchlists for all trains on the layout that have work.
- (IBAction)printDocument:(id)sender {
	NSString *preferredSwitchlistStyle = [self preferredSwitchListStyle];
	
	Class reportClass = [[self nameToSwitchListClassMap] objectForKey: preferredSwitchlistStyle];
    NSMutableString* all_html = [NSMutableString string];
    [all_html appendString: @"<html><body>"];
    ScheduledTrain* lastTrain = [[entireLayout_ allTrains] lastObject];
    
	if (reportClass == nil) {
        // Render pages for all switchlists by concatenating the separate HTML pages, and boxing each
        // in with a div setting the page break attribute.
        // TODO(bowdidge): If this doesn't work in the long term, consider
        HTMLSwitchlistRenderer *renderer = [[[HTMLSwitchlistRenderer alloc] initWithBundle: [NSBundle mainBundle]] autorelease];
        [renderer setTemplate: preferredSwitchlistStyle];
        [renderer setOptionalSettings: [switchListStyleTabController_ optionalFieldKeyValues]];
        NSString *switchlistHtmlFile = [renderer filePathForTemplateHtml: @"switchlist"];

        for (ScheduledTrain* train in [entireLayout_ allTrains]) {
            NSString *message = [renderer renderSwitchlistForTrain:train layout:[self entireLayout] iPhone: NO interactive: NO];
            if (train != lastTrain) {
                [all_html appendString: @"<div class='page' style='page-break-after: always;'>"];
            } else {
                [all_html appendString: @"<div class='page'>"];
            }
            [all_html appendString: message];
            [all_html appendString: @"</div>"];
        }

		if (!printingHtmlViewController_) {
            printingHtmlViewController_ = [[HTMLSwitchListController alloc] init];
            WebView *htmlView = [[[WebView alloc] init] autorelease];
            [printingHtmlViewController_ setWebView: htmlView];
            [[printingHtmlViewController_ htmlView] setFrameLoadDelegate: self];
        }
		[printingHtmlViewController_ drawHTML: all_html  template: switchlistHtmlFile];
        // Finish the printing in webView:didFinishLoadForFrame: once the HTML has rendered.
	} else {
        PrintEverythingView *pev = [[PrintEverythingView alloc] initWithFrame: NSMakeRect(0.0,0.0,100.0,100.0) withDocument: self
                                                                withViewClass: reportClass];
        [pev setOptionalSettings: [switchListStyleTabController_ optionalFieldKeyValues]];
        [[NSPrintOperation printOperationWithView:pev] runOperation];
        [pev autorelease];
    }
}

- (void) webView: (WebView*) printView didFinishLoadForFrame: (WebFrame*) frame {
    NSPrintInfo *printInfo = [NSPrintInfo sharedPrintInfo];
    
    NSPrintOperation *printOp = [NSPrintOperation printOperationWithView: [[[printView mainFrame] frameView] documentView] printInfo: printInfo];
    [printOp setShowsPrintPanel: YES];
    [printOp runOperation];
}

- (void) setupSortedArrayController: (NSArrayController *) arrayController
				  rearrangeCallback: (SEL) selector 
							  popup: (NSPopUpButton*) popupButton 
						  sortField: (NSString*) sortFieldName {
    // Do the same for the list of places in the industry tab.
    // Create a sort descriptor to sort on "fullNameAndID"
	
	NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc]
										 initWithKey: sortFieldName ascending:YES] autorelease];
 	
	[arrayController setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector: selector
												 name:NSPopUpButtonWillPopUpNotification
											   object:popupButton];
	
}

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController
{
    [super windowControllerDidLoadNib:windowController];
    
	// Always raise the main tab first.
	[tabContainer_ selectTabViewItem: overviewTab_];
	
	[summaryWarningsField_ setStringValue: @""];
	
    // Set the sortDescriptors for the managers array controller
	[self setupSortedArrayController: freightCarLocationArrayController_ 
				   rearrangeCallback: @selector(rearrangeIndustriesArrayController:)
							   popup: freightCarLocationPopup_
							   sortField: @"name"];
							   
	[self setupSortedArrayController: freightCarTypeArrayController_
				   rearrangeCallback: @selector(rearrangeFreightCarCarTypeArrayController:)
							   popup: freightCarCarTypePopup_
                           sortField: @"carTypeName"];
    
	[self setupSortedArrayController: industryLocationArrayController_
				   rearrangeCallback: @selector(rearrangePlaceArrayController:)
							   popup: industryLocationPopup_
							   sortField: @"name"];
							   
   [self setupSortedArrayController: cargoSourceLocationArrayController_
		rearrangeCallback: @selector(rearrangeCargoSourceLocationArrayController:)
			popup: cargoSourceLocationPopup_
			sortField: @"name"];

   [self setupSortedArrayController: cargoDestinationLocationArrayController_
		rearrangeCallback: @selector(rearrangeCargoDestinationLocationArrayController:)
			popup: cargoDestinationLocationPopup_
			sortField: @"name"];
			
	[self setupSortedArrayController: cargoCarTypeArrayController_
				   rearrangeCallback: @selector(rearrangeCargoCarTypeArrayController:)
							   popup: cargoCarTypePopup_
                           sortField: @"carTypeName"];
    
   [self setupSortedArrayController: freightCarCargoArrayController_
		rearrangeCallback: @selector(rearrangeFreightCarCargoArrayController:)
			popup: freightCarCargoPopup_
			sortField: @"cargoDescription"];

	[self setupSortedArrayController: carTypeArrayController_
				   rearrangeCallback: @selector(rearrangeFreightCarTypeArrayController:)
							   popup: freightCarCarTypePopup_
						   sortField: @"carTypeName"];

	[self setupSortedArrayController: yardLocationArrayController_
		rearrangeCallback: @selector(rearrangeYardLocationArrayController:)
			popup: yardLocationPopup_
			sortField: @"name"];

	// TODO(bowdidge): This *should* be sorting the main tables in each view, but it isn't.
	// Now, set up main tables in each view to sort alphabetically by default.
	NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc]
			initWithKey: @"name" ascending: YES
			selector:@selector(caseInsensitiveCompare:)];
	NSArray *sortDescriptors = [NSArray arrayWithObject: sortDescriptor];
	
// 	[_overviewTrainArrayController setSortDescriptors: [NSArray arrayWithObject: sortDescriptor]];
//	[_freightCarController setSortDescriptors: sortDescriptors];
	[trainArrayController_ setSortDescriptors: sortDescriptors];
//	[_yardArrayController setSortDescriptors: sortDescriptors];
	[sortDescriptor release];
} 

// Callbacks to trigger the reordering of all the popup buttons listing places and other things
// that deserve sorting alphabetically.
- (void)rearrangeIndustriesArrayController:(NSNotification *)note
{
    [freightCarLocationArrayController_ rearrangeObjects];
}

- (void) rearrangeFreightCarCarTypeArrayController: (NSNotification*) note {
    [freightCarTypeArrayController_ rearrangeObjects];
}

- (void) rearrangeCargoCarTypeArrayController: (NSNotification*) note {
    [cargoCarTypeArrayController_ rearrangeObjects];
}

- (void)rearrangePlaceArrayController:(NSNotification *)note
{
    [industryLocationArrayController_ rearrangeObjects];
} 

- (void)rearrangeCargoSourceLocationArrayController:(NSNotification *)note
{
    [cargoSourceLocationArrayController_ rearrangeObjects];
} 

- (void)rearrangeCargoDestinationLocationArrayController:(NSNotification *)note
{
    [cargoDestinationLocationArrayController_ rearrangeObjects];
} 

- (void)rearrangeFreightCarCargoArrayController:(NSNotification *)note
{
    [freightCarCargoArrayController_ rearrangeObjects];
} 

- (void)rearrangeFreightCarTypeArrayController:(NSNotification *)note
{
    [carTypeArrayController_ rearrangeObjects];
} 

- (void)rearrangeYardLocationArrayController:(NSNotification *)note
{
    [yardLocationArrayController_ rearrangeObjects];
} 
	
- (NSString *)windowNibName 
{
    return @"SwitchListWindow";
}

- (NSError*) willPresentError: (NSError*) inError {
	if (!([[inError domain] isEqualToString:  NSCocoaErrorDomain])) {
		return inError;
	}

	NSInteger errorCode = [inError code];
	if ((errorCode < NSValidationErrorMinimum) ||
		(errorCode > NSValidationErrorMaximum)) {
			return inError;
	}
	
	if (errorCode != NSValidationMultipleErrorsError) {
		return inError;
	}
	
	NSArray *detailedErrors = [[inError userInfo] objectForKey: NSDetailedErrorsKey];
	NSEnumerator *e = [detailedErrors objectEnumerator];
	
	NSMutableString *errorString= [NSMutableString string];
	NSError *er;
	while ((er=[e nextObject]) != nil) {
		[errorString appendFormat: @"%@\n", [er localizedDescription]];
	}
	NSMutableDictionary *newUserInfo = [NSMutableDictionary dictionaryWithDictionary: [inError userInfo]];
	[newUserInfo setObject: errorString forKey: NSLocalizedDescriptionKey];
	NSError *newError = [NSError errorWithDomain: [inError domain]
			code: [inError code]	
			userInfo: newUserInfo];

	// Now display the error on the console.  It would be better to send this off to a list somewhere.
	printf("%s\n",[[[inError userInfo] description] UTF8String]);
	return newError;
}
	
// Override file loading so we can do some cleanup of inappropriate old choices.	
- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)error {
	BOOL ret;
	@try {
		ret = [super readFromURL: absoluteURL ofType: typeName error: error];
	}
	@catch (NSException *localException) {
		NSLog(@"%@",[localException description]);
	}

	return ret;
}

- (EntireLayout*) entireLayout {
	return entireLayout_;
}

- (DoorAssignmentRecorder*) doorAssignmentRecorder {
	return [layoutController_ doorAssignmentRecorder];
}

// finish loads/unloads and reassign.
- (IBAction) doAdvanceLoads: (id) sender {
	int numberOfCargos = [entireLayout_ loadsPerDay];
	[layoutController_ advanceLoads];

	// Generate loads for today.
	[self createAndAssignNewCargos: numberOfCargos];
	[self doAssignCars: self];
	
	[self updateSummaryInfo:self];
	
	// Finally, advance the day.
	NSDate *currentDate = [entireLayout_ currentDate];
	// Add one day.
	currentDate = [currentDate dateByAddingTimeInterval: (60 * 60 * 24)];
	[datePicker_ setDateValue: currentDate];
	[entireLayout_ setCurrentDate: currentDate];
	
	// Clear annulled trains.
	[annulledTrains_ release];
	annulledTrains_ = [[NSMutableArray alloc] init];
}

- (void) assignCarsToTrains {
	NSMutableArray *allTrains = [NSMutableArray arrayWithArray: [entireLayout_ allTrains]];
	for (ScheduledTrain* annulledTrain in annulledTrains_) {
		[allTrains removeObject: annulledTrain];
	}
	
	NSMutableDictionary *layoutPrefs = [entireLayout_ getPreferencesDictionary];
	BOOL useDoors = NO;
	NSNumber *useDoorsPref = [layoutPrefs objectForKey: LAYOUT_PREFS_SHOW_DOORS_UI];
	if (useDoorsPref && [useDoorsPref boolValue]) {
		useDoors = YES;
	}
	
	NSNumber *respectSidingLengthsPref = [layoutPrefs objectForKey: LAYOUT_PREFS_SHOW_SIDING_LENGTH_UI];
	BOOL respectSidingLengths = NO;
	if (respectSidingLengthsPref && [respectSidingLengthsPref boolValue]) {
		respectSidingLengths = YES;
	}
		
	NSArray *errs = [layoutController_ assignCarsToTrains: allTrains respectSidingLengths: respectSidingLengths useDoors: useDoors];

	SwitchListAppDelegate *appDelegate = (SwitchListAppDelegate*) [[NSApplication sharedApplication] delegate];
	[appDelegate setProblems: errs];
}

// Selects a random set of cargos, and assigns them to available freight cars.
- (void) createAndAssignNewCargos: (int) loadsToAdd {

	NSMutableDictionary *carTypeUnavailableCount;
	carTypeUnavailableCount = [layoutController_ createAndAssignNewCargos: loadsToAdd];

	if (!carTypeUnavailableCount) return;

	// Format the warnings for unavailable cars.
	NSArray *unavailableCarTypes = [carTypeUnavailableCount allKeys];
	NSMutableString *warningString = [NSMutableString string];
	if ([unavailableCarTypes count] != 0) {
		[warningString appendFormat: @"Unavailable cars: (type/number): "];
		NSEnumerator *e = [unavailableCarTypes objectEnumerator];
		NSString *carTypeName;
		while ((carTypeName = [e nextObject]) != nil) {
			[warningString appendFormat: @"%@ (%d), ",carTypeName,
				[[carTypeUnavailableCount valueForKey: carTypeName] intValue]];
		}
		[warningString appendFormat: @"\n"];
	}
	
	[summaryWarningsField_ setStringValue: warningString];
}

// Scorched earth on loads: reset everything about all freight cars.
// For debugging, mainly.
- (IBAction) doClearAllLoads: (id)sender {
	
	NSAlert *alert = [NSAlert alertWithMessageText: @"Are you sure you want to clear cargo loads from all cars?"
		defaultButton: @"OK" alternateButton: @"Cancel" otherButton: nil
		 informativeTextWithFormat: @"Clearing cargos can help if you have changed cargos and car types significantly.  Otherwise, it just adds a bit of chaos til loads get sorted out."];
		 
	// returns 1 for OK, 0 for cancel.
	NSModalResponse ret = [alert runModal];
	if (ret != NSModalResponseOK) {
		return;
	}

	[layoutController_ clearAllLoads];
	[self updateSummaryInfo: self];
}

// Returns the number of additional cars per day that the "supersize" button
// should allow.  This is 10% of total loads to be generated,
// but never less than 2.
- (int) additionalCarsPerDay {
	int additionalCars = [entireLayout_ loadsPerDay] / 10;
	if (additionalCars < 2) {
		additionalCars = 2;
	}
	return additionalCars;
}
		
// Creates an extra 10% of loads and adds them to existing trains
// to increase the traffic this session.
- (IBAction) doAddMoreCars: (id) sender {
	int numberOfCargos= [self additionalCarsPerDay];
	[self createAndAssignNewCargos: numberOfCargos];
	[self doAssignCars: self];
	[self updateSummaryInfo: self];
}

// Reassigns cars to trains whenever anything changes.
- (IBAction) doAssignCars: (id) sender {
	[self assignCarsToTrains];
	[self updateSummaryInfo: self];
}

// Handle request to generate a switch list printout.
- (IBAction) doGenerateSwitchList: (id) sender {
	NSIndexSet *selection = [overviewTrainTable_ selectedRowIndexes];
	if ([selection count] > 1) {
		NSBeep(); return;
	}
	NSInteger selRow = [selection firstIndex];
	ScheduledTrain *train = [trains_ objectAtIndex: selRow];
    [self doGenerateSwitchListForTrain: train];
}
	
- (void) doGenerateSwitchListForTrain: (ScheduledTrain*) train {
	SwitchListBaseView *switchListView;
	NSString *preferredSwitchlistStyle = [self preferredSwitchListStyle];
	Class reportClass = [[self nameToSwitchListClassMap] objectForKey: preferredSwitchlistStyle];
									   
	if (reportClass == nil) {
		// There's no native way of drawing this, so fall back on the HTML version.
		NSString *title = [NSString stringWithFormat: @"Switch list for %@", [train name]];
		HTMLSwitchlistRenderer *renderer = [[[HTMLSwitchlistRenderer alloc] initWithBundle: [NSBundle mainBundle]] autorelease];
		[renderer setTemplate: preferredSwitchlistStyle];
        [renderer setOptionalSettings: [switchListStyleTabController_ optionalFieldKeyValues]];
		NSString *switchlistHtmlFile = [renderer filePathForTemplateHtml: @"switchlist"];

		NSString *message = [renderer renderSwitchlistForTrain:train layout:[self entireLayout] iPhone: NO interactive: NO];
		// TODO(bowdidge): Switch this to match/inherit from the SwitchListBaseView so print all works.
		HTMLSwitchListWindowController *view =[[HTMLSwitchListWindowController alloc] initWithTitle: title];
		[[view window] makeKeyAndOrderFront: self];
		[view drawHTML: message
			  template: switchlistHtmlFile];
		return;
	}
	
	NSPrintInfo *printInfo = [self printInfo];
	NSRect reportRect = [printInfo imageablePageBounds];
	switchListView = [[reportClass alloc] initWithFrame: NSMakeRect(20.0, 20.0, reportRect.size.width, reportRect.size.height)
										   withDocument: self];
    [switchListView setOptionalSettings: [switchListStyleTabController_ optionalFieldKeyValues]];
	// These three not needed for non-text.
	[switchListView setTrain: train];
	
	// TODO(bowdidge): How to free this?  Who owns?
	SwitchListReportWindowController *slwc = [[SwitchListReportWindowController alloc] initWithWindowNibName: @"SwitchListReportWindow"
																									withView: switchListView
																								withDocument: self];
	[self updateSummaryInfo: self];
	[[slwc window] center];
	[[slwc window] makeKeyAndOrderFront: self];
}

- (void) adjustAnnulButton: (id) sender {
	NSIndexSet *selection = [overviewTrainTable_ selectedRowIndexes];
	if ([selection count] != 1) {
		// Default to annul for a mix.
		[annulTrainButton_ setTitle: @"Annul Train"];
	} else {
		ScheduledTrain *trainToAnnul = [trains_ objectAtIndex: [selection firstIndex]];
		if ([annulledTrains_ containsObject: trainToAnnul]) {
			[annulTrainButton_ setTitle: @"Run Train"];
		} else {
			[annulTrainButton_ setTitle: @"Annul Train"];
		}
	}
}

// Cancel a train, and reassign its freight cars to other trains when possible.
- (IBAction) doAnnulTrain: (id) sender {
	NSIndexSet *selection = [overviewTrainTable_ selectedRowIndexes];
	NSInteger selRow = [selection firstIndex];
	
	while (selRow != NSNotFound) {
		// Redistribute the cars to the trains that have yet to run.
		ScheduledTrain *trainToAnnul = [trains_ objectAtIndex: selRow];
		if ([annulledTrains_ containsObject: trainToAnnul]) {
			// Un-annul the train.
			[annulledTrains_ removeObject: trainToAnnul];
		} else {
			// TODO(bowdidge): Annul button with multiple selections always goes to Annul.
			[annulledTrains_ addObject: trainToAnnul];
			for (FreightCar *fc in [trainToAnnul.freightCars copy]) {
				[fc removeFromTrain];
			}
		}
		selRow = [selection indexGreaterThanIndex:selRow];
	}
	// Recalculate car assignments with the changed train list.
	[self assignCarsToTrains];
	[self updateSummaryInfo: self];
	[self adjustAnnulButton: self];
}

// Mark the train as complete, and move all its freight cars to their final location.
- (IBAction) doCompleteTrain: (id) sender {
	NSIndexSet *selection = [overviewTrainTable_ selectedRowIndexes];
	
	NSInteger selRow = [selection firstIndex];
    while (selRow != NSNotFound) {
		ScheduledTrain *train = [trains_ objectAtIndex: selRow];
		[layoutController_ completeTrain: train];
		selRow = [selection indexGreaterThanIndex: selRow];
	}	
	[self updateSummaryInfo: self];
}

- (void) updateAndCacheListOfTrains {
		[trains_ release];
		trains_ = [[entireLayout_ allTrains] retain];
}

// Brings up the carTypesAccepted sheet in the Trains dialog, allowing the user to select which
// subset of car types can be carried by this train.
- (IBAction) doSetCarTypes: (id) sender {
	[self updateAndCacheListOfTrains];
	NSIndexSet *selection = [trainListTable_ selectedRowIndexes];
	if ([selection count] != 1) {
		NSBeep(); return;
	}

	ScheduledTrain *train = [[trainArrayController_ selectedObjects] lastObject];
	
	[trainCarTypesDialogController_ setTrain: train layout: entireLayout_];
	[NSApp beginSheet: setCarTypesSheet_ modalForWindow: switchListWindow_ modalDelegate: self didEndSelector: @selector(sheetDidEnd:returnCode:contextInfo:) contextInfo: nil];

	// sheet is up here
}

// Handles presses on "Set Route" button in Trains panel.  Brings up dialog box to allow user to select
// the stops a train makes.
- (IBAction) doSetRoute: (id) sender {
	[self updateAndCacheListOfTrains];
	NSIndexSet *selection = [trainListTable_ selectedRowIndexes];
	if ([selection count] != 1) {
		NSBeep(); return;
	}
	
	// No yard means they can't hit OK in the dialog.  Avoid frustration.
	if ([[entireLayout_ allYards] count] == 0) {
		NSAlert *alert = [NSAlert alertWithMessageText: @"No yards exist on layout."
										 defaultButton: @"OK" alternateButton: nil otherButton: nil
							 informativeTextWithFormat: @"Each train must begin and end in a town with a yard.  "
						  "Please add at least one yard to your layout before setting a train's route."];
		[alert runModal];
		return;
	}
	
	ScheduledTrain *train = [[trainArrayController_ selectedObjects] lastObject];

	[NSApp beginSheet: setRouteSheet_ modalForWindow: switchListWindow_ modalDelegate: self didEndSelector: @selector(sheetDidEnd:returnCode:contextInfo:) contextInfo: nil];
	// sheet is up here

	[switchRouteController_ setTrain: train layout: entireLayout_];
}

// Updates the EntireLayout's date when the date in the Layout Preferences changes.
- (IBAction) doChangeDate: (id) sender {
	NSDate *currentDate = [datePicker_ dateValue];
	[entireLayout_ setCurrentDate: currentDate];
}

- (IBAction) doChangeLayoutName: (id) sender {
	NSString *currentLayoutName = [layoutNameField_ stringValue];
	[entireLayout_ setLayoutName: currentLayoutName];
}

- (IBAction) doChangeDoorsState: (id) sender {
	BOOL buttonState = [sender state];
	[self setDoorsButtonState: buttonState];
	// Also must change setting.
	NSMutableDictionary *layoutPrefs = [entireLayout_ getPreferencesDictionary];
	[layoutPrefs setValue: [NSNumber numberWithInt: buttonState] forKey: LAYOUT_PREFS_SHOW_DOORS_UI];
	[entireLayout_ writePreferencesDictionary];
}

- (IBAction) doChangeRespectSidingLengthsState: (id) sender {
	BOOL buttonState = [sender state];
	[self setSidingLengthButtonState: buttonState];
	[self setDoorsButtonState: buttonState];
	// Also must change setting.
	NSMutableDictionary *layoutPrefs = [entireLayout_ getPreferencesDictionary];
	[layoutPrefs setValue: [NSNumber numberWithInt: buttonState] forKey: LAYOUT_PREFS_SHOW_SIDING_LENGTH_UI];
	[entireLayout_ writePreferencesDictionary];
}

// Requests the user name a text file containing car names,
// and creates car objects for the car names in the file.
- (IBAction) doImportCars: (id) sender {
	// Create the File Open Dialog class.
	NSOpenPanel* openDlg = [NSOpenPanel openPanel];
	[openDlg setCanChooseFiles:YES];
	[openDlg setPrompt: @"Import"];
	[openDlg setCanChooseDirectories:NO];
	[openDlg setAllowsMultipleSelection: NO];
	
	// Display the dialog.  If the OK button was pressed,
	// process the files.
	if ([openDlg runModalForDirectory:nil file:nil] != NSOKButton) return;

	NSURL *filename = [[openDlg URLs] lastObject];
	NSData *contents = [NSData dataWithContentsOfURL:filename];
	
	if (contents == nil) {
		NSAlert *alert = [NSAlert alertWithMessageText: [NSString stringWithFormat: @"Unable to read file %@.", filename]
										 defaultButton: @"OK" alternateButton: nil otherButton: nil
							 informativeTextWithFormat: @"File contents could not be read."];
		[alert runModal];
		return;
	}
		
	NSString * stringContents = [[NSString alloc] initWithBytes: [contents bytes] length: [contents length] encoding: NSUTF8StringEncoding];
	[stringContents autorelease];
	NSString *outErrors = nil;
	int count = [entireLayout_ importFreightCarsUsingString: stringContents errors: &outErrors];
	if (outErrors != nil) {
		NSAlert *alert = [NSAlert alertWithMessageText: @"Errors while importing file."
										 defaultButton: @"OK" alternateButton: nil otherButton: nil
							 informativeTextWithFormat: @"%@", outErrors];
		[alert runModal];
		return;
	}
	
	NSString *successString;
	if (count == 1) {
		successString = @"Imported 1 car.";
	} else {
		successString = [NSString stringWithFormat: @"Imported %d cars.", count];
	} 
	
	NSAlert *alert = [NSAlert alertWithMessageText: @"Import complete."
									 defaultButton: @"OK" alternateButton: nil otherButton: nil
						 informativeTextWithFormat: @"%@", successString];
	[alert runModal];
}
	
- (IBAction) doCarReport: (id) sender {
	HTMLSwitchlistRenderer *renderer = [[[HTMLSwitchlistRenderer alloc] initWithBundle: [NSBundle mainBundle]] autorelease];
	NSString *preferredSwitchlistStyle = [self preferredSwitchListStyle];
	[renderer setTemplate: preferredSwitchlistStyle];
	NSString *carReport = [renderer filePathForTemplateHtml: @"car-report"];
	NSString *message = [renderer renderReport: @"car-report"
									  withDict: [NSDictionary dictionaryWithObject: [self entireLayout]
																			forKey: @"layout"]];
	
	HTMLSwitchListWindowController *view =[[HTMLSwitchListWindowController alloc] initWithTitle: @"Car Report"];
	[[view window] makeKeyAndOrderFront: self];
	
	[view drawHTML: message template: carReport];	
}

- (IBAction) doIndustryReport: (id) sender {
	HTMLSwitchlistRenderer *renderer = [[[HTMLSwitchlistRenderer alloc] initWithBundle: [NSBundle mainBundle]] autorelease];
	NSString *preferredSwitchlistStyle = [self preferredSwitchListStyle];
	[renderer setTemplate: preferredSwitchlistStyle];
	NSString *industryHtml = [renderer filePathForTemplateHtml: @"industry-report"];
	NSString *message = [renderer renderReport: @"industry-report"
									  withDict: [NSDictionary dictionaryWithObject: [self entireLayout]
																			forKey: @"layout"]];
	
	HTMLSwitchListWindowController *view =[[HTMLSwitchListWindowController alloc] initWithTitle: @"Industry Report"];
    [[view window] makeKeyAndOrderFront: self];
	[view drawHTML: message template: industryHtml];	
}

// Generates the cargo report from the HTML version.
- (IBAction) doCargoReport: (id) sender {
	HTMLSwitchlistRenderer *renderer = [[[HTMLSwitchlistRenderer alloc] initWithBundle: [NSBundle mainBundle]] autorelease];
	NSString *preferredSwitchlistStyle = [self preferredSwitchListStyle];
	[renderer setTemplate: preferredSwitchlistStyle];
	NSString *industryHtml = [renderer filePathForTemplateHtml: @"cargo-report"];
	NSString *message = [renderer renderReport: @"cargo-report"
									  withDict: [NSDictionary dictionaryWithObject: [self entireLayout]
																			forKey: @"layout"]];
	
	HTMLSwitchListWindowController *view =[[HTMLSwitchListWindowController alloc] initWithTitle: @"Cargo Report"];
    [[view window] makeKeyAndOrderFront: self];
	[view drawHTML: message template: industryHtml];	
}

- (IBAction) doReservedCarReport: (id) sender {
	HTMLSwitchlistRenderer *renderer = [[[HTMLSwitchlistRenderer alloc] initWithBundle: [NSBundle mainBundle]] autorelease];
	NSString *preferredSwitchlistStyle = [self preferredSwitchListStyle];
	[renderer setTemplate: preferredSwitchlistStyle];
	NSString *reservedCarReport = [renderer filePathForTemplateHtml: @"reserved-car-report"];
	NSString *message = [renderer renderReport: @"reserved-car-report"
									  withDict: [NSDictionary dictionaryWithObject: [self entireLayout]
																			forKey: @"layout"]];
	
	HTMLSwitchListWindowController *view =[[HTMLSwitchListWindowController alloc] initWithTitle: @"Reserved Car Report"];
    [[view window] makeKeyAndOrderFront: self];
	[view drawHTML: message template: reservedCarReport];	
}

// For each yard or staging yard, print out the list of cars in each yard and the train
// that will be taking each car.
- (IBAction) doYardReport: (id) sender {
	HTMLSwitchlistRenderer *renderer = [[[HTMLSwitchlistRenderer alloc] initWithBundle: [NSBundle mainBundle]] autorelease];
	NSString *preferredSwitchlistStyle = [self preferredSwitchListStyle];
	[renderer setTemplate: preferredSwitchlistStyle];
	NSString *yardHtml = [renderer filePathForTemplateHtml: @"yard-report"];
	NSString *message = [renderer renderReport: @"yard-report"
									  withDict: [NSDictionary dictionaryWithObject: [self entireLayout]
																			forKey: @"layout"]];
	
	HTMLSwitchListWindowController *view =[[HTMLSwitchListWindowController alloc] initWithTitle: @"Yard Report"];
	[[view window] makeKeyAndOrderFront: self];
	[view drawHTML: message template: yardHtml];
}

- (IBAction) doOpenSuggestedCargoWindow: (id) sender {
	return [[suggestedCargoController_ window] makeKeyAndOrderFront: self];
}

- (void)windowDidResignKey:(NSNotification *)notification {
	// Assume it's the panel.
	[self doChangeLayoutName: self];
}


// Close up the route sheet.
- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
	[sheet orderOut: self];
}

/** 
 * Updates the text on the Overview panel showing how many cars are on the layout,
 * and how many have loads.  This gives the user an idea of whether to press the "generate more
 * loads" button.
 */
- (void) updateSummaryInfo: (id) sender {
	// how many freight cars?
	NSUInteger numberOfFreightCars = [[entireLayout_ allFreightCars] count];
	
    NSUInteger numberOfAssignedFreightCars = [[entireLayout_ allReservedFreightCars] count];
    NSUInteger numberOfCarsOnWorkbench = [[entireLayout_ allFreightCarsOnWorkbench] count];
	
	NSMutableString *freightCarStatus = [NSMutableString stringWithFormat: @"%d freight cars, %d assigned",
										 (int) numberOfFreightCars, (int) numberOfAssignedFreightCars];
	if (numberOfCarsOnWorkbench > 0) {
		[freightCarStatus appendFormat: @", %d at workbench", (int) numberOfCarsOnWorkbench];
	}
	[freightCarCountField_ setStringValue: freightCarStatus];

	[generateMoreButton_ setTitle: [NSString stringWithFormat: @"Add %d more loads", [self additionalCarsPerDay]]];

	[overviewTrainTable_ reloadData];	
}

// Table count for train table in Overview tab.  We'll display
// all trains in the database.
- (NSUInteger) numberOfRowsInTrainTableView {
	if (trains_ == nil) {
		[self updateAndCacheListOfTrains];
	}
	return [trains_ count];
}

// Populates train table in Overview tab.
- (id) trainTableObjectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSUInteger)row {
	if (trains_ == nil) {
		[self updateAndCacheListOfTrains];
	}
	ScheduledTrain *train = [trains_ objectAtIndex: row];

	// TODO(bowdidge): Replace with comparisons to TableColumn objects.
	if ([[[tableColumn headerCell] title] isEqualToString: @"Name"]) {
		return [train name];
	} else if ([[[tableColumn headerCell] title] isEqualToString: @"cars moved"]) {
		NSSet *cars = train.freightCars;
		if ([annulledTrains_ containsObject: train]) {
			return @"annulled";
		}
		if (cars != nil) {
			return [NSString stringWithFormat: @"%d", (int) [cars count]];
		} else {
			return @"---";
		}
	} else if ([[[tableColumn headerCell] title] isEqualToString: @"max cars"]) {
		return @"---";
	} else {
		return @"unknown field";
	}
}

// Table view for main document.
// This handles multiple tables, so dispatch off to different methods depending
// on the table.
- (NSInteger) numberOfRowsInTableView:(NSTableView *)tableView {
	if (tableView == overviewTrainTable_) {
		return [self numberOfRowsInTrainTableView];
	} else {
		// Seems to happen on PowerPC in Mac OS X 10.5.  No idea why.
		NSLog(@"Calling numberOfRowsInTableView on wrong table: %@ != %@!", tableView, overviewTrainTable_);
	}
	return 0;
}
	
- (BOOL)tabView:(NSTabView *)tabView shouldSelectTabViewItem:(NSTabViewItem *)tabViewItem {
	// Whenever the tab view changes to the overview, assume something important changed and recalculate
	// the set of trains.
	if (tabViewItem == overviewTab_) {
		[self doAssignCars: self];
		[self updateSummaryInfo: self];
	}
	[self updateAndCacheListOfTrains];
	return YES;
}

- (id) tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	if (tableView == overviewTrainTable_) {
		return [self trainTableObjectValueForTableColumn: tableColumn row: row];
	} else {
		// Seems to happen on PowerPC in Mac OS X 10.5.  No idea why.
		NSLog(@"Calling tableView:ObjectValueForTableColumn:row: on wrong table: %@ != %@!", tableView, overviewTrainTable_);
		return nil;
	}
}

// Handles changes when the car selection changes, or when the car's location changes.
- (void) showFreightCarDoorPopup: (id) sender {
	NSMutableDictionary *layoutPrefs = [entireLayout_ getPreferencesDictionary];
	NSNumber *useDoors = [layoutPrefs objectForKey: LAYOUT_PREFS_SHOW_DOORS_UI];
	BOOL shouldShowDoors = (useDoors && [useDoors boolValue] == YES);

		NSInteger selectedRow = [freightCarTable_ selectedRow];
	
	// Have the location overlap the door selector when the location does not have a door.
	if (selectedRow >= [[freightCarArrayController_ arrangedObjects] count]) return;
	FreightCar *freightCar = [[freightCarArrayController_ arrangedObjects] objectAtIndex: selectedRow];
	NSRect doorLabelFrame = [doorsLabel_ frame];
	NSRect doorPopupFrame = [freightCarDoorPopup_ frame];
	NSRect locationPopupFrame = [freightCarLocationPopup_ frame];
	int locationPopupWidth;
	if (shouldShowDoors && [[freightCar currentLocation] hasDoors]) {
		// Set the popup so it ends just before the "Doors:" label.
		locationPopupWidth = doorLabelFrame.origin.x - locationPopupFrame.origin.x;
	} else {
		locationPopupWidth = doorPopupFrame.origin.x + doorPopupFrame.size.width - locationPopupFrame.origin.x;
	}
		
	locationPopupFrame.size.width = locationPopupWidth;
	[[freightCarLocationPopup_ animator] setFrame: locationPopupFrame];
}

- (IBAction) freightCarLocationChanged: (id) sender {
	[self showFreightCarDoorPopup: sender];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
	NSTableView *tableView = [notification object];
	if (tableView == freightCarTable_) {
		[self showFreightCarDoorPopup: self];
	} else if (tableView == overviewTrainTable_) {
		[self adjustAnnulButton: self];
		// TODO(bowdidge): Move button enabling logic into one place.
		NSIndexSet *selection = [overviewTrainTable_ selectedRowIndexes];
		BOOL enableButtons = ([selection count] > 0) ;
		[makeSwitchlistButton_ setEnabled: enableButtons];
		[annulTrainButton_ setEnabled: enableButtons];
		[trainCompletedButton_ setEnabled: enableButtons];
		[overviewTrainTable_ reloadData];
		
	}
}

// Displays tool tips in any cells in tables in SwitchList.
// Long strings will appear in their full form.
// In other cases where the name alone is insufficient, add a special case to give the full description.
//
// Note table must have this class as delegate in order to use toolTip method.
- (NSString *)tableView:(NSTableView *)tv toolTipForCell:(NSCell *)cell rect:(NSRectPointer)rect tableColumn:(NSTableColumn *)tc row:(int)row mouseLocation:(NSPoint)mouseLocation {
	if ([cell isKindOfClass:[NSTextFieldCell class]]) {
		if ([[cell attributedStringValue] size].width > rect->size.width) {
			return [cell stringValue];
		}
    }

	// TODO(bowdidge): Support more tool tips.
	if (tv == freightCarTable_) {
		if (tc == freightCarCargoColumn_) {
			id cargoObject = [cell representedObject];
			if (cargoObject && [cargoObject isKindOfClass: [Cargo class]]) {
				return [[cell representedObject] tooltip];
			}
		}
	}
    return nil;
}

- (void) setDoorsButtonState: (BOOL) shouldBeOn {
	[hasDoorsButton_ setEnabled: shouldBeOn];
	[doorCountField_ setEnabled: shouldBeOn];
	
	// Labels aren't disabled; instead, we change the color of the text.
	NSColor *labelColor = [NSColor controlTextColor];
	if (!shouldBeOn) {
		labelColor = [NSColor disabledControlTextColor];
	}
	[doorCountLabel_ setTextColor: labelColor];
}

// Hides or exposes siding length UI as needed.
- (void) setSidingLengthButtonState: (BOOL) enable {
	[lengthField_ setHidden: !enable];
	[lengthLabel_ setHidden: !enable];
	// TODO(bowdidge): Enable when adding minimum cars to run feature.
	[minCarsToRunField_ setHidden: YES];
	[minCarsToRunLabel_ setHidden: YES];
	[maxLengthField_ setHidden: !enable];
	[maxLengthLabel_ setHidden: !enable];
	[maxLengthFeetLabel_ setHidden: !enable];
	[sidingLengthLabel_ setHidden: !enable];
	[sidingFeetLabel_ setHidden: !enable];
	[sidingLengthField_ setHidden: !enable];
}

// Brings up the Help page for something in the layouts panel.
// Triggered by Help icon next to the "doors" and "siding limit options."
- (IBAction) doLayoutHelpPressed: (id) sender {
	NSString *locBookName = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleHelpBookName"];
	// Show help on web server.
	[[NSHelpManager sharedHelpManager] openHelpAnchor: @"SwitchListLayoutHelp" inBook: locBookName];
}

// Copies the selected problems to the clipboard as strings, or all problems if
// none are selected.

- (IBAction) copy: (id) sender {
    NSMutableArray *objects = [NSMutableArray array];
    id widgetDoingCopy = [switchListWindow_ firstResponder];
    bool success = NO;
    if ([widgetDoingCopy isKindOfClass: [NSTableView class]]) {
        NSTableView *tv = widgetDoingCopy;
         NSIndexSet *selectedRows = [tv selectedRowIndexes];
        if (tv == cargoTable_) {
            for (NSInteger row = [selectedRows firstIndex]; row != NSNotFound; row = [selectedRows indexGreaterThanIndex: row]) {
                Cargo *cargo = [[cargoArrayController_ arrangedObjects] objectAtIndex: row];
                [objects addObject: cargo];
            }
        } else if (tv == freightCarTable_) {
            for (NSInteger row = [selectedRows firstIndex]; row != NSNotFound; row = [selectedRows indexGreaterThanIndex: row]) {
                FreightCar *fc = [[freightCarArrayController_ arrangedObjects] objectAtIndex: row];
                [objects addObject: fc];
            }
        } else if (tv == industryTable_) {
            for (NSInteger row = [selectedRows firstIndex]; row != NSNotFound; row = [selectedRows indexGreaterThanIndex: row]) {
                Industry *industry = [[industryArrayController_ arrangedObjects] objectAtIndex: row];
                [objects addObject: industry];
            }
        } else if (tv == townTable_) {
            for (NSInteger row = [selectedRows firstIndex]; row != NSNotFound; row = [selectedRows indexGreaterThanIndex: row]) {
                Place *town = [[townArrayController_ arrangedObjects] objectAtIndex: row];
                [objects addObject: town];
            }
        } else if (tv == trainListTable_) {
            for (NSInteger row = [selectedRows firstIndex]; row != NSNotFound; row = [selectedRows indexGreaterThanIndex: row]) {
                ScheduledTrain *train = [[trainArrayController_ arrangedObjects] objectAtIndex: row];
                [objects addObject: train];
            }
        } else if (tv == yardTable_) {
            for (NSInteger row = [selectedRows firstIndex]; row != NSNotFound; row = [selectedRows indexGreaterThanIndex: row]) {
                Yard *yard = [[yardArrayController_ arrangedObjects] objectAtIndex: row];
                [objects addObject: yard];
            }
       }
    }

    if ([objects count] > 0) {
        NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
        [pasteboard clearContents];
        success = [pasteboard writeObjects: objects];
    }
   if (!success) {
        NSBeep();
    }
}

- (IBAction) paste: (id) sender {
    NSArray *objects = [NSArray array];
    id widgetDoingCopy = [switchListWindow_ firstResponder];
    if ([widgetDoingCopy isKindOfClass: [NSTableView class]]) {
        NSTableView *tv = widgetDoingCopy;
        if (tv == cargoTable_) {
            NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
            NSArray *classes = [NSArray arrayWithObject: [Cargo class]];
            objects = [pasteboard readObjectsForClasses: classes options: [NSDictionary dictionary]];
            NSLog(@"%@", objects);
            [cargoArrayController_ addObjects: objects];
            [cargoTable_ reloadData];
            // TODO(bowdidge): Scroll to insertion.
        } else if (tv == freightCarTable_) {
            NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
            NSArray *classes = [NSArray arrayWithObject: [FreightCar class]];
            objects = [pasteboard readObjectsForClasses: classes options: [NSDictionary dictionary]];
            NSLog(@"%@", objects);
            [freightCarArrayController_ addObjects: objects];
            [freightCarTable_ reloadData];
            // TODO(bowdidge): Scroll to insertion.
        } else if (tv == industryTable_) {
            NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
            NSArray *classes = [NSArray arrayWithObject: [Industry class]];
            objects = [pasteboard readObjectsForClasses: classes options: [NSDictionary dictionary]];
            NSLog(@"%@", objects);
            [industryArrayController_ addObjects: objects];
            [industryTable_ reloadData];
            // TODO(bowdidge): Scroll to insertion.
        } else if (tv == townTable_) {
            NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
            NSArray *classes = [NSArray arrayWithObject: [Place class]];
            objects = [pasteboard readObjectsForClasses: classes options: [NSDictionary dictionary]];
            [townArrayController_ addObjects: objects];
            [townTable_ reloadData];
            // TODO(bowdidge): Scroll to insertion.
        } else if (tv == trainListTable_) {
            NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
            NSArray *classes = [NSArray arrayWithObject: [ScheduledTrain class]];
            objects = [pasteboard readObjectsForClasses: classes options: [NSDictionary dictionary]];
            NSLog(@"%@", objects);
            [trainArrayController_ addObjects: objects];
            [trainListTable_ reloadData];
            // TODO(bowdidge): Scroll to insertion.
        } else if (tv == yardTable_) {
            NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
            NSArray *classes = [NSArray arrayWithObject: [Yard class]];
            objects = [pasteboard readObjectsForClasses: classes options: [NSDictionary dictionary]];
            [yardArrayController_ addObjects: objects];
            [yardTable_ reloadData];
            // TODO(bowdidge): Scroll to insertion.
        }
    }
 }

- (TemplateCache*) templateCache {
    return theTemplateCache;
}

@end
