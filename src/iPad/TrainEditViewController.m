//
//  TrainEditViewController.m
//  SwitchList
//
//  Created by Robert Bowdidge on 9/29/12.
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

#import "TrainEditViewController.h"

#import "AppDelegate.h"
#import "CarTypes.h"
#import "CurlyView.h"
#import "EntireLayout.h"
#import "ScheduledTrain.h"
#import "TrainTableViewController.h"
#import "SelectionCell.h"

// Identify what data is being shown in selection table to the right of the
// popover window.
enum {
    SelectionViewNoContents=0,
    SelectionViewCarTypes=1,
} SelectionViewContents;

@interface TrainEditViewController ()
@property (retain, nonatomic) IBOutlet UITextField *nameField;
@property (retain, nonatomic) IBOutlet UIButton *carTypesButton;
@property (retain, nonatomic) IBOutlet UITextField *maximumLengthField;

// Cached copies of layout details.
@property (retain, nonatomic) NSArray *carTypes;

@property (nonatomic) int currentSelectionMode;

@end

@implementation TrainEditViewController

// Window is about to appear for the first time.  Gather data from the layout.
- (void)viewDidLoad {
    [super viewDidLoad];
    self.popoverSizeCollapsed = 288.0;
    self.popoverSizeExpanded = 540.0;
    
    // Do any additional setup after loading the view.
    [self.rightSideSelectionTable setDataSource: self];
    [self.rightSideSelectionTable setDelegate: self];
    
    AppDelegate *myAppDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    EntireLayout *myLayout = myAppDelegate.entireLayout;
    self.carTypes = [myLayout allCarTypes];

    self.currentSelectionMode = SelectionViewNoContents;
}

// Window is about to load.  Populate the currently selected freight car's details.
- (void) viewWillAppear: (BOOL) animated {
    [super viewWillAppear: animated];
    self.nameField.text = [self.train name];
    [self.carTypesButton setTitle: [CarTypes acceptedCarTypesString: [train acceptedCarTypesRel]] forState: UIControlStateNormal];
    
    NSNumber *maximumLength = [self.train maxLength];
    if (!maximumLength) {
        self.maximumLengthField.text = @"0";
    } else {
        self.maximumLengthField.text = [NSString stringWithFormat: @"%@", maximumLength];
    }
}

// Change the train as suggested.
- (IBAction) doSave: (id) sender {
}


// Handles the user pressing the car type in order to select a different value.
- (IBAction) doPressCarTypesButton: (id) sender {
    // TODO(bowdidge) Use sender instead of explicit button.
    [self doWidenPopoverFrom: self.carTypesButton.frame];
    self.currentSelectionMode = SelectionViewCarTypes;
    self.currentArrayToShow = self.carTypes;
    self.currentTitleSelector = NULL;
    [self.rightSideSelectionTable reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) didSelectRowWithIndexPath: (NSIndexPath*) indexPath {
    
    switch (self.currentSelectionMode) {
        case SelectionViewCarTypes:
        {
            NSString *carType;
            carType = [self.carTypes objectAtIndex: [indexPath row]];
            // TODO(bowdidge): Pass actual object.
            [self.carTypesButton setTitle: carType
                                 forState: UIControlStateNormal];
            break;
        }
        default:
            break;
    }
    
}

@synthesize train;
@end
