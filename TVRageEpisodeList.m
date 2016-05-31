//
//  TVRageEpisodeList.m
//  TvTime
//
//  Created by Alexandre Blanco Gómez on 28/11/14.
//  Copyright (c) 2014 Horseware. All rights reserved.
//

#import "TVRageEpisodeList.h"

@implementation TVRageEpisodeList
-(instancetype)initWithSid:(int)sid{
    self=[super init];
    if(self){
        self.sid=sid;
        
    }
    return self;
}

-(BOOL)parsear{
    NSError *err=nil;
    NSString *path=[[NSString alloc] initWithFormat:@"/feeds/episode_list.php?sid=%d",self.sid];
    NSURL *furl = [[NSURL alloc]initWithScheme:@"http" host:@"services.tvrage.com" path:path];
    if (!furl) {
        NSLog(@"Can't create an URL from file");
        return NO;
    }
    self.xmlEpisodeList = [[NSXMLDocument alloc] initWithContentsOfURL:furl
                                                          options:(NSXMLNodePreserveWhitespace|NSXMLNodePreserveCDATA)
                                                            error:&err];
    if (self.xmlEpisodeList == nil) {
        self.xmlEpisodeList = [[NSXMLDocument alloc] initWithContentsOfURL:furl
                                                              options:NSXMLDocumentTidyXML
                                                                error:&err];
    }
    if (self.xmlEpisodeList == nil)  {
        if (err) {
            NSLog(@"Error actualizarSerie1 %@",err);
            return NO;
        }
        NSLog(@"Error actualizarSerie2");
        return NO;
    }
    if (err) {
        NSLog(@"Error actualizarSerie3 %@",err);
        return NO;
    }
    return YES;
}

-(void)rellenarEpNumDeEpisodio:(EpisodioTemp *)episodio{
    NSArray *items = [episodio.numEpisodio componentsSeparatedByString:@"x"];
    NSString *apoyo=[items objectAtIndex:0];
    int numTemporada=[apoyo intValue];
    apoyo=[items objectAtIndex:1];
    int numCapitulo = [apoyo intValue];
    
    if(numCapitulo!=0){
        NSString *expresion=[[NSString alloc]initWithFormat:@"//Show/Episodelist/Season[@no=\"%d\"]/episode",numTemporada];
        
        NSError *err;
        NSArray *nodes = [self.xmlEpisodeList nodesForXPath:expresion error:&err];
        for(NSXMLElement *elementEpisode in nodes){
            NSArray *listaSeasonNum = [elementEpisode elementsForName:@"seasonnum"];
            if([listaSeasonNum count]>=1){
                NSXMLElement *element=[listaSeasonNum objectAtIndex:0];
                NSString *seasonnumString=[[NSString alloc] initWithFormat:@"%@",[element.children objectAtIndex:0]];
                int seasonnumInt=[seasonnumString intValue];
                
                if(seasonnumInt==numCapitulo){//Cogemos el airdate para comparar
                    NSArray *listaEpNum = [elementEpisode elementsForName:@"epnum"];
                    element=[listaEpNum objectAtIndex:0];
                    NSString *epNumString=[[NSString alloc] initWithFormat:@"%@",[element.children objectAtIndex:0]];
                    episodio.numEpisodioTotal=[NSNumber numberWithInt:epNumString.intValue];
                    //NSLog(@"Rellenar %@ con %@",episodio.nombreEpisodio,episodio.numEpisodioTotal);
                    return;
                }
            }
        }
    }
    
    return;
}

