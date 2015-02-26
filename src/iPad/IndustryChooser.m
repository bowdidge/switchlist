//
//  IndustryChooser.m
//  SwitchList
//
//  Created by Robert Bowdidge on 1/7/13.
//
//

#import "IndustryChooser.h"

#import "AbstractTableViewController.h"
#import "AppDelegate.h"
#import "EntireLayout.h"
#import "Industry.h"
#import "Place.h"

@implementation IndustryChooserCell
@synthesize checkField;
@synthesize label;
@end

@interface IndustryChooser ()
@end

@implementation IndustryChooser

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear: (BOOL) animated {
    [super viewWillAppear: animated];
    
    // Keep a list of all freight car types on hand for generating the
    // list of possible values.
    AppDelegate *myAppDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    EntireLayout *myLayout = myAppDelegate.entireLayout;

    if (self.showYards) {
        self.allIndustries = [myLayout allLocationsForFreightCars];
    } else {
        self.allIndustries = [myLayout allIndustries];
    }
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.allIndustries count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"industryChooserCell";
    IndustryChooserCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSInteger index = [indexPath row];
    Industry *industry = [self.allIndustries objectAtIndex: index];
    cell.label.text = [NSString stringWithFormat: @"%@ at %@", industry.name, industry.location.name];
    if (industry == self.keyObjectSelection) {
        cell.checkField.text = @"\u2713";
    } else {
        cell.checkField.text = @"";
    }
    return cell;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO(bowdidge): Save response.
    self.selectedIndustry = [self.allIndustries objectAtIndex: [indexPath row]];
    [self.myController doCloseChooser: self];
}

@synthesize selectedIndustry;
@synthesize allIndustries;
@end
