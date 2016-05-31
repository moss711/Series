//
//  ventanaSecundaria.m
//  pruebaSegundaVentana
//
//  Created by Alexandre Blanco Gómez on 1/11/14.
//  Copyright (c) 2014 Horseware. All rights reserved.
//

#import "ControladorVentanaSecundaria.h"
#import "Episodio.h"
#import "Serie.h"
#import "GestorDeFicheros.h"
#import "AppDelegate.h"
#import "VistaInformacion.h"

@interface ControladorVentanaSecundaria ()

@end

@implementation ControladorVentanaSecundaria

//Variables Globales
Serie* serie;
GestorDeFicheros* gestorFichero;
//Boolean modificadoVistaInformacionCheckBoxHD=NO;
NSView *vistaEnParteDerecha=nil;


- (void)mouseDown:(NSEvent *)event{
    [self.window makeFirstResponder:nil];
}

- (IBAction)cancelar:(id)sender {
    [self close];
}

- (IBAction)aceptar:(id)sender {
    NSManagedObjectContext *context=[(AppDelegate*)[NSApplication sharedApplication].delegate managedObjectContext];
     NSError *error;
    dispatch_semaphore_t semaforoSeries=[(AppDelegate*)[NSApplication sharedApplication].delegate getSemafotoSeries];
    dispatch_semaphore_wait(semaforoSeries, DISPATCH_TIME_FOREVER);//Lo estoy haciendo en main=??? por que? cambialo!
    //Comprobamos TODOS :( los cambios que se hicieron y guardamos
    //¿Quiza guardar todo sin comprobar si se cambio o no?
    [self.vistaInformacion guardarCambiosEnSerie:serie];
    
    if (![context save:&error]) {//Se guarda el cambio en coredata
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    dispatch_semaphore_signal(semaforoSeries);
    //Hacer esto mas limpio en vez de recargar todo
    [((AppDelegate*)[NSApplication sharedApplication].delegate).tableviewPrincipal reloadData];
    [self close];
}

-(instancetype)initWithSerie:(Serie *)_serie{
    self=[super initWithWindowNibName:@"ControladorVentanaSecundaria"];
    serie=_serie;
    gestorFichero=[[GestorDeFicheros alloc]init];
    return self;
}

- (IBAction)cambioSegmentedControl:(NSSegmentedControl *)sender {
    switch ([sender selectedSegment]){
        case 0:
            [vistaEnParteDerecha removeFromSuperview];
            [self.vistaARellenar addSubview:self.vistaInformacion];
            [self.vistaInformacion setAutoresizingMask:NSViewHeightSizable|NSViewWidthSizable];
            vistaEnParteDerecha=self.vistaInformacion;
            
            break;
            
        case 1:
            [vistaEnParteDerecha removeFromSuperview];
            [self.vistaARellenar addSubview:self.vistaProximos];
            [self.vistaProximos setAutoresizingMask:NSViewHeightSizable|NSViewWidthSizable];
            vistaEnParteDerecha=self.vistaProximos;
            break;
        case 2:
            [vistaEnParteDerecha removeFromSuperview];
            [self.vistaARellenar addSubview:self.vistaAnteriores];
            [self.vistaAnteriores setAutoresizingMask:NSViewHeightSizable|NSViewWidthSizable];
            vistaEnParteDerecha=self.vistaAnteriores;

            break;
        case 3:
            [vistaEnParteDerecha removeFromSuperview];
            [self.vistaARellenar addSubview:self.vistaMiniatura];
            [self.vistaMiniatura setAutoresizingMask:NSViewHeightSizable|NSViewWidthSizable];
            vistaEnParteDerecha=self.vistaMiniatura;
            break;
        case 4:
            [vistaEnParteDerecha removeFromSuperview];
            [self.vistaARellenar addSubview:self.vistaPoster];
            [self.vistaPoster setAutoresizingMask:NSViewHeightSizable|NSViewWidthSizable];
            vistaEnParteDerecha=self.vistaPoster;
            break;
    }
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
     //Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
   
    if(serie.nombreParaMostrar==nil){
        self.nombreSerie.stringValue=serie.serie;
    }else{
        self.nombreSerie.stringValue=serie.nombreParaMostrar;
    }
    NSString *pais;
    NSString *ano;
    if(serie.pais==nil){
        pais=@"";
    }else{
        pais=serie.pais;
    }
    if(serie.ano==nil){
        ano=@"";
    }else{
        ano=serie.ano.stringValue;
    }
    self.masInformacionSerie.stringValue=[[NSString alloc]initWithFormat:@"%@, %@",pais,ano];
    
    //Iniciamos la parte derecha
    [self.vistaARellenar addSubview:self.vistaInformacion];
    [self.vistaInformacion setAutoresizingMask:NSViewHeightSizable|NSViewWidthSizable];
    vistaEnParteDerecha=self.vistaInformacion;
    //NSLog(@"%@",serie.serie);
    
    
    //Iniciamos las vistas
    [self.vistaInformacion iniciarDatosConSerie:serie];
    
    //Cargamos la imagen
    NSImage* imagen=[gestorFichero recuperarPosterConSid:serie.sid];
    if(imagen==nil){
        //self.poster.image=[NSImage imageNamed:@"279830-1.jpg"];//placeholder
    }else{
        self.poster.image=imagen;
    }
    
    
}



@end
