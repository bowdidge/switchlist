//
//  FreightCarTableCell.h
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

#import <UIKit/UIKit.h>

#import "FreightCarTableViewController.h"

@class FreightCar;

// Cell contents for freight car UITableView.
// Each freight car cell contains reporting marks in the upper left,
// a short kind in the upper right, and a one line description
// at the bottom.  A useful icon goes to the left.
@interface FreightCarTableCell : UITableViewCell

// Fills in all values for the cell based on the freight car object.
- (void) fillInAsFreightCar: (FreightCar*) freightCar;
// Fills in cell for the Add item.
- (void) fillInAsAddCell;

// Current freight car represented by this cell.
@property (nonatomic, retain) IBOutlet FreightCar *freightCar;

// UITextField showing the freight car's reporting marks.
// We use a UITextField so we can edit the label directly and get
// events when selected.
@property (nonatomic, retain) IBOutlet UITextField *freightCarReportingMarks;

// UITextField showing the location of the freight car.
@property (nonatomic, retain) IBOutlet UITextField *freightCarLocation;

// UITextField showing the kind of freight car.
@property (nonatomic, retain) IBOutlet UITextField *freightCarKind;

// text describing the freight car.
@property (nonatomic, retain) IBOutlet UILabel *freightCarDescription;

// Cute icon to the left of each table cell.
@property (nonatomic, retain) IBOutlet UIImageView *freightCarIcon;

// Reference back to the controller processing changes to the cells.
@property (nonatomic, retain) IBOutlet FreightCarTableViewController *myController;
@end
