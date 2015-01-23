//
//  PasteboardHelpers.m
//  SwitchList
//
//  Created by bowdidge on 1/21/15.
//
// Copyright (c)2015 Robert Bowdidge,
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
#import "EntireLayout.h"
#import "PasteboardHelpers.h"
#import "SwitchListAppDelegate.h"
#import "SwitchListDocument.h"

NSString * const CARGO_UTI = @"com.vasonabranch.Cargo";
NSString * const FREIGHT_CAR_UTI = @"com.vasonabranch.FreightCar";
NSString * const INDUSTRY_UTI = @"com.vasonabranch.Industry";
NSString * const SCHEDULED_TRAIN_UTI = @"com.vasonabranch.ScheduledTrain";
NSString * const TOWN_UTI = @"com.vasonabranch.Place";
NSString * const YARD_UTI = @"com.vasonabranch.Yard";

@implementation Cargo (Pasteboard)
- (NSArray *)writableTypesForPasteboard:(NSPasteboard *)pasteboard {
    static NSArray *writableTypes = nil;
    
    if (!writableTypes) {
        writableTypes = [[NSArray alloc] initWithObjects: CARGO_UTI, NSPasteboardTypeString, nil];
    }
    return writableTypes;
}

- (id)pasteboardPropertyListForType:(NSString *)type {
    
    if ([type isEqualToString: CARGO_UTI]) {
        return [NSKeyedArchiver archivedDataWithRootObject:self];
    }
    
    if ([type isEqualToString: NSPasteboardTypeString]) {
        return [self descriptionForCopy];
    }
    
    return nil;
}

- (void)encodeWithCoder:(NSCoder*)coder {
    [coder encodeObject: [self cargoDescription] forKey: @"cargoDescription"];
    [coder encodeInt:[self priority] forKey:@"priority"];
    [coder encodeInt:[self rate] forKey:@"rate"];
    [coder encodeInt:[self rateUnits] forKey:@"rateUnits"];
    [coder encodeInt:[self unloadingDays] forKey:@"unloadingDays"];
}

- (id) initWithCoder: (NSCoder*) decoder {
    SwitchListAppDelegate *appDelegate = [SwitchListAppDelegate sharedAppDelegate];
    EntireLayout *layout = [[appDelegate currentDocument] entireLayout];
    NSManagedObjectContext *context = [[layout workbenchIndustry] managedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName: @"Cargo" inManagedObjectContext: context];
    if (self = [super initWithEntity:entityDescription insertIntoManagedObjectContext:context] ) {
        self.cargoDescription = [decoder decodeObjectForKey: @"cargoDescription"];
        self.priority = [decoder decodeIntForKey: @"priority"];
        self.rate = [decoder decodeIntForKey: @"rate"];
        self.rateUnits = [decoder decodeIntForKey: @"rateUnits"];
        self.unloadingDays = [decoder decodeIntForKey: @"unloadingDays"];
    }
    return self;
}

+ (NSArray *)readableTypesForPasteboard:(NSPasteboard *)pasteboard {
    
    static NSArray *readableTypes = nil;
    if (!readableTypes) {
        readableTypes = [[NSArray alloc] initWithObjects:CARGO_UTI, nil];
    }
    return readableTypes;
}

+ (NSPasteboardReadingOptions)readingOptionsForType:(NSString *)type pasteboard:(NSPasteboard *)pboard {
    if ([type isEqualToString:CARGO_UTI]) {
        return NSPasteboardReadingAsKeyedArchive;
    }
    return 0;
}
@end

@implementation FreightCar (Pasteboard)


- (NSArray *)writableTypesForPasteboard:(NSPasteboard *)pasteboard {
    static NSArray *writableTypes = nil;
    
    if (!writableTypes) {
        writableTypes = [[NSArray alloc] initWithObjects:FREIGHT_CAR_UTI, NSPasteboardTypeString, nil];
    }
    return writableTypes;
}