-(NSDate *)getAirdateDeEpisodio:(EpisodioTemp *)episodio{
    NSArray *items = [episodio.numEpisodio componentsSeparatedByString:@"x"];
    NSString *apoyo=[items objectAtIndex:0];
    int numTemporada=[apoyo intValue];
    apoyo=[items objectAtIndex:1];
    int numCapitulo = [apoyo intValue];
    
    if(numCapitulo==0){//Si es un especial
        NSError *err;
        NSString *expresion=[[NSString alloc]initWithFormat:@"//Show/Episodelist/Special/episode"];
        NSArray *nodes = [self.xmlEpisodeList nodesForXPath:expresion error:&err];
        for(NSXMLElement *elementEpisode in nodes){
            NSArray *listaSeason = [elementEpisode elementsForName:@"season"];
            
            if(listaSeason.count>0){
                NSXMLElement *element=[listaSeason objectAtIndex:0];
                NSString* seasonString=[[NSString alloc] initWithFormat:@"%@",[element.children objectAtIndex:0]];
                
                if(numTemporada==seasonString.intValue){
                    //Cogemos el titulo
                    NSArray *listatitle = [elementEpisode elementsForName:@"title"];
                    element=[listatitle objectAtIndex:0];
                    NSString *title=[[NSString alloc] initWithFormat:@"%@",[element.children objectAtIndex:0]];
                    
                    if([episodio.nombreEpisodio isEqualToString:title]){
                        //Cogemos el airdate
                        NSArray *listaAirdate = [elementEpisode elementsForName:@"airdate"];
                        element=[listaAirdate objectAtIndex:0];
                        NSString* airdateString=[[NSString alloc] initWithFormat:@"%@",[element.children objectAtIndex:0]];
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                        dateFormatter.dateFormat = @"yyyy-MM-dd";
                        NSDate *airdate= [dateFormatter dateFromString:airdateString];
                        return airdate;
                    }
                }
            }
        }
    }else{//Si es un capitulo normal
        NSString *expresion=[[NSString alloc]initWithFormat:@"//Show/Episodelist/Season[@no=\"%d\"]/episode",numTemporada];
        
        NSError *err;
        NSArray *nodes = [self.xmlEpisodeList nodesForXPath:expresion error:&err];
        for(NSXMLElement *elementEpisode in nodes){
            NSArray *listaSeasonNum = [elementEpisode elementsForName:@"seasonnum"];
            if([listaSeasonNum count]>=1){
                NSXMLElement *element=[listaSeasonNum objectAtIndex:0];
                NSString *seasonnumString=[[NSString alloc] initWithFormat:@"%@",[element.children objectAtIndex:0]];
                int seasonnumInt=[seasonnumString intValue];
                
                if(seasonnumInt==numCapitulo){//Cogemos el airdate para comparar
                    NSArray *listaAirdate = [elementEpisode elementsForName:@"airdate"];
                    element=[listaAirdate objectAtIndex:0];
                    NSString *airdateString=[[NSString alloc] initWithFormat:@"%@",[element.children objectAtIndex:0]];
                    
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    dateFormatter.dateFormat = @"yyyy-MM-dd";
                    NSDate *airdate= [dateFormatter dateFromString:airdateString];
                    return airdate;
                    
                }
            }
        }

    }
    return nil;
}

-(int)getNumeroDeTemporadas{
    NSString *expresion=[[NSString alloc]initWithFormat:@"//Show/totalseasons"];
    NSError *err;
    NSArray *nodes = [self.xmlEpisodeList nodesForXPath:expresion error:&err];
    NSXMLElement *totalSeasons=[nodes objectAtIndex:0];
    
    NSString * string=[[NSString alloc]initWithFormat:@"%@",[totalSeasons.children objectAtIndex:0]];
    return string.intValue;
}

-(NSMutableArray *)listaDeEpisodiosEmitidosConLatestEpisode:(EpisodioTemp*)latestEpisode{
    NSMutableArray *devolver =[[NSMutableArray alloc]init];
    
    //Consultamos los episodios normales
    int numeroDeTemporadas = [self getNumeroDeTemporadas];
    //NSLog(@"Numero de temporadas %d",numeroDeTemporadas);
    
    NSMutableArray *temporadas=[[NSMutableArray alloc]init];
    int i=1;
    while (i<=latestEpisode.getTemporada) {//Anadimos las temporadas a buscar
        [temporadas addObject:[[NSNumber alloc]initWithInt:i]];
        i++;
    }
    NSError *err;
    for(NSNumber* temporada in temporadas){
        //NSLog(@"Temporada %@",temporada);
        NSString *expresion=[[NSString alloc]initWithFormat:@"//Show/Episodelist/Season[@no=\"%@\"]/episode",temporada];
        NSArray *nodes = [self.xmlEpisodeList nodesForXPath:expresion error:&err];
        for(NSXMLElement *elementEpisode in nodes){
            NSArray *listaSeasonNum = [elementEpisode elementsForName:@"seasonnum"];
            if(listaSeasonNum.count>0){
                //Cogemos el numero de episodio
                NSXMLElement *element=[listaSeasonNum objectAtIndex:0];
                NSString *seasonnum=[[NSString alloc] initWithFormat:@"%@",[element.children objectAtIndex:0]];
                int seasonnumInt=[seasonnum intValue];
                //Ahora ya tenemos el numero de ese episodio
                //NSLog(@"Temporada %@ y capitulo %d",temporada,seasonnumInt);
                if(!(temporada.intValue==latestEpisode.getTemporada&&seasonnumInt>latestEpisode.getEpisodio)){//Aqui cogemos el episodio
                    //NSLog(@"Cogemos %@x%d",temporada,seasonnumInt);
                    
                    //Cogemos la fecha
                    NSArray *listaAirdate = [elementEpisode elementsForName:@"airdate"];
                    element=[listaAirdate objectAtIndex:0];
                    NSString* airdateSigString=[[NSString alloc] initWithFormat:@"%@",[element.children objectAtIndex:0]];
                    //NSLog(@"Fecha es %@",airdateSigString);
                    NSDate* airdateSig=[self calcularAirdateConTimeInterval:0 valido:NO pais:nil yString:airdateSigString];
                    
                    //Cogemos el titulo
                    NSArray *listatitle = [elementEpisode elementsForName:@"title"];
                    element=[listatitle objectAtIndex:0];
                    NSString *title=[[NSString alloc] initWithFormat:@"%@",[element.children objectAtIndex:0]];
                    
                    //Cogemos el numero episodio total
                    NSArray *listaepnum = [elementEpisode elementsForName:@"epnum"];
                    element=[listaepnum objectAtIndex:0];
                    NSString *epnum=[[NSString alloc] initWithFormat:@"%@",[element.children objectAtIndex:0]];
                    
                    //Creamos el episodio
                    EpisodioTemp* episodio=[[EpisodioTemp alloc]init];
                    episodio.sid=[NSNumber numberWithInt:self.sid];
                    episodio.hora=airdateSig;
                    episodio.numEpisodio=[[NSString alloc]initWithFormat:@"%02ldx%02d",temporada.integerValue,seasonnumInt];
                    episodio.nombreEpisodio=title;
                    episodio.numEpisodioTotal=[NSNumber numberWithInt:epnum.intValue];
                    if(episodio.hora!=nil){//Si es nil es que ponia que la fecha es 00-00-0000
                        //NSLog(@"Anadimos el episodio: %@ %@,%@",episodio.numEpisodio,episodio.nombreEpisodio,episodio.hora);
                        [devolver addObject:episodio];
                    }
                }
            }
        }
    }
    return devolver;
}

