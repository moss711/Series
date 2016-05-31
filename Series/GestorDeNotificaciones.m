//
//  GestorDeNotificaciones.m
//  TvTime
//
//  Created by Alexandre Blanco Gómez on 20/2/15.
//  Copyright (c) 2015 Horseware. All rights reserved.
//

#import "GestorDeNotificaciones.h"
#import "QuartzCore/CATransaction.h"
#import "QuartzCore/Caanimation.h"


@implementation GestorDeNotificaciones

//Crear un semaforo aqui y que se llame para cada funcion que se llama desde fuera(Para que se ejecute todo de uno en uno)
//Cada metodo arrancara un hilo nuevo para que el programa principal no depende de nada de dentro

-(id)initConBotonEp:(NSButton*)botonEp botonSub:(NSButton *)botonSub textField:(NSTextField*)textField{
    if ( self = [super init] ) {
        self.botonEp=botonEp;
        self.botonSub=botonSub;
        self.textField=textField;
        self.semaforo=dispatch_semaphore_create(1);
        self.actualizandoEpisodios=0;
        self.buscandoSubtitulos=0;
        self.buscandoTorrents=0;
        self.descargandoTorrents=0;
        self.descargandoSubtitulos=0;
        self.stringsIdle=[[NSMutableArray alloc]init];
        [self.stringsIdle addObject:@""];
        self.episodiosTotales=0;
         self.episodios24h=0;
         self.episodios7d=0;
         self.seriesTotales=0;
        self.epNuevos=0;
        self.subNuevos=0;
        self.serieDeEpNuevos=nil;//Si esto es nil es que hay mas de una serie involucrada
        self.serieDeSubNuevos=nil;//igual que arriba
        self.estado=GEST_NOTIF_ESTADO_IDLE;
        self.timer=nil;
        return self;
    } else
        return nil;
}

-(void)cambiarTextoA:(NSString*)nuevoTexto{//lamada solo desde dentro
    dispatch_async(dispatch_get_main_queue(), ^{
        CATransition *animation = [CATransition animation];
        animation.duration = 0.5;
        animation.type = kCATransitionPush;
        animation.subtype=kCATransitionFromBottom;
        //animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [self.textField.layer addAnimation:animation forKey:@"changeTextTransition"];
        self.textField.stringValue = nuevoTexto;
    });
}

-(void)actualizarBotonEp{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        bool estadoEp=NO;
        if(self.epNuevos>0){
            estadoEp=YES;
        }
        
        if(self.botonEp.enabled!=estadoEp){
            CATransition *animation = [CATransition animation];
            animation.duration = 0.5;
            animation.type = kCATransitionPush;
            animation.subtype=kCATransitionFromBottom;
            //animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            [self.botonEp.layer addAnimation:animation forKey:nil];
            self.botonEp.enabled=estadoEp;
            self.botonEp.hidden=!estadoEp;
        }
        
        
    });
}

-(void)actualizarBotonSub{
    dispatch_async(dispatch_get_main_queue(), ^{
        bool estadoSub=NO;
        if(self.subNuevos>0){
            estadoSub=YES;
        }
        if(self.botonSub.enabled!=estadoSub){
            CATransition *animation = [CATransition animation];
            animation.duration = 0.5;
            animation.type = kCATransitionPush;
            animation.subtype=kCATransitionFromBottom;
            //animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            [self.botonSub.layer addAnimation:animation forKey:nil];
            self.botonSub.enabled=estadoSub;
            self.botonSub.hidden=!estadoSub;
        }
    });
}


-(void)actualizarStringsIdle{
    //episodios en las ultimas 24h desde comprobar Anteriores
    //episodios en los ultimos 7d desde comprobarAnteriores
    [self.stringsIdle removeAllObjects];
    if(self.episodios24h>0){
        NSString *texto=[[NSString alloc]initWithFormat:@"%d episodios en las próximas 24h",self.episodios24h];
        [self.stringsIdle addObject:texto];
    }
    if(self.episodios7d>0){
        NSString *texto=[[NSString alloc]initWithFormat:@"%d episodios en los próximos 7 días",self.episodios7d];
        [self.stringsIdle addObject:texto];
    }
    if(self.episodiosTotales>0){
        NSString *texto=[[NSString alloc]initWithFormat:@"%d episodios en la lista",self.episodiosTotales];
        [self.stringsIdle addObject:texto];
    }
    if(self.seriesTotales>0){
        NSString *texto=[[NSString alloc]initWithFormat:@"Sigues %d series",self.seriesTotales];
        [self.stringsIdle addObject:texto];
    }
}

