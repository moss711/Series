//
//  CeldaAnteriorSub.m
//  TvTime
//
//  Created by Alexandre Blanco Gómez on 14/08/14.
//  Copyright (c) 2014 Horseware. All rights reserved.
//

#import "CeldaAnteriorSub.h"
#import "TableViewModif.h"
#import "AppDelegate.h"

@implementation CeldaAnteriorSub

NSTrackingArea *trackingArea;

- (void) awakeFromNib{
    [super awakeFromNib];
    //NSLog(@"x%f y%f height:%f width:%f",self.bounds.origin.x,self.bounds.origin.y,self.bounds.size.height,self.bounds.size.width);
    trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds]
                                                                options: (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways |NSTrackingInVisibleRect )
                                                                  owner:self userInfo:nil];
    [self addTrackingArea:trackingArea];
}

- (void)updateTrackingAreas {
    //NSLog(@"UpdTrack");
    //NSLog(@"x%f y%f height:%f width:%f",self.bounds.origin.x,self.bounds.origin.y,self.bounds.size.height,self.bounds.size.width);
    [self removeTrackingArea:trackingArea];
    trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds]
                                                options: (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways |NSTrackingInVisibleRect )
                                                  owner:self userInfo:nil];
    [self addTrackingArea:trackingArea];
     //NSLog(@"Tracking area: x%f y%f height:%f width:%f",trackingArea.rect.origin.x,trackingArea.rect.origin.y,trackingArea.rect.size.height,trackingArea.rect.size.width);
    
    
}

- (void) mouseEntered:(NSEvent*)theEvent {
    //NSLog(@"MouseEntered celda");
    [self.banderaSub setEnabled:self.enableSub];
    [self.banderaDescarga setEnabled:self.enableEp];
    
}

