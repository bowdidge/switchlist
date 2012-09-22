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
#import "Cargo.h"
#import "CarType.h"
#import "CurlyView.h"
#import "EntireLayout.h"
#import "FreightCar.h"
#import "FreightCarTableViewController.h"
#import "Industry.h"
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
// Buttons and controls in the user interface.
@property (retain, nonatomic) IBOutlet UITextField *reportingMarksField;
@property (retain, nonatomic) IBOutlet UIButton *carTypeButton;
@property (retain, nonatomic) IBOutlet UIButton *currentCargoButton;
@property (retain, nonatomic) IBOutlet UIButton *homeDivisionButton;
@property (retain, nonatomic) IBOutlet UIButton *currentLocationButton;
// Button (eventually) for taking a picture of a freight car.
@property (retain, nonatomic) IBOutlet UIButton *cameraButton;
@property (retain, nonatomic) IBOutlet UIImageView *carPhotoView;
@property (retain, nonatomic) IBOutlet UISegmentedControl *loadedToggle;
@property (retain, nonatomic) IBOutlet UITableView *rightSideSelectionTable;

// Cached copies of layout details.
@property (retain, nonatomic) NSArray *carTypes;
@property (retain, nonatomic) NSArray *locations;
@property (retain, nonatomic) NSArray *cargos;
@property (retain, nonatomic) NSArray *divisions;

@property (nonatomic) int currentSelectionMode;

@property (nonatomic, retain) IBOutlet CurlyView *curlyView;
@end

@implementation FreightCarEditController

// Window is about to appear for the first time.  Gather data from the layout.
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.rightSideSelectionTable setDataSource: self];
    [self.rightSideSelectionTable setDelegate: self];
    
    AppDelegate *myAppDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    EntireLayout *myLayout = myAppDelegate.entireLayout;
    self.carTypes = [myLayout allCarTypes];
    // TODO(bowdidge): Add yards.
    self.locations = [myLayout allIndustries];
    self.cargos = [myLayout allCargos];
    
    // TODO(bowdidge): Populate this list from freight cars and industries.
    self.divisions = [NSArray arrayWithObjects: @"Here", @"SP", @"WP", @"East", @"Midwest", nil];
    
    self.currentSelectionMode = SelectionViewNoContents;
}

// Returns an appropriate image for the provided freight car.
// TODO(bowdidge): Figure out how to efficiently store the actual photos of the cars.
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

// Window is about to load.  Populate the currently selected freight car's details.
- (void) viewWillAppear: (BOOL) animated {
    [super viewWillAppear: animated];
    self.reportingMarksField.text = [self.freightCar reportingMarks];
    [self.carTypeButton setTitle: [[self.freightCar carTypeRel] carTypeName] forState: UIControlStateNormal];
    [self.currentCargoButton setTitle: [[self.freightCar cargo] name] forState: UIControlStateNormal];
    [self.homeDivisionButton setTitle: [self.freightCar homeDivision] forState: UIControlStateNormal];
    [self.currentLocationButton setTitle: [[self.freightCar currentLocation] name] forState: UIControlStateNormal];;
    [self.loadedToggle setEnabled: YES forSegmentAtIndex: [freightCar isLoaded] ? 0 : 1];

    self.carPhotoView.image = [self imageForFreightCar: self.freightCar];
}

