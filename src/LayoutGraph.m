//
//  LayoutGraph.m
//  SwitchList
//
//  Created by bowdidge on 10/7/12.
//  Copyright 2012 Robert Bowdidge. All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
// 
// THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
// OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
// HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
// LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
// OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
// SUCH DAMAGE.

#import "LayoutGraph.h"

#import "EntireLayout.h"
#import "Place.h"
#import "ScheduledTrain.h"


// Container class for storing counts of the number of times trains went from
// station from to station to.
@interface AdjacencyPair : NSObject {
}
@property (nonatomic, retain) Place *from;
@property (nonatomic, retain) Place *to;
// Number of trains where the two stations were adjacent in the list of stops.
@property (nonatomic) int adjacentCount;
// Number of trains where the two stations both appeared in the same list of stops.
@property (nonatomic) int alongRouteCount;
@end

@implementation AdjacencyPair 
// Returns true if this pair represents trips between the stations from and to.
- (BOOL) isPairFrom: (Place*) from to:(Place*) to {
	if ((self.from == from && self.to == to) ||
		(self.from == to && self.to == from)) {
		return YES;
	}
	return NO;
}

@synthesize from;
@synthesize to;
@synthesize adjacentCount;
@synthesize alongRouteCount;
@end


// Object storing information on whether two stations are visited by the same train,
// and visited during consecutive stops.
@interface AdjacencyTable : NSObject {
}

@property (nonatomic, retain) NSMutableArray *allPairs;
@end


@implementation AdjacencyTable
- (id) init {
	[super init];
	self.allPairs = [NSMutableArray array];
	return self;
}

// Returns an existing AdjacencyPair between from and to, or nil if no pair exists.
- (AdjacencyPair*) containsFrom: (Place*) from to: (Place*) to {
	for (AdjacencyPair *pair in self.allPairs) {
		if ([pair isPairFrom: from to: to]) {
			return pair;
		}
	}
	return nil;
}

// Add a new adjacency pair.
- (void) addPair: (AdjacencyPair*) pair {
	[self.allPairs addObject: pair];
}
@synthesize allPairs;
@end		


@interface LayoutEdge()
@property (retain, nonatomic) LayoutNode *fromNode;
@property (retain, nonatomic) LayoutNode *toNode;

// Number of times this edge turned up in train stops.
@property (nonatomic) int occurrences;
@end


@implementation LayoutEdge 
- (id) initEdgeFrom: (LayoutNode*) start to: (LayoutNode*) end {
	[super init];
	// TODO(bowdidge): Make edge creation repeatable.
	if ([start.station.name compare: end.station.name] == NSOrderedAscending) {
		self.fromNode = start;
		self.toNode = end;
	} else {
		self.fromNode = end;
		self.toNode = start;
	}
	self.occurrences = 0;
	return self;
}

// Given one node on the edge, names the other pair.  Convenience function
// for dealing with bidirectional edges easier.
- (LayoutNode*) otherNode: (LayoutNode*) node {
	if (self.fromNode == node) {
		return self.toNode;
	} 
	return self.fromNode;
}

// Compares the two edges, and returns whether the current edge should be sorted before the other.
- (NSComparisonResult) compareByOccurrences: (LayoutEdge*) otherEdge {
	if (self.occurrences == otherEdge.occurrences) {
		// Compare by name after matching number of occurrences so things are repeatable.
		return [self.fromNode.station.name compare: otherEdge.fromNode.station.name];
	} else if (self.occurrences > otherEdge.occurrences) {
		return NSOrderedAscending;
	}
	return NSOrderedDescending;
}

- (NSString*) description {
	return [NSString stringWithFormat: @"Edge: %@ to %@ (%d)", [[self.fromNode station] name], [[self.toNode station] name], self.occurrences];
}

@synthesize fromNode;
@synthesize toNode;
@synthesize occurrences;
@end


@interface LayoutNode() 
// Array of all incoming and outgoing edges.
@property (retain, nonatomic) NSMutableArray *edges;

// Values used for doing walks on the graph.
@property (nonatomic) BOOL visited; 

// Number of times this node turned up in train stops.
@property (nonatomic) int occurrences;
@end


@implementation LayoutNode
// Constructs a new LayoutNode for the named station.
- (id) initWithPlace: (Place*) place {
	[super init];
	self.station = place;
	self.edges = [NSMutableArray array];
	self.occurrences = 0;
	return self;
}

