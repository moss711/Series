//
//  TheTVDBBanners.h
//  TvTime
//
//  Created by Alexandre Blanco Gómez on 8/1/15.
//  Copyright (c) 2015 Horseware. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TheTVDBBanners : NSObject

@property int idTheTVDB;
@property NSXMLDocument* xmlBanners;

-(instancetype)initWithID:(int)idTheTVDB;

-(NSString*)getURLMiniautraMejorValorada;
-(NSString*)getURLPosterMejorValorado;
-(NSImage*)getImagenMiniaturaMejorValorada;
-(NSData*)getDataPosterMejorValorado;

@end
