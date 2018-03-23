//
//  ScreenLED.m
//  ScreenLEDCommand
//
//  Created by Daniel Eke on 2017. 08. 18..
//  Copyright © 2017. Daniel Eke. All rights reserved.
//

#import "ScreenLED.h"
#import "ORSSerialPort.h"
#import "ORSSerialRequest.h"
#import "CFPoint.h"
#import "CFCluster.h"

@interface ScreenLED()

@property ORSSerialPort *serialPort;

@property NSColor *a;
@property NSColor *b;
@property NSColor *c;

@property NSMutableArray *prevColors;
@property NSMutableArray *stepColors;
@property NSMutableArray *currentColors;

@property float iteration;
@property dispatch_source_t fetchTimer;
@property dispatch_source_t sendTimer;

@end

@implementation ScreenLED

dispatch_source_t CreateDispatchTimer(double interval, dispatch_queue_t queue, dispatch_block_t block)
{
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    if (timer)
    {
        dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, interval * NSEC_PER_SEC), interval * NSEC_PER_SEC, (1ull * NSEC_PER_SEC) / 10);
        dispatch_source_set_event_handler(timer, block);
        dispatch_resume(timer);
    }
    return timer;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self.serialPort = [ORSSerialPort serialPortWithPath:@"/dev/cu.usbmodem1441"];
        self.serialPort.baudRate = @57600;
        [self.serialPort open];
        
        self.prevColors = [@[[NSColor redColor],[NSColor redColor],[NSColor redColor]] mutableCopy];
        self.stepColors = [@[[NSColor redColor],[NSColor redColor],[NSColor redColor]] mutableCopy];
        self.currentColors = [@[[NSColor redColor],[NSColor redColor],[NSColor redColor]] mutableCopy];
        
        self.a = [NSColor redColor];
        self.b = [NSColor redColor];
        self.c = [NSColor redColor];
        
        self.iteration = 0;
        
        float sleepStep = 0.01;
        float sleepTime = 0;
        while(1){
            @autoreleasepool {
                if(sleepTime >= 0.04){
                    [self fetchColor];
                    sleepTime = 0;
                }
                [self send];
                sleepTime += sleepStep;
                [NSThread sleepForTimeInterval:sleepStep];
            }
        }
        
    }
    return self;
}

- (void)dealloc{
    [self.serialPort close];
}

#pragma mark - Image processing

- (void)fetchColor{
    CGImageRef cgimage = CGDisplayCreateImage(kCGDirectMainDisplay);
    float width = CGImageGetWidth(cgimage);
    float height = CGImageGetHeight(cgimage);
    float sampleSize = 32;
    CGImageRef part1 = CGImageCreateWithImageInRect(cgimage, CGRectMake(0, height/3, sampleSize, height/3));
    CGImageRef part2 = CGImageCreateWithImageInRect(cgimage, CGRectMake(width/2-sampleSize, height/2-sampleSize, sampleSize*2, sampleSize));
    CGImageRef part3 = CGImageCreateWithImageInRect(cgimage, CGRectMake(width-32, height/3, sampleSize, height/3));
    
    NSColor *newA = [self getDominantColorForImage:part1 sampleSize:sampleSize];
    NSColor *newB = [self getDominantColorForImage:part2 sampleSize:sampleSize];
    NSColor *newC = [self getDominantColorForImage:part3 sampleSize:sampleSize];
    CFRelease(part1);
    CFRelease(part2);
    CFRelease(part3);
    CFRelease(cgimage);
    
    // Fallback
    if(newA == nil) newA = [NSColor yellowColor];
    if(newB == nil) newB = [NSColor yellowColor];
    if(newC == nil) newC = [NSColor yellowColor];
    
    self.prevColors = [self.stepColors copy];
    self.currentColors = [@[newA, newB, newC] mutableCopy];
    self.iteration = 0;
}

