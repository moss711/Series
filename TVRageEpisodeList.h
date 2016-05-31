//
//  TVRageEpisodeList.h
//  TvTime
//
//  Created by Alexandre Blanco Gómez on 28/11/14.
//  Copyright (c) 2014 Horseware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Serie.h"
#import "EpisodioTemp.h"

@interface TVRageEpisodeList : NSObject

@property int sid;
@property NSXMLDocument *xmlEpisodeList;

-(instancetype)initWithSid:(int)sid;
-(NSDate *)getAirdateDeEpisodio:(EpisodioTemp *)episodio;
-(void)rellenarEpNumDeEpisodio:(EpisodioTemp *)episodio;
-(BOOL)parsear;
-(NSMutableArray *)getEpisodiosDesdeTemporada:(int)temporadaReferencia Episodio:(int)episodioReferencia yFecha:(NSDate *)fechaReferencia conIntervalo:(NSTimeInterval)intervalo valido:(Boolean)esValidoElIntervalo dePais:(NSString *) pais;

-(NSMutableArray *)listaDeEpisodiosEmitidosConLatestEpisode:(EpisodioTemp*)latestEpisode;
@end
