//
//  SwitchRouteDialogController.m
//  SwitchList
//
//
//  Created by Robert Bowdidge on 7/23/07.
//
// Copyright (c)2007 Robert Bowdidge,
// All rights reserved.
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

#import "SwitchRouteDialogController.h"
#import "Place.h"

NSString *DragTownsType = @"DragTownsType";

// Controls the sheet used for selecting the stops made by a particular train.

@implementation SwitchRouteDialogController
- (void) awakeFromNib {
	[routeTableView_ registerForDraggedTypes: [NSArray arrayWithObject: DragTownsType]];
	routeList_ = [[NSMutableArray alloc] init];
	[routeTableView_ setDataSource: self];
	[routeTableView_ setDraggingSourceOperationMask: NSDragOperationMove forLocal: YES];
	[sheetTitle_ setStringValue: [NSString stringWithFormat: @"Stations to Visit:", [trainBeingChanged_ name]]];
	[warningText_ setStringValue: @""];
	trainBeingChanged_ = nil;
	entireLayout_ = nil;
	[removeButton_ setEnabled: NO];
}

- (void) dealloc {
	[routeList_ release];
	[trainBeingChanged_ release];
	[entireLayout_ release];
	[super dealloc];
}

// Method for passing in info about what we're editing.
- (void) setTrain: (ScheduledTrain*) tr layout: (EntireLayout*) layout{
	[routeList_ release];
	routeList_ = [NSMutableArray arrayWithArray: [tr stationStopStrings]];
	[routeList_ retain];
	
	[trainBeingChanged_ release];
	trainBeingChanged_ = [tr retain];
	
	[entireLayout_ release];
	entireLayout_ = [layout retain];
	
	[sheetTitle_ setStringValue: [NSString stringWithFormat: @"Stations for \"%@\" to Visit:", [trainBeingChanged_ name]]];
}



- (void) updateRouteList {
	BOOL hasProblem = NO;
	NSString *warning = @"";
	if ([routeList_ count] < 1) {
		warning = @"A train needs at least one stop.";
		hasProblem = YES;
	} else {
		if ([[entireLayout_ stationWithName: [routeList_ lastObject]] hasYard] == NO) {
			warning = @"A train must end in a town with a yard.";
			hasProblem = YES;
		}
		if ([[entireLayout_ stationWithName: [routeList_ objectAtIndex: 0]] hasYard] == NO) {
			warning =  @"A train must begin in a town with a yard.";
			hasProblem = YES;
		}
	}
	
	if (hasProblem == YES) {
		[okButton_ setEnabled: NO];
	} else {
		[okButton_ setEnabled: YES];
	}
	[warningText_ setStringValue: warning];
	[routeTableView_ reloadData];
	
}

- (IBAction) update: (id) sender {
	NSEntityDescription *ent = [NSEntityDescription entityForName: @"Place" inManagedObjectContext: [sender managedObjectContext]];
	NSFetchRequest * req2  = [[[NSFetchRequest alloc] init] autorelease];
	[req2 setEntity: ent];
	NSError *error;
	NSArray *townList = [NSMutableArray arrayWithArray: [[sender managedObjectContext] executeFetchRequest: req2 error:&error]];
	NSMutableArray *townNameList = [NSMutableArray array];
	NSEnumerator *e = [townList objectEnumerator];
	Place *pl;
	while ((pl = [e nextObject]) != nil) {
		if ([pl isOffline] == NO) {
			[townNameList addObject: [pl name]];
		}
	}
	[townNameList sortUsingSelector: @selector(compare:)];
	townList_ = [townNameList retain];
	
	[townTableView_ setDataSource: self];
	[self updateRouteList];

}

- (IBAction) done: (id) sender {
	[trainBeingChanged_ setStationStopStrings: routeList_];
	[NSApp endSheet: switchRouteDialogWindow_];
}

- (IBAction) cancel: (id) sender {
	[NSApp endSheet: switchRouteDialogWindow_];
}

- (IBAction) removeTownInRoute: (id) sender {
	NSIndexSet *townsToRemove = [routeTableView_ selectedRowIndexes];
	int itemsRemoved = 0;
    unsigned currentIndex = [townsToRemove firstIndex];
    while (currentIndex != NSNotFound) {
		[routeList_ removeObjectAtIndex: currentIndex + itemsRemoved];
		itemsRemoved++;
        currentIndex = [townsToRemove indexGreaterThanIndex:currentIndex];
    }

	[removeButton_ setEnabled: NO];
	[routeTableView_ deselectAll: self];
	[self updateRouteList];
}

