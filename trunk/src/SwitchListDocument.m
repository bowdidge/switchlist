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

#import "SwitchListDocument.h"

#import "CarAssigner.h"
#import "Cargo.h"
#import "CargoAssigner.h"
#import "CargoReport.h"
#import "CarReport.h"
#import "CarType.h"
#import "CarTypes.h"
#import "EntireLayout.h"
#import "FreightCar.h"
#import "GlobalPreferences.h"
#import "HTMLSwitchListWindowController.h"
#import "HTMLSwitchlistRenderer.h"
#import "Industry.h"
#import "IndustryReport.h"
#import "KaufmanSwitchListView.h"
#import "Place.h"
#import "PICLReport.h"
#import "PrintEverythingView.h"
#import "ReservedCarReport.h"
#import "ScheduledTrain.h"
#import "SouthernPacificSwitchListView.h"
#import "SwitchListAppDelegate.h"
#import "SwitchListReport.h"
#import "SwitchListView.h"
#import "SwitchListReportWindowController.h"
#import "TrainAssigner.h"
#import "Yard.h"
#import "YardReport.h"

#define DEBUG_CAR_ASSN 1

// Adds up all the cargo counts from all cargos in the project, and
// divides by 7 to find daily count.  Used for displaying loads/day in
// the cargo tab, and helps users understand if the number of cargos
// is balanced relative to the number of freight cars.
// On the InterfaceBuilder side, this is set up as looking at arrangedObjects
// for the table, and grabbing each of the carsPerWeek value from all visible
// cargos.  This ensures that the value is recalculated whenever carsPerWeek
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

// Adds up all the carsPerWeek and divides by seven to calculate the 
// preferred loads per day.
// This code should match the loadsPerDay calculation in SwitchListDocument.
- (id)transformedValue:(id)value {
	NSArray *allCargoCounts = (NSArray*) value;
	int curSum=0;
	NSNumber *thisCargo;
	NSEnumerator *e = [allCargoCounts objectEnumerator];
	while ((thisCargo = [e nextObject]) != nil) {
		int thisCargoCarsPerWeek = [thisCargo intValue];
		curSum += thisCargoCarsPerWeek;
	}
	return [NSNumber numberWithInt: curSum / 7];
}
@end

/**
 * Controller object for the main document. 
 */
@implementation SwitchListDocument
- (id)init 
{
    [super init];
	entireLayout_ = nil;
	locationIsNotOfflineFilter_ = [[NSPredicate predicateWithFormat: @"self.location.isOffline == 0 OR self.location.name LIKE \"Workbench\""] retain];
	placeIsNotOfflineFilter_ = [[NSPredicate predicateWithFormat: @"self.isOffline == 0"] retain];
	trains_ = nil;
	doorAssignmentRecorder_ = nil;
    return self;
}

- (void) dealloc {
	[placeIsNotOfflineFilter_ release];
	[locationIsNotOfflineFilter_ release];
	[entireLayout_ release];
	[trains_ release];
	[doorAssignmentRecorder_ release];
	[super dealloc];
}

