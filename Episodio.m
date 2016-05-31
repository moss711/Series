//
//  Episodio.m
//  TvTime
//
//  Created by Alexandre Blanco Gómez on 30/10/14.
//  Copyright (c) 2014 Horseware. All rights reserved.
//

#import "Episodio.h"
#import "Serie.h"
#import "ObjectiveGumbo.h"
#import "DescargaTemp.h"
#import "AppDelegate.h"
#import "NyaaSeBusquedaCapitulos.h"


@implementation Episodio

@dynamic avisado;
@dynamic avisadoSub;
@dynamic hora;
@dynamic fechaInclusionEnAnteriores;
@dynamic nombreEpisodio;
@dynamic numEpisodio;
@dynamic numEpisodioTotal;
@dynamic tipo;
@dynamic urlSub;
@dynamic urlSubSupuesto;
@dynamic urlSubSupuestoEpDescargado;
@dynamic releaseGroup;
@dynamic releaseGroupEpDescargado;
@dynamic usarNumEpisodioTotal;
@dynamic hayProper;
@dynamic seguirBuscando;
@dynamic magnetLink;
@dynamic serie;
@dynamic esMagnet;
@dynamic excluirBusquedaEp;
@dynamic excluirBusquedaSub;
@dynamic nombreDescarga;


- (NSComparisonResult)compareProximos:(Episodio *)otherObject {
    if((self.hora==nil)&&(otherObject.hora==nil)){
        return NSOrderedSame;
    }else if((self.hora!=nil)&&(otherObject.hora==nil)){
        return NSOrderedAscending;
    }else if((self.hora==nil)&&otherObject.hora!=nil){
        return NSOrderedDescending;
    }else{
        NSComparisonResult result= [self.hora compare:otherObject.hora];
        if(result==NSOrderedSame){
            return [self.numEpisodio compare:otherObject.numEpisodio];
        }
        return result;
    }
}

- (NSComparisonResult)compareAnteriores:(Episodio *)otherObject {
    return [self compareProximos:otherObject]*(-1);
//    if((self.hora==nil)&&(otherObject.hora==nil)){
//        return NSOrderedSame;
//    }else if((self.hora!=nil)&&(otherObject.hora==nil)){
//        return NSOrderedDescending;
//    }else if((self.hora==nil)&&otherObject.hora!=nil){
//        return NSOrderedAscending;
//    }else{
//        NSComparisonResult result= [self.hora compare:otherObject.hora];
//        if(result==NSOrderedSame){
//            return [self.numEpisodio compare:otherObject.numEpisodio]*(-1);
//        }
//        return result*(-1);
//    }
}

