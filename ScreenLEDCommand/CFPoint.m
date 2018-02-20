//
//  CFPoint.m
//  ScreenLEDCommand
//
//  Created by Daniel Eke on 2018. 02. 20..
//  Copyright © 2018. Daniel Eke. All rights reserved.
//

#import "CFPoint.h"

@implementation CFPoint

- (CGFloat)getDistanceToPoint:(CFPoint *)otherPoint {
    CGFloat distance = 0.f;
    distance += fabs(self.red - otherPoint.red);
    distance += fabs(self.green - otherPoint.green);
    distance += fabs(self.blue - otherPoint.blue);
    distance += fabs(self.alpha - otherPoint.alpha);
    return distance;
}

- (NSColor *)getColor {
    return [NSColor colorWithRed:self.red/255.f green:self.green/255.f blue:self.blue/255.f alpha:self.alpha/255.f];
}

@end
