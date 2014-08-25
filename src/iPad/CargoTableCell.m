//
//  CargoTableCell.m
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

#import "CargoTableCell.h"

#import "Cargo.h"
#import "CargoTableViewController.h"
#import "CarType.h"
#import "Industry.h"

@implementation CargoTableCell

// Fills in all values for the cell based on the cargo object.
- (void) fillInAsCargo: (Cargo*) cargo {
    self.cargo = cargo;
    NSArray *RATE_UNITS_LABEL_ARRAY = [NSArray arrayWithObjects: @"day", @"week", @"month", nil];
    struct CargoRate rate = [cargo cargoRate];

    self.cargoNameLabel.text = [cargo name];
    self.cargoNameField.text = [cargo name];
    self.cargoDescription.text = [cargo description];
    
    NSMutableString *kindString = [NSMutableString stringWithFormat: @"%d cars per %@",
                                   rate.rate, [RATE_UNITS_LABEL_ARRAY objectAtIndex: rate.units]];
    [kindString appendFormat: @", %@", ([cargo carType] ? [cargo carType] : @" ")];
    self.cargoRateLabel.text = kindString;
    cargoIcon.hidden = NO;
    
    if (cargo.source) {
        self.source.text = cargo.source.name;
    } else {
        self.source.text = @"Not set";
    }
    
    if (cargo.destination) {
        self.destination.text = cargo.destination.name;
    } else {
        self.destination.text = @"Not set";
    }
    
    if (cargo.carTypeRel) {
        self.carType.text = [NSString stringWithFormat: @"%@: %@", cargo.carTypeRel.carTypeName, cargo.carTypeRel.carTypeDescription];
    } else {
        self.carType.text = @"Any";
    }
    [self.fixedRateControl setSelectedSegmentIndex: cargo.isPriority ? 0 : 1];
    self.carRate.text = [NSString stringWithFormat: @"%d", rate.rate];
    [self.carTimeUnit setSelectedSegmentIndex: rate.units];
    // TODO(bowdidge): Fix to 1,2,3.
    [self.unloadingTimeControl setSelectedSegmentIndex: cargo.unloadingDays.intValue - 1];
}

// Handle clicks on the text fields that are supporting immediate editing.  Either make the text
// editable, or raise the correct popover to permit selection.
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == self.source) {
        // TODO(bowdidge): Put up list of potential locations here.
        [self.myController doSourcePressed: self];
        return NO;
    } else if (textField == self.destination) {
        [self.myController doDestinationPressed: self];
        return NO;
    } else if (textField == self.carType) {
        [self.myController doCarTypePressed: self];
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
    if (textField == self.source ||
        textField == self.destination ||
        textField == self.carType) {
        // Already handled in view controller's doCloseChooser.
        return YES;
    }
    
    textField.backgroundColor = [UIColor clearColor];
    textField.borderStyle = UITextBorderStyleNone;
    // TODO(bowdidge): Warn about changes to alphabetic order?
    // [self.myController noteTableCell: self changedCarReportingMarks: textField.text];
    
    NSString *newValue = textField.text;
    if (textField == self.cargoNameField) {
        self.cargo.cargoDescription = newValue;
    } else if (textField == self.carRate) {
        NSNumberFormatter *f = [[[NSNumberFormatter alloc] init] autorelease];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber *carRate = [f numberFromString: textField.text];
        self.cargo.rate = carRate;
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField endEditing: YES];
    return YES;
}

// Called when the "random/fixed" switch changes..
- (void) fixedRateControlChanged: (id) sender {
    bool isRandomRate = (bool) self.fixedRateControl.selectedSegmentIndex;
    self.cargo.priority = [NSNumber numberWithBool: !isRandomRate];
    // Regenerate text.
    [self fillInAsCargo: self.cargo];
}

// Called when the "random/fixed" switch changes..
- (void) carTimeUnitChanged: (id) sender {
    NSInteger carTimeUnit = self.carTimeUnit.selectedSegmentIndex;
    switch (carTimeUnit) {
        case 0:
            self.cargo.rateUnits = [NSNumber numberWithInt: 0];
            break;
        case 1:
            self.cargo.rateUnits = [NSNumber numberWithInt: 1];
            break;
        case 2:
            self.cargo.rateUnits = [NSNumber numberWithInt: 2];
            break;
        default:
            break;
    }
    // Regenerate text.
    [self fillInAsCargo: self.cargo];
}

// Called when the "random/fixed" switch changes..
- (void) unloadingTimeControlChanged: (id) sender {
    NSInteger unloadingTimeChoice = self.unloadingTimeControl.selectedSegmentIndex;
    // 0 on control = 1 day.
    self.cargo.unloadingDays = [NSNumber numberWithInt: (int) unloadingTimeChoice + 1];
    // Regenerate text].
    [self fillInAsCargo: self.cargo];
}

@synthesize cargoRateLabel;
@synthesize cargoDescription;
@synthesize cargoIcon;
@end
