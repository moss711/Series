//
//  VistaInformacion.m
//  TvTime
//
//  Created by Alexandre Blanco Gómez on 3/11/14.
//  Copyright (c) 2014 Horseware. All rights reserved.
//

#import "VistaInformacion.h"
@interface VistaInformacion ()
@property int idiomaSubsReal;
@end

@implementation VistaInformacion
//CHeckboxHD
BOOL modificadoCheckBoxHD= NO;
- (IBAction)cambioCheckBoxHD:(NSButton *)sender {
    modificadoCheckBoxHD=YES;
    //Activo o desactivo el control de resolucion
    if ([self.checkBoxHD state] == NSOnState) {
        self.popUpResolucion.enabled=YES;
    }
    else {
        self.popUpResolucion.enabled=NO;
    }
}
-(BOOL)modificadoCheckBoxHD{
    return modificadoCheckBoxHD;
}

//CheckBoxDescargaAutoEp
BOOL modificadoCheckBoxDescargaAutoEp=NO;
-(IBAction)cambioCheckBoxDescargaAutoEp:(NSButton *)sender{
    modificadoCheckBoxDescargaAutoEp=YES;
    if ([self.checkBoxDescargaAutoEp state] == NSOnState) {
        self.checkBoxHD.enabled=YES;
        if ([self.checkBoxHD state] == NSOnState) {
            self.popUpResolucion.enabled=YES;
        }
        else {
            self.popUpResolucion.enabled=NO;
        }
        self.textFieldNombreParaBusquedaEp.enabled=YES;
        
    }
    else {
        self.checkBoxHD.enabled=NO;
        self.popUpResolucion.enabled=NO;
        self.textFieldNombreParaBusquedaEp.enabled=NO;
    }
}
-(BOOL)modificadoCheckBoxDescargaAutoEp{
    return modificadoCheckBoxDescargaAutoEp;
}

//CheckBoxEsAnime
BOOL modificadoCheckBoxEsAnime=NO;
-(BOOL)modificadoCheckBoxEsAnime{
    return modificadoCheckBoxEsAnime;
}
- (IBAction)cambioCheckBoxEsAnime:(NSButtonCell *)sender {
    modificadoCheckBoxEsAnime=YES;
    if ([self.checkBoxEsAnime state] == NSOnState) {
        self.checkBoxDescargaAutoSub.state=NSOffState;
        self.checkBoxDescargaAutoSub.enabled=NO;
        
    }
    else {
        self.checkBoxDescargaAutoSub.state=NSOnState;
        self.checkBoxDescargaAutoSub.enabled=YES;
    }
    //Procesamos el cambio en descargaAutoSub
    [self cambioCheckBoxDescargaAutoSub:self.checkBoxDescargaAutoSub];
    //Cambio en idioma
    [self refrescarEstadoPopUpIdiomaSubs];
}

//TextFieldAno
BOOL modificadoTextFieldAno=NO;
-(BOOL)modificadoTextFieldAno{
    return modificadoTextFieldAno;
}

//TextFieldPais
BOOL modificadoTextFieldPais=NO;
-(BOOL)modificadoTextFieldPais{
    return modificadoTextFieldPais;
}

//TextFieldNombreParaMostrar
BOOL modificadoTextFieldNombreParaMostrar=NO;
-(BOOL)modificadoTextFieldNombreParaMostrar{
    return modificadoTextFieldNombreParaMostrar;
}

//TextFieldIDTVDB

BOOL modificadoTextFieldIDTVDB=NO;
-(BOOL)modificadoTextFieldIDTVDB{
    return modificadoTextFieldIDTVDB;
}

//TextFieldIDSubtitulosEs
BOOL modificadoTextFieldIDSubtitulosEs=NO;
-(BOOL)modificadoTextFieldSubtitulosEs{
    return modificadoTextFieldIDSubtitulosEs;
}

//TextFieldNombreParaBusquedaEp
BOOL modificadoTextFieldNombreParaBusquedaEp=NO;
-(BOOL)modificadoTextFieldNombreParaBusquedaEp{
    return modificadoTextFieldNombreParaBusquedaEp;
}

//TextFieldNombreParaBusquedaSub
BOOL modificadoTextFieldNombreParaBusquedaSub=NO;
-(BOOL)modificadoTextFieldNombreParaBusquedaSub{
    return modificadoTextFieldNombreParaBusquedaSub;
}