-(void)seleccionarStringIdle{//llamada solo desde dentro
    //(entre 0 y count -1)
    int y =  arc4random() % self.stringsIdle.count;
    [self cambiarTextoA:[self.stringsIdle objectAtIndex:y]];
}

-(void)refrescarTexto{//llamada solo desde dentro
    if(self.actualizandoEpisodios>0){
        if(self.estado!=GEST_NOTIF_ESTADO_ACTUALIZANDO_EP){//Si ya estoy en este estado no hago nada
            self.estado=GEST_NOTIF_ESTADO_ACTUALIZANDO_EP;
            [self cambiarTextoA:@"Actualizando episodios..."];
        }
    }else if(self.buscandoTorrents>0){
        if(self.estado!=GEST_NOTIF_ESTADO_BUSCANDO_TORRENTS){
            self.estado=GEST_NOTIF_ESTADO_BUSCANDO_TORRENTS;
            [self cambiarTextoA:@"Buscando torrents..."];
        }
    }else if(self.buscandoSubtitulos>0){
        if(self.estado!=GEST_NOTIF_ESTADO_BUSCANDO_SUB){
            self.estado=GEST_NOTIF_ESTADO_BUSCANDO_SUB;
            [self cambiarTextoA:@"Buscando subtítulos..."];
        }
    }else if(self.descargandoTorrents>0){
        if(self.estado!=GEST_NOTIF_ESTADO_DESCARGANDO_TORRENTS){
            self.estado=GEST_NOTIF_ESTADO_DESCARGANDO_TORRENTS;
            [self cambiarTextoA:@"Descargando torrents..."];
        }
    }else if(self.descargandoSubtitulos>0){
        if(self.estado!=GEST_NOTIF_ESTADO_DESCARGANDO_SUB){
            self.estado=GEST_NOTIF_ESTADO_DESCARGANDO_SUB;
            [self cambiarTextoA:@"Descargando subtítulos..."];
        }
    }else if(self.epNuevos>0||self.subNuevos>0){
        self.estado=GEST_NOTIF_ESTADO_IDLE;
        [self cambiarTextoA:[self refrescarTextoParaEpYSubNuevos]];
    }else{//Idle strings
        self.estado=GEST_NOTIF_ESTADO_IDLE;
        [self seleccionarStringIdle];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:600.0//a los 10 min
                                                          target:self
                                                        selector:@selector(refrescarTexto)
                                                        userInfo:nil
                                                         repeats:NO];
        [self.timer setTolerance:300];
    }
}

