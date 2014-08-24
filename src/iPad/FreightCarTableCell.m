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
#import "Industry.h"
#import "Place.h"

@implementation FreightCarTableCell
@synthesize freightCarReportingMarks;

@synthesize shortCarType;
@synthesize descriptionSummary;
@synthesize freightCarIcon;
@synthesize myController;

@synthesize carDivisionField;
@synthesize cargoField;
@synthesize detailedCarType;
@synthesize loadedToggle;
@synthesize carLengthField;
@synthesize longLocation;


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

- (NSString*) cargoDescriptionForFreightCar: (FreightCar*) fc {
    if (![fc cargo]) {
        return @"unassigned";
    }
    if ([fc isLoaded]) {
        return [NSString stringWithFormat: @"loaded with %@ for %@", [[fc cargo] cargoDescription], [[[fc cargo] destination] name]];
    }
    return [NSString stringWithFormat: @"will be loaded with %@ at %@", [[fc cargo] cargoDescription], [[[fc cargo] source] name]];
}

// Generates the description string for a freight car cell.  This only appears in the
// short version.
- (NSString*) descriptionForFreightCar: (FreightCar*) fc {
    NSMutableString *description = [NSMutableString string];
    if ([fc length]) {
        [description appendFormat: @"%@, length %d feet, ", [[fc carTypeRel] carTypeDescription], [[fc length] intValue]];
    }
    
    [description appendFormat: @"%@", [self cargoDescriptionForFreightCar: fc]];

   return description;
}

// Fill in the current cell based on the details for the named freight car.
- (void) fillInAsFreightCar: (FreightCar*) fc {
    self.freightCar = fc;
    self.freightCarReportingMarks.text = [fc reportingMarks];
    self.shortLocation.text = [NSString stringWithFormat: @"At %@", [[fc currentLocation] name]];
    self.shortCarType.text = [[fc carTypeRel] carTypeName];

    self.longLocation.text = [NSString stringWithFormat: @"At %@ in %@", [[fc currentLocation] name], [[[fc currentLocation] location] name]];
    self.carDivisionField.text = [fc homeDivision];
    self.cargoField.text = [self cargoDescriptionForFreightCar: fc];
    self.carLengthField.text = [NSString stringWithFormat: @"%d", [[fc length] intValue]];
    self.detailedCarType.text = [NSString stringWithFormat: @"%@ (%@)", [[fc carTypeRel] carTypeDescription], [[fc carTypeRel] carTypeName]];
    [self.loadedToggle setSelectedSegmentIndex: [fc isLoaded] ? 0 : 1];
    

    // Length xx, currently at xxx.  Will pick up load of xxx."
    self.descriptionSummary.text = [self descriptionForFreightCar: fc];
    NSString *carType = [[fc carTypeRel] carTypeName];
    NSString *imagePath = nil;
    if ([carType isEqualToString: @"T"]) {
        imagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: @"T.jpg"];
    } else if ([carType isEqualToString: @"F"] || [carType isEqualToString: @"FM"]) {
        imagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: @"F.jpg"];
    } else if ([carType isEqualToString: @"RS"]) {
        imagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: @"RS.jpg"];
    } else if ([carType isEqualToString: @"XM"]) {
        imagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: @"XM.jpg"];
    } else if ([carType isEqualToString: @"XMC"]) {
        imagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: @"XM.jpg"];
    }
    if (imagePath) {
        // crashes ipad.
        self.freightCarIcon.image = [UIImage imageWithContentsOfFile: imagePath];
    }

}

- (IBAction) doChangeLoadedState: (id) sender {
    bool notLoaded = (bool) self.loadedToggle.selectedSegmentIndex;
    if (notLoaded) {
        self.freightCar.loaded = [NSNumber numberWithBool: NO];
    } else {
        self.freightCar.loaded = [NSNumber numberWithBool: YES];
    }
    // Regenerate text.
    [self fillInAsFreightCar: self.freightCar];
}

// Mark the cell as the "add" cell at the bottom of the list.
- (void) fillInAsAddCell {
    self.freightCarReportingMarks.text = @"Add Freight Car";
    self.shortLocation.text = @"";
    self.shortCarType.text = @"";
    self.descriptionSummary.text = @"";
    self.freightCarIcon.hidden = YES;
}


// Handle clicks on the text fields that are supporting immediate editing.  Either make the text
// editable, or raise the correct popover to permit selection.
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == self.shortLocation || textField == self.longLocation) {
        // TODO(bowdidge): Put up list of potential locations here.
        [self.myController doLocationPressed: self];
        return NO;
    } else if (textField == self.shortCarType || textField == self.detailedCarType) {
        [self.myController doCarTypePressed: self];
        return NO;
    } else if (textField == self.cargoField) {
        // TODO(bowdidge): Put up list of potential locations here.
        [self.myController doCargoPressed: self];
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
    if (textField == self.shortLocation ||
        textField == self.longLocation ||
        textField == self.shortCarType ||
        textField == self.detailedCarType ||
        textField == self.cargoField) {
        // Handled in doX.
        return YES;
    }

    textField.backgroundColor = [UIColor clearColor];
    textField.borderStyle = UITextBorderStyleNone;
    // TODO(bowdidge): Warn about changes to alphabetic order?
    // [self.myController noteTableCell: self changedCarReportingMarks: textField.text];
    
    NSString *newValue = textField.text;
    if (textField == self.freightCarReportingMarks) {
        self.freightCar.reportingMarks = newValue;
    } else if (textField == self.carDivisionField) {
        self.freightCar.homeDivision = newValue;
    } else if (textField == self.carLengthField) {
        NSNumberFormatter *f = [[[NSNumberFormatter alloc] init] autorelease];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber *carLength = [f numberFromString: textField.text];
        self.freightCar.length = carLength;
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField endEditing: YES];
    return YES;
}

@end
