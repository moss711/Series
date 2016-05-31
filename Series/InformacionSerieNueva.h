//
//  InformacionSerieNueva.h
//  TvTime
//
//  Created by Alexandre Blanco Gómez on 05/08/14.
//  Copyright (c) 2014 Horseware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TheTVDBBanners.h"
#import "Serie.h"

@interface InformacionSerieNueva : NSObject
@property NSNumber *sid;
@property NSString *serie;
@property NSString  *pais;
@property NSNumber *ano;
@property NSImage *miniatura;
@property NSString *poster;
@property NSNumber *idTVdb;
@property TheTVDBBanners *tvDBBanners;
@property Serie* objSerie;
- (id)initWithSid:(NSNumber *)sid;
- (void)buscarImagen;
- (NSNumber*)obtenerIDTVdb;
- (NSData*)obtenerPoster;
- (void)parsearXMLImagenes;
@end
