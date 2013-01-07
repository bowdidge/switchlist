//
//  FreightCarKindChooser.m
//  SwitchList
//
//  Created by Robert Bowdidge on 1/6/13.
//
//

#import "CarTypeChooser.h"

#import "AppDelegate.h"
#import "CarType.h"
#import "EntireLayout.h"
#import "FreightCarTableViewController.h"

@implementation CarTypeChooserCell
@synthesize checkField;
@synthesize label;
@end

@interface CarTypeChooser ()
@end

@implementation CarTypeChooser

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Keep a list of all freight car types on hand for generating the
    // list of possible values.
    AppDelegate *myAppDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    EntireLayout *myLayout = myAppDelegate.entireLayout;
    self.allCarTypes = [myLayout allCarTypes];
    
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
    return [self.allCarTypes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"freightCarKindCell";
    CarTypeChooserCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    int index = [indexPath row];
    CarType *carType = [self.allCarTypes objectAtIndex: index];
    cell.label.text = [NSString stringWithFormat: @"%@ / %@",  carType.carTypeDescription, carType.carTypeName];
    if (carType == self.keyObjectSelection) {
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
    self.selectedCarType = [self.allCarTypes objectAtIndex: [indexPath row]];
    [self.myController doCloseChooser: self];
}

@synthesize selectedCarType;
@synthesize allCarTypes;
@end
