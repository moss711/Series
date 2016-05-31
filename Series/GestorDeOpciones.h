//
//  GestorDeOpciones.h
//  TvTime
//
//  Created by Alexandre Blanco Gómez on 19/6/15.
//  Copyright (c) 2015 Horseware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VentanaPreferencias.h"
#import "Serie.h"

@class VentanaPreferencias;

@interface GestorDeOpciones : NSObject
@property NSURL *rutaSubs;
@property TipoBuscadorSubtitulos buscadorSubsPorDefecto;
@property VentanaPreferencias *ventanaPreferencias;

-(void)mostrarPanelOpciones;
-(void)cambiarRutaSubs:(NSURL*)nuevaRuta;
-(void)cambiarBuscadorSubsPorDefecto:(int)nuevoBuscador;
@end
