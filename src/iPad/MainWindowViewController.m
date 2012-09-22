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

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "MainWindowViewController.h"

#import "AppDelegate.h"
#import "AppNavigationController.h"
#import "EntireLayout.h"
#import "FileViewController.h"
#import "HTMLSwitchlistRenderer.h"
#import "LayoutDetailTabBarController.h"
#import "ScheduledTrain.h"
#import "SwitchListColors.h"
#import "SwitchlistPresentationViewController.h"
#import "SwitchListTouchCatcherView.h"


@interface MainWindowViewController ()
// Advance layout button.
@property (nonatomic, retain) IBOutlet UIButton *advanceButton;

// File button.
@property (nonatomic, retain) IBOutlet UIButton *fileButton;

// Array of all miniature reports being shown.
@property (nonatomic, retain) NSMutableDictionary *trainNameToCatcher;

// Share location of template directory/ file root between renderer and WebView.
// TODO(bowdidge): Find better approach.
@property (nonatomic, retain) NSString *basePath;

// Indicates if switchlists need to be regenerated when main window next appears.
@property (nonatomic) BOOL needsSwitchlistRegeneration;
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

// Size of switchlist icon.  Use compile-time constants.
float SWITCHLIST_WIDTH = 120.0;
float SWITCHLIST_HEIGHT = 180.0;
// Space between switchlists, x and y.
float SWITCHLIST_BORDER = 10.0;

// Space between boxes.
float GROUP_BOX_BORDER = 32.0;
// Space above top box for icons.  Currently unused.
float EXTRA_TOP_SPACE = 0.0;
// Space for title.
float BOX_HEADER = 25.0;


// Returns the preferred rectangle for a switchlist given the outline of the
// containing element (usually graphical box) and which switchlist this would
// be.  Handles multiple lines.
- (CGRect) positionForSwitchlist: (int) i box: (CGRect) boxRect {
    float boxRectInsetWidth = boxRect.size.width - 2 * SWITCHLIST_BORDER;
    int switchlistsPerRow = boxRectInsetWidth / SWITCHLIST_TOUCH_CATCHER_VIEW_WIDTH;

    BOOL isSecondRow = ((i / switchlistsPerRow) == 1);
    int position = i % switchlistsPerRow;
    float rowY =  boxRect.origin.y + BOX_HEADER;
    if (isSecondRow) {
        rowY += SWITCHLIST_HEIGHT + SWITCHLIST_BORDER;
    }
        
    float rowX = boxRect.origin.x + SWITCHLIST_BORDER + position * (SWITCHLIST_WIDTH + SWITCHLIST_BORDER);
    CGRect frame = CGRectMake(rowX, rowY, SWITCHLIST_WIDTH, SWITCHLIST_HEIGHT);
    return frame;
}

// Creates a SwitchListTouchCatcherView, or reuses an existing one for the same train.
- (SwitchListTouchCatcherView*) makeCatcherWithText: (NSString*) htmlText label: (NSString*) labelName isReport: (BOOL) isReport {
    SwitchListTouchCatcherView *catcher;
    if (!labelName || !(catcher = [self.trainNameToCatcher objectForKey: labelName])) {
        CGRect fakeFrame = CGRectMake(-100, -100, 100, 100);
        catcher = [[SwitchListTouchCatcherView alloc] initWithFrame: fakeFrame];
        [self.view addSubview: catcher];
        catcher.delegate = self;
        catcher.label = labelName;
        catcher.isReport = isReport;
        if (labelName) {
            [self.trainNameToCatcher setObject: catcher forKey: labelName];
        }
    }
    catcher.switchlistHtml = htmlText;
    return catcher;
}

