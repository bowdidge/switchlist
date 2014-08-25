//
//  YardTableCell.h
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

#import <UIKit/UIKit.h>

#import "YardTableViewController.h"

@class Yard;

@interface YardTableCell : UITableViewCell

// Fill in cell based on Yard object.
- (void) fillInAsYard: (Yard *) place;

// Yard object represented by this cell.
@property (nonatomic, retain) Yard *yard;

// fields in both versions of cell.
@property (nonatomic, retain) IBOutlet UIImageView *yardIcon;
// Description field at bottom of cell summarizing details about
// the yard.
@property (nonatomic, retain) IBOutlet UILabel *yardDescription;

// Fields only in the short version.
@property (nonatomic, retain) IBOutlet UILabel *yardNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *yardStationLabel;

// Fields only in long version.
@property (nonatomic, retain) IBOutlet UITextField *yardNameField;
@property (nonatomic, retain) IBOutlet UITextField *yardStation;



// TableViewController handling changes to the Yard object.
@property (nonatomic, retain) IBOutlet YardTableViewController *myController;
@end
