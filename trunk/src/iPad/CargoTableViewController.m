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
#import "CargoChooser.h"
#import "CarTypeChooser.h"
#import "CargoTableCell.h"
#import "IndustryChooser.h"
#import "SwitchListColors.h"

@interface CargoTableViewController ()

@end

@implementation CargoTableViewController
@synthesize allCargos;

- (void)viewDidLoad {
    [super viewDidLoad];

    [self regenerateTableData];
    self.storyboardName = @"CargoTable";
    self.title = @"Cargos";

    UIBarButtonItem *addButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemAdd target:self action:@selector(addCargo:)];
    self.navigationItem.rightBarButtonItem = addButtonItem;
}

- (void) regenerateTableData {
    AppDelegate *myAppDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    EntireLayout *myLayout = myAppDelegate.entireLayout;
    self.allCargos = [myLayout allCargosSortedByDescription];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) addCargo: (id) sender {
    AppDelegate *myAppDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    EntireLayout *entireLayout = myAppDelegate.entireLayout;
    
    Cargo *cargo = [entireLayout createCargoWithName: @"A Cargo"];
    
    [self regenerateTableData];
    [self.tableView reloadData];
    NSInteger currentIndex = [self.allCargos indexOfObject: cargo];
    NSUInteger indexArr[] = {0, currentIndex};
    self.expandedCellPath = [NSIndexPath indexPathWithIndexes: indexArr length: 2];
    [self.tableView reloadRowsAtIndexPaths: [NSArray arrayWithObjects: self.expandedCellPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self.tableView scrollToRowAtIndexPath: self.expandedCellPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

// Called on valid click on the cargo's source location.
- (void) doCloseChooser: (id) sender {
    if ([sender isKindOfClass: [CarTypeChooser class]]) {
        CarTypeChooser *chooser = (CarTypeChooser*) sender;
        Cargo* selectedCargo = chooser.keyObject;
        selectedCargo.carTypeRel = chooser.selectedCarType;
        [self.myPopoverController dismissPopoverAnimated: YES];
        [self.tableView reloadData];
    } else if ([sender isKindOfClass: [IndustryChooser class]]) {
        IndustryChooser *chooser = (IndustryChooser*) sender;
        Cargo* selectedCargo  = chooser.keyObject;
        if ([chooser.fieldToSet isEqualToString: @"source"]) {
            selectedCargo.source = chooser.selectedIndustry;
        } else {
            selectedCargo.destination = chooser.selectedIndustry;
        }
        [self.myPopoverController dismissPopoverAnimated: YES];
        [self.tableView reloadData];
    } else {
        NSLog(@"Unknown chooser %@ used in doCloseChooser:", [sender class]);
    }
}

// Handle a touch on a cell's freight car location.  Show a popover
// to allow selecting a different location.
- (IBAction) doSourcePressed: (id) sender {
    CargoTableCell *cell = sender;
    CGRect popoverRect = [cell convertRect: cell.source.frame toView: self.view];
    IndustryChooser *chooser = [self doRaisePopoverWithStoryboardIdentifier: @"industryChooser" fromRect: popoverRect];
    chooser.keyObject = cell.cargo;
    chooser.keyObjectSelection = cell.cargo.source;
    chooser.myController = self;
    chooser.fieldToSet = @"source";
}

// Handle a touch on a cell's cargo destination.  Show a popover
// to allow selecting a different location.
- (IBAction) doDestinationPressed: (id) sender {
    CargoTableCell *cell = sender;
    CGRect popoverRect = [cell convertRect: cell.destination.frame toView: self.view];
    IndustryChooser *chooser = [self doRaisePopoverWithStoryboardIdentifier: @"industryChooser" fromRect: popoverRect];
    chooser.keyObject = cell.cargo;
    chooser.keyObjectSelection = cell.cargo.destination;
    chooser.myController = self;
    chooser.fieldToSet = @"destination";
}

// Handle a touch on a cell's cargo destination.  Show a popover
// to allow selecting a different location.
- (IBAction) doCarTypePressed: (id) sender {
    CargoTableCell *cell = sender;
    CGRect popoverRect = [cell convertRect: cell.carType.frame toView: self.view];
    CarTypeChooser *chooser = [self doRaisePopoverWithStoryboardIdentifier: @"carTypeChooser" fromRect: popoverRect];
    chooser.keyObject = cell.cargo;
    chooser.keyObjectSelection = cell.cargo.carTypeRel;
    chooser.myController = self;
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
    return [allCargos count];
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
    

    Cargo *cargo = [allCargos objectAtIndex: [indexPath row]];
    [cell fillInAsCargo: cargo];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row % 2 == 1) {
        // Alternate colors get a slight gray.
        cell.backgroundColor = [SwitchListColors switchListLightBeige];
    }
}

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
