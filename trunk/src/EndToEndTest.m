//
//  EndToEndTest.m
//  SwitchList
//
//  Created by bowdidge on 7/27/14.
//
//

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
}
- (void) setUp {
    NSLog(@"%@", [[NSBundle bundleForClass: [self class]] resourcePath]);
    NSURL* layoutUrl = [[NSBundle bundleForClass: [self class]] URLForResource: layoutFileName_ withExtension: @"swl"];
	context_ = [[NSManagedObjectContext inMemoryMOCFromBundle: [NSBundle bundleForClass: [self class]] withFile: layoutUrl] retain];
	entireLayout_ = [[EntireLayout alloc] initWithMOC: context_];
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
    
    for (ScheduledTrain* train in [entireLayout_ allTrains]) {
        NSString *all_html = [renderer renderSwitchlistForTrain:train layout: entireLayout_ iPhone: NO interactive: NO];
        
        XCTAssertTrue(all_html.length > 0, @"Switchlist text for train %@ and switchlist style %@ too short (was %d, expected >0 characters)", [train name], switchlistStyle,  (int) all_html.length);
        // Test train name appears.
        XCTAssertContains([train name], all_html);
        
        // TEST HERE FOR VALID HTML
        for (FreightCar* fc in [train freightCars]) {
            XCTAssertContains([fc reportingMarks], all_html, @"Couldn't find freight car %@ in switchlist %@.", [fc reportingMarks], switchlistStyle);
        }
        
        // TODO(bowdidge): Load HTML into a WebView to test it can be parsed.
     }
    return YES;
}

// Tests that the layout can be put through ten cycles, and cars continue to move at a reasonable rate.
- (void) doTestLayout {
    int carCount = [[entireLayout_ allFreightCars] count];
    NSArray *allTrains = [entireLayout_ allTrains];
    XCTAssertTrue([allTrains count] > 0, @"No trains found - problems loading.");

    LayoutController *controller = [[LayoutController alloc] initWithEntireLayout: entireLayout_];
    for (int i=0;i<10;i++) {
        [controller advanceLoads];
        NSDictionary *unfilledCargosDict = [controller createAndAssignNewCargos: (carCount / 4)];
        int cargosNotFilled = [self cargosNotFilled: unfilledCargosDict];
        
        NSArray *errs = [controller assignCarsToTrains: allTrains respectSidingLengths: YES useDoors: YES];
        
        int carsMoved = 0;
        for (ScheduledTrain *train in allTrains) {
            carsMoved += [[train freightCars] count];
            [controller completeTrain: train];
        }
        XCTAssertTrue(carsMoved > 0.2 * carCount, @"Insufficient cars moved: expected 0.2 * carCount (%d), got %d", carCount/5 , carsMoved);

        [self doTestOneLayout: entireLayout_ switchlistStyle: @"Line Printer"];
        [self doTestOneLayout: entireLayout_ switchlistStyle: @"PICL Report"];
        [self doTestOneLayout: entireLayout_ switchlistStyle: @"Handwritten"];
        [self doTestOneLayout: entireLayout_ switchlistStyle: @"Southern Pacific Narrow"];
        [self doTestOneLayout: entireLayout_ switchlistStyle: @"San Francisco Belt Line B-7"];
    }
    
    [controller release];
    return YES;
}

@end

@interface VasonaBranchTest : EndToEndTest {
};
@end
@implementation VasonaBranchTest
- (id) init {
    [super init];
    layoutFileName_ = @"Vasona Branch";
}
- (void) testLayout {
    [self doTestLayout];
}
@end

@interface StocktonWithDivisionsTest : EndToEndTest {
};
@end
@implementation StocktonWithDivisionsTest
- (id) init {
    [super init];
    layoutFileName_ = @"Stockton with Divisions";
}
- (void) testLayout {
    [self doTestLayout];
}
@end

@interface StocktonTest : EndToEndTest {
};
@end
@implementation StocktonTest
- (id) init {
    [super init];
    layoutFileName_ = @"Stockton";
}
- (void) testLayout {
    [self doTestLayout];
}
@end

