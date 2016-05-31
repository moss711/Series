//
//  Serie.m
//  TvTime
//
//  Created by Alexandre Blanco Gómez on 30/10/14.
//  Copyright (c) 2014 Horseware. All rights reserved.
//

#import "Serie.h"
#import "Episodio.h"


@implementation Serie

@dynamic ano;
@dynamic descargaAutomaticaEp;
@dynamic descargaAutomaticaSub;
@dynamic miniatura;
@dynamic poster;
@dynamic pais;
@dynamic prefiereHD;
@dynamic serie;
@dynamic nombreParaMostrar;
@dynamic nombreParaBusquedaEp;
@dynamic nombreParaBusquedaSubs;
@dynamic sid;
@dynamic ultimaFechaEnAnteriores;
@dynamic idTVdb;
@dynamic resolucionPreferida;
@dynamic buscadorTorrent;
@dynamic buscadorSubtitulos;
@dynamic episodios;
@dynamic ultimaTemporadaEnAnteriores;
@dynamic ultimoEpisodioEnAnteriores;
@dynamic idSubtitulosEs;


-(NSString*)getNombreAMostrar{
    if(self.nombreParaMostrar!=nil){
        return self.nombreParaMostrar;
    }else{
        return self.serie;
    }
}

@end
