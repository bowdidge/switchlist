//
//  YardTableCell.m
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

#import "YardTableCell.h"

#import "Yard.h"

@implementation YardTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

// Fill in cell based on Yard object.
- (void) fillInAsYard: (Yard *) yard {
    self.yard = yard;
    self.yardNameLabel.text = [yard name];
    self.yardNameField.text = [yard name];
    self.yardStationLabel.text = [NSString stringWithFormat: @"At %@", [[yard location] name]];
    self.yardStation.text = [NSString stringWithFormat: @"At %@", [[yard location] name]];
    
    NSString *locationKind;
    if ([[yard location] isOffline]) {
        locationKind = @"Offline";
    } else if ([[yard location] isStaging]) {
        locationKind = @"In staging";
    } else {
        locationKind = @"On layout";
    }
    self.yardDescription.text = [NSString stringWithFormat: @"%@, %d cars in yard, %d trains originate here.",
                                 locationKind,
                                 (int) [[yard freightCars] count], 3];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == self.yardNameField) {
        textField.backgroundColor = [UIColor whiteColor];
        textField.borderStyle = UITextBorderStyleRoundedRect;
        return YES;
    } else if (textField == self.yardStation) {
        [self.myController doStationPressed: self];
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (textField == self.yardNameField) {
        [self.myController noteYardTableCell: self changedName: textField.text];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.yardNameField) {
      return YES;
    }
    return NO;
}


@end
