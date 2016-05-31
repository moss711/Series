//
//  SubtitulosEsListaSeries.h
//  PruebaParserNyya
//
//  Created by Alexandre Blanco Gómez on 26/2/15.
//  Copyright (c) 2015 Horseware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SubtitulosEsSerie.h"

@interface SubtitulosEsListaSeries : NSObject

@property NSSet *series;

-(NSArray*)getListaSeriesParaNombre:(NSString*)nombre;

-(SubtitulosEsSerie*)getSerieParaNombre:(NSString*)nombre;

@end
