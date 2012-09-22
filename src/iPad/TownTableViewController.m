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
@property (nonatomic, retain) NSArray *townsOnLayout;
@property (nonatomic, retain) NSArray *townsInStaging;
@property (nonatomic, retain) NSArray *townsOffline;
@end

@implementation TownTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AppDelegate *myAppDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    EntireLayout *myLayout = myAppDelegate.entireLayout;
    NSMutableArray *onLayoutTowns = [NSMutableArray array];
    NSMutableArray *stagingTowns = [NSMutableArray array];
    NSMutableArray *offlineTowns = [NSMutableArray array];
    for (Place *p in [myLayout allStations]) {
        if ([p isOffline]) {
            [offlineTowns addObject: p];
        } else if ([p isStaging]) {
            [stagingTowns addObject: p];
        } else {
            [onLayoutTowns addObject: p];
        }
    }
    
    self.townsOnLayout = onLayoutTowns;
    self.townsInStaging = stagingTowns;
    self.townsOffline = offlineTowns;
}

- (void)didReceiveMemoryWarning
{
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
    int section = indexPath.section;
    int row = indexPath.row;
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
    static NSString *CellIdentifier = @"townCell";
    TownTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[TownTableCell alloc] initWithStyle:UITableViewCellStyleDefault
                                    reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.section == 2 && indexPath.row == self.townsOffline.count) {
        [cell fillInAsAddCell];
    } else {
        [cell fillInAsTown: [self townAtIndexPath: indexPath]];
    }
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row % 2 == 1) {
        // Alternate colors get a slight gray.
        cell.backgroundColor = [SwitchListColors switchListLightBeige];
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


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
    TownEditViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"editTown"];
    controller.myTown = [self townAtIndexPath: indexPath];

    CGRect cellFrame = [tableView rectForRowAtIndexPath: indexPath];

    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController: controller];
    controller.myPopoverController = popover;
    // Give editor a chance to call us back.
    controller.townTableViewController = self;
    CGRect cellRect = [tableView convertRect: cellFrame toView: self.view];
    // Move rect to far left so that we try to have the edit popover point to the left.
    cellRect.size.width = 100;
    [popover presentPopoverFromRect: cellRect
                             inView: [self view]
           permittedArrowDirections: UIPopoverArrowDirectionLeft
                           animated: YES];
}

@synthesize townsOnLayout;
@synthesize townsInStaging;
@synthesize townsOffline;
@end
