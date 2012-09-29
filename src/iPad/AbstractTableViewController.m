//
//  AbstractTableViewController.m
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

#import "AbstractTableViewController.h"

#import "ExpandingEditViewController.h"

@interface AbstractTableViewController ()

@end

@implementation AbstractTableViewController
- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Notifies the table controller that the table data is invalid.  Called from edit popover.
- (void) layoutObjectsChanged: (id) sender {
    [self regenerateTableData];
    [self.myTableView reloadData];
}

// Regenerates the layout data needed by the table.  Overridden by subclasses.
- (void) regenerateTableData {
}

// Displays the popover with the content from the
// ExpandingEditViewController, with the popover's arrow rooted
// within the specified frame of the selected cell.
- (void) doRaisePopoverWithEditController: (ExpandingEditViewController*) evc
                            fromIndexPath: (NSIndexPath*) indexPath {
    CGRect cellFrame = [self.myTableView rectForRowAtIndexPath: indexPath];
    // Give editor a chance to call us back.
    evc.myTableController = self;
    CGRect cellRect = [self.myTableView convertRect: cellFrame toView: self.view];
   
   self.myPopoverController = [[[UIPopoverController alloc] initWithContentViewController: evc] autorelease];
    // Freight car edit popover needs handle to popover to change its size.
    // Move rect to far left so that we try to have the edit popover point to the left.
    cellRect.size.width = 100;
    [self.myPopoverController presentPopoverFromRect: cellRect
                                              inView: [self view]
                            permittedArrowDirections: UIPopoverArrowDirectionLeft
                                            animated: YES];
    
}

// Requests edit view be closed.
- (IBAction) doDismissEditPopover: (id) sender {
    [self.myPopoverController dismissPopoverAnimated: YES];
}

@end
