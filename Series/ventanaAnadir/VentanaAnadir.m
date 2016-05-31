//
//  ventanaAnadir.m
//  TvTime
//
//  Created by Alexandre Blanco Gómez on 7/1/15.
//  Copyright (c) 2015 Horseware. All rights reserved.
//

#import "VentanaAnadir.h"
#import "TVRageSearch.h"
#import "TVRageSerie.h"
#import "CeldaTVRageSearch.h"
#import "TheTVDBSearch.h"
#import "TheTVDBSerie.h"
#import "TheTVDBBanners.h"
#import "QuartzCore/CATransaction.h"
#import "QuartzCore/Caanimation.h"
#import "TVRageEpisodeInfo.h"
#import "TVRageEpisodeList.h"
#import "EpisodioTemp.h"

@interface VentanaAnadir ()

@property TVRageSearch *tvRageSearch;
@property NSArray *resultadosBusquedaSerieTVRage;
@property TVRageSerie *serieSeleccionada;
@property TheTVDBSearch *theTVDBSearch;
@property TheTVDBSerie *serieSeleccionadaTheTVDB;
@property NSArray *episodiosAnteriores;
@property int parteDerecha;
@property EpisodioTemp* episodioReferencia;

@end

@implementation VentanaAnadir

-(instancetype)init{
    self=[super initWithWindowNibName:@"VentanaAnadir"];
    self.resultadosBusquedaSerieTVRage=[[NSArray alloc]init];
    self.parteDerecha=PARTE_DERECHA_NADA;
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}


//Estas notificaciones son de cuando se modifica el contenido, no de cuando se hace click
- (void)controlTextDidBeginEditing:(NSNotification *)notification{
    
}


//Estas notificaciones son de cuando se hace click fuera o se da enter(se pierde el focus)
- (void)controlTextDidEndEditing:(NSNotification *)aNotification{
    NSTextField *textField =[aNotification object];
    if(textField == self.textFieldNombreSerie){
        [self comenzarBusquedaTvRage];
    }else if(textField ==self.textFieldIDTheTVDB){
        int nuevasel=self.textFieldIDTheTVDB.intValue;
        NSLog(@"did end editing!!!!");
        if(nuevasel!=self.serieSeleccionadaTheTVDB.sid){
            NSLog(@"cambio!");
            self.serieSeleccionadaTheTVDB.sid=nuevasel;
            [self comenzarBusquedaImagenes];
        }
        
    }else if(textField ==self.textFieldEpisodioReferencia){
        self.textFieldEpisodioReferencia.stringValue=[[NSString alloc]initWithFormat:@"%@ %@",self.episodioReferencia.numEpisodio,self.episodioReferencia.nombreEpisodio];
    }
    
    [self.window makeFirstResponder:self];
}
//de cuando se hace click
-(void)textFieldDidBecomeFirstResponder:(NSNotification *)notification{
    NSTextField *textField = [notification object];
    if(textField==self.textFieldNombreSerie){
        if(self.parteDerecha!=PARTE_DERECHA_BUSQUEDA_SERIE_TVRAGE){
            self.parteDerecha=PARTE_DERECHA_BUSQUEDA_SERIE_TVRAGE;
            [self.tablaDerecha reloadData];
        }
    }else if(textField==self.textFieldIDTheTVDB){
        if(self.parteDerecha!=PARTE_DERECHA_BUSQUEDA_SERIE_THETVDB){
            self.parteDerecha=PARTE_DERECHA_BUSQUEDA_SERIE_THETVDB;
            [self.tablaDerecha reloadData];
            //NSLog(@"reload!");
        }
    }else if(textField==self.textFieldEpisodioReferencia){
        if(self.parteDerecha!=PARTE_DERECHA_LISTA_EPISODIOS_ANTERIORES){
            self.parteDerecha=PARTE_DERECHA_LISTA_EPISODIOS_ANTERIORES;
            [self.tablaDerecha reloadData];
        }
    }
}


-(void)comenzarBusquedaTvRage{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.tvRageSearch=[[TVRageSearch alloc]initWithString:self.textFieldNombreSerie.stringValue];
        
        NSArray *resultados=[self.tvRageSearch getBusqueda];
        
        self.resultadosBusquedaSerieTVRage=resultados;
        self.parteDerecha=PARTE_DERECHA_BUSQUEDA_SERIE_TVRAGE;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tablaDerecha reloadData];
        });
    });
}

