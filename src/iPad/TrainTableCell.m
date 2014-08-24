//
//  TrainTableCell.m
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

#import "TrainTableCell.h"

#import "CarTypes.h"
#import "ScheduledTrain.h"

@implementation TrainTableCell

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

// Fills in cell based on ScheduledTrain object.
- (void) fillInAsTrain: (ScheduledTrain*) train {
    self.train = train;
    self.trainName.text = [train name];
    NSArray *stations = [train stationsInOrder];
    self.trainDescription.text = [NSString stringWithFormat: @"From %@ to %@.", [[stations objectAtIndex: 0] name],[[stations lastObject] name]];
    self.trainKind.text = [CarTypes acceptedCarTypesString: [train acceptedCarTypesRel]];
    self.trainIcon.hidden = NO;
}

// Fill in the cell as the "Add..." cell at the bottom of the table.
- (void) fillInAsAddCell {
    self.trainName.text = @"Add Train";
    self.trainKind.text = @"";
    self.trainDescription.text = @"";
    self.trainIcon.hidden = YES;
}

// Handle clicks on the text fields that are supporting immediate editing.  Either make the text
// editable, or raise the correct popover to permit selection.
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == self.stops) {
        // Mark text as editable.
        textField.backgroundColor = [UIColor whiteColor];
        textField.borderStyle = UITextBorderStyleRoundedRect;
    } else if (textField == self.carsAccepted) {
        // TODO(bowdidge): Consider better UI.
        //[self.myController doCarTypePressed: self];
        return NO;
    }
    return YES;
}

// Note when editing is complete so that changes can be saved.  For now, only watch for changes to the
// reporting marks so that we can resort the table.
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (textField == self.trainName) {
        textField.backgroundColor = [UIColor clearColor];
        textField.borderStyle = UITextBorderStyleNone;
        self.train.name = textField.text;
        // Reorder.
        // [self.myController.tableView reloadData];
    }
    return YES;
}

@synthesize trainName;
@synthesize trainKind;
@synthesize trainDescription;
@synthesize trainIcon;
@end
