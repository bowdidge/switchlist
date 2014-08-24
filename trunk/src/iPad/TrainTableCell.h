//
//  TrainTableCell.h
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

@class ScheduledTrain;
@class TrainTableViewController;

// View data for the train cell items
@interface TrainTableCell : UITableViewCell

// Fill in cell based on train object.
- (void) fillInAsTrain: (ScheduledTrain*) place;
// Fill in the cell as the "Add..." cell at the bottom of the table.
- (void) fillInAsAddCell;

@property (nonatomic, retain) ScheduledTrain *train;
// In simple and extended cells.
@property (nonatomic, retain) IBOutlet UITextField *trainName;
@property (nonatomic, retain) IBOutlet UIImageView *trainIcon;

// In simple cells only.
@property (nonatomic, retain) IBOutlet UILabel *trainKind;
@property (nonatomic, retain) IBOutlet UILabel *trainDescription;

// In extended cells only.
@property (nonatomic, retain) IBOutlet UITextField *stops;
@property (nonatomic, retain) IBOutlet UITextField *maximumLength;
@property (nonatomic, retain) IBOutlet UITextField *carsAccepted;

// Reference back to the controller processing changes to the cells.
@property (nonatomic, retain) IBOutlet TrainTableViewController *myController;

@end
