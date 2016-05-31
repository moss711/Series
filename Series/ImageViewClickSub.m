//
//  ImageViewClickSub.m
//  TvTime
//
//  Created by Alexandre Blanco Gómez on 17/08/14.
//  Copyright (c) 2014 Horseware. All rights reserved.
//

#import "ImageViewClickSub.h"
#import "TableViewModif.h"
#import "AppDelegate.h"
#import "CeldaAnteriorSub.h"

@implementation ImageViewClickSub

NSTrackingArea *trackingArea;

- (void) awakeFromNib{
    [super awakeFromNib];
    trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds
                                                                options: (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways |NSTrackingInVisibleRect)
                                                                  owner:self userInfo:nil];
    [self addTrackingArea:trackingArea];
}

- (void)updateTrackingAreas {
    [self removeTrackingArea:trackingArea];
    trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds]
                                                options: (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways |NSTrackingInVisibleRect)
                                                  owner:self userInfo:nil];
    [self addTrackingArea:trackingArea];
    
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:frame
                                                                    options: (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways )
                                                                      owner:self userInfo:nil];
        [self addTrackingArea:trackingArea];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)mouseDown:(NSEvent *)theEvent {
    if(self.isEnabled){
        TableViewModif *tableview=(TableViewModif *)self.superview.superview.superview;
        
        [(AppDelegate*)[NSApplication sharedApplication].delegate descargaSubtituloConIndices:[[NSIndexSet alloc] initWithIndex:[tableview rowForView:self.superview]]];
        //NSLog(@"%ld",(long)[tableview rowForView:self.superview]);
    }else{
        NSBeep();//Y avisar de que no hay subtitulo con la pantallita de notificacion
    }
}

- (void) mouseEntered:(NSEvent*)theEvent {
    //NSLog(@"MouseEntered sub");
    CeldaAnteriorSub *row=(CeldaAnteriorSub *)self.superview;
    if(self.isEnabled==YES){
        [row highlightSub];
    }

}

- (void) mouseExited:(NSEvent*)theEvent {
     //NSLog(@"MouseExited sub");
    CeldaAnteriorSub *row=(CeldaAnteriorSub *)self.superview;
    [row quitarHighlight];
}

@end
