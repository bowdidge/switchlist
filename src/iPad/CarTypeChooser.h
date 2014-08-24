//
//  FreightCarKindChooser.h
//  SwitchList
//
//  Created by Robert Bowdidge on 1/6/13.
//
//

#import <UIKit/UIKit.h>

@class CarType;
@class FreightCar;
@class AbstractTableViewController;

@interface CarTypeChooserCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UILabel *checkField;
@property (retain, nonatomic) IBOutlet UILabel *carTypeName;
@property (retain, nonatomic) IBOutlet UILabel *carTypeDescription;
@end

// Popover for selecting a car type.
@interface CarTypeChooser : UITableViewController

// Reference back to the view controller listing all freight cars,
// which is responsible for changing the freight car.
@property (retain, nonatomic) IBOutlet AbstractTableViewController *myController;

// Index of item selected.
@property (retain, nonatomic) CarType *selectedCarType;

// Freight car being manipulated.  Used foremembering the current selection.
@property (retain, nonatomic) id keyObject;

// Value to mark as the currently enabled selection.
@property (retain, nonatomic) CarType *keyObjectSelection;

// List of all car types to display.
@property (retain, nonatomic) NSArray *allCarTypes;
@end