- (IBAction) addTownToRoute: (id) sender {
	NSIndexSet *townsToAdd = [townTableView_ selectedRowIndexes];
    unsigned currentIndex = [townsToAdd firstIndex];
    while (currentIndex != NSNotFound) {
		[routeList_ addObject: [townList_ objectAtIndex: currentIndex]];
        currentIndex = [townsToAdd indexGreaterThanIndex:currentIndex];
    }
	[self updateRouteList];

}

// Whenever selection changes, make sure the remove button is enabled or disabled as necessary.
- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
	if (tableView == routeTableView_) {
		[removeButton_ setEnabled: YES];
	}
	return YES;
}

- (int)numberOfRowsInTableView:(NSTableView *)tableView {
	if (tableView == townTableView_) {
		return [townList_ count];
	}
	return [routeList_ count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row {
	NSString *townName;
	if (tableView == townTableView_) {
		if ([townList_ count] <= row) {
			return @"???"; // out of bounds
		}
		townName = [townList_ objectAtIndex: row];
	} else if (tableView == routeTableView_) {
		townName = [routeList_ objectAtIndex: row];
	} else {
		return @"???";
	}

	Place *town = [entireLayout_ stationWithName: townName];

	NSMutableDictionary *attrDict = [NSMutableDictionary dictionary];
	if ([town hasYard]) {
		// Make bold.
		[attrDict setObject: [ NSFont boldSystemFontOfSize: 14]
					 forKey: NSFontAttributeName];
	}
	NSAttributedString *str = [[NSAttributedString alloc] initWithString: townName attributes: attrDict];
	return [str autorelease];
}

// Indicates drag was from route table.
NSString *ROUTE_TOKEN = @",route";

- (BOOL)tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard {
	NSArray *tableList = nil;
	if (tv == townTableView_) {
		tableList = townList_;
	} else if (tv == routeTableView_) {
		tableList = routeList_;
	}
	[pboard declareTypes: [NSArray arrayWithObject: DragTownsType] owner: self];
	NSMutableArray *townNames = [NSMutableArray array];
	
	// TODO(bowdidge): Hack.  Need better way to tell where drag comes from.
	if (tv == routeTableView_) {
		[townNames addObject: ROUTE_TOKEN];
		[townNames addObject: [NSNumber numberWithInt: [rowIndexes firstIndex]]];
	}

	unsigned int current = [rowIndexes firstIndex];
	while (current != NSNotFound) {
		[townNames addObject: [tableList objectAtIndex: current]];
		current = [rowIndexes indexGreaterThanIndex: current];
	}
	
	[pboard setData: [NSKeyedArchiver archivedDataWithRootObject:townNames] forType: DragTownsType];
	return YES;
}

- (NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)op {
	return NSDragOperationMove;
}

- (BOOL)tableView:(NSTableView*)tv acceptDrop:(id <NSDraggingInfo>)info row:(int)row dropOperation:(NSTableViewDropOperation)op {
	if (tv != routeTableView_) {
		// Only route table can be changed.
		return NO;
	}
	
    NSPasteboard* pboard = [info draggingPasteboard];
	NSData *data  = [pboard dataForType: DragTownsType];
	NSMutableArray *townNames = [NSMutableArray arrayWithArray: [NSKeyedUnarchiver unarchiveObjectWithData: data]];
	
	int insertPoint = row;
	
	// TODO(bowdidge) Hack to detect whether the drag is from the route table.  Create a new type to pass
	// this fact.
	if ([[townNames objectAtIndex: 0] isEqualToString: ROUTE_TOKEN]) {
		int rowToRemove = [[townNames objectAtIndex: 1] intValue];
		[townNames removeObjectAtIndex: 1];
		[townNames removeObjectAtIndex: 0];
		[routeList_ removeObjectAtIndex: rowToRemove];
		if (rowToRemove < row) {
			insertPoint--;
		}
	}
	if (op == NSTableViewDropOn) {
		[routeList_ removeObjectAtIndex: row];
	}

	for (NSString *name in townNames) {
		[routeList_ insertObject: name atIndex: insertPoint++];
	}
	[self updateRouteList];
	return YES;
}

@end
