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

@implementation SwitchListTouchCatcherView
@synthesize delegate;

// Draws the little icon used to represent the actual switchlist.
// TODO(bowdidge): Badge to show number of freight cars?
- (id)initWithFrame:(CGRect)frame label: (NSString*) labelText {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor: [UIColor colorWithRed: 225.0 green: 225.0 blue:177.0 alpha: 0.5]];
    }
    UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(0.0,self.frame.size.height-20.0, self.frame.size.width, 20.0)];
    label.text = labelText;
    label.font = [UIFont systemFontOfSize: 10];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor colorWithRed: 235.0 green:235.0 blue:177.0 alpha: 0.5];
    [self addSubview: label];
    return self;
}

- (void) setController: (MainWindowViewController*) d {
    delegate = d;
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


@end
