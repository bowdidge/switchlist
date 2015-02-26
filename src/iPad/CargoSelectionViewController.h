//
//  CargoSelectionViewController.h
//  SwitchList
//
//  Created by bowdidge on 8/29/14.
//  Copyright (c) 2014 Robert Bowdidge. All rights reserved.
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

#import "Industry.h"

@interface CargoSelectionViewController : UIViewController<UIPickerViewDataSource,UIPickerViewDelegate,UITableViewDataSource,UITableViewDelegate>

// Done upon change of the picker.
- (IBAction) doChangeIndustryClass: (id) sender;

// Done upon change of industry being examined.
- (IBAction) doChangeSelectedIndustry:(id) sender;

// Create the selected cargos.
- (IBAction) doCreateCargos: (id) sender;

@property(retain, nonatomic) EntireLayout *entireLayout;
@property(retain,nonatomic) IBOutlet UILabel *industryName;
@property(retain,nonatomic) IBOutlet UIPickerView *categoryPicker;
@property(retain, nonatomic) IBOutlet UITableView *suggestedCargoView;
@property(retain, nonatomic) Industry *selectedIndustry;
@property(retain, nonatomic) NSArray *suggestedCategories;
@property(retain, nonatomic) NSArray *allCategories;
@property(retain, nonatomic) NSDictionary *categoryMap;
@property(retain, nonatomic) IBOutlet UIButton *createCargosButton;
@property(retain, nonatomic) IBOutlet UITextField *proposedCargoCountMsg;

@property(retain, nonatomic) NSArray *proposedCargos;

// Index of currently-expanded cell.
@property (nonatomic, retain) NSIndexPath *expandedCellPath;

@end
