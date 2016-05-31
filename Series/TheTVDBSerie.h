//
//  TheTVDBSerie.h
//  TvTime
//
//  Created by Alexandre Blanco Gómez on 28/2/15.
//  Copyright (c) 2015 Horseware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TheTVDBBanners.h"

@interface TheTVDBSerie : NSObject

@property NSString* nombre;
@property int sid;
@property NSString* network;
@property NSString* ano;
@property TheTVDBBanners* banners;

-(NSString*)getStringPaisAno;
@end
