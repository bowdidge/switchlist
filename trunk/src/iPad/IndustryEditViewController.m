//
//  IndustryEditViewController.m
//  SwitchList
//
//  Created by Robert Bowdidge on 9/22/12.
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
 

#import "IndustryEditViewController.h"

#import "AppDelegate.h"
#import "CurlyView.h"
#import "EntireLayout.h"
#import "Industry.h"
#import "IndustryTableViewController.h"
#import "SelectionCell.h"

// Identify what data is being shown in selection table to the right of the
// popover window.
enum {
    SelectionViewNoContents=0,
    SelectionViewLocation=1,
    SelectionViewDivision=2
} SelectionViewContents;

@interface IndustryEditViewController ()
@property (retain, nonatomic) IBOutlet UITextField *nameField;
@property (retain, nonatomic) IBOutlet UIButton *townLocationButton;
@property (retain, nonatomic) IBOutlet UIButton *currentCargoButton;
@property (retain, nonatomic) IBOutlet UIButton *divisionButton;
@property (retain, nonatomic) IBOutlet UISegmentedControl *hasDoorsToggle;
@property (retain, nonatomic) IBOutlet UITextField *numberOfDoorsField;
@property (retain, nonatomic) IBOutlet UITextField *sidingLengthField;

// Cached copies of layout details.
@property (retain, nonatomic) NSArray *towns;
@property (retain, nonatomic) NSArray *divisions;

@property (nonatomic) int currentSelectionMode;

@end

@implementation IndustryEditViewController

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
    self.towns = [myLayout allStationsSortedOrder];
    // TODO(bowdidge): Populate this list from freight cars and industries.
    self.divisions = [NSArray arrayWithObjects: @"Here", @"SP", @"WP", @"East", @"Midwest", nil];
    
    self.currentSelectionMode = SelectionViewNoContents;
}

// Window is about to load.  Populate the currently selected freight car's details.
- (void) viewWillAppear: (BOOL) animated {
    [super viewWillAppear: animated];
}

- (void) setIndustry: (Industry*) theIndustry {
    [industry release];
    industry = [theIndustry retain];
    self.nameField.text = [self.industry name];
    [self.divisionButton setTitle: [self.industry division] forState: UIControlStateNormal];
    [self.townLocationButton setTitle: [[self.industry location] name] forState: UIControlStateNormal];;
    int litSegment = [self.industry hasDoors] ? 0 : 1;
    [self.hasDoorsToggle setSelectedSegmentIndex: litSegment];
    
    // TODO(bowdidge): Gray out field when disabled.
    // [self.numberOfDoorsField setEnabled: [self.myIndustry hasDoors] ? YES : NO];

    if (litSegment == 1) {
        NSNumber *numberOfDoors = [self.industry numberOfDoors];
        if (!numberOfDoors) {
            self.numberOfDoorsField.text = @"0";
        } else {
            self.numberOfDoorsField.text = [NSString stringWithFormat: @"%@", numberOfDoors];
        }
    }

    NSNumber *sidingLength = [self.industry sidingLength];
    if (!sidingLength) {
        self.sidingLengthField.text = @"0";
    } else {
        self.sidingLengthField.text = [NSString stringWithFormat: @"%@", sidingLength];
    }
}

// Change the freight car as suggested.
- (IBAction) doSave: (id) sender {
    AppDelegate *myAppDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    EntireLayout *myLayout = myAppDelegate.entireLayout;

    [self.industry setName: self.nameField.text];
    [self.industry setDivision: self.divisionButton.titleLabel.text];
    [self.industry setLocation: [myLayout stationWithName: self.townLocationButton.titleLabel.text]];
    NSInteger currentSegment = self.hasDoorsToggle.selectedSegmentIndex;
    [self.industry setHasDoors: (currentSegment == 0) ? YES : NO];

    [self.industry setNumberOfDoors: [NSNumber numberWithInt: [self.numberOfDoorsField.text intValue]]];
    [self.industry setSidingLength: [NSNumber numberWithInt: [self.sidingLengthField.text intValue]]];

    [self.myTableController layoutObjectsChanged: self];
    [self.myTableController doDismissEditPopover: self];
}


// Handles the user pressing the car type in order to select a different value.
- (IBAction) doPressDivisionButton: (id) sender {
    // TODO(bowdidge) Use sender instead of explicit button.
    [self doWidenPopoverFrom: self.divisionButton.frame];
    self.currentSelectionMode = SelectionViewDivision;
    self.currentArrayToShow = self.divisions;
    self.currentTitleSelector = NULL;
    [self.rightSideSelectionTable reloadData];
}

// Handles the user pressing the cargo button in order to select a different value.
- (IBAction) doPressTownLocationButton: (id) sender {
    [self doWidenPopoverFrom: self.townLocationButton.frame];
    self.currentSelectionMode = SelectionViewLocation;
    self.currentArrayToShow = self.towns;
    self.currentTitleSelector = @selector(name);
    [self.rightSideSelectionTable reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) didSelectRowWithIndexPath: (NSIndexPath*) indexPath {
    
    switch (self.currentSelectionMode) {
        case SelectionViewLocation:
        {
            Place *selectedLocation;
            selectedLocation = [self.towns objectAtIndex: [indexPath row]];
            // TODO(bowdidge): Pass actual object.
            [self.townLocationButton setTitle: [selectedLocation name]
                                     forState: UIControlStateNormal];
            break;
        }
        case SelectionViewDivision:
        {
            NSString *currentDivision;
            currentDivision = [self.divisions objectAtIndex: [indexPath row]];
            // TODO(bowdidge): Pass actual object.
            [self.divisionButton setTitle: currentDivision
                                 forState: UIControlStateNormal];
            break;
        }
        default:
            break;
    }
 
}

@synthesize industry;
@end
