//
//  TVRageSearch.m
//  TvTime
//
//  Created by Alexandre Blanco Gómez on 28/2/15.
//  Copyright (c) 2015 Horseware. All rights reserved.
//

#import "TVRageSearch.h"
#import "TVRageSerie.h"

@implementation TVRageSearch

-(instancetype)initWithString:(NSString *)nombre{
    self = [super init];
    if(self) {
        NSError *err=nil;
        NSString *path = [[NSString alloc] initWithFormat:@"/feeds/search.php?show=%@",nombre];
        NSURL *furl = [[NSURL alloc]initWithScheme:@"http" host:@"services.tvrage.com" path:path];
        if (!furl) {
            NSLog(@"Can't create an URL from file");
            return NO;
        }
        self.xmlSearch = [[NSXMLDocument alloc] initWithContentsOfURL:furl
                                                                   options:(NSXMLNodePreserveWhitespace|NSXMLNodePreserveCDATA)
                                                                     error:&err];
        if (self.xmlSearch == nil) {
            self.xmlSearch = [[NSXMLDocument alloc] initWithContentsOfURL:furl
                                                                       options:NSXMLDocumentTidyXML
                                                                         error:&err];
        }
        if (self.xmlSearch == nil)  {
            if (err) {
                NSLog(@"Error actualizarSerie1 %@",err);
                return nil;
            }
            NSLog(@"Error actualizarSerie2");
            return nil;
        }
        if (err) {
            NSLog(@"Error actualizarSerie3 %@",err);
            return nil;
        }
        return self;
    }
    return nil;
}

-(NSArray*)getBusqueda{
    NSError *err=nil;
    NSArray *nodes = [self.xmlSearch nodesForXPath:@"//show"
                                     error:&err];
    NSArray *hijos;
    
    NSXMLElement *elementoShowid;
    NSString *sid;
    NSString *started;
    
    NSMutableArray *series=[[NSMutableArray alloc]init];
    
    for (NSXMLElement *elementoSerie in nodes){
        TVRageSerie *serie = [[TVRageSerie alloc] init];
        
        hijos=[elementoSerie elementsForName:@"showid"];
        elementoShowid=[hijos objectAtIndex:0];
        sid=[[NSString alloc] initWithFormat:@"%@",[elementoShowid.children objectAtIndex:0]];
        serie.sid=sid.intValue;
        
        hijos=[elementoSerie elementsForName:@"name"];
        elementoShowid=[hijos objectAtIndex:0];
        NSString* nombre =[[NSString alloc] initWithFormat:@"%@",[elementoShowid.children objectAtIndex:0]];
        CFStringRef cfNombre = (CFStringRef)CFBridgingRetain(nombre);
        serie.nombre =CFBridgingRelease(CFXMLCreateStringByUnescapingEntities(kCFAllocatorDefault, cfNombre, NULL));
        
        hijos=[elementoSerie elementsForName:@"country"];
        elementoShowid=[hijos objectAtIndex:0];
        serie.esAnime=NO;
        serie.pais=[[NSString alloc] initWithFormat:@"%@",[elementoShowid.children objectAtIndex:0]];
        if([serie.pais caseInsensitiveCompare:@"JP"]==NSOrderedSame||[serie.pais caseInsensitiveCompare:@"Japan"]==NSOrderedSame){
            serie.esAnime=YES;
        }
        
        hijos=[elementoSerie elementsForName:@"started"];
        elementoShowid=[hijos objectAtIndex:0];
        started=[[NSString alloc] initWithFormat:@"%@",[elementoShowid.children objectAtIndex:0]];
        serie.ano=started;
        
        [series addObject:serie];
    }
    
    return [[NSArray alloc]initWithArray:series];
}

@end