- (id)pasteboardPropertyListForType:(NSString *)type {
    
    if ([type isEqualToString:FREIGHT_CAR_UTI]) {
        return [NSKeyedArchiver archivedDataWithRootObject:self];
    }
    
    if ([type isEqualToString:NSPasteboardTypeString]) {
        return [self descriptionForCopy];
    }
    
    return nil;
}

- (void)encodeWithCoder:(NSCoder*)coder {
    [coder encodeObject: [self reportingMarks] forKey:@"reportingMarks"];
    [coder encodeInt:[self length] forKey:@"length"];
    [coder encodeObject: [self homeDivision] forKey: @"homeDivision"];
}

- (id) initWithCoder: (NSCoder*) decoder {
    SwitchListAppDelegate *appDelegate = [SwitchListAppDelegate sharedAppDelegate];
    EntireLayout *layout = [[appDelegate currentDocument] entireLayout];
    NSManagedObjectContext *context = [[layout workbenchIndustry] managedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName: @"FreightCar" inManagedObjectContext: context];
    if (self = [super initWithEntity:entityDescription insertIntoManagedObjectContext:context] ) {
        self.reportingMarks = [decoder decodeObjectForKey: @"reportingMarks"];
        self.length = [decoder decodeIntForKey: @"length"];
        self.homeDivision = [decoder decodeObjectForKey: @"homeDivision"];
    }
    return self;
}

+ (NSArray *)readableTypesForPasteboard:(NSPasteboard *)pasteboard {
    
    static NSArray *readableTypes = nil;
    if (!readableTypes) {
        readableTypes = [[NSArray alloc] initWithObjects:FREIGHT_CAR_UTI, nil];
    }
    return readableTypes;
}

+ (NSPasteboardReadingOptions)readingOptionsForType:(NSString *)type pasteboard:(NSPasteboard *)pboard {
    if ([type isEqualToString:FREIGHT_CAR_UTI]) {
        return NSPasteboardReadingAsKeyedArchive;
    }
    return 0;
}
@end

@implementation Industry (Pasteboard)
- (NSArray *)writableTypesForPasteboard:(NSPasteboard *)pasteboard {
    static NSArray *writableTypes = nil;
    
    if (!writableTypes) {
        writableTypes = [[NSArray alloc] initWithObjects: INDUSTRY_UTI, NSPasteboardTypeString, nil];
    }
    return writableTypes;
}

- (id)pasteboardPropertyListForType:(NSString *)type {
    
    if ([type isEqualToString: INDUSTRY_UTI]) {
        return [NSKeyedArchiver archivedDataWithRootObject:self];
    }
    
    if ([type isEqualToString: NSPasteboardTypeString]) {
        return [self descriptionForCopy];
    }
    
    return nil;
}

- (void)encodeWithCoder:(NSCoder*)coder {
    [coder encodeObject: [self name] forKey:@"name"];
    [coder encodeObject: [self division] forKey: @"division"];
    [coder encodeInt:[self hasDoors] forKey:@"hasDoors"];
    [coder encodeInt:[self numberOfDoors] forKey:@"numberOfDoors"];
    [coder encodeInt:[self isYard] forKey:@"isYard"];
    [coder encodeInt:[self sidingLength] forKey:@"sidingLength"];
}

- (id) initWithCoder: (NSCoder*) decoder {
    SwitchListAppDelegate *appDelegate = [SwitchListAppDelegate sharedAppDelegate];
    EntireLayout *layout = [[appDelegate currentDocument] entireLayout];
    NSManagedObjectContext *context = [[layout workbenchIndustry] managedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName: @"Industry" inManagedObjectContext: context];
    if (self = [super initWithEntity:entityDescription insertIntoManagedObjectContext:context] ) {
        self.name = [decoder decodeObjectForKey: @"name"];
        self.division = [decoder decodeObjectForKey: @"division"];
        self.hasDoors = [decoder decodeIntForKey: @"hasDoors"];
        self.numberOfDoors = [decoder decodeIntForKey: @"numberOfDoors"];
        self.isYard = [decoder decodeIntForKey: @"isYard"];
        self.sidingLength = [decoder decodeIntForKey: @"sidingLength"];
    }
    return self;
}