// Examines the current layout database, and changes all model objects to use
// the new relationship-based CarType rather than the string based approach.
// Searches the existing database for all car types used.
// Only needed for going from v2 to v3 of the file format, and only runs if no
// CarType objects exist.
- (void) updateLayoutToUseCarTypeObjects {
	if ([[entireLayout_ allCarTypes] count] == 0) {
		// No car types - set up default.
		NSDictionary* currentlyUsedCarTypes = [CarTypes populateCarTypesFromLayout: entireLayout_];
		for (NSString *carTypeName in currentlyUsedCarTypes) {
			CarType *carType = [NSEntityDescription insertNewObjectForEntityForName:@"CarType"
															 inManagedObjectContext: [self managedObjectContext]];
			[carType setCarTypeName: carTypeName];
			[carType setCarTypeDescription: [currentlyUsedCarTypes objectForKey: carTypeName]];
		}
		
		NSMutableDictionary *nameToCarTypeMap = [NSMutableDictionary dictionary];
		NSArray *allCarTypes = [entireLayout_ allCarTypes];
		for (CarType *ct in allCarTypes) {
			[nameToCarTypeMap setObject: ct forKey: [ct carTypeName]];
		}
		 
		// If there weren't any car types, then the file still has the old ones.  Update.
		NSArray *allFreightCars = [entireLayout_ allFreightCars];
		for (FreightCar *fc in allFreightCars) {
			[fc setCarTypeRel: [nameToCarTypeMap objectForKey: [fc primitiveValueForKey: @"carType"]]];
		}
		
		NSArray *allCargos = [entireLayout_ allCargos];
		for (Cargo *cargo in allCargos) {
			[cargo setCarTypeRel: [nameToCarTypeMap objectForKey: [cargo primitiveValueForKey: @"carType"]]];
		}
		
		NSArray *allTrains = [entireLayout_ allTrains];
		for (ScheduledTrain *train in allTrains) {
			NSString *carTypesAccepted = [train primitiveValueForKey: @"acceptedCarTypes"];
			NSArray *types = [carTypesAccepted componentsSeparatedByString: @","];
			NSMutableSet *carTypes = [NSMutableSet set];
			for (NSString *type in types) {
				// Ignore Any.
				if ([type isEqualToString: @"Any"]) continue;

				CarType *ct = [nameToCarTypeMap objectForKey: type];
				[carTypes addObject: ct];
			}
			[train setPrimitiveValue: carTypes forKey: @"acceptedCarTypesRel"];
		}
	}
}	

- (void) awakeFromNib {
	entireLayout_ = [[EntireLayout alloc] initWithMOC: [self managedObjectContext]];
	
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
	
	// Disable the car length controls if the layout preference isn't set.
	NSNumber *useCarLengths = [layoutPrefs objectForKey: LAYOUT_PREFS_SHOW_SIDING_LENGTH_UI];
	if (!useCarLengths || [useCarLengths boolValue] == NO) {
		[self setSidingLengthButtonState: NO];
	} else {
		[self setSidingLengthButtonState: YES];
	}

	[overviewTrainTable_ setDoubleAction: @selector(doGenerateSwitchList:)];
	
	NSPredicate *pred = [NSPredicate predicateWithFormat: @"isYard == NO"];
	[industryArrayController_ setFilterPredicate: pred];
	
	// Set up the panel.
	[datePicker_ setDateValue: [entireLayout_ currentDate]];
	[layoutNameField_ setStringValue: [entireLayout_ layoutName]];
	
	// If we need to upgrade, do so.
	[self updateLayoutToUseCarTypeObjects];
	
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

  BOOL result = [super configurePersistentStoreCoordinatorForURL:url
                              ofType:fileType
                        modelConfiguration:configuration
                           storeOptions:options
                               error:error];
  [options release], options = nil;
  return result;
}

// Prints switchlists for all trains on the layout that have work.
- (IBAction)printDocument:(id)sender {
	NSString *preferredSwitchlistStyle = [[NSUserDefaults standardUserDefaults] stringForKey: GLOBAL_PREFS_SWITCH_LIST_DEFAULT_TEMPLATE];
	
	SwitchListAppDelegate *appDelegate = (SwitchListAppDelegate*) [[NSApplication sharedApplication] delegate];
	Class reportClass = [[appDelegate nameToSwitchListClassMap] objectForKey: preferredSwitchlistStyle];
	if (reportClass == nil) {
		// For now, default to handwritten.
		// TODO(bowdidge): Add "print all" feature for HTML templates.
		reportClass = [SwitchListView class];
	}
	
	PrintEverythingView *pev = [[PrintEverythingView alloc] initWithFrame: NSMakeRect(0.0,0.0,100.0,100.0) withDocument: self
															withViewClass: reportClass];
    [[NSPrintOperation printOperationWithView:pev] runOperation];
	[pev autorelease];
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
	
// This *should* be sorting the main tables in each view, but it isn't.
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

	int errorCode = [inError code];
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
	
// Override so we can do some cleanup of inappropriate old choices.	
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
	return doorAssignmentRecorder_;
}

