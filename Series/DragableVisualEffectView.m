//
//  DragableVisualEffectView.m
//  pruebaSegundaVentana
//
//  Created by Alexandre Blanco Gómez on 1/11/14.
//  Copyright (c) 2014 Horseware. All rights reserved.
//

#import "DragableVisualEffectView.h"

@implementation DragableVisualEffectView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (BOOL)mouseDownCanMoveWindow{
    return YES;
}
@end
