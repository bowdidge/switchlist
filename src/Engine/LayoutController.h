//
//  LayoutController.h
//  SwitchList
//
//  Created by bowdidge on 3/6/11.
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
//


#import <Foundation/Foundation.h>

#import "EntireLayout.h"

// The LayoutController class combines all the standard manipulations of a layout when
// operating - advancing cars, creating new cargos, loading those cars, and completing trains -
// into one class separate from the SwitchListDocument class used for controlling the UI.
// This code is intended to be used both by the UI and by separate integration tests.
@interface LayoutController : NSObject {
	EntireLayout *entireLayout_;
	DoorAssignmentRecorder *doorAssignmentRecorder_;
}
- (id) initWithEntireLayout: (EntireLayout*) layout;

// Marks unloaded cars as loaded, and loaded as empty,
// then creates new cargos and assigns those to cars.
- (void) advanceLoads;

// Creates the requested number of cargos and assigns them to unassigned cars.
// Returns dictionary mapping car type name (as string) to NSNumber showing number of cars
// that could not be loaded.
- (NSMutableDictionary *) createAndAssignNewCargos: (int) loadsToAdd;


// Assigns all freight cars on the layout to the trains listed, while respecting siding lengths and doors
// if requested.  Returns array of strings describing any errors encontered during assignment process.
- (NSArray *) assignCarsToTrains: (NSArray*) allTrains respectSidingLengths: (BOOL) respectSidingLengths useDoors: (BOOL) useDoors ;

// Move all freight cars to their final location.
- (void) completeTrain: (ScheduledTrain *) train;

// Clears all cargos from all freight cars.
- (void) clearAllLoads;


// For switchlists to get door assignment info.
- (DoorAssignmentRecorder*) doorAssignmentRecorder;
@property (retain) EntireLayout *entireLayout;
@property (retain) DoorAssignmentRecorder *doorAssignmentRecorder;
@end
