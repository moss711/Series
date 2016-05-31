//
//  VistaSeparador.m
//  TvTime
//
//  Created by Alexandre Blanco Gómez on 27/7/15.
//  Copyright (c) 2015 Horseware. All rights reserved.
//

#import "VistaSeparador.h"

@implementation VistaSeparador

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    [[NSColor gridColor] setFill];
    //[result setFill];
    NSRectFill(dirtyRect);
    [super drawRect:dirtyRect];
}

@end
