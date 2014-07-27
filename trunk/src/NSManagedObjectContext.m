#import "NSManagedObjectContext.h"
#import <CoreData/NSPersistentStoreCoordinator.h>

// From http://www.litp.org/blog/?p=62

@implementation NSManagedObjectContext (UnitTests)

+ (NSManagedObjectContext *)inMemoryMOCFromBundle:(NSBundle *)appBundle withFile: (NSURL*) layoutUrl {
	// get model from app bundle passed into method
	NSArray *bundleArray = [NSArray arrayWithObject:appBundle];
	NSAssert([bundleArray count] == (unsigned)1, @"1 object in bundle array");
	NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:bundleArray];
    
	NSPersistentStoreCoordinator *coordinator = [[[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model] autorelease];
	if (coordinator == nil) {
		NSLog(@"Can't get instance of NSPersistentStoreCoordinator");
		return nil;
	}
	
	// Add an in-memory persistent store to the coordinator.
	NSMutableDictionary *options = [NSMutableDictionary dictionary];
    // Don't change the layout file.
    [options setObject: [NSNumber numberWithBool:YES] forKey: NSReadOnlyPersistentStoreOption];
    [options setObject: [NSNumber numberWithBool: YES] forKey: NSMigratePersistentStoresAutomaticallyOption];
    [options setObject: [NSNumber numberWithBool:YES] forKey: NSInferMappingModelAutomaticallyOption];
	
    NSString *storeType = NSXMLStoreType;
    if (layoutUrl == nil) {
        storeType = NSInMemoryStoreType;
    }
	NSError *addStoreError = nil;
	if (![coordinator addPersistentStoreWithType: storeType configuration:nil URL: layoutUrl options:options error:&addStoreError]) {
		NSLog(@"Error setting up in-memory store unit test: %@ ", addStoreError);
		return nil;
	}
	
	// Now we can set up the managed object context and assign it to persistent store coordinator.
	NSManagedObjectContext *context = [[[NSManagedObjectContext alloc] init] autorelease];
	[context setPersistentStoreCoordinator: coordinator];
	NSAssert( context != nil, @"Can't set up managed object context for unit test.");
	
	return [[context retain] autorelease];
}

@end