+ (NSArray *)readableTypesForPasteboard:(NSPasteboard *)pasteboard {
    
    static NSArray *readableTypes = nil;
    if (!readableTypes) {
        readableTypes = [[NSArray alloc] initWithObjects:INDUSTRY_UTI, nil];
    }
    return readableTypes;
}

+ (NSPasteboardReadingOptions)readingOptionsForType:(NSString *)type pasteboard:(NSPasteboard *)pboard {
    if ([type isEqualToString:INDUSTRY_UTI]) {
        return NSPasteboardReadingAsKeyedArchive;
    }
    return 0;
}
@end

@implementation Place (Pasteboard)
- (NSArray *)writableTypesForPasteboard:(NSPasteboard *)pasteboard {
    static NSArray *writableTypes = nil;
    
    if (!writableTypes) {
        writableTypes = [[NSArray alloc] initWithObjects: TOWN_UTI, NSPasteboardTypeString, nil];
    }
    return writableTypes;
}

- (id)pasteboardPropertyListForType:(NSString *)type {
    
    if ([type isEqualToString: TOWN_UTI]) {
        return [NSKeyedArchiver archivedDataWithRootObject:self];
    }
    
    if ([type isEqualToString: NSPasteboardTypeString]) {
        return [self descriptionForCopy];
    }
    
    return nil;
}

- (void)encodeWithCoder:(NSCoder*)coder {
    [coder encodeObject: [self name] forKey: @"name"];
    [coder encodeInt:[self isOffline] forKey:@"isOffline"];
    [coder encodeInt:[self isStaging] forKey:@"isStaging"];
}

- (id) initWithCoder: (NSCoder*) decoder {
    SwitchListAppDelegate *appDelegate = [SwitchListAppDelegate sharedAppDelegate];
    EntireLayout *layout = [[appDelegate currentDocument] entireLayout];
    NSManagedObjectContext *context = [[layout workbenchIndustry] managedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName: @"Place" inManagedObjectContext: context];
    if (self = [super initWithEntity:entityDescription insertIntoManagedObjectContext:context] ) {
        self.name = [decoder decodeObjectForKey: @"name"];
        self.isOffline = [decoder decodeIntForKey: @"isOffline"];
        self.isStaging = [decoder decodeIntForKey: @"isStaging"];
    }
    return self;
}

+ (NSArray *)readableTypesForPasteboard:(NSPasteboard *)pasteboard {
    
    static NSArray *readableTypes = nil;
    if (!readableTypes) {
        readableTypes = [[NSArray alloc] initWithObjects:TOWN_UTI, nil];
    }
    return readableTypes;
}

+ (NSPasteboardReadingOptions)readingOptionsForType:(NSString *)type pasteboard:(NSPasteboard *)pboard {
    if ([type isEqualToString:TOWN_UTI]) {
        return NSPasteboardReadingAsKeyedArchive;
    }
    return 0;
}
@end

@implementation ScheduledTrain (Pasteboard)
- (NSArray *)writableTypesForPasteboard:(NSPasteboard *)pasteboard {
    static NSArray *writableTypes = nil;
    
    if (!writableTypes) {
        writableTypes = [[NSArray alloc] initWithObjects: SCHEDULED_TRAIN_UTI, NSPasteboardTypeString, nil];
    }
    return writableTypes;
}

- (id)pasteboardPropertyListForType:(NSString *)type {
    
    if ([type isEqualToString: SCHEDULED_TRAIN_UTI]) {
        return [NSKeyedArchiver archivedDataWithRootObject:self];
    }
    
    if ([type isEqualToString: NSPasteboardTypeString]) {
        return [self descriptionForCopy];
    }
    
    return nil;
}

