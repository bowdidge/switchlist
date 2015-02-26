//
//  IndustryChooser.h
//  SwitchList
//
//  Created by Robert Bowdidge on 1/7/13.
//
//

#import <UIKit/UIKit.h>

@class InduYard;
@class AbstractTableViewController;

@interface IndustryChooserCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UILabel *checkField;
@property (retain, nonatomic) IBOutlet UILabel *label;
@end

// Popover for selecting a car type.
@interface IndustryChooser : UITableViewController

// Reference back to the view controller listing all freight cars,
// which is responsible for changing the freight car.
@property (retain, nonatomic) IBOutlet AbstractTableViewController *myController;

// Item selected in chooser.
@property (retain, nonatomic) InduYard *selectedIndustry;

// Freight car being manipulated.  Used for remembering the current selection.
@property (retain, nonatomic) id keyObject;

// Value to mark as the currently enabled selection.
@property (retain, nonatomic) InduYard *keyObjectSelection;

// List of all car types to display.
@property (retain, nonatomic) NSArray *allIndustries;

// Name of field being set.  For distinguishing between source and destination.
@property (retain, nonatomic) NSString *fieldToSet;

// Show yards as well as industries.
@property (nonatomic) BOOL showYards;

@end