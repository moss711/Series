//
//  GestorDeFicheros.h
//  TvTime
//
//  Created by Alexandre Blanco Gómez on 1/11/14.
//  Copyright (c) 2014 Horseware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Episodio.h"
#import "GestorDeOpciones.h"

@interface GestorDeFicheros : NSObject

@property GestorDeOpciones* gestorOpciones;

-(instancetype)initWithGestorOpciones:(GestorDeOpciones*)gestorOpciones;
-(BOOL)guardarPosterConData:(NSData*)dataPoster conSid:(NSNumber*)sid;
-(BOOL)guardarPoster:(NSImage*)poster conSid:(NSNumber*)sid;
-(BOOL)guardarTorrentDeEpisodio:(Episodio*)ep ConURL:(NSString *)stringURLTorrent;
-(BOOL)guardarSubDeEpisodio:(Episodio*)ep ConURL:(NSString *)stringURLSub;
-(NSString *)rutaTorrentDeEpisodio:(Episodio *)ep;
-(Boolean)eliminarPosterConSid:(NSNumber*)sid;
-(Boolean)eliminarTorrentDeEpisodio:(Episodio *)ep;
-(NSImage*)recuperarPosterConSid:(NSNumber*)sid;
@end
