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

@interface SwitchlistPresentationViewController ()
@property(nonatomic, retain) IBOutlet UIWebView *webView;
@property(nonatomic, retain) IBOutlet UIButton *backButton;
@property(nonatomic, retain) IBOutlet UIButton *printButton;
@end

@implementation SwitchlistPresentationViewController

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
    
    //   switchlistView.layer.borderColor = [UIColor redColor].CGColor;
    //  switchlistView.layer.borderWidth = 3.0f;
    
	// Do any additional setup after loading the view.
    [self.webView setDelegate: self];
    
    NSString *path = [[NSBundle mainBundle] bundlePath];
    // Base url names which directory contains related files to be loaded together.
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    
    [self.webView loadHTMLString: self.htmlText baseURL: baseURL];

    self.navigationItem.title = @"San Jose Cannery Turn Switchlist";
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"%@", error);
}

@synthesize htmlText;
@synthesize backButton;
@synthesize printButton;
@synthesize webView;
@end
