//
//  SwitchListTouchCatcherView.h
//  SwitchList for iPad
//
//  Created by Robert Bowdidge on 9/6/12.
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

#import "MainWindowViewController.h"

@class ScheduledTrain;

// Draws the little icon used to represent the actual switchlist.
@interface SwitchListTouchCatcherView : UIView {
}
- (id) initWithFrame: (CGRect) frame;
// Compare in sorted order based on label.
- (NSComparisonResult) compare: (SwitchListTouchCatcherView*) view;

@property(nonatomic, retain) IBOutlet MainWindowViewController *delegate;
// Text of report to show when this button is pressed.
// TODO(bowdidge): Generate lazily.
@property(nonatomic, retain) NSString *switchlistHtml;
// Train object to be described, or nil if the document is a report.
@property(nonatomic, retain) ScheduledTrain *train;
// Label for the icon - either the name of the train, or the name of the report.
@property(nonatomic, retain) NSString *label;
@property(nonatomic) BOOL isReport;
@end

extern float SWITCHLIST_TOUCH_CATCHER_VIEW_HEIGHT;
extern float SWITCHLIST_TOUCH_CATCHER_VIEW_WIDTH;
