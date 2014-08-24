//
//  IndustryTableCell.h
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

@class InduYard;
@class Industry;
@class IndustryTableViewController;

@interface IndustryTableCell : UITableViewCell {
}

// Fill in cell based on cargo object.
- (void) fillInAsIndustry: (Industry*) industry;
// Fill in the cell as the "Add..." cell at the bottom of the table.
- (void) fillInAsAddCell;

// Called when the "spot at specific doors" switch changes state.
- (IBAction) doorSwitchChanged: (id) sender;

// Industry represented by this cell.
@property (nonatomic, retain) Industry  *myIndustry;

// Information in all cells
@property (nonatomic, retain) IBOutlet UITextField *industryName;
@property (nonatomic, retain) IBOutlet UITextField *industryLocation;
@property (nonatomic, retain) IBOutlet UILabel *sidingLengthLabel;
@property (nonatomic, retain) IBOutlet UIImageView *industryIcon;

// Information only in short row.
@property (nonatomic, retain) IBOutlet UILabel *industryDescription;

// Information in detailed row.
@property (nonatomic, retain) IBOutlet UITextField *townName;
@property (nonatomic, retain) IBOutlet UITextField *divisionName;
@property (nonatomic, retain) IBOutlet UISegmentedControl *hasDoorsControl;
@property (nonatomic, retain) IBOutlet UITextField *numberOfDoorsField;
@property (nonatomic, retain) IBOutlet UITextField *cargos;
@property (nonatomic, retain) IBOutlet UITextField *sidingLength;
@property (nonatomic, retain) IBOutlet UIButton *cargoHelpButton;

// Reference back to the controller processing changes to the cells.
@property (nonatomic, retain) IBOutlet IndustryTableViewController *myController;

@end
