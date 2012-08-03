//
//  NSArray_DeepMutableCopy.m
//
//  Created by Matt Gemmell on 02/05/2008.
//  Copyright 2008 Instinctive Code. All rights reserved.
//

#import "NSArray_DeepMutableCopy.h"


@implementation NSArray (DeepMutableCopy)


- (NSMutableArray *)deepMutableCopy;
{
    NSMutableArray *newArray;
    unsigned int index, count;
	
    count = [self count];
    newArray = [[NSMutableArray allocWithZone:[self zone]] initWithCapacity:count];
    for (index = 0; index < count; index++) {
        id anObject;
		
        anObject = [self objectAtIndex:index];
        if ([anObject respondsToSelector:@selector(deepMutableCopy)]) {
            id anObject2 = [anObject deepMutableCopy];
            [newArray addObject:anObject2];
            [anObject2 release];
        } else if ([anObject respondsToSelector:@selector(mutableCopyWithZone:)]) {
            id anObject2 = [anObject mutableCopyWithZone:nil];
            [newArray addObject:anObject2];
            [anObject2 release];
        } else {
            [newArray addObject:anObject];
        }
    }
	
    return newArray;
}


@end
