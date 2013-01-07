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

// Cached copies of layout details.
@property (retain, nonatomic) NSArray *carTypes;
@property (retain, nonatomic) NSArray *locations;
@property (retain, nonatomic) NSArray *cargos;
@property (retain, nonatomic) NSArray *divisions;

@property (nonatomic) int currentSelectionMode;

@end

@implementation FreightCarEditController

// Window is about to appear for the first time.  Gather data from the layout.
- (void)viewDidLoad {
    [super viewDidLoad];
    self.popoverSizeCollapsed = 288.0;
    self.popoverSizeExpanded = 540.0;
    
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

// Window is about to load.
- (void) viewWillAppear: (BOOL) animated {
    [super viewWillAppear: animated];
}

- (void) setFreightCar: (FreightCar*) fc {
    [freightCar release];
    freightCar = [fc retain];
    self.reportingMarksField.text = [self.freightCar reportingMarks];
    [self.carTypeButton setTitle: [[self.freightCar carTypeRel] carTypeName] forState: UIControlStateNormal];
    [self.currentCargoButton setTitle: [[self.freightCar cargo] name] forState: UIControlStateNormal];
    [self.homeDivisionButton setTitle: [self.freightCar homeDivision] forState: UIControlStateNormal];
    [self.currentLocationButton setTitle: [[self.freightCar currentLocation] name] forState: UIControlStateNormal];;
    [self.loadedToggle setSelectedSegmentIndex: [freightCar isLoaded] ? 0 : 1];

    self.carPhotoView.image = [self imageForFreightCar: self.freightCar];
}

// Change the freight car as suggested.
- (IBAction) doSave: (id) sender {
    AppDelegate *myAppDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    EntireLayout *myLayout = myAppDelegate.entireLayout;

    [self.freightCar setReportingMarks: [self.reportingMarksField.text uppercaseString]];
    [self.freightCar setHomeDivision: self.homeDivisionButton.titleLabel.text];
    for (CarType *ct in self.carTypes) {
        if ([[ct carTypeName] isEqualToString: self.carTypeButton.titleLabel.text]) {
            [[self freightCar] setCarTypeRel: ct];
            break;
        }
    }
    
    for (InduYard *induYard in self.locations) {
        if ([[induYard name] isEqualToString: self.currentLocationButton.titleLabel.text]) {
            [[self freightCar] setCurrentLocation: induYard];
            break;
        }
    }

    // Location not set?  Put at workbench.
    if (![[self freightCar] currentLocation]) {
        [[self freightCar] setCurrentLocation: [myLayout workbenchIndustry]];
    }

    for (Cargo *cargo in self.cargos) {
        if ([[cargo name] isEqualToString: self.currentCargoButton.titleLabel.text]) {
            [[self freightCar] setCargo: cargo];
            break;
        }
    }
    
    self.carPhotoView.image = nil;
    [self.myTableController layoutObjectsChanged: self];
    [self.myTableController doDismissEditPopover: self];
}

// Window is about to be closed.  Save out the changes to the current freight car.
// TODO(bowdidge): Should have explicit save button so possible to cancel without editing.
- (void) viewWillDisappear: (BOOL) animated {
    [super viewWillDisappear: animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// User wants to take a picture of the freight car.
- (IBAction) doPressCameraButton: (id) sender {
}

// Handles the user pressing the car type in order to select a different value.
- (IBAction) doPressCarTypeButton: (id) sender {
    [self doWidenPopoverFrom: self.carTypeButton.frame];
    self.currentSelectionMode = SelectionViewCarType;
    self.currentArrayToShow = self.carTypes;
    self.currentTitleSelector = @selector(carTypeName);
    [self.rightSideSelectionTable reloadData];
}

// Handles the user pressing the cargo button in order to select a different value.
- (IBAction) doPressCargoButton: (id) sender {
    [self doWidenPopoverFrom: self.currentCargoButton.frame];
    self.currentSelectionMode = SelectionViewCurrentCargo;
    self.currentArrayToShow = self.cargos;
    self.currentTitleSelector = @selector(name);
    [self.rightSideSelectionTable reloadData];
}

// Handles the user pressing the location button to select a different current location
// for the freight car.
- (IBAction) doPressLocationButton: (id) sender {
    [self doWidenPopoverFrom: self.currentLocationButton.frame];
    self.currentSelectionMode = SelectionViewLocation;
    self.currentArrayToShow = self.locations;
    self.currentTitleSelector = @selector(name);
    [self.rightSideSelectionTable reloadData];
    
}

// Handles the user pressing the division button to select a different home division
// for the freight car.
- (IBAction) doPressDivisionButton: (id) sender {
    [self doWidenPopoverFrom: self.homeDivisionButton.frame];
    self.currentSelectionMode = SelectionViewDivision;
    self.currentArrayToShow = self.divisions;
    self.currentTitleSelector = NULL;
   [self.rightSideSelectionTable reloadData];
    
}

// Handles the user pressing an item in the right-hand-side selection table.
- (void)didSelectRowWithIndexPath: (NSIndexPath *)indexPath {
    switch (self.currentSelectionMode) {
        case SelectionViewCarType:
        {
            CarType *selectedCarType;
            selectedCarType = [self.carTypes objectAtIndex: [indexPath row]];
            [self.carTypeButton setTitle: [selectedCarType carTypeName]
                                forState: UIControlStateNormal];
            break;
        }
        case SelectionViewLocation:
        {
            InduYard *currentLocation;
            currentLocation = [self.locations objectAtIndex: [indexPath row]];
            // TODO(bowdidge): Pass actual object.
            [self.currentLocationButton setTitle: [currentLocation name]
                                        forState: UIControlStateNormal];
            break;
        }
        case SelectionViewCurrentCargo:
        {
            Cargo *currentCargo;
            currentCargo = [self.cargos objectAtIndex: [indexPath row]];
            // TODO(bowdidge): Pass actual object.
            [self.currentCargoButton setTitle: [currentCargo name]
                                     forState: UIControlStateNormal];
            break;
        }
        case SelectionViewDivision:
        {
            NSString *currentDivision;
            currentDivision = [self.divisions objectAtIndex: [indexPath row]];
            // TODO(bowdidge): Pass actual object.
            [self.homeDivisionButton setTitle: currentDivision
                                     forState: UIControlStateNormal];
            break;
        }
        default:
            break;
    }
    
}

@synthesize freightCar;
@synthesize currentSelectionMode;
@end