//Todos los textField
- (void)controlTextDidBeginEditing:(NSNotification *)notification;{
    NSTextField *textField = [notification object];
    if(textField ==self.textFieldAno){
        modificadoTextFieldAno=YES;
    }else if(textField==self.textFieldPais){
        modificadoTextFieldPais=YES;
    }else if(textField==self.textFieldNombreParaMostrar){
        modificadoTextFieldNombreParaMostrar=YES;
    }else if(textField==self.textFieldIDTVDB){
        modificadoTextFieldIDTVDB=YES;
    }else if(textField==self.textFieldNombreParaBusquedaEp){
        modificadoTextFieldNombreParaBusquedaEp=YES;
    }else if(textField==self.textFieldNombreParaBusquedaSub){
        modificadoTextFieldNombreParaBusquedaSub=YES;
    }else if(textField==self.textFieldIDSubtitulosEs){
        modificadoTextFieldIDSubtitulosEs=YES;
    }
}
- (void)controlTextDidEndEditing:(NSNotification *)aNotification{
    [self.window makeFirstResponder:self];
}

//PopUpResolucion
BOOL modificadoPopUpResolucion=NO;
-(BOOL)modificadoPopUpResolucion{
    return modificadoPopUpResolucion;
}
- (IBAction)cambioPopUpResolucion:(id)sender {
    modificadoPopUpResolucion=YES;
}

//PopUpIdiomaSubs
BOOL modificadoPopUpIdiomaSubs=NO;
-(BOOL)modificadoPopUpIdiomaSubs{
    return modificadoPopUpIdiomaSubs;
}
-(IBAction)cambioPopUpIdiomaSubs:(id)sender{
    modificadoPopUpIdiomaSubs=YES;
    self.idiomaSubsReal=self.popUpIdiomaSubs.selectedTag;
}

//CheckBoxDescargaAutoSub
BOOL modificadoCheckBoxDescargaAutoSub=NO;
-(BOOL)modificadoCheckBoxDescargaAutoSub{
    return modificadoCheckBoxDescargaAutoSub;
}
-(IBAction)cambioCheckBoxDescargaAutoSub:(id)sender{
    modificadoCheckBoxDescargaAutoSub=YES;
    if ([self.checkBoxDescargaAutoSub state] == NSOnState) {
        self.textFieldNombreParaBusquedaSub.enabled=YES;
        self.popUpIdiomaSubs.enabled=YES;
    }else{
        self.textFieldNombreParaBusquedaSub.enabled=NO;
        self.popUpIdiomaSubs.enabled=NO;
    }

}

