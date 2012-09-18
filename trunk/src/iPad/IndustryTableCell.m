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

// Creates description string for industry cell.
// Form is "Receives x, y, sends z.  Doors for spotting."
// TODO(bowdidge): List only common cargos so list doesn't become too large.
- (NSString*) descriptionForIndustry: (Industry*) i {
    // Receives x,y, sends z.  Doors for spotting."
    NSSet *outCargos = [i originatingCargos];
    NSSet *inCargos = [i terminatingCargos];
    NSMutableString *description = [NSMutableString string];
    if ([outCargos count] != 0) {
        [description appendFormat: @"receives %@, ", [[outCargos anyObject] cargoDescription]];
    }
    if ([inCargos count] != 0) {
        [description appendFormat: @"ships %@, ", [[inCargos anyObject] cargoDescription]];
    }
    if ([i hasDoors]) {
        [description appendString: @"Spot at specific doors."];
    }
    return description;
}

// Fill in cell based on cargo object.
- (void) fillInAsIndustry: (Industry*) industry {
    self.industryName.text = [NSString stringWithFormat: @"%@ at %@", [industry name], [[industry location] name]];
    self.industrySidingLength.text = [NSString stringWithFormat: @"%d foot siding", [[industry sidingLength] intValue]];
    self.industryDescription.text = [self descriptionForIndustry: industry];
}

// Fill in the cell as the "Add..." cell at the bottom of the table.
- (void) fillInAsAddCell {
    self.industryName.text = @"Add Industry";
    self.industrySidingLength.text = @"";
    self.industryDescription.text = @"";
    self.industryIcon.hidden = YES;
}

@synthesize industryName;
@synthesize industrySidingLength;
@synthesize industryDescription;
@synthesize industryIcon;
@end
