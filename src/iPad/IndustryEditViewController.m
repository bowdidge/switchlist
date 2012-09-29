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
    self.nameField.text = [self.myIndustry name];
    [self.divisionButton setTitle: [self.myIndustry division] forState: UIControlStateNormal];
    [self.townLocationButton setTitle: [[self.myIndustry location] name] forState: UIControlStateNormal];;
    int litSegment = [self.myIndustry hasDoors] ? 0 : 1;
    [self.hasDoorsToggle setSelectedSegmentIndex: litSegment];
    
    // TODO(bowdidge): Gray out field when disabled.
    // [self.numberOfDoorsField setEnabled: [self.myIndustry hasDoors] ? YES : NO];

    if (litSegment == 1) {
        NSNumber *numberOfDoors = [self.myIndustry numberOfDoors];
        if (!numberOfDoors) {
            self.numberOfDoorsField.text = @"0";
        } else {
            self.numberOfDoorsField.text = [NSString stringWithFormat: @"%@", numberOfDoors];
        }
    }

    NSNumber *sidingLength = [self.myIndustry sidingLength];
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

    [self.myIndustry setName: self.nameField.text];
    [self.myIndustry setDivision: self.divisionButton.titleLabel.text];
    [self.myIndustry setLocation: [myLayout stationWithName: self.townLocationButton.titleLabel.text]];
    int currentSegment = self.hasDoorsToggle.selectedSegmentIndex;
    [self.myIndustry setHasDoors: (currentSegment == 0) ? YES : NO];

    [self.myIndustry setNumberOfDoors: [NSNumber numberWithInt: [self.numberOfDoorsField.text intValue]]];
    [self.myIndustry setSidingLength: [NSNumber numberWithInt: [self.sidingLengthField.text intValue]]];

    [self.myTableController layoutObjectsChanged: self];
    [self.myTableController doDismissEditPopover: self];
}


// Handles the user pressing the car type in order to select a different value.
- (IBAction) doPressDivisionButton: (id) sender {
    // TODO(bowdidge) Use sender instead of explicit button.
    [self doWidenPopoverFrom: self.divisionButton.frame];
    self.currentSelectionMode = SelectionViewDivision;
    [self.rightSideSelectionTable reloadData];
}

// Handles the user pressing the cargo button in order to select a different value.
- (IBAction) doPressTownLocationButton: (id) sender {
    [self doWidenPopoverFrom: self.townLocationButton.frame];
    self.currentSelectionMode = SelectionViewLocation;
    [self.rightSideSelectionTable reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Handles the user pressing an item in the right-hand-side selection table.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self doNarrowPopoverFrame];
    
    // Selected item.
    Place *selectedLocation;
    NSString *currentDivision;
    switch (self.currentSelectionMode) {
        case SelectionViewLocation:
            selectedLocation = [self.towns objectAtIndex: [indexPath row]];
            // TODO(bowdidge): Pass actual object.
            [self.townLocationButton setTitle: [selectedLocation name]
                                        forState: UIControlStateNormal];
            break;
        case SelectionViewDivision:
            currentDivision = [self.divisions objectAtIndex: [indexPath row]];
            // TODO(bowdidge): Pass actual object.
            [self.divisionButton setTitle: currentDivision
                                     forState: UIControlStateNormal];
            break;
        default:
            break;
    }
    
}

// Returns the number of sections in the selection table on the right hand side of the popover.
// This is always 1 - there are no divisions in the selection table.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Three sections: on layout, on workbench, and empty/add.
    return 1;
}

// Returns the number of rows in the selection table to the right hand side of
// the popover.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (self.currentSelectionMode) {
        case SelectionViewLocation:
            return self.towns.count;
        case SelectionViewDivision:
            return self.divisions.count;
        default:
            return 0;
    }
    return 0;
}

// Creates each cell for the selection table.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"selectionCell";
    
    SelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SelectionCell alloc] initWithStyle:UITableViewCellStyleDefault
                                    reuseIdentifier:CellIdentifier];
        [cell autorelease];
    }
    
    switch (self.currentSelectionMode) {
        case SelectionViewLocation:
            cell.cellText.text = [[self.towns objectAtIndex: [indexPath row]] name];
            break;
        case SelectionViewDivision:
            cell.cellText.text = [self.divisions objectAtIndex: [indexPath row]];
            break;
        default:
            cell.cellText.text = @"";
            break;
    }
    return cell;
}

@synthesize myIndustry;
@end
