//
//  CurlyView.m
//  SwitchList
//
//  Created by Robert Bowdidge on 9/21/12.
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

#import "CurlyView.h"

@implementation CurlyView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// Draw bezier curves between right side of leftRegion and left side of rightRegion for
// highlighting where the data comes from.
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetShadow(context, CGSizeMake(2.0, 2.0), 3.0);
    CGContextSetLineWidth(context, 2.0);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetAlpha(context, 0.5);
    
    UIBezierPath *path = [UIBezierPath bezierPath];

    // offset start to make up for curve of button.
    float leftOffset = 20.0;
    // Length of the invisible vector for controlling the curve.
    float controlPointOffset = 30.0;
    CGPoint upperLeft =  CGPointMake(self.leftRegion.origin.x + self.leftRegion.size.width - leftOffset,
                                     self.leftRegion.origin.y);
    CGPoint upperRight = CGPointMake(self.rightRegion.origin.x, self.rightRegion.origin.y);
    CGPoint lowerRight = CGPointMake(self.rightRegion.origin.x,
                                     self.rightRegion.origin.y + self.rightRegion.size.height);
    CGPoint lowerLeft = CGPointMake(self.leftRegion.origin.x + self.leftRegion.size.width - leftOffset,
                                    self.leftRegion.origin.y + self.leftRegion.size.height);
    
    [path moveToPoint: upperLeft];
    [path addCurveToPoint: upperRight
            controlPoint1: CGPointMake(upperLeft.x + controlPointOffset, upperLeft.y)
            controlPoint2: CGPointMake(upperRight.x - controlPointOffset, upperRight.y)];
    [path addLineToPoint: lowerRight];
    [path addCurveToPoint: lowerLeft
            controlPoint1: CGPointMake(lowerRight.x - controlPointOffset, lowerRight.y)
            controlPoint2: CGPointMake(lowerLeft.x + controlPointOffset, lowerLeft.y)];
    [path fill];
}

@synthesize leftRegion;
@synthesize rightRegion;
@end
