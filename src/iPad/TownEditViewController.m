//
//  TownEditViewController.m
//  SwitchList
//
//  Created by Robert Bowdidge on 9/22/12.
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

#import "TownEditViewController.h"

#import "AppDelegate.h"
#import "EntireLayout.h"
#import "Place.h"
#import "TownTableViewController.h"

@interface TownEditViewController ()
@property (nonatomic, retain) IBOutlet UITextField *townNameTextField;
@property (nonatomic, retain) IBOutlet UISegmentedControl *townLocationControl;

@end

@implementation TownEditViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

// Window is about to load.  Populate the currently selected town's details.
- (void) viewWillAppear: (BOOL) animated {
    [super viewWillAppear: animated];

    int segmentOn=0;
    
    if ([self.myTown isOffline]) {
        segmentOn = 2;
    } else if ([self.myTown isStaging]) {
        segmentOn = 1;
    }
    self.townNameTextField.text = [self.myTown name];
    self.townLocationControl.selectedSegmentIndex = segmentOn;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Commits any changes to the town, and closes the popover.
- (IBAction) doSave: (id) sender {
    BOOL hasChanges = NO;
    if (![self.townNameTextField.text isEqualToString: [self.myTown name]]) {
        [self.myTown setName: self.townNameTextField.text];
        hasChanges = YES;
    }
    
    int currentSegment = self.townLocationControl.selectedSegmentIndex;

    if (currentSegment == 2 && ![self.myTown isOffline]) {
        [self.myTown setIsOffline: YES];
        hasChanges = YES;
    } else if (currentSegment == 1 && ![self.myTown isStaging]) {
        [self.myTown setIsStaging: YES];
        hasChanges = YES;
    } else if (currentSegment == 0 && ![self.myTown isOnLayout]) {
        [self.myTown setIsOnLayout];
        hasChanges = YES;
    }

    if (hasChanges) {
        [self.myTableController layoutObjectsChanged: self];
    }
    [self.myTableController doDismissEditPopover: (id) sender];
}

@synthesize townNameTextField;
@synthesize townLocationControl;
@synthesize myNavigationBar;
@end
