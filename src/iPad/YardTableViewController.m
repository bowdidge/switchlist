//
//  YardTableViewController.m
//  SwitchList for iPad
//
//  Created by Robert Bowdidge on 9/9/12.
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

#import "YardTableViewController.h"

#import "AppDelegate.h"
#import "EntireLayout.h"
#import "Place.h"
#import "PlaceChooser.h"
#import "SwitchListColors.h"
#import "Yard.h"
#import "YardTableCell.h"

@interface YardTableViewController ()

@end

@implementation YardTableViewController
@synthesize allYards;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.storyboardName = @"YardTable";
    self.title = @"Yards";

    [self regenerateTableData];
    UIBarButtonItem *addButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemAdd target:self action:@selector(addYard:)];
    self.navigationItem.rightBarButtonItem = addButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) regenerateTableData {
    AppDelegate *myAppDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    EntireLayout *myLayout = myAppDelegate.entireLayout;
    self.allYards = [myLayout allYards];
}

- (IBAction) addYard: (id) sender {
    AppDelegate *myAppDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    EntireLayout *entireLayout = myAppDelegate.entireLayout;
    
    Yard *yard = [entireLayout createYardWithName: @"A-Yard"];
    [yard setLocation: [entireLayout workbench]];

    [self regenerateTableData];
    [self.tableView reloadData];
    NSInteger yardIndex = [self.allYards indexOfObject: yard];
    NSUInteger indexArr[] = {0, yardIndex};
    self.expandedCellPath = [NSIndexPath indexPathWithIndexes: indexArr length: 2];
    [self.tableView reloadRowsAtIndexPaths: [NSArray arrayWithObjects: self.expandedCellPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
}


#pragma mark - Table view data source

// Returns number of sections in yard table view.
// There is only the one section for now.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

// Returns section heading for yard table view.
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Yards on layout";
}

// Returns the number of rows in each section.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [allYards count];
}

// Returns the cell at the specified row and section.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier;
    if ([indexPath compare: self.expandedCellPath] == NSOrderedSame) {
        cellIdentifier = @"extendedYardCell";
    } else {
        cellIdentifier = @"yardCell";
    }
    YardTableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[YardTableCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:cellIdentifier];
        [cell autorelease];
    }
    
    // Configure the cell.
    Yard *yard = [allYards objectAtIndex: [indexPath row]];
   [cell fillInAsYard: yard];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row % 2 == 1) {
        // Alternate colors get a slight gray.
        cell.backgroundColor = [SwitchListColors switchListLightBeige];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

// Handles editing actions on table - delete or insert.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Yard *yardToDelete = [self yardAtIndexPath: indexPath];
        [[yardToDelete managedObjectContext] deleteObject: yardToDelete];
        [self regenerateTableData];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

// Handles raising the correct popup when user touches the containing
// station's name.
- (IBAction) doStationPressed: (id) sender {
    YardTableCell *cell = sender;
    CGRect popoverRect = [cell convertRect: cell.yardStation.frame toView: self.view];
    PlaceChooser *chooser = [self doRaisePopoverWithStoryboardIdentifier: @"placeChooser" fromRect: popoverRect];
    chooser.keyObject = cell.yard;
    chooser.keyObjectSelection = cell.yard.location;
    chooser.controller = self;
}

// Handles changing the yard's name when an edit is complete.
- (IBAction) noteYardTableCell: (YardTableCell*) cell changedName: (NSString*) newName {
    cell.yard.name = newName;
    [self.tableView reloadData];
}


#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath compare: self.expandedCellPath] == NSOrderedSame) {
        return 120.0;
    }
    return 80.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath compare: self.expandedCellPath] == NSOrderedSame) {
        [self.tableView beginUpdates];
        self.expandedCellPath = nil;
        [self.tableView endUpdates];
        [self.tableView reloadRowsAtIndexPaths: [NSArray arrayWithObjects: indexPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
        return;
    }
    
    [self.tableView beginUpdates];
    NSIndexPath *oldPath = [self.expandedCellPath retain];
    self.expandedCellPath = indexPath;
    [self.tableView endUpdates];
    [self.tableView reloadRowsAtIndexPaths: [NSArray arrayWithObjects: indexPath, oldPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
    [oldPath release];
}

// Handle changing the yard's containing town when a town is selected in the chooser.
- (void) doCloseChooser: (id) sender {
    PlaceChooser *chooser = (PlaceChooser*) sender;
    [(Yard*) chooser.keyObject setLocation: chooser.selectedPlace];
    [self.myPopoverController dismissPopoverAnimated: YES];
    [self.tableView reloadData];
}

@end
