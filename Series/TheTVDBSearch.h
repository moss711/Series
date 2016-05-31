//
//  TheTVDBSearch.h
//  TvTime
//
//  Created by Alexandre Blanco Gómez on 28/2/15.
//  Copyright (c) 2015 Horseware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TheTVDBSerie.h"

@interface TheTVDBSearch : NSObject

@property NSString* nombre;
@property NSArray* series;
@property int idTVRage;

-(instancetype)initWithNombre:(NSString*)nombre idTVRage:(int)idTvRage;

-(TheTVDBSerie*)getPrimeraOpcion;

@end
