//
//  UITest.m
//  SwitchList
//
//  Created by bowdidge on 2/11/16.
//
//

#import <XCTest/XCTest.h>

@interface UITest : XCTestCase {
}
@end



@implementation UITest

// Simple test to make sure UI tests are working.
- (void)  testSimpleUI {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app launch];
    NSLog(@"UI Test");
    [app.menuItems[@"New"] click];
    XCUIElement *switchlistWindow = [[XCUIApplication alloc] init].windows[@"Untitled"];
    [switchlistWindow click];
    [switchlistWindow.tabs[@"Freight Cars"] click];
    
    
    XCUIElement *untitledWindow = [[XCUIApplication alloc] init].windows[@"Untitled"];
    XCUIElement *addButton = untitledWindow.buttons[@"Add"];
    [addButton click];
    
    XCUIElement *reportingMarksTextField = untitledWindow.textFields[@"Reporting Marks"];
    XCTAssertNotNil(reportingMarksTextField, @"Can't find Reporting Marks Field");
    
    // Select all text.
    [reportingMarksTextField click];
    [app.menuItems[@"Select All"] click];
    [reportingMarksTextField typeText:@"WP 20120\r"];

    // Make another.
    [addButton click];
    // Select all text.
    reportingMarksTextField = untitledWindow.textFields[@"Reporting Marks"];
    [reportingMarksTextField click];
    [app.menuItems[@"Select All"] click];
    [reportingMarksTextField typeText:@"UP 80935\r"];

    XCTAssertEqualObjects(@"UP 80935", [reportingMarksTextField value], @"Didn't get edit correct.");
    // We now have two freight cars.
    XCTAssertEqual(2, [switchlistWindow.tables.tableRows count]);
}

// TODO(bowdidge): Load file from disk.
- (void)  testRevert {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    NSMutableArray *args = [NSMutableArray arrayWithArray: app.launchArguments];
    // NSString *dataPath = [[NSBundle mainBundle] pathForResource: @"Vasona Branch" ofType: @"swl"];

    NSString *dataPath = [[NSBundle bundleForClass: [self class]] pathForResource: @"Vasona Branch" ofType: @"swl"];
    XCTAssertNotNil(dataPath);
    [args addObject: dataPath];
    app.launchArguments = args;
    [app launch];
    
    
    XCUIElement *switchlistWindow = [[XCUIApplication alloc] init].windows[@"Vasona Branch.swl"];
    [switchlistWindow click];
    sleep(1);
    XCTAssertNotNil(switchlistWindow);
    XCTAssertNotNil(switchlistWindow.tabs[@"Freight Cars"]);
    [switchlistWindow.tabs[@"Freight Cars"] click];
    
    
    XCUIElement *addButton = switchlistWindow.buttons[@"Add"];
    [addButton click];
    
    XCUIElement *reportingMarksTextField = switchlistWindow.textFields[@"Reporting Marks"];
    XCTAssertNotNil(reportingMarksTextField, @"Can't find Reporting Marks Field");
    
    // Select all text.
    [reportingMarksTextField click];
    [app.menuItems[@"Select All"] click];
    [reportingMarksTextField typeText:@"WP 20120\r"];
    
    // Reverting the file has caused crashes in past.
    [app.menuItems[@"Revert"] click];
    // press ok on the sheet.
    [[app.sheets elementBoundByIndex: 0].buttons[@"Revert"] click];
    
    // Shouldn't crash.
    switchlistWindow = [[XCUIApplication alloc] init].windows[@"Vasona Branch.swl"];
    [switchlistWindow click];
    
}

@end