//
//  FreightCarEditController.m
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

#import "FreightCarEditController.h"

#import "AppDelegate.h"
#import "CarType.h"
#import "EntireLayout.h"
#import "FreightCar.h"
#import "FreightCarTableViewController.h"
#import "SelectionCell.h"

// Identify what data is being shown in selection table to the right of the
// popover window.
enum {
    SelectionViewNoContents=0,
    SelectionViewCarType=1,
    SelectionViewLocation=2,
    SelectionViewCurrentCargo=3,
    SelectionViewDivision=4
} SelectionViewContents;

@interface FreightCarEditController ()
@property (retain, nonatomic) IBOutlet UITextField *reportingMarksField;
@property (retain, nonatomic) IBOutlet UIButton *carTypeButton;
@property (retain, nonatomic) IBOutlet UIButton *currentCargoButton;
@property (retain, nonatomic) IBOutlet UITextField *homeDivisionField;
@property (retain, nonatomic) IBOutlet UIButton *currentLocationButton;
@property (retain, nonatomic) IBOutlet UIButton *cameraButton;
@property (retain, nonatomic) IBOutlet UIImageView *carPhotoView;
@property (retain, nonatomic) IBOutlet UISegmentedControl *loadedToggle;
@property (retain, nonatomic) IBOutlet UITableView *selectionTable;

// Cached copies of layout details.
@property (retain, nonatomic) NSArray *carTypes;
@property (retain, nonatomic) NSArray *locations;
@property (retain, nonatomic) NSArray *cargos;

@property (nonatomic) int currentSelectionMode;
@end

@implementation FreightCarEditController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.selectionTable setDataSource: self];
    [self.selectionTable setDelegate: self];
    
    AppDelegate *myAppDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    EntireLayout *myLayout = myAppDelegate.entireLayout;
    self.carTypes = [myLayout allCarTypes];
    // TODO(bowdidge): Yards.
    self.locations = [myLayout allIndustries];
    self.cargos = [myLayout allCargos];
    self.currentSelectionMode = SelectionViewNoContents;
}

// Returns an appropriate image for the provided freight car.
- (UIImage*) imageForFreightCar: (FreightCar*) fc {
    NSString *carType = [[fc carTypeRel] carTypeName];
    NSString *imagePath = nil;
    if ([carType isEqualToString: @"T"]) {
        imagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: @"T.jpg"];
    } else if ([carType isEqualToString: @"FM"]  || [carType isEqualToString: @"F"]) {
        imagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: @"F.jpg"];
    } else if ([carType isEqualToString: @"RS"]) {
        imagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: @"RS.jpg"];
    } else if ([carType isEqualToString: @"XM"] || [carType isEqualToString: @"XMC"]) {
        imagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: @"XM.jpg"];
    } else {
        imagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: @"freightCar.jpg"];
    }
    return [UIImage imageWithContentsOfFile: imagePath];
}

- (void) viewWillAppear: (BOOL) animated {
    [super viewWillAppear: animated];
    self.reportingMarksField.text = [self.freightCar reportingMarks];
    [self.carTypeButton setTitle: [[self.freightCar carTypeRel] carTypeName] forState: UIControlStateNormal];
    [self.currentCargoButton setTitle: [[self.freightCar cargo] name] forState: UIControlStateNormal];
    self.homeDivisionField.text = [self.freightCar homeDivision];
    [self.currentLocationButton setTitle: [[self.freightCar currentLocation] name] forState: UIControlStateNormal];;
    [self.loadedToggle setEnabled: YES forSegmentAtIndex: [freightCar isLoaded] ? 0 : 1];

    self.carPhotoView.image = [self imageForFreightCar: self.freightCar];
}

- (void) viewWillDisappear: (BOOL) animated {
    BOOL hasChanges = NO;
    if ([self.reportingMarksField.text isEqualToString: [self.freightCar reportingMarks]]) {
        [self.freightCar setReportingMarks: self.reportingMarksField.text];
        hasChanges = 1;
    }
    // TODO(bowdidge): Should dispose of rest of cached layout data each time view changes.
    
    self.carPhotoView.image = nil;
    [super viewWillDisappear: animated];
    if (hasChanges) {
        [self.myTabController freightCarsChanged: self];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// User wants to take a picture of the freight car.
- (IBAction) doPressCameraButton: (id) sender {
}

// Widens the popover to a larger width that displays the right-hand-side table.
// TODO(bowdidge): Scroll up so that the table doesn't get cut off by the keyboard.
- (void) doWidenPopover {
    CGRect currentFrame = self.view.frame;
    // Stock size is 288x342, widen to 540x342 to show list.
    currentFrame.size.width = 540;
    self.view.frame = currentFrame;
    self.selectionTable.hidden = NO;
    [self.myPopoverController setPopoverContentSize: currentFrame.size animated: YES]; 
}

// Handles the user pressing the car type in order to select a different value.
- (IBAction) doPressCarTypeButton: (id) sender {
    [self doWidenPopover];
    self.currentSelectionMode = SelectionViewCarType;
    [self.selectionTable reloadData];
}

// Handles the user pressing the cargo button in order to select a different value.
- (IBAction) doPressCargoButton: (id) sender {
    [self doWidenPopover];
    self.currentSelectionMode = SelectionViewCurrentCargo;
    [self.selectionTable reloadData];    
}

// Handles the user pressing the location button to select a different current location
// for the freight car.
- (IBAction) doPressLocationButton: (id) sender {
    [self doWidenPopover];
    self.currentSelectionMode = SelectionViewLocation;
    [self.selectionTable reloadData];
    
}

// Handles the user pressing an item in the right-hand-side table.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"%d selected", [indexPath row]);
    // Selection table selected.
    CGRect currentFrame = self.view.frame;
    // Stock size is 288x342, widen to 540x342 to show list, back to 288 after.
    // TODO(bowdidge): Doesn't redraw correctly.
    // Why required to be so much bigger?
    currentFrame.size.width = 288;
    [self.myPopoverController setPopoverContentSize: currentFrame.size animated: YES];
}

// Returns the number of sections in the selection table on the right hand side of the popover.
// This is always 1.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Three sections: on layout, on workbench, and empty/add.
    return 1;
}

// Returns the section title for the selection table.
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
   return @"";
}

// Returns the number of rows in the selection table to the right hand side of
// the popover.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (self.currentSelectionMode) {
        case SelectionViewCarType:
            return self.carTypes.count;
        case SelectionViewLocation:
            return self.locations.count;
        case SelectionViewCurrentCargo:
            return self.cargos.count;
        case SelectionViewDivision:
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
    }
    
    CarType *carType = nil;
    InduYard *location = nil;
    Cargo *cargo = nil;
    switch (self.currentSelectionMode) {
        case SelectionViewCarType:
            carType = [self.carTypes objectAtIndex: [indexPath row]];
            cell.cellText.text = [NSString stringWithFormat: @"%@ (%@)", carType.carTypeName, carType.carTypeDescription];
            break;
        case SelectionViewLocation:
            location = [self.locations objectAtIndex: [indexPath row]];
            cell.cellText.text = [location name];
            break;
        case SelectionViewCurrentCargo:
            // TODO(bowdidge): Deserves two lines.
            cargo = [self.cargos objectAtIndex: [indexPath row]];
            cell.cellText.text = [cargo description];
            break;
        default:
            cell.cellText.text = @"";
            break;
    }
    return cell;
}

@synthesize freightCar;
@synthesize currentSelectionMode;
@end
