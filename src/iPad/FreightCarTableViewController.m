//
//  FreightCarTableViewController.m
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

#import "FreightCarTableViewController.h"

#import "AppDelegate.h"
#import "AppNavigationController.h"
#import "Cargo.h"
#import "CarType.h"
#import "CarTypeChooser.h"
#import "EntireLayout.h"
#import "FreightCar.h"
#import "FreightCarEditController.h"
#import "FreightCarTableCell.h"
#import "IndustryChooser.h"
#import "SwitchListColors.h"

@interface FreightCarTableViewController ()
- (IBAction) doKindPressed: (id) sender;
- (void) doCloseChooser: (id) sender;
@end

@implementation FreightCarTableViewController
@synthesize allFreightCars;
@synthesize allFreightCarsOnWorkbench;

- (void)viewDidLoad {
    [super viewDidLoad];
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

// Gathers freight car data from the entire layout again, reloading if necessary.
- (void) regenerateTableData {
    AppDelegate *myAppDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    EntireLayout *myLayout = myAppDelegate.entireLayout;
    self.allFreightCars = [myLayout allFreightCarsOnLayout];
    self.allFreightCarsOnWorkbench = [myLayout allFreightCarsOnWorkbench];
}

- (void) viewWillAppear: (BOOL) animate {
    [super viewWillAppear: animate];
    [self regenerateTableData];
}

- (void) viewWillDisappear: (BOOL) animate {
    self.allFreightCars = nil;
    self.allFreightCarsOnWorkbench = nil;
    [super viewWillDisappear: animate];
}
- (void)didReceiveMemoryWarning {
    self.allFreightCars = nil;
    self.allFreightCarsOnWorkbench = nil;
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Three sections: on layout, on workbench, and empty/add.
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
      return @"Freight cars on layout";
    } else if (section == 1){
        return @"Freight cars at workbench";
    } else {
        // Empty/add.  Won't show as title, but makes processing cells easier.
        return @"";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    // Add one for "Add freight car".
    if (section == 0) {
        return [self.allFreightCars count];
    } else if (section == 1) {
        return [self.allFreightCarsOnWorkbench count];
    } else {
        return 1;
    }
}

- (FreightCar*) freightCarAtIndexPath: (NSIndexPath *) indexPath {
    NSInteger section = [indexPath section];
    if (section != 0 && section != 1) {
        return nil;
    }
    NSInteger row = [indexPath row];
    if (section == 0) {
        return [allFreightCars objectAtIndex: row];
    } else {
        return [allFreightCarsOnWorkbench objectAtIndex: row];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row % 2 == 1) {
        // Alternate colors get a slight gray.
        cell.backgroundColor = [SwitchListColors switchListLightBeige];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"freightCarCell";
    
    FreightCarTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[FreightCarTableCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellIdentifier];
        [cell autorelease];
    }
    
    FreightCar *fc = [self freightCarAtIndexPath: indexPath];
    if (!fc) {
        // Add.
        [cell fillInAsAddCell];
    } else {
        [cell fillInAsFreightCar: fc];
    }
    return cell;
}


// Determines if row can be edited or deleted.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Handles editing actions on table - delete or insert.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        FreightCar *freightCarToDelete = [self freightCarAtIndexPath: indexPath];
        [[freightCarToDelete managedObjectContext] deleteObject: freightCarToDelete];
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

// Handle a touch on a cell's freight car kind.  Show a popover
// to allow selecting a different car kind.
- (IBAction) doKindPressed: (id) sender {
    FreightCarTableCell *cell = sender;
    CGRect popoverRect = [cell convertRect: cell.freightCarKind.frame toView: self.view];
    CarTypeChooser *chooser = [self doRaisePopoverWithStoryboardIdentifier: @"carTypeChooser" fromRect: popoverRect];
    chooser.keyObject = cell.freightCar;
    chooser.keyObjectSelection = cell.freightCar.carTypeRel;
    chooser.myController = self;
}

// Handle a touch on a cell's freight car location.  Show a popover
// to allow selecting a different location.
- (IBAction) doLocationPressed: (id) sender {
    FreightCarTableCell *cell = sender;
    CGRect popoverRect = [cell convertRect: cell.freightCarKind.frame toView: self.view];
    IndustryChooser *chooser = [self doRaisePopoverWithStoryboardIdentifier: @"industryChooser" fromRect: popoverRect];
    chooser.keyObject = cell.freightCar;
    chooser.keyObjectSelection = cell.freightCar.currentLocation;
    chooser.myController = self;
}

// Handle an edit that changed a car's reporting marks.
- (IBAction) noteTableCell: (FreightCarTableCell*) cell changedCarReportingMarks: (NSString*) reportingMarks {
    [cell.freightCar setReportingMarks: reportingMarks];
    [self.tableView reloadData];
}

// Called on valid click on the freight car kind chooser.
- (void) doCloseChooser: (id) sender {
    if ([sender isKindOfClass: [CarTypeChooser class]]) {
        CarTypeChooser *chooser = (CarTypeChooser*) sender;
        FreightCar *selectedFreightCar = chooser.keyObject;
        selectedFreightCar.carTypeRel = chooser.selectedCarType;
        [self.myPopoverController dismissPopoverAnimated: YES];
        [self.tableView reloadData];
    } else if ([sender isKindOfClass: [IndustryChooser class]]) {
        IndustryChooser *chooser = (IndustryChooser*) sender;
        FreightCar *selectedFreightCar = chooser.keyObject;
        selectedFreightCar.currentLocation = chooser.selectedIndustry;
        [self.myPopoverController dismissPopoverAnimated: YES];
        [self.tableView reloadData];        
    }
}

#pragma mark - Table view delegate

// Handles presses on the table.  When a selection is made in the freight
// car table, we show a popover for editing the freight car.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FreightCar *freightCar = [self freightCarAtIndexPath: indexPath];
    if (!freightCar) {
        // Create a new freight car.
        AppDelegate *myAppDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
        EntireLayout *myLayout = myAppDelegate.entireLayout;
        NSManagedObjectContext *moc = [[myLayout workbenchIndustry] managedObjectContext];
        [NSEntityDescription entityForName: @"FreightCar" inManagedObjectContext: moc];
        freightCar = [NSEntityDescription insertNewObjectForEntityForName:@"FreightCar"
                                                   inManagedObjectContext: moc];
        [freightCar setReportingMarks: @"SP 84712"];
    }
    FreightCarEditController *freightCarEditVC = [self doRaisePopoverWithStoryboardIdentifier: @"editFreightCar"
                                                                                fromIndexPath: indexPath];
    freightCarEditVC.freightCar = freightCar;
}

@end
