//
//  IndustryEditViewController.h
//  SwitchList
//
//  Created by Robert Bowdidge on 9/22/12.
//
//

#import <UIKit/UIKit.h>

@class Industry
;
@class IndustryTableViewController;

@interface IndustryEditViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
- (IBAction) doPressTownLocationButton: (id) sender;
- (IBAction) doPressDivisionButton: (id) sender;
- (IBAction) doSave: (id) sender;

@property (nonatomic, retain) Industry *myIndustry;
// Controller for small edit window once car has been selected.
@property (nonatomic, retain) UIPopoverController *myPopoverController;
// Reference back to the table controller for the list of industries.
@property (nonatomic, retain) IndustryTableViewController *myTableController;

@end