- (void) mouseExited:(NSEvent*)theEvent {
    //NSLog(@"MouseExited celda");
    //NSLog(@"Tracking area: x%f y%f height:%f width:%f",trackingArea.rect.origin.x,trackingArea.rect.origin.y,trackingArea.rect.size.height,trackingArea.rect.size.width);
    [self.banderaDescarga setEnabled:NO];
    [self.banderaSub setEnabled:NO];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
//        NSMenu *theMenu = [[NSMenu alloc] initWithTitle:@"Contextual Menu"];
//        [theMenu insertItemWithTitle:@"Beep" action:@selector(beep) keyEquivalent:@"" atIndex:0];
//        [theMenu insertItemWithTitle:@"Honk" action:@selector(honk) keyEquivalent:@"" atIndex:1];
//        [self setMenu:theMenu];
//        NSLog(@"Inicio");
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(void)excluirBusquedaEp{
    TableViewModif *tableview=(TableViewModif *)self.superview.superview;
    NSInteger row=[tableview rowForView:self];
    NSInteger numeroFilas=[tableview numberOfSelectedRows];
    if(numeroFilas>1){
        NSIndexSet *filasSeleccionadas=[tableview selectedRowIndexes];
        if([filasSeleccionadas containsIndex:row]){//Si se hizo click secundario en una de las filas de la seleccion lo mandamos a todas
            //NSLog(@"Se hace sobre varias selecciones");
            [(AppDelegate*)[NSApplication sharedApplication].delegate setExcluirBusquedaEpA:YES paraEpisodios:filasSeleccionadas];
            return;
        }
    }
    //NSLog(@"Marcar como descargado %lu",row);
    [(AppDelegate*)[NSApplication sharedApplication].delegate setExcluirBusquedaEpA:YES paraEpisodios:[[NSIndexSet alloc] initWithIndex:row]];
}

-(void)noExcluirBusquedaEp{
    TableViewModif *tableview=(TableViewModif *)self.superview.superview;
    NSInteger row=[tableview rowForView:self];
    NSInteger numeroFilas=[tableview numberOfSelectedRows];
    if(numeroFilas>1){
        NSIndexSet *filasSeleccionadas=[tableview selectedRowIndexes];
        if([filasSeleccionadas containsIndex:row]){//Si se hizo click secundario en una de las filas de la seleccion lo mandamos a todas
            //NSLog(@"Se hace sobre varias selecciones");
            [(AppDelegate*)[NSApplication sharedApplication].delegate setExcluirBusquedaEpA:NO paraEpisodios:filasSeleccionadas];
            return;
        }
    }
    //NSLog(@"Marcar como descargado %lu",row);
    [(AppDelegate*)[NSApplication sharedApplication].delegate setExcluirBusquedaEpA:NO paraEpisodios:[[NSIndexSet alloc] initWithIndex:row]];
}

-(void)excluirBusquedaSub{
    TableViewModif *tableview=(TableViewModif *)self.superview.superview;
    NSInteger row=[tableview rowForView:self];
    NSInteger numeroFilas=[tableview numberOfSelectedRows];
    if(numeroFilas>1){
        NSIndexSet *filasSeleccionadas=[tableview selectedRowIndexes];
        if([filasSeleccionadas containsIndex:row]){//Si se hizo click secundario en una de las filas de la seleccion lo mandamos a todas
            //NSLog(@"Se hace sobre varias selecciones");
            [(AppDelegate*)[NSApplication sharedApplication].delegate setExcluirBusquedaSubA:YES paraEpisodios:filasSeleccionadas];
            return;
        }
    }
    //NSLog(@"Marcar como descargado %lu",row);
    [(AppDelegate*)[NSApplication sharedApplication].delegate setExcluirBusquedaSubA:YES paraEpisodios:[[NSIndexSet alloc] initWithIndex:row]];
}

-(void)noExcluirBusquedaSub{
    TableViewModif *tableview=(TableViewModif *)self.superview.superview;
    NSInteger row=[tableview rowForView:self];
    NSInteger numeroFilas=[tableview numberOfSelectedRows];
    if(numeroFilas>1){
        NSIndexSet *filasSeleccionadas=[tableview selectedRowIndexes];
        if([filasSeleccionadas containsIndex:row]){//Si se hizo click secundario en una de las filas de la seleccion lo mandamos a todas
            //NSLog(@"Se hace sobre varias selecciones");
            [(AppDelegate*)[NSApplication sharedApplication].delegate setExcluirBusquedaSubA:NO paraEpisodios:filasSeleccionadas];
            return;
        }
    }
    //NSLog(@"Marcar como descargado %lu",row);
    [(AppDelegate*)[NSApplication sharedApplication].delegate setExcluirBusquedaSubA:NO paraEpisodios:[[NSIndexSet alloc] initWithIndex:row]];
}

-(void)eliminarEp{
    TableViewModif *tableview=(TableViewModif *)self.superview.superview;
    NSInteger row=[tableview rowForView:self];
    NSInteger numeroFilas=[tableview numberOfSelectedRows];
    if(numeroFilas>1){
        NSIndexSet *filasSeleccionadas=[tableview selectedRowIndexes];
        if([filasSeleccionadas containsIndex:row]){//Si se hizo click secundario en una de las filas de la seleccion lo mandamos a todas
            //NSLog(@"Se hace sobre varias selecciones");
            [(AppDelegate*)[NSApplication sharedApplication].delegate eliminarEpisodiosConIndices:filasSeleccionadas];
            return;
        }
    }
    //NSLog(@"Marcar como descargado %lu",row);
    
    [(AppDelegate*)[NSApplication sharedApplication].delegate eliminarEpisodiosConIndices:[[NSIndexSet alloc] initWithIndex:row]];
}

-(void)marcarEpDescargado{
    TableViewModif *tableview=(TableViewModif *)self.superview.superview;
    NSInteger row=[tableview rowForView:self];
    NSInteger numeroFilas=[tableview numberOfSelectedRows];
    if(numeroFilas>1){
        NSIndexSet *filasSeleccionadas=[tableview selectedRowIndexes];
        if([filasSeleccionadas containsIndex:row]){//Si se hizo click secundario en una de las filas de la seleccion lo mandamos a todas
            //NSLog(@"Se hace sobre varias selecciones");
            [(AppDelegate*)[NSApplication sharedApplication].delegate setEpisodioDescargadoA:YES paraEpisodios:filasSeleccionadas];
            return;
        }
    }
    //NSLog(@"Marcar como descargado %lu",row);
    [(AppDelegate*)[NSApplication sharedApplication].delegate setEpisodioDescargadoA:YES paraEpisodios:[[NSIndexSet alloc] initWithIndex:row]];
    
}
-(void)marcarEpNoDescargado{
    TableViewModif *tableview=(TableViewModif *)self.superview.superview;
    NSInteger row=[tableview rowForView:self];
    NSInteger numeroFilas=[tableview numberOfSelectedRows];
    if(numeroFilas>1){
        NSIndexSet *filasSeleccionadas=[tableview selectedRowIndexes];
        if([filasSeleccionadas containsIndex:row]){
            //NSLog(@"Se hace sobre varias selecciones");
            [(AppDelegate*)[NSApplication sharedApplication].delegate setEpisodioDescargadoA:NO paraEpisodios:filasSeleccionadas];
            return;
        }
    }
    //NSLog(@"Marcar como no descargado %lu",row);
    [(AppDelegate*)[NSApplication sharedApplication].delegate setEpisodioDescargadoA:NO paraEpisodios:[[NSIndexSet alloc] initWithIndex:row]];
    
}

-(void)marcarSubDescargado{
    TableViewModif *tableview=(TableViewModif *)self.superview.superview;
    NSInteger row=[tableview rowForView:self];
    NSInteger numeroFilas=[tableview numberOfSelectedRows];
    if(numeroFilas>1){
        NSIndexSet *filasSeleccionadas=[tableview selectedRowIndexes];
        if([filasSeleccionadas containsIndex:row]){//Si se hizo click secundario en una de las filas de la seleccion lo mandamos a todas
            //NSLog(@"Se hace sobre varias selecciones");
            [(AppDelegate*)[NSApplication sharedApplication].delegate setSubDescargadoA:YES paraEpisodios:filasSeleccionadas];
            return;
        }
    }
    //NSLog(@"Marcar como descargado %lu",row);
    [(AppDelegate*)[NSApplication sharedApplication].delegate setSubDescargadoA:YES paraEpisodios:[[NSIndexSet alloc] initWithIndex:row]];
    
}
-(void)marcarSubNoDescargado{
    TableViewModif *tableview=(TableViewModif *)self.superview.superview;
    NSInteger row=[tableview rowForView:self];
    NSInteger numeroFilas=[tableview numberOfSelectedRows];
    if(numeroFilas>1){
        NSIndexSet *filasSeleccionadas=[tableview selectedRowIndexes];
        if([filasSeleccionadas containsIndex:row]){
            //NSLog(@"Se hace sobre varias selecciones");
            [(AppDelegate*)[NSApplication sharedApplication].delegate setSubDescargadoA:NO paraEpisodios:filasSeleccionadas];
            return;
        }
    }
    //NSLog(@"Marcar como no descargado %lu",row);
    [(AppDelegate*)[NSApplication sharedApplication].delegate setSubDescargadoA:NO paraEpisodios:[[NSIndexSet alloc] initWithIndex:row]];
    
}
-(void)mostrarBusquedaEp{
    TableViewModif *tableview=(TableViewModif *)self.superview.superview;
    NSInteger row=[tableview rowForView:self];
    NSInteger numeroFilas=[tableview numberOfSelectedRows];
    if(numeroFilas>1){
        NSIndexSet *filasSeleccionadas=[tableview selectedRowIndexes];
        if([filasSeleccionadas containsIndex:row]){
            //NSLog(@"Se hace sobre varias selecciones");
            [(AppDelegate*)[NSApplication sharedApplication].delegate muestraBusquedaEpisodio:filasSeleccionadas];
            return;
        }
    }
    //NSLog(@"Marcar como no descargado %lu",row);
    [(AppDelegate*)[NSApplication sharedApplication].delegate muestraBusquedaEpisodio:[[NSIndexSet alloc] initWithIndex:row]];
    
}
-(void)descargarSub{
    TableViewModif *tableview=(TableViewModif *)self.superview.superview;
    NSInteger row=[tableview rowForView:self];
    NSInteger numeroFilas=[tableview numberOfSelectedRows];
    if(numeroFilas>1){
        NSIndexSet *filasSeleccionadas=[tableview selectedRowIndexes];
        if([filasSeleccionadas containsIndex:row]){
            //NSLog(@"Se hace sobre varias selecciones");
            [(AppDelegate*)[NSApplication sharedApplication].delegate descargaSubtituloConIndices:filasSeleccionadas];
            return;
        }
    }
    //NSLog(@"Marcar como no descargado %lu",row);
    [(AppDelegate*)[NSApplication sharedApplication].delegate descargaSubtituloConIndices:[[NSIndexSet alloc] initWithIndex:row]];
}
-(void)mostrarInformacionSerie{
    TableViewModif *tableview=(TableViewModif *)self.superview.superview;
    NSInteger row=[tableview rowForView:self];
    [(AppDelegate*)[NSApplication sharedApplication].delegate mostrarInfoDeSerie:[[NSIndexSet alloc] initWithIndex:row]];
}

-(void)descargarEp{
    TableViewModif *tableview=(TableViewModif *)self.superview.superview;
    NSInteger row=[tableview rowForView:self];
    NSInteger numeroFilas=[tableview numberOfSelectedRows];
    if(numeroFilas>1){
        NSIndexSet *filasSeleccionadas=[tableview selectedRowIndexes];
        if([filasSeleccionadas containsIndex:row]){
            //NSLog(@"Se hace sobre varias selecciones");
            [(AppDelegate*)[NSApplication sharedApplication].delegate descargaEpisodioConIndices:filasSeleccionadas];
            return;
        }
    }
    //NSLog(@"Marcar como no descargado %lu",row);
    [(AppDelegate*)[NSApplication sharedApplication].delegate descargaEpisodioConIndices:[[NSIndexSet alloc] initWithIndex:row]];
}

-(void)highlightEp{
    [self.banderaSub setEnabled:NO];
}

-(void)highlightSub{
    [self.banderaDescarga setEnabled:NO];
}

-(void)quitarHighlight{
    [self.banderaDescarga setEnabled:self.enableEp];
    [self.banderaSub setEnabled:self.enableSub];
}
@end
