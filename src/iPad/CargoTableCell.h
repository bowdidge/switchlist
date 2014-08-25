//
//  CargoTableCell.h
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

#import "FreightCar.h"

@class CargoTableViewController;

// Cell contents for cargo UITableView.
// Each cargo contains a name in the upper left, a short kind in the upper right, and a one line description
// at the bottom.  A useful icon goes to the left.
@interface CargoTableCell : UITableViewCell
// Fill in cell based on cargo object.
- (void) fillInAsCargo: (Cargo*) fc;

- (IBAction) fixedRateControlChanged: (id) sender;
// Called when the "random/fixed" switch changes..
- (IBAction) carTimeUnitChanged: (id) sender;
// Called when the "random/fixed" switch changes..
- (IBAction) unloadingTimeControlChanged: (id) sender;

// cargo displayed in this cell.
@property (nonatomic, retain) IBOutlet Cargo *cargo;
@property (nonatomic, retain) IBOutlet CargoTableViewController *myController;

// In both kinds of cells
@property (nonatomic, retain) IBOutlet UIImageView *cargoIcon;

// In short cell only.
@property (nonatomic, retain) IBOutlet UILabel *cargoNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *cargoDescription;
@property (nonatomic, retain) IBOutlet UILabel *cargoRateLabel;

// In extended cell only.
@property (nonatomic, retain) IBOutlet UITextField *cargoNameField;
@property (nonatomic, retain) IBOutlet UITextField *source;
@property (nonatomic, retain) IBOutlet UITextField *destination;
@property (nonatomic, retain) IBOutlet UITextField *carType;
@property (nonatomic, retain) IBOutlet UISegmentedControl *fixedRateControl;
@property (nonatomic, retain) IBOutlet UITextField *carRate;
@property (nonatomic, retain) IBOutlet UISegmentedControl *carTimeUnit;
@property (nonatomic, retain) IBOutlet UISegmentedControl *unloadingTimeControl;
@end
