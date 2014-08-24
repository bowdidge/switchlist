//
//  TrainTableViewController.m
//  SwitchList for iPad
//
//  Created by Robert Bowdidge on 9/9/12.
//  Copyright (c) 2012 Robert Bowdidge. All rights reserved.
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

#import "TrainTableViewController.h"

#import "AppDelegate.h"
#import "CarTypeChooser.h"
#import "EntireLayout.h"
#import "ScheduledTrain.h"
#import "SwitchListColors.h"
#import "TrainTableCell.h"

@interface TrainTableViewController ()
@property (retain, nonatomic) NSArray *allTrains;
@end

@implementation TrainTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.storyboardName = @"TrainTable";
    self.title = @"Trains";
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    AppDelegate *myAppDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    EntireLayout *myLayout = myAppDelegate.entireLayout;
    self.allTrains = [myLayout allTrains];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Returns nil if out of range.
- (ScheduledTrain*) trainAtIndexPath: (NSIndexPath *) indexPath {
    NSInteger row = [indexPath row];
    if (row < 0 || row > [self.allTrains count]) {
        return nil;
    }
    return [self.allTrains objectAtIndex: [indexPath row]];
}

// Handle a touch on a cell's freight car kind.  Show a popover
// to allow selecting a different car kind.
- (IBAction) doCarTypePressed: (id) sender {
    TrainTableCell *cell = sender;
    CGRect popoverRect = [cell convertRect: cell.carsAccepted.frame toView: self.view];
    CarTypeChooser *chooser = [self doRaisePopoverWithStoryboardIdentifier: @"carTypeChooser" fromRect: popoverRect];
    chooser.keyObject = cell.train;
    // TODO(bowdidge): Should be all car types accepted by train.
    chooser.keyObjectSelection = nil;
    chooser.myController = self;
}

#pragma mark - Table view data source

// Returns number of sections to show in the train table.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Train table only has one section for all trains.
    return 1;
}

// Returns label to show on each section.
// Because only one section exists, this will never be shown.
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Trains on layout";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Add one item for the "Add Train..." cell.
    return [allTrains count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier;
    if ([indexPath compare: self.expandedCellPath] == NSOrderedSame) {
        cellIdentifier = @"trainExtendedCell";
    } else {
        cellIdentifier = @"trainCell";
    }
    TrainTableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[TrainTableCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:cellIdentifier];
        [cell autorelease];
    }
    
    // Configure the cell...
    NSInteger row = [indexPath row];
    if (row == [allTrains count]) {
        [cell fillInAsAddCell];
    } else {
        ScheduledTrain *train = [allTrains objectAtIndex: row];
        [cell fillInAsTrain: train];
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
        return 140.0;
    }
    return 80.0;
}

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

    ScheduledTrain *myTrain = [self trainAtIndexPath: indexPath];
    if (!myTrain) {
        // Create a new industry.
    }
    
    [self.tableView beginUpdates];
    NSIndexPath *oldPath = [self.expandedCellPath retain];
    self.expandedCellPath = indexPath;
    [self.tableView endUpdates];
    [self.tableView reloadRowsAtIndexPaths: [NSArray arrayWithObjects: indexPath, oldPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
    [oldPath release];
}

// Requests edit view be closed.
- (IBAction) doDismissEditPopover: (id) sender {
    [self.myPopoverController dismissPopoverAnimated: YES];
}

@synthesize allTrains;
@end
