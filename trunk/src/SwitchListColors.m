//
//  SwitchListColors.m
//  SwitchList
//
//  Created by Robert Bowdidge on 9/17/12.
//
//

#import <UIKit/UIKit.h>
#import "SwitchListColors.h"

@implementation SwitchListColors

+ (UIColor*) switchListDarkBeige {
    return [UIColor colorWithRed:227/256.0 green:218/256.0 blue:171/256.0 alpha:1.0];
}
// Used for highlighting on edge of main screen insets.
+ (UIColor*) switchListMediumBeige {
    return [UIColor colorWithRed: 238/256.0 green: 229/256.0 blue: 179/256.0 alpha: 1.0];
}

// Used for table cells.
+ (UIColor*) switchListLightBeige {
    return [UIColor colorWithRed:245/256.0 green:245/256.0 blue: 220/256.0 alpha:1.0];
}

@end