-(void)mostrarBusquedaEpisodio{
    NSString *temporada = [self.numEpisodio componentsSeparatedByString:@"x"][0];
    NSString *capitulo = [self.numEpisodio componentsSeparatedByString:@"x"][1];
    int temporadaint = [temporada intValue];
    int capituloint = [capitulo intValue];
    
    //Elimino ciertos caracteres del titulo para hacer la busqueda
    NSCharacterSet *trim = [NSCharacterSet characterSetWithCharactersInString:@"(;);'"];
    NSString *nombreSerieTrimeado = [[self.serie.serie componentsSeparatedByCharactersInSet: trim] componentsJoinedByString: @""];
    
    
    NSString *direccion= [[NSString alloc]initWithFormat:@"https://kickass.to/usearch/%@%%20s%02de%02d/?field=seeders&sorder=desc",nombreSerieTrimeado,temporadaint,capituloint];
    direccion =[direccion stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    NSURL *url = [NSURL URLWithString:direccion];
    if( ![[NSWorkspace sharedWorkspace] openURL:url] )
        NSLog(@"Failed to open url: %@",[url description]);
    
    //Piratebay
//    NSString *temporada = [self.numEpisodio componentsSeparatedByString:@"x"][0];
//    NSString *capitulo = [self.numEpisodio componentsSeparatedByString:@"x"][1];
//    int temporadaint = [temporada intValue];
//    int capituloint = [capitulo intValue];
//    
//    //Elimino ciertos caracteres del titulo para hacer la busqueda
//    NSCharacterSet *trim = [NSCharacterSet characterSetWithCharactersInString:@"(;);'"];
//    NSString *nombreSerieTrimeado = [[self.serie.serie componentsSeparatedByCharactersInSet: trim] componentsJoinedByString: @""];
//    
//    
//    NSString *direccion= [[NSString alloc]initWithFormat:@"http://thepiratebay.se/search/%@%%20s%02de%02d/0/7/0",nombreSerieTrimeado,temporadaint,capituloint];
//    direccion =[direccion stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
//    NSURL *url = [NSURL URLWithString:direccion];
//    if( ![[NSWorkspace sharedWorkspace] openURL:url] )
//        NSLog(@"Failed to open url: %@",[url description]);
}

-(Boolean)descargarSub{
    if(self.releaseGroupEpDescargado!=nil){//Si hay una version guardada como ultima version descargada solo nos interesa esa
        if(self.urlSubSupuestoEpDescargado!=nil){
            GestorDeFicheros *gestorFich=[(AppDelegate*)[NSApplication sharedApplication].delegate instanciaGestorFicheros];
            if(gestorFich==nil){
                NSLog(@"Gestor de ficheros es nil");
            }
            return [gestorFich guardarSubDeEpisodio:self ConURL:self.urlSubSupuestoEpDescargado];
        }
    }else if(self.releaseGroup!=nil){//Si no hubo version guardada como ultima descargada pero hay una version candidata a ser bajada
        if(self.urlSubSupuesto!=nil){
            GestorDeFicheros *gestorFich=[(AppDelegate*)[NSApplication sharedApplication].delegate instanciaGestorFicheros];
            if(gestorFich==nil){
                NSLog(@"Gestor de ficheros es nil");
            }
            return [gestorFich guardarSubDeEpisodio:self ConURL:self.urlSubSupuesto];
        }
    }
    //Si no hay ninguna version registrada o si no se encontraron los subs para la version correcta(pero si se encontro la pagina con los subtitulos)
    if(self.urlSub!=nil){
        NSURL *url = [NSURL URLWithString:self.urlSub];
        if( ![[NSWorkspace sharedWorkspace] openURL:url] ){
            NSLog(@"Failed to open url: %@",[url description]);
            return NO;
        }
        return YES;
    }
    return NO;
}

-(NSString*)horaString{
    return[NSDateFormatter localizedStringFromDate:self.hora
                                         dateStyle:NSDateFormatterShortStyle
                                         timeStyle:NSDateFormatterShortStyle];
}

-(long)diasRestantes{
    NSTimeInterval queda =[self.hora timeIntervalSinceDate:[NSDate date]];//son segundos
    
    return queda/60/60/24;
}

-(long)horasRestantes{
    NSTimeInterval queda =[self.hora timeIntervalSinceDate:[NSDate date]];//son segundos
    
    long dias = queda/60/60/24;
    queda= queda - dias * 60 * 60 *24;
    long horas = queda / 60 / 60;
    queda= queda - horas *60 * 60;
    long min = queda /60;
    
    if(min>=30){
        horas++;
    }
    return horas;
}

-(NSString*)buscarSub{
    if(self.serie.buscadorSubtitulos==nil||self.serie.buscadorSubtitulos.intValue==Addic7ed){
        return [self buscarSubAddic7ed];
    }else if(self.serie.buscadorSubtitulos.intValue==SubtitulosES){
        if(self.serie.idSubtitulosEs!=nil){
            return [self buscarSubSubtitulosEs];
        }
    }
    return nil;
}
-(NSString*)buscarSubConDireccion:(NSString *)direccion yVersion:(NSString*)versionSolicitada{
    if(self.serie.buscadorSubtitulos==nil||self.serie.buscadorSubtitulos.intValue==Addic7ed){
        return [self buscarSubAddic7edConDireccion:direccion yVersion:versionSolicitada];
    }else if(self.serie.buscadorSubtitulos.intValue==SubtitulosES){
        if(self.serie.idSubtitulosEs!=nil){
            return [self buscarSubSubtitulosEsConDireccion:direccion yVersion:versionSolicitada];
        }
    }
    return nil;
}


-(NSString *)buscarSubAddic7ed{
        NSString *nombreSerie;
        if(self.serie.nombreParaBusquedaSubs==nil){
            nombreSerie=self.serie.serie;
        }else{
            nombreSerie=self.serie.nombreParaBusquedaSubs;
        }
        NSString *path=[[NSString alloc] initWithFormat:@"/search.php?search=%@&Submit=Search",nombreSerie];
        NSURL *furl = [[NSURL alloc]initWithScheme:@"http" host:@"www.addic7ed.com" path:path];
        
        //NSLog(@"%@",furl);
        
        
        OGNode * data = [ObjectiveGumbo parseNodeWithUrl:furl encoding:NSUTF8StringEncoding];
        NSArray * tabla = [data elementsWithClass:@"tabel"];
        if([tabla count]>0){
            OGElement *tabel=[tabla objectAtIndex:0];
            NSArray *elementosA=[tabel elementsWithTag:GUMBO_TAG_A];
            for (OGElement *elementoA in elementosA){
                NSString *url=[[NSString alloc]initWithFormat:@"%@%@",@"http://www.addic7ed.com/",elementoA.attributes[@"href"] ];
                
                NSRegularExpression *nameExpression = [NSRegularExpression regularExpressionWithPattern:@"^(.+) - (\\d{2}x\\d{2}) - .+$" options:NSRegularExpressionCaseInsensitive error:nil];
                NSArray *matches = [nameExpression matchesInString:[elementoA text]
                                                           options:0
                                                             range:NSMakeRange(0, [[elementoA text] length])];
                
                if ([matches count]>0){
                    NSTextCheckingResult *match = [matches objectAtIndex:0];
                    NSRange matchRange = [match rangeAtIndex:1];
                    NSString *serie = [[elementoA text] substringWithRange:matchRange];
                    matchRange = [match rangeAtIndex:2];
                    NSString *ep = [[elementoA text] substringWithRange:matchRange];
                    
                    //NSLog(@"%@ vs %@",serie,self.serie.serie);
                    //NSLog(@"%@ vs %@",ep,self.numEpisodio);
                    if([serie isEqualToString:nombreSerie]&&[ep isEqualToString:self.numEpisodio]){
                        //self.urlSub=url;
                        //NSLog(@"encontrado sub");
                        return url;
                    }
                }
                //NSLog(@"Serie: %@ url: %@",[elementoA text],url);
            }
        }
    return nil;
}

-(NSString*)buscarSubAddic7edConDireccion:(NSString *)direccion yVersion:(NSString*)versionSolicitada{
    NSURL *url=[NSURL URLWithString:direccion];
    
    //Buscamos tambien versiones equivalentes(ej: dimension funciona con lol,asap con immerse)
    NSMutableArray *versionesValidas=[[NSMutableArray alloc]init];
    
    if([versionSolicitada rangeOfString:@"DIMENSION" options:NSCaseInsensitiveSearch].location!=NSNotFound ||
       [versionSolicitada rangeOfString:@"LOL" options:NSCaseInsensitiveSearch].location!=NSNotFound ||
       [versionSolicitada rangeOfString:@"SYS" options:NSCaseInsensitiveSearch].location!=NSNotFound){
        
        [versionesValidas addObject:@"LOL"];
        [versionesValidas addObject:@"SYS"];
        [versionesValidas addObject:@"DIMENSION"];
    }else if([versionSolicitada rangeOfString:@"IMMERSE" options:NSCaseInsensitiveSearch].location!=NSNotFound ||
             [versionSolicitada rangeOfString:@"XII" options:NSCaseInsensitiveSearch].location!=NSNotFound ||
             [versionSolicitada rangeOfString:@"ASAP" options:NSCaseInsensitiveSearch].location!=NSNotFound){
        
        [versionesValidas addObject:@"XII"];
        [versionesValidas addObject:@"ASAP"];
        [versionesValidas addObject:@"IMMERSE"];
    }else if([versionSolicitada rangeOfString:@"ORENJI" options:NSCaseInsensitiveSearch].location!=NSNotFound ||
             [versionSolicitada rangeOfString:@"FQM" options:NSCaseInsensitiveSearch].location!=NSNotFound){
        
        [versionesValidas addObject:@"FQM"];
        [versionesValidas addObject:@"ORENJI"];
    }else{
        [versionesValidas addObject:versionSolicitada];
    }
    
    
    OGNode * data = [ObjectiveGumbo parseNodeWithUrl:url encoding:NSUTF8StringEncoding];
    //NSLog(@"%@",data.html);
    NSArray * newsTitles=[data elementsWithClass:@"NewsTitle"];
    NSString *urlHI=nil;
    for(OGElement *newsTitle in newsTitles){
        if(![newsTitle.text hasPrefix:@"Version "]){
            continue;
        }
        OGNode *tBody = newsTitle.parent.parent;
        NSArray *trs =[tBody elementsWithTag:GUMBO_TAG_TR];
        if(trs.count<2){
            NSLog(@"Error!,menos de 2 elementos tr");
            continue;
        }
        OGElement *tr=[trs objectAtIndex:1];
        NSArray *newsDates =[tr elementsWithClass:@"newsDate"];
        if(newsDates.count<1){
            continue;
        }
        OGElement *newsDate=[newsDates objectAtIndex:0];
        //NSLog(@"%@",newsTitle.text);
        //NSLog(@"->%@",newsDate.text);
        
        NSString *version=[newsTitle.text substringFromIndex:8];
        NSRange rango=[version rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
        version=[version substringToIndex:rango.location];
        
        Boolean versionEncontrada=NO;
        for(NSString *releaseGroup in versionesValidas){
            if([version rangeOfString:releaseGroup options:NSCaseInsensitiveSearch].location!=NSNotFound||[newsDate.text rangeOfString:releaseGroup options:NSCaseInsensitiveSearch].location!=NSNotFound){//Si encuentra el substring en alguno de los dos
                versionEncontrada=YES;
                break;
            }
        }
        if(!versionEncontrada){
            continue;
        }
        //En este punto sabemos que la version es la correcta, miramos si es HI y buscamos idioma
        NSArray * images=[tBody elementsWithTag:GUMBO_TAG_IMG];
        Boolean hearingImpaired=NO;
        for(OGElement *img in images){
            NSString *valor=[[img attributes] valueForKey:@"title"];
            if(valor!=nil){
                if([valor rangeOfString:@"Hearing Impaired" options:NSCaseInsensitiveSearch].location!=NSNotFound){
                    hearingImpaired=YES;
                    break;
                }
            }
        }
        
        NSArray *languages = [tBody elementsWithClass:@"language"];
        for(OGElement *language in languages){
            NSArray *buttonDownloads=[language.parent elementsWithClass:@"buttonDownload"];
            if(buttonDownloads.count<1){
                continue;
            }
            OGElement *buttonDownload = [buttonDownloads objectAtIndex:buttonDownloads.count-1];
            NSString* urlSub=[buttonDownload.attributes valueForKey:@"href"];
            urlSub=[@"http://www.addic7ed.com" stringByAppendingString:urlSub];
            //NSLog(@"--->%@ %@",language.text,urlSub);
            if([language.text rangeOfString:@"English" options:NSCaseInsensitiveSearch].location!=NSNotFound){
                if(hearingImpaired){
                    urlHI=urlSub;
                    //NSLog(@"-->Buena! HI");
                }else{
                    return urlSub;
                    //NSLog(@"-->Buena! No HI");
                }
            }
            
            
            
        }
    }
    return urlHI;
}


-(NSString*)buscarSubSubtitulosEs{
    int temporadaint = [self getNumeroTemporada];
    int capituloint = [self getNumeroEpisodio];
    if(self.serie.idSubtitulosEs==nil){
        return nil;
    }
    int idSubEs=self.serie.idSubtitulosEs.intValue;
    
    NSString *direccion=[[NSString alloc]initWithFormat:@"http://www.subtitulos.es/ajax_loadShow.php?show=%d&season=%d",idSubEs,temporadaint];
    NSURL *url=[NSURL URLWithString:direccion];
    
    OGNode * data = [ObjectiveGumbo parseNodeWithUrl:url encoding:NSUTF8StringEncoding];
    NSArray *aes = [data elementsWithTag:GUMBO_TAG_A];
    for(OGElement* a in aes){
        NSRegularExpression *nameExpression = [NSRegularExpression regularExpressionWithPattern:@"^.+ \\d+x(\\d+) - .+$"
                                                                                        options:NSRegularExpressionCaseInsensitive
                                                                                          error:nil];
        NSArray *matches = [nameExpression matchesInString:[a text]
                                                   options:0
                                                     range:NSMakeRange(0, [[a text] length])];
        
        if (matches.count<1){
            continue;
        }
        NSTextCheckingResult *match = [matches objectAtIndex:0];
        NSRange matchRange = [match rangeAtIndex:1];
        if([a.text substringWithRange:matchRange].intValue!=capituloint){
            continue;
        }
        
        NSDictionary* atributos=a.attributes;
        NSString* urlSub=nil;
        
        urlSub=[atributos objectForKey:@"href"];
        
        //Comprobar si esta terminada la traducción
        OGNode* tBody=a.parent.parent.parent;
        NSArray* trs=[tBody elementsWithTag:GUMBO_TAG_TR];
        for(OGElement *tr in trs){
            //Buscamos si hay la linea de Español (España)
            Boolean encontradoEspanol=NO;
            NSArray* tds=[tr elementsWithTag:GUMBO_TAG_TD];
            for(OGElement *td in tds){
                if(!encontradoEspanol){
                    if([td.text rangeOfString:@"Español (España)" options:NSCaseInsensitiveSearch].location!=NSNotFound){
                        encontradoEspanol=YES;
                        //NSLog(@"%@",td.text);
                    }
                }else{//Aqui ya vimos que hay sub en español, ahora comprobamos que este completo
                    NSString* textoTrim=[td.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    //NSLog(@"->%@<-",textoTrim);
                    //NSLog(@"Completado");
                    if([textoTrim isEqualToString:@"Completado"]){
                        return urlSub;
                    }
                }
            }
        }
    }
    return nil;
}

-(NSString*)buscarSubSubtitulosEsConDireccion:(NSString *)direccion yVersion:(NSString*)versionSolicitada{
    NSURL *url=[NSURL URLWithString:direccion];
    
    //Buscamos tambien versiones equivalentes(ej: dimension funciona con lol,asap con immerse
    NSMutableArray *versionesValidas=[[NSMutableArray alloc]init];
    //
    
    //EL chorrazo de codigo es simplemente un containsString pero case insensitive
    if([versionSolicitada rangeOfString:@"DIMENSION" options:NSCaseInsensitiveSearch].location!=NSNotFound ||
       [versionSolicitada rangeOfString:@"LOL" options:NSCaseInsensitiveSearch].location!=NSNotFound ||
       [versionSolicitada rangeOfString:@"SYS" options:NSCaseInsensitiveSearch].location!=NSNotFound){
        
        [versionesValidas addObject:@"LOL"];
        [versionesValidas addObject:@"SYS"];
        [versionesValidas addObject:@"DIMENSION"];
    }else if([versionSolicitada rangeOfString:@"IMMERSE" options:NSCaseInsensitiveSearch].location!=NSNotFound ||
             [versionSolicitada rangeOfString:@"XII" options:NSCaseInsensitiveSearch].location!=NSNotFound ||
             [versionSolicitada rangeOfString:@"ASAP" options:NSCaseInsensitiveSearch].location!=NSNotFound){
        
        [versionesValidas addObject:@"XII"];
        [versionesValidas addObject:@"ASAP"];
        [versionesValidas addObject:@"IMMERSE"];
    }else if([versionSolicitada rangeOfString:@"ORENJI" options:NSCaseInsensitiveSearch].location!=NSNotFound ||
             [versionSolicitada rangeOfString:@"FQM" options:NSCaseInsensitiveSearch].location!=NSNotFound){
        
        [versionesValidas addObject:@"FQM"];
        [versionesValidas addObject:@"ORENJI"];
    }else{
        [versionesValidas addObject:versionSolicitada];
    }
    
    OGNode * data = [ObjectiveGumbo parseNodeWithUrl:url encoding:NSUTF8StringEncoding];
    //NSLog(@"%@",data.html);
    NSArray* elementosVersion=[data elementsWithID:@"version"];
    
    for(OGElement *elementoVersion in elementosVersion){//Cada version
        NSArray* elementosBubble=[elementoVersion elementsWithClass:@"bubble"];
        if(elementosBubble.count<1){
            continue;
        }
        OGElement *elementoBubble=[elementosBubble objectAtIndex:0];
        
        NSArray* elementosTitleSub=[elementoBubble elementsWithClass:@"title-sub"];
        if(elementosTitleSub.count<1){
            continue;
        }
        OGElement *elementoTitleSub=[elementosTitleSub objectAtIndex:0];
        //Matching para quedarnos con la parte que queremos!
        NSString* textoElementoTitleSubTrimeado=[elementoTitleSub.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        //NSLog(@"->%@<-",textoElementoTitleSubTrimeado);
        NSRegularExpression *nameExpression = [NSRegularExpression regularExpressionWithPattern:@"^Versión (.+) \\d+\\.\\d+ megabytes.+$"
                                                                                        options:NSRegularExpressionCaseInsensitive
                                                                                          error:nil];
        NSArray *matches = [nameExpression matchesInString:textoElementoTitleSubTrimeado
                                                   options:0
                                                     range:NSMakeRange(0, [textoElementoTitleSubTrimeado length])];
        
        if (matches.count<1){
            continue;
        }
        NSTextCheckingResult *match = [matches objectAtIndex:0];
        NSRange matchRange = [match rangeAtIndex:1];
        NSString* textoVersion=[textoElementoTitleSubTrimeado substringWithRange:matchRange];
        //NSLog(@"->%@<-",textoVersion);
        
        //Ahora cogemos el comentario para ver mas versiones
        NSArray* comentarios=[elementoBubble elementsWithClass:@"comentario"];
        NSArray* comentariosTokenizados=[[NSArray alloc]init];
        if(comentarios.count>0){
            OGElement* comentario=[comentarios objectAtIndex:0];
            //NSLog(@"%@",comentario.text);
            //Estoes para eliminar los caracteres blancos al principio y al final del string
            NSString* comentarioTrimeado=[comentario.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            //Esto es para eliminar los caracteres de newline que pueda haber por el medio  
            comentarioTrimeado = [[comentarioTrimeado componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]] componentsJoinedByString: @" "];
            
            //NSLog(@"%@",comentarioTrimeado);
            
            
            
            nameExpression = [NSRegularExpression regularExpressionWithPattern:@"Comentario:(.+)"
                                                                       options:NSRegularExpressionCaseInsensitive
                                                                         error:nil];
            matches = [nameExpression matchesInString:comentarioTrimeado
                                              options:0
                                                range:NSMakeRange(0, [comentarioTrimeado length])];
            
            if (matches.count>0){
                match = [matches objectAtIndex:0];
                matchRange = [match rangeAtIndex:1];
                comentarioTrimeado=[comentarioTrimeado substringWithRange:matchRange];
                
                //separamos todas las palabras con espacios
                NSCharacterSet *trim = [NSCharacterSet characterSetWithCharactersInString:@"(;);';,;.;-;/"];
                comentarioTrimeado = [[comentarioTrimeado componentsSeparatedByCharactersInSet: trim] componentsJoinedByString: @" "];
                comentariosTokenizados=[comentarioTrimeado componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//                                for(NSString *token in comentariosTokenizados){
//                                    NSLog(@"->%@<-",token);
//                                }
            }
        }
        
        //Comprobamos si la version es la que estamos buscando
        BOOL esValidaLaVersion=NO;
        //Primero con texto version, aqui comprobamos si contiene la version que buscamos
        for(NSString* versionValida in versionesValidas){
            if([textoVersion rangeOfString:versionValida options:NSCaseInsensitiveSearch].location!=NSNotFound){
                esValidaLaVersion=YES;
                break;
            }
        }
        
        if(!esValidaLaVersion){//Buscamos en el comentario si algun token es tal cual(case insensitive) la version que buscamos
            for(NSString* versionValida in versionesValidas){
                for(NSString* token in comentariosTokenizados){
                    
                    if([versionValida caseInsensitiveCompare:token]==NSOrderedSame){
                        esValidaLaVersion=YES;
                        break;
                    }
                }
                if(esValidaLaVersion){
                    break;
                }
            }
        }
        
        if(!esValidaLaVersion){
            continue;
        }
        //Ahora sabemos que la version es valida
        //Miramos que haya un subtitulo en Español (España) y que este terminado
        
        //NSLog(@"%@",elementoVersion.html);
        NSArray* hijosVersion=[elementoVersion children];
        Boolean idiomaCorrecto=NO;
        for(id hijo in hijosVersion){
            if([hijo class]==[OGElement class]){
                OGElement *hijoElement=hijo;
                if(hijoElement.tag==GUMBO_TAG_UL){//Esto es un nuevo idioma
                    NSArray *idiomas=[hijoElement elementsWithClass:@"li-idioma"];
                    if(idiomas.count<1){
                        continue;
                    }
                    OGElement *elemIdioma=[idiomas objectAtIndex:0];
                    NSString *idioma=[elemIdioma.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    //NSLog(@"Idioma:%@",idioma);
                    if([idioma caseInsensitiveCompare:@"Español (España)"]==NSOrderedSame){
                        idiomaCorrecto=YES;
                    }else{
                        idiomaCorrecto=NO;
                    }
                }else if(hijoElement.tag==GUMBO_TAG_SPAN){
                    if(idiomaCorrecto){//Si el idioma es correcto y esta terminado!
                        Boolean tieneClaseDescargar=NO;
                        Boolean tieneClaseGreen=NO;
                        for(NSString *clase in hijoElement.classes){
                            if([clase caseInsensitiveCompare:@"green"]){
                                tieneClaseGreen=YES;
                            }else if([clase caseInsensitiveCompare:@"descargar"]){
                                tieneClaseDescargar=YES;
                            }
                        }
                        if(tieneClaseDescargar&&tieneClaseGreen){
                            NSArray *aes=[hijoElement elementsWithTag:GUMBO_TAG_A];
                            if(aes.count>0){
                                OGElement *a=[aes objectAtIndex:0];
                                NSString *url=[a.attributes objectForKey:@"href"];
                                if(url!=nil){
                                    return url;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    return nil;
}

-(NSString *)buscarSubSupuestoEpDescargadoConDireccion:(NSString *)direccion{
    return [self buscarSubConDireccion:direccion yVersion:self.releaseGroupEpDescargado];
}
-(NSString*)buscarSubSupuestoConDireccion:(NSString *)direccion{
    return [self buscarSubConDireccion:direccion yVersion:self.releaseGroup];
}

-(Boolean)descargarEpisodio{
    if(self.magnetLink!=NULL){
        if(self.serie.buscadorTorrent.intValue==buscadorSeriesOccidentales||self.serie.buscadorTorrent==nil){
            NSURL *url = [NSURL URLWithString:self.magnetLink];
            if( ![[NSWorkspace sharedWorkspace] openURL:url] ){
                NSLog(@"Failed to open url: %@",[url description]);
                return NO;
            }
            return YES;
        }
        else if(self.serie.buscadorTorrent.intValue==buscadorSeriesAnimeSubsIncrustados){
            
            NSFileManager *fileManager=[NSFileManager defaultManager];
            NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
            NSURL *directorioBase=[appSupportURL URLByAppendingPathComponent:@"com.horseware.Series"];
            NSString *componente=[[NSString alloc]initWithFormat:@"torrents"] ;
            NSURL *carpetaTorrents=[directorioBase URLByAppendingPathComponent:componente];
            NSString *nombreFich=[[NSString alloc]initWithFormat:@"%d.%@.%@",self.serie.sid.intValue,self.numEpisodio,self.nombreEpisodio ];
            NSURL *urlFichero=[carpetaTorrents URLByAppendingPathComponent:nombreFich];
            urlFichero=[urlFichero URLByAppendingPathExtension:@"torrent"];
            
            if( ![[NSWorkspace sharedWorkspace] openFile:urlFichero.path] ){
                NSLog(@"Failed to open path: %@",urlFichero.path);
                return NO;
            }
            return YES;
        }
    }
    NSLog(@"ERROOOOOOOOOOOR, ME ESTA PIDIENDO DESCARGAR PERO NO HAY NADA %@",self.nombreEpisodio);
    return YES;//No seria return no?
}



-(DescargaTemp *)buscarTorrent{
    NSMutableArray *torrents;
    
    if(self.serie.buscadorTorrent.intValue==buscadorSeriesOccidentales||self.serie.buscadorTorrent==NULL){
        torrents=[self buscarTorrentsSeriesOcc];
    }else{
        torrents=[self buscarTorrentsAnimeSubsIncr];
    }
    if(torrents==nil){
        //NSLog(@"NILlLLL");
        return nil;
    }
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"seeds"
                                                 ascending:YES];//Los ordeno al reves para quedarme con el ultimo
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *torrentsOrdenados = [torrents sortedArrayUsingDescriptors:sortDescriptors];
    
    DescargaTemp *torrentElegido480=nil;
    DescargaTemp *torrentElegidoProper480=nil;
    DescargaTemp *torrentElegido720=nil;
    DescargaTemp *torrentElegidoProper720=nil;
    DescargaTemp *torrentElegido1080=nil;
    DescargaTemp *torrentElegidoProper1080=nil;
    
    //NSLog(@"%@ Cuenta de torrents ordenados: %lu",self.serie.serie,torrentsOrdenados.count);
    for(DescargaTemp *torrent in torrentsOrdenados){//Recorremos la busqueda
        //NSLog(@"%@ %lu",torrent.nombre,torrent.resolucion);
        switch(torrent.resolucion){
            case 480:
                torrentElegido480=torrent;
                if(torrent.esProper){
                    torrentElegidoProper480=torrent;
                }
                break;
            case 720:
                torrentElegido720=torrent;
                if(torrent.esProper){
                    torrentElegidoProper720=torrent;
                }
                break;
            case 1080:
                torrentElegido1080=torrent;
                if(torrent.esProper){
                    torrentElegidoProper1080=torrent;
                }
                break;
        }
    }
    //NSLog(@"%@",torrentElegido720.nombre);
    
    NSMutableArray *resoluciones=[[NSMutableArray alloc]init];
    if(self.serie.prefiereHD.boolValue){//Orden de preferencia de resoluciones
        if(self.serie.resolucionPreferida.intValue==1080){
            [resoluciones addObject:[NSNumber numberWithInt:1080]];
            [resoluciones addObject:[NSNumber numberWithInt:720]];
        }else{//incluye el null
            [resoluciones addObject:[NSNumber numberWithInt:720]];
            [resoluciones addObject:[NSNumber numberWithInt:1080]];
        }
        [resoluciones addObject:[NSNumber numberWithInt:480]];
    }else{
        [resoluciones addObject:[NSNumber numberWithInt:480]];
        [resoluciones addObject:[NSNumber numberWithInt:720]];
        [resoluciones addObject:[NSNumber numberWithInt:1080]];
    }
    
    for(NSNumber *resolucion in resoluciones){
        switch (resolucion.intValue){
            case 480:
                if(torrentElegido480!=nil){
                    if(torrentElegidoProper480!=nil){
                        return torrentElegidoProper480;
                    }else{
                        return torrentElegido480;
                    }
                }
                break;
            case 720:
                if(torrentElegido720!=nil){
                    if(torrentElegidoProper720!=nil){
                        return torrentElegidoProper720;
                    }else{
                        return torrentElegido720;
                    }
                }
                break;
            case 1080:
                if(torrentElegido1080!=nil){
                    if(torrentElegidoProper1080!=nil){
                        return torrentElegidoProper1080;
                    }else{
                        return torrentElegido1080;
                    }
                }
                break;
        }
    }
    
    //Resolucion que quiere
    //Proper
    //Mas seeds
    return nil;
}

-(NSMutableArray *)buscarTorrentsSeriesOcc{
    NSMutableArray *torrents= [[NSMutableArray alloc]init];
    [torrents addObjectsFromArray:[self buscarTorrentsSeriesOccKickass]];
    [torrents addObjectsFromArray:[self buscarTorrentsSeriesOccPirateBay]];
    return torrents;
}

-(NSMutableArray *)buscarTorrentsAnimeSubsIncr{
    NSMutableArray *torrents = [[NSMutableArray alloc]init];
    [torrents addObjectsFromArray:[self buscarTorrentsAnimeSubsIncrNyaa]];
    return torrents;
}

-(NSMutableArray *)buscarTorrentsSeriesOccKickass{
    NSMutableArray *torrents = [[NSMutableArray alloc]init];
    
    NSString *temporada = [self.numEpisodio componentsSeparatedByString:@"x"][0];
    NSString *capitulo = [self.numEpisodio componentsSeparatedByString:@"x"][1];
    int capituloint=[capitulo intValue];
    int temporadaint=[temporada intValue];
    NSString *nombreSerie=self.serie.nombreParaBusquedaEp;
    if(nombreSerie==nil){
        nombreSerie=self.serie.serie;
    }
    
    NSCharacterSet *trim = [NSCharacterSet characterSetWithCharactersInString:@"(;);'"];
    NSString *nombreSerieTrimeado = [[nombreSerie componentsSeparatedByCharactersInSet: trim] componentsJoinedByString: @""];
    
    NSString *direccion;
    bool esEspecial=NO;
    if(capituloint==0){
        esEspecial=YES;
    }
    if(esEspecial){
        NSString *nombreEpisodioTrimeado =[[self.nombreEpisodio componentsSeparatedByCharactersInSet: trim] componentsJoinedByString: @""];
        direccion= [[NSString alloc]initWithFormat:@"http://kickass.to/usearch/%@%%20s%02d%%20%@/?field=seeders&sorder=desc",nombreSerieTrimeado,temporadaint,nombreEpisodioTrimeado];
    }else{
        direccion= [[NSString alloc]initWithFormat:@"http://kickass.to/usearch/%@%%20s%02de%02d/?field=seeders&sorder=desc",nombreSerieTrimeado,temporadaint,capituloint];
    }
    
    
    direccion =[direccion stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    NSURL *url = [NSURL URLWithString:direccion];
    //NSLog(@"url %@",url.absoluteString);
    OGNode * data = [ObjectiveGumbo parseNodeWithUrl:url encoding:NSUTF8StringEncoding];
    
    //Comprobar que haya resultados
    NSArray *parrafos=[data elementsWithTag:GUMBO_TAG_P];
    for(OGElement *p in parrafos){
        if([p.text containsString:@"did not match any documents"]){
            NSLog(@"%@ %@ no hay resultados",self.serie.serie,self.nombreEpisodio);
            return torrents;
        }
    }

    
    
    NSArray * resultadosOdd=[data elementsWithClass:@"odd"];
    NSMutableArray *resultados= [[NSMutableArray alloc]initWithArray:resultadosOdd];
    [resultados addObjectsFromArray:[data elementsWithClass:@"even"]];
    for(OGElement *elementoDescargar in resultados){
        //NSLog(@"%@",elementoDescargar.text);
        NSArray *elementosTD=[elementoDescargar elementsWithTag:GUMBO_TAG_TD];
        if(elementosTD.count<6){
            continue;
        }
        OGElement *td=[elementosTD objectAtIndex:0];
        //NSArray *magnets=[td elementsWithClass:@"imagnet"];
        NSArray *magnets=[td elementsWithAttribute:@"title" andValue:@"Torrent magnet link"];
        if(magnets.count<1){
            continue;
        }
        OGElement *imagnet=[magnets objectAtIndex:0];
        NSString *magnet=[[imagnet attributes]valueForKey:@"href"];
        NSArray *cellMainLinks=[td elementsWithClass:@"cellMainLink"];
        if(cellMainLinks.count<1){
            continue;
        }
        OGElement *cellMainLink=[cellMainLinks objectAtIndex:0];
        NSString *nombre=cellMainLink.text;
        td=[elementosTD objectAtIndex:4];//Seeds
        NSString *seeds=td.text;
        td=[elementosTD objectAtIndex:5];//Peers
        NSString *peers=td.text;
        
        //Descartamos los torrents que no sean de este episodio
        //Buscamos que tengan el string de la forma s01e01 o 1x01
        if(!esEspecial){//Si es especial no se busca el numero de episodio
            NSString *stringComparacion =[[NSString alloc]initWithFormat:@"s%02de%02d",temporadaint,capituloint ];
            if([nombre rangeOfString:stringComparacion options:NSCaseInsensitiveSearch].location==NSNotFound){
                stringComparacion=[[NSString alloc]initWithFormat:@"%dx%02d",temporadaint,capituloint];
                if([nombre rangeOfString:stringComparacion options:NSCaseInsensitiveSearch].location==NSNotFound){
                    continue;
                }
            }
        }
        
        //NSLog(@"%@ Seeds: %@ Peers: %@, %@",nombre,seeds,peers,magnet);
        DescargaTemp *torrent=[[DescargaTemp alloc]init];
        torrent.magnetLink=magnet;
        torrent.nombre=nombre;
        torrent.peers=peers.intValue;
        torrent.seeds=seeds.intValue;
        if ([nombre containsString:@"720p"]){
            torrent.esHD=YES;
            torrent.resolucion=720;
        }else if([nombre containsString:@"1080p"]){
            torrent.esHD=YES;
            torrent.resolucion=1080;
        }else{
            torrent.esHD=NO;
            torrent.resolucion=480;
        }
        if([nombre containsString:@"REPACK"]||[nombre containsString:@"PROPER"]){
            torrent.esProper=YES;
        }else{
            torrent.esProper=NO;
        }
        torrent.esMagnet=YES;
        torrent.episodio=self;
        [torrents addObject:torrent];
    }
    return torrents;
}

-(NSArray *)buscarTorrentsAnimeSubsIncrNyaa{//El nuevo
    
    NyaaSeBusquedaCapitulos *busquedaCap=[[NyaaSeBusquedaCapitulos alloc]initWithEpisodio:self];
    return busquedaCap.descargas;
//    NSString *temporada = [self.numEpisodio componentsSeparatedByString:@"x"][0];
//    NSString *capitulo = [self.numEpisodio componentsSeparatedByString:@"x"][1];
//    int capituloint=[capitulo intValue];
//    NSString *nombreSerie=self.serie.nombreParaBusquedaEp;
//    if(nombreSerie==nil){
//        nombreSerie=self.serie.serie;
//    }
//    
//    NSCharacterSet *trim = [NSCharacterSet characterSetWithCharactersInString:@"(;);'"];
//    NSString *nombreSerieTrimeado = [[nombreSerie componentsSeparatedByCharactersInSet: trim] componentsJoinedByString: @""];
//    
//    NSString *direccion=[[NSString alloc]initWithFormat:@"http://www.nyaa.se/?page=search&term=%%22%@+%02d%%22&sort=2",nombreSerieTrimeado,capituloint];
//    direccion =[direccion stringByReplacingOccurrencesOfString:@" " withString:@"+"];
//    
//    NSURL *url = [NSURL URLWithString:direccion];
//    //NSLog(@"%@ %@ url %@",self.serie.serie,self.numEpisodio,url.absoluteString);
//    OGNode * data = [ObjectiveGumbo parseNodeWithUrl:url encoding:NSUTF8StringEncoding];
//    NSArray * resultados=[data elementsWithClass:@"tlistdownload"];
//    //NSLog(@"numresul %ld",resultados.count);
//    for(OGElement *elementoTlistDownload in resultados){
//        //Coger el padre y hacer matching de titulo [fansub] Nombre de serie - 01 [720p] [hash opcional]
//        NSArray *nombres=[elementoTlistDownload.parent elementsWithClass:@"tlistname"];
//        if(nombres.count<1){
//            //NSLog(@"Continue");
//            continue;
//        }
//        OGElement *tListName = [nombres objectAtIndex:0];
//        NSArray *tListNameAs=[tListName elementsWithTag:GUMBO_TAG_A];
//        if(tListNameAs.count<1){
//            continue;
//        }
//        OGElement *tListNameA=[tListNameAs objectAtIndex:0];
//        NSRegularExpression *nameExpression = [NSRegularExpression regularExpressionWithPattern:@"^\\[(.+)] (.+) - (\\d+) \\[(\\d+)p].+$" options:NSRegularExpressionCaseInsensitive error:nil];
//        NSArray *matches = [nameExpression matchesInString:tListNameA.text
//                                                   options:0
//                                                     range:NSMakeRange(0, [tListNameA.text length])];
//        //NSLog(@"%@",tListNameA.text);
//        
//        if(matches.count<1){//No hubo match
//            //NSLog(@"%@ no match",tListNameA.text);
//            continue;
//        }else{//Hay match
//            NSTextCheckingResult *match = [matches objectAtIndex:0];
//            NSRange matchRange;
//            //fansub
//            //matchRange = [match rangeAtIndex:1];
//            //NSLog(@"%@",[tListNameA.text substringWithRange:matchRange]);
//            
//            matchRange = [match rangeAtIndex:2];//Nombre de serie coincide con el que buscamos
//            //NSLog(@"%@.%@",nombreSerieTrimeado,[tListNameA.text substringWithRange:matchRange]);
//            if([[tListNameA.text substringWithRange:matchRange] caseInsensitiveCompare:nombreSerieTrimeado]!=NSOrderedSame){
//                //NSLog(@"No coincide");
//                continue;
//            }
//            //NSLog(@"Si coincide");
//            matchRange = [match rangeAtIndex:3];//Num de capitulo igual
//            if(capituloint!=[tListNameA.text substringWithRange:matchRange].intValue){
//                continue;
//            }
//            matchRange = [match rangeAtIndex:4];//resolucion
//            NSString *resolucion=[tListNameA.text substringWithRange:matchRange];
//            
//            NSArray *elementosAenTListDownload =[elementoTlistDownload elementsWithTag:GUMBO_TAG_A];
//            if(elementosAenTListDownload.count<1){
//                continue;
//            }
//            OGElement *elementoA = [elementosAenTListDownload objectAtIndex:0];
//            NSString * direccion =[[elementoA attributes] valueForKey:@"href"];
//            
//            NSArray *seeds=[elementoTlistDownload.parent elementsWithClass:@"tlistsn"];
//            if(seeds.count<1){
//                continue;
//            }
//            OGElement *tlistsn = [seeds objectAtIndex:0];
//            //NSLog(@"ep %@ Seeds: %@",self.numEpisodio,tlistsn.text);
//            
//            NSArray *leeches=[elementoTlistDownload.parent elementsWithClass:@"tlistln"];
//            if(leeches.count<1){
//                continue;
//            }
//            OGElement *tlistln = [leeches objectAtIndex:0];
//            //NSLog(@"Leechers: %@",tlistln.text);
//            
//            DescargaTemp *descarga=[[DescargaTemp alloc]init];
//            descarga.urlTorrent=direccion;
//            descarga.nombre=tListNameA.text;
//            descarga.seeds=tlistsn.text.intValue;
//            descarga.peers=tlistln.text.intValue;
//            if(resolucion.intValue==1080||resolucion.intValue==720){
//                descarga.esHD=YES;
//            }else{
//                descarga.esHD=NO;
//            }
//            descarga.resolucion=resolucion.intValue;
//            descarga.esProper=NO;
//            descarga.esMagnet=NO;
//            descarga.episodio=self;
//            [torrents addObject:descarga];
//        }
//        
//    }
//    if(resultados.count==0){//Puede ser que no haya resultados o que solo hubiera 1 y nos llevara a el directamente
//        NSArray * resultados=[data elementsWithClass:@"viewdownloadbutton"];
//        if(resultados.count<1){
//            return torrents;
//        }
//        NSArray *viewTorrentNames=[data elementsWithClass:@"viewtorrentname"];
//        if(viewTorrentNames.count<1){
//            return torrents;
//        }
//        OGElement *viewTorrentName = [viewTorrentNames objectAtIndex:0];
//        NSRegularExpression *nameExpression = [NSRegularExpression regularExpressionWithPattern:@"^\\[(.+)] (.+) - (\\d+) \\[(\\d+)p].+$" options:NSRegularExpressionCaseInsensitive error:nil];
//        NSArray *matches = [nameExpression matchesInString:viewTorrentName.text
//                                                   options:0
//                                                     range:NSMakeRange(0, [viewTorrentName.text length])];
//        if(matches.count<1){
//            return torrents;
//        }
//        
//        NSTextCheckingResult *match = [matches objectAtIndex:0];
//        NSRange matchRange;
//        //fansub
//        //matchRange = [match rangeAtIndex:1];
//        //NSLog(@"%@",[tListNameA.text substringWithRange:matchRange]);
//        matchRange = [match rangeAtIndex:2];
//        if([[viewTorrentName.text substringWithRange:matchRange] caseInsensitiveCompare:nombreSerieTrimeado]!=NSOrderedSame){//Nombre de serie
//            return torrents;
//        }
//        matchRange = [match rangeAtIndex:3];
//        if(capituloint!=[viewTorrentName.text substringWithRange:matchRange].intValue){//Num capitulo
//            return torrents;
//        }
//        matchRange = [match rangeAtIndex:4];//resolucion
//        NSString *resolucion=[viewTorrentName.text substringWithRange:matchRange];
//        OGElement *elemento=[resultados objectAtIndex:0];
//        NSArray *elementosA =[elemento elementsWithTag:GUMBO_TAG_A];
//        if(elementosA.count<1){
//            return torrents;
//        }
//        OGElement *elementoA = [elementosA objectAtIndex:0];
//        NSString *direccion=[[elementoA attributes]valueForKey:@"href"];
//        
//        
//        NSArray *seeds=[data elementsWithClass:@"viewsn"];
//        if(seeds.count<1){
//            return torrents;
//        }
//        OGElement *tlistsn = [seeds objectAtIndex:0];
//        NSLog(@"Seeds: %@",tlistsn.text);
//        
//        NSArray *leeches=[data elementsWithClass:@"viewln"];
//        if(leeches.count<1){
//            return torrents;
//        }
//        OGElement *tlistln = [leeches objectAtIndex:0];
//        NSLog(@"Leechers: %@",tlistln.text);
//        
//        DescargaTemp *descarga=[[DescargaTemp alloc]init];
//        descarga.urlTorrent=direccion;
//        descarga.nombre=viewTorrentName.text;
//        descarga.seeds=tlistsn.text.intValue;
//        descarga.peers=tlistln.text.intValue;
//        if(resolucion.intValue==1080||resolucion.intValue==720){
//            descarga.esHD=YES;
//        }else{
//            descarga.esHD=NO;
//        }
//        descarga.resolucion=resolucion.intValue;
//        descarga.esProper=NO;
//        descarga.esMagnet=NO;
//        descarga.episodio=self;
//        [torrents addObject:descarga];
//    }
//    
//    return torrents;
}

-(NSMutableArray *) buscarTorrentsSeriesOccPirateBay{
    NSString *temporada = [self.numEpisodio componentsSeparatedByString:@"x"][0];
    NSString *capitulo = [self.numEpisodio componentsSeparatedByString:@"x"][1];
    int temporadaint = [temporada intValue];
    int capituloint = [capitulo intValue];
    
    //Elimino ciertos caracteres del titulo para hacer la busqueda
    NSString *nombreSerie;
    if(self.serie.nombreParaBusquedaEp!=nil&&![self.serie.nombreParaBusquedaEp isEqualToString:@""]){
        nombreSerie=self.serie.nombreParaBusquedaEp;
    }else{
        nombreSerie=self.serie.serie;
    }
    
    NSCharacterSet *trim = [NSCharacterSet characterSetWithCharactersInString:@"(;);'"];
    NSString *nombreSerieTrimeado = [[nombreSerie componentsSeparatedByCharactersInSet: trim] componentsJoinedByString: @""];
    
    NSMutableArray *direcciones = [[NSMutableArray alloc]init];
    NSString *direccion= [[NSString alloc]initWithFormat:@"http://thepiratebay.se/search/%@%%20s%02de%02d/0/7/0",nombreSerieTrimeado,temporadaint,capituloint];
    direccion =[direccion stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
    [direcciones addObject:direccion];
    direccion= [[NSString alloc]initWithFormat:@"http://thepiratebay.se/search/%@%%20%dx%02d/0/7/0",nombreSerieTrimeado,temporadaint,capituloint];
    direccion =[direccion stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    [direcciones addObject:direccion];
    
    NSMutableArray *descargas=[[NSMutableArray alloc]init];
    
    for(NSString *direccion in direcciones){//Se hacen dos busquedas, s01e01 y 1x01
        //NSLog(@"URL %@",direccion);
        NSURL *url = [NSURL URLWithString:direccion];
        
        OGNode * data = [ObjectiveGumbo parseNodeWithUrl:url encoding:NSUTF8StringEncoding];
        NSArray * resultados=[data elementsWithID:@"searchResult"];
        if(resultados.count>=1){
            OGElement *searchResult=[resultados objectAtIndex:0];
            
            NSArray *elementostBody= [searchResult elementsWithTag:GUMBO_TAG_TBODY];
            if(elementostBody.count>=1){
                OGElement *tBody = [elementostBody objectAtIndex:0];
                NSArray *elementosTR= [tBody elementsWithTag:GUMBO_TAG_TR];
                for(OGElement *tr in elementosTR){
                    NSArray *elementosTD = [tr elementsWithTag:GUMBO_TAG_TD];
                    if(elementosTD.count!=4){
                        NSLog(@"Busqueda de torrent: esperaba 4 elementos td dentro de un fila de la tabla, tengo %lu",(unsigned long)elementosTD.count);
                    }
                    OGElement *columna2= [elementosTD objectAtIndex:1];
                    OGElement *seeds=[elementosTD objectAtIndex:2];
                    OGElement *peers=[elementosTD objectAtIndex:3];
                    
                    DescargaTemp *descargaTemp = [[DescargaTemp alloc]init];
                    descargaTemp.seeds=seeds.text.intValue;
                    descargaTemp.peers=peers.text.intValue;
                    
                    NSArray *elementosA= [columna2 elementsWithTag:GUMBO_TAG_A];
                    descargaTemp.nombre = ((OGElement *)[elementosA objectAtIndex:0]).text;
                    descargaTemp.magnetLink = ((OGElement *)[elementosA objectAtIndex:1]).attributes[@"href"];
                    //NSLog(@"%@:Seeds %@, peers %@, %@",nombre,seeds.text,peers.text,magnet);
                    
                    if ([descargaTemp.nombre containsString:@"720p"]){
                        descargaTemp.esHD=YES;
                        descargaTemp.resolucion=720;
                    }else if([descargaTemp.nombre containsString:@"1080p"]){
                        descargaTemp.esHD=YES;
                        descargaTemp.resolucion=1080;
                    }else{
                        descargaTemp.esHD=NO;
                        descargaTemp.resolucion=480;
                    }

                    if([descargaTemp.nombre containsString:@"REPACK"]||[descargaTemp.nombre containsString:@"PROPER"]){
                        descargaTemp.esProper=YES;
                    }else{
                        descargaTemp.esProper=NO;
                    }
                    descargaTemp.episodio=self;
                    descargaTemp.esMagnet=YES;
                    [descargas addObject:descargaTemp];
                    
                }
                //NSLog(@"%lu",(unsigned long)[elementostBody count]);
            }
            
        }
    }
    
    return descargas;
}

-(Boolean)numCapituloAnteriorA:(Episodio*)otroEpisodio{
    int temporadaEste = self.getNumeroTemporada;
    int capituloEste = self.getNumeroEpisodio;

    NSString *temporada = [otroEpisodio.numEpisodio componentsSeparatedByString:@"x"][0];
    NSString *capitulo = [otroEpisodio.numEpisodio componentsSeparatedByString:@"x"][1];
    int temporadaOtro  = [temporada intValue];
    int capituloOtro = [capitulo intValue];
    
    if(temporadaEste<temporadaOtro){
        return YES;
    }
    if(temporadaEste>temporadaOtro){
        return NO;
    }
    if(capituloEste<capituloOtro){
        return YES;
    }
    return NO;
    
}

-(int)getNumeroEpisodio{
    NSString *capitulo = [self.numEpisodio componentsSeparatedByString:@"x"][1];
    return capitulo.intValue;
}
-(int)getNumeroTemporada{
    NSString *temporada = [self.numEpisodio componentsSeparatedByString:@"x"][0];
    return temporada.intValue;
}
@end
