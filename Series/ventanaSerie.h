//
//  DragableWindow.h
//  pruebaSegundaVentana
//
//  Created by Alexandre Blanco Gómez on 1/11/14.
//  Copyright (c) 2014 Horseware. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ventanaSerie : NSWindow

-(BOOL)isMovableByWindowBackground;
-(BOOL)canBecomeKeyWindow;
@end
