//
//  FileViewController.m
//  SwitchList
//
//  Created by Robert Bowdidge on 9/21/12.
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

#import "FileViewController.h"

#import "AppDelegate.h"
#import "FileCell.h"

@interface FileViewController ()
// Array of filenames.
@property (nonatomic, retain) NSMutableArray *allSampleLayouts;
@property (nonatomic, retain) NSMutableArray *allLocalLayouts;
@property (nonatomic, retain) NSMutableArray *allICloudLayouts;
@end

@implementation FileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    AppDelegate *myAppDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    self.allSampleLayouts = [NSMutableArray arrayWithArray: [myAppDelegate allSampleLayouts]];
    self.allLocalLayouts = [NSMutableArray arrayWithArray: [myAppDelegate allLocalLayouts]];
    self.allICloudLayouts = [NSMutableArray arrayWithArray: [myAppDelegate allICloudLayouts]];
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table for list of files.
const int FILE_SAMPLE_SECTION = 0;
const int FILE_LOCAL_SECTION = 1;
const int FILE_ICLOUD_SECTION = 2;
const int FILE_NEW_SECTION = 3;

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == FILE_SAMPLE_SECTION) {
        return @"Sample Layouts";
    } else if (section == FILE_LOCAL_SECTION) {
        return @"Your Layouts";
    } else if (section == FILE_ICLOUD_SECTION) {
        return @"Your iCloud Layouts";
    } else if (section == FILE_NEW_SECTION) {
        return @"Create a New Layout";
    } else {
        // Empty/add.  Won't show as title, but makes processing cells easier.
        return @"";
    }
}

// Returns the number of sections in the file list.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

// Returns the number of rows in the specified towns section.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == FILE_SAMPLE_SECTION) {
        return [self.allSampleLayouts count];
    } else if (section == FILE_LOCAL_SECTION) {
        return [self.allLocalLayouts count];
    } else if (section == FILE_ICLOUD_SECTION) {
        return [self.allICloudLayouts count];
    } else if (section == FILE_NEW_SECTION) {
        return 1;
    } else {
        return 0;
    }
}

// Returns contents of the cell for the specified row and section.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"fileCell";
    FileCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[[FileCell alloc] initWithStyle:UITableViewCellStyleDefault
                               reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    NSString *label;
    NSURL *url;
    if (section == FILE_SAMPLE_SECTION) {
        label = [[[[self.allSampleLayouts objectAtIndex: row] path] lastPathComponent] stringByDeletingPathExtension];
        url = [self.allSampleLayouts objectAtIndex: row];
    } else if (section == FILE_LOCAL_SECTION) {
        label = [[[[self.allLocalLayouts objectAtIndex: row] path] lastPathComponent] stringByDeletingPathExtension];
        url = [self.allLocalLayouts objectAtIndex: row];
    } else if (section == FILE_ICLOUD_SECTION) {
        label = [[[[self.allICloudLayouts objectAtIndex: row] path] lastPathComponent] stringByDeletingPathExtension];
        url = [self.allICloudLayouts objectAtIndex: row];
    } else if (section == FILE_NEW_SECTION) {
        label = @"Create New Layout";
        url = nil;
    } else {
        label = @"";
    }
    cell.label.text = label;
    cell.url = url;
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Open.
    AppDelegate *myAppDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;

    NSInteger section = [indexPath section];
    if (section == FILE_NEW_SECTION) {
        // Get name.
        // TODO(bowdidge): Validate name is safe.
        UIAlertView *newFileAlert = [[UIAlertView alloc] initWithTitle: @"Name for New Layout" message: @"Please name your new layout." delegate: self cancelButtonTitle: @"OK" otherButtonTitles: nil];
        newFileAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
        newFileAlert.delegate = self;
        [newFileAlert show];
        return;
    }

    FileCell *cellAtPath =  (FileCell*) [tableView cellForRowAtIndexPath: indexPath];
    NSURL *fileURL = cellAtPath.url;

    if (fileURL) {
        [myAppDelegate openLayoutWithName: fileURL];
    }
    [self.myPopoverController dismissPopoverAnimated: YES];
}

#pragma mark Alert handler callbacks.

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    AppDelegate *myAppDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    UITextField *filename_field =  [actionSheet textFieldAtIndex: 0];
    NSURL *fileURL = [[myAppDelegate applicationDocumentsDirectory] URLByAppendingPathComponent: [NSString stringWithFormat: @"%@.sql", filename_field.text]];
    [myAppDelegate openLayoutWithName: fileURL];
    [self.myPopoverController dismissPopoverAnimated: YES];
}

@synthesize fileTable;
@synthesize addButton;

@end
