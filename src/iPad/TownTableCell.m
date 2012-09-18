//
//  CityTableCell.m
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

#import "TownTableCell.h"

#import "Place.h"

@implementation TownTableCell
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

- (NSString*) descriptionForTown: (Place*) p {
    int industryCount = p.industries.count;
    int yardCount = p.yards.count;
    int freightCarCount= p.freightCarsAtStation.count;
    
    if (industryCount == 0 && yardCount == 0 && freightCarCount == 0) {
        return @"Not much more than a wide spot in the road.";
    }
    
    NSMutableArray *response = [NSMutableArray array];
    if (industryCount != 0) {
        [response addObject: [NSString stringWithFormat: @"%d industries", industryCount]];
    }
    if (yardCount == 1) {
        [response addObject: @"has yard"];
    } else if (yardCount > 1) {
        [response addObject: @"has multiple yards"];
    }
                                
    if (freightCarCount != 0) {
        [response addObject: [NSString stringWithFormat: @"%d freight cars in town", freightCarCount]];
    }
    
    NSString *responseString = [NSString stringWithFormat: @"%@.", [response componentsJoinedByString: @", "]];

    return responseString;
}

// Fill in cell based on cargo object.
- (void) fillInAsTown: (Place*) place {
    self.townName.text = [place name];
    if ([place isOffline]) {
        self.townKind.text = @"Offline";
    } else if ([place isStaging]) {
        self.townKind.text = @"Staging";
    } else {
        self.townKind.text = @"On Layout";
    }

    // X industries, x yards, x cars in town.
    self.townDescription.text = [self descriptionForTown: place];
    self.townIcon.hidden = NO;
}

// Fill in the cell as the "Add..." cell at the bottom of the table.
- (void) fillInAsAddCell {
    self.townName.text = @"Add Town";
    self.townKind.text = @"";
    self.townDescription.text = @"";
    self.townIcon.hidden = YES;
}

- (IBAction) hideIcon: (BOOL) value {
    [townIcon setHidden: value];
}

@synthesize townName;
@synthesize townKind;
@synthesize townDescription;
@synthesize townIcon;
@end