// Window is about to be closed.  Save out the changes to the current freight car.
// TODO(bowdidge): Should have explicit save button so possible to cancel without editing.
- (void) viewWillDisappear: (BOOL) animated {
    AppDelegate *myAppDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    EntireLayout *myLayout = myAppDelegate.entireLayout;

    BOOL hasChanges = NO;
    if (![self.reportingMarksField.text isEqualToString: [self.freightCar reportingMarks]]) {
        [self.freightCar setReportingMarks: [self.reportingMarksField.text uppercaseString]];
        hasChanges = YES;
    }
    
    if ([self.homeDivisionButton.titleLabel.text isEqualToString: [self.freightCar homeDivision]] != NSOrderedSame) {
        [self.freightCar setHomeDivision: self.homeDivisionButton.titleLabel.text];
        hasChanges = YES;
    }
    
    if (![self.carTypeButton.titleLabel.text isEqualToString: [[[self freightCar] carTypeRel] carTypeName]]) {
        for (CarType *ct in self.carTypes) {
            if ([[ct carTypeName] isEqualToString: self.carTypeButton.titleLabel.text]) {
                [[self freightCar] setCarTypeRel: ct];
                hasChanges = YES;
                break;
            }
        }
    }
    
    if (![self.currentLocationButton.titleLabel.text isEqualToString: [[[self freightCar] currentLocation] name]]) {
        for (InduYard *induYard in self.locations) {
            if ([[induYard name] isEqualToString: self.currentLocationButton.titleLabel.text]) {
                [[self freightCar] setCurrentLocation: induYard];
                hasChanges = YES;
                break;
            }
        }
    }
    // Location not set?  Put at workbench.
    if (![[self freightCar] currentLocation]) {
        [[self freightCar] setCurrentLocation: [myLayout workbenchIndustry]];
    }

    if (![self.currentCargoButton.titleLabel.text isEqualToString: [[[self freightCar] cargo] name]]) {
        for (Cargo *cargo in self.cargos) {
            if ([[cargo name] isEqualToString: self.currentCargoButton.titleLabel.text]) {
                [[self freightCar] setCargo: cargo];
                hasChanges = YES;
                break;
            }
        }
    }
    
    self.carPhotoView.image = nil;
    [super viewWillDisappear: animated];
    if (hasChanges) {
        [self.myTableController freightCarsChanged: self];
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
// Also sets up curves between the button requesting the information and the table
// to hint what's being selected.
// TODO(bowdidge): Better done with just some light highlighting under the button?
- (void) doWidenPopoverFrom: (CGRect) leftSideRect {
    
    CGRect currentFrame = self.view.frame;
    self.curlyView.leftRegion = leftSideRect;
    self.curlyView.rightRegion = self.rightSideSelectionTable.frame;
    [self.curlyView setNeedsDisplay];

    // Stock size is 288x342, widen to 540x342 to show list.
    currentFrame.size.width = 540;
    self.view.frame = currentFrame;
    self.rightSideSelectionTable.hidden = NO;
    [self.myPopoverController setPopoverContentSize: currentFrame.size animated: YES]; 
}

// Handles the user pressing the car type in order to select a different value.
- (IBAction) doPressCarTypeButton: (id) sender {
    [self doWidenPopoverFrom: self.carTypeButton.frame];
    self.currentSelectionMode = SelectionViewCarType;
    [self.rightSideSelectionTable reloadData];
}

// Handles the user pressing the cargo button in order to select a different value.
- (IBAction) doPressCargoButton: (id) sender {
    [self doWidenPopoverFrom: self.currentCargoButton.frame];
    self.currentSelectionMode = SelectionViewCurrentCargo;
    [self.rightSideSelectionTable reloadData];    
}

// Handles the user pressing the location button to select a different current location
// for the freight car.
- (IBAction) doPressLocationButton: (id) sender {
    [self doWidenPopoverFrom: self.currentLocationButton.frame];
    self.currentSelectionMode = SelectionViewLocation;
    [self.rightSideSelectionTable reloadData];
    
}

// Handles the user pressing the division button to select a different home division
// for the freight car.
- (IBAction) doPressDivisionButton: (id) sender {
    [self doWidenPopoverFrom: self.homeDivisionButton.frame];
    self.currentSelectionMode = SelectionViewDivision;
    [self.rightSideSelectionTable reloadData];
    
}

// Handles the user pressing an item in the right-hand-side selection table.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Selection table selected.
    CGRect currentFrame = self.view.frame;
    // Stock size is 288x342, widen to 540x342 to show list, back to 288 after.
    currentFrame.size.width = 288;
    [self.myPopoverController setPopoverContentSize: currentFrame.size animated: YES];
    
    // Selected item.
    CarType *selectedCarType;
    InduYard *currentLocation;
    Cargo *currentCargo;
    NSString *currentDivision;
    switch (self.currentSelectionMode) {
        case SelectionViewCarType:
            selectedCarType = [self.carTypes objectAtIndex: [indexPath row]];
            [self.carTypeButton setTitle: [selectedCarType carTypeName]
                                forState: UIControlStateNormal];
            break;
        case SelectionViewLocation:
            currentLocation = [self.locations objectAtIndex: [indexPath row]];
            // TODO(bowdidge): Pass actual object.
            [self.currentLocationButton setTitle: [currentLocation name]
                                        forState: UIControlStateNormal];
            break;
        case SelectionViewCurrentCargo:
            currentCargo = [self.cargos objectAtIndex: [indexPath row]];
            // TODO(bowdidge): Pass actual object.
            [self.currentCargoButton setTitle: [currentCargo name]
                                     forState: UIControlStateNormal];
            break;
        case SelectionViewDivision:
            currentDivision = [self.divisions objectAtIndex: [indexPath row]];
            // TODO(bowdidge): Pass actual object.
            [self.homeDivisionButton setTitle: currentDivision
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
    }
    
    CarType *carType = nil;
    InduYard *location = nil;
    Cargo *cargo = nil;
    switch (self.currentSelectionMode) {
        case SelectionViewCarType:
            carType = [self.carTypes objectAtIndex: [indexPath row]];
            // Shorter form of description that has a better chance of fitting.
            cell.cellText.text = [NSString stringWithFormat: @"%@ (%@)", carType.carTypeName, carType.carTypeDescription];
            break;
        case SelectionViewLocation:
            location = [self.locations objectAtIndex: [indexPath row]];
            cell.cellText.text = [location name];
            break;
        case SelectionViewCurrentCargo:
            // TODO(bowdidge): Deserves two lines.
            cargo = [self.cargos objectAtIndex: [indexPath row]];
            // Shorter form of description that has a better chance of fitting.
            cell.cellText.text = [NSString stringWithFormat: @"%@ (%@->%@)",
                                  [cargo name], [[cargo source] name], [[cargo destination] name]];
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

@synthesize freightCar;
@synthesize currentSelectionMode;
@end