// finish loads/unloads and reassign.
- (IBAction) doAdvanceLoads: (id) sender {
	NSArray *freightCarsToAdvance = [entireLayout_ allFreightCarsAtDestination];
	NSEnumerator *e = [freightCarsToAdvance objectEnumerator];
	id car;
	while ((car = [e nextObject]) != nil) {
		if ([car isLoaded] == NO) {
			[car setIsLoaded: YES];
			// cargo stays the same
		} else {
			[car setIsLoaded: NO];
			[car setValue: nil forKey: @"cargo"];
		}
	}
	
	// Finally, advance the day.
	NSDate *currentDate = [entireLayout_ currentDate];
	// Add one day.
	currentDate = [currentDate addTimeInterval: (60 * 60 * 24)];
	[datePicker_ setDateValue: currentDate];
	[entireLayout_ setCurrentDate: currentDate];
	
	// Generate loads for today.
	int numberOfCargos = [entireLayout_ loadsPerDay];
	[self createAndAssignNewCargos: numberOfCargos];
	[self doAssignCars: self];
	[self updateSummaryInfo:self];
}

- (void) assignCarsToTrains: (NSArray*) allTrains {
	// Start from scratch (all cars, not just available) to make sure the placement is right.
	NSArray *allFreightCars = [entireLayout_ allFreightCars];

	NSEnumerator *e = [allFreightCars objectEnumerator];
	FreightCar *car;
	while ((car = [e nextObject]) != nil) {
		[car setCurrentTrain: nil];
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
	
	TrainAssigner *ta = [[TrainAssigner alloc] initWithLayout: entireLayout_ useDoors: useDoors respectSidingLengths: respectSidingLengths];

	[ta assignCarsToTrains: allTrains];
	[doorAssignmentRecorder_ release];
	doorAssignmentRecorder_ = [[ta doorAssignmentRecorder] retain];
	NSArray *errs = [ta errors];
	SwitchListAppDelegate *appDelegate = (SwitchListAppDelegate*) [[NSApplication sharedApplication] delegate];
	[appDelegate setProblems: errs];
	
	[ta release];
}

/**
 * Selects a random set of cargos, and assigns them to available freight cars.
 */
- (void) createAndAssignNewCargos: (int) loadsToAdd {

	CargoAssigner *assigner = [[[CargoAssigner alloc] initWithEntireLayout: entireLayout_] autorelease];
	NSArray *cargosForToday = [assigner cargosForToday: loadsToAdd];
	// Keep track of how many cargos couldn't be filled to help layout owner with cargo balance.
	NSMutableDictionary *carTypeUnavailableCount = [NSMutableDictionary dictionary];
	
	NSArray *allFreightCars = [entireLayout_ allAvailableFreightCars];
	id cargo;
	
	// Sanity check.
	if ([allFreightCars count] < 1) {
		return;
	}
	
	CarAssigner *carAssigner = [[CarAssigner alloc] initWithUnassignedCars: allFreightCars layout: entireLayout_];

	NSEnumerator *cargoEnum = [cargosForToday objectEnumerator];
	while ((cargo = [cargoEnum nextObject]) != nil) {
		
		FreightCar *frtCar = [carAssigner assignedCarForCargo: cargo];
		
		if (frtCar == nil) {
			// No cars available - increase the count on this cargo in the unavailable cars dict.
			NSString *cargoCarReqt = [[cargo carTypeRel] carTypeName];
			if (cargoCarReqt == nil) {
					cargoCarReqt = @"Unspecified";
			}
			NSNumber *count = [carTypeUnavailableCount valueForKey: cargoCarReqt];
			if (count == nil) {
				// first car of this type that's unavailable.
				count = [NSNumber numberWithInt: 1];
			} else {
				count = [NSNumber numberWithInt: [count intValue] + 1];
			}
			[carTypeUnavailableCount setObject: count forKey: cargoCarReqt];;
		}
	}
	[carAssigner release];

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

// scorched earth on loads -- for debugging, mainly.
- (IBAction) doClearAllLoads: (id)sender {
	
	NSAlert *alert = [NSAlert alertWithMessageText: @"Are you sure you want to clear cargo loads from all cars?"
		defaultButton: @"OK" alternateButton: @"Cancel" otherButton: nil
		 informativeTextWithFormat: @"Clearing cargos can help if you have changed cargos and car types significantly.  Otherwise, it just adds a bit of chaos til loads get sorted out."];
		 
	// returns 1 for OK, 0 for cancel.
	int ret = [alert runModal];
	if (ret != 1) {
		return;
	}

	NSArray *unavailableFreightCars = [entireLayout_ allReservedFreightCars];
	NSEnumerator *e = [unavailableFreightCars objectEnumerator];
	id car;
	while ((car = [e nextObject]) != nil) {
		[car setIsLoaded: NO];
		[car setCargo: nil];
		[car setCurrentTrain: nil];
	}
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
	[self assignCarsToTrains: [entireLayout_ allTrains]];
	[self updateSummaryInfo: self];
}

// Handle request to generate a switch list printout.
- (IBAction) doGenerateSwitchList: (id) sender {
	NSIndexSet *selection = [overviewTrainTable_ selectedRowIndexes];
	if ([selection count] > 1) {
		NSBeep(); return;
	}
	int selRow = [selection firstIndex];
	ScheduledTrain *train = [trains_ objectAtIndex: selRow];
	
	SwitchListBaseView *switchListView;
	SwitchListAppDelegate *appDelegate = (SwitchListAppDelegate*) [[NSApplication sharedApplication] delegate];
	NSString *preferredSwitchlistStyle = [[NSUserDefaults standardUserDefaults] stringForKey: GLOBAL_PREFS_SWITCH_LIST_DEFAULT_TEMPLATE];
	Class reportClass = [[appDelegate nameToSwitchListClassMap] objectForKey: preferredSwitchlistStyle];
									   
	if (reportClass == nil) {
		// There's no native way of drawing this, so fall back on the HTML version.
		NSString *title = [NSString stringWithFormat: @"Switch list for %@", [train name]];
		HTMLSwitchlistRenderer *renderer = [[HTMLSwitchlistRenderer alloc] initWithBundle: [NSBundle mainBundle]];
		[renderer setTemplate: preferredSwitchlistStyle];
		NSString *switchlistHtmlFile = [renderer filePathForTemplateFile: @"switchlist"];

		NSString *message = [renderer renderSwitchlistForTrain:train layout:[self entireLayout] iPhone: NO];
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

- (IBAction) doAnnulTrain: (id) sender {
	NSIndexSet *selection = [overviewTrainTable_ selectedRowIndexes];
	int selRow = [selection firstIndex];
	
	NSMutableArray *allTrains = [NSMutableArray arrayWithArray: [entireLayout_ allTrains]];
	while (selRow != NSNotFound) {
		// Redistribute the cars to the trains that have yet to run.
		ScheduledTrain *trainToAnnul = [trains_ objectAtIndex: selRow];
		[allTrains removeObject: trainToAnnul];
		NSSet *carsInTrain = [NSSet setWithSet: [trainToAnnul freightCars]];
		for (FreightCar *car in carsInTrain) {
			[car removeFromTrain];
		}
		selRow = [selection indexGreaterThanIndex:selRow];
	}
	
	// and reassign.
	[self assignCarsToTrains: allTrains];
	
	// do something here
	[self updateSummaryInfo: self];
}


- (IBAction) doCompleteTrain: (id) sender {
	NSIndexSet *selection = [overviewTrainTable_ selectedRowIndexes];
	
	int selRow = [selection firstIndex];
    while (selRow != NSNotFound) {
		ScheduledTrain *train = [trains_ objectAtIndex: selRow];
		
		NSSet *carMvmts = [NSSet setWithSet: [train freightCars]];
		for (FreightCar *car in carMvmts) {
			if (![car moveOneStep]) {
				// Problem occurred - silently fail.
			}
		}
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

/**
 * Handles presses on "Set Route" button in Trains panel.  Brings up dialog box to allow user to select
 * the stops a train makes.
 */
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
	[switchRouteController_ update: self];
}

/* When the date in the Layout Preferences changes, update the EntireLayout's date. */
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
							 informativeTextWithFormat: outErrors];
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
						 informativeTextWithFormat: successString];
	[alert runModal];
}
	
- (IBAction) doCarReport: (id) sender {
	HTMLSwitchlistRenderer *renderer = [[HTMLSwitchlistRenderer alloc] initWithBundle: [NSBundle mainBundle]];
	NSString *preferredSwitchlistStyle = [[NSUserDefaults standardUserDefaults] stringForKey: GLOBAL_PREFS_SWITCH_LIST_DEFAULT_TEMPLATE];
	[renderer setTemplate: preferredSwitchlistStyle];
	NSString *carReport = [renderer filePathForTemplateFile: @"car-report"];
	NSString *message = [renderer renderReport: @"car-report"
									  withDict: [NSDictionary dictionaryWithObject: [self entireLayout]
																			forKey: @"layout"]];
	
	HTMLSwitchListWindowController *view =[[HTMLSwitchListWindowController alloc] initWithTitle: @"Car Report"];
	[[view window] makeKeyAndOrderFront: self];
	
	[view drawHTML: message template: carReport];	
}

- (IBAction) doIndustryReport: (id) sender {
	HTMLSwitchlistRenderer *renderer = [[HTMLSwitchlistRenderer alloc] initWithBundle: [NSBundle mainBundle]];
	NSString *preferredSwitchlistStyle = [[NSUserDefaults standardUserDefaults] stringForKey: GLOBAL_PREFS_SWITCH_LIST_DEFAULT_TEMPLATE];
	[renderer setTemplate: preferredSwitchlistStyle];
	NSString *industryHtml = [renderer filePathForTemplateFile: @"industry-report"];
	NSString *message = [renderer renderReport: @"industry-report"
									  withDict: [NSDictionary dictionaryWithObject: [self entireLayout]
																			forKey: @"layout"]];
	
	HTMLSwitchListWindowController *view =[[HTMLSwitchListWindowController alloc] initWithTitle: @"Industry Report"];
    [[view window] makeKeyAndOrderFront: self];
	[view drawHTML: message template: industryHtml];	
}

- (IBAction) doCargoReport: (id) sender {
	CargoReport *report = [[CargoReport alloc] initWithDocument: self
												 withIndustries: [[self entireLayout] allIndustries]];
	[report setObjects: [[self entireLayout] allValidCargos]];
	[report generateReport];
}

- (IBAction) doReservedCarReport: (id) sender {
	HTMLSwitchlistRenderer *renderer = [[HTMLSwitchlistRenderer alloc] initWithBundle: [NSBundle mainBundle]];
	NSString *preferredSwitchlistStyle = [[NSUserDefaults standardUserDefaults] stringForKey: GLOBAL_PREFS_SWITCH_LIST_DEFAULT_TEMPLATE];
	[renderer setTemplate: preferredSwitchlistStyle];
	NSString *reservedCarReport = [renderer filePathForTemplateFile: @"reserved-car-report"];
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
	HTMLSwitchlistRenderer *renderer = [[HTMLSwitchlistRenderer alloc] initWithBundle: [NSBundle mainBundle]];
	NSString *preferredSwitchlistStyle = [[NSUserDefaults standardUserDefaults] stringForKey: GLOBAL_PREFS_SWITCH_LIST_DEFAULT_TEMPLATE];
	[renderer setTemplate: preferredSwitchlistStyle];
	NSString *yardHtml = [renderer filePathForTemplateFile: @"yard-report"];
	NSString *message = [renderer renderReport: @"yard-report"
									  withDict: [NSDictionary dictionaryWithObject: [self entireLayout]
																			forKey: @"layout"]];
	
	HTMLSwitchListWindowController *view =[[HTMLSwitchListWindowController alloc] initWithTitle: @"Reserved Car Report"];
	[[view window] makeKeyAndOrderFront: self];
	[view drawHTML: message template: yardHtml];
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
	int numberOfFreightCars = [[entireLayout_ allFreightCars] count];
	
	int numberOfAssignedFreightCars = [[entireLayout_ allReservedFreightCars] count];
	int numberOfCarsOnWorkbench = [[entireLayout_ allFreightCarsOnWorkbench] count];
	
	NSMutableString *freightCarStatus = [NSMutableString stringWithFormat: @"%d freight cars, %d assigned",
										 numberOfFreightCars, numberOfAssignedFreightCars];
	if (numberOfCarsOnWorkbench > 0) {
		[freightCarStatus appendFormat: @", %d at workbench", numberOfCarsOnWorkbench];
	}
	[freightCarCountField_ setStringValue: freightCarStatus];

	[generateMoreButton_ setTitle: [NSString stringWithFormat: @"Add %d more loads", [self additionalCarsPerDay]]];

	[overviewTrainTable_ reloadData];

	NSIndexSet *selection = [overviewTrainTable_ selectedRowIndexes];
	BOOL enableButtons = ([selection count] > 0) ;
	[makeSwitchlistButton_ setEnabled: enableButtons];
	[annulTrainButton_ setEnabled: enableButtons];
	[trainCompletedButton_ setEnabled: enableButtons];
	[overviewTrainTable_ reloadData];
	
}

// Table count for train table in Overview tab.  We'll display
// all trains in the database.
- (int) numberOfRowsInTrainTableView {
	if (trains_ == nil) {
		[self updateAndCacheListOfTrains];
	}
	return [trains_ count];
}

// Populates train table in Overview tab.
- (id)trainTableObjectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row {
	if (trains_ == nil) {
		[self updateAndCacheListOfTrains];
	}

	// TODO(bowdidge): Replace with comparisons to TableColumn objects.
	if ([[[tableColumn headerCell] title] isEqualToString: @"Name"]) {
		return [[trains_ objectAtIndex: row] name];
	} else if ([[[tableColumn headerCell] title] isEqualToString: @"cars moved"]) {
		ScheduledTrain *train = [trains_ objectAtIndex: row];
		NSSet *cars = [train freightCars];
		if (cars != nil) {
			int carCt = [cars count];
			return [NSString stringWithFormat: @"%d",carCt];
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
- (int)numberOfRowsInTableView:(NSTableView *)tableView {
	if (tableView == overviewTrainTable_) {
		return [self numberOfRowsInTrainTableView];
	} else {
		assert(1==0);
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

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row {
	if (tableView == overviewTrainTable_) {
		return [self trainTableObjectValueForTableColumn: tableColumn row: row];
	} else {
		assert(1==0);
	}
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
	// Update summary info and re-enable buttons.
	[self updateSummaryInfo: self];
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

- (BOOL) selectionShouldChangeInTableView: (id) a {
	return YES;
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
	[minCarsToRunField_ setHidden: !enable];
	[minCarsToRunLabel_ setHidden: !enable];
	[maxLengthField_ setHidden: !enable];
	[maxLengthLabel_ setHidden: !enable];
	[sidingLengthLabel_ setHidden: !enable];
	[sidingFeetLabel_ setHidden: !enable];
	[sidingLengthField_ setHidden: !enable];
}

@end

NSString *LAYOUT_PREFS_SHOW_DOORS_UI = @"SpotToDoorsAtIndustries";
NSString *LAYOUT_PREFS_DEFAULT_NUM_LOADS = @"DefaultNumberOfLoads";
NSString *LAYOUT_PREFS_SHOW_SIDING_LENGTH_UI = @"ShowSidingLength";