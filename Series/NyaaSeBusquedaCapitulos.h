//
//  NyaaSeBusquedaCapitulos.h
//  TvTime
//
//  Created by Alexandre Blanco Gómez on 3/4/15.
//  Copyright (c) 2015 Horseware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjectiveGumbo.h"
#import "Episodio.h"

@interface NyaaSeBusquedaCapitulos : NSObject

@property NSString* nombreSerie;
@property NSString* nombreSerieTrimeado;
@property int capitulo;
@property int temporada;
@property OGNode *data;
@property Episodio *episodio;
@property NSArray *descargas;

-(instancetype)initWithEpisodio:(Episodio*)episodio;
@end