// Compares the two nodes, and returns whether the current edge should be sorted before the other.
// TODO(bowdidge): Should sort by name.
- (NSComparisonResult) compareByOccurrences: (LayoutNode*) otherNode {
	if (self.occurrences == otherNode.occurrences) {
		return [self.station.name compare: otherNode.station.name];
	} else if (self.occurrences > otherNode.occurrences) {
		return NSOrderedAscending;
	}
	return NSOrderedDescending;
}

NSInteger compareByCount(id this, id that, void *context) {
	int thisCount = [this count];
	int thatCount = [that count];
	if (thisCount == thatCount) {
		return NSOrderedSame;
	} else if (thisCount < thatCount) {
		return NSOrderedAscending;
	} 
	return NSOrderedDescending;
}

// Returns a list of stations in reasonable order, suitable for display.
// TODO(bowdidge): Need to find how to present graph so branches are more obvious.
- (NSArray*) stationsInReasonableOrder {
	self.visited = YES;
	NSMutableArray *result = [NSMutableArray arrayWithObject: self];
	// TODO(bowdidge): Need to sort edges in repeatable way.
	NSLog(@"Edges for %@ are %@", self.station.name, [self.edges sortedArrayUsingSelector: @selector(compareByOccurrences:)]);
	
	NSMutableArray *edgeResults = [NSMutableArray array];
	for (LayoutEdge *edge in [self.edges sortedArrayUsingSelector: @selector(compareByOccurrences:)]) {
		LayoutNode *nextNode = [edge otherNode: self];
		if (!nextNode.visited) {
			[edgeResults addObject: [nextNode stationsInReasonableOrder]];
		}
	}
	// Insert the children from shortest to longest.  This allows local branches and the 
	// like to appear earlier.  Weighting by frequency of the train following an edge means
	// the common paths should become longer.
	for (NSArray *edgeResult in [edgeResults sortedArrayUsingFunction: &compareByCount context: nil]) {
		[result addObjectsFromArray: edgeResult];
	}
	return result;
}

- (NSString*) description {
	return [NSString stringWithFormat: @"LayoutNode: %@ %d edges", 
			[self.station name], [self.edges count]];
}

@synthesize station;
@synthesize edges;
@synthesize visited;
@synthesize occurrences;
@end


@interface LayoutGraph()
- (void) addEdgeFromStation: (LayoutNode*) previousStationNode toStation: (LayoutNode*) stationNode;

// Map of objectID for Place to LayoutNode for Place.
@property (retain, nonatomic) NSMutableDictionary *stationToNodeMap;

// Set of LayoutNode starting points in train.  Number of occurrences on the
// LayoutNode shows how many trains start at the station.
@property (retain, nonatomic) NSSet *starts;

// Pointer back to layout object.
@property (retain, nonatomic) EntireLayout *entireLayout;

@end

@implementation LayoutGraph
// Creates a new layout graph with the named layout and trains.
- (id) initWithLayout: (EntireLayout*) layout  {
	[super init];
	self.entireLayout = layout;
	NSArray *trains = [self.entireLayout allTrains];
	
	self.stationToNodeMap = [NSMutableDictionary dictionary];
	NSMutableSet *allStarts = [NSMutableSet set];
	AdjacencyTable *table = [[AdjacencyTable alloc] init];
	
	NSArray *allStations = [layout allStations];
	int stationCount = [allStations count];
	int i, j;
	for (i=0; i < stationCount; i++) {
		for (j=i; j < stationCount; j++) {
			Place *from = [allStations objectAtIndex: i];
			Place *to = [allStations objectAtIndex: j];
			if (from == to) continue;
			int adjacent = 0;
			int onSameRoute = 0;
			for (ScheduledTrain *train in trains) {
				NSArray *allStops = [train stationsInOrder];
				if ([allStops containsObject: from] && [allStops containsObject: to]) {
					onSameRoute++;
				}
				// TODO(bowdidge): Check for multiple.
				if ([allStops containsObject: from] && [allStops containsObject: to]) {
					int fromIndex = [allStops indexOfObject: from];
					int toIndex = [allStops indexOfObject: to];
					if (fromIndex == toIndex + 1 || fromIndex == toIndex - 1) {
						adjacent++;
					}
				}
			}
			
			if (adjacent || onSameRoute) {
				AdjacencyPair *pair = [table containsFrom: from to: to];
				if (!pair) {
					pair = [[[AdjacencyPair alloc] init] autorelease];
					pair.from = from;
					pair.to = to;
					[table addPair: pair];
				}
				if (adjacent) {
					pair.adjacentCount += adjacent;
				}
				if (onSameRoute) {
					pair.alongRouteCount += onSameRoute;
				}
			}
		}
	}
	
	for (ScheduledTrain *train in trains) {
		NSArray *allStops = [train stationsInOrder];
		LayoutNode *start = [self layoutNodeForStation: [[allStops objectAtIndex: 0] name]];
		if (![allStarts containsObject: start]) {
			[allStarts addObject: start];
		}
		start.occurrences++;
	}
	
	self.starts = allStarts;
	for (AdjacencyPair *pair in table.allPairs) {
		NSLog(@"Examining pair %@,%@ %d %d", [pair.from name], [pair.to name], pair.adjacentCount, pair.alongRouteCount);
		if (pair.adjacentCount == pair.alongRouteCount) {
			// NSLog(@"Adding edge from %@ to %@", [pair.from name], [pair.to name]);
			LayoutNode *fromNode = [self layoutNodeForStation: [pair.from name]];
			LayoutNode *toNode = [self layoutNodeForStation: [pair.to name]];
			
			[self addEdgeFromStation: fromNode toStation: toNode];
			LayoutEdge *edge = [self edgeFromStation: fromNode toStation:toNode];
			edge.occurrences = pair.adjacentCount;
		}
	}
	
	return self;
}

