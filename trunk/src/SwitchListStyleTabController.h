//
//  SwitchListStyleTabController.h
//  SwitchList
//
//  Created by bowdidge on 8/2/14.
//
// Copyright (c)2014 Robert Bowdidge,
// All rights reserved.
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
//

#import <Cocoa/Cocoa.h>
#import <webKit/webView.h>

#import "ClickCatchingView.h"
#import "EntireLayout.h"
#import "HTMLSwitchListController.h"

@class SwitchListDocument;

// Controller for handling the selection and display of switchlist styles in the Styles tab.
@interface SwitchListStyleTabController : NSObject<NSTableViewDelegate, NSTableViewDataSource, ClickCatcherController> {
    // Style tab for switchlists.
    HTMLSwitchListController *demoSwitchListController_;
	IBOutlet NSPopUpButton *switchListStyleButton_;
    IBOutlet NSTableView *switchListStyleOptions_;
    // Column listing option names.
    IBOutlet NSTableColumn *optionColumn_;
    // Column listing values that user can change.
    IBOutlet NSTableColumn *valueColumn_;
    IBOutlet WebView *demoSwitchListView_;
    
    // Names and values for customizing the switchlist.
    NSArray *optionalFieldKeyValues_;
    IBOutlet SwitchListDocument *document_;
    IBOutlet ClickCatchingView *clickCatchingView_;
    
    IBOutlet NSTextField *styleDescription_;
    
    NSMutableDictionary *styleNameToDescriptionMap_;
};
// Style tab.
- (IBAction) switchListFormatPreferenceChanged: (id) sender;

// TODO(bowdidge): Should request for particular switchlist style.
- (NSArray*) optionalFieldKeyValues;

// Puts the switchlist template names in the pop-up in sorted order,
// rescanning the template directories.
- (void) reloadSwitchlistTemplateNames;

- (IBAction) switchListStyleHelpPressed: (id) sender;
- (void) clickCaught: (id) sender;
@end
