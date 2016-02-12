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

- (void)  testSimpleUI {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app launch];
    NSLog(@"UI Test");
    
    XCUIElement *switchlistWindow = [[XCUIApplication alloc] init].windows[@"Untitled"];
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

@end