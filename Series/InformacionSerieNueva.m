//
//  InformacionSerieNueva.m
//  TvTime
//
//  Created by Alexandre Blanco Gómez on 05/08/14.
//  Copyright (c) 2014 Horseware. All rights reserved.
//

#import "InformacionSerieNueva.h"

@implementation InformacionSerieNueva
- (id)initWithSid:(NSNumber *)sid1{
    self = [super init];
    if (self) {
        self.sid=sid1;
        [self obtenerInformacionSerie];
        NSSize tamano;
        tamano.height=108;
        tamano.width=192;
        
        self.idTVdb=[self obtenerIDTVdb];
        self.miniatura=[self resizeImage:[self obtenerImagen:self.serie] size:tamano];
    }
    return self;
}

- (void)obtenerInformacionSerie{
    NSXMLDocument *xmlDoc;
    NSError *err=nil;
    NSString *path=[[NSString alloc] initWithFormat:@"/feeds/episodeinfo.php?sid=%@",self.sid];
    NSURL *furl = [[NSURL alloc]initWithScheme:@"http" host:@"services.tvrage.com" path:path];
    if (!furl) {
        NSLog(@"Can't create an URL from file");
        return;
    }
    xmlDoc = [[NSXMLDocument alloc] initWithContentsOfURL:furl
                                                  options:(NSXMLNodePreserveWhitespace|NSXMLNodePreserveCDATA)
                                                    error:&err];
    if (xmlDoc == nil) {
        xmlDoc = [[NSXMLDocument alloc] initWithContentsOfURL:furl
                                                      options:NSXMLDocumentTidyXML
                                                        error:&err];
    }
    if (xmlDoc == nil)  {
        if (err) {
            NSLog(@"%@",err.localizedFailureReason);
            return;
        }
        return;
    }
    
    if (err) {
        NSLog(@"%@",err.localizedFailureReason);
        return;
    }
    
    //Esto ya es parte del flu
    
    //Obtener nombre ano y pais
    
    NSArray *nodes = [xmlDoc nodesForXPath:@"//show"
                                     error:&err];
    
    NSArray *hijos;
    NSString *started;
    if([nodes count]>=1){
        NSXMLElement *elementoSerie = [nodes objectAtIndex:0];
        hijos=[elementoSerie elementsForName:@"name"];
        NSXMLElement *elemento=[hijos objectAtIndex:0];
        self.serie=[[NSString alloc] initWithFormat:@"%@",[elemento.children objectAtIndex:0]];
        
        hijos=[elementoSerie elementsForName:@"country"];
        elemento=[hijos objectAtIndex:0];
        self.pais=[[NSString alloc] initWithFormat:@"%@",[elemento.children objectAtIndex:0]];
        
        hijos=[elementoSerie elementsForName:@"started"];
        elemento=[hijos objectAtIndex:0];
        started=[[NSString alloc] initWithFormat:@"%@",[elemento.children objectAtIndex:0]];
        self.ano=[NSNumber numberWithInt:started.intValue];
    }
    
}

-(NSNumber *)obtenerIDTVdb{
    NSXMLDocument *xmlDoc;
    NSError *err=nil;
    
    //Comprobamos el string
    
    NSString *path = [[NSString alloc] initWithFormat:@"/api/GetSeries.php?seriesname=%@",self.serie];
    NSLog(@"%@",path);
    NSURL *furl = [[NSURL alloc]initWithScheme:@"http" host:@"thetvdb.com" path:path];
    NSLog(@"%@",[furl path]);
    if (!furl) {
        NSLog(@"Can't create an URL from file");
        return Nil;
    }
    xmlDoc = [[NSXMLDocument alloc] initWithContentsOfURL:furl
                                                  options:(NSXMLNodePreserveWhitespace|NSXMLNodePreserveCDATA)
                                                    error:&err];
    if (xmlDoc == nil) {
        xmlDoc = [[NSXMLDocument alloc] initWithContentsOfURL:furl
                                                      options:NSXMLDocumentTidyXML
                                                        error:&err];
    }
    if (xmlDoc == nil)  {
        if (err) {
            NSLog(@"%@",err.localizedFailureReason);
            return Nil;
        }
        NSLog(@"%@",@"Error. XML vacio");
        return Nil;
    }
    
    if (err) {
        NSLog(@"%@",err.localizedFailureReason);
        return Nil;
    }
    
    //Ya tenemos el documento
    
    err=nil;
    NSArray *nodes = [xmlDoc nodesForXPath:@"//Data/Series/seriesid"
                                     error:&err];
    
    //Comprobar error de lista vacia
    if([nodes count]==0){
        if([self.serie hasSuffix:@")"]){
            NSUInteger longitud= [self.serie length];
            NSRange rango= {0,longitud-5};
            NSString *nombre=[self.serie substringWithRange:rango];
            NSLog(@"nuevo nombre: _%@_",nombre);
            
            path = [[NSString alloc] initWithFormat:@"/api/GetSeries.php?seriesname=%@",nombre];
            NSLog(@"%@",path);
            furl = [[NSURL alloc]initWithScheme:@"http" host:@"thetvdb.com" path:path];
            NSLog(@"%@",[furl path]);
            if (!furl) {
                NSLog(@"Can't create an URL from file");
                return Nil;
            }
            xmlDoc = [[NSXMLDocument alloc] initWithContentsOfURL:furl
                                                          options:(NSXMLNodePreserveWhitespace|NSXMLNodePreserveCDATA)
                                                            error:&err];
            if (xmlDoc == nil) {
                xmlDoc = [[NSXMLDocument alloc] initWithContentsOfURL:furl
                                                              options:NSXMLDocumentTidyXML
                                                                error:&err];
            }
            if (xmlDoc == nil)  {
                if (err) {
                    NSLog(@"%@",err.localizedFailureReason);
                    return Nil;
                }
                NSLog(@"%@",@"Error. XML vacio");
                return Nil;
            }
            
            if (err) {
                NSLog(@"%@",err.localizedFailureReason);
                return Nil;
            }
            
            //Ya tenemos el documento
            
            err=nil;
            nodes = [xmlDoc nodesForXPath:@"//Data/Series/seriesid"
                                    error:&err];
        }
        if([nodes count]==0){
            return NULL;
        }
    }
    
    NSXMLElement *seriesid=[nodes objectAtIndex:0];
    NSString *sid=[[NSString alloc] initWithFormat:@"%@",[seriesid.children objectAtIndex:0]];
    
    NSLog(@"SID tvshowdv %@",sid);
    return [[NSNumber alloc]initWithInt:sid.intValue];
}

