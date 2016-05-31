//
//  GestorDeOpciones.m
//  TvTime
//
//  Created by Alexandre Blanco Gómez on 19/6/15.
//  Copyright (c) 2015 Horseware. All rights reserved.
//

#import "GestorDeOpciones.h"

@implementation GestorDeOpciones

-(instancetype)init{
    if ( self = [super init] ) {
        bool mostrarVentanaOpciones=NO;
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        
        //Ruta descarga subs
        NSString* rutaSubs=[prefs objectForKey:@"rutaSubs"];
        if(rutaSubs==nil){
            mostrarVentanaOpciones=YES;
            NSString* home=[[[NSProcessInfo processInfo] environment] objectForKey:@"HOME"];
            rutaSubs=[[NSString alloc]initWithFormat:@"file://%@/Movies/",home];
        }
        self.rutaSubs=[NSURL URLWithString:rutaSubs];
        
        //BuscadorSubs(Idioma) por defecto
        NSNumber* buscadorSubs=[prefs objectForKey:@"buscadorSubsPred"];
        if(buscadorSubs==nil){
            mostrarVentanaOpciones=YES;
            buscadorSubs=[NSNumber numberWithInt:SubtitulosES];
        }
        self.buscadorSubsPorDefecto=buscadorSubs.intValue;
        
        if(mostrarVentanaOpciones){
            self.ventanaPreferencias=[[VentanaPreferencias alloc]initWithGestorDeOpciones:self];
            [self.ventanaPreferencias showWindow:self];
        }
        
        return self;
    } else
        return nil;
}

-(void)mostrarPanelOpciones{
    self.ventanaPreferencias=[[VentanaPreferencias alloc]initWithGestorDeOpciones:self];
    [self.ventanaPreferencias showWindow:self];
}

-(void)cambiarRutaSubs:(NSURL *)nuevaRuta{
    self.rutaSubs=nuevaRuta;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:self.rutaSubs.absoluteString forKey:@"rutaSubs"];
    [prefs synchronize];
}

-(void)cambiarBuscadorSubsPorDefecto:(int)nuevoBuscador{
    self.buscadorSubsPorDefecto=nuevoBuscador;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:[NSNumber numberWithInt:self.buscadorSubsPorDefecto] forKey:@"buscadorSubsPred"];
    [prefs synchronize];
}

@end
