//
//  TVRageEpisodeInfo.m
//  TvTime
//
//  Created by Alexandre Blanco Gómez on 28/11/14.
//  Copyright (c) 2014 Horseware. All rights reserved.
//

#import "TVRageEpisodeInfo.h"

@implementation TVRageEpisodeInfo

-(instancetype)initWithSid:(int)sid;{
    self = [super init];
    if(self) {
        self.sid=sid;
    }
    return self;

}

-(BOOL)parsear{
    NSError *err=nil;
    NSString *path=[[NSString alloc] initWithFormat:@"/feeds/episodeinfo.php?sid=%d",self.sid];
    NSURL *furl = [[NSURL alloc]initWithScheme:@"http" host:@"services.tvrage.com" path:path];
    if (!furl) {
        NSLog(@"Can't create an URL from file");
        return NO;
    }
    self.xmlEpisodeInfo = [[NSXMLDocument alloc] initWithContentsOfURL:furl
                                                          options:(NSXMLNodePreserveWhitespace|NSXMLNodePreserveCDATA)
                                                            error:&err];
    if (self.xmlEpisodeInfo == nil) {
        self.xmlEpisodeInfo = [[NSXMLDocument alloc] initWithContentsOfURL:furl
                                                              options:NSXMLDocumentTidyXML
                                                                error:&err];
    }
    if (self.xmlEpisodeInfo == nil)  {
        if (err) {
            NSLog(@"ErrorObtenerInfo 1 %@",err);
            return NO;
        }
        NSLog(@"ErrorObtenerInfo 3");
        return NO;
    }
    
    if (err) {
        NSLog(@"ErrorObtenerInfo 2 %@",err);
        return NO;
    }
    
    return YES;
}

-(EpisodioTemp *)getNextEpisode{
    NSError *err;
    NSArray *nodes = [self.xmlEpisodeInfo nodesForXPath:@"//show/nextepisode"
                                     error:&err];
    
    if(nodes.count>0){
        NSXMLElement *elementNextEpisode = [nodes objectAtIndex:0];
        nodes = [elementNextEpisode elementsForName:@"airtime"];//Buscamos la fecha en que sale
        NSArray *hijos;
        NSXMLElement *informacion;
        for (NSXMLElement *elementAirtime in nodes) {
            //NSXMLNode=[elementAirtime attributeForName:@"airtime"];
            NSXMLNode *nodo=[elementAirtime attributeForName:@"format"];
            if([[nodo stringValue] isEqualToString:@"RFC3339"]){
                //NSLog(@"%@",[elementAirtime.children objectAtIndex:0]);
                NSString *horaString = [[NSString alloc] initWithFormat:@"%@",[elementAirtime.children objectAtIndex:0]];
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
                
                NSDate *date;
                NSError *error;
                [formatter getObjectValue:&date forString:horaString range:nil error:&error];
                
                EpisodioTemp *episodio=[[EpisodioTemp alloc]init];
                episodio.sid=[NSNumber numberWithInt:self.sid];
                episodio.hora=date;
                
                hijos=[elementNextEpisode elementsForName:@"title"];
                informacion=[hijos objectAtIndex:0];
                episodio.nombreEpisodio=[[NSString alloc] initWithFormat:@"%@",[informacion.children objectAtIndex:0]];
                
                hijos=[elementNextEpisode elementsForName:@"number"];
                informacion=[hijos objectAtIndex:0];
                episodio.numEpisodio=[[NSString alloc] initWithFormat:@"%@",[informacion.children objectAtIndex:0]];
                
                return episodio;
            }
        }
    }
    return nil;
}

-(EpisodioTemp *)getLatestEpisode{
    NSError *err;
    NSArray *nodes = [self.xmlEpisodeInfo nodesForXPath:@"//show/latestepisode"
                            error:&err];
    if([nodes count]>=1){
        NSXMLElement *elementLatestEpisode = [nodes objectAtIndex:0];
        EpisodioTemp *episodio=[[EpisodioTemp alloc]init];
        episodio.sid=[NSNumber numberWithInt:self.sid];
        
        NSArray *hijos=[elementLatestEpisode elementsForName:@"title"];
        NSXMLElement *informacion=[hijos objectAtIndex:0];
        episodio.nombreEpisodio=[[NSString alloc] initWithFormat:@"%@",[informacion.children objectAtIndex:0]];
        
        hijos=[elementLatestEpisode elementsForName:@"number"];
        informacion=[hijos objectAtIndex:0];
        episodio.numEpisodio=[[NSString alloc] initWithFormat:@"%@",[informacion.children objectAtIndex:0]];
        
        hijos = [elementLatestEpisode elementsForName:@"airdate"];
        informacion=[hijos objectAtIndex:0];
        NSString *airdateString=[[NSString alloc] initWithFormat:@"%@",[informacion.children objectAtIndex:0]];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd";
        NSDate *airdate= [dateFormatter dateFromString:airdateString];
        episodio.hora= airdate;
        return episodio;
    }
    return nil;
}

-(NSString *)getPais{
    NSError *err;
    NSArray *nodes = [self.xmlEpisodeInfo nodesForXPath:@"//show/country"
                                     error:&err];
    if(nodes.count>0){
        NSXMLElement *country=[nodes objectAtIndex:0];
        return [[NSString alloc]initWithFormat:@"%@",[country.children objectAtIndex:0]];
        //NSLog(@"%@ Pais:%@",nombre,pais);
    }
    return nil;
}
@end
