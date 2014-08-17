//
//  TemplateCacheTest.m
//  SwitchList
//
//  Created by bowdidge on 8/16/14.
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

#import "TemplateCacheTest.h"

#import "GlobalPreferences.h"
#import "SwitchList_OCUnit.h"
#import "Templatecache.h"

@interface FakeFileManager : NSFileManager {
};
//- (BOOL) fileExistsAtPath: (NSString*) path isDirectory: (BOOL*) isDirectory;
//- (NSArray*) contentsOfDirectoryAtPath: (NSString*) path error: (NSError*) err;
- (NSString*) applicationSupportDirectory;
@end

@implementation FakeFileManager
- (NSString*) applicationSupportDirectory {
    NSString* tmpdir = NSTemporaryDirectory();
    NSLog(@"%@", tmpdir);
    return tmpdir;
}
@end

@implementation TemplateCacheTest

- (NSString *)pathForTemporaryFileWithPrefix:(NSString *)prefix
{
    NSString *  result;
    CFUUIDRef   uuid;
    CFStringRef uuidStr;
    
    uuid = CFUUIDCreate(NULL);
    assert(uuid != NULL);
    
    uuidStr = CFUUIDCreateString(NULL, uuid);
    assert(uuidStr != NULL);
    
    result = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@", prefix, uuidStr]];
    assert(result != nil);
    
    CFRelease(uuidStr);
    CFRelease(uuid);
    
    return result;
}

- (void) testTemplateCacheContainsHandwritten {
    TemplateCache *myCache = [[TemplateCache alloc] initWithFileManager: [NSFileManager defaultManager]];
    XCTAssertNotNil(myCache, @"Expected not nil");
    XCTAssertTrue([[myCache validTemplateNames] containsObject: DEFAULT_SWITCHLIST_TEMPLATE], @"Didn't find 'Handwritten' in %@", [myCache validTemplateNames]);
}

- (void) testTemplateCacheDoesNotContainInsaneTemplate {
    TemplateCache *myCache = [[TemplateCache alloc] initWithFileManager: [NSFileManager defaultManager]];
    XCTAssertNotNil(myCache, @"Expected not nil");
    XCTAssertFalse([[myCache validTemplateNames] containsObject: @"Insane"], @"Shouldn't have found 'Insane' in %@", [myCache validTemplateNames]);
}

- (void) testStockTemplates {
    TemplateCache *myCache = [[TemplateCache alloc] init];
    XCTAssertTrue([myCache validTemplateNames].count == 1, @"Expected one template, got %ld (%@)", [myCache validTemplateNames].count, [myCache validTemplateNames]);
}

// TODO(bowdidge): Add some templates in a directory in /tmp?
- (void) testNoMatchDirectoriesWithoutSwitchlist {
    NSError* err;
    FakeFileManager* fakeFileManager = [[[FakeFileManager alloc] init] autorelease];
    TemplateCache *myCache = [[TemplateCache alloc] initWithFileManager: fakeFileManager];
    
    // Create an empty directory. It shouldn't show up.
    NSString* switchlistDirectory = [NSTemporaryDirectory() stringByAppendingPathComponent: @"NoSwitchList"];
    XCTAssertTrue([[NSFileManager defaultManager] createDirectoryAtPath: switchlistDirectory withIntermediateDirectories: NO attributes: [NSDictionary dictionary]  error: &err], @"Problems creating test directory");
    XCTAssertFalse([[myCache validTemplateNames] containsObject: @"NotASwitchList"], @"Shouldn't have found 'NotASwitchList' in %@", [myCache validTemplateNames]);
}

- (void) testMatchDirectoriesWithSwitchlist {
    NSError* err;
    FakeFileManager* fakeFileManager = [[[FakeFileManager alloc] init] autorelease];
    TemplateCache *myCache = [[TemplateCache alloc] initWithFileManager: fakeFileManager];
    
    // Create an empty directory. It shouldn't show up.
    NSString* switchlistDirectory = [NSTemporaryDirectory() stringByAppendingPathComponent: @"MySwitchList"];
    NSString* switchlistFile = [switchlistDirectory stringByAppendingPathComponent: @"switchlist.html"];
    XCTAssertTrue([[NSFileManager defaultManager] createDirectoryAtPath: switchlistDirectory withIntermediateDirectories: NO attributes: [NSDictionary dictionary]  error: &err], @"Problems creating test directory");
    XCTAssertTrue([[NSFileManager defaultManager] createFileAtPath: switchlistFile contents: [NSData data] attributes: [NSDictionary dictionary]], @"Problems creating file");
    XCTAssertTrue([[myCache validTemplateNames] containsObject: @"MySwitchList"], @"Shouldn't have found 'NotASwitchList' in %@", [myCache validTemplateNames]);
}

@end