-(void)iniciarDatosConSerie:(Serie *)serie{
    //CheckboxHD
    if(serie.prefiereHD.boolValue==YES){
        NSLog(@"Prefiere Hd");
        [self.checkBoxHD setState:NSOnState];
    }else{
        NSLog(@"No quiere HD");
        [self.checkBoxHD setState:NSOffState];
    }
    //CheckBoxDescargaAutoEp
    if(serie.descargaAutomaticaEp!=nil&&serie.descargaAutomaticaEp.boolValue==NO){
        NSLog(@"No descarga auto ep");
        [self.checkBoxDescargaAutoEp setState:NSOffState];
        self.checkBoxHD.enabled=NO;
        self.popUpResolucion.enabled=NO;
        self.textFieldNombreParaBusquedaEp.enabled=NO;
    }else{
        NSLog(@"Descarga auto ep");
        [self.checkBoxDescargaAutoEp setState:NSOnState];
        if ([self.checkBoxHD state] == NSOnState) {
            self.popUpResolucion.enabled=YES;
        }
        else {
            self.popUpResolucion.enabled=NO;
        }
        self.textFieldNombreParaBusquedaEp.enabled=YES;
    }
    
    //CheckBoxEsAnime
    if(serie.buscadorTorrent!=nil){
        if(serie.buscadorTorrent.integerValue==buscadorSeriesOccidentales){
            self.checkBoxEsAnime.state=NSOffState;
        }else if(serie.buscadorTorrent.integerValue==buscadorSeriesAnimeSubsIncrustados){
            self.checkBoxEsAnime.state=NSOnState;
        }
    }
    
    //TextFieldAno
    if(serie.ano!=nil){
        self.textFieldAno.stringValue=serie.ano.stringValue;
    }
    //TextFieldPais
    if(serie.pais!=nil){
        self.textFieldPais.stringValue=serie.pais;
    }
    //TextFieldNombreParaMostrar
    if(serie.nombreParaMostrar==nil){
        self.textFieldNombreParaMostrar.stringValue=serie.serie;
    }else{
        self.textFieldNombreParaMostrar.stringValue=serie.nombreParaMostrar;
    }
    //TextFieldIDTVDB
    if(serie.idTVdb!=nil){
        self.textFieldIDTVDB.stringValue=serie.idTVdb.stringValue;
    }
    //TextFieldIDSubtitulosEs
    if(serie.idSubtitulosEs!=nil){
        self.textFieldIDSubtitulosEs.stringValue=serie.idSubtitulosEs.stringValue;
    }
    //TextFieldIDTVRAGE
    self.textFieldIDTVRAGE.stringValue=serie.sid.stringValue;
    //TextFieldNombre
    self.textFieldNombre.stringValue=serie.serie;
    
    //TextFieldNombreParaBusquedaEp
    if(serie.nombreParaBusquedaEp==nil){
        self.textFieldNombreParaBusquedaEp.stringValue=serie.serie;
    }else{
        self.textFieldNombreParaBusquedaEp.stringValue=serie.nombreParaBusquedaEp;
    }
    
    //textFieldNombreParaBusquedaSub
    if(serie.nombreParaBusquedaSubs==nil){
        self.textFieldNombreParaBusquedaSub.stringValue=serie.serie;
    }else{
        self.textFieldNombreParaBusquedaSub.stringValue=serie.nombreParaBusquedaSubs;
    }
    
    //PopUpResolucion
    if(!serie.prefiereHD.boolValue){
        self.popUpResolucion.enabled=NO;
    }else if(serie.resolucionPreferida!=nil){
        if(serie.resolucionPreferida.integerValue==720){
            [self.popUpResolucion selectItemWithTitle:@"720p"];
        }else if(serie.resolucionPreferida.integerValue==1080){
            [self.popUpResolucion selectItemWithTitle:@"1080p"];
        }
    }
    
    //CheckBoxDescargaAutoSub
    if(serie.buscadorTorrent!=nil && serie.buscadorTorrent.integerValue==buscadorSeriesAnimeSubsIncrustados){
        [self.checkBoxDescargaAutoSub setState:NSOffState];
        self.checkBoxDescargaAutoSub.enabled=NO;
        self.textFieldNombreParaBusquedaSub.enabled=NO;
        
    }else{
        if(serie.descargaAutomaticaSub!=nil&&serie.descargaAutomaticaSub.boolValue==NO){
            [self.checkBoxDescargaAutoSub setState:NSOffState];
            self.textFieldNombreParaBusquedaSub.enabled=NO;
        }else{
            [self.checkBoxDescargaAutoSub setState:NSOnState];
            self.textFieldNombreParaBusquedaSub.enabled=YES;
        }
    }
    
    //PopUpIdiomaSubs
    if(serie.buscadorTorrent==nil||serie.buscadorTorrent.intValue==Addic7ed){
        self.idiomaSubsReal=0;
    }else{
        self.idiomaSubsReal=1;
    }
    
    
    if(serie.buscadorTorrent!=nil&&serie.buscadorTorrent.intValue==buscadorSeriesAnimeSubsIncrustados){
        //Es anime y le pongo ingles y no enabled
        self.popUpIdiomaSubs.enabled=NO;
        [self.popUpIdiomaSubs selectItemWithTag:0];
    }else{//no es anime
        //Miramos si tiene la busqueda habilitada
        if(serie.descargaAutomaticaSub==nil||serie.descargaAutomaticaSub.boolValue){//busqueda de sub habilitada
            self.popUpIdiomaSubs.enabled=YES;
        }else{//busqueda sub deshabilitada
            self.popUpIdiomaSubs.enabled=NO;
        }
        //Idioma de la busqueda
        if(serie.buscadorSubtitulos==nil||serie.buscadorSubtitulos.intValue==Addic7ed){//Ingles
            [self.popUpIdiomaSubs selectItemWithTag:0];
        }else{//espanol
            [self.popUpIdiomaSubs selectItemWithTag:1];
        }
    }
    
}

