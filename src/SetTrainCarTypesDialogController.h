//
//  SetTrainCarTypesDialogController.h
//  SwitchList
//
//  Created by bowdidge on 11/7/10.
//
// Copyright (c)2010 Robert Bowdidge,
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

@class EntireLayout;
@class ScheduledTrain;

// Controller hiding some of the interaction behavior for the sheet
// letting the user choose which kinds of freight cars are carried by the
// current train.
@interface SetTrainCarTypesDialogController : NSObject<NSTableViewDataSource>  {
	IBOutlet NSWindow *trainCarTypesDialogWindow_;
	IBOutlet NSTableView *trainCarTypesTable_;
	IBOutlet NSTableColumn *checkBoxColumn_;
	IBOutlet NSTableColumn *carTypeNameColumn_;
	IBOutlet NSTableColumn *carTypeDescriptionColumn_;

	IBOutlet NSTextField *_sheetTitle;

	EntireLayout *entireLayout_;
	ScheduledTrain *trainToChange_;
	
	// Cached and sorted.
	NSMutableArray *allCarTypes_;
	// Working set of car types currently accepted by the train.
	NSMutableSet *currentCarTypes_;
}

// Sets up the current train and layout for populating the dialog controller.
// Call before displaying the dialog.
- (void) setTrain: (ScheduledTrain*) tr layout: (EntireLayout*) layout;

// Actions for the OK/Cancel buttons in the dialog.
- (IBAction) cancel: (id) sender;
- (IBAction) done: (id) sender;

@end
