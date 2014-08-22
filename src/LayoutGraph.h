//
//  LayoutGraph.h
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

#import <Foundation/Foundation.h>

// Classes used for inferring the graph of reachable stations on the layout
// from the routes of all trains on the layout.  This graph can be used
// for simpler UIs such as adding the stops for new trains via a touch
// interface, presentation of current locations of cars, etc.

@class EntireLayout;
@class LayoutNode;
@class Place;

// Bidirectional edge from/to.
@interface LayoutEdge : NSObject {
	LayoutNode *fromNode;
	LayoutNode *toNode;
	int occurrences;
}
@end

// Node representing a station on the layout.
@interface LayoutNode : NSObject {
	Place *station;
	
	// Array of all incoming and outgoing edges.
	NSMutableArray *edges;
	
	// Values used for doing walks on the graph.
	BOOL visited; 
	
	// Number of times this node turned up in train stops.
	int occurrences;
}
- (id) initWithPlace: (Place*) place;

// Station represented by node.
@property (retain, nonatomic) Place *station;
@end


// Object representing entire graph for layout.
@interface LayoutGraph : NSObject {
	// Map of objectID for Place to LayoutNode for Place.
	NSMutableDictionary *stationToNodeMap;
	
	// Set of LayoutNode starting points in train.  Number of occurrences on the
	// LayoutNode shows how many trains start at the station.
	NSSet *starts;
	
	// Pointer back to layout object.
	EntireLayout *entireLayout;
	
}

// Create the layout with all existing trains on the layout.
- (id) initWithLayout: (EntireLayout*) layout;

// Lookups on graph.
- (LayoutNode*) layoutNodeForStation: (NSString*) stationName;
- (LayoutEdge*) edgeFromStation: (LayoutNode*) previousStationNode toStation: (LayoutNode*) stationNode;
- (BOOL) edgeExistsFromStationName: (NSString*) previousName toStationName: (NSString*) stationName;

- (NSArray*) stationsInReasonableOrder;
@end
