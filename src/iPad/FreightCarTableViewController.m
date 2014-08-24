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
#import "CargoChooser.h"
#import "CarType.h"
#import "CarTypeChooser.h"
#import "EntireLayout.h"
#import "FreightCar.h"
#import "FreightCarTableCell.h"
#import "Industry.h"
#import "IndustryChooser.h"
#import "SwitchListColors.h"

@interface FreightCarTableViewController ()
- (void) doCloseChooser: (id) sender;
@end

@implementation FreightCarTableViewController
@synthesize allFreightCars;
@synthesize allFreightCarsOnWorkbench;

- (void)viewDidLoad {
    [super viewDidLoad];
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.storyboardName = @"FreightCarTable";
    self.title = @"Freight Cars";
    
    UIBarButtonItem *addButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemAdd target:self action:@selector(addFreightCar:)];

    self.navigationItem.rightBarButtonItem = addButtonItem;
}

- (void) addFreightCar: (id) sender {
    AppDelegate *myAppDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    EntireLayout *entireLayout = myAppDelegate.entireLayout;
 
    FreightCar *fc = [entireLayout createFreightCar: @"AA&A 84712" withCarType: @"XM" withLength: [NSNumber numberWithInt: 40]];
    [fc setCurrentLocation: [entireLayout workbenchIndustry]];
    NSUInteger indexArr[] = {1, 0};
    [self regenerateTableData];
    [self.tableView reloadData];
    self.expandedCellPath = [NSIndexPath indexPathWithIndexes: indexArr length: 2];
    [self.tableView reloadRowsAtIndexPaths: [NSArray arrayWithObjects: self.expandedCellPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
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

// Handle a touch on a cell's freight car kind.  Show a popover
// to allow selecting a different car kind.
- (IBAction) doCarTypePressed: (id) sender {
    FreightCarTableCell *cell = sender;
    CGRect popoverRect = [cell convertRect: cell.detailedCarType.frame toView: self.view];
    CarTypeChooser *chooser = [self doRaisePopoverWithStoryboardIdentifier: @"carTypeChooser" fromRect: popoverRect];
    chooser.keyObject = cell.freightCar;
    chooser.keyObjectSelection = cell.freightCar.carTypeRel;
    chooser.myController = self;
}

// Handle a touch on a cell's freight car kind.  Show a popover
// to allow selecting a different car kind.
- (IBAction) doCargoPressed: (id) sender {
    FreightCarTableCell *cell = sender;
    CGRect popoverRect = [cell convertRect: cell.cargoField.frame toView: self.view];
    // TODO(bowdidge): Limit choices to cargos for this car, or cargos without a car type, or the car's current contents.
    CargoChooser *chooser = [self doRaisePopoverWithStoryboardIdentifier: @"cargoChooser" fromRect: popoverRect];
    [chooser setFreightCar: cell.freightCar];
    chooser.myController = self;
}

// Handle a touch on a cell's freight car location.  Show a popover
// to allow selecting a different location.
- (IBAction) doLocationPressed: (id) sender {
    FreightCarTableCell *cell = sender;
    CGRect popoverRect = [cell convertRect: cell.shortCarType.frame toView: self.view];
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
    } else if ([sender isKindOfClass: [CargoChooser class]]) {
        CargoChooser *chooser = (CargoChooser*) sender;
        FreightCar *selectedFreightCar = chooser.keyObject;
        selectedFreightCar.cargo = chooser.selectedCargo;
        [self.myPopoverController dismissPopoverAnimated: YES];
        [self.tableView reloadData];
    } else {
        NSLog(@"Unknown chooser %@ used in doCloseChooser:", [sender class]);
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Three sections: on layout, on workbench, and empty/add.
    return 2;
}

const int CARS_ON_LAYOUT_SECTION = 0;
const int CARS_AT_WORKBENCH_SECTION = 1;

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == CARS_ON_LAYOUT_SECTION) {
      return @"Freight cars on layout";
    } else if (section == CARS_AT_WORKBENCH_SECTION){
        return @"Freight cars at workbench";
    } else {
        // Empty/add.  Won't show as title, but makes processing cells easier.
        return @"";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    // Add one for "Add freight car".
    if (section == CARS_ON_LAYOUT_SECTION) {
        return [self.allFreightCars count];
    } else if (section == CARS_AT_WORKBENCH_SECTION) {
        return [self.allFreightCarsOnWorkbench count];
    } else {
        return 1;
    }
}

- (FreightCar*) freightCarAtIndexPath: (NSIndexPath *) indexPath {
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    if (section == CARS_ON_LAYOUT_SECTION) {
        return [allFreightCars objectAtIndex: row];
    } else if (section == CARS_AT_WORKBENCH_SECTION){
        return [allFreightCarsOnWorkbench objectAtIndex: row];
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath compare: self.expandedCellPath] == NSOrderedSame) {
        return 180.0;
    }
    return 80.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier;
    if ([indexPath compare: self.expandedCellPath] == NSOrderedSame) {
        cellIdentifier = @"extendedFreightCarCell";
    } else {
        cellIdentifier = @"freightCarCell";
    }
    FreightCarTableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[FreightCarTableCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:cellIdentifier];
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
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
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

#pragma mark - Table view delegate

// Handles presses on the table.  When a selection is made in the freight
// car table, we show a popover for editing the freight car.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
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

@end
