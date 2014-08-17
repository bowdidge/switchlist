//
//  IndustryTableViewController.m
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

#import "IndustryTableViewController.h"

#import "AppDelegate.h"
#import "AppNavigationController.h"
#import "Cargo.h"
#import "Industry.h"
#import "IndustryEditViewController.h"
#import "IndustryTableCell.h"
#import "PlaceChooser.h"
#import "SwitchListColors.h"

@interface IndustryTableViewController ()
@property (retain, nonatomic) NSArray *allIndustries;
@end

@implementation IndustryTableViewController
- (void)viewDidLoad {
    [super viewDidLoad];
}

// Gathers freight car data from the entire layout again, reloading if necessary.
- (void) regenerateTableData {
    AppDelegate *myAppDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    EntireLayout *myLayout = myAppDelegate.entireLayout;
    self.allIndustries = [myLayout allIndustries];
}

- (void) viewWillAppear: (BOOL) animate {
    [super viewWillAppear: animate];
    [self regenerateTableData];
}

- (void) viewWillDisappear: (BOOL) animate {
    self.allIndustries = nil;
    [super viewWillDisappear: animate];
}
- (void)didReceiveMemoryWarning {
    self.allIndustries = nil;
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (Industry*) industryAtIndexPath: (NSIndexPath *) indexPath {
    return [self.allIndustries objectAtIndex: [indexPath row]];
}


#pragma mark - Table view data source

// Returns number of sections for table view to draw.
// For now, only one category.
// TODO(bowdidge): Split into online and offline industries?
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// Generates table for section.
// Always returns same string because only one section.
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Industries on layout";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // TODO(bowdidge) Add one item for the "Add Industry" cell.
    return [allIndustries count];
}

// Generates cell for particular row.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"industryCell";
    IndustryTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[IndustryTableCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellIdentifier];
        [cell autorelease];
    }
    
    // Configure the cell...
    NSInteger row = [indexPath row];
    if (row == [self.allIndustries count]) {
        [cell fillInAsAddCell];
    } else {
        Industry *industry = [self industryAtIndexPath: indexPath];
        [cell fillInAsIndustry: industry];
    }
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

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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


#pragma mark - Table view delegate

// Handles presses on the table.  When a selection is made in the freight
// car table, we show a popover for editing the freight car.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Industry *myIndustry = [self industryAtIndexPath: indexPath];
    if (!myIndustry) {
        // Create a new industry.
    }
    
    IndustryEditViewController *industryEditVC = [self doRaisePopoverWithStoryboardIdentifier: @"editTheIndustry"
                                                                                fromIndexPath: indexPath];
    industryEditVC.industry = myIndustry;
}

// Handles raising the correct popup when user touches the containing
// station's name.
- (IBAction) doStationPressed: (id) sender {
    IndustryTableCell *cell = sender;
    CGRect popoverRect = [cell convertRect: cell.industryLocation.frame toView: self.view];
    PlaceChooser *chooser = [self doRaisePopoverWithStoryboardIdentifier: @"placeChooser" fromRect: popoverRect];
    chooser.keyObject = cell.myIndustry;
    chooser.keyObjectSelection = cell.myIndustry.location;
    chooser.controller = self;
}

// Requests edit view be closed.
- (IBAction) doDismissEditPopover: (id) sender {
    [self.myPopoverController dismissPopoverAnimated: YES];
}

@synthesize allIndustries;
@end
