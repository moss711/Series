//
//  TableViewBusqueda.m
//  TvTime
//
//  Created by Alexandre Blanco Gómez on 28/07/14.
//  Copyright (c) 2014 Horseware. All rights reserved.
//

#import "TableViewBusqueda.h"
#import "AppDelegate.h"

@implementation TableViewBusqueda


- (void)keyDown:(NSEvent *)theEvent
{
    unichar key = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
    if(key == NSEnterCharacter)
    {
        //NSLog(@"Pulsado enter");
        [self enter];
        return;
    }
    if(key == NSCarriageReturnCharacter)
    {
        //NSLog(@"Pulsado retorno de carro");
        [self enter];
        return;
    }
    
    [super keyDown:theEvent];
    
}

-(void)enter{
    [(AppDelegate*)[NSApplication sharedApplication].delegate popoverAnadir:self];
}


@end
