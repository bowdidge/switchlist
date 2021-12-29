//
//  EndToEndTest.m
//  SwitchList
//
//  Created by bowdidge on 7/27/14.
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

#import "EndToEndTest.h"

#import "EntireLayout.h"
#import "FreightCar.h"
#import "HTMLSwitchlistRenderer.h"
#import "HTMLSwitchListController.h"
#import "LayoutController.h"
#import "ScheduledTrain.h"
#import "SwitchList_OCUnit.h"

// Test that we can correctly iterate on a layout several times with cars still moving.
@implementation EndToEndTest
// Initial setup.
- (id) init {
    // layoutFileName should be set by subclasses.
    layoutFileName_ = @"Bogus";
    return self;
}

- (void) setUp {
    NSURL* layoutUrl = [[NSBundle bundleForClass: [self class]] URLForResource:layoutFileName_ withExtension: @"swl"];

    NSLog(@"%@", layoutUrl);
    XCTAssertNotNil(layoutUrl);
    if (!layoutUrl) {
        return;
    }

    // Test bundle isn't same as class's bundle.
    NSBundle *mainBundle = [NSBundle bundleForClass: [EndToEndTest class]];
    NSURL *modelURL = [NSURL fileURLWithPath: @"SwitchListDocument.momd" relativeToURL: mainBundle.resourceURL];
 
    NSLog(@"%@", modelURL);
    XCTAssertNotNil(modelURL);
    
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL: modelURL];
    NSPersistentContainer *container = [[NSPersistentContainer alloc] initWithName: @"SwitchListDocument" managedObjectModel: model];
    if (container == nil) {
        NSLog(@"No valid container!");
        XCTAssertTrue(NO, @"problems loading persistent store");
        return;
    }
     NSPersistentStoreDescription *description = [[NSPersistentStoreDescription alloc] init];
    [description setURL: layoutUrl];
    description.type = NSXMLStoreType;
    description.shouldAddStoreAsynchronously = YES;
    description.shouldMigrateStoreAutomatically = YES;
    container.persistentStoreDescriptions = [NSArray arrayWithObject: description];
    [container loadPersistentStoresWithCompletionHandler: ^(NSPersistentStoreDescription* description, NSError* error) {
        NSLog(@"Loading persistent stores: %@ %@", description, error);
    }];
    sleep(5);
    context_ = [container viewContext];
	entireLayout_ = [[EntireLayout alloc] initWithMOC: context_];
    NSLog(@"Places: %d", (int) entireLayout_.allStations.count);
    NSLog(@"Industries: %d", (int) entireLayout_.allIndustries.count);
    NSLog(@"Cars: %d", (int) entireLayout_.allFreightCars.count);
}

// Calculates total number of cargos that were created but couldn't be filled
// because of lack of cars.  Used as metric to indicate potential trouble.
- (int) cargosNotFilled: (NSDictionary*) unfilledDict {
    int totalCount = 0;
    for (NSNumber *count in [unfilledDict allValues]) {
        totalCount += [count intValue];
    }
    return totalCount;
}

// Tests that switchlists are reasonably rendered, and attempts to catch obvious problems.
- (BOOL) doTestOneLayout: (EntireLayout*) layout switchlistStyle: (NSString*) switchlistStyle {
    HTMLSwitchlistRenderer *renderer = [[[HTMLSwitchlistRenderer alloc] initWithBundle: [NSBundle bundleForClass: [self class]]] autorelease];
    [renderer setTemplate: switchlistStyle];
    HTMLSwitchListController *printingHtmlViewController = [[[HTMLSwitchListController alloc] init] autorelease];
    
    XCTAssertTrue([entireLayout_ allTrains].count > 0, @"Expected at least one train, but got zero");
    for (ScheduledTrain* train in [entireLayout_ allTrains]) {
        NSString *all_html = [renderer renderSwitchlistForTrain:train layout: entireLayout_ iPhone: NO interactive: NO];
        
        XCTAssertTrue(all_html.length > 0, @"Switchlist text for train %@ and switchlist style %@ too short (was %d, expected >0 characters)", [train name], switchlistStyle,  (int) all_html.length);
        // Test train name appears.
        XCTAssertContains([train name], all_html);
        
        // TEST HERE FOR VALID HTML
        for (FreightCar* fc in train.freightCars) {
            // Can't check together because of non-breaking spaces added for jitter.
            XCTAssertContains([fc number], all_html, @"Couldn't find freight car %@ in switchlist %@.", [fc reportingMarks], switchlistStyle);
            XCTAssertContains([fc initials], all_html, @"Couldn't find freight car %@ in switchlist %@.", [fc reportingMarks], switchlistStyle);
        }
        
        // TODO(bowdidge): Load HTML into a WebView to test it can be parsed.
     }
    return YES;
}

