//
//  CFCluster.h
//  ScreenLEDCommand
//
//  Created by Daniel Eke on 2018. 02. 20..
//  Copyright © 2018. Daniel Eke. All rights reserved.
//

// Source: https://github.com/buranmert/ColorFinder

#import <Cocoa/Cocoa.h>
#import "CFPoint.h"

@interface CFCluster : NSObject

@property (nonatomic, strong) NSMutableArray *points;
@property (nonatomic, strong) CFPoint *center;

- (instancetype)initWithPoint:(CFPoint *)point;
- (void)addPoint:(CFPoint *)point;
- (NSUInteger)getWeight;
- (void)updateCenterWithNewPoint:(CFPoint *)newPoint;

@end