-(NSString *)refrescarTextoParaEpYSubNuevos{//Separado para que quede mas legible el codigo de refrescar texto
    if(self.epNuevos>0&&self.subNuevos>0){//Episodios y sub nuevos
        NSString *texto;
        if(self.epNuevos==1){//Parte de episodios
            texto=[[NSString alloc]initWithFormat:@"Un episodio y "];
        }else{
            texto=[[NSString alloc]initWithFormat:@"%d episodios y ",self.epNuevos];
        }
        if(self.subNuevos==1){//Parte de subtitulos
            NSString *apoyo=[[NSString alloc]initWithFormat:@"un subtítulo nuevos"];
            texto=[texto stringByAppendingString:apoyo];
        }else{
            NSString *apoyo=[[NSString alloc]initWithFormat:@"%d subtítulos nuevos",self.subNuevos];
            texto=[texto stringByAppendingString:apoyo];
        }
        if([self.serieDeSubNuevos isEqualToString:self.serieDeEpNuevos]){//Esto significa que solo hay una serie involucrada
            NSString* apoyo=[[NSString alloc] initWithFormat:@" de %@",self.serieDeEpNuevos];
            texto=[texto stringByAppendingString:apoyo];
        }
        return texto;
    }else if(self.epNuevos>0&&self.subNuevos==0){//Solo episodios nuevos
        if(self.serieDeEpNuevos!=nil){
            NSString *texto;
            if(self.epNuevos==1){
                texto=[[NSString alloc]initWithFormat:@"Un episodio nuevo de %@",self.serieDeEpNuevos];
            }else{
                texto=[[NSString alloc]initWithFormat:@"%d episodios nuevos de %@",self.epNuevos,self.serieDeEpNuevos];
            }
            
            return texto;
        }else{
            NSString *texto=[[NSString alloc]initWithFormat:@"%d episodios nuevos",self.epNuevos];
            return texto;
        }
    }else if(self.epNuevos==0&&self.subNuevos>0){//Solo subtitulos nuevos
        if(self.serieDeSubNuevos!=nil){
            NSString *texto;
            if(self.subNuevos==1){
                texto=[[NSString alloc]initWithFormat:@"Un subtítulo nuevo de %@",self.serieDeSubNuevos];
            }else{
                texto=[[NSString alloc]initWithFormat:@"%d subtítulos nuevos de %@",self.subNuevos,self.serieDeSubNuevos];
            }
            return texto;
        }else{
            NSString *texto=[[NSString alloc]initWithFormat:@"%d subtítulos nuevos",self.subNuevos];
            return texto;
        }
    }
    return nil;//No deberia llegar a aqui nunca
}


-(void)inicioDeActualizarEpisodios{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_semaphore_wait(self.semaforo,DISPATCH_TIME_FOREVER);
        self.actualizandoEpisodios++;
        [self refrescarTexto];
        dispatch_semaphore_signal(self.semaforo);
    });
}
-(void)finDeActualizarEpisodiosConEpisodiosTotales:(int)numEpisodiosTotales episodios24h:(int)numEpisodios24h episodios7d:(int)numEpisodios7d seriesTotales:(int)numSeriesTotales{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_semaphore_wait(self.semaforo,DISPATCH_TIME_FOREVER);
        self.actualizandoEpisodios--;
        self.episodiosTotales=numEpisodiosTotales;
        self.episodios24h=numEpisodios24h;
        self.episodios7d=numEpisodios7d;
        self.seriesTotales=numSeriesTotales;
        [self actualizarStringsIdle];
        [self refrescarTexto];
        dispatch_semaphore_signal(self.semaforo);
    });
}

-(void)inicioDeBuscarTorrents{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_semaphore_wait(self.semaforo,DISPATCH_TIME_FOREVER);
        self.buscandoTorrents++;
        [self refrescarTexto];
        dispatch_semaphore_signal(self.semaforo);
    });
}

-(void)finDeBuscarTorrentsConEpisodiosNuevos:(int)numEpNuevos serieDeEpNuevos:(NSString *)serieDeEpNuevos{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_semaphore_wait(self.semaforo,DISPATCH_TIME_FOREVER);
        self.buscandoTorrents--;
        self.epNuevos=numEpNuevos;
        self.serieDeEpNuevos=serieDeEpNuevos;
        [self actualizarBotonEp];
        //Ojo chapuza!
        //esto es porque se llama a buscarSubs justo despues de terminar buscarTorrents y si no se hace la chapuza el estado pasa por el de ep nuevo entre Buscando torrents y Buscando subtitulos
        dispatch_semaphore_signal(self.semaforo);
        [NSThread sleepForTimeInterval:0.01];
        dispatch_semaphore_wait(self.semaforo,DISPATCH_TIME_FOREVER);
        //Fin de chapuza
        
        [self refrescarTexto];
        dispatch_semaphore_signal(self.semaforo);
    });
}

-(void)inicioDeBuscarSubtitulos{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_semaphore_wait(self.semaforo,DISPATCH_TIME_FOREVER);
        self.buscandoSubtitulos++;
        [self refrescarTexto];
        dispatch_semaphore_signal(self.semaforo);
    });
}

