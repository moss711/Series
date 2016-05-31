//
//  NyaaSeBusquedaCapitulos.m
//  TvTime
//
//  Created by Alexandre Blanco Gómez on 3/4/15.
//  Copyright (c) 2015 Horseware. All rights reserved.
//

#import "NyaaSeBusquedaCapitulos.h"
#import "ObjectiveGumbo.h"
#import "DescargaTemp.h"
#import "Episodio.h"
#import "Serie.h"


@implementation NyaaSeBusquedaCapitulos

-(instancetype)initWithEpisodio:(Episodio*)episodio{
    self = [super init];
    if(self) {
        self.capitulo=episodio.getNumeroEpisodio;
        self.temporada=episodio.getNumeroTemporada;
        self.nombreSerie=episodio.serie.nombreParaBusquedaEp;
        self.episodio=episodio;
        if(self.nombreSerie==nil){
            self.nombreSerie=episodio.serie.serie;
        }
        
                
        
        NSCharacterSet *trim = [NSCharacterSet characterSetWithCharactersInString:@"(;);'"];
        self.nombreSerieTrimeado = [[self.nombreSerie componentsSeparatedByCharactersInSet: trim] componentsJoinedByString: @""];
        
        NSString *direccion=[[NSString alloc]initWithFormat:@"http://www.nyaa.se/?page=search&term=%%22%@+%02d%%22&sort=2",self.nombreSerieTrimeado,self.capitulo];
        direccion =[direccion stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        
        NSURL *url = [NSURL URLWithString:direccion];
        
        self.data=[ObjectiveGumbo parseNodeWithUrl:url encoding:NSUTF8StringEncoding];
        
        [self parsearPagina];
        
        return self;
    }
    return nil;
}

-(void)parsearPagina{
    NSMutableArray *torrents=[[NSMutableArray alloc]init];
    
    NSArray * resultados=[self.data elementsWithClass:@"tlistdownload"];
    for(OGElement *elementoTlistDownload in resultados){
        NSArray *nombres=[elementoTlistDownload.parent elementsWithClass:@"tlistname"];
        if(nombres.count<1){
            continue;
        }
        OGElement *tListName = [nombres objectAtIndex:0];
        NSArray *tListNameAs=[tListName elementsWithTag:GUMBO_TAG_A];
        if(tListNameAs.count<1){
            continue;
        }
        OGElement *tListNameA=[tListNameAs objectAtIndex:0];
        NSString *nombreDescarga=tListNameA.text;
        //Miramos el primer regEx
        DescargaTemp *descarga=[self comprobarPrimerRegExDe:nombreDescarga];
        if(descarga==nil){
            //Probamos con otra regEx
            descarga=[self comprobarSegundoRegExDe:nombreDescarga];
            if(descarga==nil){
                continue;
            }
        }
        
        //Aqui ya tenemos una descarga correcta
        //Direccion
        NSArray *elementosAenTListDownload =[elementoTlistDownload elementsWithTag:GUMBO_TAG_A];
        if(elementosAenTListDownload.count<1){
            continue;
        }
        OGElement *elementoA = [elementosAenTListDownload objectAtIndex:0];
        descarga.urlTorrent =[[elementoA attributes] valueForKey:@"href"];
        
        //Seeds
        NSArray *seeds=[elementoTlistDownload.parent elementsWithClass:@"tlistsn"];
        if(seeds.count<1){
            continue;
        }
        OGElement *tlistsn = [seeds objectAtIndex:0];
        //NSLog(@"ep %@ Seeds: %@",self.numEpisodio,tlistsn.text);
        
        //Leeches
        NSArray *leeches=[elementoTlistDownload.parent elementsWithClass:@"tlistln"];
        if(leeches.count<1){
            continue;
        }
        OGElement *tlistln = [leeches objectAtIndex:0];
        //NSLog(@"Leechers: %@",tlistln.text);
        descarga.seeds=tlistsn.text.intValue;
        descarga.peers=tlistln.text.intValue;
        descarga.esProper=NO;
        descarga.esMagnet=NO;
        descarga.episodio=self.episodio;
        [torrents addObject:descarga];
    }
    //Puede ser que no haya resultados o que solo hubiera 1 y nos llevara a el directamente
    if(resultados.count==0){
        NSArray * resultados=[self.data elementsWithClass:@"viewdownloadbutton"];
        if(resultados.count>0){
            NSArray *viewTorrentNames=[self.data elementsWithClass:@"viewtorrentname"];
            if(viewTorrentNames.count>0){
                OGElement *viewTorrentName = [viewTorrentNames objectAtIndex:0];
                NSString* nombreDescarga=viewTorrentName.text;
                DescargaTemp *descarga=[self comprobarPrimerRegExDe:nombreDescarga];
                if(descarga==nil){
                    //Otra regEx
                    descarga=[self comprobarSegundoRegExDe:nombreDescarga];
                }
                if(descarga!=nil){
                    //Aqui ya tenemos una descarga correcta
                    
                    //Direccion
                    OGElement *elemento=[resultados objectAtIndex:0];
                    NSArray *elementosA =[elemento elementsWithTag:GUMBO_TAG_A];
                    if(elementosA.count>0){
                        //Seeds & leeches
                        OGElement *elementoA = [elementosA objectAtIndex:0];
                        descarga.urlTorrent=[[elementoA attributes]valueForKey:@"href"];
                        NSArray *seeds=[self.data elementsWithClass:@"viewsn"];
                        NSArray *leeches=[self.data elementsWithClass:@"viewln"];
                        if(seeds.count>0&&leeches.count>0){
                            OGElement *tlistsn = [seeds objectAtIndex:0];
                            OGElement *tlistln = [leeches objectAtIndex:0];
                            descarga.seeds=tlistsn.text.intValue;
                            descarga.peers=tlistln.text.intValue;
                            descarga.esProper=NO;
                            descarga.esMagnet=NO;
                            descarga.episodio=self.episodio;
                            [torrents addObject:descarga];
                        }
                    }
                }
            }
        }
    }
    
    self.descargas=[[NSArray alloc]initWithArray:torrents];
}

-(DescargaTemp*)comprobarPrimerRegExDe:(NSString*)nombreDescarga{
    //Si no hay match devuelve nil, si hay match devuelve la descarga con el nombre de descarga, el fansub y la resolucion cubiertos
    NSRegularExpression *nameExpression = [NSRegularExpression regularExpressionWithPattern:@"^\\[(.+)] (.+) - (\\d+) \\[(\\d+)p].+$" options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *matches = [nameExpression matchesInString:nombreDescarga
                                               options:0
                                                 range:NSMakeRange(0, [nombreDescarga length])];
    if(matches.count<1){//No hubo match
        return nil;
    }
    //Hay match
    NSTextCheckingResult *match = [matches objectAtIndex:0];
    NSRange matchRange;
    
    //fansub
    matchRange = [match rangeAtIndex:1];
    NSString* fansub=[nombreDescarga substringWithRange:matchRange];
    
    //Nombre de serie coincide con el que buscamos
    matchRange = [match rangeAtIndex:2];
    //NSLog(@"%@.%@",nombreSerieTrimeado,[tListNameA.text substringWithRange:matchRange]);
    if([[nombreDescarga substringWithRange:matchRange] caseInsensitiveCompare:self.nombreSerieTrimeado]!=NSOrderedSame){
        //NSLog(@"No coincide el nombre");
        return nil;
    }
    
    //Num de capitulo igual
    matchRange = [match rangeAtIndex:3];
    if(self.capitulo!=[nombreDescarga substringWithRange:matchRange].intValue){
        return nil;
    }
    
    //Resolucion
    matchRange = [match rangeAtIndex:4];
    NSString *resolucion=[nombreDescarga substringWithRange:matchRange];
    
    
    
    DescargaTemp *descarga=[[DescargaTemp alloc]init];
    descarga.releaseGroup=fansub;
    descarga.nombre=nombreDescarga;
    if(resolucion.intValue==1080||resolucion.intValue==720){
        descarga.esHD=YES;
    }else{
        descarga.esHD=NO;
    }
    descarga.resolucion=resolucion.intValue;
    return descarga;
}

-(DescargaTemp*)comprobarSegundoRegExDe:(NSString*)nombreDescarga{
    //Si no hay match devuelve nil, si hay match devuelve la descarga con el nombre de descarga, el fansub y la resolucion cubiertos
    //[Commie] Yahari Ore no Seishun Love Comedy wa Machigatteiru. Zoku - 01 [E3B1108A].mkv
    NSRegularExpression *nameExpression = [NSRegularExpression regularExpressionWithPattern:@"^\\[(.+)] (.+) - (\\d+) \\[.+].+$" options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *matches = [nameExpression matchesInString:nombreDescarga
                                               options:0
                                                 range:NSMakeRange(0, [nombreDescarga length])];
    if(matches.count<1){//No hubo match
        return nil;
    }
    //Hay match
    NSTextCheckingResult *match = [matches objectAtIndex:0];
    NSRange matchRange;
    
    //fansub
    matchRange = [match rangeAtIndex:1];
    NSString* fansub=[nombreDescarga substringWithRange:matchRange];
    
    //Nombre de serie coincide con el que buscamos
    matchRange = [match rangeAtIndex:2];
    //NSLog(@"%@.%@",nombreSerieTrimeado,[tListNameA.text substringWithRange:matchRange]);
    if([[nombreDescarga substringWithRange:matchRange] caseInsensitiveCompare:self.nombreSerieTrimeado]!=NSOrderedSame){
        //NSLog(@"No coincide el nombre");
        return nil;
    }
    
    //Num de capitulo igual
    matchRange = [match rangeAtIndex:3];
    if(self.capitulo!=[nombreDescarga substringWithRange:matchRange].intValue){
        return nil;
    }
    
    
    DescargaTemp *descarga=[[DescargaTemp alloc]init];
    descarga.releaseGroup=fansub;
    descarga.nombre=nombreDescarga;
    descarga.esHD=YES;
    descarga.resolucion=720;
    return descarga;
}

@end
