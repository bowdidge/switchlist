//
//  SwitchListViewController.m
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

#import "MainWindowViewController.h"

#import "AppDelegate.h"
#import "AppNavigationController.h"
#import "EntireLayout.h"
#import "HTMLSwitchlistRenderer.h"
#import "LayoutDetailTabBarController.h"
#import "ScheduledTrain.h"
#import "SwitchlistPresentationViewController.h"
#import "SwitchListTouchCatcherView.h"


@interface MainWindowViewController ()
// Advance layout button.
@property (nonatomic, retain) IBOutlet UIButton *advanceButton;

// Array of all miniature reports being shown.
@property (nonatomic, retain) NSMutableArray *allCatchers;

@end

@implementation MainWindowViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

// Generate the SwitchList html documents to display on the screen.
- (void)generateDocumentTable {
    // For now, use table to decide where the items will appear.
    // TODO(bowdidge): Use scrolling list.
    // TODO(bowdidge): Correctly handle redrawing when screen rotates.
    float xStart[16] = {50.0, 200.0, 350.0, 500, 50, 200, 350, 500, 50, 200, 350, 500, 50, 200, 350, 500};
    float yStart[16] = {100.0, 100.0, 100.0, 100, 300, 300, 300, 300, 500, 500, 500, 500, 700, 700, 700, 700};

    float SWITCHLIST_WIDTH = 120.0;
    float SWITCHLIST_HEIGHT = 180.0;
    AppDelegate *myAppDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    EntireLayout *layout = [myAppDelegate entireLayout];

    // Remove any existing views in preparation for the redraw.
    for (UIView *subview in self.allCatchers) {
        [subview removeFromSuperview];
    }
    
    HTMLSwitchlistRenderer *renderer = [[HTMLSwitchlistRenderer alloc] initWithBundle: [NSBundle mainBundle]];
    int i=0;
    for (ScheduledTrain *train in [layout allTrains]) {
        NSString *switchlistText = [renderer renderSwitchlistForTrain: train
                                                               layout: layout
                                                               iPhone: NO];
        NSString *label = [NSString stringWithFormat: @"%@ (%d)", [train name], [[train freightCars] count]];
        CGRect frame = CGRectMake(xStart[i], yStart[i], SWITCHLIST_WIDTH, SWITCHLIST_HEIGHT);
        SwitchListTouchCatcherView *catcher = [[SwitchListTouchCatcherView alloc] initWithFrame: frame
                                                                                          label: label];
        [[self view] addSubview: catcher];
        [catcher setDelegate: self];
        [self.allCatchers addObject: catcher];
        catcher.switchlistHtml = switchlistText;
        i++;
    }
    
    // Do industry report as well.
    NSString *switchlistText = [renderer renderIndustryListForLayout: layout];
    SwitchListTouchCatcherView *catcher = [[SwitchListTouchCatcherView alloc] initWithFrame: CGRectMake(xStart[i], yStart[i], SWITCHLIST_WIDTH, SWITCHLIST_HEIGHT)
                                                                                      label: @"Industry Report"];
    [[self view] addSubview: catcher];
    [catcher setDelegate: self];
    catcher.switchlistHtml = switchlistText;
    i++;
}

- (void)viewDidLoad {
	// Do any additional setup after loading the view.
    [super viewDidLoad];
    // Generate the list of documents.
    [self generateDocumentTable];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

// Handle press on one of the switchlist icons, and display that switchlist full size.
- (IBAction) didTouchSwitchList: (id) sender {
    AppDelegate *myAppDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    AppNavigationController *navigationController = (AppNavigationController*)myAppDelegate.window.rootViewController;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
    SwitchlistPresentationViewController *presentationVC = [storyboard instantiateViewControllerWithIdentifier:@"presentation"];

    [presentationVC setHtmlText: ((SwitchListTouchCatcherView*)sender).switchlistHtml];
    [navigationController pushViewController: presentationVC animated: YES];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // TODO(bowdidge): Make sure press was on icon.
    //[[self navigationController] pushViewController: nil animated: YES];
}

// Handles press on the gear to show layout details. Raises tab view.
- (IBAction) showLayoutDetail: (id) sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
    LayoutDetailTabBarController *myTab = [storyboard instantiateViewControllerWithIdentifier:@"layoutDetailTabBar"];
    
    AppDelegate *myAppDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    AppNavigationController *navigationController = (AppNavigationController*)myAppDelegate.window.rootViewController;
    [navigationController pushViewController: myTab animated:YES];

}

// Handles press on advance button.  Prepare for next session.
- (IBAction) doAdvanceLayout: (id) sender {
    AppDelegate *myAppDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    EntireLayout *entireLayout = myAppDelegate.entireLayout;
    [myAppDelegate.layoutController advanceLoads];
    [myAppDelegate.layoutController createAndAssignNewCargos: 40];
    [myAppDelegate.layoutController assignCarsToTrains: [entireLayout allTrains] respectSidingLengths:YES useDoors:YES];
    [self generateDocumentTable];
}

@synthesize allCatchers;
@end
