//
//  GestorDeNotificaciones.h
//  TvTime
//
//  Created by Alexandre Blanco Gómez on 20/2/15.
//  Copyright (c) 2015 Horseware. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GestorDeNotificaciones : NSObject

@property NSButton* botonEp;
@property NSButton* botonSub;
@property NSTextField* textField;
@property dispatch_semaphore_t semaforo;
@property int actualizandoEpisodios;
@property int buscandoTorrents;
@property int buscandoSubtitulos;
@property int descargandoTorrents;
@property int descargandoSubtitulos;
//Para los strings de idle
@property NSMutableArray* stringsIdle;
@property int episodiosTotales;
@property int episodios24h;
@property int episodios7d;
@property int seriesTotales;
@property int estado;

//Para mostrar num de episodios y subs pendientes
@property int epNuevos;
@property int subNuevos;
@property NSString* serieDeEpNuevos;
@property NSString* serieDeSubNuevos;
@property NSTimer* timer;

-(id)initConBotonEp:(NSButton*)botonEp botonSub:(NSButton *)botonSub textField:(NSTextField*)textField;

-(void)inicioDeActualizarEpisodios;
-(void)finDeActualizarEpisodiosConEpisodiosTotales:(int)numEpisodiosTotales episodios24h:(int)numEpisodios24h episodios7d:(int)numEpisodios7d seriesTotales:(int)numSeriesTotales;

-(void)inicioDeBuscarTorrents;
-(void)finDeBuscarTorrentsConEpisodiosNuevos:(int)numEpNuevos serieDeEpNuevos:(NSString*) serieDeEpNuevos;

-(void)inicioDeBuscarSubtitulos;
-(void)finDeBuscarSubtitulosConSubtitulosNuevos:(int)subNuevos serieDeSubNuevos:(NSString*) serieDeSubNuevos;

-(void)inicioDeDescargarTorrents;
-(void)finDeDescargarTorrentsConEpisodiosNuevos:(int)numEpNuevos serieDeEpNuevos:(NSString*) serieDeEpNuevos;

-(void)inicioDeDescargarSubtitulos;
-(void)finDeDescargarSubtitulosConSubtitulosNuevos:(int)subNuevos serieDeSubNuevos:(NSString*) serieDeSubNuevos;

-(void)actualizarEpNuevosConEpisodiosNuevos:(int)numEpNuevos serieDeEpNuevos:(NSString*) serieDeEpNuevos;
-(void)actualizarSubtitulosNuevosConSubtitulosNuevos:(int)subNuevos serieDeSubNuevos:(NSString*) serieDeSubNuevos;
-(void)actualizarEpYSubtitulosNuevosConEpisodiosNuevo:(int)numEpNuevos serieDeEpNuevos:(NSString*) serieDeEpNuevos subtitulosNuevos:(int)subNuevos serieDeSubNuevos:(NSString*) serieDeSubNuevos;
-(void)actualizarTodoComoDescargado;



typedef NS_ENUM(int, EstadoGestorDeNotificaciones) {
    GEST_NOTIF_ESTADO_ACTUALIZANDO_EP = 0,
    GEST_NOTIF_ESTADO_BUSCANDO_TORRENTS =1,
    GEST_NOTIF_ESTADO_BUSCANDO_SUB=2,
    GEST_NOTIF_ESTADO_DESCARGANDO_TORRENTS=3,
    GEST_NOTIF_ESTADO_DESCARGANDO_SUB=4,
    GEST_NOTIF_ESTADO_IDLE=5
};
@end
