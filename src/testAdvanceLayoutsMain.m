//
//  main.m
//  SwitchList
//
//  Created by Robert Bowdidge on 9/17/05.
//
// Copyright (c)2005 Robert Bowdidge,
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

#import <Cocoa/Cocoa.h>
#include <sys/time.h>

#import "EntireLayout.h"
#import "LayoutController.h"
#import "NSMigrationManagerCategory.h"
#import "ScheduledTrain.h"

// Creates NSManagedObjectModel for the named database schema.
NSManagedObjectModel *managedObjectModel(NSString* momPath) {
    NSURL *modelURL = [NSURL fileURLWithPath:momPath];
    return [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
}

// Generates the NSManagedObjectContext for the named persistent layout and schema.
NSManagedObjectContext *managedObjectContext(NSString* momPath, NSString* storePath) {
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: managedObjectModel(momPath)];
    [context setPersistentStoreCoordinator: coordinator];
	
    NSString *STORE_TYPE = NSXMLStoreType;
    NSURL *url = [NSURL fileURLWithPath:storePath];
    NSError *error;
    NSPersistentStore *newStore = [coordinator addPersistentStoreWithType:STORE_TYPE configuration:nil URL:url options:nil error:&error];
	
    if (newStore == nil) {
        NSLog(@"ERROR: %@: Store Configuration Failure\n%@", storePath,
              ([error localizedDescription] != nil) ?
              [error localizedDescription] : @"Unknown Error");
		return nil;
    }
	
    return context;
}

// Calculates total number of cargos that were created but couldn't be filled
// because of lack of cars.  Used as metric to indicate potential trouble.
int CargosNotFilled(NSDictionary* unfilledDict) {
	int totalCount = 0;
	for (NSNumber *count in [unfilledDict allValues]) {
		totalCount += [count intValue];
	}
	return totalCount;
}

// Runs the layout through several cycles of assigning cars, running trains, and advancing cars.
// Prints informative error and returns NO if anything appears wrong, else returns YES.
BOOL TestLayout(char *layoutName) {
	NSString *filename = [NSString stringWithUTF8String: layoutName];
	if ([[NSFileManager defaultManager] fileExistsAtPath: filename] == NO) {
		fprintf(stderr, "ERROR: No such file %s\n", layoutName);
		return NO;
	}

	// TODO(bowdidge): Infer or allow as parameter.
	NSString *pathToMom =  @"/SharedProducts/Debug/SwitchList.app/Contents/Resources/SwitchListDocument.momd/SwitchListDocument 4.mom";
	if ([[NSFileManager defaultManager] fileExistsAtPath: pathToMom] == NO) {
		NSLog(@"FAIL: %@: Configuration error: expected schema file at %@, but not found", filename, pathToMom);
		return NO;
	}

	NSManagedObjectContext *context = managedObjectContext(pathToMom, filename);
	if (!context) {
		NSLog(@"FAIL: %@: Setup error: problems loading file.  (Incompatible version?)", layoutName);
		return NO;
	}
	EntireLayout *entireLayout = [[EntireLayout alloc] initWithMOC: context];
	int carCount = [[entireLayout allFreightCars] count];
	NSLog(@"Layout is %@, %d cars", filename, carCount);
	NSArray *allTrains = [entireLayout allTrains];
	LayoutController *controller = [[LayoutController alloc] initWithEntireLayout: entireLayout];
	int i;
	for (i=0;i<10;i++) {
		[controller advanceLoads];
		NSDictionary *unfilledCargosDict = [controller createAndAssignNewCargos: (carCount / 4)];
		int cargosNotFilled = CargosNotFilled(unfilledCargosDict);
		
		NSArray *errs = [controller assignCarsToTrains: allTrains respectSidingLengths: YES useDoors: YES];
		
		int carsMoved = 0;
		for (ScheduledTrain *train in allTrains) {
			carsMoved += [[train freightCars] count];
			[controller completeTrain: train];
		}
		if (carsMoved < 0.2 * carCount) {
			NSLog(@"FAIL: Insufficient cars moved: expected 0.2 * carCount (%d), got %d", 
				  carCount/5 , carsMoved);
			return NO;
		}
	    NSLog(@"PASS: iteration %d: Cars moved: %d, unfilled cargos: %d, assignment errors: %3d", i, carsMoved, cargosNotFilled, [errs count]);
	}

	[controller release];
	[entireLayout release];
	return YES;
}

// Takes a list of layout files on the command line, and runs each repeatedly to make sure the current
// car assignment, train generation, and car advancing code works well on real layouts.
int main(int argc, char *argv[]) {
	struct timeval tp;
	struct timezone tz;
	gettimeofday(&tp, &tz);
	srand(tp.tv_usec);
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// Workaround for bug in 10.5.
	[NSMigrationManager addRelationshipMigrationMethodIfMissing];

	int i;

	if (argc < 2) {
		fprintf(stderr, "Usage: testAdvanceLayoutsMain [layout files]+\n");
		exit(1);
	}
	
	int testsRun = 0;
	int testsPassed = 0;
	for (i=1;i<argc;i++) {
		BOOL result = NO;
		result = TestLayout(argv[i]);
		testsRun++;
		if (result) {
			testsPassed++;
		}
	}
	NSLog(@"%s: %d tests run, %d passed.", (testsRun == testsPassed ? "PASS" : "FAIL"), testsRun, testsPassed);
	[pool release];
	return 0;
}


