//
//  SwitchListDocument.h
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

#import <Cocoa/Cocoa.h>
#import <AppKit/NSPersistentDocument.h>
#import "EntireLayout.h"
#import "SwitchListDocumentInterface.h"
#import "SwitchRouteDialogController.h"
#import "SetTrainCarTypesDialogController.h"

@class DoorAssignmentRecorder;

@interface SwitchListDocument : NSPersistentDocument<SwitchListDocumentInterface> {
	IBOutlet NSTextField *freightCarCountField_;
	IBOutlet NSWindow *switchListWindow_;

	IBOutlet NSTabView *tabContainer_;
	IBOutlet NSTabViewItem *overviewTab_;
	IBOutlet NSTableView *overviewTrainTable_;
	NSArray *trains_; // for main overview
	
	IBOutlet NSButton *makeSwitchlistButton_;
	IBOutlet NSButton *annulTrainButton_;
	IBOutlet NSButton *trainCompletedButton_;
	
	IBOutlet NSTextField *summaryWarningsField_;
	IBOutlet NSButton *generateTodayLoadsButton_;
	IBOutlet NSButton *generateMoreButton_;

	IBOutlet NSButton *setRouteButton_;

	IBOutlet NSWindow *setRouteSheet_;
	IBOutlet SwitchRouteDialogController *switchRouteController_;

	// Car type sheet for trains tab.
	IBOutlet NSWindow *setCarTypesSheet_;
	IBOutlet NSTableView *carTypesAcceptedTable_;
	IBOutlet SetTrainCarTypesDialogController *trainCarTypesDialogController_;

	// Train tab.
	IBOutlet NSTableView *trainListTable_;
	IBOutlet NSTextField *carTypesLabel_;
	IBOutlet NSTextField *maxLengthField_;
	IBOutlet NSTextField *maxLengthLabel_;
	IBOutlet NSTextField *minCarsToRunField_;
	IBOutlet NSTextField *minCarsToRunLabel_;
	
	// Freight car tab
	IBOutlet NSTextField *lengthField_;
	IBOutlet NSTextField *lengthLabel_;
	
	
	// Industries tab
	IBOutlet NSButton *hasDoorsButton_;
	IBOutlet NSTextField *doorCountField_;
	IBOutlet NSTextField *doorCountLabel_;

	IBOutlet NSTextField *sidingLengthLabel_;	
	IBOutlet NSTextField *sidingFeetLabel_;	
	IBOutlet NSTextField *sidingLengthField_;
	// Access to the various controllers of popups so we can sort their contents (and make it
	// easier to find particular items.
	IBOutlet NSPopUpButton *freightCarLocationPopup_;
	IBOutlet NSArrayController *freightCarController_;
	
	IBOutlet NSArrayController *freightCarLocationArrayController_;

	IBOutlet NSArrayController *industryLocationArrayController_;
	IBOutlet NSPopUpButton *industryLocationPopup_;

	IBOutlet NSArrayController *cargoSourceLocationArrayController_;
	IBOutlet NSPopUpButton *cargoSourceLocationPopup_;
	
	IBOutlet NSArrayController *cargoDestinationLocationArrayController_;
	IBOutlet NSPopUpButton *cargoDestinationLocationPopup_;
	
	IBOutlet NSArrayController *yardLocationArrayController_;
	IBOutlet NSPopUpButton *yardLocationPopup_;
	
	IBOutlet NSArrayController *freightCarCargoArrayController_;
	IBOutlet NSPopUpButton *freightCarCargoPopup_;
	IBOutlet NSPopUpButton *freightCarCarTypePopup_;
	
	// Array controllers for main tables in each tab.
	IBOutlet NSArrayController *overviewTrainArrayController_;
	IBOutlet NSArrayController *freightCarArrayController_;
	IBOutlet NSArrayController *townArrayController_;
	IBOutlet NSArrayController *industryArrayController_;
	IBOutlet NSArrayController *cargoArrayController_;
	IBOutlet NSArrayController *trainArrayController_;
	IBOutlet NSArrayController *yardArrayController_;
	
	// Misc controllers
	// Car type in freightcar - experimenting only.
	IBOutlet NSArrayController *carTypeArrayController_;
	
	EntireLayout *entireLayout_;
	DoorAssignmentRecorder *doorAssignmentRecorder_;
	
	// Layout info 
	IBOutlet NSDatePicker *datePicker_;
	IBOutlet NSTextField *layoutNameField_;
	IBOutlet NSButton *enableDoorsButton_;
	
	IBOutlet NSTableView *carTypeTable_;
	IBOutlet NSTableColumn *carTypeTableColumn_;
	IBOutlet NSTableColumn *carTypeDescriptionTableColumn_;
	IBOutlet NSButton *addCarTypeButton_;
	IBOutlet NSButton *removeCarTypeButton_;
	
	// Filters to limit what appears in popups.
	NSPredicate *locationIsNotOfflineFilter_;
	NSPredicate *placeIsNotOfflineFilter_;
}


- (IBAction) doAssignCars: (id) sender;
// Creates an extra 10% of loads and adds them to existing trains
// to increase the traffic this session.
- (IBAction) doAddMoreCars: (id) sender;
	
- (IBAction) doGenerateSwitchList: (id) sender;
- (IBAction) doAnnulTrain: (id) sender;
- (IBAction) doCompleteTrain: (id) sender;
/**
 * Selects a random set of cargos, and assigns them to available freight cars.
 */
- (void) createAndAssignNewCargos: (int) loadsToAdd;

- (IBAction) updateSummaryInfo: (id) sender;

// scorched earth on loads -- for debugging, mainly.
- (IBAction) doClearAllLoads: (id)sender;
- (IBAction) doAdvanceLoads: (id) sender; // finish loads/unloads and reassign.

- (IBAction) doSetRoute: (id) sender;

// Bring up car types dialog for setting which cars a train will carry.
- (IBAction) doSetCarTypes: (id) sender;

- (IBAction) doChangeDate: (id) sender;
- (IBAction) doChangeLayoutName: (id) sender;
- (IBAction) doChangeDoorsState: (id) sender;
- (IBAction) doChangeRespectSidingLengthsState: (id) sender;

- (IBAction) doImportCars: (id) sender;

- (IBAction) doCarReport: (id) sender;
- (IBAction) doIndustryReport: (id) sender;
- (IBAction) doCargoReport: (id) sender;
- (IBAction) doReservedCarReport: (id) sender;
- (IBAction) doYardReport: (id) sender;

// Car type table - providing data.
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;

// car type table - delegation.
/* Allows the delegate to provide further setup for 'cell' in 'tableColumn'/'row'. It is not safe to do drawing inside this method, and you should only setup state for 'cell'.
 */ 
- (BOOL)selectionShouldChangeInTableView:(NSTableView *)tableView;


// Returns EntireLayout object so other windows can get access to global layout information.
- (EntireLayout*) entireLayout;
// For switch list generators to get knowledge of door assignments.
- (DoorAssignmentRecorder*) doorAssignmentRecorder;

// Enable/disable door spotting ui.
- (void) setDoorsButtonState: (BOOL) shouldBeOn;
// Hides or exposes siding length UI as needed.
- (void) setSidingLengthButtonState: (BOOL) enable;
@end 

// Settings for the preferences dictionary.
extern NSString *LAYOUT_PREFS_SHOW_DOORS_UI;
extern NSString *LAYOUT_PREFS_DEFAULT_NUM_LOADS;
extern NSString *LAYOUT_PREFS_SHOW_SIDING_LENGTH_UI;
