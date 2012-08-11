//
//  SetTrainCarTypesDialogController.m
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

#import "SetTrainCarTypesDialogController.h"

#import "CarType.h"
#import "EntireLayout.h"
#import "SCheduledTrain.h"


@implementation SetTrainCarTypesDialogController

- (id) init {
	[super init];
	allCarTypes_ = nil;
	currentCarTypes_ = nil;
	return self;
}

- (void) dealloc {
	[allCarTypes_ release];
	[currentCarTypes_ release];
	[super dealloc];
}

// Method for passing in info about what we're editing.
- (void) setTrain: (ScheduledTrain*) tr layout: (EntireLayout*) layout{
	[trainToChange_ release];
	trainToChange_ = [tr retain];
	
	[entireLayout_ release];
	entireLayout_ = [layout retain];
	allCarTypes_ = [[NSMutableArray alloc] initWithArray: [entireLayout_ allCarTypes]];
	[allCarTypes_ sortUsingSelector: @selector(compare:)];

	NSSet *officialCarTypes = [trainToChange_ primitiveValueForKey: @"acceptedCarTypesRel"];
	if ([officialCarTypes count] == 0) {
		currentCarTypes_ = [[NSMutableSet alloc] initWithArray: allCarTypes_];
	} else {
		currentCarTypes_ = [[NSMutableSet alloc] initWithSet: officialCarTypes];
	}
    [trainCarTypesTable_ reloadData];
	[_sheetTitle setStringValue: [NSString stringWithFormat: @"Car types for \"%@\" to carry:", [trainToChange_ name]]];
}

- (IBAction) done: (id) sender {
	// If all are selected, mark as none.
	if ([currentCarTypes_ count] == [allCarTypes_ count]) {
		[trainToChange_ setCarTypesAcceptedRel: [NSSet set]];
	} else {
		[trainToChange_ setCarTypesAcceptedRel: currentCarTypes_];
	}
	[NSApp endSheet: trainCarTypesDialogWindow_];
}

- (IBAction) cancel: (id) sender {
	[NSApp endSheet: trainCarTypesDialogWindow_];
}

// Data sources for the table of car types.
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
	return [allCarTypes_ count];
}

- (void)tableView:(NSTableView *)aTable setObjectValue:(id)aData 
   forTableColumn:(NSTableColumn *)aCol 
			  row:(NSInteger)aRow {
	// Only for check box - editing off elsewhere.
	NSNumber *result = (NSNumber*) aData;
	if ([result boolValue] == NO) {
		[currentCarTypes_ removeObject: [allCarTypes_ objectAtIndex: aRow]];
	} else {
		[currentCarTypes_ addObject: [allCarTypes_ objectAtIndex: aRow]];
	}
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	CarType *carType = [allCarTypes_ objectAtIndex: row];
	if (tableColumn == carTypeNameColumn_) {
		return [carType carTypeName];
	} else if (tableColumn == carTypeDescriptionColumn_) {
		return [carType carTypeDescription];
	} else {
		if ([currentCarTypes_ containsObject: carType]) {
			return [NSNumber numberWithBool: YES];
		} else {
			return [NSNumber numberWithBool: NO];
		}
	}
	return @"";
}
@end
