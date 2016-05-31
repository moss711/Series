//
//  DragableWindow.m
//  pruebaSegundaVentana
//
//  Created by Alexandre Blanco Gómez on 1/11/14.
//  Copyright (c) 2014 Horseware. All rights reserved.
//

#import "ventanaSerie.h"

@implementation ventanaSerie

-(BOOL)isMovableByWindowBackground{
    return YES;
}
-(BOOL)canBecomeKeyWindow{
    return YES;
}

@end
