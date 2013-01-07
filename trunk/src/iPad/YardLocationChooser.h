//
//  YardLocationChooser.h
//  SwitchList
//
//  Created by Robert Bowdidge on 10/6/12.
//
//

#import <UIKit/UIKit.h>

@class Yard;
@class YardTableViewController;

@interface YardLocationCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UILabel *checkField;
@property (retain, nonatomic) IBOutlet UILabel *label;
@end

// Popover for selecting the station where the yard resides.
@interface YardLocationChooser : UITableViewController
@property (retain, nonatomic) IBOutlet YardTableViewController *controller;
@property (retain, nonatomic) Yard *selectedYard;
@property (nonatomic) int checkedValue;
// List of all stations (Place objects) in sorted order.
@property (retain, nonatomic) NSArray *allStations;
@end
