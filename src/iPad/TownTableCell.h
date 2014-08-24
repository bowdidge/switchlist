//
//  CityTableCell.h
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

@class Place;

// View data for cells in Town table.
@interface TownTableCell : UITableViewCell

// Fill in cell based on cargo object.
- (void) fillInAsTown: (Place*) place;
// Fill in the cell as the "Add..." cell at the bottom of the table.
- (void) fillInAsAddCell;

@property (nonatomic, retain) IBOutlet UITextField *townName;
@property (nonatomic, retain) IBOutlet UILabel *townKind;
@property (nonatomic, retain) IBOutlet UILabel *townDescription;
@property (nonatomic, retain) IBOutlet UIImageView *townIcon;

// Detail view only.
@property (nonatomic, retain) IBOutlet UISegmentedControl *stagingControl;

- (IBAction) hideIcon: (BOOL) value;
@end
