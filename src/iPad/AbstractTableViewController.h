//
//  AbstractTableViewController.h
//  SwitchList for iPad
//
//  Created by Robert Bowdidge on 9/9/12.
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

@class ExpandingEditViewController;

// Behavior common to all the table views for different
// kinds of objects.  Provides a common interface for create
// the edit popover common to all tables, and the interfaces
// for noting when the table needs to be regenerated from
// the backing objects.
@interface AbstractTableViewController : UITableViewController

// Handles redrawing the table when data objects change.  To be
// called from EditController when saving changes to object.
- (void) layoutObjectsChanged: (id) sender;

// Do the actual work to change the data structures filling the
// table, and triggers a redraw of the table.
// To be implemented by subclasses.
- (void) regenerateTableData;

// Raises a popover window for an edit view on the table.
// evc: EditViewController that controls the edit view
// indexPath: reference to selected cell to know where to
// put point of popover.
- (void) doRaisePopoverWithEditController: (ExpandingEditViewController*) evc
                              fromIndexPath: (NSIndexPath*) indexPath;

// Closes an existing popover.  To be called from EditController
// when window is explicitly to be closed (after a save).
// This code path not called when user touches outside the popover.
- (IBAction) doDismissEditPopover: (id) sender;

// Reference to currently active popover controller.
@property (retain, nonatomic) UIPopoverController *myPopoverController;
// IB outlet pointing to table view for this tab.
@property (retain, nonatomic) IBOutlet UITableView *myTableView;

@end
