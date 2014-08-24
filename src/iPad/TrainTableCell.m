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
    self.trainDescription.text = [self.train niceListOfStationsString];
    self.trainKind.text = [CarTypes acceptedCarTypesString: [train acceptedCarTypesRel]];
    self.trainIcon.hidden = NO;
    self.stops.text = [self.train niceListOfStationsString];
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
    if (textField == self.carsAccepted) {
        //[self.myController doCarTypePressed: self];
        return NO;
    } else if (textField == self.stops) {
        // Run graph
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
    if (textField == self.carsAccepted ||
        textField == self.stops) {
        // should have already been handled..
        return YES;
    }
    
    textField.backgroundColor = [UIColor clearColor];
    textField.borderStyle = UITextBorderStyleNone;
    // TODO(bowdidge): Warn about changes to alphabetic order?
    // [self.myController noteTableCell: self changedCarReportingMarks: textField.text];
    
    NSString *newValue = textField.text;
    if (textField == self.trainName) {
        self.train.name = newValue;
    } else if (textField == self.maximumLength) {
        NSNumberFormatter *f = [[[NSNumberFormatter alloc] init] autorelease];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber *maxLength = [f numberFromString: textField.text];
        self.train.maxLength = maxLength;
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField endEditing: YES];
    return YES;
}

@synthesize trainName;
@synthesize trainKind;
@synthesize trainDescription;
@synthesize trainIcon;
@end