// Do the initial creation of the switchlists and reports, and add the needed icons to the view.
- (void) createViews {
    AppDelegate *myAppDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    EntireLayout *layout = [myAppDelegate entireLayout];

    HTMLSwitchlistRenderer *renderer = [[[HTMLSwitchlistRenderer alloc] initWithBundle: [NSBundle mainBundle]] autorelease];
    
    self.basePath = nil;
    if (myAppDelegate.preferredTemplateStyle) {
        [renderer setTemplate: myAppDelegate.preferredTemplateStyle];
       // Valid directory?  If not, default to the stock version.
        if ([renderer templateDirectory]) {
            self.basePath = [[renderer templateDirectory] stringByAppendingPathComponent: @"switchlist.html"];
        }
    }
    if (!self.basePath) {
        self.basePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: @"switchlist.html"];
    }
    SwitchListTouchCatcherView *catcher;
    for (ScheduledTrain *train in [layout allTrains]) {
        NSString *htmlText = [renderer renderSwitchlistForTrain: train layout: layout iPhone: NO];
        catcher = [self makeCatcherWithText: htmlText label: [train name] isReport: NO];
        [catcher setTrain: train];
        // Ensure badge redraws.
        [catcher setNeedsDisplay];
    }

    [self makeCatcherWithText: [renderer renderIndustryListForLayout: layout]
                                                        label: @"Industry Report"
                                                     isReport: YES];
    [self makeCatcherWithText: [renderer renderYardReportForLayout: layout]
                                                        label: @"Yard Report"
                                                     isReport: YES];
    [self makeCatcherWithText: [renderer renderCarlistForLayout: layout]
                                                        label: @"Car List"
                                                     isReport: YES];
}

// Generate the SwitchList html documents to display on the screen.
- (void)generateDocumentTable {

    UIInterfaceOrientation orient = [[UIApplication sharedApplication] statusBarOrientation];
    BOOL isPortrait = UIInterfaceOrientationIsPortrait(orient);

    CGRect rect = self.view.bounds;
    // TODO(bowdidge): Clean up this code once I'm happy with the appearance.
    float TWO_ROW_BOX = BOX_HEADER + 2 * SWITCHLIST_HEIGHT + 3 * SWITCHLIST_BORDER;
    float ONE_ROW_BOX = BOX_HEADER + 1 * SWITCHLIST_HEIGHT + 2 * SWITCHLIST_BORDER;
    
    float FIRST_BOX_START_Y = GROUP_BOX_BORDER + EXTRA_TOP_SPACE;
    float SECOND_BOX_START_Y = FIRST_BOX_START_Y + TWO_ROW_BOX + GROUP_BOX_BORDER;
    
    float BOX_WIDTH = rect.size.width - GROUP_BOX_BORDER * 2;
    
    CGRect firstBoxBounds = CGRectMake(GROUP_BOX_BORDER, FIRST_BOX_START_Y, BOX_WIDTH, TWO_ROW_BOX);
    CGRect secondBoxBounds;
    if (isPortrait) {
        secondBoxBounds = CGRectMake(GROUP_BOX_BORDER, SECOND_BOX_START_Y, BOX_WIDTH, ONE_ROW_BOX);
    } else {
        // Put off screen.
        secondBoxBounds = CGRectMake(2000.0, 2000.0, 100.0, 100.0);
    }

    [UIView animateWithDuration:0.5 animations:^{
        CGRect labelFrame = firstBoxBounds;
        labelFrame.origin.y = 0;
        labelFrame.size.height = 20;
        switchlistBox.frame = firstBoxBounds;
        switchlistsLabel.text = @"Switchlists for train crews";
        switchlistsLabel.frame = labelFrame;
    
        labelFrame = secondBoxBounds;
        labelFrame.origin.y = 0;
        labelFrame.size.height = 20;
        reportBox.frame = secondBoxBounds;
        reportsLabel.text = @"Paperwork for setup";
        reportsLabel.frame = labelFrame;

        int i=0;
        // Iterate through all switchlists and reports, and drop the reports for now.  They
        // get placed in a separate box or at the end.
        NSArray *allDocuments = [[self.trainNameToCatcher allValues] sortedArrayUsingSelector: @selector(compare:)];
        for (SwitchListTouchCatcherView *switchlist in allDocuments) {
            if ([switchlist isReport] == NO) {
                [switchlist setFrame: [self positionForSwitchlist: i box: firstBoxBounds]];
                i++;
           }
        }
        
        CGRect setupBoxBounds = firstBoxBounds;
        if (isPortrait) {
            // Restart for next box.
            i = 0;
            setupBoxBounds = secondBoxBounds;
        }
    
        for (SwitchListTouchCatcherView *report in allDocuments) {
            if ([report isReport]) {
                [report setFrame: [self positionForSwitchlist: i box: setupBoxBounds]];
                i++;
            }
        }
    }];
}

