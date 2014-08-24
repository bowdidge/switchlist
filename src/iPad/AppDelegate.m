//
//  AppDelegate.m
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

#import "AppDelegate.h"
#import "CarType.h"
#import "CarTypes.h"
#import "EntireLayout.h"
#import "MainWindowViewController.h"

#import <CoreData/CoreData.h>

@interface AppDelegate ()

@property (nonatomic, strong) NSURL *currentFilePath;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory;
- (void)saveContext;
@end

@implementation AppDelegate
// Writes out the data store to disk.
- (void)saveContext {
    NSError *error;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             */
            NSLog(@"Error while saving managed context %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound
// to the persistent store coordinator for the application.
- (NSManagedObjectContext *) managedObjectContext {
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *) managedObjectModel {
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"SwitchListDocument" withExtension:@"momd"];
    managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    
    NSError *error;
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                  configuration:nil
                                                            URL:self.currentFilePath
                                                        options:options
                                                          error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return persistentStoreCoordinator;
}

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

// Closes the currently open file, saves file, and tears down CoreData objects.
- (void) closeFile {
    NSError *error = nil;
    [self.managedObjectContext save: &error];
    if (error) {
        NSLog(@"Problems saving file!");
    }
    self.persistentStoreCoordinator = nil;
    self.managedObjectContext = nil;
}

// Helper.  Open the specified path.
- (BOOL) openNewFile: (NSURL*) filename {
    self.currentFilePath = filename;
    self.entireLayout = [[EntireLayout alloc] initWithMOC: [self managedObjectContext]];
    self.layoutController = [[[LayoutController alloc] initWithEntireLayout: entireLayout] autorelease];
    
    if ([[self.entireLayout allCarTypes] count] == 0) {
		NSDictionary* currentlyUsedCarTypes = [CarTypes populateCarTypesFromLayout: self.entireLayout];
		for (NSString *carTypeName in currentlyUsedCarTypes) {
			CarType *carType = [NSEntityDescription insertNewObjectForEntityForName:@"CarType"
															 inManagedObjectContext: self.managedObjectContext];
			[carType setCarTypeName: carTypeName];
			[carType setCarTypeDescription: [currentlyUsedCarTypes objectForKey: carTypeName]];
		}
    }
    return YES;
}

// Opens a new file with the given name in the application documents directory.
// If the file does not exist, the store will be in memory, and written to disk on save.
- (BOOL) openLayoutWithName: (NSString*) filename {
    [self closeFile];
    // TODO(bowdidge): Need to keep separate map of layout name -> filename.
    NSURL *newFilePath = [[self applicationDocumentsDirectory] URLByAppendingPathComponent: filename];
    if (![self openNewFile:newFilePath]) {
        UIAlertView *badFileAlert = [[UIAlertView alloc] initWithTitle: @"Unable to load file" message: @"There was an unknown problem when loading the file" delegate: self cancelButtonTitle: @"OK" otherButtonTitles: nil];
        [badFileAlert show];
        return NO;
    }
    [self.mainWindowViewController noteRegenerateSwitchlists];
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Load vasona.sql first, copy if not available.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *newFile = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"vasona.sql"];

    if (![fileManager fileExistsAtPath:[self.currentFilePath path]]) {
        NSURL *defaultStoreURL = [[NSBundle mainBundle] URLForResource:@"vasona" withExtension:@"sql"];
        if (defaultStoreURL) {
            [fileManager copyItemAtURL:defaultStoreURL toURL:newFile error:NULL];
        }
    }
 
    [self openNewFile: newFile];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (NSArray*) allLayouts {
    // TODO: examples, too?
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *files = [fileManager contentsOfDirectoryAtPath: [[self applicationDocumentsDirectory] path]
                                                      error: &error];
    if (error) {
        NSLog(@"Error when reading application documents directory: %@", error);
        return [NSArray array];
    }
    return files;
}

@synthesize managedObjectModel;
@synthesize managedObjectContext;
@synthesize persistentStoreCoordinator;

@synthesize layoutDetailTabBarController;
@synthesize entireLayout;
@synthesize layoutController;
@synthesize preferredTemplateStyle;
@end
