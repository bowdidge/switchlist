//
//  SwitchListViewController.h
//  SwitchList for iPad
//
//  Created by Robert Bowdidge on 9/5/12.
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
#import "SwitchlistPresentationViewController.h"

@interface MainWindowViewController : UIViewController


// Handles press on one of the switchlist forms.
- (IBAction) didTouchSwitchList: (id) sender;

// Handles press on advance layout button.
- (IBAction) doAdvanceLayout: (id) sender;

// Regenerates switchlists now.  May take on the order of a second.
- (IBAction) doRegenerateSwitchlists: (id) sender;

// Warn that switchlists need regenerating on next load of main page.
- (IBAction) noteRegenerateSwitchlists;

- (IBAction) raiseFreightCarView: (id) sender;
- (IBAction) raiseIndustryView: (id) sender;
- (IBAction) raiseTownView: (id) sender;
- (IBAction) raiseTrainView: (id) sender;
- (IBAction) raiseCargoView: (id) sender;


// NSView and labels used for grouping switchlists and reports.
// By doing these as views, it's easy to animate their resizing.
@property(nonatomic, retain) IBOutlet UILabel *switchlistsLabel;
@property(nonatomic, retain) IBOutlet UILabel *reportsLabel;
// Box that all switchlists will be displayed on top of.
@property(nonatomic, retain) IBOutlet UIView *switchlistBox;
// Box that all reports will be displayed on top of.  Disappears when
// in landscape mode.
@property(nonatomic, retain) IBOutlet UIView *reportBox;
@end
