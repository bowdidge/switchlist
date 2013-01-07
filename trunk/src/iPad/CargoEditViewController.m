//
//  CargoEditControllerViewController.m
//  SwitchList
//
//  Created by Robert Bowdidge on 9/28/12.
//
//

#import "CargoEditViewController.h"

#import "AppDelegate.h"
#import "Cargo.h"
#import "CargoEditViewController.h"
#import "CarType.h"

// Identify what data is being shown in selection table to the right of the
// popover window.
enum {
    SelectionViewNoContents=0,
    SelectionViewCarType=1,
    SelectionViewSource=2,
    SelectionViewDestination=3,
} SelectionViewContents;


@interface CargoEditViewController ()
@property (retain, nonatomic) IBOutlet UITextField *descriptionField;
@property (retain, nonatomic) IBOutlet UIButton *carTypeButton;
@property (retain, nonatomic) IBOutlet UIButton *sourceButton;
@property (retain, nonatomic) IBOutlet UIButton *destinationButton;
@property (retain, nonatomic) IBOutlet UISegmentedControl *fixedToggle;
@property (retain, nonatomic) IBOutlet UISegmentedControl *rateToggle;

// Cached copies of layout details.
@property (retain, nonatomic) NSArray *carTypes;
@property (retain, nonatomic) NSArray *locations;
@property (nonatomic) int currentSelectionMode;
@end


@implementation CargoEditViewController

// Window is about to appear for the first time.  Gather data from the layout.
- (void)viewDidLoad {
    [super viewDidLoad];
    self.popoverSizeCollapsed = 288.0;
    self.popoverSizeExpanded = 540.0;
    
    // Do any additional setup after loading the view.
    
    AppDelegate *myAppDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    EntireLayout *myLayout = myAppDelegate.entireLayout;
    self.carTypes = [myLayout allCarTypes];
    // TODO(bowdidge): Add yards.
    self.locations = [myLayout allIndustries];
    
    self.currentSelectionMode = SelectionViewNoContents;
}

// Window is about to load.  Populate the currently selected freight car's details.
- (void) viewWillAppear: (BOOL) animated {
    [super viewWillAppear: animated];
}

- (void) setCargo: (Cargo*) myCargo {
    [cargo release];
    cargo = [myCargo retain];
    self.descriptionField.text = [self.cargo name];
    [self.sourceButton setTitle: [[self.cargo source] name] forState: UIControlStateNormal];
    [self.destinationButton setTitle: [[self.cargo destination] name] forState: UIControlStateNormal];
    [self.carTypeButton setTitle: [[self.cargo carTypeRel]  carTypeName] forState: UIControlStateNormal];;
    [self.rateToggle setSelectedSegmentIndex: [self.cargo cargoRate].units];
    [self.fixedToggle setSelectedSegmentIndex: [self.cargo isPriority]];
}

// Change the freight car as suggested.
- (IBAction) doSave: (id) sender {
/*
 AppDelegate *myAppDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    EntireLayout *myLayout = myAppDelegate.entireLayout;
    
    [self.myIndustry setName: self.nameField.text];
    [self.myIndustry setDivision: self.divisionButton.titleLabel.text];
    [self.myIndustry setLocation: [myLayout stationWithName: self.townLocationButton.titleLabel.text]];
    int currentSegment = self.hasDoorsToggle.selectedSegmentIndex;
    [self.myIndustry setHasDoors: (currentSegment == 0) ? YES : NO];
    
    [self.myIndustry setNumberOfDoors: [NSNumber numberWithInt: [self.numberOfDoorsField.text intValue]]];
    [self.myIndustry setSidingLength: [NSNumber numberWithInt: [self.sidingLengthField.text intValue]]];
    
    [self.myTableController layoutObjectsChanged: self];
 */
    [self.myTableController doDismissEditPopover: self];
}

// Handles the user pressing the car type in order to select a different value.
- (IBAction) doPressSourceButton: (id) sender {
    // TODO(bowdidge) Use sender instead of explicit button.
    [self doWidenPopoverFrom: self.sourceButton.frame];
    self.currentSelectionMode = SelectionViewSource;
    self.currentArrayToShow = self.locations;
    self.currentTitleSelector = @selector(name);
    [self.rightSideSelectionTable reloadData];
}

// Handles the user pressing the cargo button in order to select a different value.
- (IBAction) doPressDestinationButton: (id) sender {
    [self doWidenPopoverFrom: self.destinationButton.frame];
    self.currentSelectionMode = SelectionViewDestination;
    self.currentArrayToShow = self.locations;
    self.currentTitleSelector = @selector(name);
    [self.rightSideSelectionTable reloadData];
}

// Handles the user pressing the car type in order to select a different value.
- (IBAction) doPressCarTypeButton: (id) sender {
    // TODO(bowdidge) Use sender instead of explicit button.
    [self doWidenPopoverFrom: self.carTypeButton.frame];
    self.currentSelectionMode = SelectionViewCarType;
    self.currentArrayToShow = self.carTypes;
    self.currentTitleSelector = @selector(carTypeName);
    [self.rightSideSelectionTable reloadData];
}

- (IBAction) doPressFixedRateButton: (id) sender {
}

- (IBAction) doPressRateButton: (id) sender {
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Handles the user pressing an item in the right-hand-side selection table.
- (void)didSelectRowWithIndexPath: (NSIndexPath *)indexPath {
}

@synthesize cargo;
@synthesize currentSelectionMode;
@synthesize carTypes;
@synthesize locations;
@end
