//
//  SwitchListTouchCatcherView.m
//  SwitchList for iPad
//
//  Created by Robert Bowdidge on 9/6/12.
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

#import "SwitchListTouchCatcherView.h"

#import "ScheduledTrain.h"

@implementation SwitchListTouchCatcherView

// Draws the little icon used to represent the actual switchlist.
// TODO(bowdidge): Badge to show number of freight cars?
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor: [UIColor colorWithRed: 0.0 green: 0.0 blue:0.0 alpha: 0.0]];
    }
    return self;
}

- (void) setController: (MainWindowViewController*) d {
    delegate = d;
}

// Draw the switchlist icon used for selecting a report or switchlist to view.
// Draws a iconic miniature switchlist, and a badge showing the number of cars still
// to switch.
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    int carCount = [[train freightCars] count];
    BOOL isEmptyTrain = (carCount == 0);
    
    // Empty train icons should be slightly washed out.
    CGContextSetAlpha(context, (train && isEmptyTrain ? 0.5 : 1.0));
    CGContextSetShadow(context, CGSizeMake(5.0, 5.0), 3.0);
    
    // Draw the sample switchlist icon.
    NSString *filename = [[NSBundle mainBundle] pathForResource: @"switchlistButton" ofType: @"png"];
    CGDataProviderRef imgDataProvider = CGDataProviderCreateWithCFData((CFDataRef)[NSData dataWithContentsOfFile: filename]);
    CGImageRef switchlistButtonImage = CGImageCreateWithPNGDataProvider(imgDataProvider, NULL, true, kCGRenderingIntentDefault);
    CGRect imageRect = CGRectMake(0.0, 0.0, 95.0, 160.0);
    CGContextDrawImage(context, imageRect, switchlistButtonImage);
    
   
    if (train) {
        // Draw badge: red circle with radius 20 centered at lower right corner,
        // and white text for count or checkbox to indicate completed.
        CGContextSetRGBFillColor(context, 0.6, 0.0, 0.0, 1.0);
        CGContextFillEllipseInRect(context, CGRectMake(70, 130, 40, 40));
    }
    
    // Turn down shadow for text.
    CGContextSetShadow(context, CGSizeMake(2.0, 2.0), 2.0);
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
 
    if (train) {
        // Only badges for trains.
        NSString *carCountString = nil;
        if (carCount != 0) {
            carCountString = [NSString stringWithFormat: @"%d", carCount];
        } else {
            // Check symbol.
            carCountString = @"\u2713";
        }
    
        // Draw count on the badge.
        [carCountString drawInRect: CGRectMake(70, 140, 40, 20)
                          withFont: [UIFont boldSystemFontOfSize: 19.0]
                     lineBreakMode: UILineBreakModeClip alignment: UITextAlignmentCenter];
    
    }
    
    NSString *iconTitle = nil;
    if (train) {
        iconTitle = [self.train name];
    } else {
        iconTitle = self.label;
    }
    
    // Draw train name in black over icon.
    CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
    CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 1.0);

    [iconTitle drawInRect: CGRectMake(0.0, 10.0, 95.0, 30.0)
                            withFont: [UIFont boldSystemFontOfSize: 13.0]
                        lineBreakMode: UILineBreakModeClip alignment: UITextAlignmentCenter];
}

// Dispatches touches back to the main view to change view to the witchlist of interest.
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // UITouch *touch = [[event allTouches] anyObject];
    [delegate didTouchSwitchList: self];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect
//{
    // Drawing code
 //}


@synthesize delegate;
@synthesize label;
@synthesize train;
@end