-(NSImage*) obtenerImagen:(NSString*)nombre{
    if(self.idTVdb==NULL||self.tvDBBanners==NULL){
        return [NSImage imageNamed:@"ImagenDefecto.png"];
    }
    NSString * path=self.tvDBBanners.getURLMiniautraMejorValorada;
    if(path==nil){
        return [NSImage imageNamed:@"ImagenDefecto.png"];
    }
    NSURL *furl = [[NSURL alloc]initWithString:path];
    
//    NSError *err=nil;
//    NSString *path = [[NSString alloc] initWithFormat:@"/data/series/%@",self.idTVdb];
//    NSURL *furl = [[NSURL alloc]initWithScheme:@"http" host:@"thetvdb.com" path:path];
//    if (!furl) {
//        NSLog(@"Can't create an URL from file");
//        return Nil;
//    }
//    NSXMLDocument *xmlDoc = [[NSXMLDocument alloc] initWithContentsOfURL:furl
//                                                  options:(NSXMLNodePreserveWhitespace|NSXMLNodePreserveCDATA)
//                                                    error:&err];
//    
//    if (xmlDoc == nil) {
//        xmlDoc = [[NSXMLDocument alloc] initWithContentsOfURL:furl
//                                                      options:NSXMLDocumentTidyXML
//                                                        error:&err];
//    }
//    if (xmlDoc == nil)  {
//        if (err) {
//            NSLog(@"%@",err);
//            return [NSImage imageNamed:@"ImagenDefecto.png"];
//        }
//        return [NSImage imageNamed:@"ImagenDefecto.png"];
//    }
//    
//    if (err) {
//        NSLog(@"%@",err.localizedFailureReason);
//        return [NSImage imageNamed:@"ImagenDefecto.png"];
//    }
//    
//    //Ya tenemos el documento
//    
//    err=nil;
//    NSArray *nodes = [xmlDoc nodesForXPath:@"//Data/Series/fanart"
//                            error:&err];
//    NSXMLElement *nodos2=[nodes objectAtIndex:0];
//    NSString *fanart=[[NSString alloc] initWithFormat:@"%@",[nodos2.children objectAtIndex:0]];
//    
//    NSLog(@"fanart tvshowdv %@",fanart);
//    
//    if([fanart isEqualToString:@"(null)"]){
//        return [NSImage imageNamed:@"ImagenDefecto.png"];
//    }
//    
//    path = [[NSString alloc] initWithFormat:@"/banners/%@",fanart];
//    furl = [[NSURL alloc]initWithScheme:@"http" host:@"thetvdb.com" path:path];
//    if (!furl) {
//        NSLog(@"Can't create an URL from file");
//        return [NSImage imageNamed:@"ImagenDefecto.png"];
//    }
    
    
    return [[NSImage alloc] initWithContentsOfURL:furl];
}

-(NSData*) obtenerPoster{
    
    if(self.tvDBBanners==NULL){
        return nil;
    }
    NSString* path=self.tvDBBanners.getURLPosterMejorValorado;
    if(path==nil){
        return nil;
    }
    NSURL *furl = [[NSURL alloc]initWithString:path];
    
    NSData *data=[[NSData alloc]initWithContentsOfURL:furl];
    return data;
    //return [[NSImage alloc] initWithContentsOfURL:furl];
}

- (NSImage*) resizeImage:(NSImage*)sourceImage size:(NSSize)size
{
    
    NSRect targetFrame = NSMakeRect(0, 0, size.width, size.height);
    NSImage* targetImage = nil;
    NSImageRep *sourceImageRep =
    [sourceImage bestRepresentationForRect:targetFrame
                                   context:nil
                                     hints:nil];
    
    targetImage = [[NSImage alloc] initWithSize:size];
    
    [targetImage lockFocus];
    [sourceImageRep drawInRect: targetFrame];
    [targetImage unlockFocus];
    
    return targetImage;
}

-(void) buscarImagen{
    NSSize tamano;
    tamano.height=108;
    tamano.width=192;
    
    self.miniatura=[self resizeImage:[self obtenerImagen:self.serie] size:tamano];
}

-(void)parsearXMLImagenes{
    if(self.idTVdb==nil){
        self.tvDBBanners=nil;
    }else{
        self.tvDBBanners=[[TheTVDBBanners alloc]initWithID:self.idTVdb.intValue];
    }
}


@end
