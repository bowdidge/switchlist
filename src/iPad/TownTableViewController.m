//
//  TownTableViewController.m
//  SwitchList for iPad
//
//  Created by Robert Bowdidge on 9/8/12.
//  Copyright (c) 2012 Robert Bowdidge. All rights reserved.
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

#import "TownTableViewController.h"

#import "AppDelegate.h"
#import "AppNavigationController.h"
#import "EntireLayout.h"
#import "Place.h"
#import "SwitchListColors.h"
#import "TownTableCell.h"

@interface TownTableViewController ()
// Cached data on layout's towns, sorted by section to show.
@property (nonatomic, retain) NSArray *townsOnLayout;
@property (nonatomic, retain) NSArray *townsInStaging;
@property (nonatomic, retain) NSArray *townsOffline;

@end

@implementation TownTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self regenerateTableData];
    self.storyboardName = @"TownTable";
    self.title = @"Towns";
    
    UIBarButtonItem *addButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemAdd target:self action:@selector(addTown:)];
    
    self.navigationItem.rightBarButtonItem = addButtonItem;
}

- (void) addTown: (id) sender {
    AppDelegate *myAppDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    EntireLayout *entireLayout = myAppDelegate.entireLayout;
    
    Place *town = [entireLayout createTownWithName: @"Atomic City"];
    [town setIsOnLayout];
    
    // Fragile way to open object - should instead search list.
    [self regenerateTableData];
    [self.tableView reloadData];
    NSInteger currentIndex = [self.townsOnLayout indexOfObject: town];
    NSUInteger indexArr[] = {0, currentIndex};
    self.expandedCellPath = [NSIndexPath indexPathWithIndexes: indexArr length: 2];
    [self.tableView reloadRowsAtIndexPaths: [NSArray arrayWithObjects: self.expandedCellPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
}

// Gathers town data from the entire layout again, reloading if necessary.
- (void) regenerateTableData {
    AppDelegate *myAppDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    EntireLayout *myLayout = myAppDelegate.entireLayout;
    NSMutableArray *offlineTowns = [NSMutableArray array];
    NSMutableArray *stagingTowns = [NSMutableArray array];
    NSMutableArray *onLayoutTowns = [NSMutableArray array];
    for (Place *p in [myLayout allStations]) {
        if ([p isOffline]) {
            [offlineTowns addObject: p];
        } else if ([p isStaging]) {
            [stagingTowns addObject: p];
        } else {
            [onLayoutTowns addObject: p];
        }
    }
    self.townsOffline = [offlineTowns sortedArrayUsingSelector: @selector(compareNames:)];
    self.townsInStaging = [stagingTowns sortedArrayUsingSelector: @selector(compareNames:)];
    self.townsOnLayout = [onLayoutTowns sortedArrayUsingSelector: @selector(compareNames:)];
}

- (void) regenerateTableDataForChangeInPlace: (Place*) place {
    [self regenerateTableData];
    // Regenerate the selection.
    if (self.expandedCellPath) {
        NSInteger placeIndex;
        if ((placeIndex =[self.townsOnLayout indexOfObject: place]) != NSNotFound) {
            NSUInteger indexArr[] = {0, placeIndex};
            self.expandedCellPath = [NSIndexPath indexPathWithIndexes: indexArr length: 2];
        } else if ((placeIndex = [self.townsInStaging indexOfObject: place]) != NSNotFound) {
            NSUInteger indexArr[] = {1, placeIndex};
            self.expandedCellPath = [NSIndexPath indexPathWithIndexes: indexArr length: 2];
        } else if ((placeIndex = [self.townsOffline indexOfObject: place]) != NSNotFound) {
            NSUInteger indexArr[] = {2, placeIndex};
            self.expandedCellPath = [NSIndexPath indexPathWithIndexes: indexArr length: 2];
        } else {
            NSLog(@"Can't find %@ in data in regenerateTableDataForChangeInPlace:", place.name);
        }
    }
}

- (void)didReceiveMemoryWarning
{
    self.townsOnLayout = nil;
    self.townsInStaging = nil;
    self.townsOffline = nil;
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

const int TOWNS_ON_LAYOUT_SECTION = 0;
const int TOWNS_IN_STAGING_SECTION = 1;
const int TOWNS_OFF_LINE_SECTION = 2;

// Returns section name for table.
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == TOWNS_ON_LAYOUT_SECTION) {
        return @"Towns on Layout";
    } else if (section == TOWNS_IN_STAGING_SECTION) {
        return @"Towns in Staging";
    } else {
        return @"Imaginary Towns";
    }
}

// Returns the number of sections in the towns table.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Separate sections for online, staging, and offline towns.
    return 3;
}

// Returns the number of rows in the specified towns section.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!self.townsOnLayout) {
        [self regenerateTableData];
    }
    if (section == TOWNS_ON_LAYOUT_SECTION) {
        return self.townsOnLayout.count;
    } else if (section == TOWNS_IN_STAGING_SECTION) {
        return self.townsInStaging.count;
    }
    return self.townsOffline.count;
}

// Returns place object represented in table view at the given row and section.
- (Place*) townAtIndexPath: (NSIndexPath*) indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == TOWNS_ON_LAYOUT_SECTION) {
        return [self.townsOnLayout objectAtIndex: row];
    } else if (section == TOWNS_IN_STAGING_SECTION) {
        return [self.townsInStaging objectAtIndex: row];
    } else {
        return [self.townsOffline objectAtIndex: row];
    }
    return nil;
}

// Returns contents of the cell for the specified row and section.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.townsOnLayout) {
        [self regenerateTableData];
    }
    
    NSString *cellIdentifier;
    if ([indexPath compare: self.expandedCellPath] == NSOrderedSame) {
        cellIdentifier = @"extendedTownCell";
    } else {
        cellIdentifier = @"townCell";
    }
    TownTableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[TownTableCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:cellIdentifier];
        [cell autorelease];
    }
    
    [cell fillInAsTown: [self townAtIndexPath: indexPath]];
    cell.myController = self;
    return cell;
}

// Gets access to the row just before drawing for doing color banding of rows.
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row % 2 == 1) {
        // Alternate colors get a slight gray.
        cell.backgroundColor = [SwitchListColors switchListLightBeige];
    }
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath compare: self.expandedCellPath] == NSOrderedSame) {
        return 120.0;
    }
    return 80.0;
}

// Handles presses on the table.  When a selection is made in the table, we show a popover for editing the object.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath compare: self.expandedCellPath] == NSOrderedSame) {
        [self.tableView beginUpdates];
        self.expandedCellPath = nil;
        [self.tableView endUpdates];
        [self.tableView reloadRowsAtIndexPaths: [NSArray arrayWithObjects: indexPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
        return;
    }
    
    Place *myTown = [self townAtIndexPath: indexPath];
    if (!myTown) {
        // Create a new industry.
    }
    
    [self.tableView beginUpdates];
    NSIndexPath *oldPath = [self.expandedCellPath retain];
    self.expandedCellPath = indexPath;
    [self.tableView endUpdates];
    [self.tableView reloadRowsAtIndexPaths: [NSArray arrayWithObjects: indexPath, oldPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
    [oldPath release];
}

// Handles editing actions on table - delete or insert.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Place *townToDelete = [self townAtIndexPath: indexPath];
        [[townToDelete managedObjectContext] deleteObject: townToDelete];
        [self regenerateTableData];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

@synthesize townsOnLayout;
@synthesize townsInStaging;
@synthesize townsOffline;
@end
