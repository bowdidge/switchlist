//
//  FreightCarKindChooser.h
//  SwitchList
//
//  Created by Robert Bowdidge on 1/6/13.
//
//

#import <UIKit/UIKit.h>

@class FreightCar;
@class FreightCarTableViewController;

@interface FreightCarKindCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UILabel *checkField;
@property (retain, nonatomic) IBOutlet UILabel *label;
@end

// Popover for selecting the station where the yard is placed.
@interface FreightCarKindChooser : UITableViewController

// Reference back to the view controller listing all freight cars,
// which is responsible for changing the freight car.
@property (retain, nonatomic) IBOutlet FreightCarTableViewController *myController;

// Index of item selected.
@property (nonatomic) int checkedValue;

// Freight car being manipulated.  Used for marking the current setting,
// and also remembering the current selection.
@property (retain, nonatomic) FreightCar *selectedFreightCar;

// List of all car types to display.
@property (retain, nonatomic) NSArray *allCarTypes;
@end
