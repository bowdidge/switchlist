//
//  FreightCarTableViewController.h
//  SwitchList for iPad
//
//  Created by Robert Bowdidge on 9/8/12.
//  Copyright (c) 2012 Robert Bowdidge. All rights reserved.
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

#import <UIKit/UIKit.h>

#import "AbstractTableViewController.h"

@class FreightCarTableCell;

// Controller for freight car table in freight car tab.
@interface FreightCarTableViewController : AbstractTableViewController


// Handle presses on a cell's freight car location, type, or cargo.  Show a popover to allow selecting one item.
- (IBAction) doCarTypePressed: (id) sender;
- (IBAction) doLocationPressed: (id) sender;
- (IBAction) doCargoPressed: (id) sender;

// Reload all data from railroad again.
- (void) regenerateTableData;

// Handle changes to items that require resorting the table.
- (IBAction) noteTableCell: (FreightCarTableCell*) cell changedCarReportingMarks: (NSString*) reportingMarks;

// Requests edit view be closed.

@property (retain, nonatomic) NSArray *allFreightCars;
@property (retain, nonatomic) NSArray *allFreightCarsOnWorkbench;
@end
