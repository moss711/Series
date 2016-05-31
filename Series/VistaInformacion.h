//
//  VistaInformacion.h
//  TvTime
//
//  Created by Alexandre Blanco Gómez on 3/11/14.
//  Copyright (c) 2014 Horseware. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Serie.h"

@interface VistaInformacion : NSView <NSTextFieldDelegate>

-(void)iniciarDatosConSerie:(Serie*)serie;
-(void)guardarCambiosEnSerie:(Serie *)serie;

//CheckBoxHD
- (IBAction)cambioCheckBoxHD:(NSButton *)sender;
-(BOOL)modificadoCheckBoxHD;
@property (weak) IBOutlet NSButton *checkBoxHD;

//CheckBoxDescargaAutoEp
- (IBAction)cambioCheckBoxDescargaAutoEp:(NSButton *)sender;
-(BOOL)modificadoCheckBoxDescargaAutoEp;
@property (weak) IBOutlet NSButton *checkBoxDescargaAutoEp;

//CheckBoxEsAnime
- (IBAction)cambioCheckBoxEsAnime:(NSButton *)sender;
-(BOOL)modificadoCheckBoxEsAnime;
@property (weak) IBOutlet NSButton *checkBoxEsAnime;


//textFieldAno
@property (weak) IBOutlet NSTextField *textFieldAno;
-(BOOL)modificadoTextFieldAno;

//textFieldPais
@property (weak) IBOutlet NSTextField *textFieldPais;
-(BOOL)modificadoTextFieldPais;

//textFieldNombreParaMostrar
@property (weak) IBOutlet NSTextField *textFieldNombreParaMostrar;
-(BOOL)modificadoTextFieldNombreParaMostrar;

//textFieldIDTVDB
@property (weak) IBOutlet NSTextField *textFieldIDTVDB;
-(BOOL)modificadoTextFieldIDTVDB;

//textfieldIDSubtitulosEs
@property (weak) IBOutlet NSTextField *textFieldIDSubtitulosEs;
-(BOOL)modificadoTextFieldSubtitulosEs;


//textFieldIDTVRAGE
@property (weak) IBOutlet NSTextField *textFieldIDTVRAGE;
//textFieldNombre
@property (weak) IBOutlet NSTextField *textFieldNombre;

//textFieldNombreParaBusquedaEp
@property (weak) IBOutlet NSTextField *textFieldNombreParaBusquedaEp;
-(BOOL)modificadoTextFieldNombreParaBusquedaEp;

//textFieldfNombreParaBusquedaSub
@property (weak) IBOutlet NSTextField *textFieldNombreParaBusquedaSub;
-(BOOL)modificadoTextFieldNombreParaBusquedaSub;

//popUpResolucion
@property (weak) IBOutlet NSPopUpButton *popUpResolucion;
-(BOOL)modificadoPopUpResolucion;
- (IBAction)cambioPopUpResolucion:(id)sender;

//CheckBoxDescargaAutoSub
@property (weak) IBOutlet NSButton *checkBoxDescargaAutoSub;
- (IBAction)cambioCheckBoxDescargaAutoSub:(id)sender;
-(BOOL) modificadoCheckBoxDescargaAutoSub;

//popUpIdiomaSubs
@property (weak) IBOutlet NSPopUpButton *popUpIdiomaSubs;
-(BOOL)modificadoPopUpIdiomaSubs;
- (IBAction)cambioPopUpIdiomaSubs:(id)sender;




@end
