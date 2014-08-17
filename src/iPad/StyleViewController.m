//
//  StyleViewController.m
//  SwitchList
//
//  Copyright (c) 2014 Robert Bowdidge. All rights reserved.
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

#import "StyleViewController.h"

#import "Foundation/Foundation.h"

#import "AppDelegate.h"
#import "FileCell.h"
#import "MainWindowViewController.h"
#import "StyleTableViewCell.h"
#import "TemplateCache.h"


@interface StyleViewController ()

@end

@implementation StyleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    // Custom initialization
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.theTemplateCache = [[[TemplateCache alloc] init] autorelease];
    NSLog(@"%@", self.theTemplateCache);

	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Returns the number of sections in the towns table.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.theTemplateCache validTemplateNames] count];
}

// Returns the number of rows in the specified towns section.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

// Returns contents of the cell for the specified row and section.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AppDelegate *myAppDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    static NSString *CellIdentifier = @"styleCell";
    NSArray* validTemplateNames = [self.theTemplateCache validTemplateNames];
    StyleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[[StyleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                reuseIdentifier:CellIdentifier] autorelease];
    }
    NSInteger row = [indexPath indexAtPosition: 0];
    cell.label.text = [validTemplateNames objectAtIndex: row];;
    if ([cell.label.text isEqualToString: myAppDelegate.preferredTemplateStyle]) {
        cell.currentSelectionIndicator.text = @"+";
    } else {
        cell.currentSelectionIndicator.text = @"";
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
    // TODO(bowdidge): Change selection.
    AppDelegate *myAppDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    NSArray* validTemplateNames = [self.theTemplateCache validTemplateNames];
    int selectionIndex = (int) [indexPath indexAtPosition: 0];
    if (selectionIndex >= 0 && selectionIndex < validTemplateNames.count) {
        myAppDelegate.preferredTemplateStyle = [validTemplateNames objectAtIndex: selectionIndex];
        [myAppDelegate.mainWindowViewController noteRegenerateSwitchlists];
    }
    [self.myPopoverController dismissPopoverAnimated: YES];
}

@synthesize styleTable;

@end
