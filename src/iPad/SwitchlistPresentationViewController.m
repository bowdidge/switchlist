//
//  SingleSwitchListViewController.m
//  SwitchList for iPad
//
//  Created by Robert Bowdidge on 9/6/12.
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

#import "SwitchlistPresentationViewController.h"

#import <UIKit/UIWebView.h>

#import "AppDelegate.h"
#import "AppNavigationController.h"

// Shows the actual HTML of a switchlist or report in a single window,
// and allows printing and other document operations.
@interface SwitchlistPresentationViewController ()
// view actually drawing the HTML.
@property(nonatomic, retain) IBOutlet UIWebView *webView;
// Navigation bar back button.
@property(nonatomic, retain) IBOutlet UIButton *backButton;
// Separate button for doing AirPrint to print the document.
@property(nonatomic, retain) IBOutlet UIBarButtonItem *printButton;
@end

@implementation SwitchlistPresentationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
	// Do any additional setup after loading the view.
    [self.webView setDelegate: self];
    
    // Identify the file in terms of the bundle directory so that
    // requests for additional files comefrom the bundle directory.
    // TODO(bowdidge): How to display multiple pages?
    [self.webView loadHTMLString: self.htmlText
                         baseURL: [NSURL fileURLWithPath: self.basePath]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"UIWebView error: %@", error);
}

// Prints the current document in the UIWebView to an AirPrint printer.
- (IBAction) doPrint: (id) sender {
    UIPrintInteractionController *pic = [UIPrintInteractionController sharedPrintController];
    pic.delegate = self;
    
    UIPrintInfo *printInfo = [UIPrintInfo printInfo];
    printInfo.outputType = UIPrintInfoOutputGeneral;
    // Add repot or train name.
    printInfo.jobName = @"Switchlist";
    pic.printInfo = printInfo;
    // TODO(bowdidge): Hide buttons in web page.
    pic.printFormatter = [webView viewPrintFormatter];
    pic.showsPageRange = YES;
    
    void (^completionHandler)(UIPrintInteractionController *, BOOL, NSError *) =
    ^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
        if (!completed && error) {
            NSLog(@"Printing could not complete because of error: %@", error);
                  }
                  };
    [pic presentFromBarButtonItem: self.printButton animated: YES completionHandler: completionHandler];
}

@synthesize htmlText;
@synthesize backButton;
@synthesize printButton;
@synthesize webView;
@end
