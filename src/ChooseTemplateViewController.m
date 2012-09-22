//
//  ChooseTemplateViewController.m
//  SwitchList
//
//  Created by Robert Bowdidge on 9/21/12.
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

#import "ChooseTemplateViewController.h"

#import "LayoutDetailsViewController.h"
#import "TemplateCell.h"

@interface ChooseTemplateViewController ()
// Table filling view for showing list of switchlist templates.
@property (nonatomic, retain) IBOutlet UITableView *templateTable;
// Descriptions of all templates.  Dictionary.
@property (nonatomic, retain) NSMutableArray *allTemplates;
@property (nonatomic, retain) NSMutableArray *allCustomTemplates;
@end

// Keys for the allTemplates / allCustomTemplates dictionaries.
// TODO(bowdidge): Replace with a real object populated by scanning the resources folder.
NSString *TEMPLATE_NAME_KEY = @"templateName";
NSString *TEMPLATE_DESCRIPTION_KEY = @"templateDescription";
NSString *TEMPLATE_IS_CUSTOM_KEY = @"customTemplate";

@implementation ChooseTemplateViewController

- (NSDictionary*) templateDictWithName: (NSString*) name description: (NSString*) description isCustom: (BOOL) isCustom {
    NSDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue: name forKey: TEMPLATE_NAME_KEY];
    [dict setValue: description forKey: TEMPLATE_DESCRIPTION_KEY];
    [dict setValue: [NSNumber numberWithBool: isCustom] forKey: TEMPLATE_IS_CUSTOM_KEY];
    return dict;
}

- (void) viewDidLoad {
    self.allTemplates = [NSMutableArray array];
    self.allCustomTemplates = [NSMutableArray array];

    // NOTE: name is also the directory to search for the template files.
    [self.allTemplates addObject: [self templateDictWithName: @"Handwritten"
                                            description: @"Mid 20th century inked."
                                               isCustom: NO]];
    [self.allTemplates addObject: [self templateDictWithName: @"Southern Pacific Narrow"
                                            description: @"Handwritten, prototypical switchlist."
                                               isCustom: NO]];
    [self.allTemplates addObject: [self templateDictWithName: @"Line Printer"
                                            description: @"Simple, computer-generated switchlist."
                                               isCustom: NO]];
    [self.allTemplates addObject: [self templateDictWithName: @"PICL Report"
                                            description: @"1980's era computer generated list."
                                               isCustom: NO]];
    [self.allTemplates addObject: [self templateDictWithName: @"San Francisco Belt Line B-7"
                                            description: @"Per-industry documents."
                                               isCustom: NO]];
    //[self.allCustomTemplates addObject: [self templateDictWithName: @"Thomas the Tank Engine"
    //                                                description: @"For the Brio crowd."
    //                                                 isCustom: YES]];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Built in templates, custom.
    // TODO(bowdidge): Look for custom, user-provided templates.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.allTemplates.count;
    } else {
        return self.allCustomTemplates.count;
    }
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Built-in templates";
    } else if (section == 1){
        return @"Custom templates";
    } else {
        // Empty/add.  Won't show as title, but makes processing cells easier.
        return @"";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"templateCell";
    TemplateCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    int row = [indexPath row];
    if ([indexPath section] == 1) {
        NSDictionary *template = [self.allCustomTemplates objectAtIndex: row];
        cell.templateName.text = [template objectForKey: TEMPLATE_NAME_KEY];
        cell.templateDescription.text = [template objectForKey: TEMPLATE_DESCRIPTION_KEY];
    } else {
        NSDictionary *template = [self.allTemplates objectAtIndex: row];
        cell.templateName.text = [template objectForKey: TEMPLATE_NAME_KEY];
        cell.templateDescription.text = [template objectForKey: TEMPLATE_DESCRIPTION_KEY];
    }
    return cell;
}

// Handles the user pressing an item in the right-hand-side selection table.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    int row = [indexPath row];
    int section = [indexPath section];
    NSString *name;
    if (section == 0) {
        name = [[self.allTemplates objectAtIndex: row] objectForKey: TEMPLATE_NAME_KEY];
    } else {
        name = [[self.allCustomTemplates objectAtIndex: row] objectForKey: TEMPLATE_NAME_KEY];
    }
    [self.layoutDetailsController templateNameChanged: name];
    [self.myPopoverController dismissPopoverAnimated: YES];
}

@synthesize allTemplates;
@synthesize allCustomTemplates;
@synthesize layoutDetailsController;
@end
