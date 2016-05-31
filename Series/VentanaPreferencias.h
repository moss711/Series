//
//  VentanaPreferencias.h
//  TvTime
//
//  Created by Alexandre Blanco Gómez on 25/3/15.
//  Copyright (c) 2015 Horseware. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GestorDeOpciones.h"

@class GestorDeOpciones;

@interface VentanaPreferencias : NSWindowController


@property GestorDeOpciones *gestorOpciones;

@property (weak) IBOutlet NSTextField *textFieldDirectorioSubs;
@property (weak) IBOutlet NSPopUpButton *desplegableIdiomaSubs;

-(instancetype)initWithGestorDeOpciones:(GestorDeOpciones*)gestorOpciones;
- (IBAction)abrirPanelRutaSubs:(id)sender;

- (IBAction)botonCancelar:(id)sender;
- (IBAction)botonAceptar:(id)sender;
@end