// Tests that the layout can be put through ten cycles, and cars continue to move at a reasonable rate.
- (void) doTestLayout {
    NSUInteger carCount = [[entireLayout_ allFreightCars] count];
    NSArray *allTrains = [entireLayout_ allTrains];
    XCTAssertTrue([allTrains count] > 0, @"No trains found - problems loading.");
    XCTAssertTrue([[entireLayout_ allFreightCars] count] > 0, @"No freight cars found - problems loading.");

    LayoutController *controller = [[LayoutController alloc] initWithEntireLayout: entireLayout_];
    for (int i=0;i<10;i++) {
        [controller advanceLoads];
        [controller createAndAssignNewCargos: entireLayout_.allFreightCars.count  * 0.2];
        NSArray *errs = [controller assignCarsToTrains: allTrains respectSidingLengths: YES useDoors: YES];
        

        [self doTestOneLayout: entireLayout_ switchlistStyle: @"Line Printer"];
        [self doTestOneLayout: entireLayout_ switchlistStyle: @"PICL Report"];
        [self doTestOneLayout: entireLayout_ switchlistStyle: @"Handwritten"];
        [self doTestOneLayout: entireLayout_ switchlistStyle: @"Southern Pacific Narrow"];
        [self doTestOneLayout: entireLayout_ switchlistStyle: @"San Francisco Belt Line B-7"];

        int carsMoved = 0;
        for (ScheduledTrain *train in allTrains) {
            carsMoved += [train.freightCars count];
            [controller completeTrain: train];
        }
        XCTAssertTrue(carsMoved > 0.2 * carCount, @"Insufficient cars moved on iter %d: expected 0.2 * carCount (%d), got %d", (int) i, (int) carCount/5 , (int) carsMoved);
    }
    
    [controller release];
}

@end

@interface VasonaBranchTest : EndToEndTest {
};
@end
@implementation VasonaBranchTest
- (void) setUp {
    layoutFileName_ = @"Vasona Branch";
    [super setUp];
}
- (void) testLayout {
    [self doTestLayout];
}
@end

@interface StocktonWithDivisionsTest : EndToEndTest {
};
@end
@implementation StocktonWithDivisionsTest
- (void) setUp {
    layoutFileName_ = @"Stockton with Divisions";
    [super setUp];
}
- (void) testLayout {
    [self doTestLayout];
}
@end

@interface StocktonTest : EndToEndTest {
};
@end
@implementation StocktonTest
- (void) setUp {
    layoutFileName_ = @"Stockton Example";
    [super setUp];
}
- (void) testLayout {
    [self doTestLayout];
}
@end

@interface LetterheadViaTest : EndToEndTest {
};
@end

// Test that Railroad Letterhead correctly renders destinations for
// cars ending at the staging yard.

@implementation LetterheadViaTest
- (void) setUp {
    layoutFileName_ = @"Shelf Layout";
    [super setUp];
}

- (void) testViaStringAppearsWhenCarGoesBeyondYard {
    NSBundle *bundleForUnitTests = [NSBundle bundleForClass: [self class]];
    NSArray *allTrains = [entireLayout_ allTrains];

    XCTAssertTrue([allTrains count] > 0, @"No trains found - problems loading.");
    XCTAssertTrue([[entireLayout_ allFreightCars] count] > 0, @"No freight cars found - problems loading.");
    
    HTMLSwitchlistRenderer *renderer = [[HTMLSwitchlistRenderer alloc] initWithBundle: bundleForUnitTests];
    [renderer setTemplate: @"Railroad Letterhead"];
    NSString *result = [renderer renderSwitchlistForTrain: [entireLayout_ trainWithName: @"Only Train"] layout: entireLayout_ iPhone: false interactive: false];
   
    XCTAssertContains(@"to Chicago via Staging", result, "Expected car to Chicago to show up as 'to Chicago via Staging'");
    XCTAssertContains(@"to Staging", result, "Expected car to staging showed up as 'to Staging'");

}

    
@end

