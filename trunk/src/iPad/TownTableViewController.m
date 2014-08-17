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
#import "TownEditViewController.h"
#import "TownTableCell.h"

@interface TownTableViewController ()
// Cached data on layout's towns, sorted by section to show.
@property (nonatomic, retain) NSArray *townsOnLayout;
@property (nonatomic, retain) NSArray *townsInStaging;
@property (nonatomic, retain) NSArray *townsOffline;

@end

@implementation TownTableViewController

// Gathers freight car data from the entire layout again, reloading if necessary.
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

- (void)viewDidLoad {
    [super viewDidLoad];
    [self regenerateTableData];
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

// Returns section name for table.
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0) {
        return @"Towns on Layout";
    } else if (section == 1) {
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
    if (section == 0) {
        return self.townsOnLayout.count;
    } else if (section == 1) {
        return self.townsInStaging.count;
    }
    // Imaginary +1 for"add another"
    return self.townsOffline.count + 1;
}

// Returns place object represented in table view at the given row and section.
- (Place*) townAtIndexPath: (NSIndexPath*) indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0) {
        return [self.townsOnLayout objectAtIndex: row];
    } else if (section == 1) {
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
    static NSString *CellIdentifier = @"townCell";
    TownTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[TownTableCell alloc] initWithStyle:UITableViewCellStyleDefault
                                    reuseIdentifier:CellIdentifier];
        [cell autorelease];
    }
    
    if (indexPath.section == 2 && indexPath.row == self.townsOffline.count) {
        [cell fillInAsAddCell];
    } else {
        [cell fillInAsTown: [self townAtIndexPath: indexPath]];
    }
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    TownEditViewController *controller = [self doRaisePopoverWithStoryboardIdentifier: @"editTown"
                                                                        fromIndexPath: indexPath];
    controller.town = [self townAtIndexPath: indexPath];
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
