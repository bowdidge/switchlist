//
//  NSMigrationManagerCategory.m
//  SwitchList
//
// Workaround for missing method in Mac OS X 10.5.  Code taken from Apple release notes.
//
#import <CoreData/CoreData.h>

@interface NSMigrationManager (Workaround)

+ (void)addRelationshipMigrationMethodIfMissing;

@end