- (void)viewDidLoad {
	// Do any additional setup after loading the view.
    [super viewDidLoad];

    AppDelegate *myAppDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    myAppDelegate.mainWindowViewController = self;
    
    self.trainNameToCatcher = [NSMutableDictionary dictionary];

    // Start box offscreen for better animation.
    [switchlistBox setFrame: CGRectMake(-100, -100, 100, 100)];
    [reportBox setFrame: CGRectMake(-100, -100, 100, 100)];
    [switchlistsLabel setFrame: CGRectMake(-100, -100, 100, 100)];
    [reportsLabel setFrame: CGRectMake(-100, -100, 100, 100)];
    [self createViews];
 
    // Generate the list of documents.  Disable animation on the initial render.
    [CATransaction begin];
    [CATransaction setDisableActions: YES];
    [self generateDocumentTable];
    [CATransaction commit];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.

    AppDelegate *myAppDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    myAppDelegate.mainWindowViewController = nil;
}

- (void) viewWillAppear {
    if (self.needsSwitchlistRegeneration) {
        [self doRegenerateSwitchlists: self];
        self.needsSwitchlistRegeneration = NO;
    }
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    // Regenerate the switchlists arrangement to match the space.
    [self generateDocumentTable];
}

// Handle press on one of the switchlist icons, and display that switchlist full size.
- (IBAction) didTouchSwitchList: (id) sender {
    AppDelegate *myAppDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    AppNavigationController *navigationController = (AppNavigationController*)myAppDelegate.window.rootViewController;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
    SwitchlistPresentationViewController *presentationVC = [storyboard instantiateViewControllerWithIdentifier:@"presentation"];

    [presentationVC setHtmlText: ((SwitchListTouchCatcherView*)sender).switchlistHtml];
    presentationVC.basePath = self.basePath;
    presentationVC.navigationItem.title = ((SwitchListTouchCatcherView*)sender).label;
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

// Trigger regeneration of all HTML for all trains, and create new trains.
// To be done whenever something affecting switchlists change.
- (IBAction) doRegenerateSwitchlists: (id) sender {
    [self createViews];
    [CATransaction begin];
    [CATransaction setDisableActions: YES];
    [self generateDocumentTable];
    [CATransaction commit];
}

// Handles press on advance button.  Prepare for next session.
- (IBAction) doAdvanceLayout: (id) sender {
    AppDelegate *myAppDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    EntireLayout *entireLayout = myAppDelegate.entireLayout;
    [myAppDelegate.layoutController advanceLoads];
    [myAppDelegate.layoutController createAndAssignNewCargos: 40];
    [myAppDelegate.layoutController assignCarsToTrains: [entireLayout allTrains] respectSidingLengths:YES useDoors:YES];
 
    [self doRegenerateSwitchlists: self];
}

- (IBAction) noteRegenerateSwitchlists {
    // TODO(bowdidge): Do this lazily.
    [self doRegenerateSwitchlists: self];
}

// Switch from this scene to another.
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"fileSegue"]) {
        FileViewController *fileController = segue.destinationViewController;
        fileController.myPopoverController = ((UIStoryboardPopoverSegue*)segue).popoverController;
    }
}

/*
- (IBAction) doOpenFilePopover: (id) sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
    FileViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"fileView"];
    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController: controller];
    controller.myPopoverController = popover;
    [popover presentPopoverFromRect: [self.fileButton frame]
                             inView: [self view]
           permittedArrowDirections: UIPopoverArrowDirectionLeft
                           animated: YES];

}*/

@synthesize switchlistBox;
@synthesize reportBox;
@synthesize switchlistsLabel;
@synthesize reportsLabel;
@synthesize basePath;
@synthesize needsSwitchlistRegeneration;
@end
