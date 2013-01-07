//
//  CargoEditControllerViewController.h
//  SwitchList
//
//  Created by Robert Bowdidge on 9/28/12.
//
//

#import "ExpandingEditViewController.h"

@class Cargo;

@interface CargoEditViewController : ExpandingEditViewController

// Actions for the different buttons.
- (IBAction) doPressSourceButton: (id) sender;
- (IBAction) doPressDestinationButton: (id) sender;
- (IBAction) doPressCarTypeButton: (id) sender;
- (IBAction) doPressFixedRateButton: (id) sender;
- (IBAction) doPressRateButton: (id) sender;
- (IBAction) doSave: (id) sender;

// Cargo to display.
@property (nonatomic, retain) Cargo *cargo;

@end
