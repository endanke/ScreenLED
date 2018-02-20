//
//  main.m
//  ScreenLEDCommand
//
//  Created by Daniel Eke on 2017. 08. 18..
//  Copyright © 2017. Daniel Eke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ScreenLED.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        ScreenLED* screenLED = [[ScreenLED alloc] init];
        [[NSRunLoop mainRunLoop] run];
    }
    return 0;
}
