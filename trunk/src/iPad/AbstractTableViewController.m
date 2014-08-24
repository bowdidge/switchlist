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

// Regenerates the layout data needed by the table.
- (void) regenerateTableData {
}

// Raises the requested popover (either an Edit popover or something else), with the popover's arrow rooted
// within the specified portion of a cell.
// Returns the view controller for the popover.
- (id) doRaisePopoverWithStoryboardIdentifier: (NSString*) storyboardIdentifier
                                     fromRect: (CGRect) cellRect {
    
    UIStoryboard *storyboard;
    // The choosers used by more than one table view are stored in the main storyboard.
    if ([storyboardIdentifier isEqualToString: @"placeChooser"] ||
        [storyboardIdentifier isEqualToString: @"industryChooser"] ||
        [storyboardIdentifier isEqualToString: @"cargoChooser"] ||
        [storyboardIdentifier isEqualToString: @"carTypeChooser"]) {
        storyboard = [UIStoryboard storyboardWithName: @"MainStoryboard" bundle:[NSBundle mainBundle]];
    } else {
        storyboard = [UIStoryboard storyboardWithName: self.storyboardName bundle:[NSBundle mainBundle]];
    }
    id popoverVC = [storyboard instantiateViewControllerWithIdentifier: storyboardIdentifier];

    // Give editor a chance to call us back.
    
    if ([popoverVC respondsToSelector: @selector(setMyTableController:)]) {
        [popoverVC setMyTableController: self];
    }
   
   self.myPopoverController = [[[UIPopoverController alloc] initWithContentViewController: popoverVC] autorelease];
    // Freight car edit popover needs handle to popover to change its size.
    // Move rect to far left so that we try to have the edit popover point to the left.
    [self.myPopoverController presentPopoverFromRect: cellRect
                                              inView: [self view]
                            permittedArrowDirections: UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionRight
                                            animated: YES];
    return popoverVC;
}

// Raises the requested popover, centered on the cell of the table.
- (id) doRaisePopoverWithStoryboardIdentifier: (NSString*) storyboardIdentifier
                                fromIndexPath: (NSIndexPath*) indexPath {
    CGRect cellFrame = [self.myTableView rectForRowAtIndexPath: indexPath];
    CGRect cellRect = [self.myTableView convertRect: cellFrame toView: self.view];
    cellRect.size.width = 100;
    return [self doRaisePopoverWithStoryboardIdentifier: storyboardIdentifier fromRect: cellRect];
}

// Requests edit view be closed.
- (IBAction) doDismissEditPopover: (id) sender {
    [self.myPopoverController dismissPopoverAnimated: YES];
}

- (void) doCloseChooser: (id) sender {
}

@synthesize expandedCellPath;
@end