-(void)comenzarBusquedaEpisodiosAnteriores{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int idTVRage=self.serieSeleccionada.sid;
        TVRageEpisodeInfo* tvRageEpisodeInfo=[[TVRageEpisodeInfo alloc]initWithSid:idTVRage];
        [tvRageEpisodeInfo parsear];
        EpisodioTemp* lastEpisode=tvRageEpisodeInfo.getLatestEpisode;
        TVRageEpisodeList* tvRageEpisodeList=[[TVRageEpisodeList alloc]initWithSid:idTVRage];
        [tvRageEpisodeList parsear];
        
        if(self.serieSeleccionada.sid!=idTVRage){
            return;
        }
        NSMutableArray* episodiosAnterioes=[tvRageEpisodeList listaDeEpisodiosEmitidosConLatestEpisode:lastEpisode];
        
        NSArray *sortedArray;
        sortedArray = [episodiosAnterioes sortedArrayUsingSelector:@selector(compareInv:)];
        
        self.episodiosAnteriores=sortedArray;
        self.episodioReferencia=nil;
        if(sortedArray.count>0){
            EpisodioTemp* episodioTemp=[sortedArray objectAtIndex:0];
            self.episodioReferencia=episodioTemp;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(self.episodioReferencia==nil){
                self.textFieldEpisodioReferencia.stringValue=@"";
            }else{
                self.textFieldEpisodioReferencia.stringValue=[[NSString alloc]initWithFormat:@"%@ %@",self.episodioReferencia.numEpisodio,self.episodioReferencia.nombreEpisodio];
            }
            if(self.parteDerecha==PARTE_DERECHA_LISTA_EPISODIOS_ANTERIORES){
                [self.tablaDerecha reloadData];
            }
        });
    });
}

-(void)comenzarBusquedaTheTVDB{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        TheTVDBSearch *busqueda=[[TheTVDBSearch alloc]initWithNombre:self.serieSeleccionada.nombre idTVRage:self.serieSeleccionada.sid];
        
        if(busqueda.idTVRage!=self.serieSeleccionada.sid){//Si se selecciono otra mientras se buscaba
            return;
        }
        
        self.theTVDBSearch=busqueda;
        self.serieSeleccionadaTheTVDB=self.theTVDBSearch.getPrimeraOpcion;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.textFieldIDTheTVDB.stringValue=[[NSString alloc]initWithFormat:@"%d",self.serieSeleccionadaTheTVDB.sid];
            if(self.parteDerecha==PARTE_DERECHA_BUSQUEDA_SERIE_THETVDB){
                [self.tablaDerecha reloadData];
            }
        });
        [self comenzarBusquedaImagenes];
    });
}

-(void)comenzarBusquedaImagenes{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if(self.serieSeleccionadaTheTVDB==nil||self.theTVDBSearch.idTVRage!=self.serieSeleccionada.sid){
            return;
        }
        int idTheTVDB=self.serieSeleccionadaTheTVDB.sid;
        int idTVRage=self.serieSeleccionada.sid;
        TheTVDBBanners *banners=[[TheTVDBBanners alloc]initWithID:idTheTVDB];
        
        NSURL *furl = [[NSURL alloc]initWithString:banners.getURLMiniautraMejorValorada];
        NSData *data=[[NSData alloc]initWithContentsOfURL:furl];
        NSImage* miniatura=[[NSImage alloc] initWithContentsOfURL:furl];
        NSSize tamano;
        tamano.height=108;
        tamano.width=192;
        miniatura=[self resizeImage:miniatura size:tamano];
        
        furl = [[NSURL alloc]initWithString:banners.getURLPosterMejorValorado];
        data=[[NSData alloc]initWithContentsOfURL:furl];
        NSImage* poster=[[NSImage alloc]initWithData:data];
        
        if(self.serieSeleccionada.sid!=idTVRage||self.serieSeleccionadaTheTVDB.sid!=idTheTVDB){
            return;
        }
        self.serieSeleccionadaTheTVDB.banners=banners;
        self.serieSeleccionada.miniatura=miniatura;
        self.serieSeleccionada.poster=poster;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            CATransition *animation = [CATransition animation];
            animation.duration = 0.25;
            animation.type = kCATransitionFade;
            //animation.subtype=kCATransitionFromBottom;
            //animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            [self.imageViewPoster.layer addAnimation:animation forKey:@"changeImage"];
            self.imageViewPoster.image=self.serieSeleccionada.poster;
        });
    });
}

- (void)mouseDown:(NSEvent *)event{
    [self.window makeFirstResponder:nil];
}

- (IBAction)botonCancelar:(id)sender {
    [self close];
}

- (IBAction)botonAceptar:(id)sender {
    [self close];
}
- (IBAction)cambioPopUpResolucion:(id)sender {
}
- (IBAction)cambioPopUpIdiomaSubs:(id)sender {
}
- (IBAction)cambioCheckBoxEsAnime:(id)sender {
}


