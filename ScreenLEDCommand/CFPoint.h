//
//  CFPoint.h
//  ScreenLEDCommand
//
//  Created by Daniel Eke on 2018. 02. 20..
//  Copyright © 2018. Daniel Eke. All rights reserved.
//

// Source: https://github.com/buranmert/ColorFinder

#import <Cocoa/Cocoa.h>

@interface CFPoint : NSObject

@property (nonatomic) CGFloat red;
@property (nonatomic) CGFloat green;
@property (nonatomic) CGFloat blue;
@property (nonatomic) CGFloat alpha;

- (CGFloat)getDistanceToPoint:(CFPoint *)otherPoint;
- (NSColor *)getColor;
    
@end
