//
//  EditViewController.h
//  SwitchList
//
//  Created by Robert Bowdidge on 10/5/12.
//
//

#import <UIKit/UIKit.h>

#import "AbstractTableViewController.h"

// Abstract superclass for all UIViewControllers responsible
// for edit popovers.  Edit popovers are the popovers that allow editing
// most or all fields of a given object.
@interface EditViewController : UIViewController

// Commit any changes made in the edit popover.
- (IBAction) doSave: (id) sender;

// Reference back to the table controller for the list of industries.
@property (nonatomic, retain) AbstractTableViewController *myTableController;
@end
