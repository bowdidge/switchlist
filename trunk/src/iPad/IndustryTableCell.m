//
//  IndustryTableCell.m
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

#import "IndustryTableCell.h"

#import "Cargo.h"
#import "Industry.h"
#import "IndustryTableViewController.h"

@implementation IndustryTableCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (NSString*) cargoDescriptionForIndustry: (Industry*) i {
    NSMutableString *description = [NSMutableString string];
    NSSet *outCargos = [i originatingCargos];
    NSSet *inCargos = [i terminatingCargos];
    if ([outCargos count] != 0) {
        [description appendFormat: @"Receives %@. ", [[outCargos anyObject] cargoDescription]];
    }
    if ([inCargos count] != 0) {
        [description appendFormat: @"Ships %@. ", [[inCargos anyObject] cargoDescription]];
    }
    if ([outCargos count] == 0 && [inCargos count] == 0) {
        [description appendFormat: @"No cargos arriving or leaving. "];
    }
    return description;
}

// Creates description string for industry cell.
// Form is "Receives x, y, sends z.  Doors for spotting."
// TODO(bowdidge): List only common cargos so list doesn't become too large.
- (NSString*) descriptionForIndustry: (Industry*) i {
    // Receives x,y, sends z.  Doors for spotting."
    NSMutableString *description = [NSMutableString string];
    [description appendString: [self cargoDescriptionForIndustry: i]];
    if ([i hasDoors]) {
        [description appendString: @"Spot at specific doors."];
    }
    return description;
}

// Fill in cell based on cargo object.
- (void) fillInAsIndustry: (Industry*) industry {
    self.myIndustry = industry;
    self.industryNameLabel.text = [industry name];
    self.industryNameField.text = [industry name];
    self.sidingLengthLabel.text = [NSString stringWithFormat: @"%d foot siding", [[industry sidingLength] intValue]];
    self.industryDescription.text = [self descriptionForIndustry: industry];

    self.townNameLabel.text = [[industry location] name];
    self.townNameField.text = [[industry location] name];
    self.divisionName.text = [industry division];
    self.sidingLength.text = [NSString stringWithFormat: @"%d", [[industry sidingLength] intValue]];
    [self.hasDoorsControl setSelectedSegmentIndex: [industry hasDoors] ? 0 : 1];
    if (industry.hasDoors) {
        self.numberOfDoorsField.text = [NSString stringWithFormat: @"%d", (int) [[industry numberOfDoors] intValue]];
    } else {
        self.numberOfDoorsField.text = @"";
    }
    self.cargos.text = [self cargoDescriptionForIndustry: industry];;
}

// Called when the "spot at specific doors" switch changes state.
- (void) doorSwitchChanged: (id) sender {
    bool notHasDoors = (bool) self.hasDoorsControl.selectedSegmentIndex;
    if (notHasDoors) {
        self.myIndustry.hasDoors = [NSNumber numberWithBool: NO];
    } else {
        self.myIndustry.hasDoors = [NSNumber numberWithBool: YES];
    }
    // Regenerate text.
    [self fillInAsIndustry: self.myIndustry];
}

// Handle clicks on the text fields that are supporting immediate editing.  Either make the text
// editable, or raise the correct popover to permit selection.
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == self.townNameField) {
        // TODO(bowdidge): Put up list of potential locations here.
        [self.myController doStationPressed: self];
        return NO;
    } else if (textField == self.cargos) {
        // What to do here?
        return NO;
    }
    
    // Treat as text field.
    textField.backgroundColor = [UIColor whiteColor];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    
    return YES;
}

// Note when editing is complete so that changes can be saved.  For now, only watch for changes to the
// reporting marks so that we can resort the table.
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (textField == self.townNameField) {
        // Already handled in view controller's doCloseChooser.
        return YES;
    }
    
    // TODO(bowdidge): Warn about changes to alphabetic order?
    // [self.myController noteTableCell: self changedCarReportingMarks: textField.text];
    
    NSString *newValue = textField.text;
    if (textField == self.industryNameField) {
        self.myIndustry.name = newValue;
    } else if (textField == self.divisionName) {
        self.myIndustry.division = newValue;
    } else if (textField == self.numberOfDoorsField) {
        NSNumberFormatter *f = [[[NSNumberFormatter alloc] init] autorelease];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber *numberOfDoors = [f numberFromString: textField.text];
        self.myIndustry.numberOfDoors = numberOfDoors;
    } else if (textField == self.sidingLength) {
        NSNumberFormatter *f = [[[NSNumberFormatter alloc] init] autorelease];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber *sidingLength = [f numberFromString: textField.text];
        self.myIndustry.sidingLength = sidingLength;
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField endEditing: YES];
    return YES;
}


@synthesize myIndustry;
@synthesize sidingLengthLabel;
@synthesize industryDescription;
@synthesize industryIcon;

@synthesize divisionName;
@synthesize hasDoorsControl;
@synthesize numberOfDoorsField;
@synthesize cargos;
@synthesize cargoHelpButton;

@end
