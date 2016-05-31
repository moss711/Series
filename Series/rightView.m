//
//  rightView.m
//  pruebaSegundaVentana
//
//  Created by Alexandre Blanco Gómez on 1/11/14.
//  Copyright (c) 2014 Horseware. All rights reserved.
//

#import "rightView.h"

@implementation rightView

- (void)drawRect:(NSRect)dirtyRect {
    //Hex to nscolor
//    NSColor* result = nil;
//    unsigned colorCode = 0;
//    unsigned char redByte, greenByte, blueByte;
//    
//    
//    NSScanner* scanner = [NSScanner scannerWithString:@"f9f8f4"];
//    (void) [scanner scanHexInt:&colorCode]; // ignore error
//    
//    redByte = (unsigned char)(colorCode >> 16);
//    greenByte = (unsigned char)(colorCode >> 8);
//    blueByte = (unsigned char)(colorCode); // masks off high bits
//    
//    result = [NSColor
//              colorWithCalibratedRed:(CGFloat)redByte / 0xff
//              green:(CGFloat)greenByte / 0xff
//              blue:(CGFloat)blueByte / 0xff
//              alpha:1.0];
    
    // set any NSColor for filling, say white:
    [[NSColor whiteColor] setFill];
    //[result setFill];
    NSRectFill(dirtyRect);
    [super drawRect:dirtyRect];
}

@end
