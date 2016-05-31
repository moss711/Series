//
//  Episodio.h
//  TvTime
//
//  Created by Alexandre Blanco Gómez on 30/10/14.
//  Copyright (c) 2014 Horseware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DescargaTemp.h"

@class Serie;
@class DescargaTemp;

@interface Episodio : NSManagedObject

@property (nonatomic, retain) NSNumber * avisado;
@property (nonatomic, retain) NSNumber * avisadoSub;
@property (nonatomic, retain) NSDate * hora;
@property (nonatomic, retain) NSDate * fechaInclusionEnAnteriores;
@property (nonatomic, retain) NSString * nombreEpisodio;
@property (nonatomic, retain) NSString * numEpisodio;
@property (nonatomic, retain) NSNumber * numEpisodioTotal;
@property (nonatomic, retain) NSNumber * usarNumEpisodioTotal;
@property (nonatomic, retain) NSNumber * tipo;
@property (nonatomic, retain) NSString * urlSub;
@property (nonatomic, retain) NSString * urlSubSupuesto;
@property (nonatomic, retain) NSString * urlSubSupuestoEpDescargado;
@property (nonatomic, retain) NSString * releaseGroup;
@property (nonatomic, retain) NSString * releaseGroupEpDescargado;
@property (nonatomic,retain) NSString * magnetLink;
@property (nonatomic,retain) NSString * nombreDescarga;
@property (nonatomic, retain) NSNumber * hayProper;
@property (nonatomic, retain) NSNumber * esMagnet;
@property (nonatomic, retain) NSNumber * seguirBuscando;
@property (nonatomic, retain) NSNumber * excluirBusquedaEp;
@property (nonatomic, retain) NSNumber * excluirBusquedaSub;
@property (nonatomic, retain) Serie *serie;


-(Boolean)numCapituloAnteriorA:(Episodio*)otroEpisodio;
- (void)mostrarBusquedaEpisodio;
- (Boolean)descargarSub;
- (NSString*)horaString;
-(long)diasRestantes;
- (long)horasRestantes;
-(NSString *)buscarSub;
- (DescargaTemp *)buscarTorrent;
- (Boolean)descargarEpisodio;
- (NSComparisonResult)compareAnteriores:(Episodio *)otherObject;
- (NSComparisonResult)compareProximos:(Episodio *)otherObject ;
- (NSString*)buscarSubSupuestoConDireccion:(NSString*)direccion;
- (NSString*)buscarSubSupuestoEpDescargadoConDireccion:(NSString*)direccion;

-(int)getNumeroEpisodio;
-(int)getNumeroTemporada;

@end