-(void)refrescarEstadoPopUpIdiomaSubs{
    if([self.checkBoxEsAnime state] == NSOnState){
        //Es anime y le pongo ingles y no enabled
        self.popUpIdiomaSubs.enabled=NO;
        [self.popUpIdiomaSubs selectItemWithTag:0];
    }else{//no es anime
        //Miramos si tiene la busqueda habilitada
        if([self.checkBoxDescargaAutoSub state]==NSOnState){//busqueda de sub habilitada
            self.popUpIdiomaSubs.enabled=YES;
        }else{//busqueda sub deshabilitada
            self.popUpIdiomaSubs.enabled=NO;
        }
        //Idioma de la busqueda
        [self.popUpIdiomaSubs selectItemWithTag:self.idiomaSubsReal];
    }
}


-(void)guardarCambiosEnSerie:(Serie *)serie{
    //CheckBoxHD
    if(modificadoCheckBoxHD){
        if ([self.checkBoxHD state] == NSOnState) {
            serie.prefiereHD=@YES;
        }
        else {
            serie.prefiereHD=@NO;
        }
    }
    //ChecBoxDescargaAutoEp
    if(modificadoCheckBoxDescargaAutoEp){
        if ([self.checkBoxDescargaAutoEp state] == NSOnState) {
            serie.descargaAutomaticaEp=@YES;
        }
        else {
            serie.descargaAutomaticaEp=@NO;
        }
    }
    if(modificadoTextFieldAno){
        serie.ano=[[NSNumber alloc]initWithInteger:self.textFieldAno.integerValue];
    }
    if(modificadoTextFieldPais) {
        serie.pais=self.textFieldPais.stringValue;
    }
    if(modificadoTextFieldNombreParaMostrar){
        serie.nombreParaMostrar=self.textFieldNombreParaMostrar.stringValue;
    }
    if(modificadoTextFieldIDTVDB){
        serie.idTVdb=[[NSNumber alloc]initWithInteger:self.textFieldIDTVDB.integerValue];
    }
    if(modificadoTextFieldIDSubtitulosEs){
        serie.idSubtitulosEs=[NSNumber numberWithInteger:self.textFieldIDSubtitulosEs.integerValue];
    }
    //TextFieldNombreParaBusquedaEp
    if(modificadoTextFieldNombreParaBusquedaEp){
        if(![self.textFieldNombreParaBusquedaEp.stringValue isEqualToString:@""]){
            serie.nombreParaBusquedaEp=self.textFieldNombreParaBusquedaEp.stringValue;
        }else{
            serie.nombreParaBusquedaEp=serie.serie;
        }
    }
    //textFieldNombreParaBusquedaSub
    if(modificadoTextFieldNombreParaBusquedaSub) {
        if(![self.textFieldNombreParaBusquedaSub.stringValue isEqualToString:@""]){
            serie.nombreParaBusquedaSubs=self.textFieldNombreParaBusquedaSub.stringValue;
        }else{
            serie.nombreParaBusquedaSubs=serie.serie;
        }
    }
    //PopUpResolucion
    if(modificadoPopUpResolucion){
        if([self.popUpResolucion.selectedItem.title isEqualToString:@"720p"]){
            serie.resolucionPreferida=[[NSNumber alloc]initWithInt:720];
        }else{
            serie.resolucionPreferida=[[NSNumber alloc]initWithInt:1080];
        }
    }
    
    //CheckBoxAnime
    if(modificadoCheckBoxEsAnime){
        if (self.checkBoxEsAnime.state==NSOffState){
            serie.buscadorTorrent=[[NSNumber alloc]initWithInteger:buscadorSeriesOccidentales];
        }else {
            serie.buscadorTorrent=[[NSNumber alloc]initWithInteger:buscadorSeriesAnimeSubsIncrustados];
        }
    }
    
    //CheckBoxDescargaAutoSub
    if(modificadoCheckBoxDescargaAutoSub){
        if ([self.checkBoxDescargaAutoSub state] == NSOnState) {
            serie.descargaAutomaticaSub=@YES;
        }
        else {
            serie.descargaAutomaticaSub=@NO;
        }
    }
    
    //PopUpIdiomaSub
    if(modificadoPopUpIdiomaSubs){
        serie.buscadorSubtitulos=[NSNumber numberWithInt:self.popUpIdiomaSubs.selectedTag];
    }
    
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}


//- (BOOL)performKeyEquivalent:(NSEvent *)theEvent{
//    unichar key = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
//    if(key == NSEnterCharacter||key==NSCarriageReturnCharacter){
//        NSLog(@"Aqui");
//        return YES;
//    }else{
//        return[super performKeyEquivalent:theEvent];
//    }
//}

@end
