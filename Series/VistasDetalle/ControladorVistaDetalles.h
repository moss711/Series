//
//  ControladorVistaDetalles.h
//  TvTime
//
//  Created by Alexandre Blanco Gómez on 27/7/15.
//  Copyright (c) 2015 Horseware. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Serie.h"
#import "ControladorVistaSecundaria.h"

@interface ControladorVistaDetalles : NSViewController

@property (weak) IBOutlet NSView *vistaCabecera;
@property (weak) IBOutlet NSView *vistaCuerpo;
@property (weak) IBOutlet NSTextField *labelTitulo;
@property (weak) IBOutlet NSTextField *labelSubtitulo;
@property (weak) IBOutlet NSTextField *labelBotonIzq;
@property ControladorVistaSecundaria* controladorVistaActual;
@property NSMutableArray* historialVistas;


-(void)mostrarVistaStandby;
-(void)mostrarVistaProximosCapitulos:(NSArray*)series;

@end
