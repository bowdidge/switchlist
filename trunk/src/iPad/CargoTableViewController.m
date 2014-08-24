//
//  CargoTableViewController.m
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

#import "CargoTableViewController.h"

#import "AppDelegate.h"
#import "Cargo.h"
#import "CargoTableCell.h"
#import "SwitchListColors.h"

@interface CargoTableViewController ()

@end

@implementation CargoTableViewController
@synthesize allCargos;

- (void)viewDidLoad {
    [super viewDidLoad];

    AppDelegate *myAppDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    EntireLayout *myLayout = myAppDelegate.entireLayout;
    allCargos = [[myLayout allCargos] copy];
    self.storyboardName = @"CargoTable";
    self.title = @"Cargos";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

// Returns the cargo object represented by the item on the specific row of the table.
- (Cargo*) cargoAtIndexPath: (NSIndexPath *)indexPath {
    return [allCargos objectAtIndex: [indexPath row]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Cargo views only have one category.
    // TODO(bowdidge): Consider other categories - loads that stay online?
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // Irrelevant - title not shown when only one exists.
    return @"Cargos for layout";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Add one extra cargo for "Add new cargo" listing.
    return [allCargos count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier;
    if ([indexPath compare: self.expandedCellPath] == NSOrderedSame) {
        cellIdentifier = @"extendedCargoCell";
    } else {
        cellIdentifier = @"cargoCell";
    }
    CargoTableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[CargoTableCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:cellIdentifier];
        [cell autorelease];
    }
    

    NSInteger row = [indexPath row];
    if (row == [self.allCargos count]) {
        [cell fillInAsAddCell];
    } else {
        Cargo *cargo = [allCargos objectAtIndex: row];
        [cell fillInAsCargo: cargo];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath compare: self.expandedCellPath] == NSOrderedSame) {
        return 160.0;
    }
    return 80.0;
}


// Handles presses on the table.  When a selection is made in the cargo
// table, we show a popover for editing the cargo.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath compare: self.expandedCellPath] == NSOrderedSame) {
        [self.tableView beginUpdates];
        self.expandedCellPath = nil;
        [self.tableView endUpdates];
        [self.tableView reloadRowsAtIndexPaths: [NSArray arrayWithObjects: indexPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
        return;
    }
    
    Cargo *cargo = [self cargoAtIndexPath: indexPath];
    if (!cargo) {
        // Create a new freight car.
        AppDelegate *myAppDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
        EntireLayout *myLayout = myAppDelegate.entireLayout;
        NSManagedObjectContext *moc = [[myLayout workbenchIndustry] managedObjectContext];
        [NSEntityDescription entityForName: @"Cargo" inManagedObjectContext: moc];
        cargo = [NSEntityDescription insertNewObjectForEntityForName:@"Cargo"
                                              inManagedObjectContext: moc];
        cargo.cargoDescription = @"Stuff";
    }

    [self.tableView beginUpdates];
    NSIndexPath *oldPath = [self.expandedCellPath retain];
    self.expandedCellPath = indexPath;
    [self.tableView endUpdates];
    [self.tableView reloadRowsAtIndexPaths: [NSArray arrayWithObjects: indexPath, oldPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
    [oldPath release];
}


@end
