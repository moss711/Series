//
//  Serie.h
//  TvTime
//
//  Created by Alexandre Blanco Gómez on 30/10/14.
//  Copyright (c) 2014 Horseware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Episodio;

@interface Serie : NSManagedObject

@property (nonatomic, retain) NSNumber * ano;
@property (nonatomic, retain) NSNumber * descargaAutomaticaEp;
@property (nonatomic, retain) NSNumber * descargaAutomaticaSub;
@property (nonatomic, retain) NSData * miniatura;
@property (nonatomic, retain) NSString * poster;
@property (nonatomic, retain) NSString * pais;
@property (nonatomic, retain) NSNumber * prefiereHD;
@property (nonatomic, retain) NSString * serie;
@property (nonatomic, retain) NSString * nombreParaMostrar;
@property (nonatomic, retain) NSString * nombreParaBusquedaEp;
@property (nonatomic, retain) NSString * nombreParaBusquedaSubs;
@property (nonatomic, retain) NSNumber * sid;
@property (nonatomic, retain) NSDate * ultimaFechaEnAnteriores;
@property (nonatomic, retain) NSNumber * idTVdb;
@property (nonatomic, retain) NSNumber * resolucionPreferida;
@property (nonatomic, retain) NSNumber * buscadorTorrent;
@property (nonatomic, retain) NSNumber * buscadorSubtitulos;
@property (nonatomic, retain) NSNumber * ultimaTemporadaEnAnteriores;
@property (nonatomic, retain) NSNumber * ultimoEpisodioEnAnteriores;
@property (nonatomic, retain) NSNumber * idSubtitulosEs;
@property (nonatomic, retain) NSSet *episodios;

typedef NS_ENUM(NSInteger, TipoBuscadorTorrents) {
    buscadorSeriesOccidentales = 0,
    buscadorSeriesAnimeSubsIncrustados =1
};
typedef NS_ENUM(NSInteger,TipoBuscadorSubtitulos){
    Addic7ed=0,
    SubtitulosES=1
};

-(NSString*)getNombreAMostrar;

@end

@interface Serie (CoreDataGeneratedAccessors)

- (void)addEpisodiosObject:(Episodio *)value;
- (void)removeEpisodiosObject:(Episodio *)value;
- (void)addEpisodios:(NSSet *)values;
- (void)removeEpisodios:(NSSet *)values;

@end
