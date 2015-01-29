//
//  CargoSelectionViewController.m
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

#import "AppDelegate.h"
#import "Cargo.h"
#import "CargoSelectionViewController.h"
#import "EntireLayout.h"
#import "TypicalIndustryStore.h"

// Represents a potential cargo for the current industry.
@interface ProposedCargo : NSObject {
    NSNumber *isKeep;
    BOOL isReceive;
    NSString *name;
    NSString *carsPerWeek;
    InduYard *industry;
    BOOL isExistingCargo;
}
// Value of checkbox whether to create this cargo.  NSNumber required
// for checkbox.
@property (nonatomic, retain) NSNumber *isKeep;
// Is incoming cargo.
@property (nonatomic) BOOL isReceive;
// String value for receive column: either "Receive" or "Ship".
@property (nonatomic, readonly) NSString *receiveString;
// Cargo description.
@property (nonatomic, retain) NSString *name;
// Rate of cars arriving or departing.
@property (nonatomic, retain) NSString *carsPerWeek;
// Preferred industry as source/dest of cargo.
@property (nonatomic, retain) InduYard *industry;
// Existing cargo just being shown for context?
@property (nonatomic) BOOL isExistingCargo;
@end

@implementation ProposedCargo
@synthesize isKeep;
@synthesize isReceive;
@synthesize name;
@synthesize carsPerWeek;
@synthesize industry;
@synthesize isExistingCargo;

// Creates a proposed cargo based on an existing Cargo object.
- (id) initWithExistingCargo: (Cargo*) cargo isReceive: (BOOL) shouldReceive {
	self = [self init];
	self.name = [cargo cargoDescription];
	self.isKeep = [NSNumber numberWithBool: NO];
	self.isExistingCargo = YES;
	self.isReceive = shouldReceive;
	self.industry = (shouldReceive ? [cargo source] : [cargo destination]);
	self.carsPerWeek = [[cargo carsPerWeek] stringValue];
	return self;
}

- (NSString*) receiveString {
	return (self.isReceive ? @"Receive" : @"Ship");
}
@end


@interface CargoSelectionCell: UITableViewCell
@property(retain, nonatomic) IBOutlet UIButton *checkbox;
@property(retain, nonatomic) IBOutlet UILabel *cargoDescription;
@property(nonatomic) BOOL isSelected;

- (IBAction) selectCargo: (id) sender;
@end
@implementation CargoSelectionCell
- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle: style reuseIdentifier: reuseIdentifier];
    return self;
}

- (IBAction) selectCargo: (id) sender {
    self.checkbox.selected = !self.checkbox.selected;
}
@end

@interface CargoSelectionViewController ()
@end

