//
//  CeldaAnteriorSub.h
//  TvTime
//
//  Created by Alexandre Blanco Gómez on 14/08/14.
//  Copyright (c) 2014 Horseware. All rights reserved.
//

#import "CeldaPrincipal.h"
#import "ImageViewClickDescargar.h"
#import "ImageViewClickSub.h"

@interface CeldaAnteriorSub : CeldaPrincipal
@property IBOutlet ImageViewClickDescargar *banderaDescarga;
@property IBOutlet ImageViewClickSub *banderaSub;
@property Boolean enableSub;
@property Boolean enableEp;

-(void)marcarSubDescargado;
-(void)marcarEpDescargado;
-(void)marcarSubNoDescargado;
-(void)marcarEpNoDescargado;
-(void)excluirBusquedaEp;
-(void)noExcluirBusquedaEp;
-(void)excluirBusquedaSub;
-(void)noExcluirBusquedaSub;
-(void)mostrarInformacionSerie;
-(void)highlightSub;
-(void)quitarHighlight;
-(void)highlightEp;
-(void)mostrarBusquedaEp;
-(void)descargarEp;
-(void)eliminarEp;
@end
