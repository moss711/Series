//
//  TheTVDBBanners.m
//  TvTime
//
//  Created by Alexandre Blanco Gómez on 8/1/15.
//  Copyright (c) 2015 Horseware. All rights reserved.
//

#import "TheTVDBBanners.h"

@implementation TheTVDBBanners
-(instancetype)initWithID:(int)idTheTVDB{
    self = [super init];
    if(self) {
        self.idTheTVDB=idTheTVDB;
        //Inicializar xml
        NSError *err=nil;
        NSString *path = [[NSString alloc] initWithFormat:@"/api/88DB7E048464363A/series/%d/banners.xml",self.idTheTVDB];
        NSURL *furl = [[NSURL alloc]initWithScheme:@"http" host:@"thetvdb.com" path:path];
        if (!furl) {
            NSLog(@"Can't create an URL from file");
        }
        self.xmlBanners = [[NSXMLDocument alloc] initWithContentsOfURL:furl
                                                                     options:(NSXMLNodePreserveWhitespace|NSXMLNodePreserveCDATA)
                                                                       error:&err];
        
        if (self.xmlBanners == nil) {
            self.xmlBanners = [[NSXMLDocument alloc] initWithContentsOfURL:furl
                                                          options:NSXMLDocumentTidyXML
                                                            error:&err];
        }
        if (self.xmlBanners == nil)  {
            if (err) {
                NSLog(@"%@",err);
            }
            return nil;
        }
        
        if (err) {
            NSLog(@"%@",err);
            return nil;
        }

    }
    return self;
}

-(NSString *)getURLMiniautraMejorValorada{
    NSError *err=nil;
    NSArray *nodes = [self.xmlBanners nodesForXPath:@"//Banners/Banner[BannerType=\"fanart\"]"
                                     error:&err];
    
    //EL xml ya esta ordenado por rating
    if(nodes.count<1){
        return nil;
    }
    NSXMLElement *banner=[nodes objectAtIndex:0];
    NSArray *apoyo=[banner elementsForName:@"BannerPath"];
    if(apoyo.count<1){
        return nil;
    }
    NSXMLElement *bannerPath=[apoyo objectAtIndex:0];
    return [[NSString alloc ]initWithFormat:@"http://thetvdb.com/banners/%@",bannerPath.stringValue ];
}

-(NSString *)getURLPosterMejorValorado{
    NSError *err=nil;
    NSArray *nodes = [self.xmlBanners nodesForXPath:@"//Banners/Banner[BannerType=\"poster\"]"
                                              error:&err];
    
    //EL xml ya esta ordenado por rating
    if(nodes.count<1){
        return nil;
    }
    NSXMLElement *banner=[nodes objectAtIndex:0];
    NSArray *apoyo=[banner elementsForName:@"BannerPath"];
    if(apoyo.count<1){
        return nil;
    }
    NSXMLElement *bannerPath=[apoyo objectAtIndex:0];
    return [[NSString alloc ]initWithFormat:@"http://thetvdb.com/banners/%@",bannerPath.stringValue ];
}

-(NSImage*)getImagenMiniaturaMejorValorada{
    NSURL *furl = [[NSURL alloc]initWithString:self.getURLMiniautraMejorValorada];
    NSImage* miniatura=[[NSImage alloc] initWithContentsOfURL:furl];
    NSSize tamano;
    tamano.height=108;
    tamano.width=192;
    return [self resizeImage:miniatura size:tamano];
}

-(NSData*)getDataPosterMejorValorado{
    NSURL *furl = [[NSURL alloc]initWithString:self.getURLPosterMejorValorado];
    return [[NSData alloc]initWithContentsOfURL:furl];
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

@end
