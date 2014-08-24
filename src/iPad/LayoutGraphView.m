//
//  LayoutGraphView.m
//  SwitchList
//
//  Created by Robert Bowdidge on 2/16/13.
//
//

// TODO(bowdidge):
// Number the items as we touch each, and display a number on the graph.
// Arcs.
//
// Algorithm:
// On touchBegan:
//   if a node is selected,
//     * get into route building mode.
//     * the node under initial node gets added as node 0.
//     * change appearance of node 0 to show it's in route and has number 1.
//     * cause redraw.
// On touchMoved:
//   if not route building mode,
//     ignore.
//   if not on top of node:
//     set current location as end point.
//     draw bezier curve from last node to here.
//     clear current lingering node.
//   if on top of node:
//     if we're already waiting on a node, and it's this one, do nothing.
//     if it's different, set timer for 1 sec to trigger next station.
//
// On timer fire:
//     add node to list of nodes.
//     cause redraw.

#import "LayoutGraphView.h"

#import "AppDelegate.h"
#import "LayoutGraph.h"
#import "Place.h"
#import "ScheduledTrain.h"

const int STATION_SEPARATOR_Y = 70;
const int STATION_START_Y = 100;
const int STATION_HEIGHT = 50;
const int STATION_LEFT = 50;
const int STATION_WIDTH = 160;

// Seconds before a touch on a station is interpreted as the train stops at that station.
const float MAX_LINGER_INTERVAL = 0.6;

@implementation LayoutGraphView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) return nil;
    
    lastStationIndexTouched_ = -1;
    lingering_station_ = -1;
    performing_drag_ = NO;

    self.backgroundColor = [UIColor redColor];

    self.currentSelectedStops = [NSMutableArray array];
    graph_initialized_ = NO;
    
    return self;
}

- (void) dealloc {
    [super dealloc];
}

- (void) setCurrentTrain:(ScheduledTrain *)train {
    NSArray* placeStops = [train stationsInOrder];
    [self initializeGraphIfNeeded];
    NSMutableArray *layoutNodeStops = [NSMutableArray array];
    for (Place *station in placeStops) {
        LayoutNode *node = [layout_graph_ layoutNodeForStation: [station name]];
        [layoutNodeStops addObject: node];
    }
    self.currentSelectedStops = layoutNodeStops;
    [self setNeedsDisplay];
}

// Build up the graph of routes between stations, and come up with a decent ordering
// for the stations on the screen.
// Creates layout_graph_ as well as a list of all stations in preferred drawing order.
- (void) initializeGraphIfNeeded {
    if (graph_initialized_) return;
    graph_initialized_ = YES;
    AppDelegate *myAppDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    layout_graph_ = [[LayoutGraph alloc] initWithLayout: myAppDelegate.entireLayout];
    all_stations_display_order_ = [[layout_graph_ stationsInReasonableOrder] retain];
}

// Draws the curved line between two nodes of the graph.
- (void) drawLineX: (float) fromX Y: (float) fromY toX: (float) toX Y: (float) toY {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, 0, 0, 0, 1.0);
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineWidth = 3.0;
    
    CGPoint first =  CGPointMake(fromX, fromY);
    CGPoint second = CGPointMake (toX, toY);
    // Push curves to the right 300 pixels when drawing a line up the screen,
    // and 150 pixels when going down the screen.
    float offset = 300.0;
    if (fromY - toY < 0) offset = 150.0;
    CGPoint firstControl = CGPointMake(fromX + offset, fromY);
    CGPoint secondControl = CGPointMake(toX + offset, toY);
    
    [path moveToPoint: first];
    [path addCurveToPoint: second
            controlPoint1: firstControl
            controlPoint2: secondControl];
    [path stroke];
}

// Redraws the view.
- (void)drawRect:(CGRect)rect {
    [self initializeGraphIfNeeded];
    CGContextRef context = UIGraphicsGetCurrentContext();

    if ([self.currentSelectedStops count] > 1) {
        LayoutNode *prevNode = [self.currentSelectedStops objectAtIndex: 0];
        int currentIndex = 1;
        while (currentIndex < [self.currentSelectedStops count]) {
            LayoutNode *currNode = [self.currentSelectedStops objectAtIndex: currentIndex];
            NSInteger prevPos = [all_stations_display_order_ indexOfObject: prevNode];
            NSInteger currPos = [all_stations_display_order_ indexOfObject: currNode];
            // Draw line from prev to current.
            [self drawLineX: STATION_LEFT + STATION_WIDTH / 2 Y: prevPos * STATION_SEPARATOR_Y + STATION_START_Y
                        toX: STATION_LEFT + STATION_WIDTH / 2 Y: currPos * STATION_SEPARATOR_Y + STATION_START_Y];
            prevNode = currNode;
            currentIndex++;
        }
    }

    if (performing_drag_) {
        // draw line.
        [self drawLineX: STATION_LEFT + STATION_WIDTH / 2 Y: lastStationIndexTouched_ * STATION_SEPARATOR_Y + STATION_START_Y
                    toX: current_drag_point_.x Y: current_drag_point_.y];
    }

    float y = STATION_START_Y;
    int ct = 0;
    for (LayoutNode *stationNode in all_stations_display_order_) {
        if (lastStationIndexTouched_ == ct) {
            CGContextSetRGBFillColor(context, 0.5, 0.5, 0.5, 1.0);
        } else if (lingering_station_ == ct) {
            CGContextSetRGBFillColor(context, 0.6, 0.5, 0.5, 1.0);
        } else {
            CGContextSetRGBFillColor(context, 0.6, 0.0, 0.0, 1.0);
        }
        CGContextFillEllipseInRect(context, CGRectMake(STATION_LEFT, y - STATION_HEIGHT/2, STATION_WIDTH, STATION_HEIGHT));
        
        CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 1.0);
   [[stationNode.station name] drawInRect: CGRectMake(STATION_SEPARATOR_Y, y-15.0, 120.0, 30.0)
                 withFont: [UIFont boldSystemFontOfSize: 13.0]
            lineBreakMode: UILineBreakModeClip alignment: UITextAlignmentCenter];
        y += STATION_SEPARATOR_Y;
        ct++;
    }
}

