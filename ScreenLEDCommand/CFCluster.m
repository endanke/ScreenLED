//
//  CFCluster.m
//  ScreenLEDCommand
//
//  Created by Daniel Eke on 2018. 02. 20..
//  Copyright © 2018. Daniel Eke. All rights reserved.
//

#import "CFCluster.h"

@implementation CFCluster

- (instancetype)initWithPoint:(CFPoint *)point {
    self = [super init];
    if (self != nil) {
        _points = [NSMutableArray arrayWithObject:point];
        _center = point;
    }
    return self;
}

- (void)addPoint:(CFPoint *)point {
    [self updateCenterWithNewPoint:point];
    [self.points addObject:point];
}

- (NSUInteger)getWeight {
    return self.points.count;
}

- (void)updateCenterWithNewPoint:(CFPoint *)newPoint {
    CGFloat red = ((self.center.red * self.points.count) + newPoint.red) / (self.points.count + 1);
    CGFloat green = ((self.center.green * self.points.count) + newPoint.green) / (self.points.count + 1);
    CGFloat blue = ((self.center.blue * self.points.count) + newPoint.blue) / (self.points.count + 1);
    CGFloat alpha = ((self.center.alpha * self.points.count) + newPoint.alpha) / (self.points.count + 1);
    CFPoint *newCenter = [CFPoint new];
    newCenter.red = red;
    newCenter.green = green;
    newCenter.blue = blue;
    newCenter.alpha = alpha;
    self.center = newCenter;
}

@end
