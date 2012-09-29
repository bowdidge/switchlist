//
//  ExpandingEditViewController.m
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

#import "ExpandingEditViewController.h"

@class CurlyView;

@interface ExpandingEditViewController ()
@end

// View controller for SwitchList's edit views that have a selection table to the right.
@implementation ExpandingEditViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

// Widens the popover to a larger width that displays the right-hand-side table.
// Also sets up curves between the button requesting the information and the table
// to hint what's being selected.
// TODO(bowdidge): Better done with just some light highlighting under the button?
// TODO(bowdidge): Abstract this code into a superclass for easier reuse.
- (void) doWidenPopoverFrom: (CGRect) leftSideRect {
    CGRect currentFrame = self.view.frame;
    self.curlyView.leftRegion = leftSideRect;
    self.curlyView.rightRegion = self.rightSideSelectionTable.frame;
    [self.curlyView setNeedsDisplay];
    
   currentFrame.size.width = self.popoverSizeExpanded;
    self.view.frame = currentFrame;
    self.rightSideSelectionTable.hidden = NO;
    self.curlyView.hidden = NO;
    [self.myTableController.myPopoverController setPopoverContentSize: currentFrame.size animated: YES];
    // No idea why I need to set this manually.
    [self.myNavigationBar setFrame: CGRectMake(0.0, 0.0, self.popoverSizeExpanded, 44.0)];
}

// Collapses the popover frame and hides the table.
- (void) doNarrowPopoverFrame {
    // Selection table selected.
    self.curlyView.hidden = YES;
    CGRect currentFrame = self.view.frame;
    // Stock size is 288x342, widen to 540x342 to show list, back to 288 after.
    currentFrame.size.width = self.popoverSizeCollapsed;
    [self.myTableController.myPopoverController setPopoverContentSize: currentFrame.size animated: YES];
    // No idea why I need to set this manually.
    [self.myNavigationBar setFrame: CGRectMake(0.0, 0.0, self.popoverSizeCollapsed, 44.0)];
}


@synthesize curlyView;
@synthesize popoverSizeCollapsed;
@synthesize popoverSizeExpanded;
@end
