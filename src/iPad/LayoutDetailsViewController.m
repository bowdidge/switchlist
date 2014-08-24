//
//  LayoutDetailsTabViewController.m
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

#import "LayoutDetailsViewController.h"

#import "AppDelegate.h"
#import "ChooseTemplateViewController.h"
#import "MainWindowViewController.h"

@interface LayoutDetailsViewController ()
@property (nonatomic,retain) IBOutlet UIButton *templateButton;
@end

@implementation LayoutDetailsViewController

- (void) viewDidLoad {
    self.title = @"Layout Settings";
}

- (void) viewWillAppear: (BOOL) animated {
    AppDelegate *myAppDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    NSString *templateName = myAppDelegate.preferredTemplateStyle;
    if (!templateName) {
        templateName = @"Handwritten";
    }
    [self.templateButton setTitle: templateName forState: UIControlStateNormal];
    [self.templateButton setTitle: templateName forState: UIControlStateSelected];
}

// Switch from this scene to another.
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"templateSegue"]) {
        ChooseTemplateViewController *controller = segue.destinationViewController;
        controller.myPopoverController = ((UIStoryboardPopoverSegue*)segue).popoverController;
        controller.layoutDetailsController = self;
        
    }
}

- (IBAction) templateNameChanged: (NSString*) templateName {
    AppDelegate *myAppDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    [self.templateButton setTitle: templateName forState: UIControlStateNormal];
    [self.templateButton setTitle: templateName forState: UIControlStateSelected];

    myAppDelegate.preferredTemplateStyle = templateName;
    [myAppDelegate.mainWindowViewController noteRegenerateSwitchlists];
}
@end