//Seleccion en la tabla
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification{
    if(self.tablaDerecha.numberOfSelectedRows>0){
        if(self.parteDerecha==PARTE_DERECHA_BUSQUEDA_SERIE_TVRAGE){
            TVRageSerie* nuevaSeleccion=[self.resultadosBusquedaSerieTVRage objectAtIndex:self.tablaDerecha.selectedRow];
            if(nuevaSeleccion.sid!=self.serieSeleccionada.sid){
                self.serieSeleccionada=nuevaSeleccion;
                [self nuevaSeleccionDeSerieTvRage];
            }
        }else if(self.parteDerecha==PARTE_DERECHA_BUSQUEDA_SERIE_THETVDB){
            TheTVDBSerie* seleccion =[self.theTVDBSearch.series objectAtIndex:self.tablaDerecha.selectedRow];
            if(seleccion.sid!=self.serieSeleccionadaTheTVDB.sid){
                self.serieSeleccionadaTheTVDB=seleccion;
                [self comenzarBusquedaImagenes];
            }
        }else if(self.parteDerecha==PARTE_DERECHA_LISTA_EPISODIOS_ANTERIORES){
            EpisodioTemp* seleccion=[self.episodiosAnteriores objectAtIndex:self.tablaDerecha.selectedRow];
            if([seleccion compare:self.episodioReferencia]!=NSOrderedSame){
                self.episodioReferencia=seleccion;
                self.textFieldEpisodioReferencia.stringValue=[[NSString alloc]initWithFormat:@"%@ %@",seleccion.numEpisodio,seleccion.nombreEpisodio];
            }
        }
    }
}

-(void)nuevaSeleccionDeSerieTvRage{
    self.textFieldNombreSerie.stringValue=self.serieSeleccionada.nombre;
    self.textFieldPaisAno.stringValue=self.serieSeleccionada.getStringPaisAno;
    if(self.serieSeleccionada.esAnime){
        self.checkBoxEsAnime.state=NSOnState;
    }else{
        self.checkBoxEsAnime.state=NSOffState;
    }
    [self cambioCheckBoxEsAnime:self];
    [self comenzarBusquedaEpisodiosAnteriores];
    [self comenzarBusquedaTheTVDB];//Se llama a semaforo dentro
    
    
}

//Datamodel
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if(self.parteDerecha==PARTE_DERECHA_BUSQUEDA_SERIE_TVRAGE){
        TVRageSerie* serie=[self.resultadosBusquedaSerieTVRage objectAtIndex:row];
        CeldaTVRageSearch *result = [tableView makeViewWithIdentifier:@"celdaTVRageSearch" owner:self];
        result.nombre.stringValue=serie.nombre;
        result.paisAno.stringValue=serie.getStringPaisAno;
        
        return result;
    }else if(self.parteDerecha==PARTE_DERECHA_BUSQUEDA_SERIE_THETVDB){
        TheTVDBSerie* serie=[self.theTVDBSearch.series objectAtIndex:row];
        CeldaTVRageSearch *result = [tableView makeViewWithIdentifier:@"celdaTVRageSearch" owner:self];
        result.nombre.stringValue=serie.nombre;
        result.paisAno.stringValue=serie.getStringPaisAno;
        
        return result;
    }else if(self.parteDerecha==PARTE_DERECHA_LISTA_EPISODIOS_ANTERIORES){
        EpisodioTemp* ep=[self.episodiosAnteriores objectAtIndex:row];
        CeldaTVRageSearch *result = [tableView makeViewWithIdentifier:@"celdaTVRageSearch" owner:self];
        result.nombre.stringValue=[[NSString alloc]initWithFormat:@"%@ %@",ep.numEpisodio,ep.nombreEpisodio];
        NSString* str=[NSDateFormatter localizedStringFromDate:ep.hora
                                       dateStyle:NSDateFormatterShortStyle
                                       timeStyle:NSDateFormatterNoStyle];
        result.paisAno.stringValue=str;
        return result;
    }
    return nil;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    //NSLog(@"Pide");
    if(self.parteDerecha==PARTE_DERECHA_BUSQUEDA_SERIE_TVRAGE){
        return self.resultadosBusquedaSerieTVRage.count;
    }else if(self.parteDerecha==PARTE_DERECHA_BUSQUEDA_SERIE_THETVDB){
        return self.theTVDBSearch.series.count;
    }else if(self.parteDerecha==PARTE_DERECHA_LISTA_EPISODIOS_ANTERIORES){
        return self.episodiosAnteriores.count;
        
    }
    return 0;
}


//Utilidades
- (NSImage*) resizeImage:(NSImage*)sourceImage size:(NSSize)size
{
    
    NSRect targetFrame = NSMakeRect(0, 0, size.width, size.height);
    NSImage* targetImage = nil;
    NSImageRep *sourceImageRep =
    [sourceImage bestRepresentationForRect:targetFrame
                                   context:nil
                                     hints:nil];
    
    targetImage = [[NSImage alloc] initWithSize:size];
    
    [targetImage lockFocus];
    [sourceImageRep drawInRect: targetFrame];
    [targetImage unlockFocus];
    
    return targetImage;
}

@end
