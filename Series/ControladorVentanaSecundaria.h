//
//  ventanaSecundaria.h
//  pruebaSegundaVentana
//
//  Created by Alexandre Blanco Gómez on 1/11/14.
//  Copyright (c) 2014 Horseware. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Episodio.h"
#import "VistaInformacion.h"

@interface ControladorVentanaSecundaria : NSWindowController
@property (weak) IBOutlet NSImageView *poster;
@property (weak) IBOutlet NSTextField *nombreSerie;
@property (weak) IBOutlet NSTextField *masInformacionSerie;
@property (strong) IBOutlet VistaInformacion *vistaInformacion;
@property (strong) IBOutlet NSView *vistaProximos;
@property (strong) IBOutlet NSView *vistaAnteriores;
@property (strong) IBOutlet NSView *vistaMiniatura;
@property (strong) IBOutlet NSView *vistaPoster;
@property (weak) IBOutlet NSSegmentedControl *segmentedControl;
@property (weak) IBOutlet NSView *vistaARellenar;

- (IBAction)cancelar:(id)sender;
- (IBAction)aceptar:(id)sender;
-(instancetype)initWithSerie:(Serie*) serie;
- (IBAction)cambioSegmentedControl:(NSSegmentedControl *)sender;




@end
