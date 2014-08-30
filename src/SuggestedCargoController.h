// 
//  SuggestedCargoController.h
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


#import <Cocoa/Cocoa.h>

@class Industry;
@class SwitchListDocument;
@class TypicalIndustryStore;

// Represents a potential cargo for the current industry.
@interface ProposedCargo : NSObject {
    NSNumber *isKeep;
    BOOL isReceive;
    NSString *name;
    NSString *carsPerWeek;
    InduYard *industry;
    BOOL isExistingCargo;
}
// Value of checkbox whether to create this cargo.  NSNumber required
// for checkbox.
@property (nonatomic, retain) NSNumber *isKeep;
// Is incoming cargo.
@property (nonatomic) BOOL isReceive;
// String value for receive column: either "Receive" or "Ship".
@property (nonatomic, readonly) NSString *receiveString;
// Cargo description.
@property (nonatomic, retain) NSString *name;
// Rate of cars arriving or departing.
@property (nonatomic, retain) NSString *carsPerWeek;
// Preferred industry as source/dest of cargo.
@property (nonatomic, retain) InduYard *industry;
// Existing cargo just being shown for context?
@property (nonatomic) BOOL isExistingCargo;
@end

// Controller for the Cargo Assistant dialog box.
@interface SuggestedCargoController : NSObject<NSTableViewDelegate> {
	IBOutlet NSPopUpButton *currentIndustryButton_;
	IBOutlet NSPopUpButton *suggestedIndustriesButton_;
	IBOutlet NSTextField *titleTextField_;
	IBOutlet NSTextField *desiredCarsPerWeek_;
	IBOutlet NSTableView *cargosTable_;
	IBOutlet NSButton *createButton_;
	IBOutlet NSButton *cancelButton_;
	IBOutlet SwitchListDocument *document_;
	IBOutlet NSArrayController *proposedCargoArrayController_;
	IBOutlet NSArrayController *currentIndustryArrayController_;
	IBOutlet NSArrayController *industryColumnArrayController_;
	IBOutlet NSTextField *proposedCargoCountMsg_;
	IBOutlet NSWindow *window_;
	
	// Current industry selected in Cargo Assistant window.
	Industry *currentIndustry_;
	// Object storing the potential cargo database.
	TypicalIndustryStore *store_;
}
// Updates the table to show sample cargos for the provided category number.
- (void) setCargosToCategory: (NSString*) categoryLabel;
// Action when the potential industry class is changed.
- (IBAction) doChangeIndustryClass: (id) sender;
// Action when the current industry is changed.
- (IBAction) doChangeIndustry: (id) sender;
// Action when the carsPerWeek field is changed.
- (IBAction) doChangeCarsPerWeek: (id) sender;
// Create button is pressed.
- (IBAction) doCreate: (id) sender;
	
- (NSWindow*) window;

@end
