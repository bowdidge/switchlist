//
//  FreightCarTableCell.m
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

#import "FreightCarTableCell.h"

#import "Cargo.h"
#import "CarType.h"
#import "FreightCar.h"
#import "FreightCarTableViewController.h"

@implementation FreightCarTableCell
@synthesize freightCarReportingMarks;
@synthesize freightCarKind;
@synthesize freightCarDescription;
@synthesize freightCarIcon;
@synthesize myController;

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

// Generates the description string for a freight car cell.
- (NSString*) descriptionForFreightCar: (FreightCar*) fc {
    NSMutableString *description = [NSMutableString string];
    if ([fc length]) {
        [description appendFormat: @"%@, length %d feet, ", [[fc carTypeRel] carTypeDescription], [[fc length] intValue]];
    }
    if (![fc cargo]) {
        [description appendString: @"empty, "];
    } else {
        if ([fc isLoaded]) {
            [description appendFormat: @"loaded with %@, ", [[fc cargo] cargoDescription]];
        } else {
            [description appendFormat: @"will be loaded with %@, ", [[fc cargo] cargoDescription]];
        }
        [description appendFormat: @"destination is %@", [[[fc cargo] destination] name]];
    }
    return description;
}

- (void) fillInAsFreightCar: (FreightCar*) fc {
    self.freightCar = fc;
    self.freightCarReportingMarks.text = [fc reportingMarks];
    self.freightCarLocation.text = [NSString stringWithFormat: @"At %@", [[fc currentLocation] name]];
    self.freightCarKind.text = [[fc carTypeRel] carTypeName];
    // Length xx, currently at xxx.  Will pick up load of xxx."
    self.freightCarDescription.text = [self descriptionForFreightCar: fc];
    NSString *carType = [[fc carTypeRel] carTypeName];
    NSString *imagePath = nil;
    if ([carType isEqualToString: @"T"]) {
        imagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: @"T.jpg"];
    } else if ([carType isEqualToString: @"F"]) {
        imagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: @"F.jpg"];
    } else if ([carType isEqualToString: @"RS"]) {
        imagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: @"RS.jpg"];
    } else if ([carType isEqualToString: @"XM"]) {
        imagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: @"XM.jpg"];
    }
    if (imagePath) {
        // crashes ipad.
        //self.freightCarIcon.image = [UIImage imageWithContentsOfFile: imagePath];
    }

}

// Mark the cell as the "add" cell at the bottom of the list.
- (void) fillInAsAddCell {
    freightCarReportingMarks.text = @"Add Freight Car";
    freightCarKind.text = @"";
    freightCarDescription.text = @"";
    freightCarIcon.hidden = YES;
}


//  Handle clicks on the text fields that are supporting immediate
// editing.
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == self.freightCarReportingMarks) {
        // Mark text as editable.
        textField.backgroundColor = [UIColor whiteColor];
        textField.borderStyle = UITextBorderStyleRoundedRect;
    } else if (textField == self.freightCarLocation) {
        // TODO(bowdidge): Put up list of potential locations here.
        [self.myController doLocationPressed: self];
        return NO;
    } else if (textField == self.freightCarKind) {
        [self.myController doKindPressed: self];
        return NO;
    }
    return YES;
}

// Note when editing is complete so changes can be saved.
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (textField == self.freightCarReportingMarks) {
        textField.backgroundColor = [UIColor clearColor];
        textField.borderStyle = UITextBorderStyleNone;
        [self.myController noteTableCell: self changedCarReportingMarks: textField.text];
    }
    return YES;
}

@end
