//
//  UILayoutGraphViewController.m
//  SwitchList
//
//  Created by Robert Bowdidge on 2/16/13.
//
//

#import "LayoutGraphViewController.h"

@implementation LayoutGraphViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.title = [NSString stringWithFormat: @"Set route for %@", self.train.name];
    [self.graphView setCurrentTrain: self.train];
}

// For initialization.
- (void) setCurrentTrain: (ScheduledTrain*) train {
    self.train = train;
}
@end
