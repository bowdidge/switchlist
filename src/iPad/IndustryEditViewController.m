//
//  IndustryEditViewController.m
//  SwitchList
//
//  Created by Robert Bowdidge on 9/22/12.
//
//

#import "IndustryEditViewController.h"

#import "AppDelegate.h"
#import "CurlyView.h"
#import "EntireLayout.h"
#import "Industry.h"
#import "IndustryTableViewController.h"
#import "SelectionCell.h"

// Identify what data is being shown in selection table to the right of the
// popover window.
enum {
    SelectionViewNoContents=0,
    SelectionViewLocation=1,
    SelectionViewDivision=2
} SelectionViewContents;

@interface IndustryEditViewController ()
@property (retain, nonatomic) IBOutlet UITextField *nameField;
@property (retain, nonatomic) IBOutlet UIButton *townLocationButton;
@property (retain, nonatomic) IBOutlet UIButton *currentCargoButton;
@property (retain, nonatomic) IBOutlet UIButton *divisionButton;
@property (retain, nonatomic) IBOutlet UISegmentedControl *hasDoorsToggle;
@property (retain, nonatomic) IBOutlet UITextField *numberOfDoorsField;
@property (retain, nonatomic) IBOutlet UITextField *sidingLengthField;

@property (retain, nonatomic) IBOutlet UITableView *rightSideSelectionTable;

@property (retain, nonatomic) IBOutlet UINavigationBar *myNavigationBar;
@property (retain, nonatomic) IBOutlet CurlyView *curlyView;

// Cached copies of layout details.
@property (retain, nonatomic) NSArray *towns;
@property (retain, nonatomic) NSArray *divisions;

@property (nonatomic) int currentSelectionMode;
@end

@implementation IndustryEditViewController

// Window is about to appear for the first time.  Gather data from the layout.
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.rightSideSelectionTable setDataSource: self];
    [self.rightSideSelectionTable setDelegate: self];
    
    AppDelegate *myAppDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    EntireLayout *myLayout = myAppDelegate.entireLayout;
    self.towns = [myLayout allStationsSortedOrder];
    // TODO(bowdidge): Populate this list from freight cars and industries.
    self.divisions = [NSArray arrayWithObjects: @"Here", @"SP", @"WP", @"East", @"Midwest", nil];
    
    self.currentSelectionMode = SelectionViewNoContents;
}

// Window is about to load.  Populate the currently selected freight car's details.
- (void) viewWillAppear: (BOOL) animated {
    [super viewWillAppear: animated];
    self.nameField.text = [self.myIndustry name];
    [self.divisionButton setTitle: [self.myIndustry division] forState: UIControlStateNormal];
    [self.townLocationButton setTitle: [[self.myIndustry location] name] forState: UIControlStateNormal];;
    [self.hasDoorsToggle setEnabled: YES forSegmentAtIndex: [self.myIndustry hasDoors] ? 0 : 1];
    self.numberOfDoorsField.text = [NSString stringWithFormat: @"%@", [self.myIndustry numberOfDoors]];
    self.sidingLengthField.text = [NSString stringWithFormat: @"%@", [self.myIndustry sidingLength]];
}

// Change the freight car as suggested.
- (IBAction) doSave: (id) sender {
    int hasChanges = 0;
    if (hasChanges) {
        [self.myTableController industriesChanged: self];
    }
    [self.myTableController doDismissEditPopover: self];
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
    
    // Stock size is 288x342, widen to 540x342 to show list.
    currentFrame.size.width = 540;
    self.view.frame = currentFrame;
    self.rightSideSelectionTable.hidden = NO;
    [self.myPopoverController setPopoverContentSize: currentFrame.size animated: YES];
}

// Collapses the popover frame and hides the table.
- (void) doNarrowPopoverFrame {
    // Selection table selected.
    CGRect currentFrame = self.view.frame;
    // Stock size is 288x342, widen to 540x342 to show list, back to 288 after.
    currentFrame.size.width = 288;
    [self.myPopoverController setPopoverContentSize: currentFrame.size animated: YES];
}

// Handles the user pressing the car type in order to select a different value.
- (IBAction) doPressDivisionButton: (id) sender {
    // TODO(bowdidge) Use sender instead of explicit button.
    [self doWidenPopoverFrom: self.divisionButton.frame];
    self.currentSelectionMode = SelectionViewDivision;
    [self.rightSideSelectionTable reloadData];
}

// Handles the user pressing the cargo button in order to select a different value.
- (IBAction) doPressTownLocationButton: (id) sender {
    [self doWidenPopoverFrom: self.townLocationButton.frame];
    self.currentSelectionMode = SelectionViewLocation;
    [self.rightSideSelectionTable reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Handles the user pressing an item in the right-hand-side selection table.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self doNarrowPopoverFrame];
    
    // Selected item.
    Place *selectedLocation;
    NSString *currentDivision;
    switch (self.currentSelectionMode) {
        case SelectionViewLocation:
            selectedLocation = [self.towns objectAtIndex: [indexPath row]];
            // TODO(bowdidge): Pass actual object.
            [self.townLocationButton setTitle: [selectedLocation name]
                                        forState: UIControlStateNormal];
            break;
        case SelectionViewDivision:
            currentDivision = [self.divisions objectAtIndex: [indexPath row]];
            // TODO(bowdidge): Pass actual object.
            [self.divisionButton setTitle: currentDivision
                                     forState: UIControlStateNormal];
            break;
        default:
            break;
    }
    
}

// Returns the number of sections in the selection table on the right hand side of the popover.
// This is always 1 - there are no divisions in the selection table.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Three sections: on layout, on workbench, and empty/add.
    return 1;
}

// Returns the number of rows in the selection table to the right hand side of
// the popover.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (self.currentSelectionMode) {
        case SelectionViewLocation:
            return self.towns.count;
        case SelectionViewDivision:
            return self.divisions.count;
        default:
            return 0;
    }
    return 0;
}

// Creates each cell for the selection table.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"selectionCell";
    
    SelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SelectionCell alloc] initWithStyle:UITableViewCellStyleDefault
                                    reuseIdentifier:CellIdentifier];
        [cell autorelease];
    }
    
    switch (self.currentSelectionMode) {
        case SelectionViewLocation:
            cell.cellText.text = [[self.towns objectAtIndex: [indexPath row]] name];
            break;
        case SelectionViewDivision:
            cell.cellText.text = [self.divisions objectAtIndex: [indexPath row]];
            break;
        default:
            cell.cellText.text = @"";
            break;
    }
    return cell;
}


@end
