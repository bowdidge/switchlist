//
//  YardLocationChooser.h
//  SwitchList
//
//  Created by Robert Bowdidge on 10/6/12.
//
//

#import <UIKit/UIKit.h>

@class Place;
@class Yard;
@class YardTableViewController;

@interface PlaceChooserCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UILabel *checkField;
@property (retain, nonatomic) IBOutlet UILabel *label;
@end

// Popover for selecting the station where the yard resides.
@interface PlaceChooser : UITableViewController

@property (retain, nonatomic) IBOutlet YardTableViewController *controller;

// Object having its place set.
@property (retain, nonatomic) id keyObject;

// Place currently holding object.
@property (retain, nonatomic) Place *keyObjectSelection;

// Location chosen by user.  Only valid when closing.
@property (retain, nonatomic) Place *selectedPlace;

// List of all stations (Place objects) in sorted order.
@property (retain, nonatomic) NSArray *allStations;
@end
