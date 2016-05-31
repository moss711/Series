//
//  SubtitulosEsSerie.m
//  PruebaParserNyya
//
//  Created by Alexandre Blanco Gómez on 21/2/15.
//  Copyright (c) 2015 Horseware. All rights reserved.
//

#import "SubtitulosEsSerie.h"

@implementation SubtitulosEsSerie

- (NSString *)description {
    return [NSString stringWithFormat: @"Nombre %@ id %d hits %d", self.nombre, self.id,self.hits];
}
@end
