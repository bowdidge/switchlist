//
//  MGTemplateStandardFilters.m
//
//  Created by Matt Gemmell on 13/05/2008.
//  Copyright 2008 Instinctive Code. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MGTemplateStandardFilters.h"


#define UPPERCASE		@"uppercase"
#define LOWERCASE		@"lowercase"
#define CAPITALIZED		@"capitalized"
#define DATE_FORMAT		@"date_format"
#define COLOR_FORMAT	@"color_format"
#define DEFAULT         @"default"
#define UNLESS         @"unless"


@implementation MGTemplateStandardFilters


- (NSArray *)filters
{
	return [NSArray arrayWithObjects:
			UPPERCASE, LOWERCASE, CAPITALIZED, 
			DATE_FORMAT, COLOR_FORMAT, DEFAULT,
            UNLESS,
			nil];
}

- (NSString*) stringsConcatenatedWithSpaces: (NSArray*) array {
    NSMutableString* result = [NSMutableString string];
    for (NSString* item in array) {
        [result appendFormat: @"%@ ", item];
    }
    return result;
}
- (NSObject *)filterInvoked:(NSString *)filter withArguments:(NSArray *)args onValue:(NSObject *)value;
{
	if ([filter isEqualToString:UPPERCASE]) {
        if (!value) return nil;
		return [[NSString stringWithFormat:@"%@", value] uppercaseString];
		
	} else if ([filter isEqualToString:LOWERCASE]) {
        if (!value) return nil;
		return [[NSString stringWithFormat:@"%@", value] lowercaseString];
		
	} else if ([filter isEqualToString:CAPITALIZED]) {
        if (!value) return nil;
		return [[NSString stringWithFormat:@"%@", value] capitalizedString];
		
	} else if ([filter isEqualToString:DATE_FORMAT]) {
        if (!value) return nil;
		// Formats NSDates according to Unicode syntax:
		// http://unicode.org/reports/tr35/tr35-4.html#Date_Format_Patterns 
		// e.g. "dd MM yyyy" etc.
		if ([value isKindOfClass:[NSDate class]] && [args count] == 1) {
			NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
			[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
			NSString *format = [args objectAtIndex:0];
			[dateFormatter setDateFormat:format];
			return [dateFormatter stringFromDate:(NSDate *)value];
		}

	} else if ([filter isEqualToString:COLOR_FORMAT]) {
		// TODO(bowdidge): Better fix than deleting code.
		// Leave out the color functionality - it relies on NSColor, and would
		// require linking this code with Cocoa.
	} else if ([filter isEqualToString: DEFAULT]) {
        if (!value) {
            return [self stringsConcatenatedWithSpaces: args];
        }
        if ([value isKindOfClass: [NSString class]] && [(NSString*)value length] == 0) {
            return [self stringsConcatenatedWithSpaces: args];;
        }
    }
    return value;
}


@end