@implementation CargoSelectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    AppDelegate *myAppDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    self.entireLayout = myAppDelegate.entireLayout;
    self.allCategories = myAppDelegate.typicalIndustryStore.typicalIndustries;
    self.categoryMap = myAppDelegate.typicalIndustryStore.categoryMap;
    [self doChangeIndustryClass: self];
    self.title = @"Suggest Cargos";
    [self doChangeSelectedIndustry: self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Returns a default industry likely to be a source / destination of any industry.
- (Industry*) likelyDestination {
	NSArray *allIndustries = [self.entireLayout allIndustries];
	Industry *mostPopularStagingIndustry = nil;
	int mostPopularCargoCount = 0;
	for (Industry *i in allIndustries) {
		if ([i isStaging] || [i isOffline]) {
			NSInteger cargoCount = [[i originatingCargos] count] + [[i terminatingCargos] count];
			if (!mostPopularStagingIndustry || cargoCount > mostPopularCargoCount) {
				mostPopularStagingIndustry = i;
				mostPopularCargoCount = cargoCount;
			}
		}
	}
	
	if (mostPopularStagingIndustry) {
		return mostPopularStagingIndustry;
	}
	
	// Next, try most popular industry in general?
	Industry *mostPopularIndustry = nil;
	for (Industry *i in allIndustries) {
		NSInteger cargoCount = [[i originatingCargos] count] + [[i terminatingCargos] count];
		if (!mostPopularStagingIndustry || cargoCount > mostPopularCargoCount) {
			mostPopularStagingIndustry = i;
			mostPopularCargoCount = cargoCount;
		}
	}
    
	// return most popular industry or nil if none.
	if (mostPopularIndustry) {
		return mostPopularIndustry;
	}
	
	return [self.entireLayout workbenchIndustry];
}
// Reloads the table with data for the provided category.
- (void) setCargosToCategory: (NSString*) category {
	NSDictionary *industryDict = [self.categoryMap objectForKey: category];
    
	NSMutableArray *newContents= [NSMutableArray array];
	Industry *likelyDestination = [self likelyDestination];
	
	int proposedCargoCount = 0;
	int existingCargoCount = 0;
	
	for (NSDictionary *cargo in [industryDict objectForKey: @"Cargo"]) {
		ProposedCargo *c = [[[ProposedCargo alloc] init] autorelease];
		c.name = [cargo objectForKey: @"Name"];
		// TODO(bowdidge): Consider era.
		// NSString *era = [cargo objectForKey: @"Era"];
		c.isKeep = [NSNumber numberWithBool: YES];
		c.isReceive = ([[cargo objectForKey: @"Incoming"] intValue] != 0);
		c.isExistingCargo = NO;
		c.industry = likelyDestination;
		int rate = [[cargo objectForKey: @"Rate"] intValue];
		int totalCarsPerWeek = 10; //TODO(bowdidge): Fix.
		int carsPerWeek = (totalCarsPerWeek * rate) / 100;
		if (carsPerWeek < 1) {
			carsPerWeek = 1;
		}
		c.carsPerWeek = [NSString stringWithFormat: @"%d", carsPerWeek];
		[newContents addObject: c];
		proposedCargoCount++;
	}
    
	// Fill in the existing cargos for context, graying out
	for (Cargo *cargo in [self.selectedIndustry originatingCargos]) {
		ProposedCargo *c = [[[ProposedCargo alloc] initWithExistingCargo: cargo isReceive: NO] autorelease];
		[newContents addObject: c];
		existingCargoCount++;
	}
    
	for (Cargo *cargo in [self.selectedIndustry terminatingCargos]) {
		ProposedCargo *c = [[[ProposedCargo alloc] initWithExistingCargo: cargo isReceive: YES] autorelease];
		[newContents addObject: c];
		existingCargoCount++;
	}
	
    self.proposedCargos = newContents;
	[self.suggestedCargoView reloadData];
    
	// Hint to the user what the grayed out cargos are by giving an informative message at the bottom.
	// Get the plural right.
	NSString *msg = [NSString stringWithFormat: @"%d proposed cargo%s, %d existing cargo%s.",
					 proposedCargoCount, (proposedCargoCount == 1 ? "" : "s"),
					 existingCargoCount, (existingCargoCount == 1 ? "" : "s")];
	//[proposedCargoCountMsg_ setStringValue: msg];
}

- (IBAction) doChangeIndustryClass: (id) sender {
	NSString *category = @"cannery"; //[self.categoryPicker titleOfSelectedItem];
	[self setCargosToCategory: category];
    [self.categoryPicker reloadAllComponents];
}

- (IBAction) doChangeSelectedIndustry:(id) sender {
    AppDelegate *myAppDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    self.industryName.text = [NSString stringWithFormat: @"%@ is a", self.selectedIndustry.name];
    self.suggestedCategories = [myAppDelegate.typicalIndustryStore categoriesForIndustryName: self.selectedIndustry.name];
    [self.categoryPicker reloadAllComponents];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.suggestedCategories count] + [self.allCategories count] + 1;
}

- (NSString*) categoryAtRow: (NSInteger) row {
    if (row < [self.suggestedCategories count]) {
        return [self.suggestedCategories objectAtIndex: row];
    } else if (row == [self.suggestedCategories count]) {
        return @"--------";
    }
    return [[self.allCategories objectAtIndex: row - self.suggestedCategories.count - 1] objectForKey: @"IndustryClass"];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self categoryAtRow: row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSString *category = [self categoryAtRow: row];
    [self setCargosToCategory: category];
}


//
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // Irrelevant - title not shown when only one exists.
    return @"Cargos for industry";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.proposedCargos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"cargoSuggestion";
    if ([indexPath compare: self.expandedCellPath] == NSOrderedSame) {
        cellIdentifier = @"extendedCargoSuggestion";
    }
    CargoSelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[CargoSelectionCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:cellIdentifier];
        [cell autorelease];
    }
    NSString* filename = [[[NSBundle mainBundle] URLForResource: @"uncheck-icon" withExtension: @"png"] path];
    [cell.checkbox setImage: [UIImage imageWithContentsOfFile: filename] forState: UIControlStateNormal];
    filename = [[[NSBundle mainBundle] URLForResource: @"check-1-icon" withExtension: @"png"] path];
    [cell.checkbox setImage: [UIImage imageWithContentsOfFile: filename] forState: UIControlStateSelected];
   
    ProposedCargo *c = [self.proposedCargos objectAtIndex: [indexPath row]];
    cell.cargoDescription.text = [NSString stringWithFormat: @"%@ from West Coast", c.name];
    if ([c isExistingCargo]) {
        cell.checkbox.enabled = NO;
        cell.cargoDescription.enabled = NO;
    } else {
        cell.checkbox.enabled = YES;
        cell.cargoDescription.enabled = YES;
    }
    return cell;
}

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
        [tableView beginUpdates];
        self.expandedCellPath = nil;
        [tableView endUpdates];
        [tableView reloadRowsAtIndexPaths: [NSArray arrayWithObjects: indexPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
        return;
    }
    
    [tableView beginUpdates];
    NSIndexPath *oldPath = [self.expandedCellPath retain];
    self.expandedCellPath = indexPath;
    [tableView endUpdates];
    [tableView reloadRowsAtIndexPaths: [NSArray arrayWithObjects: indexPath, oldPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
    [oldPath release];
}

@end