-(NSMutableArray *)getEpisodiosDesdeTemporada:(int)temporadaReferencia Episodio:(int)episodioReferencia yFecha:(NSDate *)fechaReferencia conIntervalo:(NSTimeInterval)intervalo valido:(Boolean)esValidoElIntervalo dePais:(NSString *)pais{
    
    NSMutableArray *devolver =[[NSMutableArray alloc]init];
    
    //Consultamos los episodios normales
    int numeroDeTemporadas = [self getNumeroDeTemporadas];
    //NSLog(@"Numero de temporadas %d",numeroDeTemporadas);

    NSMutableArray *temporadas=[[NSMutableArray alloc]init];
    int i=temporadaReferencia;
    while (i<=numeroDeTemporadas) {//Anadimos las temporadas a buscar
        [temporadas addObject:[[NSNumber alloc]initWithInt:i]];
        i++;
    }
    NSError *err;
    for(NSNumber* temporada in temporadas){
        //NSLog(@"Temporada %@",temporada);
        NSString *expresion=[[NSString alloc]initWithFormat:@"//Show/Episodelist/Season[@no=\"%@\"]/episode",temporada];
        NSArray *nodes = [self.xmlEpisodeList nodesForXPath:expresion error:&err];
        for(NSXMLElement *elementEpisode in nodes){
            NSArray *listaSeasonNum = [elementEpisode elementsForName:@"seasonnum"];
            if(listaSeasonNum.count>0){
                //Cogemos el numero de episodio
                NSXMLElement *element=[listaSeasonNum objectAtIndex:0];
                NSString *seasonnum=[[NSString alloc] initWithFormat:@"%@",[element.children objectAtIndex:0]];
                int seasonnumInt=[seasonnum intValue];
                //Ahora ya tenemos el numero de ese episodio
                //NSLog(@"Temporada %@ y capitulo %d",temporada,seasonnumInt);
                if(temporada.intValue>temporadaReferencia||(temporada.intValue==temporadaReferencia&&seasonnumInt>episodioReferencia)){//Aqui cogemos el episodio
                    //NSLog(@"Cogemos %@x%d",temporada,seasonnumInt);
                    
                    //Cogemos la fecha
                    NSArray *listaAirdate = [elementEpisode elementsForName:@"airdate"];
                    element=[listaAirdate objectAtIndex:0];
                    NSString* airdateSigString=[[NSString alloc] initWithFormat:@"%@",[element.children objectAtIndex:0]];
                    //NSLog(@"Fecha es %@",airdateSigString);
                    NSDate* airdateSig=[self calcularAirdateConTimeInterval:intervalo valido:esValidoElIntervalo pais:pais yString:airdateSigString];
                    
                    //Cogemos el titulo
                    NSArray *listatitle = [elementEpisode elementsForName:@"title"];
                    element=[listatitle objectAtIndex:0];
                    NSString *title=[[NSString alloc] initWithFormat:@"%@",[element.children objectAtIndex:0]];
                    CFStringRef cfTitle = (CFStringRef)CFBridgingRetain(title);
                    title =CFBridgingRelease(CFXMLCreateStringByUnescapingEntities(kCFAllocatorDefault, cfTitle, NULL));
                    
                    //Cogemos el numero episodio total
                    NSArray *listaepnum = [elementEpisode elementsForName:@"epnum"];
                    element=[listaepnum objectAtIndex:0];
                    NSString *epnum=[[NSString alloc] initWithFormat:@"%@",[element.children objectAtIndex:0]];
                    
                    //Creamos el episodio
                    EpisodioTemp* episodio=[[EpisodioTemp alloc]init];
                    episodio.sid=[NSNumber numberWithInt:self.sid];
                    episodio.hora=airdateSig;
                    episodio.numEpisodio=[[NSString alloc]initWithFormat:@"%02ldx%02d",temporada.integerValue,seasonnumInt];
                    episodio.nombreEpisodio=title;
                    episodio.numEpisodioTotal=[NSNumber numberWithInt:epnum.intValue];
                    if(episodio.hora!=nil){//Si es nil es que ponia que la fecha es 00-00-0000
                        //NSLog(@"Anadimos el episodio: %@ %@,%@",episodio.numEpisodio,episodio.nombreEpisodio,episodio.hora);
                        [devolver addObject:episodio];
                    }
                }
            }
        }
    }
    
    //Consultamos los especiales
    NSString *expresion=[[NSString alloc]initWithFormat:@"//Show/Episodelist/Special/episode"];
    NSArray *nodes = [self.xmlEpisodeList nodesForXPath:expresion error:&err];
    for(NSXMLElement *elementEpisode in nodes){
        NSArray *listaAirdate = [elementEpisode elementsForName:@"airdate"];
        if(listaAirdate.count>0){
            
            //Cogemos la fecha
            NSXMLElement *element=[listaAirdate objectAtIndex:0];
            NSString* airdateSigString=[[NSString alloc] initWithFormat:@"%@",[element.children objectAtIndex:0]];
            NSDate* airdateSig=[self calcularAirdateConTimeInterval:intervalo valido:esValidoElIntervalo pais:pais yString:airdateSigString];
            
            if(airdateSig!=nil){
                if(airdateSig.timeIntervalSince1970>fechaReferencia.timeIntervalSince1970){//Solo lo cogemos si es mas reciente que la fecha del ultimo episodio que tenemos
                    
                    //Cogemos el titulo
                    NSArray *listatitle = [elementEpisode elementsForName:@"title"];
                    element=[listatitle objectAtIndex:0];
                    NSString *title=[[NSString alloc] initWithFormat:@"%@",[element.children objectAtIndex:0]];
                    
                    //Cogemos el numero temporada
                    NSArray *listaseason = [elementEpisode elementsForName:@"season"];
                    element=[listaseason objectAtIndex:0];
                    NSString *season=[[NSString alloc] initWithFormat:@"%@",[element.children objectAtIndex:0]];
                    
                    //Creamos el episodio
                    EpisodioTemp* episodio=[[EpisodioTemp alloc]init];
                    episodio.sid=[NSNumber numberWithInt:self.sid];
                    episodio.hora=airdateSig;
                    episodio.numEpisodio=[[NSString alloc]initWithFormat:@"%02ldx00",season.integerValue];
                    episodio.nombreEpisodio=title;
                    if(episodio.hora!=nil){//Si es nil es que ponia que la fecha es 00-00-0000
                        //NSLog(@"Anadimos el especial: %@ %@,%@ hora string: %@",episodio.numEpisodio,episodio.nombreEpisodio,episodio.hora,airdateSigString);
                        [devolver addObject:episodio];
                    }
                }
            }
        }
    }
    
    return devolver;
}
-(NSDate *)calcularAirdateConTimeInterval:(NSTimeInterval )intervalo valido:(Boolean)esValido pais:(NSString *)pais yString:(NSString *)airdateString{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    
    if(esValido){
        //NSLog(@"Es valido el intervalo, hora string: %@",airdateString);
        NSDate *airdateSinCorregir= [dateFormatter dateFromString:airdateString];
        if(airdateSinCorregir==nil){
            return nil;
        }
        return [NSDate dateWithTimeInterval:intervalo sinceDate:airdateSinCorregir];
    }else{
        //NSLog(@"No es valido el intervalo, hora string: %@",airdateString);
        if(pais!=nil){
            if([pais isEqualToString:@"Japan"]){
                dateFormatter.timeZone=[NSTimeZone timeZoneWithName:@"Asia/Tokyo"];
                return [dateFormatter dateFromString:airdateString];
            }
        }
        return [dateFormatter dateFromString:airdateString];
    }
    return nil;
}
@end