- (void)encodeWithCoder:(NSCoder*)coder {
    [coder encodeObject: [self name] forKey:@"name"];
    [coder encodeInt:[self minCarsToRun] forKey:@"minCarsToRun"];
    //[coder encodeObject: [self stationsInOrder] forKey: @"stationsInOrder"];
}

- (id) initWithCoder: (NSCoder*) decoder {
    SwitchListAppDelegate *appDelegate = [SwitchListAppDelegate sharedAppDelegate];
    EntireLayout *layout = [[appDelegate currentDocument] entireLayout];
    NSManagedObjectContext *context = [[layout workbenchIndustry] managedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName: @"ScheduledTrain" inManagedObjectContext: context];
    if (self = [super initWithEntity:entityDescription insertIntoManagedObjectContext:context] ) {
        self.name = [decoder decodeObjectForKey: @"name"];
        self.minCarsToRun = [decoder decodeIntForKey: @"minCarsToRun"];
        //self.stationsInOrder = [decoder decodeObjectForKey: @"stationsInOrder"];
    }
    return self;
}

+ (NSArray *)readableTypesForPasteboard:(NSPasteboard *)pasteboard {
    
    static NSArray *readableTypes = nil;
    if (!readableTypes) {
        readableTypes = [[NSArray alloc] initWithObjects:SCHEDULED_TRAIN_UTI, nil];
    }
    return readableTypes;
}

+ (NSPasteboardReadingOptions)readingOptionsForType:(NSString *)type pasteboard:(NSPasteboard *)pboard {
    if ([type isEqualToString:SCHEDULED_TRAIN_UTI]) {
        return NSPasteboardReadingAsKeyedArchive;
    }
    return 0;
}
@end

@implementation Yard (Pasteboard)
- (NSArray *)writableTypesForPasteboard:(NSPasteboard *)pasteboard {
    static NSArray *writableTypes = nil;
    
    if (!writableTypes) {
        writableTypes = [[NSArray alloc] initWithObjects: YARD_UTI, NSPasteboardTypeString, nil];
    }
    return writableTypes;
}

- (id)pasteboardPropertyListForType:(NSString *)type {
    
    if ([type isEqualToString: YARD_UTI]) {
        return [NSKeyedArchiver archivedDataWithRootObject:self];
    }
    
    if ([type isEqualToString: NSPasteboardTypeString]) {
        return [self descriptionForCopy];
    }
    
    return nil;
}

- (void)encodeWithCoder:(NSCoder*)coder {
    [coder encodeObject: [self name] forKey: @"name"];
}

- (id) initWithCoder: (NSCoder*) decoder {
    SwitchListAppDelegate *appDelegate = [SwitchListAppDelegate sharedAppDelegate];
    EntireLayout *layout = [[appDelegate currentDocument] entireLayout];
    NSManagedObjectContext *context = [[layout workbenchIndustry] managedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName: @"Yard" inManagedObjectContext: context];
    if (self = [super initWithEntity:entityDescription insertIntoManagedObjectContext:context] ) {
        self.name = [decoder decodeObjectForKey: @"name"];
    }
    return self;
}

+ (NSArray *)readableTypesForPasteboard:(NSPasteboard *)pasteboard {
    
    static NSArray *readableTypes = nil;
    if (!readableTypes) {
        readableTypes = [[NSArray alloc] initWithObjects:YARD_UTI, nil];
    }
    return readableTypes;
}

+ (NSPasteboardReadingOptions)readingOptionsForType:(NSString *)type pasteboard:(NSPasteboard *)pboard {
    if ([type isEqualToString:YARD_UTI]) {
        return NSPasteboardReadingAsKeyedArchive;
    }
    return 0;
}
@end
