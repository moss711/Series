//
//  DescargaTemp.h
//  TvTime
//
//  Created by Alexandre Blanco Gómez on 30/10/14.
//  Copyright (c) 2014 Horseware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Episodio.h"

@class Episodio;

@interface DescargaTemp : NSObject

@property  NSString * magnetLink;
@property NSString *urlTorrent;
@property NSString * nombre;
@property  int peers;
@property  int seeds;
@property  Boolean esHD;
@property  int resolucion;
@property  Boolean esProper;
@property Boolean esMagnet;
@property Episodio * episodio;
@property NSString *releaseGroup;


@end

