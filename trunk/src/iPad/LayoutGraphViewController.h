//
//  UILayoutGraphViewController.h
//  SwitchList
//
//  Created by Robert Bowdidge on 2/16/13.
//
//

#import <UIKit/UIKit.h>

#import "LayoutGraphView.h"
#import "ScheduledTrain.h"
#import "TrainTableViewController.h"

@interface LayoutGraphViewController : UIViewController
// For initialization.
- (void) setCurrentTrain: (ScheduledTrain*) train;

@property(retain, nonatomic) IBOutlet LayoutGraphView *graphView;
@property(retain, nonatomic) IBOutlet ScheduledTrain *train;
@property(assign, nonatomic) IBOutlet TrainTableViewController* controller;
@end
