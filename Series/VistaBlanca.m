//
//  VistaBlanca.m
//  TvTime
//
//  Created by Alexandre Blanco Gómez on 27/7/15.
//  Copyright (c) 2015 Horseware. All rights reserved.
//

#import "VistaBlanca.h"

@implementation VistaBlanca

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    // Drawing code here.
    [[NSColor whiteColor] setFill];
    //[result setFill];
    NSRectFill(dirtyRect);
    [super drawRect:dirtyRect];
}

@end