- (int) isTouchedNodeX: (float) x Y: (float) y {
    int yIndex = (y - 75.0) / STATION_SEPARATOR_Y;
    int yOffset = (y - 75.0) - (yIndex * STATION_SEPARATOR_Y);
    if ((x > 50 && x < 210) &&
        (yOffset > 0 && yOffset < 50)) {
        if (yIndex < [all_stations_display_order_ count]) {
            return yIndex;
        }
        // fall through and fail if we're beyond range of stations.
    }
    return -1;
}

// Dispatches touches back to the main view to change view to the witchlist of interest.
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchPoint = [touch locationInView: self];


    lastStationIndexTouched_ = [self isTouchedNodeX: touchPoint.x Y: touchPoint.y];

    if (lastStationIndexTouched_ != -1) {
        NSLog(@"lastTouch %d", lastStationIndexTouched_);
        self.currentSelectedStops = [NSMutableArray arrayWithObject: [all_stations_display_order_ objectAtIndex: lastStationIndexTouched_]];
        LayoutNode *n = [all_stations_display_order_ objectAtIndex: lastStationIndexTouched_];
        NSLog(@"Start new route at %@", [n.station name]);
    }
}

// Handles the timer indicating that a touch lingered long enough at a station to be considered
// a stop.
- (void) touchesStation: (NSTimer*) timer {
    NSDictionary *userDict = [timer userInfo];
    LayoutNode *currStationNode = [userDict objectForKey: @"node"];
    int nodeTouched = [[userDict objectForKey: @"nodeTouched"] intValue];
    [self.currentSelectedStops addObject: currStationNode];
    NSLog(@"Appending to route: %@", currStationNode.station.name);
    lastStationIndexTouched_ = nodeTouched;
    [self setNeedsDisplay];
}

// Handles movement of touches.
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchPoint = [touch locationInView: self];

    // Not a route selection.
    if (lastStationIndexTouched_ == -1) return;
    
    performing_drag_ = YES;
    current_drag_point_ = touchPoint;

    NSLog(@"Move to %f,%f", touchPoint.x, touchPoint.y);
    int isNodeTouched = [self isTouchedNodeX: touchPoint.x Y: touchPoint.y];
    if (isNodeTouched == -1) {
        // In between stations.
        lingering_station_ = -1;
        NSLog(@"Releasing timer");
        [current_linger_timer_ invalidate];
        [current_linger_timer_ release];
        current_linger_timer_ = nil;
    } else {
        // Avoid dups.
        LayoutNode *currNode = [all_stations_display_order_ objectAtIndex: isNodeTouched];
        LayoutNode *prevNode = [self.currentSelectedStops lastObject];
        
        NSLog(@"Station is %@, last is %@", currNode.station.name,prevNode.station.name);
        // If we're not on the station we started on, and we're not on one that we're waiting for a linger on.
        if (currNode != prevNode && isNodeTouched != lingering_station_) {
            // TODO(bowdidge): Consider animating to show that a cell's been touched.
            // Wait a length of time before registering.
            if (lingering_station_ != isNodeTouched) {
                lingering_station_ = isNodeTouched;
                NSLog(@"Setting timer!");
                [current_linger_timer_ invalidate];
                [current_linger_timer_ release];
                NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys: currNode, @"node",
                                          [NSNumber numberWithInt: isNodeTouched], @"nodeTouched", nil];
                current_linger_timer_ = [[NSTimer scheduledTimerWithTimeInterval: MAX_LINGER_INTERVAL target:self selector:@selector(touchesStation:) userInfo:userInfo repeats:NO] retain];
            } else {
                // Already have timer, most likely.
            }
        }
    }
    [self setNeedsDisplay];
}

// Handles lift.
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    performing_drag_ = NO;
    lastStationIndexTouched_ = -1;
    NSLog(@"Route done!");
    for (LayoutNode *node in self.currentSelectedStops) {
        NSLog(@"Station: %@", node.station.name);
    }
    // Lingering?  Count last location as a valid stop.
    if (current_linger_timer_) {
        [current_linger_timer_ fire];
    }
    [current_linger_timer_ invalidate];
    [current_linger_timer_ release];
    current_linger_timer_ = nil;
    lingering_station_ = -1;
    lastStationIndexTouched_ = -1;
    performing_drag_ = NO;
    current_drag_point_ = CGPointMake(0.0,0.0);
    
    [self setNeedsDisplay];
    
    
    // Animation for locking down view?
}


@end
