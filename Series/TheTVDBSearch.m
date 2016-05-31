//
//  TheTVDBSearch.m
//  TvTime
//
//  Created by Alexandre Blanco Gómez on 28/2/15.
//  Copyright (c) 2015 Horseware. All rights reserved.
//

#import "TheTVDBSearch.h"

@implementation TheTVDBSearch

-(instancetype)initWithNombre:(NSString *)nombre idTVRage:(int)idTvRage{
    self = [super init];
    if(self) {
        self.nombre=nombre;
        self.idTVRage=idTvRage;
        
        NSError *err=nil;
        NSXMLDocument *xml;
        //Comprobamos el string
        
        NSString *path = [[NSString alloc] initWithFormat:@"/api/GetSeries.php?seriesname=%@",self.nombre];
        NSLog(@"%@",path);
        NSURL *furl = [[NSURL alloc]initWithScheme:@"http" host:@"thetvdb.com" path:path];
        NSLog(@"%@",[furl path]);
        if (!furl) {
            NSLog(@"Can't create an URL from file");
            return Nil;
        }
        xml = [[NSXMLDocument alloc] initWithContentsOfURL:furl
                                                      options:(NSXMLNodePreserveWhitespace|NSXMLNodePreserveCDATA)
                                                        error:&err];
        if (xml == nil) {
            xml = [[NSXMLDocument alloc] initWithContentsOfURL:furl
                                                          options:NSXMLDocumentTidyXML
                                                            error:&err];
        }
        if (xml == nil)  {
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
        
        NSArray *nodes = [xml nodesForXPath:@"//Data/Series"
                                         error:&err];
        
        NSMutableArray *series=[[NSMutableArray alloc]init];
        
        for (NSXMLElement *elementoSerie in nodes){
            TheTVDBSerie* serie =[[TheTVDBSerie alloc]init];
            
            NSArray* hijos=[elementoSerie elementsForName:@"seriesid"];
            if(hijos.count<1){
                continue;
            }
            NSXMLElement *elemento=[hijos objectAtIndex:0];
            NSString* sid=[[NSString alloc] initWithFormat:@"%@",[elemento.children objectAtIndex:0]];
            serie.sid=sid.intValue;

            hijos=[elementoSerie elementsForName:@"SeriesName"];
            if(hijos.count<1){
                continue;
            }
            elemento=[hijos objectAtIndex:0];
            NSString* nombre=[[NSString alloc] initWithFormat:@"%@",[elemento.children objectAtIndex:0]];
            serie.nombre=nombre;
            
            hijos=[elementoSerie elementsForName:@"Network"];
            if(hijos.count<1){
                continue;
            }
            elemento=[hijos objectAtIndex:0];
            NSString* network=[[NSString alloc] initWithFormat:@"%@",[elemento.children objectAtIndex:0]];
            serie.network=network;
            
            hijos=[elementoSerie elementsForName:@"FirstAired"];
            if(hijos.count<1){
                continue;
            }
            elemento=[hijos objectAtIndex:0];
            NSString* firstAired=[[NSString alloc] initWithFormat:@"%@",[elemento.children objectAtIndex:0]];
            NSString* ano=[firstAired substringToIndex:4];
            serie.ano=ano;
            
            
            
            [series addObject:serie];
        }
        
        self.series=[[NSArray alloc]initWithArray:series];
        return self;
    }
    return nil;
}

-(TheTVDBSerie*)getPrimeraOpcion{
    if(self.series.count<1){
        return nil;
    }
    return [self.series objectAtIndex:0];
}

@end
