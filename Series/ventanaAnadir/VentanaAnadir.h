//
//  ventanaAnadir.h
//  TvTime
//
//  Created by Alexandre Blanco Gómez on 7/1/15.
//  Copyright (c) 2015 Horseware. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TextFieldConAvisoDeFocus.h"

@interface VentanaAnadir : NSWindowController <TextFieldFocusDelegate,NSTableViewDataSource,NSTableViewDelegate>

//TableView
@property (weak) IBOutlet NSTableView *tablaDerecha;


//textFieldNombrSerie
@property (weak) IBOutlet NSTextField *textFieldNombreSerie;

//textFieldPaisAno
@property (weak) IBOutlet NSTextField *textFieldPaisAno;

//popUpResolucion
- (IBAction)cambioPopUpResolucion:(id)sender;
@property (weak) IBOutlet NSPopUpButton *popUpResolucion;

//popUpIdiomaSubs
@property (weak) IBOutlet NSPopUpButton *popUpIdiomaSubs;
- (IBAction)cambioPopUpIdiomaSubs:(id)sender;

//chechboxAnime
@property (weak) IBOutlet NSButton *checkBoxEsAnime;
- (IBAction)cambioCheckBoxEsAnime:(id)sender;

//episodioReferencia
@property (weak) IBOutlet NSTextField *textFieldEpisodioReferencia;

//textFieldIDTheTVDB
@property (weak) IBOutlet NSTextField *textFieldTituloIDTheTVDB;
@property (weak) IBOutlet NSTextField *textFieldIDTheTVDB;

@property (weak) IBOutlet NSImageView *imageViewPoster;


//botones inferiores
- (IBAction)botonCancelar:(id)sender;
- (IBAction)botonAceptar:(id)sender;


//Deficion de tipos
typedef NS_ENUM(NSInteger,TipoParteDerecha){
    PARTE_DERECHA_NADA=0,
    PARTE_DERECHA_BUSQUEDA_SERIE_TVRAGE=1,
    PARTE_DERECHA_BUSQUEDA_SERIE_THETVDB=2,
    PARTE_DERECHA_LISTA_EPISODIOS_ANTERIORES=3
};

@end
