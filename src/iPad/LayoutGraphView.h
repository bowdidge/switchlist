//
//  LayoutGraphView.h
//  SwitchList
//
//  Created by Robert Bowdidge on 2/16/13.
//
//

#import <UIKit/UIKit.h>

@class LayoutGraph;
@class ScheduledTrain;

@protocol LayoutGraphViewDelegate
- (void) trainDidChangeRoute: (ScheduledTrain*) train;
@end

@interface LayoutGraphView : UIView {
    // True if a drag is currently being done to set a route.
    BOOL performing_drag_;
    // Current point for finger.
    CGPoint current_drag_point_;

    LayoutGraph *layout_graph_;
    NSArray *all_stations_display_order_;
    BOOL graph_initialized_;
    
    // Index of last station that was officially a stop.  Lines draw from this station.
    int lastStationIndexTouched_;
    // Index of current station that we think we're lingering on.  Used to invalidate the
    // timer if the user moves away from this station.
    int lingering_station_;
    // Timer waiting for interval to confirm user wants current station to be on list of stops.
    NSTimer *current_linger_timer_;
}
- (void) setCurrentTrain: (ScheduledTrain*) train;

@property (nonatomic, retain) ScheduledTrain *train;
// List of LayoutNode objects representing stations visited so far, in visit order.
@property (nonatomic, retain) NSMutableArray *currentSelectedStops;

@property (nonatomic, retain) id<LayoutGraphViewDelegate> delegate;
@end