// Based on: https://github.com/buranmert/ColorFinder
static const CGFloat CFColorThreshold = 80.f;
static const CGFloat CFInversePrecisionFactor = 16;
- (NSColor*)getDominantColorForImage:(CGImageRef)imageRef sampleSize:(NSUInteger)sampleSize{
    NSUInteger width = sampleSize;
    NSUInteger height = sampleSize;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSUInteger bytesPerPixel = 4;
    unsigned char *rawData = (unsigned char*) calloc(height * width * bytesPerPixel, sizeof(unsigned char));
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, colorSpace,  kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    // Now your rawData contains the image data in the RGBA8888 pixel format.
    NSUInteger rawDataCount = height * width * bytesPerPixel;
    NSMutableArray *clusterArray = [NSMutableArray array];
    for (int byteIndex = 0 ; byteIndex + bytesPerPixel*CFInversePrecisionFactor < rawDataCount ; byteIndex += bytesPerPixel * CFInversePrecisionFactor) {
        CFPoint *point = [CFPoint new];
        point.red   = rawData[byteIndex] * 1.f;
        point.green = rawData[byteIndex+1] * 1.f;
        point.blue  = rawData[byteIndex+2] * 1.f;
        point.alpha = rawData[byteIndex+3] * 1.f;
        
        __block NSInteger clusterIndex = -1;
        __block CGFloat closestDistance = CGFLOAT_MAX;
        [clusterArray enumerateObjectsUsingBlock:^(CFCluster *cluster, NSUInteger idx, BOOL *stop) {
            CGFloat distance = [cluster.center getDistanceToPoint:point];
            if (distance < CFColorThreshold && distance < closestDistance) {
                closestDistance = distance;
                clusterIndex = idx;
            }
        }];
        
        if (clusterIndex >= 0) {
            [((CFCluster *)[clusterArray objectAtIndex:clusterIndex]) addPoint:point];
        }
        else {
            CFCluster *newCluster = [[CFCluster alloc] initWithPoint:point];
            [clusterArray addObject:newCluster];
        }
        byteIndex += bytesPerPixel;
    }
    free(rawData);
    
    CFCluster *tempCluster = nil;
    for (CFCluster *cluster in clusterArray) {
        if (tempCluster == nil || [cluster getWeight] > [tempCluster getWeight]) {
            tempCluster = cluster;
        }
    }
    NSColor *dominantColor = [tempCluster.center getColor];
    return dominantColor;
}


#pragma mark - Sending related methods

- (void)send{
    // Step crossfade and send current color
    if(self.iteration < 10){
        for(int j = 0; j < [self.currentColors count]; j++){
            self.stepColors[j] = [self.prevColors[j] blendedColorWithFraction:0.1*self.iteration ofColor:self.currentColors[j]];
        }
        [self sendColors:self.stepColors[0] b:self.stepColors[1] c:self.stepColors[2]];
    }
    self.iteration++;
}


- (void)sendColors:(NSColor*)a b:(NSColor*)b c:(NSColor*)c {
    NSString *colorText = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@ %@ %@ %@",
                           [self stringFromColorComponent: c.redComponent],
                           [self stringFromColorComponent: c.greenComponent],
                           [self stringFromColorComponent: c.blueComponent],
                           
                           [self stringFromColorComponent: b.redComponent],
                           [self stringFromColorComponent: b.greenComponent],
                           [self stringFromColorComponent: b.blueComponent],
                           
                           [self stringFromColorComponent: a.redComponent],
                           [self stringFromColorComponent: a.greenComponent],
                           [self stringFromColorComponent: a.blueComponent]];
    NSData *data = [colorText dataUsingEncoding:NSUTF8StringEncoding];
    [self.serialPort sendData:data];
}

- (NSString*)stringFromColorComponent:(CGFloat)value{
    int result = value*255.0;
    return [NSString stringWithFormat:@"%03d", result];
}

@end


