//
//  ExpandingEditViewController.h
//  SwitchList
//
//  Created by Robert Bowdidge on 9/25/12.
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

#import "AbstractTableViewController.h"
#import "EditViewController.h"
#import "CurlyView.h"

@interface ExpandingEditViewController : EditViewController<UITableViewDataSource, UITableViewDelegate>

// Widens the popover to show the selection table on the right side.
- (void) doWidenPopoverFrom: (CGRect) leftSideRect;

// Collapses the popover frame and hides the table.
- (void) doNarrowPopoverFrame;

// Handles selection of a particular row in the right hand table.
// To be implemented by subclasses.
- (void) didSelectRowWithIndexPath: (NSIndexPath*) path;
    
// Table on right side of popover that is alternately exposed and hidden.
@property (retain, nonatomic) IBOutlet UITableView *rightSideSelectionTable;

// UIView doing highlighting to tie button to table.
@property (retain, nonatomic) IBOutlet CurlyView *curlyView;

// Width of popover in unexpanded state.  To be set by subclasses.
@property (nonatomic) float popoverSizeCollapsed;
// Width of popover in expanded state. To be set by subclasses.
@property (nonatomic) float popoverSizeExpanded;

// Navigation bar capping every edit window.
@property (retain, nonatomic) IBOutlet UINavigationBar *myNavigationBar;

// Current array of data to show and select in the right hand table.
@property (retain, nonatomic) NSArray *currentArrayToShow;


// Selector to call on each data element to get label for cell.
// TODO(bowdidge): Consider multiple selectors for multiple pieces of information.
@property (nonatomic) SEL currentTitleSelector;



@end
