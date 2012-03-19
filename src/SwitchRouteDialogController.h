//
//  SwitchRouteDialogController.h
//  SwitchList
//
//  Created by Robert Bowdidge on 7/23/07.
//
// Copyright (c)2007 Robert Bowdidge,
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
#import <AppKit/NSTableView.h>
#import "ScheduledTrain.h"
#import "EntireLayout.h"

// This class drives the sheet used for selecting the stations visited
// by a train.
@interface SwitchRouteDialogController : NSObject<NSTableViewDataSource> {
	// Public only for testing.
@public
	IBOutlet NSTableView *townTableView_;
	IBOutlet NSTableView *routeTableView_;
@protected
	IBOutlet NSButton *addButton_;
	IBOutlet NSButton *removeButton_;
	IBOutlet NSButton *cancelButton_;
	IBOutlet NSButton *okButton_;
	IBOutlet NSWindow *switchRouteDialogWindow_;
	// Array of all non-offline Place objects on the layout.  Used to populate the list of potential stops.
	NSArray *townList_;
	ScheduledTrain *trainBeingChanged_;
	// Array of all stops on the current train as Place objects.
	NSMutableArray *routeList_;
	EntireLayout *entireLayout_;
	
	IBOutlet NSTextField *sheetTitle_;
	IBOutlet NSTextField *warningText_;
}

- (IBAction) addTownToRoute: (id) sender;
- (IBAction) removeTownInRoute: (id) sender;
- (IBAction) cancel: (id) sender;
- (IBAction) done: (id) sender;

- (IBAction) update: (id) sender;
- (void) setTrain: (ScheduledTrain*) tr layout: (EntireLayout*) layout;
@end
