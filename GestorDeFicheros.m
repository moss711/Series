//
//  GestorDeFicheros.m
//  TvTime
//
//  Created by Alexandre Blanco Gómez on 1/11/14.
//  Copyright (c) 2014 Horseware. All rights reserved.
//

#import "GestorDeFicheros.h"
#import "Episodio.h"
#import "Serie.h"

@implementation GestorDeFicheros
NSFileManager *fileManager;
NSURL *directorioBase;

//-(instancetype)init{
//    NSString* home=[[[NSProcessInfo processInfo] environment] objectForKey:@"HOME"];
//    NSString * rutaSubs=[[NSString alloc]initWithFormat:@"file://%@/Movies/",home];
//    return [self initWithRutaSubs:rutaSubs];
//}

//-(instancetype)initWithRutaSubs:(NSString*)ruta{
//    fileManager=[NSFileManager defaultManager];
//    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
//    directorioBase=[appSupportURL URLByAppendingPathComponent:@"com.horseware.Series"];
//    
//    self.directorioSubs=[NSURL URLWithString:ruta];
//    //self.directorioSubs=[NSURL URLWithString:@"file:///Users/Alex/Movies/"];
//    return [super init];
//}

-(instancetype)initWithGestorOpciones:(GestorDeOpciones *)gestorOpciones{
    self.gestorOpciones=gestorOpciones;
    
    fileManager=[NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    directorioBase=[appSupportURL URLByAppendingPathComponent:@"com.horseware.Series"];
    return [super init];
}

-(BOOL)guardarPosterConData:(NSData*)data conSid:(NSNumber*)sid{
    NSString *componente=[[NSString alloc]initWithFormat:@"imagenes/%@",sid.stringValue ] ;
    NSURL *carpetaSerie=[directorioBase URLByAppendingPathComponent:componente];
    NSLog(@"%@",carpetaSerie);
    //NSError *error;
    if ([fileManager createDirectoryAtURL:carpetaSerie withIntermediateDirectories:YES attributes:nil error:nil]) {
        NSURL *urlFichero=[carpetaSerie URLByAppendingPathComponent:@"poster"];
        urlFichero=[urlFichero URLByAppendingPathExtension:@"jpg"];
        return[data writeToURL:urlFichero atomically:NO];
    }
    return NO;
}

-(BOOL)guardarPoster:(NSImage*)poster conSid:(NSNumber*)sid{
    //NSData *data = [poster TIFFRepresentation];//anadir compresion?
    NSData *data = [poster TIFFRepresentationUsingCompression:NSTIFFCompressionJPEG factor:0.3];

    NSString *componente=[[NSString alloc]initWithFormat:@"imagenes/%@",sid.stringValue ] ;
    NSURL *carpetaSerie=[directorioBase URLByAppendingPathComponent:componente];
    NSLog(@"%@",carpetaSerie);
    //NSError *error;
    if ([fileManager createDirectoryAtURL:carpetaSerie withIntermediateDirectories:YES attributes:nil error:nil]) {
        NSURL *urlFichero=[carpetaSerie URLByAppendingPathComponent:@"poster"];
        urlFichero=[urlFichero URLByAppendingPathExtension:@"jpg"];
        return[data writeToURL:urlFichero atomically:NO];
    }
    return NO;
}

-(NSImage*)recuperarPosterConSid:(NSNumber*)sid{
    NSString *componente=[[NSString alloc]initWithFormat:@"imagenes/%@",sid.stringValue ] ;
    NSURL *carpetaSerie=[directorioBase URLByAppendingPathComponent:componente];
    NSURL *urlFichero=[carpetaSerie URLByAppendingPathComponent:@"poster"];
    urlFichero=[urlFichero URLByAppendingPathExtension:@"jpg"];
    
    NSData *data = [[NSData alloc]initWithContentsOfURL:urlFichero];
    return [[NSImage alloc]initWithData:data];
}

-(Boolean)eliminarPosterConSid:(NSNumber*)sid{
    NSError* err;
    NSString *componente=[[NSString alloc]initWithFormat:@"imagenes/%@",sid.stringValue ] ;
    NSURL *carpetaSerie=[directorioBase URLByAppendingPathComponent:componente];//borramos la carpeta
    //NSURL *urlFichero=[carpetaSerie URLByAppendingPathComponent:@"poster"];
    //urlFichero=[urlFichero URLByAppendingPathExtension:@"jpg"];
    if ([[NSFileManager defaultManager] isDeletableFileAtPath:carpetaSerie.path]) {
        BOOL success = [[NSFileManager defaultManager] removeItemAtPath:carpetaSerie.path error:&err];
        if (!success) {
            NSLog(@"Error removing file at path: %@", err.localizedDescription);
        }
        return success;
    }
    return NO;
}

-(BOOL)guardarTorrentDeEpisodio:(Episodio*)ep ConURL:(NSString *)stringURLTorrent {
    NSURL *urlTorrent =[[NSURL alloc]initWithString:stringURLTorrent];
    NSData *data=[[NSData alloc]initWithContentsOfURL:urlTorrent];
    NSString *componente=[[NSString alloc]initWithFormat:@"torrents"] ;
    NSURL *carpetaTorrents=[directorioBase URLByAppendingPathComponent:componente];
    //NSError *error;
    if ([fileManager createDirectoryAtURL:carpetaTorrents withIntermediateDirectories:YES attributes:nil error:nil]) {
        NSString *nombreFich=[[NSString alloc]initWithFormat:@"%d.%@.%@",ep.serie.sid.intValue,ep.numEpisodio,ep.nombreEpisodio ];
        NSURL *urlFichero=[carpetaTorrents URLByAppendingPathComponent:nombreFich];
        urlFichero=[urlFichero URLByAppendingPathExtension:@"torrent"];
        return [data writeToURL:urlFichero atomically:NO];
    }
    return NO;
}

-(BOOL)guardarSubDeEpisodio:(Episodio*)ep ConURL:(NSString *)stringURLSub {
    NSURL *urlSub =[[NSURL alloc]initWithString:stringURLSub];
    //NSData *data=[[NSData alloc]initWithContentsOfURL:urlSub];
    //NSArray * availableCookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:@"http://www.addic7ed.com"]];
    //NSDictionary * headers = [NSHTTPCookie requestHeaderFieldsWithCookies:availableCookies];
    NSMutableDictionary *headers=[[NSMutableDictionary alloc]init];
    [headers setValue:ep.urlSub forKey:@"Referer"];
    
    NSMutableURLRequest * request;
    NSHTTPURLResponse   * response;
    NSError             * error;
    
    request = [[NSMutableURLRequest alloc] initWithURL:urlSub
                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                       timeoutInterval:60];
    
    [request setAllHTTPHeaderFields:headers];
    error       = nil;
    response    = nil;
    
    NSData * dataHTML = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    //NSError *error;
    NSString *nombreFich;
    if(ep.serie.buscadorSubtitulos!=nil&&ep.serie.buscadorSubtitulos.intValue==SubtitulosES){
        nombreFich=[[NSString alloc]initWithFormat:@"%@-%@.%@-%@ subtitulos.es",ep.serie.serie,ep.numEpisodio,ep.nombreEpisodio,ep.releaseGroup];
    }else{
        nombreFich=[[NSString alloc]initWithFormat:@"%@-%@.%@-%@ addic7ed.com",ep.serie.serie,ep.numEpisodio,ep.nombreEpisodio,ep.releaseGroup];
    }
    //Reemplazar caracteres extranos
    nombreFich = [nombreFich stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
    
    NSURL *urlFichero=[self.gestorOpciones.rutaSubs URLByAppendingPathComponent:nombreFich];
    urlFichero=[urlFichero URLByAppendingPathExtension:@"srt"];
    return [dataHTML writeToURL:urlFichero atomically:NO];
    return NO;
}

-(NSString *)rutaTorrentDeEpisodio:(Episodio *)ep{
    NSString *componente=[[NSString alloc]initWithFormat:@"torrents"] ;
    NSURL *carpetaTorrents=[directorioBase URLByAppendingPathComponent:componente];
    NSString *nombreFich=[[NSString alloc]initWithFormat:@"%d.%@.%@",ep.serie.sid.intValue,ep.numEpisodio,ep.nombreEpisodio ];
    NSURL *urlFichero=[carpetaTorrents URLByAppendingPathComponent:nombreFich];
    urlFichero=[urlFichero URLByAppendingPathExtension:@"torrent"];
    return urlFichero.path;
}

-(Boolean)eliminarTorrentDeEpisodio:(Episodio *)ep{
    NSString *path=[self rutaTorrentDeEpisodio:ep];
    NSError *error;
    if ([[NSFileManager defaultManager] isDeletableFileAtPath:path]) {
        BOOL success = [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
        if (!success) {
            NSLog(@"Error removing file at path: %@", error.localizedDescription);
        }
        return success;
    }
    return NO;
}
@end