-(void)finDeBuscarSubtitulosConSubtitulosNuevos:(int)subNuevos serieDeSubNuevos:(NSString *)serieDeSubNuevos{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_semaphore_wait(self.semaforo,DISPATCH_TIME_FOREVER);
        self.buscandoSubtitulos--;
        self.subNuevos=subNuevos;
        self.serieDeSubNuevos=serieDeSubNuevos;
        [self actualizarBotonSub];
        [self refrescarTexto];
        dispatch_semaphore_signal(self.semaforo);
    });
}

-(void)inicioDeDescargarTorrents{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_semaphore_wait(self.semaforo,DISPATCH_TIME_FOREVER);
        self.descargandoTorrents++;
        [self refrescarTexto];
        dispatch_semaphore_signal(self.semaforo);
    });
}

-(void)finDeDescargarTorrentsConEpisodiosNuevos:(int)numEpNuevos serieDeEpNuevos:(NSString *)serieDeEpNuevos{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_semaphore_wait(self.semaforo,DISPATCH_TIME_FOREVER);
        self.descargandoTorrents--;
        self.epNuevos=numEpNuevos;
        self.serieDeEpNuevos=serieDeEpNuevos;
        [self actualizarBotonEp];
        [self refrescarTexto];
        dispatch_semaphore_signal(self.semaforo);
    });
}

-(void)inicioDeDescargarSubtitulos{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_semaphore_wait(self.semaforo,DISPATCH_TIME_FOREVER);
        self.descargandoSubtitulos++;
        [self refrescarTexto];
        dispatch_semaphore_signal(self.semaforo);
    });
}

-(void)finDeDescargarSubtitulosConSubtitulosNuevos:(int)subNuevos serieDeSubNuevos:(NSString *)serieDeSubNuevos{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_semaphore_wait(self.semaforo,DISPATCH_TIME_FOREVER);
        self.descargandoSubtitulos--;
        self.subNuevos=subNuevos;
        self.serieDeSubNuevos=serieDeSubNuevos;
        [self actualizarBotonSub];
        [self refrescarTexto];
        dispatch_semaphore_signal(self.semaforo);
    });
}

-(void)actualizarEpNuevosConEpisodiosNuevos:(int)numEpNuevos serieDeEpNuevos:(NSString *)serieDeEpNuevos{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_semaphore_wait(self.semaforo,DISPATCH_TIME_FOREVER);
        self.epNuevos=numEpNuevos;
        self.serieDeEpNuevos=serieDeEpNuevos;
        [self actualizarBotonEp];
        [self refrescarTexto];
        dispatch_semaphore_signal(self.semaforo);
    });
}

-(void)actualizarSubtitulosNuevosConSubtitulosNuevos:(int)subNuevos serieDeSubNuevos:(NSString *)serieDeSubNuevos{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_semaphore_wait(self.semaforo,DISPATCH_TIME_FOREVER);
        self.subNuevos=subNuevos;
        self.serieDeSubNuevos=serieDeSubNuevos;
        [self actualizarBotonSub];
        [self refrescarTexto];
        dispatch_semaphore_signal(self.semaforo);
    });
}

-(void)actualizarEpYSubtitulosNuevosConEpisodiosNuevo:(int)numEpNuevos serieDeEpNuevos:(NSString *)serieDeEpNuevos subtitulosNuevos:(int)subNuevos serieDeSubNuevos:(NSString *)serieDeSubNuevos{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_semaphore_wait(self.semaforo,DISPATCH_TIME_FOREVER);
        self.subNuevos=subNuevos;
        self.serieDeSubNuevos=serieDeSubNuevos;
        [self actualizarBotonSub];
        self.epNuevos=numEpNuevos;
        self.serieDeEpNuevos=serieDeEpNuevos;
        [self actualizarBotonEp];
        [self refrescarTexto];
        dispatch_semaphore_signal(self.semaforo);
    });
}

-(void)actualizarTodoComoDescargado{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_semaphore_wait(self.semaforo,DISPATCH_TIME_FOREVER);
        self.subNuevos=0;
        self.epNuevos=0;
        self.serieDeEpNuevos=nil;
        self.serieDeSubNuevos=nil;
        [self actualizarBotonEp];
        [self actualizarBotonSub];
        [self refrescarTexto];
        dispatch_semaphore_signal(self.semaforo);
    });
}

//el proper tiene preferencia??
//Si hay ep y subs pero son de la misma serie string especial
@end