// Returns list of LayoutNodes in a reasonable display order.
- (NSArray*) stationsInReasonableOrder {
	for (LayoutNode *node in [self.stationToNodeMap allValues]) {
		node.visited = NO;
	}
	NSMutableArray *result = [NSMutableArray array];
	for (LayoutNode *node in [[self.starts allObjects] sortedArrayUsingSelector: @selector(compareByOccurrences:)]) {
		if (node.visited == NO) {
			[result addObjectsFromArray: [node stationsInReasonableOrder]];
		}
	}
	return result;
}

// Adds a new edge between two existing LayoutNode objects.
- (void) addEdgeFromStation: (LayoutNode*) previousStationNode toStation: (LayoutNode*) stationNode {
	// Already existing edge?
	for (LayoutEdge *edge in [previousStationNode edges]) {
		if ([edge toNode] == stationNode || [edge fromNode] == stationNode) {
			return;
		}
	}
	LayoutEdge *edge = [[LayoutEdge alloc] initEdgeFrom: previousStationNode to: stationNode];
	[previousStationNode.edges addObject: edge];
	[stationNode.edges addObject: edge];
	// NSLog(@"Adding edge %@", edge);
	// NSLog(@"Edges on %@: %@", stationNode, edge);
}

// Returns a LayoutEdge between the two LayoutNodes if one exists, or nil if none exists.
- (LayoutEdge*) edgeFromStation: (LayoutNode*) previousStationNode toStation: (LayoutNode*) stationNode {
	// NSLog(@"Edges for %@: %@", stationNode, [stationNode edges]);
	for (LayoutEdge *edge in [previousStationNode edges]) {
		if ([edge toNode] == stationNode || [edge fromNode] == stationNode) {
			return edge;
		}
	}
	return nil;
}

// Returns YES if an edge exists between layout nodes for the stations with the given names.
// For testing only.
- (BOOL) edgeExistsFromStationName: (NSString*) previousName toStationName: (NSString*) stationName {
	return [self edgeFromStation: [self layoutNodeForStation: previousName]
					   toStation: [self layoutNodeForStation: stationName]] != nil;
}
	
- (LayoutNode*) layoutNodeForPlace: (Place*)  station {
	LayoutNode *stationNode = [self.stationToNodeMap objectForKey: [station objectID]];
	if (!stationNode) {
		stationNode = [[LayoutNode alloc] initWithPlace: station];
		[self.stationToNodeMap setObject: stationNode forKey: [station objectID]];
	}	
	return stationNode;
}

// Returns the LayoutNode for the named station, or nil if no LayoutNode yet exists.
- (LayoutNode*) layoutNodeForStation: (NSString *) stationName {
	Place *p = [self.entireLayout stationWithName: stationName];
	if (!p) {
		NSLog(@"No such station %@", stationName);
		return nil;
	}
	return [self layoutNodeForPlace: p];
}

@synthesize stationToNodeMap;
@synthesize starts;
@synthesize entireLayout;
@end
