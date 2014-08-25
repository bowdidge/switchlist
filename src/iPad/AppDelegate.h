//
//  AppDelegate.h
//  SwitchList for iPad
//
//  Created by Robert Bowdidge on 8/30/12.
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


#import <UIKit/UIKit.h>

#import "EntireLayout.h"
#import "LayoutController.h"

@class MainWindowViewController;

// Application-level support for the whole SwitchList-on-iPad app.
// Contains functionality for looking at the current layout,
// and for any interactions between different portions of the program.
@interface AppDelegate : UIResponder <UIApplicationDelegate>

// Returns list of accessible filenames containing layouts.
- (NSArray*) allSampleLayouts;
- (NSArray*) allLocalLayouts;
- (NSArray*) allICloudLayouts;

// Closes existing file.
- (BOOL) openLayoutWithName: (NSURL*) filename;
// Explicitly save the layout.
- (IBAction) doSave: (id) sender;

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory;
- (NSURL*) sampleDocumentsDirectory;

@property (strong, nonatomic) UIWindow *window;

// Reference to TabBarController, used by MainController to open the tab bar.
@property (strong, nonatomic) UITabBarController *layoutDetailTabBarController;

// Wrapper object around the data file's store.
@property (strong, nonatomic) EntireLayout *entireLayout;
// Controller for changing the state of the layout - advancing to the next day, creating
// cargos, etc.
@property (strong, nonatomic) LayoutController *layoutController;

// Name of preferred HTML style for drawing switchlists.
// TODO(bowdidge): Make persistent.
@property (retain, nonatomic) NSString *preferredTemplateStyle;

// Handle to main view controller for reloading data / reprocessing trains.
@property (retain, nonatomic) MainWindowViewController *mainWindowViewController;
@end
