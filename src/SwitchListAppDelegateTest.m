//
//  SwitchListAppDelegateTest.m
//  SwitchList
//
//  Created by bowdidge on 2/13/11.
//  Copyright 2011 Robert Bowdidge. All rights reserved.
//

#import "SwitchListAppDelegateTest.h"
#import <Cocoa/Cocoa.h>
#import "SwitchListAppDelegate.h"

@implementation SwitchListAppDelegateTest
- (void) testWebServerShutsDown {
	// TODO(bowdidge) Figure out how to test this - this didn't work.
	//	SwitchListAppDelegate *delegate = [[SwitchListAppDelegate alloc] init];
	//	[delegate startWebServerShowAlert: NO];
	
	//    NSURL *baseURL = [[NSURL URLWithString:@"http://localhost:20000"] retain];
	//	NSMutableData *esponseData = [[NSMutableData data] retain];
	
	//    NSURLRequest *request = [NSURLRequest requestWithURL:baseURL];
	//	NSHTTPURLResponse *response;
	//	NSError *error;
	//    NSData *data = [NSURLConnection sendSynchronousRequest: request returningResponse: &response error: &error];
	//	XCTAssertTrue(200 == [response statusCode], @"wrong status");
}		
@end
